#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const apiPath = process.argv[2] || path.join(ROOT, 'selfhost/build/agy/wave6_unified/api.mjs');
const srcPath = process.argv[3] || path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend');

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

const prep = api.p88_cache_prepare(BASE_PATH, fs.readFileSync(BASE_FILE, 'utf8'), fs.readFileSync(CARRIER_FILE, 'utf8'), STAMP);
const plan = api.p86_plan(prep.seed, srcPath, fs.readFileSync(srcPath, 'utf8'));
const req = plan.request;
const {source, book, names} = req;
const ctors = api.nc_add_ctors(api.nc_default_ctors(), api.p144o_constructors(source, source, api.p144o_payload(api.nc_ctor_context(book))));
const prep112 = api.p112s_prepare(book, names, ctors);
const book2 = prep112.book, nodes = prep112.nodes;
const bangs = api.nc_bangs_names(book2, names);
const scan = api.p128br_scan(book2, api.no_candidate_names(book2, names, bangs), {$:'Nil'}, {$:'Nil'}, {$:'Nil'}, {$:'Nil'});
const [workers, helpers, retry] = [scan.functions ?? scan.workers, scan.helpers, scan.retry];
const ready = api.p113e_signatures(workers, api.missing());
const remaining = api.p167ob_remaining(book2, names, bangs, ready);
const sigs = api.book_cached(api.nq_signatures(book2, names), 0);

// 1. Profile p113pl_candidates per-def!
let okCount = 0, failCount = 0, okMs = 0, failMs = 0, flatFailAfterBoxedFail = 0, flatFailMs = 0;
const errCounts = new Map();
const slowFails = [];
let cur = remaining;
while (cur?.$ === 'Con') {
  const name = cur.head;
  cur = cur.tail;
  const def = api.lookup(book2, name);
  const info = api.lookup(sigs, name);
  const t0 = performance.now();
  const cands = api.p121f_selected(book2, name, sigs, api.p121f_plan(book2, def));
  const dt1 = performance.now() - t0;
  let boxedOk = false;
  let c = cands;
  let errMsg = '';
  while (c?.$ === 'Con') {
    if (c.head.error === '') boxedOk = true;
    else errMsg = c.head.error;
    c = c.tail;
  }
  if (boxedOk) { okCount++; okMs += dt1; }
  else {
    failCount++; failMs += dt1;
    errCounts.set(errMsg, (errCounts.get(errMsg) || 0) + 1);
    slowFails.push([dt1, name, errMsg]);
  }
  if (api.tg(api.dv(info)) === 'NQSig') {
    const tf0 = performance.now();
    const fc = api.p113pl_flat_candidate(book2, name, sigs);
    const dtf = performance.now() - tf0;
    if (!boxedOk) {
      flatFailAfterBoxedFail++;
      flatFailMs += dtf;
    }
  }
}
console.log(`p113pl boxed: ok=${okCount} (${okMs.toFixed(1)}ms) fail=${failCount} (${failMs.toFixed(1)}ms) flatAfterBoxedFail=${flatFailAfterBoxedFail} (${flatFailMs.toFixed(1)}ms)`);
console.log('Top fail reasons:');
for (const [e, cnt] of [...errCounts.entries()].sort((a,b)=>b[1]-a[1]).slice(0, 12)) {
  console.log(`  ${String(cnt).padStart(4)}  ${e}`);
}
console.log('Slowest failed candidates:');
for (const [ms, n, e] of slowFails.sort((a,b)=>b[0]-a[0]).slice(0, 12)) {
  console.log(`  ${ms.toFixed(1).padStart(6)}ms  ${n.padEnd(32)}  ${e}`);
}

// 2. Profile p169o_selected: 1 pass vs 2 passes of p113i_function, and p113i_scan vs p113k_function
const raw = api.p113pl_candidates(book2, remaining, bangs, sigs);
const sc = api.p126sc_candidates(raw);
const fns0 = api.p113d_passes(sc, ready, api.nt_reverse(workers, {$:'Nil'}), 32);
const fns1 = api.w4p_adapt_functions(fns0, ready, workers, sigs);
const plans = api.p169q_plans(book2, retry);
const zipOwners = api.w4c_zip_owners_map(book2);
const sel = api.p169q_selection(book2, plans, api.missing(), api.missing());
let tInl1 = 0, tInl2 = 0, tK = 0, nFns = 0, nInlined1 = 0, nInlined2 = 0;
let table = {$:'P113IEmpty'};
let f = fns1;
while (f?.$ === 'Con') {
  const fn = f.head;
  f = f.tail;
  nFns++;
  const t0 = performance.now();
  const r1 = api.p113i_function(fn, table);
  tInl1 += performance.now() - t0;
  const t1 = performance.now();
  const r2 = api.p113i_function(r1, table);
  tInl2 += performance.now() - t1;
  const t2 = performance.now();
  api.p113k_function(fn);
  tK += performance.now() - t2;
  if (api.p113i_original_clean(fn)) table = api.p113i_table_function(r2, table);
}
console.log(`\np169o: nFns=${nFns} pass1=${tInl1.toFixed(1)}ms pass2=${tInl2.toFixed(1)}ms (single p113k_function=${tK.toFixed(1)}ms)`);

// 3. Profile p167l_functions breakdown
const inlined = api.p169o_selected(fns1, ready, zipOwners, sel);
const priv = api.p167l_private(inlined);
const tCat0 = performance.now();
const cat = api.p167l_catalogue(book2, names, bangs, api.p113e_signatures(inlined, api.missing()), {$:'P167Catalogue', index:api.missing(), error:''});
const tCat = performance.now() - tCat0;
const tLoop0 = performance.now();
const built = api.p167l_loop(
  {$:'P167Context', book:book2, catalogue:cat.index, bangs},
  api.p167l_demand(api.nc_ref_name(book2, 'main'), api.p167l_function_demands(priv, {$:'P167Demand', pending:{$:'Nil'}, asked:api.missing(), count:0})),
  {$:'P167Built', segments:{$:'Nil'}, present:api.missing(), adapters:api.missing(), fresh:0, families:0, factories:0, wrappers:0, demands:0, error:''}
);
const tLoop = performance.now() - tLoop0;
const ordered = api.nt_reverse(built.segments, {$:'Nil'});
const tDedup0 = performance.now();
const pruned = api.w6_dedup_segments(ordered);
const tDedup = performance.now() - tDedup0;
const tFin0 = performance.now();
api.p140or_finish(source, names, ctors, {$:'P111Book', segments:pruned, fresh:built.fresh, error:built.error});
const tFin = performance.now() - tFin0;
console.log(`\np167l_functions: catalogue=${tCat.toFixed(1)}ms loop=${tLoop.toFixed(1)}ms dedup=${tDedup.toFixed(1)}ms p140or_finish=${tFin.toFixed(1)}ms`);
