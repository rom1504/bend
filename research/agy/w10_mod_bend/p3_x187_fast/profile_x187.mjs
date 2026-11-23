#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const API_PATH = process.argv[2] || path.join(ROOT, 'selfhost/build/agy/wave10_unified/api.mjs');
const SRC_PATH = process.argv[3] || path.join(ROOT, 'research/agy/w9_ladder/rung1_parse.bend');

const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const mod = await import(pathToFileURL(API_PATH).href);
const api = mod.default ?? mod;

const NIL = {$: 'Nil'};

function listLen(xs) {
  let n = 0;
  let cur = xs;
  while (cur && cur.$ === 'Con') {
    n++;
    cur = cur.tail ?? cur.rest ?? cur.t ?? cur[1];
  }
  return n;
}

function getField(obj, ...names) {
  for (const k of names) {
    if (obj && Object.prototype.hasOwnProperty.call(obj, k)) return obj[k];
  }
  return undefined;
}

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
let prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
if (prep.$ !== 'P86PreparationReady') {
  throw new Error('p88_cache_prepare failed: ' + JSON.stringify(prep));
}

const name = path.basename(SRC_PATH, '.bend');
const srcText = fs.readFileSync(SRC_PATH, 'utf8');

let plan = api.p86_plan(prep.seed, SRC_PATH, srcText);
prep = null;
if (plan.$ !== 'P86PlanReady') throw new Error(`p86_plan failed: ${plan.error}`);
let prepared = api.x198pw_plan(plan);
plan = null;
if (prepared.error && prepared.error.length > 0) throw new Error(`x198pw_plan failed: ${prepared.error}`);

let cursor = prepared.cursor;
prepared = null;
const liveSegs = api.w8_cursor_seg_count(cursor);

const tTotal0 = performance.now();

const tIdx0 = performance.now();
const avail = api.x181_cursor_index(cursor, api.missing());
const idxMs = performance.now() - tIdx0;

let build = api.x187_build_empty();
let cur = cursor;
cursor = null;

let privCount = 0;
let privEmitMs = 0;
let privBuildMs = 0;

let pubCount = 0;
let pubEmitMs = 0;
let pubBuildMs = 0;

let tableCount = 0;
let tableEmitMs = 0;
let tableBuildMs = 0;

while (cur) {
  if (cur.$ === 'P134Private') {
    let xs = getField(cur, 'functions', 'entries', 'items', 0);
    const ctx = getField(cur, 'context', 'ctx', 1);
    while (xs && xs.$ === 'Con') {
      const head = getField(xs, 'head', 'h', 0);
      const t0 = performance.now();
      const out = api.x181_program_private_fast(head, ctx, avail);
      const t1 = performance.now();
      build = api.x187_output(out, build);
      const t2 = performance.now();
      privEmitMs += (t1 - t0);
      privBuildMs += (t2 - t1);
      privCount++;
      xs = getField(xs, 'tail', 'rest', 't', 1);
    }
    cur = cur.next;
  } else if (cur.$ === 'P134Legacy') {
    cur = cur.next;
  } else if (cur.$ === 'P134Public') {
    let xs = getField(cur, 'segments', 'entries', 'items', 0);
    const ctx = getField(cur, 'context', 'ctx', 1);
    while (xs && xs.$ === 'Con') {
      const head = getField(xs, 'head', 'h', 0);
      const t0 = performance.now();
      const out = api.x181_program_public_fast(head, ctx, avail);
      const t1 = performance.now();
      build = api.x187_output(out, build);
      const t2 = performance.now();
      pubEmitMs += (t1 - t0);
      pubBuildMs += (t2 - t1);
      pubCount++;
      xs = getField(xs, 'tail', 'rest', 't', 1);
    }
    cur = cur.next;
  } else if (cur.$ === 'P134Tables') {
    let xs = getField(cur, 'tables', 'entries', 'items', 0);
    while (xs && xs.$ === 'Con') {
      const head = getField(xs, 'head', 'h', 0);
      const t0 = performance.now();
      const out = api.x181_program_data(head, avail);
      const t1 = performance.now();
      build = api.x187_output(out, build);
      const t2 = performance.now();
      tableEmitMs += (t1 - t0);
      tableBuildMs += (t2 - t1);
      tableCount++;
      xs = getField(xs, 'tail', 'rest', 't', 1);
    }
    break;
  } else {
    break;
  }
}
cur = null;

const tMain0 = performance.now();
build = api.x187_build_seq(api.x181_program_main(), build);
const mainMs = performance.now() - tMain0;

if (build.error && build.error.length > 0) throw new Error(`build error: ${build.error}`);

