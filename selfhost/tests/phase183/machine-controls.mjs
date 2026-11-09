#!/usr/bin/env bun
// Current checked Bend emitter, unchanged finite Phase181 machine oracles.
// Historical fixture paths identify test data only; no phase build adapter,
// compiler image, Base binding, runtime object or runtime policy is imported.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';

const own = fileURLToPath(import.meta.url);
const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i], value = process.argv[i + 1];
  need(['--api', '--source-check', '--assets', '--out'].includes(key) && value && !Object.hasOwn(args, key), 'Unknown, incomplete, or duplicate option: ' + key);
  args[key] = value;
}
for (const key of ['--api', '--source-check', '--assets', '--out']) need(args[key], 'Required option: ' + key);
const out = path.resolve(args['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh selfhost/build output required');
fs.mkdirSync(out, {recursive: true});
const read = file => JSON.parse(fs.readFileSync(file, 'utf8'));
const fixture = name => path.join(workspace, 'selfhost/tests/phase181', name);
const runtimeDir = path.join(workspace, 'selfhost/src/runtime/qbe');
const report = {
  kind: 'phase183-machine-abi-controls', version: 1, complete: false,
  inputs: [pin(own), pin(process.execPath), pin(path.join(workspace, 'selfhost/tools/build/hosted.mjs')),
    ...['abi-controls.bend', 'hygiene-controls.bend', 'abi-runner.c', 'abi-preserve.s'].map(name => pin(fixture(name))),
    pin(path.join(path.dirname(own), 'abi-contract.c')), pin(path.join(runtimeDir, 'runtime.h')), pin(path.join(runtimeDir, 'primitives.h'))],
  rows: [], jobs: [], runtimeABI: 11102, linkedRuntime: null,
  scope: 'Seventeen actual direct functions pass the unchanged IR verifier and execute against retained literal machine/ABI oracles; ten namespace observations retain their prior expectations. Current source acceptance and header contracts are required separately. No runtime provider, source-language, ownership, broad qualification, or bootstrap claim.',
};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const same = (a, b) => a?.bytes === b?.bytes && a?.sha256 === b?.sha256;
const list = (xs, bound = 64) => {
  const result = [];
  while (xs?.$ === 'Con') {
    need(result.length < bound, 'Unexpected or cyclic fixture list');
    result.push(xs.head); xs = xs.tail;
  }
  need(xs?.$ === 'Nil', 'Malformed fixture list');
  return result;
};
save();

function run(label, command) {
  const begin = performance.now();
  const env = {...process.env}; delete env.LD_PRELOAD; delete env.LD_AUDIT;
  const result = spawnSync(command[0], command.slice(1), {cwd: workspace, env, encoding: 'utf8', timeout: 15000, maxBuffer: 4 * 1024 * 1024});
  const stdout = path.join(out, label + '.stdout'), stderr = path.join(out, label + '.stderr');
  fs.writeFileSync(stdout, result.stdout ?? ''); fs.writeFileSync(stderr, result.stderr ?? '');
  report.jobs.push({label, command, status: result.status, signal: result.signal, error: result.error?.message ?? null,
    seconds: (performance.now() - begin) / 1000, stdout: pin(stdout), stderr: pin(stderr)});
  save();
  need(result.status === 0 && !result.signal && !result.error, label + ' failed');
  if (label === 'execute') need(result.stdout === 'controls pass\n' && result.stderr === '', 'Literal machine/ABI observations differ');
}

try {
  const authority = read(args['--api']), checked = read(args['--source-check']), assets = read(args['--assets']);
  need(authority.kind === 'bend-checked-hosted-api' && authority.complete && authority.checked, 'Current checked hosted emitter API required');
  need(checked.kind === 'bend-independent-source-check' && checked.complete && checked.checked && checked.typeAccepted && checked.unresolvedHoles === 0, 'Independent complete source acceptance required');
  need(same(authority.source, checked.source), 'API and independent check sources differ');
  need(authority.upstream?.revision === assets.upstream && checked.upstream === assets.upstream, 'API/check/assets upstream revisions differ');
  report.source = authority.source;
  report.api = authority.api;
  report.sourceCheck = pin(args['--source-check']);
  report.upstream = assets.upstream;
  report.inputs.push(pin(args['--api']), report.sourceCheck, pin(args['--assets']), authority.api, authority.source, ...checked.inputs);
  const tool = key => {
    const expected = assets.assets?.[key]; need(expected, 'Missing tool asset: ' + key);
    const actual = pin(path.resolve(workspace, expected.file)); need(same(actual, expected), 'Tool asset differs: ' + key);
    report.inputs.push(actual); return actual.file;
  };
  const assembler = tool('assembler'), linker = tool('linker');
  const engine = assets.assets?.bun;
  need(same(pin(process.execPath), engine), 'Pinned Bun engine required');
  const policy = assets.toolchains?.x86;
  need(policy?.target === 'amd64_sysv' && Array.isArray(policy.assemblerFlags) && Array.isArray(policy.linkerFlags) && Array.isArray(policy.libraries), 'Explicit maintained AMD64 SysV x86 machine policy required');
  report.toolchain = policy;
  report.inputs.forEach(verify);
  const api = (await import(pathToFileURL(authority.api.file))).default;
  for (const name of ['p181c_validate', 'p181c_functions', 'p181h_validate', 'p181h_controls', 'x181_direct', 'missing']) need(typeof api?.[name] === 'function', 'Missing checked export: ' + name);
  need(api.p181c_validate() === '', 'Machine fixtures fail unchanged IR verifier');
  need(api.p181h_validate() === '', 'Hygiene fixtures fail unchanged IR verifier');
  report.irVerified = true;
  const expected = ['valid-ir', 'hidden-result-parameter', 'reserved-prefix', 'nested-local', 'nested-alloca', 'call-destination', 'segment-local', 'segment-alloca', 'ordinary-accepted', 'nearby-prefix-accepted'].map(name => name + '=1');
  report.hygiene = list(api.p181h_controls());
  need(JSON.stringify(report.hygiene) === JSON.stringify(expected), 'Hygiene observations differ');
  const functions = list(api.p181c_functions());
  need(functions.length === 17 && functions.every((fn, i) => fn.name === 'p181' + String.fromCharCode(97 + i)), 'Exact machine fixture inventory differs');
  const ids = {$: 'N111Ids', functions: api.missing(), constructors: api.missing()};
  let text = '';
  for (const fn of functions) {
    const emitted = api.x181_direct(fn, ids);
    need(emitted?.$ === 'X181Output' && emitted.error === '', 'x86 refused ' + fn.name + ': ' + emitted?.error);
    const chunks = list(emitted.chunks, 10000); need(chunks.every(chunk => typeof chunk === 'string'), 'Assembly chunks must be strings');
    text += chunks.join(''); report.rows.push({name: fn.name, emitted: true});
  }
  text += '.section .note.GNU-stack,"",@progbits\n';
  const assembly = path.join(out, 'controls.s'); fs.writeFileSync(assembly, text);
  report.assembly = pin(assembly); save();
  run('compile-observer', [linker, '-std=c11', '-O2', '-fno-pie', '-c', fixture('abi-runner.c'), '-o', path.join(out, 'observer.o')]);
  run('compile-current-contract', [linker, '-std=c11', '-O2', '-fno-pie', '-I', runtimeDir, '-c', path.join(path.dirname(own), 'abi-contract.c'), '-o', path.join(out, 'contract.o')]);
  run('assemble-observer', [assembler, ...policy.assemblerFlags, '-o', path.join(out, 'preserve.o'), fixture('abi-preserve.s')]);
  run('assemble-generated', [assembler, ...policy.assemblerFlags, '-o', path.join(out, 'generated.o'), assembly]);
  run('link', [linker, ...policy.linkerFlags, ...['observer.o', 'contract.o', 'preserve.o', 'generated.o'].map(name => path.join(out, name)), ...policy.libraries, '-o', path.join(out, 'controls')]);
  run('execute', [path.join(out, 'controls')]);
  report.binary = pin(path.join(out, 'controls'));
  report.inputs.forEach(verify); report.complete = true;
} catch (error) {
  report.error = String(error.stack ?? error); process.exitCode = 1;
}
save();
console.log(JSON.stringify({complete: report.complete, rows: report.rows.length, hygiene: report.hygiene?.length, error: report.error}));
