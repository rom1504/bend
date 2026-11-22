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

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
const seed = prep.seed;
const srcText = fs.readFileSync(srcPath, 'utf8');

function time(name, fn) {
  const t0 = performance.now();
  const res = fn();
  const ms = performance.now() - t0;
  console.log(`${name.padEnd(32)} ${ms.toFixed(1).padStart(8)} ms`);
  return res;
}

const tAll = performance.now();
const seedKeys = Object.keys(seed);
const base = seed[seedKeys[1]];
const book0 = seed[seedKeys[2]];
const fresh = seed[seedKeys[3]];
const ready = seed[seedKeys[4]];
const world = seed[seedKeys[5]];

const b0 = api.f_source_end(base);
const w0 = api.p86_width(srcText, 0);
const innerKeys = Object.keys(base.source);
const fsrc = {$: base.source.$};
fsrc[innerKeys[1]] = srcPath;
fsrc[innerKeys[2]] = srcPath;
fsrc[innerKeys[3]] = srcText;
if (true) {
  const srcLoc = api.f_source_located(fsrc, b0, (b0 + w0 + 1) >>> 0);
  const header = time('1. f_source_header', () => api.f_source_header(srcLoc));
  const cSeed = time('2. f_prefix_complete_ready_seed', () =>
    api.f_prefix_complete_ready_seed(base, '', api.f_prefix_graph_empty(), api.f_source_path(base), api.f_source_text(base), book0, ready));
  const sourcesList = {$: 'Con', head: srcLoc, tail: {$: 'Con', head: base, tail: {$: 'Nil'}}};
  const cKeys = Object.keys(cSeed);
  const carrier0 = cSeed[cKeys[1]];
  const cSrc = time('3. f_prefix_complete_source', () =>
    api.f_prefix_complete_source(srcLoc, '', header, sourcesList, carrier0, api.f_path_dir(api.f_source_path(srcLoc))));
  const carrier1 = cSrc[cKeys[1]];
  const load = time('4. f_prefix_graph_trace', () =>
    api.f_prefix_graph_trace(carrier1, sourcesList, fresh));
  const lKeys = Object.keys(load);
  const trace = load[lKeys[1]];
  const suffix = load[lKeys[3]];
  const tKeys = Object.keys(trace);
  const result0 = trace[tKeys[1]];
  const rKeys = Object.keys(result0);
  const original = result0[rKeys[1]];
  const enough = api.p143cg_enough(suffix, 256);
  console.log('   p143cg_enough(suffix, 256):', enough.$);
  const checked = time('5. check_program', () =>
    enough === true || enough?.$ === 'True'
      ? api.p143cb_program(load, {$: 'Nil'}, world, {$: 'True'})
      : api.check_program_diagnostic_world(load, {$: 'Nil'}, world));
  const dKeys = Object.keys(checked);
  const book = checked[dKeys[2]];
  const report = time('6. driver_report_data', () => api.driver_report_data(original));
  const repKeys = Object.keys(report);
  const verdict = report[repKeys[1]];
  const ownedErr = time('7. driver_emit_owned', () => api.driver_emit_owned(book));
  const jErr = time('8. j_compile_error', () => api.j_compile_error(book));
  const context = time('9. book_context_world', () => api.book_context_world(book, load, world));
  const stops = time('10. nc_annotation_stops', () => api.nc_annotation_stops(context));
  const mainList = {$: 'Con', head: 'main', tail: {$: 'Nil'}};
  const reached = time('11. reach_book', () => api.reach_book(context, mainList, stops));
  const annotated = time('12. annotate_selected', () => api.annotate_selected(context, reached, stops));
  const jlErr = time('13. jl_checked_error', () => api.jl_checked_error(context, annotated, mainList, stops));
  const finalPlan = time('14. agy_bf_plan', () => api.agy_bf_plan(context, stops, verdict, annotated));
  console.log('finalPlan.$:', finalPlan.$, 'total:', (performance.now() - tAll).toFixed(1), 'ms');
} else {
  const plan = time('p86_plan (full)', () => api.p86_plan(seed, srcPath, srcText));
  console.log('plan.$:', plan.$);
}