let bText = build.text;
let bRodata = build.rodata;
let bData = build.data;
const ts = build.textSize;
const rs = build.rodataSize;
const ds = build.dataSize;
let bSymbols = build.symbols;
let bNames = build.names;
let bRelocs = build.relocations;
build = null;

const namesCount = listLen(bNames);
const relocsCount = listLen(bRelocs);

const tSymCnt0 = performance.now();
const symCntOk = api.x188_symbol_count(bNames, 0, 1);
const symCntMs = performance.now() - tSymCnt0;
if (symCntOk !== true) throw new Error('x188_symbol_count failed');

const tRev0 = performance.now();
let rodataFwd = api.nt_reverse(bRodata, NIL);
bRodata = null;
let dataFwd = api.nt_reverse(bData, NIL);
bData = null;
const revRdMs = performance.now() - tRev0;

const tScan0 = performance.now();
let fixState = api.x188_fixup_scan(
  bRelocs, bSymbols, ts, 0,
  {$: 'X188Fixups', patches: NIL, relocations: NIL, escaped: api.missing(), error: ''}
);
bRelocs = null;
const fixupScanMs = performance.now() - tScan0;
if (fixState.error && fixState.error.length > 0) throw new Error(`fixup scan error: ${fixState.error}`);

const patchesCount = listLen(fixState.patches);
const keptRelocsCount = listLen(fixState.relocations);
let escaped = fixState.escaped;
let keptRelocs = fixState.relocations;

const tApply0 = performance.now();
const planPatches = api.x201f_plan(fixState.patches, ts, 0, NIL);
let patched = api.x201f_selected(bText, fixState.patches, ts, planPatches);
bText = null;
fixState = null;
const fixupApplyMs = performance.now() - tApply0;
if (patched.error && patched.error.length > 0) throw new Error(`fixup apply error: ${patched.error}`);
let textFwd = patched.bytes;
patched = null;

const sizes = {$: 'X187ElfSizes', text: ts, rodata: rs, data: ds};

// Substage-profile x187_build_symbols + x187_elf_sized:
// 1. Collect X187Symbol list (exact mirror of x187_build_symbols -> x187_build_symbol_final -> x188_build_symbol_checked)
const tBuildSyms0 = performance.now();
let symList = NIL;
let keptSymsCount = 0;
let nCur = bNames;
while (nCur && nCur.$ === 'Con') {
  const nm = nCur.head;
  const sym = api.p111v_get(bSymbols, nm);
  const defined = sym.unsafe;
  const global = sym.native;
  if (!defined && nm.startsWith('.L')) throw new Error('undefined local label: ' + nm);
  const isGlob = global || !defined;
  const xsym = {
    $: 'X187Symbol',
    name: nm,
    section: sym.arity,
    value: sym.templates,
    size: sym.typ.id,
    global: isGlob,
    kind: sym.typ.quant,
  };
  if (!api.w7c_elf_sym_nums_valid(xsym.section, xsym.value, xsym.size, xsym.global, xsym.kind, sizes)) {
    throw new Error('invalid ELF symbol: ' + nm);
  }
  const drop = !isGlob && nm.startsWith('.L') && api.dk(api.p111v_get(escaped, nm)) === 'Absent';
  if (!drop) {
    symList = {$: 'Con', head: xsym, tail: symList};
    keptSymsCount++;
  }
  nCur = nCur.tail;
}
bNames = null;
bSymbols = null;
escaped = null;
const elfBuildSymsMs = performance.now() - tBuildSyms0;

// 2. x187_elf_symbols (locals) + x187_elf_globals (globals)
const tSymtab0 = performance.now();
const initSyms = {
  $: 'X187ElfSymbols',
  index: api.missing(),
  count: 1,
  firstGlobal: 1,
  table: api.x187_elf_zero(24, NIL),
  strings: {$: 'Con', head: 0, tail: NIL},
  stringSize: 1,
  error: '',
};
let localSyms = api.x187_elf_symbols(symList, false, sizes, initSyms);
let allSyms = api.x187_elf_globals(symList, sizes, localSyms);
localSyms = null;
symList = null;
const elfSymtabMs = performance.now() - tSymtab0;
if (allSyms.error && allSyms.error.length > 0) throw new Error(`elf symtab error: ${allSyms.error}`);

// 3. w7c_relocs_fused
const tRelocs0 = performance.now();
let relocRes = api.w7c_relocs_fused(keptRelocs, sizes, allSyms.index, 0, NIL, 0, NIL, 0, NIL, 0);
keptRelocs = null;
const elfRelocsMs = performance.now() - tRelocs0;
if (relocRes.$ !== 'W7cRelocOk') throw new Error('w7c_relocs_fused failed');

