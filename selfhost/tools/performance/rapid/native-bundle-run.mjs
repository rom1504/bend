// Experimental closed-bundle native driver boundary. Compiler work stays Bend.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';

const MAX_INPUT_BYTES = 16 * 1024 * 1024;
const sha = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
function regular(file, role) {
  const canonical = fs.realpathSync(file), stat = fs.statSync(canonical);
  if (!stat.isFile()) throw Error(`${role} must be a regular file`);
  if (['input', 'Base', 'runtime'].includes(role) && stat.size > MAX_INPUT_BYTES) throw Error(`${role} exceeds the experimental 16 MiB limit`);
  return {path: canonical, dev: stat.dev, ino: stat.ino, bytes: stat.size};
}
function destination(file, inputs) {
  const absolute = path.resolve(file);
  const canonical = path.join(fs.realpathSync(path.dirname(absolute)), path.basename(absolute));
  let existing;
  try { existing = regular(canonical, 'output'); }
  catch (error) { if (error.code !== 'ENOENT') throw error; }
  for (const input of inputs) {
    if (canonical === input.path || existing && (existing.path === input.path || existing.dev === input.dev && existing.ino === input.ino)) {
      throw Error('Output aliases a protected input: ' + input.path);
    }
  }
  // Reject output symlinks rather than silently replacing their link or target.
  try { if (fs.lstatSync(canonical).isSymbolicLink()) throw Error('Output must not be a symbolic link'); }
  catch (error) { if (error.code !== 'ENOENT') throw error; }
  return canonical;
}

export function runNativeBundle({binary, input, base, runtime, output, mode = 'program', cpu, timeoutMs = 120000}, {spawn = spawnSync} = {}) {
  if (!['program', 'library'].includes(mode)) throw Error('Mode must be program or library');
  if (cpu !== undefined && !/^\d+$/.test(String(cpu))) throw Error('CPU must be a nonnegative integer');
  if (!Number.isSafeInteger(timeoutMs) || timeoutMs <= 0) throw Error('Timeout must be a positive integer');
  const files = {binary: regular(binary, 'binary'), input: regular(input, 'input'), base: regular(base, 'Base'), runtime: regular(runtime, 'runtime')};
  const protectedInputs = Object.values(files);
  const target = destination(output, protectedInputs);
  const hashes = Object.fromEntries(Object.entries(files).map(([name, file]) => [name, sha(file.path)]));
  const temporary = fs.mkdtempSync(path.join(path.dirname(target), '.bend-native-'));
  const temporaryOutput = path.join(temporary, 'output.mjs');
  const args = ['--threads', '1', '--gpu', 'off', '--', files.input.path, files.base.path, files.runtime.path, temporaryOutput, mode];
  const command = cpu === undefined ? files.binary.path : 'taskset';
  const commandArgs = cpu === undefined ? args : ['-c', String(cpu), files.binary.path, ...args];
  const started = performance.now();
  try {
    const result = spawn(command, commandArgs, {encoding: 'utf8', timeout: timeoutMs, maxBuffer: 16 * 1024 * 1024});
    const wallMs = performance.now() - started;
    for (const [name, file] of Object.entries(files)) if (sha(file.path) !== hashes[name]) throw Error(`Protected ${name} changed during execution`);
    const report = {kind: 'experimental-native-closed-bundle-run', mode, cpu: cpu === undefined ? null : Number(cpu), platform: process.platform, architecture: process.arch, cpuModel: os.cpus()[0]?.model,
      files, inputSha256: hashes, output: target, status: result.status, signal: result.signal ?? null, wallMs,
      compileMs: Number(/(?:^|\n)compile_ms=(\d+)/.exec(result.stderr ?? '')?.[1] ?? NaN),
      consumedChars: Number(/(?:^|\n)consumed_chars=(\d+)/.exec(result.stderr ?? '')?.[1] ?? NaN),
      stdout: result.stdout ?? '', stderr: result.stderr ?? '', error: result.error?.message ?? null, published: false,
      scope: 'One main plus optional Base; regular files <=16 MiB; no other imports or external JS assets. compileMs excludes input IO; wallMs includes native process IO and output.'};
    if (result.status === 0 && !result.error) {
      const emitted = regular(temporaryOutput, 'emitted output');
      // Recheck aliases immediately before publication; never publish partial failures.
      destination(target, protectedInputs);
      report.outputBytes = emitted.bytes;
      report.outputSha256 = sha(temporaryOutput);
      fs.renameSync(temporaryOutput, target);
      report.published = true;
    }
    return report;
  } finally { fs.rmSync(temporary, {recursive: true, force: true}); }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [binary, input, base, runtime, output, mode, ...options] = process.argv.slice(2);
  if (![binary, input, base, runtime, output, mode].every(Boolean) || options.some(x => !/^--(?:cpu|timeout-ms)=\d+$/.test(x))) {
    throw Error('usage: node native-bundle-run.mjs BINARY INPUT BASE RUNTIME OUTPUT program|library [--cpu=N] [--timeout-ms=N]');
  }
  const value = key => options.find(x => x.startsWith(`--${key}=`))?.split('=')[1];
  const report = runNativeBundle({binary, input, base, runtime, output, mode, cpu: value('cpu'), timeoutMs: Number(value('timeout-ms') ?? 120000)});
  console.log(JSON.stringify(report, null, 2));
  if (!report.published) process.exitCode = 1;
}
