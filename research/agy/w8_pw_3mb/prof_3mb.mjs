#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const apiPath = process.argv[2] || path.join(ROOT, 'selfhost/build/agy/wave7c_unified/api.mjs');
const srcPath = process.argv[3] || path.join(ROOT, 'selfhost/build/agy/wave7c_unified/compiler.bend');

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

function log(s) {
  fs.writeSync(2, s + '\n');
}
function mb() {
  const m = process.memoryUsage();
  return `heap=${(m.heapUsed / 1048576).toFixed(0)}MB rss=${(m.rss / 1048576).toFixed(0)}MB`;
}
function time(label, fn) {
  log(`[START] ${label.padEnd(28)} ${mb()}`);
  const t0 = performance.now();
  const r = fn();
  const ms = performance.now() - t0;
  log(`[DONE ] ${label.padEnd(28)} ${ms.toFixed(1).padStart(9)} ms  ${mb()}`);
  return r;
}

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const prep = time('p88_cache_prepare', () => api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP));
const srcText = fs.readFileSync(srcPath, 'utf8');
const plan = time('p86_plan', () => api.p86_plan(prep.seed, srcPath, srcText));
const req = plan.request;

const tPw0 = performance.now();
const adm = time('p111_runtime_admission', () => api.p111_runtime_admission(req));
const {source, book, names, paths, scope, bound} = req;
const err = time('nc_compile_error_known', () => api.nc_compile_error_known(source, bound));
const perm = time('p167ob_permission', () => api.p167ob_permission(req));
const cert = time('p113a_certificate', () => api.p113a_certificate(req));
const ctors = time('p144o_constructors', () =>
  api.nc_add_ctors(api.nc_default_ctors(), api.p144o_constructors(source, source, api.p144o_payload(api.nc_ctor_context(book)))));
const prep112 = time('p112s_prepare', () => api.p112s_prepare(book, names, ctors));
const book2 = prep112.book, nodes = prep112.nodes;
const bangs = time('nc_bangs_names', () => api.nc_bangs_names(book2, names));
const scan = time('p128br_scan', () => api.p128br_scan(book2, api.no_candidate_names(book2, names, bangs), {$:'Nil'}, {$:'Nil'}, {$:'Nil'}, {$:'Nil'}));
const [workers, helpers, retry] = [scan.functions ?? scan.workers, scan.helpers, scan.retry];
const sv = time('p167ob_seed_verify', () => api.p167ob_seed_verify(ctors, workers));
const ready = api.p113e_signatures(workers, api.missing());
const remaining = time('p167ob_remaining', () => api.p167ob_remaining(book2, names, bangs, ready));
const sigs = time('nq_signatures', () => api.book_cached(api.nq_signatures(book2, names), 0));
const filtered = time('w7_filter_remaining', () => api.w7_filter_remaining(book2, remaining, bangs));
const raw = time('p113pl_candidates', () => api.p113pl_candidates(book2, filtered, bangs, sigs));
const sc = time('p126sc_candidates', () => api.p126sc_candidates(raw));
const fns0 = time('p113d_passes', () => api.p113d_passes(sc, ready, api.nt_reverse(workers, {$:'Nil'}), 32));
const fns1 = time('w4p_adapt_functions', () => api.w4p_adapt_functions(fns0, ready, workers, sigs));
const plans = time('p169q_plans', () => api.p169q_plans(book2, retry));
const zipOwners = time('w4c_zip_owners_map', () => api.w4c_zip_owners_map(book2));
const sel = time('p169q_selection', () => api.p169q_selection(book2, plans, api.missing(), api.missing()));
const inlined = time('p169o_selected', () => api.p169o_selected(fns1, ready, zipOwners, sel));
const lfns = time('p167l_functions', () => api.p167l_functions(source, book2, names, ctors, nodes, bangs, inlined));

// Breakdown inside p169s_lowered:
const {program, adapters} = lfns;
const {original, functions} = program;
const p111prog = original.program;
const segs = p111prog.segments;
const origErr = time('p167v_original', () => api.p167v_original(book2, bangs, program, adapters));
const view = time('p168v_functions', () => api.p168v_functions(functions, adapters));
const vfn = time('p118b_verify_functions', () => api.p118b_verify_functions(view, p111prog));
const direct = {$:'P113DProgram', original, functions: view};
const vafter = time('p113a_verify_after', () => api.p113a_verify_after(direct, cert, ''));
const ids = time('p111q_ids', () => api.p111q_ids(p111prog));
const idx = time('p112f_index', () => api.p112f_index(segs));
const tables = time('p112s_tables', () => api.p112s_tables(p111prog, original.nodes, ids));
const imp = time('p168j_imports', () => api.p168j_imports(segs, api.p113e_signatures(view, api.missing()), {$:'P112RegionRegistry', ready:api.missing(), symbols:api.missing(), entries:{$:'Nil'}, workers:0, fusions:0}));
const reg = time('p168j_registry', () => api.p168j_registry(segs, idx, imp));

const prepared = time('p169s_lowered(full)', () => api.p169s_lowered(req, lfns));
const after = time('x198pw_after', () => api.x198pw_after(prepared, req));
log(`TOTAL x198pw_plan substages: ${(performance.now() - tPw0).toFixed(1)} ms`);
