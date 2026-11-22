#!/usr/bin/env node
/**
 * Detailed stage profiler for Wave 5 incremental compilation (`p86_plan` + `x198pw_plan` + `prepare_cursor` + emit + link).
 * Measures both cold-process (run 1) and warm-JIT persistent-process (run 2, edit) timings!
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {fileURLToPath, pathToFileURL} from 'node:url';

const tProc0 = performance.now();
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, '../../..');
const API_PATH = path.join(REPO, 'selfhost/build/agy/wave5c_unified/api.mjs');
const BASE_PATH = path.join(REPO, 'selfhost/dist/base.bend');
const CARRIER_PATH = path.join(REPO, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_STAMP_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

function prepUpstreamSmall(family) {
  const suite = JSON.parse(fs.readFileSync(path.join(REPO, 'research/agy/wave4_bench/inputs/upstream/suite.json'), 'utf8'));
  const spec = suite[family];
  let txt = fs.readFileSync(path.join(REPO, 'research/agy/wave4_bench/inputs/upstream', family, 'main.bend'), 'utf8');
  for (let i = 0; i < spec.bendKnobs.length; i++) {
    const bname = spec.bendKnobs[i];
    const oldV = spec.upstream[i];
    const newV = spec.small[i];
    const re = new RegExp(`(^def ${bname}\\(\\) -> Nat:\\n  )${oldV}n$`, 'm');
    txt = txt.replace(re, `$1${newV}n`);
  }
  return txt;
}

function editNonComment(src, oldStr, newStr) {
  const lines = src.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (!lines[i].trimStart().startsWith('#') && lines[i].includes(oldStr)) {
      lines[i] = lines[i].replace(oldStr, newStr);
      return lines.join('\n');
    }
  }
  throw new Error(`Could not find ${oldStr}`);
}

function ms(t0) {
  return Math.round((performance.now() - t0) * 10) / 10;
}

function profileDetailed(api, seed, srcPath, srcText) {
  const out = {};
  const tAll0 = performance.now();

  // --- p86_plan breakdown ---
  let t0 = performance.now();
  const base = seed.source;
  const begin = api.f_source_end(base);
  const source = api.f_source_located({$: 'FSource', name: srcPath, path: srcPath, text: srcText}, begin, begin + api.p86_width(srcText, 0) + 1);
  const header = api.f_source_header(source);
  out.fe_header = ms(t0);

  t0 = performance.now();
  const seeded = api.f_prefix_complete_ready_seed(
    base, '', api.f_prefix_graph_empty(), api.f_source_path(base), api.f_source_text(base), seed.book, seed.ready
  );
  out.fe_seed = ms(t0);

  t0 = performance.now();
  const sourcesList = {$: 'Con', head: source, tail: {$: 'Con', head: base, tail: {$: 'Nil'}}};
  const completed = api.f_prefix_complete_source(source, '', header, sourcesList, seeded.carrier, api.f_path_dir(api.f_source_path(source)));
  out.fe_parse = ms(t0);

  t0 = performance.now();
  const load = api.f_prefix_graph_trace(completed.carrier, sourcesList, seed.fresh);
  out.fe_trace = ms(t0);

  t0 = performance.now();
  const enough = api.p143cg_enough(load.suffix, 256);
  const checkRes = enough
    ? api.p143cb_program(load, {$: 'Nil'}, seed.world, {$: 'True'})
    : api.check_program_diagnostic_world(load, {$: 'Nil'}, seed.world);
  out.fe_check = ms(t0);
  if (checkRes.error !== '') throw new Error('check: ' + checkRes.error);

  t0 = performance.now();
  const original = load.trace.result.book;
  const book = checkRes.book;
  const report = api.driver_report_data(original);
  const ownErr = api.driver_emit_owned(book);
  const jErr = api.j_compile_error(book);
  if (ownErr || jErr) throw new Error('own/j: ' + ownErr + jErr);
  out.fe_report_own = ms(t0);

  t0 = performance.now();
  const context = api.book_context_world(book, load, seed.world);
  out.fe_context = ms(t0);

  t0 = performance.now();
  const stops = api.nc_annotation_stops(context);
  const mainList = {$: 'Con', head: 'main', tail: {$: 'Nil'}};
  const reached = api.reach_book(context, mainList, stops);
  const annotated = api.annotate_selected(context, reached, stops);
  out.fe_reach_ann = ms(t0);

  t0 = performance.now();
  const jlErr = api.jl_checked_error(context, annotated, mainList, stops);
  if (jlErr) throw new Error('jl: ' + jlErr);
  out.fe_jl_check = ms(t0);

  t0 = performance.now();
  const plan = api.agy_bf_plan(context, stops, report.verdict, annotated);
  if (plan.$ !== 'P86PlanReady') throw new Error('agy_bf_plan failed: ' + plan.$);
  out.fe_opt_plan = ms(t0);
  out.p86_plan_sum = ms(tAll0);

  // --- x198pw_plan breakdown ---
  const tPw0 = performance.now();
  t0 = performance.now();
  const p169 = api.p169np_plan(plan);
  out.pw_p169np = ms(t0);

  t0 = performance.now();
  const req = plan.request;
  let pw = p169;
  if (pw.error === '') {
    let ts = performance.now(); pw = api.x198pw_annotate(req, pw); out.pw_x198pw = ms(ts);
    ts = performance.now(); pw = api.agy_zip_annotate(req, pw); out.pw_zip = ms(ts);
    ts = performance.now(); pw = api.agy_fl_annotate(req, pw); out.pw_fl = ms(ts);
    ts = performance.now(); pw = api.agy_da_annotate(pw); out.pw_da = ms(ts);
    ts = performance.now(); pw = api.agy_map_annotate(req, pw); out.pw_map = ms(ts);
    ts = performance.now(); pw = api.agy_bp_annotate(req, pw); out.pw_bp = ms(ts);
    ts = performance.now(); pw = api.agy_sh_annotate(req, pw); out.pw_sh = ms(ts);
  }
  out.x198pw_sum = ms(tPw0);

  // --- agy_parcg_prepare_cursor breakdown ---
  t0 = performance.now();
  const ready = api.agy_parcg_prepare_cursor(pw);
  out.prepare_cursor = ms(t0);
  if (ready.error !== '') throw new Error('prepare_cursor: ' + ready.error);

  out.total_fe_lower = ms(tAll0);
  return {out, plan, ready};
}

async function main() {
  const tImp0 = performance.now();
  const api = (await import(pathToFileURL(API_PATH))).default;
  const apiLoadMs = ms(tImp0);

  const tPrep0 = performance.now();
  const baseText = fs.readFileSync(BASE_PATH, 'utf8');
  const carrier = fs.readFileSync(CARRIER_PATH, 'utf8');
  const prep = api.p88_cache_prepare(BASE_STAMP_PATH, baseText, carrier, STAMP);
  if (prep.$ !== 'P86PreparationReady') throw new Error('prep failed');
  const prepMs = ms(tPrep0);

  console.log(`Startup: api_import=${apiLoadMs}ms, p88_cache_prepare=${prepMs}ms (since script start: ${ms(tProc0)}ms)\n`);

  const cases = [
    ['histogram', prepUpstreamSmall('histogram')],
    ['gameoflife', prepUpstreamSmall('gameoflife')],
    ['nbody', prepUpstreamSmall('nbody')],
    ['lexer', fs.readFileSync(path.join(REPO, 'selfhost/tests/consolidation/native-broad/lexer.bend'), 'utf8')],
  ];

  // Pass 1 (cold JIT)
  console.log('=== PASS 1 (Cold JIT) ===');
  for (const [name, src] of cases) {
    const {out} = profileDetailed(api, prep.seed, `/tmp/${name}.bend`, src);
    console.log(name, JSON.stringify(out));
  }

  // Pass 2 (warm JIT, 1-function edit)
  console.log('\n=== PASS 2 (Warm JIT, 1-function edit) ===');
  for (const [name, src] of cases) {
    const edited = editNonComment(src, '2654435761', '2654435763');
    const {out} = profileDetailed(api, prep.seed, `/tmp/${name}.bend`, edited);
    console.log(name, JSON.stringify(out));
  }

  // Pass 3 (very warm JIT, another edit)
  console.log('\n=== PASS 3 (Very Warm JIT, 1-function edit) ===');
  for (const [name, src] of cases) {
    const edited = editNonComment(src, '2654435761', '2654435765');
    const {out} = profileDetailed(api, prep.seed, `/tmp/${name}.bend`, edited);
    console.log(name, JSON.stringify(out));
  }
}

main().catch(e => { console.error(e); process.exit(1); });
