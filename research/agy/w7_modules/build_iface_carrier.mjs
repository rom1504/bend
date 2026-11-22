#!/usr/bin/env node
// General interface-only .p130 carrier builder for separate-object native compilation.
// Given Base + prefix module(s) (+ optional compiled prefix_lib.o for ABI matching),
// produces a compact .p130 carrier where:
//   - Every ADT, constructor, law, and Def type signature is preserved verbatim
//     (guaranteeing identical constructor IDs `cid` across separately compiled .o files).
//   - Prefix Defs already compiled into `prefix_lib.o` have their bodies replaced by
//     general self-recursive ABI-matched stubs:
//       * Direct (`p113d_`) ABI: `λx0..x{k-1}. f(x0..x{k-1})` (non-inlinable, 0 external deps)
//       * Public CPS (`p111_`) ABI: `λx0..x{k-1}. (λ_u. f(x0..x{k-1}))(0)` (stays in `p111_` CPS ABI)
//     Downstream `n1` typechecks against the exact checked interface and emits ONLY the
//     edited top module's functions + tiny weak-overrideable stubs, linking cleanly with
//     `prefix_lib.o` via `gcc-10` in sub-second time!

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {encodeBaseArena} from '../../../selfhost/tools/base-cache-graph.mjs';

const ROOT = '/home/ai/bend2_agy';
const DEFAULT_API = path.join(ROOT, 'selfhost/build/agy/wave6_unified/api.mjs');
const DEFAULT_BASE = path.join(ROOT, 'selfhost/dist/base.bend');

const SCHEMA = [
  ['Nil', []],
  ['Con', ['head', 'tail']],
  ['KTerm', ['tag', 'name', 'id', 'quant', 'kids', 'removed', 'originBegin', 'originEnd']],
  ['KLambda', ['name', 'id', 'quant', 'kids', 'removed', 'originBegin', 'originEnd', 'quantityPresent']],
  ['KLiteral', ['kind', 'number', 'text', 'originBegin', 'originEnd']],
  ['KDef', ['name', 'kind', 'arity', 'templates', 'typ', 'value', 'ctors', 'native', 'unsafe']],
  ['KIndexLeaf', ['hash', 'bucket']],
  ['KIndexNode', ['hash', 'mask', 'left', 'right']],
  ['KBasePrefixState', ['bound', 'delta', 'stamp', 'patches', 'ready']],
  ['FFreshPrefixState', ['next', 'ready']],
  ['KBasePreparedWorld', ['state', 'prefix', 'final', 'book', 'checked', 'seen', 'todos', 'checkedBound']],
  ['FReadyPrefixState', ['names', 'ctors', 'count', 'ready']],
];

function sha256(buf) {
  return crypto.createHash('sha256').update(buf).digest('hex');
}

function toArr(list) {
  const out = [];
  let cur = list;
  while (cur?.$ === 'Con') {
    out.push(cur.head);
    cur = cur.tail;
  }
  return out;
}

function fromArr(arr) {
  let cur = {$: 'Nil'};
  for (let i = arr.length - 1; i >= 0; i--) {
    cur = {$: 'Con', head: arr[i], tail: cur};
  }
  return cur;
}

function kt(tag, name, id, quant, kids) {
  return {
    $: 'KTerm', tag, name, id, quant,
    kids: fromArr(kids), removed: {$: 'Nil'}, originBegin: 0, originEnd: 0,
  };
}

function klit(kind, number, text) {
  return {
    $: 'KLiteral', kind, number, text, originBegin: 0, originEnd: 0,
  };
}

function klam(name, id, quant, body, quantityPresent = false) {
  return {
    $: 'KLambda', name, id, quant,
    kids: fromArr([body]), removed: {$: 'Nil'}, originBegin: 0, originEnd: 0, quantityPresent,
  };
}

function stripAnn(t) {
  let cur = t;
  while (cur?.$ === 'KTerm' && (cur.tag === 'Ann' || cur.tag === 'Src' || cur.tag === 'Use')) {
    const ks = toArr(cur.kids);
    if (ks.length === 0) break;
    cur = ks[0];
  }
  return cur;
}

function encodeFidName(prefix, bendName) {
  const full = '$direct.' + bendName;
  const codes = [...full].map((c) => c.charCodeAt(0)).join('_');
  return `${prefix}FID_${codes}_`;
}

