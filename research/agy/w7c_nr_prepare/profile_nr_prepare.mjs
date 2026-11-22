#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const apiPath = process.argv[2] || path.join(ROOT, 'selfhost/build/agy/wave7_unified/api.mjs');
const srcPath = process.argv[3] || path.join(ROOT, 'research/agy/w7_bench/compiler_slice_750kb.bend');

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;
const srcText = fs.readFileSync(srcPath, 'utf8');

function time(name, fn) {
  const t0 = performance.now();
  const res = fn();
  const ms = performance.now() - t0;
  console.log(`${name.padEnd(36)} ${ms.toFixed(1).padStart(9)} ms`);
  return res;
}

function buildContextAndAnnotated() {
  const baseText = fs.readFileSync(BASE_FILE, 'utf8');
  const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
  const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
  const seed = prep.seed;
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
  const srcLoc = api.f_source_located(fsrc, b0, (b0 + w0 + 1) >>> 0);
  const header = api.f_source_header(srcLoc);
  const cSeed = api.f_prefix_complete_ready_seed(base, '', api.f_prefix_graph_empty(), api.f_source_path(base), api.f_source_text(base), book0, ready);
  const sourcesList = {$: 'Con', head: srcLoc, tail: {$: 'Con', head: base, tail: {$: 'Nil'}}};
  const cKeys = Object.keys(cSeed);
  const carrier0 = cSeed[cKeys[1]];
  const cSrc = api.f_prefix_complete_source(srcLoc, '', header, sourcesList, carrier0, api.f_path_dir(api.f_source_path(srcLoc)));
  const carrier1 = cSrc[cKeys[1]];
  const load = api.f_prefix_graph_trace(carrier1, sourcesList, fresh);
  const lKeys = Object.keys(load);
  const suffix = load[lKeys[3]];
  const enough = api.p143cg_enough(suffix, 256);
  const checked = enough === true || enough?.$ === 'True'
    ? api.p143cb_program(load, {$: 'Nil'}, world, {$: 'True'})
    : api.check_program_diagnostic_world(load, {$: 'Nil'}, world);
  const dKeys = Object.keys(checked);
  const book = checked[dKeys[2]];
  const context = api.book_context_world(book, load, world);
  const stops = api.nc_annotation_stops(context);
  const mainList = {$: 'Con', head: 'main', tail: {$: 'Nil'}};
  const reached = api.reach_book(context, mainList, stops);
  const annotated = api.annotate_selected(context, reached, stops);
  return {context, stops, annotated};
}

const {context, annotated} = buildContextAndAnnotated();
console.log(`=== nr_prepare_annotated breakdown: ${path.basename(srcPath)} (${(srcText.length/1024).toFixed(1)} KB) ===`);

const t0 = performance.now();
const annIdx = time('1. nc_context_index(annotated)', () => api.nc_context_index(annotated));
const merged = time('2. nc_context_defs(book, annIdx)', () => api.nc_context_defs(context, annIdx));
const bound  = time('3. norm_max_book(merged)', () => api.norm_max_book(merged));
const source = time('4. book_cached(merged, bound)', () => api.book_cached(merged, bound));
const facts  = time('5. p144o_build(source)', () => api.p144o_build(source));
const view   = time('6. p144o_view(source, facts)', () => api.p144o_view(source, facts));
const mainList = {$: 'Con', head: 'main', tail: {$: 'Nil'}};
const closure = time('7. nr_walk(view, ["main"], [], [])', () => api.nr_walk(view, mainList, {$: 'Nil'}, {$: 'Nil'}));
const cKeys = Object.keys(closure);
const names = closure[cKeys[1]];
const nrFacts = closure[cKeys[2]];
const attached = time('8. ns_attach_book(view, facts, 0, [])', () => api.ns_attach_book(view, nrFacts, 0, {$: 'Nil'}));
const paths = time('9. nc_paths_of(source, names)', () => api.nc_paths_of(source, names));
const filtered = time('10. kr_filter(source, names)', () => api.kr_filter(source, names));
console.log(`${'SUM (1..10)'.padEnd(36)} ${(performance.now() - t0).toFixed(1).padStart(9)} ms`);
let nCount = 0;
for (let c = names; c && c.$ === 'Con'; c = c.tail) nCount++;
console.log(`names count: ${nCount}, bound: ${bound}`);
