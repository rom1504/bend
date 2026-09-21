// Compare one checked Bend pipeline emitted to native code and upstream JS.
// Compiler algorithms and complete-output consumption stay in emitted workers.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {runNativeBundle} from './native-bundle-run.mjs';

const require = createRequire(import.meta.url);
const tool = fileURLToPath(import.meta.url);
const sha = value => createHash('sha256').update(value).digest('hex');
const fileSha = file => sha(fs.readFileSync(file));
const canonical = file => fs.realpathSync(path.resolve(file));
const median = values => {
  const sorted = [...values].sort((a, b) => a - b), middle = sorted.length >> 1;
  return sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
};

// Preserve generated workers verbatim. Only replace the pinned program's IO
// entry with exports, since its File.read JS foreign code requires Bun.
export function exposeBundleWorkers(original) {
  const entry = 'cli(process.argv.slice(2));\nio_exit($main$, null);';
  if (original.split(entry).length !== 2) throw Error('Expected exactly one pinned upstream IO program entry');
  for (const name of ['rapid_bundle_compile', 'rapid_bundle_consumed']) {
    if (!original.includes(`function $${name}$(`)) throw Error(`Missing generated worker ${name}`);
  }
  return original.replace(entry, `module.exports = {
  compile: (...args) => run_loop($rapid_bundle_compile$(...args)),
  consume: result => run_loop($rapid_bundle_consumed$(result)),
};`);
}

function worker(requestFile, resultFile) {
  const request = JSON.parse(fs.readFileSync(requestFile, 'utf8'));
  const workers = require(request.exposed);
  const [text, baseText, runtime] = [request.input, request.base, request.runtime]
    .map(file => fs.readFileSync(file, 'utf8'));
  // Import and all input IO finish before timing, matching the native driver.
  const cpuStart = process.cpuUsage(), start = performance.now();
  const result = workers.compile(request.input, request.base, text, baseText, runtime, request.mode === 'library');
  const consumed = workers.consume(result);
  const compileMs = performance.now() - start, cpu = process.cpuUsage(cpuStart);
  const consumedChars = Number(consumed);
  if (!Number.isSafeInteger(consumedChars) || consumedChars < 0) throw Error('Invalid generated consumption result');
  if (result?.$ !== 'RapidBundleResult' || typeof result.source !== 'string' ||
      typeof result.error !== 'string' || typeof result.checked !== 'boolean') {
    throw Error('Unexpected generated result ABI');
  }
  const report = {compileMs, consumedChars, cpuMs: (cpu.user + cpu.system) / 1000,
    maxRssKiB: process.resourceUsage().maxRSS, phase: result.phase, checked: result.checked,
    diagnostic: result.error, outputBytes: Buffer.byteLength(result.source), published: false};
  if (!result.error && result.checked) {
    fs.writeFileSync(request.output, result.source);
    report.outputSha256 = fileSha(request.output);report.published = true;
  } else process.exitCode = 1;
  fs.writeFileSync(resultFile, JSON.stringify(report, null, 2) + '\n');
}

