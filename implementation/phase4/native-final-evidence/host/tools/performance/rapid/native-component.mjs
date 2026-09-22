// Checked native experiment build. The algorithms remain in the supplied Bend
// source; this tool only calls the pinned upstream compiler and host C compiler.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {spawnFileCapture as spawnSync} from './native-file-capture.mjs';
import {buildNative} from '../../native-build.mjs';

const [input, outputDirectory, ...options] = process.argv.slice(2);
if (!input || !outputDirectory || options.some(option => !['--js', '--build'].includes(option) && !/^--cpu=\d+$/.test(option))) {
  throw Error('usage: node native-component.mjs SOURCE.bend OUTPUT_DIRECTORY [--js] [--build] [--cpu=N]');
}
const source = path.resolve(input), output = path.resolve(outputDirectory);
const root = path.resolve(import.meta.dirname, '../../..');
const upstream = path.resolve(process.env.BEND_UPSTREAM || path.join(root, '.bootstrap/upstream'));
const pin = '6018e28ecc67cf1fffc0c20c64b11023474c2df8';
const cpu = options.find(option => option.startsWith('--cpu='))?.slice(6);
if (cpu !== undefined) {
  const affinity = await spawnSync('taskset', ['-pc', cpu, String(process.pid)], {encoding: 'utf8'});
  if (affinity.status !== 0) throw Error('Could not set CPU affinity: ' + affinity.stderr);
}
const sha = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
fs.mkdirSync(output, {recursive: true});
const reportFile = path.join(output, 'native-build-report.json');
if (fs.existsSync(reportFile)) throw Error('Use a fresh output directory to preserve prior build evidence');
const report = {kind: 'checked-native-component-build', started: new Date().toISOString(), complete: false,
  node: process.version, nodeExecutable: process.execPath, cpu: cpu === undefined ? null : Number(cpu), source, sourceSha256: sha(source), upstream, pin, options, phases: [],
  toolSha256: sha(import.meta.filename), scope: 'Native experiment build, not compiler self-hosting or full language conformance'};
const save = () => fs.writeFileSync(reportFile, JSON.stringify(report, null, 2) + '\n');
const phase = async (name, action) => {
  report.currentPhase = name; save(); console.error(`[native ${new Date().toISOString()}] ${name}`); const start = performance.now();
  const result = await action(); report.phases.push({name, milliseconds: performance.now() - start});
  delete report.currentPhase; save(); return result;
};
save();
try {
  const revision = await spawnSync('git', ['-C', upstream, 'rev-parse', 'HEAD'], {encoding: 'utf8'});
  if (revision.error || revision.signal || revision.status !== 0 || revision.stdout.trim() !== pin) throw Error('Expected the pinned upstream checkout');
  const status = await spawnSync('git', ['-C', upstream, 'status', '--porcelain', '--untracked-files=no'], {encoding: 'utf8'});
  if (status.error || status.signal || status.status !== 0 || status.stdout.trim()) throw Error('Pinned upstream has modified tracked files');
  report.upstreamTrackedFilesClean = true;
  report.upstreamFiles = ['bend2/bend.ts', 'bend2/comp.ts', 'bend2/base.bend'].map(file => ({file, sha256: sha(path.join(upstream, file))}));
  const B = await import(pathToFileURL(path.join(upstream, 'bend2/bend.ts')));
  const C = await import(pathToFileURL(path.join(upstream, 'bend2/comp.ts')));
  const book = B.book_nil();
  try {
    await phase('load', () => B.book_load(book, source, '', new Map()));
    await phase('check-and-owned', () => {
      B.book_valid(book); C.book_owned(book, C.SYNTH);
      if (book.hols + book.open) throw Error('Unresolved laws or holes');
    });
    if (options.includes('--js')) {
      const file = path.join(output, 'program.cjs');
      fs.writeFileSync(file, await phase('javascript-emission', () => C.js_book(book)));
      report.javascript = {file, sha256: sha(file)}; save();
    }
    const file = path.join(output, 'program.c');
    const c = await phase('c-emission', () => C.compile_book(book));
    fs.writeFileSync(file, c); report.c = {file, sha256: sha(file), bytes: Buffer.byteLength(c)}; save();
    if (options.includes('--build')) {
      const binary = path.join(output, 'program');
      report.native = await phase('clang', () => buildNative({source: c, file, binary, target: 'cpu', cwd: output,
        timeoutMs: Number(process.env.BEND_NATIVE_BUILD_TIMEOUT || 60000)}));
      if (report.native.status !== 'ok') throw Error(report.native.diagnostic || report.native.reason || report.native.status);
      report.binary = {file: binary, sha256: sha(binary)};
    }
    if (sha(source) !== report.sourceSha256) throw Error('Source changed during build');
    report.complete = true;
  } catch (error) { throw Error(error?.$ === 'Err' ? B.err_show(error) : String(error)); }
} catch (error) { report.error = error.message; process.exitCode = 1; }
report.maxNodeRssKiB = process.resourceUsage().maxRSS;
report.finished = new Date().toISOString(); save();
console.log(JSON.stringify(report));
