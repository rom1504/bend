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

function time(label, fn) {
  const t0 = performance.now();
  const r = fn();
  const ms = performance.now() - t0;
  console.log(`${label.padEnd(32)} ${ms.toFixed(1).padStart(8)} ms`);
  return r;
}

const lowered = time('p168_request_mode', () => api.p168_request_mode(1, req));
const {source, book, names} = req;
const {program, adapters} = lowered;
const {original, functions} = program; // P113DProgram
const bangs = api.nc_bangs_names(book, names);

console.log('--- inside p169s_lowered ---');
const origErr = time('  p167v_original', () => api.p167v_original(book, bangs, program, adapters));
const view = time('  p168v_functions', () => api.p168v_functions(functions, adapters));
const cert = time('  p113a_certificate', () => api.p113a_certificate(req));
const p111prog = original.program;
const nodes = original.nodes;
const segs = p111prog.segments;
const vfn = time('  p118b_verify_functions', () => api.p118b_verify_functions(view, p111prog));
const direct = {$:'P113DProgram', original, functions: view};
const vafter = time('  p113a_verify_after', () => api.p113a_verify_after(direct, cert, ''));
const cplan = time('  p118c_plan', () => api.p118c_plan(req));

console.log('--- inside p169a_seeded ---');
const ids = time('  p111q_ids', () => api.p111q_ids(p111prog));
const idx = time('  p112f_index', () => api.p112f_index(segs));
const t1 = time('  p112s_tables', () => api.p112s_tables(p111prog, nodes, ids));
const t2 = time('  p117p_tables', () => api.p117p_tables(t1, {$:'Nil'}));
const t3 = time('  p118z_tables', () => api.p118z_tables(t2));
const t4 = time('  p118c_tables', () => api.p118c_tables(t3));
const imp = time('  p168j_imports', () => api.p168j_imports(segs, api.p113e_signatures(view, api.missing()), {$:'P112RegionRegistry', ready:api.missing(), symbols:api.missing(), entries:{$:'Nil'}, workers:0, fusions:0}));
const reg = time('  p168j_registry', () => api.p168j_registry(segs, idx, imp));

console.log('--- inside p167l_functions (w6_dedup_segments) ---');
time('  w6_dedup_segments(post)', () => api.w6_dedup_segments(segs));
