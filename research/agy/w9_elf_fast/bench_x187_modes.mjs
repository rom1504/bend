#!/usr/bin/env node
// Measure both x187_prepared (-O2) and x187_prepared_fast (-O0) on the same prepared plan
// (matching research/agy/w7_bench/stage_bench.mjs setup).
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

function countBytes(list) {
  let n = 0;
  let cur = list;
  while (cur?.$ === 'Con') {
    n++;
    cur = cur.tail;
  }
  return n;
}

const args = process.argv.slice(2);
let apiPath = path.join(ROOT, 'selfhost/build/agy/wave8_unified/api.mjs');
let srcPath = path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend');
let mode = 'both';
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--api') apiPath = args[++i];
  else if (args[i] === '--src') srcPath = args[++i];
  else if (args[i] === '--mode') mode = args[++i];
}

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
if (prep.$ !== 'P86PreparationReady') throw Error(`p88_cache_prepare failed: ${prep.$}`);

const srcText = fs.readFileSync(srcPath, 'utf8');
const tPlan0 = performance.now();
const plan = api.p86_plan(prep.seed, srcPath, srcText);
const planMs = performance.now() - tPlan0;
if (plan.$ !== 'P86PlanReady') throw Error(`p86_plan failed: ${plan.error ?? plan.$}`);

const tPw0 = performance.now();
const prepared = api.x198pw_plan(plan);
const pwMs = performance.now() - tPw0;
if (prepared.error !== '') throw Error(`x198pw_plan failed: ${prepared.error}`);

const out = {
  ok: true,
  api: apiPath,
  src: path.basename(srcPath),
  srcBytes: srcText.length,
  planMs: +planMs.toFixed(1),
  pwMs: +pwMs.toFixed(1),
};

if (mode === 'both' || mode === 'o2') {
  const t0 = performance.now();
  const obj = api.x187_prepared(prepared);
  const ms = performance.now() - t0;
  if (obj.error !== '') throw Error(`x187_prepared failed: ${obj.error}`);
  out.x187_prepared_ms = +ms.toFixed(1);
  out.x187_prepared_bytes = countBytes(obj.bytes);
}

if (mode === 'both' || mode === 'fast') {
  const t0 = performance.now();
  const obj = api.x187_prepared_fast(prepared);
  const ms = performance.now() - t0;
  if (obj.error !== '') throw Error(`x187_prepared_fast failed: ${obj.error}`);
  out.x187_prepared_fast_ms = +ms.toFixed(1);
  out.x187_prepared_fast_bytes = countBytes(obj.bytes);
}

out.rssMib = +(process.memoryUsage().rss / (1024 * 1024)).toFixed(1);
console.log(JSON.stringify(out));
