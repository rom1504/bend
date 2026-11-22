#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import inspector from 'node:inspector';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const args = process.argv.slice(2);
let apiPath = path.join(ROOT, 'selfhost/build/agy/wave6_unified/api.mjs');
let srcPath = path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend');
let profileEmit = false;
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--api') apiPath = args[++i];
  else if (args[i] === '--src') srcPath = args[++i];
  else if (args[i] === '--emit') profileEmit = true;
}

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
if (prep.$ !== 'P86PreparationReady') throw Error(`prep failed: ${prep.$}`);

const srcText = fs.readFileSync(srcPath, 'utf8');
const tPlan0 = performance.now();
const plan = api.p86_plan(prep.seed, srcPath, srcText);
const planMs = performance.now() - tPlan0;
if (plan.$ !== 'P86PlanReady') throw Error(`plan failed: ${plan.$}`);

const session = new inspector.Session();
session.connect();
const post = (m, p) => new Promise((res, rej) => session.post(m, p || {}, (e, r) => e ? rej(e) : res(r)));

await post('Profiler.enable');
await post('Profiler.setSamplingInterval', {interval: 200});
await post('Profiler.start');

const tPw0 = performance.now();
const prepared = api.x198pw_plan(plan);
const pwMs = performance.now() - tPw0;
if (prepared.error !== '') throw Error(`pw failed: ${prepared.error}`);

let emitMs = 0;
if (profileEmit) {
  const tE0 = performance.now();
  const obj = api.x187_prepared(prepared);
  emitMs = performance.now() - tE0;
  if (obj.error !== '') throw Error(`emit failed: ${obj.error}`);
}

const {profile} = await post('Profiler.stop');
session.disconnect();

// Compute self hits and inclusive hits per functionName
const nodes = new Map();
for (const n of profile.nodes) nodes.set(n.id, n);
const parent = new Map();
for (const n of profile.nodes) {
  for (const c of (n.children || [])) parent.set(c, n.id);
}

const selfHits = new Map();
const totalHits = new Map();
const samples = profile.samples || [];
for (const id of samples) {
  const n = nodes.get(id);
  const fn = (n?.callFrame?.functionName) || '(anon)';
  selfHits.set(fn, (selfHits.get(fn) || 0) + 1);
  const seen = new Set();
  let cur = id;
  while (cur !== undefined) {
    const cn = nodes.get(cur);
    const cfn = (cn?.callFrame?.functionName) || '(anon)';
    if (!seen.has(cfn)) {
      seen.add(cfn);
      totalHits.set(cfn, (totalHits.get(cfn) || 0) + 1);
    }
    cur = parent.get(cur);
  }
}

const totalSamples = samples.length || 1;
const msPerSample = (profileEmit ? (pwMs + emitMs) : pwMs) / totalSamples;

console.log(`src=${path.basename(srcPath)} (${srcText.length}B) planMs=${planMs.toFixed(1)} pwMs=${pwMs.toFixed(1)} emitMs=${emitMs.toFixed(1)} samples=${totalSamples}`);

// Count cursor items
let privCount = 0, pubCount = 0, tabCount = 0, privStmts = 0, pubStmts = 0, maxPrivStmts = 0, maxPrivName = '';
function countP113DStmts(list) {
  let c = 0, cur = list;
  while (cur?.$ === 'Con') {
    c++;
    const s = cur.head;
    if (s?.$ === 'P113DIf') c += countP113DStmts(s.yes) + countP113DStmts(s.no);
    cur = cur.tail;
  }
  return c;
}
function listLen(l) { let c = 0, cur = l; while (cur?.$ === 'Con') { c++; cur = cur.tail; } return c; }
let cur = prepared.cursor;
while (cur) {
  if (cur.$ === 'P134Private') {
    let f = cur.functions;
    while (f?.$ === 'Con') {
      privCount++;
      const sc = countP113DStmts(f.head.body);
      privStmts += sc;
      if (sc > maxPrivStmts) { maxPrivStmts = sc; maxPrivName = f.head.name; }
      f = f.tail;
    }
    cur = cur.next;
  } else if (cur.$ === 'P134Public') {
    let s = cur.segments;
    while (s?.$ === 'Con') {
      pubCount++;
      pubStmts += listLen(s.head.body);
      s = s.tail;
    }
    cur = cur.next;
  } else if (cur.$ === 'P134Legacy') {
    cur = cur.next;
  } else if (cur.$ === 'P134Tables') {
    tabCount += listLen(cur.tables);
    break;
  } else break;
}
console.log(`cursor: privFns=${privCount} (stmts=${privStmts}, max=${maxPrivStmts} in ${maxPrivName}) pubSegs=${pubCount} (stmts=${pubStmts}) tables=${tabCount}`);

console.log('\n=== TOP INCLUSIVE (total time) ===');
const topInc = [...totalHits.entries()].sort((a, b) => b[1] - a[1]).slice(0, 35);
for (const [fn, h] of topInc) {
  console.log(`${(h * msPerSample).toFixed(1).padStart(8)} ms (${(100 * h / totalSamples).toFixed(1).padStart(5)}%)  ${fn}`);
}

console.log('\n=== TOP SELF ===');
const topSelf = [...selfHits.entries()].sort((a, b) => b[1] - a[1]).slice(0, 25);
for (const [fn, h] of topSelf) {
  console.log(`${(h * msPerSample).toFixed(1).padStart(8)} ms (${(100 * h / totalSamples).toFixed(1).padStart(5)}%)  ${fn}`);
}
