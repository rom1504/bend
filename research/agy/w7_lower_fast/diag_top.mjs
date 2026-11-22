#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const api = (await import(pathToFileURL(path.join(ROOT, 'selfhost/build/agy/wave6_unified/api.mjs')).href)).default;
const prep = api.p88_cache_prepare(BASE_PATH, fs.readFileSync(BASE_FILE, 'utf8'), fs.readFileSync(CARRIER_FILE, 'utf8'), STAMP);
const plan = api.p86_plan(prep.seed, path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend'), fs.readFileSync(path.join(ROOT, 'research/agy/w7_bench/compiler_slice.bend'), 'utf8'));
const {source, book, names} = plan.request;
const ctors = api.nc_add_ctors(api.nc_default_ctors(), api.p144o_constructors(source, source, api.p144o_payload(api.nc_ctor_context(book))));
const prep112 = api.p112s_prepare(book, names, ctors);
const book2 = prep112.book;
const bangs = api.nc_bangs_names(book2, names);
const scan = api.p128br_scan(book2, api.no_candidate_names(book2, names, bangs), {$:'Nil'}, {$:'Nil'}, {$:'Nil'}, {$:'Nil'});
const workers = scan.functions ?? scan.workers;
const ready = api.p113e_signatures(workers, api.missing());
const remaining = api.p167ob_remaining(book2, names, bangs, ready);
const sigs = api.book_cached(api.nq_signatures(book2, names), 0);

// Top slowest in p113pl_candidates
const plTimes = [];
let cur = remaining;
while (cur?.$ === 'Con') {
  const name = cur.head; cur = cur.tail;
  const def = api.lookup(book2, name);
  const t0 = performance.now();
  const cands = api.p121f_selected(book2, name, sigs, api.p121f_plan(book2, def));
  const dt = performance.now() - t0;
  let sz = 0;
  if (cands?.$ === 'Con') sz = api.p113i_size(cands.head.function.body);
  plTimes.push([dt, name, sz]);
}
console.log('=== TOP 12 SLOWEST p113pl_candidates ===');
for (const [dt, n, sz] of plTimes.sort((a,b)=>b[0]-a[0]).slice(0, 12)) {
  console.log(`  ${dt.toFixed(1).padStart(7)}ms  sz=${String(sz).padStart(5)}  ${n}`);
}

const raw = api.p113pl_candidates(book2, remaining, bangs, sigs);
const fns1 = api.w4p_adapt_functions(
  api.p113d_passes(api.p126sc_candidates(raw), ready, api.nt_reverse(workers, {$:'Nil'}), 32),
  ready, workers, sigs
);

console.log('\n=== TOP 15 SLOWEST p169o (p113i_function) ===');
let table = {$:'P113IEmpty'};
const inlRows = [];
let f = fns1;
while (f?.$ === 'Con') {
  const fn = f.head; f = f.tail;
  const sz0 = api.p113i_size(fn.body);
  const tS0 = performance.now();
  const sc = api.p113i_scan(fn.body, table, 0, 8192);
  const tScan = performance.now() - tS0;
  const sz1 = api.p113i_size(sc.body);
  const tK0 = performance.now();
  const r1 = api.p113k_function({$:'P113DFunction', name:fn.name, params:fn.params, result:fn.result, public:fn.public, body:sc.body});
  const tK = performance.now() - tK0;
  const sz2 = api.p113i_size(r1.body);
  inlRows.push([tScan + tK, tScan, tK, sz0, sz1, sz2, sc.next, fn.name]);
  if (api.p113i_original_clean(fn)) table = api.p113i_table_function(r1, table);
}
for (const [tot, ts, tk, s0, s1, s2, sites, n] of inlRows.sort((a,b)=>b[0]-a[0]).slice(0, 15)) {
  console.log(`  tot=${tot.toFixed(1).padStart(6)}ms (scan=${ts.toFixed(1).padStart(5)} k=${tk.toFixed(1).padStart(6)}) sz:${s0}->${s1}->${s2} sites=${sites} ${n}`);
}