// General self-recursive ABI-matched stub builder.
// Works for ANY Def regardless of return type; never inlines; pulls in 0 callees.
function buildRecursiveStub(d, forceCps) {
  if (d.kind !== 'Def' || d.templates !== 0) return null;
  const binders = [];
  let cur = stripAnn(d.typ);
  while (cur?.$ === 'KTerm' && cur.tag === 'All') {
    const ks = toArr(cur.kids);
    if (ks.length !== 2) return null;
    binders.push({name: cur.name || 'x', id: cur.id, quant: cur.quant});
    cur = stripAnn(ks[1]);
  }
  if (binders.length !== d.arity) return null;

  // Build `f(x_0)(x_1)...(x_{k-1})`
  let call = kt('Ref', d.name, 0, 0, []);
  for (const b of binders) {
    call = kt('App', '', 0, 0, [call, kt('Var', b.name, b.id, 0, [])]);
  }
  // If `prefix_lib.o` exports `p111_` CPS ABI (not `p113d_`), bind an unapplied
  // closure `let _f = (λ_cps. _cps) in call` so `p113d_live` rejects direct lowering
  // ("unsupported core node Lam") and `n1` emits exact `p111_FID_$direct.<name>` CPS ABI!
  let body = forceCps
    ? kt('Let', '_f', 999991, 0, [
        klam('_cps', 999992, 1, kt('Var', '_cps', 999992, 0, []), false),
        call,
      ])
    : call;
  for (let i = binders.length - 1; i >= 0; i--) {
    const b = binders[i];
    body = klam(b.name, b.id, b.quant, body, false);
  }
  return body;
}

function emitWordCarrier(records, strings, rootIds, baseStamp) {
  const stamp = 'p130-word-pair-v1:' + baseStamp;
  const parts = [];
  const word = (n) => {
    assert(Number.isInteger(n) && n >= 0 && n <= 0xffffffff);
    return String.fromCodePoint(65536 + (n % 65536), 65536 + Math.floor(n / 65536));
  };
  const pushStr = (s) => {
    const chars = [...s];
    assert(chars.length <= 1048576);
    parts.push(word(chars.length), s, '\n');
  };
  const strIds = new Map(strings.map((s, i) => [s, i]));
  const arenaStringFields = SCHEMA.map((s) => {
    if (s[0] === 'KTerm') return new Set([0, 1]);
    if (s[0] === 'KLambda') return new Set([0]);
    if (s[0] === 'KLiteral') return new Set([0, 2]);
    if (s[0] === 'KDef') return new Set([0, 1]);
    return new Set();
  });

  pushStr(stamp);
  parts.push(word(records.length), word(strings.length));
  for (const s of strings) pushStr(s);
  for (let i = 0; i < records.length; i++) {
    const row = records[i];
    const tag = row[0];
    const size = row.length - 1;
    parts.push(word(tag), word(size));
    const sFields = arenaStringFields[tag];
    for (let j = 0; j < size; j++) {
      let v = row[j + 1];
      if (sFields.has(j)) {
        v = strIds.get(v);
        assert.notEqual(v, undefined);
      } else if (tag === 1 && j === 0 && typeof v === 'string') {
        const id = strIds.get(v);
        assert.notEqual(id, undefined);
        v = id + 0x80000000;
      } else if (typeof v === 'boolean') {
        v = v ? 1 : 0;
      }
      parts.push(word(v));
    }
  }
  for (const r of rootIds) parts.push(word(r));
  return {bytes: Buffer.from(parts.join(''), 'utf8'), stamp};
}

function readDefinedGlobals(objPath) {
  if (!objPath) return new Set();
  const out = execFileSync('nm', ['-g', '--defined-only', objPath], {encoding: 'utf8'});
  const syms = new Set();
  for (const line of out.split('\n')) {
    const parts = line.trim().split(/\s+/);
    if (parts.length >= 3) syms.add(parts[2]);
  }
  return syms;
}

