#!/usr/bin/env node
/**
 * Profile inside `p168_request_mode` AND inspect exact diff between cold & edit1
 * on `ready.cursor`, `plan.request`, and the call graph!
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

function listToArray(l) {
  const out = [];
  for (let c = l; c && c.$ === 'Con'; c = c.tail) out.push(c.head);
  return out;
}

function ms(t0) { return Math.round((performance.now() - t0) * 10) / 10; }

function itemName(item) {
  if (!item || typeof item !== 'object') return '?';
  if (typeof item.name === 'string') return item.name;
  for (const k of Object.keys(item)) {
    if (k !== '$' && typeof item[k] === 'string' && item[k].length > 0) return `${k}:${item[k]}`;
  }
  return item.$ || '?';
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

  // Warm up
  for (const [name, src] of cases) {
    const plan = api.p86_plan(prep.seed, `/tmp/${name}.bend`, src);
    api.x198pw_plan(plan);
  }

  for (const [name, src] of cases) {
    const edited = editNonComment(src, '2654435761', '2654435763');
    const plan1 = api.p86_plan(prep.seed, `/tmp/${name}.bend`, src);
    const plan2 = api.p86_plan(prep.seed, `/tmp/${name}.bend`, edited);

    // Profile inside p168_request_mode on plan1.request
    const req = plan1.request;
    let t0 = performance.now();
    const ctors = api.nc_add_ctors(api.nc_default_ctors(),
      api.p144o_constructors(req.source, req.source, api.p144o_payload(api.nc_ctor_context(req.book))));
    const tCtors = ms(t0);

    t0 = performance.now();
    const cert = api.p113a_certificate(req);
    const tCert = ms(t0);

    t0 = performance.now();
    const sPrep = api.p112s_prepare(req.book, req.names, ctors);
    const tSPrep = ms(t0);

    t0 = performance.now();
    const bangs = api.nc_bangs_names(sPrep.book, req.names);
    const cand = api.no_candidate_names(sPrep.book, req.names, bangs);
    const scan = api.p128br_scan(sPrep.book, cand, {$:'Nil'}, {$:'Nil'}, {$:'Nil'}, {$:'Nil'});
    const tScan = ms(t0);

    t0 = performance.now();
    const scanFields = Object.keys(scan).filter(k => k !== '$');
    const scanWorkers = scan[scanFields[0]];
    const seedVer = api.p167ob_seed_verify(ctors, scanWorkers);
    const sigs = api.p113e_signatures(scanWorkers, api.missing());
    const rem = api.p167ob_remaining(sPrep.book, req.names, bangs, sigs);
    const tRem = ms(t0);

    // Also diff cursor items between plan1 and plan2
    const r1 = api.agy_parcg_prepare_cursor(api.x198pw_plan(plan1));
    const r2 = api.agy_parcg_prepare_cursor(api.x198pw_plan(plan2));
    const diffNames = [];
    let c1 = r1.cursor, c2 = r2.cursor;
    while (c1 && c2) {
      if (c1.$ !== c2.$) { diffNames.push(`TAG_DIFF:${c1.$}!=${c2.$}`); break; }
      if (c1.$ === 'P134Private' || c1.$ === 'P134Public') {
        const f = Object.keys(c1).filter(k => k !== '$');
        const a1 = listToArray(c1[f[0]]);
        const a2 = listToArray(c2[f[0]]);
        const n = Math.max(a1.length, a2.length);
        for (let i = 0; i < n; i++) {
          if (JSON.stringify(a1[i]) !== JSON.stringify(a2[i])) {
            diffNames.push(`${c1.$}[${i}]:${itemName(a2[i])}`);
          }
        }
        c1 = c1[f[2]]; c2 = c2[f[2]];
      } else if (c1.$ === 'P134Legacy') {
        const f = Object.keys(c1).filter(k => k !== '$');
        c1 = c1[f[2]]; c2 = c2[f[2]];
      } else {
        if (JSON.stringify(c1) !== JSON.stringify(c2)) diffNames.push(`TAIL:${c1.$}`);
        break;
      }
    }

    console.log(name, JSON.stringify({
      tCtors, tCert, tSPrep, tScan, tRem,
      candLen: listToArray(cand).length,
      workersLen: listToArray(scanWorkers).length,
      diffNames,
    }));
  }
}

main().catch(e => { console.error(e); process.exit(1); });
