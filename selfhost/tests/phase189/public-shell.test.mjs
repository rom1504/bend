// Evaluate the real launcher body with mocked I/O and child transport only.
// No compiler, Python child, installed API, or generated program executes.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {fileURLToPath} from 'node:url';

const cliURL = new URL('../../cli.mjs', import.meta.url);
const cli = fileURLToPath(cliURL);
const source = fs.readFileSync(cli, 'utf8')
  .replace(/^import [^\n]+\n/gm, '')
  .replace('import.meta.url', '__moduleURL');

async function route(args, result = {status: 0}) {
  const calls = [], errors = [];
  let selectorReads = 0;
  const process = {argv: ['node', cli, ...args], env: {}, exitCode: undefined};
  const context = {
    __moduleURL: cliURL.href, path, fileURLToPath, process,
    fs: {readFileSync(file) {
      assert.equal(file, path.resolve(path.dirname(cli), 'manifests/current.json'));
      selectorReads++;
      throw Error('ordinary-selected-route');
    }},
    spawnSync(...call) {calls.push(call); return result;},
    console: {error(message) {errors.push(message);}},
  };
  vm.runInNewContext(source, context, {filename: cli});
  await new Promise(resolve => setImmediate(resolve));
  return {calls, errors, selectorReads, status: process.exitCode};
}

const cases = [
  [['--target', 'x86', 'input.bend', '-o', 'program'], true],
  [['--target=x86', 'input.bend', '--run', '--', '', 'a b', '+RTS'], true],
  [['input.bend', '-o', 'program.s'], true],
  [['input.bend', '--output', 'program.s'], true],
  [['input.bend', '-o', 'program.c'], false],
  [['input.bend', '-o', 'program.mjs'], false],
  [['--target', 'qbe', 'input.bend', '-o', 'program.ssa'], false],
  [['--version'], false],
  [['input.bend', '--run', '--', '--target', 'x86'], false],
  [['input.bend', '--run', '--', '--target=x86'], false],
  [['input.bend', '--run', '--', '-o', 'application.s'], false],
];
for (const [args, x86] of cases) {
  const observed = await route(args, {status: 23});
  assert.equal(observed.calls.length, x86 ? 1 : 0);
  assert.equal(observed.selectorReads, x86 ? 0 : 1);
  if (x86) {
    assert.deepEqual(JSON.parse(JSON.stringify(observed.calls[0])), [
      'python3', ['-B', path.resolve(path.dirname(cli), 'tools/build/public-native.py'), ...args],
      {stdio: 'inherit'},
    ]);
    assert.equal(observed.status, 23);
    assert.deepEqual(observed.errors, []);
  } else {
    assert.equal(observed.status, 1);
    assert.deepEqual(observed.errors, ['ordinary-selected-route']);
  }
}
const args = ['--target=x86', 'input.bend', '--run'];
assert.equal((await route(args, {status: 0})).status, 0);
const signal = await route(args, {status: null, signal: 'SIGTERM'});
assert.equal(signal.status, 1);
assert.deepEqual(signal.errors, ['x86 command terminated by SIGTERM']);
const failed = await route(args, {error: Error('mock spawn refusal')});
assert.equal(failed.status, 1);
assert.deepEqual(failed.errors, ['mock spawn refusal']);
console.log('phase189 public shell controls pass: 14');
