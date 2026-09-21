// Compare the same emitted Bend lexer and complete Bend token digest/count.
// Native code uses File.read before its clock. Node reads the same bytes before
// entering the generated workers because pinned File.read uses Bun-only FFI.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const require = createRequire(import.meta.url);
const sha = value => createHash('sha256').update(value).digest('hex');
const [first, second, ...options] = process.argv.slice(2);
if (first === '--worker') {
  const directory = path.resolve(second);
  const preparation = JSON.parse(fs.readFileSync(path.join(directory, 'preparation.json')));
  const source = fs.readFileSync(preparation.input, 'utf8');
  assert.equal(sha(source), preparation.inputSha256);
  const output = require(path.join(directory, 'worker-exposed.cjs'))(source);
  console.log(output.digest); console.log(output.count); console.log(output.milliseconds);
} else {
  if (!first || options.some(option => !/^--cpu=\d+$/.test(option))) throw Error('usage: node native-lexer-measure.mjs OUTPUT_DIRECTORY [REPETITIONS=3] [--cpu=N]');
  const directory = path.resolve(first), repetitions = Number(second || 3);
  if (!Number.isInteger(repetitions) || repetitions < 1) throw Error('Invalid repetition count');
  const cpu = options.find(option => option.startsWith('--cpu='))?.slice(6);
  const reportFile = path.join(directory, 'native-comparison.json');
  if (fs.existsSync(reportFile)) throw Error('Move previous measurement report aside before another run');
  const original = fs.readFileSync(path.join(directory, 'program.cjs'), 'utf8');
  const entry = 'cli(process.argv.slice(2));\nio_exit($main$, null);';
  if (original.split(entry).length !== 2) throw Error('Expected exactly one pinned upstream program entry');
  for (const name of ['f_lex', 'rapid_probe_tokens', 'List$length']) if (!original.includes(`function $${name}$(`)) throw Error('Missing generated worker ' + name);
  const exposed = original.replace(entry, `module.exports = function(source) {
    const start = performance.now();
    const tokens = run_loop($f_lex$(source, 1, 0, 0, {$: "Nil"}));
    const digest = run_loop($rapid_probe_tokens$(tokens, 2166136261));
    const count = Number(run_loop($List$length$(tokens)));
    return {digest, count, milliseconds: performance.now() - start};
  };`);
  fs.writeFileSync(path.join(directory, 'worker-exposed.cjs'), exposed);
  const node = process.env.BEND_BENCH_NODE || process.execPath;
  const commands = {native: [path.join(directory, 'program'), '--threads', '1'],
    javascript: [node, '--stack_size=4096', import.meta.filename, '--worker', directory]};
  const report = {kind: 'native-lexer-and-complete-consumption-comparison', started: new Date().toISOString(), complete: false,
    node: process.version, nodeExecutable: node, cpu: cpu === undefined ? null : Number(cpu), repetitions,
    method: 'Alternating fresh processes. Timed work is the same Bend lexer, full token-text/position/kind digest, and Bend token count. Native clock rounds to milliseconds. Input reading, output printing, emission and Clang build excluded; process wall recorded separately. JavaScript host ABI removes the generated IO main invocation only; emitted Bend workers unchanged.',
    artifacts: Object.fromEntries(['lexer.bend', 'program.c', 'program.cjs', 'program', 'worker-exposed.cjs'].map(file => [file, sha(fs.readFileSync(path.join(directory, file)))])), rows: []};
  const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
  save(); let expected;
  try {
    for (let repetition = 0; repetition < repetitions; repetition++) {
      const order = repetition % 2 ? ['javascript', 'native'] : ['native', 'javascript'];
      for (const variant of order) {
        const command = cpu === undefined ? commands[variant] : ['taskset', '-c', cpu, ...commands[variant]];
        const start = performance.now();
        const child = spawnSync(command[0], command.slice(1), {encoding: 'utf8', cwd: directory, timeout: 30000, maxBuffer: 2 ** 20});
        const row = {variant, repetition, processMilliseconds: performance.now() - start, exitCode: child.status,
          signal: child.signal, stdout: child.stdout, stderr: child.stderr, error: child.error?.message};
        report.rows.push(row); save();
        if (child.error || child.status !== 0) throw Error('Probe failed: ' + JSON.stringify(row));
        const values = child.stdout.trim().split(/\s+/).map(Number);
        assert.equal(values.length, 3); assert(values.every(Number.isFinite));
        [row.digest, row.count, row.milliseconds] = values;
        assert(Number.isInteger(row.digest)); assert(Number.isInteger(row.count));
        expected ??= [row.digest, row.count]; assert.deepEqual([row.digest, row.count], expected);
        save(); console.log(JSON.stringify(row));
      }
    }
    const median = values => { values.sort((a, b) => a - b); const mid = values.length >> 1; return values.length % 2 ? values[mid] : (values[mid - 1] + values[mid]) / 2; };
    report.summary = Object.fromEntries(Object.keys(commands).map(variant => [variant, {
      lexerAndConsumeMedianMilliseconds: median(report.rows.filter(row => row.variant === variant).map(row => row.milliseconds)),
      processMedianMilliseconds: median(report.rows.filter(row => row.variant === variant).map(row => row.processMilliseconds)),
    }]));
    report.complete = true;
  } catch (error) { report.error = error.message; process.exitCode = 1; }
  report.finished = new Date().toISOString(); save(); console.log(JSON.stringify(report));
}