async function main() {
  const args = process.argv.slice(2);
  let apiPath = DEFAULT_API;
  let basePath = DEFAULT_BASE;
  let prefixPath = null;
  let prefixObjPath = null;
  let topPath = null;
  let outDir = null;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--api') apiPath = args[++i];
    else if (args[i] === '--base') basePath = args[++i];
    else if (args[i] === '--prefix') prefixPath = args[++i];
    else if (args[i] === '--prefix-obj') prefixObjPath = args[++i];
    else if (args[i] === '--top') topPath = args[++i];
    else if (args[i] === '--out-dir') outDir = args[++i];
  }
  if (!prefixPath || !outDir) {
    console.error('Usage: build_iface_carrier.mjs --prefix FILE [--prefix-obj OBJ] [--top FILE] --out-dir DIR');
    process.exit(2);
  }
  fs.mkdirSync(outDir, {recursive: true});

  const t0 = performance.now();
  const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
  const api = mod.default ?? mod;
  const importMs = performance.now() - t0;

  const baseText = fs.readFileSync(basePath, 'utf8');
  const prefixText = fs.readFileSync(prefixPath, 'utf8').replace(/^import Base\s*\n/, '');
  const combinedText = baseText + '\n' + prefixText + '\n';
  const combinedPath = path.join(path.resolve(outDir), 'prefix_base.bend');
  fs.writeFileSync(combinedPath, combinedText, 'utf8');

  const baseDefNames = new Set();
  for (const m of baseText.matchAll(/^(?:def|type|law)\s+([A-Za-z_][A-Za-z0-9_.]*)/gm)) {
    baseDefNames.add(m[1]);
  }

  const prefixObjSyms = readDefinedGlobals(prefixObjPath);

  const tPrep0 = performance.now();
  const prep = api.p86_prepare(combinedPath, combinedText);
  const prepMs = performance.now() - tPrep0;
  if (prep.$ !== 'P86PreparationReady') {
    throw Error(`p86_prepare failed: ${prep.error ?? prep.$}`);
  }
  const seed = prep.seed;

  const tStrip0 = performance.now();
  const allDefs = toArr(seed.book);

  // Keep Base bodies only for Base defs referenced by topPath (or core types)
  const topIdents = new Set();
  if (topPath) {
    const topText = fs.readFileSync(topPath, 'utf8');
    for (const m of topText.matchAll(/[A-Za-z_][A-Za-z0-9_.]*/g)) topIdents.add(m[0]);
  }
  const baseKeepRoots = [];
  for (const d of allDefs) {
    if (baseDefNames.has(d.name) && (topIdents.has(d.name) || ['U32', 'Bool', 'String', 'List', 'Nat', 'IO', 'Unit'].includes(d.name))) {
      baseKeepRoots.push(d.name);
    }
  }
  const stops = api.nc_annotation_stops(seed.book);
  const baseKeepSet = new Set(toArr(api.reach_book(seed.book, fromArr(baseKeepRoots), stops)).map((d) => d.name));

  // Build general ABI-matched self-recursive stubs for ALL non-Base prefix Defs
  // that are referenced by topPath (or all prefix Defs with templates === 0).
  const stubMap = new Map();
  let cpsStubs = 0;
  let directStubs = 0;
  for (const d of allDefs) {
    if (d.kind === 'Def' && !baseDefNames.has(d.name)) {
      const directSym = encodeFidName('p113d_', d.name);
      const cpsSym = encodeFidName('p111_', d.name);
      const hasDirect = prefixObjSyms.has(directSym);
      const hasCps = prefixObjSyms.has(cpsSym);
      // Only force CPS if prefix_lib.o exports p111_ WITHOUT p113d_
      const forceCps = hasCps && !hasDirect;
      const stub = buildRecursiveStub(d, forceCps);
      if (stub) {
        stubMap.set(d.name, stub);
        if (forceCps) cpsStubs++;
        else directStubs++;
      }
    }
  }

  const era = kt('Era', '', 0, 0, []);
  const memo = new WeakMap();
  const transform = (v) => {
    if (!v || typeof v !== 'object') return v;
    if (memo.has(v)) return memo.get(v);
    if (v.$ === 'KDef') {
      let newVal;
      if (v.kind !== 'Def') {
        newVal = transform(v.value);
      } else if (stubMap.has(v.name)) {
        newVal = stubMap.get(v.name);
      } else if (baseKeepSet.has(v.name)) {
        newVal = transform(v.value);
      } else {
        newVal = era;
      }
      const out = {...v, typ: transform(v.typ), value: newVal, ctors: transform(v.ctors)};
      memo.set(v, out);
      return out;
    }
    const out = {};
    for (const k of Object.keys(v)) out[k] = transform(v[k]);
    memo.set(v, out);
    return out;
  };

  const [sBook, sWorld, sReady] = [seed.book, seed.world, seed.ready].map(transform);
  const g1 = encodeBaseArena([sBook]);
  const g2 = encodeBaseArena([sWorld.state, seed.fresh, sWorld, sReady], g1);
  const rootIds = [g1.roots[0], ...g2.roots];
  const nodeCount = g2.records.length;
  const stringCount = g2.strings.length;

  const baseStamp = 'w7-mod-iface-v2:' + sha256(Buffer.from(combinedText, 'utf8'));
  const {bytes, stamp} = emitWordCarrier(g2.records, g2.strings, rootIds, baseStamp);
  const stripEmitMs = performance.now() - tStrip0;

  const carrierPath = path.join(path.resolve(outDir), 'prefix_iface.p130');
  fs.writeFileSync(carrierPath, bytes);

  const meta = {
    ok: true,
    combinedPath,
    carrierPath,
    stamp,
    combinedBytes: Buffer.byteLength(combinedText, 'utf8'),
    carrierBytes: bytes.length,
    totalDefs: allDefs.length,
    directStubs,
    cpsStubs,
    keptBaseBodies: baseKeepSet.size,
    nodeCount,
    stringCount,
    fitsN1Limits: nodeCount <= 65536 && stringCount <= 4096,
    prefixSha256: sha256(Buffer.from(prefixText, 'utf8')),
    baseSha256: sha256(Buffer.from(baseText, 'utf8')),
    importMs: +importMs.toFixed(1),
    prepMs: +prepMs.toFixed(1),
    stripEmitMs: +stripEmitMs.toFixed(1),
  };
  fs.writeFileSync(path.join(path.resolve(outDir), 'iface_meta.json'), JSON.stringify(meta, null, 2));
  console.log(JSON.stringify(meta, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
