#!/usr/bin/env node
// Shared Tier-0 stage-timed compile benchmark for Wave 7 100x self-compile campaign.
// Prints exact JSON stage timings: p88_prep, p86_plan, x198pw_plan, x187_prepared, totalMs, objBytes.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

function bytesListToBuffer(list) {
  const bytes = [];
  let cur = list;
  while (cur?.$ === 'Con') {
    bytes.push(cur.head);
    cur = cur.tail;
  }
  return Buffer.from(bytes);
}

const args = process.argv.slice(2);
let apiPath = path.join(ROOT, 'selfhost/build/agy/wave6_unified/api.mjs');
let srcPath = path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend');
let outObj = null;
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--api') apiPath = args[++i];
  else if (args[i] === '--src') srcPath = args[++i];
  else if (args[i] === '--out-obj') outObj = args[++i];
}

const tImport0 = performance.now();
const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;
const importMs = performance.now() - tImport0;

const tPrep0 = performance.now();
const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
if (prep.$ !== 'P86PreparationReady') throw Error(`p88_cache_prepare failed: ${prep.$}`);
const prepSeed = prep.seed;
const prepMs = performance.now() - tPrep0;

const srcText = fs.readFileSync(srcPath, 'utf8');
const tPlan0 = performance.now();
const plan = api.p86_plan(prepSeed, srcPath, srcText);
const planMs = performance.now() - tPlan0;
if (plan.$ !== 'P86PlanReady') {
  console.error(JSON.stringify({ok: false, stage: 'p86_plan', error: plan.error ?? plan.$}));
  process.exit(1);
}

const tPw0 = performance.now();
const prepared = api.x198pw_plan(plan);
const pwMs = performance.now() - tPw0;
if (prepared.error !== '') {
  console.error(JSON.stringify({ok: false, stage: 'x198pw_plan', error: prepared.error}));
  process.exit(1);
}

const tEmit0 = performance.now();
const obj = api.x187_prepared(prepared);
const emitMs = performance.now() - tEmit0;
if (obj.error !== '') {
  console.error(JSON.stringify({ok: false, stage: 'x187_prepared', error: obj.error}));
  process.exit(1);
}

const tBuf0 = performance.now();
const buf = bytesListToBuffer(obj.bytes);
const bufMs = performance.now() - tBuf0;
if (outObj) fs.writeFileSync(outObj, buf);

const totalMs = planMs + pwMs + emitMs + bufMs;
console.log(JSON.stringify({
  ok: true,
  src: path.basename(srcPath),
  srcBytes: srcText.length,
  objBytes: buf.length,
  importMs: +importMs.toFixed(1),
  prepMs: +prepMs.toFixed(1),
  planMs: +planMs.toFixed(1),
  pwMs: +pwMs.toFixed(1),
  emitMs: +emitMs.toFixed(1),
  bufMs: +bufMs.toFixed(1),
  totalMs: +totalMs.toFixed(1),
  rssMib: +(process.memoryUsage().rss / (1024 * 1024)).toFixed(1),
}));
