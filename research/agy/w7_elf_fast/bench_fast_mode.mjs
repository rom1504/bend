#!/usr/bin/env node
// Benchmark & verify x187_prepared_fast (x86-object-fast / -O0) vs x187_prepared (-O2) on compiler_slice.bend.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';
const SRC_FILE = path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend');
const RT = path.join(ROOT, 'selfhost/build/agy/unified/runtime-agy.o');
const CC = '/usr/bin/x86_64-linux-gnu-gcc-10';

function bytesListToBuffer(list) {
  const bytes = [];
  let cur = list;
  while (cur?.$ === 'Con') {
    bytes.push(cur.head);
    cur = cur.tail;
  }
  return Buffer.from(bytes);
}

const apiPath = process.argv[2] || '/tmp/agy_w7_elf_fast/api.mjs';
const mode = process.argv[3] || 'fast';
const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
const srcText = fs.readFileSync(SRC_FILE, 'utf8');
const plan = api.p86_plan(prep.seed, SRC_FILE, srcText);
const prepared = api.x198pw_plan(plan);

const t0 = performance.now();
const obj = mode === 'fast' ? api.x187_prepared_fast(prepared) : api.x187_prepared(prepared);
const emitMs = performance.now() - t0;
if (obj.error !== '') {
  console.error(JSON.stringify({ok: false, mode, error: obj.error}));
  process.exit(1);
}
const tBuf0 = performance.now();
const buf = bytesListToBuffer(obj.bytes);
const bufMs = performance.now() - tBuf0;

const objPath = `/tmp/agy_w7_elf_fast/slice_${mode}.o`;
const exePath = `/tmp/agy_w7_elf_fast/slice_${mode}`;
fs.writeFileSync(objPath, buf);
execFileSync(CC, ['-no-pie', objPath, RT, '-o', exePath, '-lm', '-lpthread']);
const out = execFileSync(exePath, [], {encoding: 'utf8', timeout: 15000}).trim();
fs.unlinkSync(objPath);
fs.unlinkSync(exePath);

console.log(JSON.stringify({
  ok: out === '34',
  mode,
  out,
  objBytes: buf.length,
  emitMs: +emitMs.toFixed(1),
  bufMs: +bufMs.toFixed(1),
}, null, 2));
if (out !== '34') process.exit(1);
