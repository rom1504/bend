#!/usr/bin/env node
// Profile x187_prepared_fast and x187_prepared on compiler_slice_750kb.bend
import fs from 'node:fs';
import path from 'node:path';
import inspector from 'node:inspector/promises';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const args = process.argv.slice(2);
let apiPath = path.join(ROOT, 'selfhost/build/agy/wave7_unified/api.mjs');
let srcPath = path.join(ROOT, 'research/agy/w7_bench/compiler_slice_750kb.bend');
let mode = 'fast';
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
const srcText = fs.readFileSync(srcPath, 'utf8');
const plan = api.p86_plan(prep.seed, srcPath, srcText);
const prepared = api.x198pw_plan(plan);

// Count cursor items
let privCount = 0, pubCount = 0, tblCount = 0;
let cur = prepared.cursor;
while (cur) {
  if (cur.$ === 'P134Private') {
    let l = cur.functions; while (l?.$ === 'Con') { privCount++; l = l.tail; }
    cur = cur.next;
  } else if (cur.$ === 'P134Public') {
    let l = cur.segments; while (l?.$ === 'Con') { pubCount++; l = l.tail; }
    cur = cur.next;
  } else if (cur.$ === 'P134Legacy') {
    cur = cur.next;
  } else if (cur.$ === 'P134Tables') {
    let l = cur.tables; while (l?.$ === 'Con') { tblCount++; l = l.tail; }
    cur = null;
  } else break;
}
console.log(`src=${path.basename(srcPath)} (${srcText.length} B): private=${privCount}, public=${pubCount}, tables=${tblCount}`);

const session = new inspector.Session();
session.connect();
await session.post('Profiler.enable');
await session.post('Profiler.setSamplingInterval', { interval: 200 });
await session.post('Profiler.start');
const tp0 = performance.now();
const res = mode === 'o2' ? api.x187_prepared(prepared) : api.x187_prepared_fast(prepared);
const tpMs = performance.now() - tp0;
const { profile } = await session.post('Profiler.stop');
session.disconnect();

let objBytes = 0;
let c = res.bytes;
while (c?.$ === 'Con') { objBytes++; c = c.tail; }

const parent = new Map();
const nodes = new Map();
for (const n of profile.nodes) nodes.set(n.id, n);
for (const n of profile.nodes) {
  for (const ch of (n.children || [])) parent.set(ch, n.id);
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
  let curId = n.id;
  while (curId !== undefined) {
    const nd = nodes.get(curId);
    const fn = nd.callFrame.functionName || '(anon)';
    if (!seen.has(fn)) {
      seen.add(fn);
      inclHits.set(fn, (inclHits.get(fn) || 0) + h);
    }
    curId = parent.get(curId);
  }
}

console.log(`=== ${mode} = ${tpMs.toFixed(1)} ms, objBytes=${objBytes}, error=${JSON.stringify(res.error)}, samples=${totalHits} ===\n`);
console.log('--- TOP INCLUSIVE ---');
for (const [fn, h] of [...inclHits.entries()].filter(([fn]) => fn.startsWith('$') || fn.startsWith('(')).sort((a,b) => b[1]-a[1]).slice(0, 35)) {
  console.log(`  incl ${(100*h/totalHits).toFixed(1).padStart(5)}% (${(tpMs*h/totalHits).toFixed(1).padStart(6)}ms)  self ${(tpMs*(selfHits.get(fn)||0)/totalHits).toFixed(1).padStart(6)}ms  ${fn}`);
}
console.log('\n--- TOP SELF ---');
for (const [fn, h] of [...selfHits.entries()].sort((a,b) => b[1]-a[1]).slice(0, 25)) {
  console.log(`  self ${(100*h/totalHits).toFixed(1).padStart(5)}% (${(tpMs*h/totalHits).toFixed(1).padStart(6)}ms)  incl ${(tpMs*(inclHits.get(fn)||0)/totalHits).toFixed(1).padStart(6)}ms  ${fn}`);
}
