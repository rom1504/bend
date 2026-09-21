// Compile already emitted C without repeating Bend checking or C emission.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {findClang, nativeBuildPlan} from '../../native-build.mjs';
const [input, output, ...options] = process.argv.slice(2);
if (!input || !output || options.some(option => !/^--(?:opt=O[0123]|cpu=\d+|timeout-ms=\d+)$/.test(option))) {
  throw Error('usage: node native-compile-c.mjs INPUT.c OUTPUT_BINARY [--opt=O1] [--cpu=N] [--timeout-ms=60000]');
}
const option = (name, fallback) => options.find(value => value.startsWith(`--${name}=`))?.split('=')[1] ?? fallback;
const optimization = option('opt', 'O1'), timeoutMs = Number(option('timeout-ms', '60000')), cpu = option('cpu');
if (!Number.isSafeInteger(timeoutMs) || timeoutMs <= 0) throw Error('Invalid timeout');
if (cpu !== undefined) {
  const affinity = spawnSync('taskset', ['-pc', cpu, String(process.pid)], {encoding: 'utf8'});
  if (affinity.status !== 0) throw Error('Could not set CPU affinity: ' + affinity.stderr);
}
const file = path.resolve(input), binary = path.resolve(output), reportFile = binary + '.build.json';
if (fs.existsSync(binary) || fs.existsSync(reportFile)) throw Error('Use a fresh binary/report path');
const source = fs.readFileSync(file, 'utf8'), sha = value => createHash('sha256').update(value).digest('hex');
const plan = nativeBuildPlan({source, file, binary, target: 'cpu'});
const compiler = findClang({gpu: false});
const args = plan.args.map(argument => argument === '-O3' ? '-' + optimization : argument);
const report = {kind: 'native-c-only-build', started: new Date().toISOString(), complete: false,
  source: file, sourceSha256: sha(source), binary, compiler, args, optimization, timeoutMs,
  cpu: cpu === undefined ? null : Number(cpu), scope: 'C compilation only; Bend checker/emission provenance must accompany this report'};
const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
save(); const start = performance.now();
const result = spawnSync(compiler.command, args, {encoding: 'utf8', timeout: timeoutMs, maxBuffer: 2 ** 20});
Object.assign(report, {milliseconds: performance.now() - start, exitCode: result.status, signal: result.signal,
  stdout: result.stdout, stderr: result.stderr, error: result.error?.message, finished: new Date().toISOString()});
if (result.status === 0 && !result.error) {
  if (sha(fs.readFileSync(file)) !== report.sourceSha256) throw Error('C source changed during compilation');
  report.complete = true; report.binarySha256 = sha(fs.readFileSync(binary));
} else process.exitCode = 1;
save(); console.log(JSON.stringify(report));
