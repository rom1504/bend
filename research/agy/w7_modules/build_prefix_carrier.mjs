#!/usr/bin/env node
// General interface-stripped .p130 module-prefix carrier builder.
// Compiles Base + prefix module(s) once via the checked compiler API, strips
// unused Def bodies (keeping full checked types/ctors for every declaration and
// keeping bodies only for the runtime-exported closure), and emits a standard
// p130-word-pair-v1 carrier directly consumable by unmodified native `n1`.

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
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

// Build a word-pair-v1 .p130 carrier directly from arena records & strings.
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
    const fields = s[1];
    // Match base-cache-graph.mjs string fields
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
  const bytes = Buffer.from(parts.join(''), 'utf8');
  return {bytes, stamp};
}

function stripInterface(roots, keepBodies) {
  const era = {
    $: 'KTerm', tag: 'Era', name: '', id: 0, quant: 0,
    kids: {$: 'Nil'}, removed: {$: 'Nil'}, originBegin: 0, originEnd: 0,
  };
  const memo = new WeakMap();
  const walk = (v) => {
    if (!v || typeof v !== 'object') return v;
    if (memo.has(v)) return memo.get(v);
    if (v.$ === 'KDef') {
      const keep = keepBodies.has(v.name) || v.kind !== 'Def';
      const out = {
        ...v,
        typ: walk(v.typ),
        value: keep ? walk(v.value) : era,
        ctors: walk(v.ctors),
      };
      memo.set(v, out);
      return out;
    }
    const out = {};
    for (const k of Object.keys(v)) out[k] = walk(v[k]);
    memo.set(v, out);
    return out;
  };
  return roots.map(walk);
}

// Extract identifiers referenced in a top-module source file (conservative lexical scan)
// so we know which prefix definitions might be called at runtime by the top module.
function extractReferencedIdents(text) {
  const ids = new Set();
  for (const m of text.matchAll(/[A-Za-z_][A-Za-z0-9_.]*/g)) {
    ids.add(m[0]);
  }
  return ids;
}

async function main() {
  const args = process.argv.slice(2);
  let apiPath = DEFAULT_API;
  let basePath = DEFAULT_BASE;
  let prefixPath = null;
  let topPath = null;
  let outDir = null;
  let extraRoots = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--api') apiPath = args[++i];
    else if (args[i] === '--base') basePath = args[++i];
    else if (args[i] === '--prefix') prefixPath = args[++i];
    else if (args[i] === '--top') topPath = args[++i];
    else if (args[i] === '--out-dir') outDir = args[++i];
    else if (args[i] === '--roots') extraRoots = args[++i].split(',').filter(Boolean);
  }
  if (!prefixPath || !outDir) {
    console.error('Usage: build_prefix_carrier.mjs --prefix FILE [--top FILE] [--roots a,b] --out-dir DIR');
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

  const tPrep0 = performance.now();
  const prep = api.p86_prepare(combinedPath, combinedText);
  const prepMs = performance.now() - tPrep0;
  if (prep.$ !== 'P86PreparationReady') {
    throw Error(`p86_prepare failed: ${prep.error ?? prep.$}`);
  }
  const seed = prep.seed;

  // Determine runtime-needed prefix defs from top module references + explicit roots.
  const tStrip0 = performance.now();
  const allDefs = toArr(seed.book);
  const defNames = new Set(allDefs.map((d) => d.name));
  const rootSet = new Set(extraRoots.filter((r) => defNames.has(r)));
  if (topPath) {
    const topText = fs.readFileSync(topPath, 'utf8');
    for (const id of extractReferencedIdents(topText)) {
      if (defNames.has(id)) rootSet.add(id);
    }
  }
  // Always keep primitive/native wrappers and core Base IO/print helpers needed by entrypoints
  for (const core of ['U32', 'Bool', 'String', 'List', 'Nat', 'IO', 'Unit', 'Pair', 'Maybe', 'Result']) {
    if (defNames.has(core)) rootSet.add(core);
  }
  const stops = api.nc_annotation_stops(seed.book);
  const reached = toArr(api.reach_book(seed.book, fromArr([...rootSet]), stops));
  const keepBodies = new Set(reached.map((d) => d.name));

  // Strip bodies of non-kept Defs across [book, world, ready], preserving exact types & ctors.
  const [sBook, sWorld, sReady] = stripInterface([seed.book, seed.world, seed.ready], keepBodies);
  const sChecked = sWorld.state;
  const sFresh = seed.fresh;

  const g1 = encodeBaseArena([sBook]);
  const g2 = encodeBaseArena([sChecked, sFresh, sWorld, sReady], g1);
  const rootIds = [g1.roots[0], ...g2.roots];
  const nodeCount = g2.records.length;
  const stringCount = g2.strings.length;

  const baseStamp = 'w7-mod-prefix-v1:' + sha256(Buffer.from(combinedText, 'utf8'));
  const {bytes, stamp} = emitWordCarrier(g2.records, g2.strings, rootIds, baseStamp);
  const stripEmitMs = performance.now() - tStrip0;

  const carrierPath = path.join(path.resolve(outDir), 'prefix.p130');
  fs.writeFileSync(carrierPath, bytes);

  const meta = {
    ok: true,
    combinedPath,
    carrierPath,
    stamp,
    combinedBytes: Buffer.byteLength(combinedText, 'utf8'),
    carrierBytes: bytes.length,
    totalDefs: allDefs.length,
    rootCount: rootSet.size,
    keptBodies: keepBodies.size,
    nodeCount,
    stringCount,
    fitsN1Limits: nodeCount <= 65536 && stringCount <= 4096,
    prefixSha256: sha256(Buffer.from(prefixText, 'utf8')),
    baseSha256: sha256(Buffer.from(baseText, 'utf8')),
    importMs: +importMs.toFixed(1),
    prepMs: +prepMs.toFixed(1),
    stripEmitMs: +stripEmitMs.toFixed(1),
  };
  fs.writeFileSync(path.join(path.resolve(outDir), 'prefix_meta.json'), JSON.stringify(meta, null, 2));
  console.log(JSON.stringify(meta, null, 2));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
