#!/usr/bin/env node
/**
 * Measure exact millisecond breakdown inside `p168_selected` -> `p168_candidates` -> `p168_closed` -> `p169o_closed` -> `p168_retry`.
 */
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

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
    const re = new RegExp(`(^def ${spec.bendKnobs[i]}\\(\\) -> Nat:\\n  )${spec.upstream[i]}n$`, 'm');
    txt = txt.replace(re, `$1${spec.small[i]}n`);
  }
  return txt;
}

function ms(t0) { return Math.round((performance.now() - t0) * 10) / 10; }
function listLen(l) { let n = 0; for (let c = l; c && c.$ === 'Con'; c = c.tail) n++; return n; }

async function main() {
  const api = (await import(pathToFileURL(API_PATH))).default;
  const baseText = fs.readFileSync(BASE_PATH, 'utf8');
  const carrier = fs.readFileSync(CARRIER_PATH, 'utf8');
  const prep = api.p88_cache_prepare(BASE_STAMP_PATH, baseText, carrier, STAMP);

  const cases = [
    ['histogram', prepUpstreamSmall('histogram')],
    ['gameoflife', prepUpstreamSmall('gameoflife')],
    ['nbody', prepUpstreamSmall('nbody')],
    ['lexer', fs.readFileSync(path.join(REPO, 'selfhost/tests/consolidation/native-broad/lexer.bend'), 'utf8')],
  ];

  // Warmup
  for (const [name, src] of cases) {
    const plan = api.p86_plan(prep.seed, `/tmp/${name}.bend`, src);
    api.x198pw_plan(plan);
  }

  for (const [name, src] of cases) {
    const plan = api.p86_plan(prep.seed, `/tmp/${name}.bend`, src);
    const req = plan.request;

    const ctors = api.nc_add_ctors(api.nc_default_ctors(),
      api.p144o_constructors(req.source, req.source, api.p144o_payload(api.nc_ctor_context(req.book))));
    const sPrep = api.p112s_prepare(req.book, req.names, ctors);
    const bangs = api.nc_bangs_names(sPrep.book, req.names);
    const cand = api.no_candidate_names(sPrep.book, req.names, bangs);
    const scan = api.p128br_scan(sPrep.book, cand, {$:'Nil'}, {$:'Nil'}, {$:'Nil'}, {$:'Nil'});
    const sf = Object.keys(scan).filter(k => k !== '$');
    const workers = scan[sf[0]], helpers = scan[sf[1]], retry = scan[sf[2]];
    const readyIdx = api.p113e_signatures(workers, api.missing());
    const rem = api.p167ob_remaining(sPrep.book, req.names, bangs, readyIdx);

    let t0 = performance.now();
    const sigs = api.book_cached(api.nq_signatures(sPrep.book, req.names), 0);
    const tSigs = ms(t0);

    t0 = performance.now();
    const raw = api.p113pl_candidates(sPrep.book, rem, bangs, sigs);
    const tRaw = ms(t0);

    t0 = performance.now();
    const sc = api.p126sc_candidates(raw);
    const fns0 = api.p113d_passes(sc, readyIdx, api.nt_reverse(workers, {$:'Nil'}), 32);
    const fns1 = api.w4p_adapt_functions(fns0, readyIdx, workers, sigs);
    const tPasses = ms(t0);

    t0 = performance.now();
    const qPlans = api.p169q_plans(sPrep.book, retry);
    const tQPlans = ms(t0);

    t0 = performance.now();
    const sel = api.p169q_selection(sPrep.book, qPlans, api.missing(), api.missing());
    const zipOwners = api.w4c_zip_owners_map(sPrep.book);
    const fns2 = api.p169o_selected(fns1, readyIdx, zipOwners, sel);
    const tOSelected = ms(t0);

    t0 = performance.now();
    const scalars = api.p169q_scalars(sPrep.book, qPlans, fns2, {$:'Nil'}, api.nt_reverse(helpers, {$:'Nil'}), {$:'Nil'});
    const tQScalars = ms(t0);

    t0 = performance.now();
    const stats = {$:'Nil'};
    const scF = Object.keys(scalars).filter(k => k !== '$');
    const added = scalars[scF[0]], h2 = scalars[scF[1]], r2 = scalars[scF[2]];
    const mergedFns = api.nt_append(added, api.p118b_without(fns2, api.p113e_signatures(added, api.missing())));
    const finalLowered = api.p168_retry(req.source, sPrep.book, req.names, ctors, sPrep.nodes, bangs, stats, mergedFns, h2, r2);
    const tRetry = ms(t0);

    console.log(name, JSON.stringify({
      tSigs, tRaw, tPasses, tQPlans, tOSelected, tQScalars, tRetry,
      remLen: listLen(rem), rawLen: listLen(raw), fns1Len: listLen(fns1), retryLen: listLen(retry),
    }));
  }
}

main().catch(e => { console.error(e); process.exit(1); });