export async function measure(configFile, outputDirectory) {
  const configPath = canonical(configFile), config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const resolveConfig = file => canonical(path.resolve(path.dirname(configPath), file));
  const build = resolveConfig(config.buildDirectory);
  const buildReportFile = path.join(build, 'native-build-report.json');
  const buildReport = JSON.parse(fs.readFileSync(buildReportFile, 'utf8'));
  const cBuildReportFile = config.cBuildReport ? resolveConfig(config.cBuildReport) : null;
  const cBuild = cBuildReportFile ? JSON.parse(fs.readFileSync(cBuildReportFile, 'utf8')) : null;
  const completedPhases = new Set(buildReport.phases?.map(phase => phase.name));
  if (!buildReport.javascript || !buildReport.c || !buildReport.upstreamTrackedFilesClean ||
      !['load', 'check-and-owned', 'javascript-emission', 'c-emission'].every(name => completedPhases.has(name)) ||
      buildReport.pin !== '6018e28ecc67cf1fffc0c20c64b11023474c2df8' ||
      (cBuild ? !cBuild.complete || cBuild.exitCode !== 0 : !buildReport.complete || !buildReport.binary)) {
    throw Error('Pinned checked C/JS emission and a successful native C build are required');
  }
  const binary = canonical(cBuild ? cBuild.binary : buildReport.binary.file);
  const originalJs = canonical(path.join(build, 'program.cjs'));
  if (fileSha(binary) !== (cBuild ? cBuild.binarySha256 : buildReport.binary.sha256) ||
      fileSha(originalJs) !== buildReport.javascript.sha256 || fileSha(buildReport.source) !== buildReport.sourceSha256 ||
      fileSha(buildReport.c.file) !== buildReport.c.sha256 ||
      (cBuild && (canonical(cBuild.source) !== canonical(buildReport.c.file) || cBuild.sourceSha256 !== buildReport.c.sha256))) {
    throw Error('Build inputs/artifacts changed or C-only build does not match checked emission');
  }
  const base = resolveConfig(config.base), runtime = resolveConfig(config.runtime);
  const node = config.node ? resolveConfig(config.node) : canonical(process.execPath);
  const cpu = config.cpu;
  if (!Number.isSafeInteger(cpu) || cpu < 0) throw Error('An explicit nonnegative CPU is required');
  const repetitions = config.repetitions ?? 3, timeoutMs = config.timeoutMs ?? 120000;
  if (!Number.isSafeInteger(repetitions) || repetitions < 1 || !Number.isSafeInteger(timeoutMs) || timeoutMs < 1) {
    throw Error('Invalid repetitions or timeout');
  }
  if (!Array.isArray(config.workloads) || !config.workloads.length) throw Error('At least one workload is required');
  const ids = new Set();
  const workloads = config.workloads.map(workload => {
    if (!/^[a-zA-Z0-9_-]+$/.test(workload.id) || ids.has(workload.id)) throw Error('Invalid or duplicate workload ID');
    ids.add(workload.id);
    const mode = workload.mode ?? 'program';
    if (!['program', 'library'].includes(mode)) throw Error('Mode must be program or library');
    if (mode === 'program' && typeof workload.expected !== 'string') throw Error('Program workloads require expected stdout');
    return {...workload, input: resolveConfig(workload.input), mode};
  });
  const output = path.resolve(outputDirectory);
  fs.mkdirSync(path.dirname(output), {recursive: true});fs.mkdirSync(output);
  const exposed = path.join(output, 'worker-exposed.cjs');
  fs.writeFileSync(exposed, exposeBundleWorkers(fs.readFileSync(originalJs, 'utf8')));
  const artifactPaths = new Set([configPath, tool, canonical(fileURLToPath(new URL('./native-bundle-run.mjs', import.meta.url))),
    binary, originalJs, buildReportFile, buildReport.source, node, base, runtime, exposed,
    ...workloads.map(workload => workload.input)]);
  if (buildReport.c?.file) artifactPaths.add(buildReport.c.file);
  if (cBuildReportFile) artifactPaths.add(cBuildReportFile);
  const artifacts = Object.fromEntries([...artifactPaths].map(file => [file, fileSha(file)]));
  const flags = config.nodeFlags ?? ['--stack-size=4096', '--max-old-space-size=4096'];
  const env = {...process.env, NODE_DISABLE_COMPILE_CACHE: '1'};
  delete env.NODE_OPTIONS;delete env.NODE_COMPILE_CACHE;
  const report = {kind: 'matched-closed-bundle-native-and-upstream-emitted-js', started: new Date().toISOString(),
    complete: false, config: {...config, buildDirectory: build, cBuildReport: cBuildReportFile, base, runtime, node, workloads}, artifacts,
    buildProvenance: {checkedEmissionReport: buildReportFile, originalCombinedBuildComplete: buildReport.complete,
      cBuildReport: cBuildReportFile, cOptimization: cBuild?.optimization ?? 'See original native build report',
      note: cBuild ? 'Separate successful C compilation of the identical checked C source; original interrupted/failed build report is preserved unchanged.' : 'Completed combined build'},
    platform: process.platform, architecture: process.arch, cpuModel: os.cpus()[0]?.model,
    loadStart: os.loadavg(), cpu, repetitions, nodeFlags: flags, rows: [],
    method: 'Alternating fresh processes on one CPU. Both execute the same checked Bend rapid_bundle_compile and rapid_bundle_consumed workers. Inputs and runtime are preloaded before inner timing; generated output/error is fully consumed before the clock stops. File output, validation, startup and worker import are excluded from compileMs. Process wall includes each process IO, startup and output. Native clock has millisecond resolution. This compares backend execution of the Bend compiler, not the handwritten TypeScript compiler.',
    scope: 'Main plus optional Base only; no cache, other imports or external JS assets. Same canonical module paths and runtime bytes in both variants. A library validation imports emitted JS but does not exercise every exported function.'};
  const reportFile = path.join(output, 'report.json');
  const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
  const unchanged = () => Object.entries(artifacts).every(([file, hash]) => {
    try { return fileSha(file) === hash; } catch { return false; }
  });
  const spawn = (command, args, options) => spawnSync(command, args, {...options, env});
  const runNode = (args, limit = timeoutMs) => {
    const command = ['taskset', '-c', String(cpu), node, ...flags, ...args];
    const start = performance.now();
    const child = spawn(command[0], command.slice(1), {encoding: 'utf8', timeout: limit, maxBuffer: 16 * 1024 * 1024});
    return {child, command, wallMs: performance.now() - start};
  };
  const validate = (file, workload) => {
    const syntax = runNode(['--check', file], workload.runTimeoutMs ?? 15000);
    const result = {syntaxExitCode: syntax.child.status, syntaxStderr: syntax.child.stderr,
      syntaxError: syntax.child.error?.message ?? null, scope: workload.mode === 'program' ? 'program execution' : 'library import only'};
    if (syntax.child.status !== 0 || syntax.child.error) return {...result, passed: false};
    const execution = runNode([file, ...(workload.args ?? [])], workload.runTimeoutMs ?? 15000);
    return {...result, exitCode: execution.child.status, stdout: execution.child.stdout, stderr: execution.child.stderr,
      error: execution.child.error?.message ?? null, expected: workload.expected ?? '',
      passed: !execution.child.error && execution.child.status === 0 && execution.child.stdout.trim() === (workload.expected ?? '').trim()};
  };
  save();
  try {
    for (const workload of workloads) {
      let expectedBytes, expectedConsumed;
      // Reuse this destination for both implementations; preserve each completed
      // artifact separately after measurement so output-location policy matches.
      const emitted = path.join(output, `${workload.id}-current.mjs`);
      for (let repetition = 0; repetition < repetitions; repetition++) {
        for (const variant of repetition % 2 ? ['javascript', 'native'] : ['native', 'javascript']) {
          if (!unchanged()) throw Error('A frozen input changed before invocation');
          fs.rmSync(emitted, {force: true});
          const stem = `${workload.id}-${repetition}-${variant}`;
          const row = {workload: workload.id, variant, repetition, mode: workload.mode, status: 'running'};
          report.rows.push(row);save();
          try {
            if (variant === 'native') {
              const result = runNativeBundle({binary, input: workload.input, base, runtime, output: emitted,
                mode: workload.mode, cpu, timeoutMs: workload.timeoutMs ?? timeoutMs}, {spawn});
              Object.assign(row, {processMs: result.wallMs, compileMs: result.compileMs, consumedChars: result.consumedChars,
                exitCode: result.status, signal: result.signal, stdout: result.stdout, stderr: result.stderr,
                error: result.error, published: result.published, nativeReport: result});
            } else {
              const requestFile = path.join(output, `${stem}.request.json`), resultFile = path.join(output, `${stem}.result.json`);
              fs.writeFileSync(requestFile, JSON.stringify({exposed, input: workload.input, base, runtime, output: emitted, mode: workload.mode}));
              const {child, command, wallMs} = runNode([tool, '--worker', requestFile, resultFile], workload.timeoutMs ?? timeoutMs);
              Object.assign(row, {processMs: wallMs, command, exitCode: child.status, signal: child.signal,
                stdout: child.stdout, stderr: child.stderr, error: child.error?.message ?? null});
              if (fs.existsSync(resultFile)) Object.assign(row, JSON.parse(fs.readFileSync(resultFile, 'utf8')));
            }
            fs.writeFileSync(path.join(output, `${stem}.stdout`), row.stdout ?? '');
            fs.writeFileSync(path.join(output, `${stem}.stderr`), row.stderr ?? '');
            row.status = row.exitCode === 0 && !row.error && row.published && Number.isFinite(row.compileMs) &&
              Number.isSafeInteger(row.consumedChars) && row.consumedChars >= 0 ? 'ok' : 'failed';
            if (row.status === 'ok') {
              const bytes = fs.readFileSync(emitted);
              expectedBytes ??= bytes;
              expectedConsumed ??= row.consumedChars;
              row.outputBytes = bytes.length;row.outputSha256 = sha(bytes);row.bytesEqual = bytes.equals(expectedBytes);
              row.consumptionEqual = row.consumedChars === expectedConsumed;
              const archived = path.join(output, `${stem}.mjs`);fs.copyFileSync(emitted, archived);
              row.validation = validate(emitted, workload);
              if (!row.bytesEqual) row.status = 'different-emitted-bytes';
              if (!row.consumptionEqual) row.status = 'different-consumption-result';
              if (!row.validation.passed) row.status = 'invalid-output';
            }
          } catch (error) { row.status = 'failed';row.error = error.message; }
          save();console.log(JSON.stringify(row));
          if (!unchanged()) throw Error('A frozen input changed during invocation');
        }
      }
    }
    report.inputsUnchanged = unchanged();
    report.summary = workloads.flatMap(workload => ['native', 'javascript'].map(variant => {
      const rows = report.rows.filter(row => row.workload === workload.id && row.variant === variant);
      const successful = rows.filter(row => row.status === 'ok');
      const cell = {workload: workload.id, variant, attempted: rows.length, successful: successful.length};
      if (successful.length === rows.length) {
        for (const key of ['compileMs', 'processMs']) cell[key] = {median: median(rows.map(row => row[key])), min: Math.min(...rows.map(row => row[key])), max: Math.max(...rows.map(row => row[key]))};
      }
      return cell;
    }));
    report.complete = report.inputsUnchanged && report.rows.every(row => row.status === 'ok');
  } catch (error) { report.error = error.message;report.inputsUnchanged = unchanged(); }
  report.finished = new Date().toISOString();report.loadEnd = os.loadavg();save();
  if (!report.complete) process.exitCode = 1;
  console.log(JSON.stringify({report: reportFile, complete: report.complete, summary: report.summary}));
  return report;
}

if (process.argv[1] && path.resolve(process.argv[1]) === tool) {
  if (process.argv[2] === '--worker') worker(process.argv[3], process.argv[4]);
  else {
    if (process.argv.length !== 4) throw Error('usage: node native-bundle-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
    await measure(process.argv[2], process.argv[3]);
  }
}
