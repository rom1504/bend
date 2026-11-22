#!/usr/bin/env node
// Inclusive + self time V8 CPU profile of x187_prepared on compiler_slice.bend.
import fs from 'node:fs';
import path from 'node:path';
import inspector from 'node:inspector/promises';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';
const SRC_FILE = path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend');

const apiPath = process.argv[2] || path.join(ROOT, 'selfhost/build/agy/wave6_unified/api.mjs');
const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
const srcText = fs.readFileSync(SRC_FILE, 'utf8');
const plan = api.p86_plan(prep.seed, SRC_FILE, srcText);
const prepared = api.x198pw_plan(plan);

const session = new inspector.Session();
session.connect();
await session.post('Profiler.enable');
await session.post('Profiler.setSamplingInterval', { interval: 200 });
await session.post('Profiler.start');
const tp0 = performance.now();
const res2 = api.x187_prepared(prepared);
const tpMs = performance.now() - tp0;
const { profile } = await session.post('Profiler.stop');
session.disconnect();

const parent = new Map();
const nodes = new Map();
for (const n of profile.nodes) nodes.set(n.id, n);
for (const n of profile.nodes) {
  for (const c of (n.children || [])) parent.set(c, n.id);
}

const selfHits = new Map();
const inclHits = new Map();
let totalHits = 0;

for (const n of profile.nodes) {
  const h = n.hitCount || 0;
  if (h <= 0) continue;
  totalHits += h;
  const selfName = n.callFrame.functionName || '(anon)';
  selfHits.set(selfName, (selfHits.get(selfName) || 0) + h);
  const seen = new Set();
  let cur = n.id;
  while (cur !== undefined) {
    const nd = nodes.get(cur);
    const fn = nd.callFrame.functionName || '(anon)';
    if (!seen.has(fn)) {
      seen.add(fn);
      inclHits.set(fn, (inclHits.get(fn) || 0) + h);
    }
    cur = parent.get(cur);
  }
}

console.log(`=== x187_prepared = ${tpMs.toFixed(1)} ms (${totalHits} samples, error=${JSON.stringify(res2.error)}) ===\n`);
console.log('--- TOP 60 INCLUSIVE ---');
const topIncl = [...inclHits.entries()]
  .filter(([fn]) => fn.startsWith('$') || fn.startsWith('('))
  .sort((a, b) => b[1] - a[1])
  .slice(0, 60);
for (const [fn, h] of topIncl) {
  const pct = (100 * h / totalHits).toFixed(1);
  const ms = (tpMs * h / totalHits).toFixed(1);
  const sh = selfHits.get(fn) || 0;
  const sms = (tpMs * sh / totalHits).toFixed(1);
  console.log(`  incl ${pct.padStart(5)}% (${ms.padStart(6)}ms)  self ${sms.padStart(6)}ms  ${fn}`);
}
