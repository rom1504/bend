#!/usr/bin/env node
// Emit Wave 10 pure-Bend x86-module ELF .o using `api.w10_module_prepared` (ZERO objcopy!).
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const args = process.argv.slice(2);
let apiPath = '';
let srcPath = '';
let basePath = path.join(ROOT, 'selfhost/dist/base.bend');
let baseKeyPath = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
let carrierPath = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
let stamp = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';
let outObj = '';
let fidBase = 0;
let modName = 'm0';

for (let i = 0; i < args.length; i++) {
  const a = args[i];
  if (a === '--api') apiPath = args[++i];
  else if (a === '--src') srcPath = args[++i];
  else if (a === '--base') basePath = args[++i];
  else if (a === '--base-key') baseKeyPath = args[++i];
  else if (a === '--carrier') carrierPath = args[++i];
  else if (a === '--stamp') stamp = args[++i];
  else if (a === '--out') outObj = args[++i];
  else if (a === '--fid-base') fidBase = Number(args[++i]);
  else if (a === '--mod-name') modName = args[++i];
}

const t0 = performance.now();
const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;
const importMs = performance.now() - t0;

const t1 = performance.now();
const prep = api.p88_cache_prepare(
  baseKeyPath,
  fs.readFileSync(basePath, 'utf8'),
  fs.readFileSync(carrierPath, 'utf8'),
  stamp,
);
const prepMs = performance.now() - t1;
if (prep.$ !== 'P86PreparationReady') {
  console.error(JSON.stringify({ok: false, stage: 'prep', error: prep.error ?? prep.$}));
  process.exit(1);
}

const t2 = performance.now();
const plan = api.p86_plan(prep.seed, srcPath, fs.readFileSync(srcPath, 'utf8'));
const planMs = performance.now() - t2;
if (plan.$ !== 'P86PlanReady') {
  console.error(JSON.stringify({ok: false, stage: 'p86_plan', error: plan.error ?? plan.$}));
  process.exit(1);
}

const t3 = performance.now();
const prepared = api.x198pw_plan(plan);
const pwMs = performance.now() - t3;
if (prepared.error !== '') {
  console.error(JSON.stringify({ok: false, stage: 'x198pw_plan', error: prepared.error}));
  process.exit(1);
}

const segCount = api.w8_cursor_seg_count(prepared.cursor);
const t4 = performance.now();
const obj = api.w10_module_prepared(prepared, prep.seed, fidBase, modName);
const emitMs = performance.now() - t4;
if (obj.error !== '') {
  console.error(JSON.stringify({ok: false, stage: 'w10_module_prepared', error: obj.error}));
  process.exit(1);
}

const t5 = performance.now();
const fd = fs.openSync(outObj, 'w');
const CHUNK = 1024 * 1024;
const buf = Buffer.allocUnsafe(CHUNK);
let off = 0;
let totalBytes = 0;
let cur = obj.bytes;
while (cur?.$ === 'Con') {
  buf[off++] = cur.head & 0xff;
  if (off === CHUNK) {
    fs.writeSync(fd, buf, 0, off);
    totalBytes += off;
    off = 0;
  }
  cur = cur.tail;
}
if (off > 0) {
  fs.writeSync(fd, buf, 0, off);
  totalBytes += off;
}
fs.closeSync(fd);
const writeMs = performance.now() - t5;

console.log(JSON.stringify({
  ok: true,
  mode: 'w10-module',
  modName,
  fidBase,
  segCount,
  objBytes: totalBytes,
  importMs: +importMs.toFixed(1),
  prepMs: +prepMs.toFixed(1),
  planMs: +planMs.toFixed(1),
  pwMs: +pwMs.toFixed(1),
  emitMs: +emitMs.toFixed(1),
  writeMs: +writeMs.toFixed(1),
  compileMs: +(prepMs + planMs + pwMs + emitMs + writeMs).toFixed(1),
}));
