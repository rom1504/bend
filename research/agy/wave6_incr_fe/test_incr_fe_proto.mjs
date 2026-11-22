#!/usr/bin/env node
/**
 * Prototype test: incremental single-def parse + typecheck + annotate vs full p86_plan.
 * Verifies exact structural equivalence of the resulting KDef!
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

/**
 * Split Bend source into top-level blocks.
 * Decorators (@unsafe, @meta, etc.) attach to the immediately following top-level item.
 */
function splitTopLevelBlocks(src) {
  const lines = src.split('\n');
  const blocks = [];
  let cur = null;
  let pendingDecorators = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();
    const isBlankOrComment = trimmed === '' || trimmed.startsWith('#');
    const isTopCol = line.length > 0 && line[0] !== ' ' && line[0] !== '\t' && !isBlankOrComment;

    if (isTopCol) {
      if (line.startsWith('@')) {
        if (cur) { blocks.push(cur); cur = null; }
        pendingDecorators.push(line);
        continue;
      }
      if (cur) blocks.push(cur);
      let kind = 'other';
      let name = '';
      let header = line;
      const mDef = line.match(/^def\s+([^\s(:]+)/);
      const mType = line.match(/^type\s+([^\s(:]+)/);
      const mLaw = line.match(/^law\s+([^\s(:]+)/);
      const mImp = line.match(/^import\s+/);
      if (mDef) { kind = 'def'; name = mDef[1]; }
      else if (mType) { kind = 'type'; name = mType[1]; }
      else if (mLaw) { kind = 'law'; name = mLaw[1]; }
      else if (mImp) { kind = 'import'; name = line; }
      cur = {
        kind,
        name,
        header: (pendingDecorators.length ? pendingDecorators.join('\n') + '\n' : '') + header,
        lines: [...pendingDecorators, line],
      };
      pendingDecorators = [];
    } else if (cur) {
      cur.lines.push(line);
    }
  }
  if (cur) blocks.push(cur);
  // Trim trailing blank/comment lines from each block for clean hashing
  for (const b of blocks) {
    while (b.lines.length > 0) {
      const t = b.lines[b.lines.length - 1].trim();
      if (t === '' || t.startsWith('#')) b.lines.pop();
      else break;
    }
    b.text = b.lines.join('\n') + '\n';
  }
  return blocks;
}

function listToArray(l) {
  const out = [];
  for (let c = l; c && c.$ === 'Con'; c = c.tail) out.push(c.head);
  return out;
}

function arrayToList(arr) {
  let acc = {$: 'Nil'};
  for (let i = arr.length - 1; i >= 0; i--) acc = {$: 'Con', head: arr[i], tail: acc};
  return acc;
}

// Strip source span offsets (begin/end) when comparing KTerms structurally
function stripSpans(v) {
  if (!v || typeof v !== 'object') return v;
  if (Array.isArray(v)) return v.map(stripSpans);
  const out = {};
  for (const k of Object.keys(v)) {
    if (k === 'begin' || k === 'end') out[k] = 0;
    else out[k] = stripSpans(v[k]);
  }
  return out;
}

function ms(t0) { return Math.round((performance.now() - t0) * 10) / 10; }

async function main() {
  const api = (await import(pathToFileURL(API_PATH))).default;
  const baseText = fs.readFileSync(BASE_PATH, 'utf8');
  const carrier = fs.readFileSync(CARRIER_PATH, 'utf8');
  const prep = api.p88_cache_prepare(BASE_STAMP_PATH, baseText, carrier, STAMP);
  const seed = prep.seed;
  const base = seed.source;

  const cases = [
    ['histogram', prepUpstreamSmall('histogram')],
    ['gameoflife', prepUpstreamSmall('gameoflife')],
    ['nbody', prepUpstreamSmall('nbody')],
    ['lexer', fs.readFileSync(path.join(REPO, 'selfhost/tests/consolidation/native-broad/lexer.bend'), 'utf8')],
  ];

  // Warmup
  for (const [name, src] of cases) api.p86_plan(seed, `/tmp/${name}.bend`, src);

  for (const [name, src] of cases) {
    const edited = editNonComment(src, '2654435761', '2654435763');
    const b1 = splitTopLevelBlocks(src);
    const b2 = splitTopLevelBlocks(edited);
    const changed = [];
    for (let i = 0; i < b2.length; i++) {
      if (b1[i].text !== b2[i].text) changed.push(b2[i]);
    }

    // Full reference for original & edited
    const fullOrig = api.p86_plan(seed, `/tmp/${name}.bend`, src);
    const fullEdit = api.p86_plan(seed, `/tmp/${name}.bend`, edited);

    // Now test incremental parse + check + annotate of ONLY `changed[0]`!
    const t0 = performance.now();
    const miniText = changed.map(c => c.text).join('\n');
    const begin = api.f_source_end(base);
    const miniSrc = api.f_source_located({$: 'FSource', name: `/tmp/${name}.bend`, path: `/tmp/${name}.bend`, text: miniText}, begin, begin + api.p86_width(miniText, 0) + 1);
    const header = api.f_source_header(miniSrc);
    const seeded = api.f_prefix_complete_ready_seed(
      base, '', api.f_prefix_graph_empty(), api.f_source_path(base), api.f_source_text(base), seed.book, seed.ready
    );
    const sourcesList = {$: 'Con', head: miniSrc, tail: {$: 'Con', head: base, tail: {$: 'Nil'}}};
    const completed = api.f_prefix_complete_source(miniSrc, '', header, sourcesList, seeded.carrier, api.f_path_dir(api.f_source_path(miniSrc)));
    const load = api.f_prefix_graph_trace(completed.carrier, sourcesList, seed.fresh);
    const parsedDefs = listToArray(load.suffix);
    const tParse = ms(t0);

    // Splice parsedDefs into fullOrig.request.source (or book) and check ONLY parsedDefs!
    const t1 = performance.now();
    const origBookArr = listToArray(fullOrig.request.book);
    const parsedMap = new Map(parsedDefs.map(d => [d.name, d]));
    const splicedBookArr = origBookArr.map(d => parsedMap.has(d.name) ? parsedMap.get(d.name) : d);
    const splicedBook = arrayToList(splicedBookArr);
    const world = api.kw_initial(splicedBook);
    const checkedDefs = [];
    for (const d of parsedDefs) {
      const res = api.check_definition_body(world, d, 0);
      const ok = api.good(res);
      if (!ok) throw new Error(`${name}: check_definition_body failed on ${d.name}`);
      // checked term is ct(res), checked type is ty
      const checkedVal = api.ct(res);
      checkedDefs.push({...d, value: checkedVal});
    }
    const tCheck = ms(t1);

    const t2 = performance.now();
    const checkedMap = new Map(checkedDefs.map(d => [d.name, d]));
    const checkedBookArr = origBookArr.map(d => checkedMap.has(d.name) ? checkedMap.get(d.name) : d);
    const checkedBook = arrayToList(checkedBookArr);
    const ctx = api.book_context(checkedBook);
    const annDefs = checkedDefs.map(d => api.ka_def(ctx, d));
    const tAnn = ms(t2);

    // Compare annDefs[0] against fullEdit.request.book!
    const fullEditMap = new Map(listToArray(fullEdit.request.book).map(d => [d.name, d]));
    const got = stripSpans(annDefs[0]);
    const want = stripSpans(fullEditMap.get(annDefs[0].name));
    const exact = JSON.stringify(got) === JSON.stringify(want);
    if (!exact) {
      const gs = JSON.stringify(got);
      const ws = JSON.stringify(want);
      let idx = 0;
      while (idx < gs.length && idx < ws.length && gs[idx] === ws[idx]) idx++;
      console.log(`  DIFF(${name}) at ${idx}: got=${gs.slice(Math.max(0,idx-40), idx+80)} vs want=${ws.slice(Math.max(0,idx-40), idx+80)}`);
    }

    console.log(name, JSON.stringify({
      changed: changed.map(c => c.name),
      parsedCount: parsedDefs.length,
      tParse, tCheck, tAnn,
      totalIncrFe: Math.round((tParse + tCheck + tAnn) * 10) / 10,
      exactMatchWithFullBook: exact,
    }));
  }
}

main().catch(e => { console.error(e); process.exit(1); });
