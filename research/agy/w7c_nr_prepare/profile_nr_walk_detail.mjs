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
const srcPath = process.argv[3] || path.join(ROOT, 'selfhost/build/agy/wave7_unified/compiler.bend');

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;
const srcText = fs.readFileSync(srcPath, 'utf8');

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
  return {context, annotated};
}

const {context, annotated} = buildContextAndAnnotated();
const annIdx = api.nc_context_index(annotated);
const merged = api.nc_context_defs(context, annIdx);
const bound = api.norm_max_book(merged);
const source = api.book_cached(merged, bound);
const facts = api.p144o_build(source);
const view = api.p144o_view(source, facts);

let ownedCount = 0;
for (let c = facts.names; c && c.$ === 'Con'; c = c.tail) ownedCount++;
console.log('p144o_build owned ctor count:', ownedCount, 'valid:', facts.valid?.$);

// Simulate p143nr_walk in JS calling the exact Bend helpers to time each part!
let tLookup = 0, tDefPlain = 0, tArity = 0, tRefs = 0, tSeen = 0, count = 0;
let seen = api.missing();
let todo = ['main'];
const topSlowDef = [];

while (todo.length > 0) {
  const name = todo.pop();
  const h = api.index_hash(name, 2166136261);
  let t = performance.now();
  const isMem = api.p142j_member(seen, name, h);
  tSeen += performance.now() - t;
  if (isMem === true || isMem?.$ === 'True') continue;
  t = performance.now();
  seen = api.p142j_mark(seen, name, h);
  tSeen += performance.now() - t;

  t = performance.now();
  const d = api.lookup(view, name);
  tLookup += performance.now() - t;

  t = performance.now();
  const body = api.nc_definition_plain(view, d, 0);
  const dtDef = performance.now() - t;
  tDefPlain += dtDef;
  if (dtDef > 5) topSlowDef.push([dtDef, name, api.dk(d)]);

  const isDef = api.dk(d) === 'Def' && !(api.nc_native_def(d)?.$ === 'True' || api.nc_foreign(d)?.$ === 'True');
  if (isDef) {
    t = performance.now();
    api.nd_arity_plain(view, name);
    tArity += performance.now() - t;
  }

  t = performance.now();
  const refs = api.nc_refs(body);
  tRefs += performance.now() - t;
  for (let c = refs; c && c.$ === 'Con'; c = c.tail) todo.push(c.head);
  count++;
}

console.log(`Visited ${count} defs:`);
console.log(`  seen (p142j):          ${tSeen.toFixed(1)} ms`);
console.log(`  lookup(view, name):    ${tLookup.toFixed(1)} ms`);
console.log(`  nc_definition_plain:   ${tDefPlain.toFixed(1)} ms`);
console.log(`  nd_arity_plain:        ${tArity.toFixed(1)} ms`);
console.log(`  nc_refs:               ${tRefs.toFixed(1)} ms`);
topSlowDef.sort((a,b) => b[0] - a[0]);
console.log('Top 10 slowest nc_definition_plain:', topSlowDef.slice(0, 10));