// 4. w7_elf_sections_emit
const tEmit0 = performance.now();
let objRes = api.w7_elf_sections_emit(
  textFwd, rodataFwd, dataFwd, ts, rs, ds,
  allSyms.count, allSyms.firstGlobal, allSyms.table, allSyms.strings, allSyms.stringSize,
  relocRes.parts
);
allSyms = null;
relocRes = null;
textFwd = null;
rodataFwd = null;
dataFwd = null;
const elfEmitMs = performance.now() - tEmit0;
if (objRes.error && objRes.error.length > 0) throw new Error(`elf emit error: ${objRes.error}`);
const elfBytes = listLen(objRes.bytes);

const elfTotalMs = elfBuildSymsMs + elfSymtabMs + elfRelocsMs + elfEmitMs;
const totalMs = performance.now() - tTotal0;
const k = liveSegs / 1000.0;

const row = {
  api: API_PATH,
  name,
  live_segments: liveSegs,
  priv_fns: privCount,
  pub_segs: pubCount,
  tables: tableCount,
  names_count: namesCount,
  kept_syms_count: keptSymsCount,
  relocs_count: relocsCount,
  patches_count: patchesCount,
  kept_relocs_count: keptRelocsCount,
  text_bytes: ts,
  rodata_bytes: rs,
  data_bytes: ds,
  elf_bytes: elfBytes,
  ms: {
    cursor_index: Number(idxMs.toFixed(1)),
    priv_emit: Number(privEmitMs.toFixed(1)),
    priv_build: Number(privBuildMs.toFixed(1)),
    priv_total: Number((privEmitMs + privBuildMs).toFixed(1)),
    pub_emit: Number(pubEmitMs.toFixed(1)),
    pub_build: Number(pubBuildMs.toFixed(1)),
    pub_total: Number((pubEmitMs + pubBuildMs).toFixed(1)),
    table_emit: Number(tableEmitMs.toFixed(1)),
    table_build: Number(tableBuildMs.toFixed(1)),
    table_total: Number((tableEmitMs + tableBuildMs).toFixed(1)),
    main_build: Number(mainMs.toFixed(1)),
    sym_count: Number(symCntMs.toFixed(1)),
    rev_rd: Number(revRdMs.toFixed(1)),
    fixup_scan: Number(fixupScanMs.toFixed(1)),
    fixup_apply: Number(fixupApplyMs.toFixed(1)),
    fixup_total: Number((fixupScanMs + fixupApplyMs).toFixed(1)),
    elf_build_syms: Number(elfBuildSymsMs.toFixed(1)),
    elf_symtab: Number(elfSymtabMs.toFixed(1)),
    elf_relocs: Number(elfRelocsMs.toFixed(1)),
    elf_emit: Number(elfEmitMs.toFixed(1)),
    elf_total: Number(elfTotalMs.toFixed(1)),
    total_sum: Number(totalMs.toFixed(1)),
  },
  ms_per_1k: {
    cursor_index: Number((idxMs / k).toFixed(1)),
    priv_emit: Number((privEmitMs / k).toFixed(1)),
    priv_build: Number((privBuildMs / k).toFixed(1)),
    priv_total: Number(((privEmitMs + privBuildMs) / k).toFixed(1)),
    pub_emit: Number((pubEmitMs / k).toFixed(1)),
    pub_build: Number((pubBuildMs / k).toFixed(1)),
    pub_total: Number(((pubEmitMs + pubBuildMs) / k).toFixed(1)),
    table_total: Number(((tableEmitMs + tableBuildMs) / k).toFixed(1)),
    fixup_scan: Number((fixupScanMs / k).toFixed(1)),
    fixup_apply: Number((fixupApplyMs / k).toFixed(1)),
    elf_build_syms: Number((elfBuildSymsMs / k).toFixed(1)),
    elf_symtab: Number((elfSymtabMs / k).toFixed(1)),
    elf_relocs: Number((elfRelocsMs / k).toFixed(1)),
    elf_emit: Number((elfEmitMs / k).toFixed(1)),
    elf_total: Number((elfTotalMs / k).toFixed(1)),
    total_sum: Number((totalMs / k).toFixed(1)),
  },
};

fs.writeSync(2, `[${name}] segs=${liveSegs} total=${row.ms.total_sum}ms (${row.ms_per_1k.total_sum} ms/1k) priv=${row.ms.priv_total}ms pub=${row.ms.pub_total}ms fixup=${row.ms.fixup_total}ms elf=${row.ms.elf_total}ms (syms=${row.ms.elf_build_syms} symtab=${row.ms.elf_symtab} relocs=${row.ms.elf_relocs} emit=${row.ms.elf_emit})\n`);
console.log(JSON.stringify(row, null, 2));
