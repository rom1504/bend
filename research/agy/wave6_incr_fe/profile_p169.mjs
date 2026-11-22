#!/usr/bin/env node
/**
 * Profile inside `pw_p169np` + `emitSingleUnit` (warm JIT) + `gcc-10` link + cursor structure.
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

function listLen(l) {
  let n = 0;
  for (let c = l; c && c.$ === 'Con'; c = c.tail) n++;
  return n;
}

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

  // Warm up once
  for (const [name, src] of cases) {
    const plan = api.p86_plan(prep.seed, `/tmp/${name}.bend`, src);
    const pw = api.x198pw_plan(plan);
    api.agy_parcg_prepare_cursor(pw);
  }

  console.log('=== WARM p169np BREAKDOWN ===');
  for (const [name, src] of cases) {
    const plan = api.p86_plan(prep.seed, `/tmp/${name}.bend`, src);
    const req = plan.request;

    let t0 = performance.now();
    const adm = api.p111_runtime_admission(req);
    const tAdm = ms(t0);

    t0 = performance.now();
    const lowered = api.p168_request_mode(1, req);
    const tMode = ms(t0);

    t0 = performance.now();
    const bangs = api.nc_bangs_names(req.book, req.names);
    const vOrig = api.p167v_original(req.book, bangs, lowered.program, lowered.adapters);
    const tVOrig = ms(t0);

    t0 = performance.now();
    const p169 = api.p169a_original(req, lowered.adapters, lowered.program, vOrig);
    const tAOrig = ms(t0);

    // Inspect cursor segments
    const ready = api.agy_parcg_prepare_cursor(api.x198pw_after(p169, req));
    const segs = [];
    let cur = ready.cursor;
    while (cur) {
      if (cur.$ === 'P134Private' || cur.$ === 'P134Public') {
        const f = Object.keys(cur).filter(k => k !== '$');
        segs.push(`${cur.$}:${listLen(cur[f[0]])}`);
        cur = cur[f[2]];
      } else if (cur.$ === 'P134Legacy') {
        const f = Object.keys(cur).filter(k => k !== '$');
        cur = cur[f[2]];
      } else {
        segs.push(cur.$);
        break;
      }
    }

    // Time emitting 2 private items on warm JIT
    let tEmit1 = 0;
    if (ready.cursor.$ === 'P134Private') {
      const f = Object.keys(ready.cursor).filter(k => k !== '$');
      const head = ready.cursor[f[0]].head;
      const single = {$: 'P134Private'};
      single[f[0]] = {$: 'Con', head, tail: {$: 'Nil'}};
      single[f[1]] = ready.cursor[f[1]];
      single[f[2]] = {$: 'P134Main'};
      const r1 = {$: 'AgyParCgReady', cursor: single, available: ready.available, error: ''};
      // warmup emit
      api.agy_parcg_emit_presliced(r1, false);
      t0 = performance.now();
      api.agy_parcg_emit_presliced(r1, false);
      tEmit1 = ms(t0);
    }

    console.log(name, JSON.stringify({
      reqBookLen: listLen(req.book),
      reqNamesLen: listLen(req.names),
      tAdm, tMode, tVOrig, tAOrig,
      totalP169: Math.round((tAdm + tMode + tVOrig + tAOrig) * 10) / 10,
      tEmit1Warm: tEmit1,
      segs,
    }));
  }
}

main().catch(e => { console.error(e); process.exit(1); });
