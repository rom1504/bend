#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const ROOT = '/home/ai/bend2_agy';
const API_PATH = process.argv[2] || '/tmp/agy_p3_x187/api.mjs';
const SRC_PATH = process.argv[3] || path.join(ROOT, 'research/agy/w9_ladder/rung1_parse.bend');
const MODE = process.argv[4] || 'both'; // 'e2e' | 'substage' | 'both'

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
if (prep.$ !== 'P86PreparationReady') throw new Error('prep failed');

const name = path.basename(SRC_PATH, '.bend');
const srcText = fs.readFileSync(SRC_PATH, 'utf8');

const tP86 = performance.now();
let plan = api.p86_plan(prep.seed, SRC_PATH, srcText);
const p86Ms = performance.now() - tP86;
prep = null;
if (plan.$ !== 'P86PlanReady') throw new Error(`p86_plan failed: ${plan.error}`);

const tPw = performance.now();
let prepared = api.x198pw_plan(plan);
const pwMs = performance.now() - tPw;
plan = null;
if (prepared.error && prepared.error.length > 0) throw new Error(`x198pw_plan failed: ${prepared.error}`);

const liveSegs = api.w8_cursor_seg_count(prepared.cursor);
const k = liveSegs / 1000.0;

if (MODE === 'e2e') {
  const t0 = performance.now();
  let obj = api.x187_prepared_fast(prepared);
  const fastMs = performance.now() - t0;
  prepared = null;
  if (obj.error && obj.error.length > 0) throw new Error(`x187_prepared_fast failed: ${obj.error}`);
  const elfBytes = listLen(obj.bytes);
  obj = null;
  const out = {
    api: API_PATH,
    name,
    live_segments: liveSegs,
    p86_plan_ms: Number(p86Ms.toFixed(1)),
    x198pw_plan_ms: Number(pwMs.toFixed(1)),
    x187_prepared_fast_ms: Number(fastMs.toFixed(1)),
    x187_ms_per_1k: Number((fastMs / k).toFixed(1)),
    elf_bytes: elfBytes,
  };
  fs.writeSync(2, `[e2e ${name}] segs=${liveSegs} x187_prepared_fast=${out.x187_prepared_fast_ms}ms (${out.x187_ms_per_1k} ms/1k) bytes=${elfBytes}\n`);
  console.log(JSON.stringify(out, null, 2));
  process.exit(0);
}

// Substage mode for new w10f_* pipeline:
let cursor = prepared.cursor;
prepared = null;

const tTotal0 = performance.now();
const tIdx0 = performance.now();
const avail = api.x181_cursor_index(cursor, api.missing());
const idxMs = performance.now() - tIdx0;

let build = api.x187_build_empty();
let cur = cursor;
cursor = null;

let privCount = 0, privEmitMs = 0, privBuildMs = 0;
let pubCount = 0, pubEmitMs = 0, pubBuildMs = 0;
let tableCount = 0, tableEmitMs = 0, tableBuildMs = 0;

while (cur) {
  if (cur.$ === 'P134Private') {
    let xs = getField(cur, 'functions', 'entries', 'items', 0);
    const ctx = getField(cur, 'context', 'ctx', 1);
    while (xs && xs.$ === 'Con') {
      const head = getField(xs, 'head', 'h', 0);
      const t0 = performance.now();
      const out = api.x181_program_private_fast(head, ctx, avail);
      const t1 = performance.now();
      build = api.w10f_output_fn(out, build);
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
      build = api.w10f_output_fn(out, build);
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

const namesCount = listLen(build.names);
const relocsCount = listLen(build.relocations);
const ts = build.textSize, rs = build.rodataSize, ds = build.dataSize;

const tFinish0 = performance.now();
let objRes = api.w10f_x201f_finish_any(build, false, api.missing());
build = null;
const finishMs = performance.now() - tFinish0;
if (objRes.error && objRes.error.length > 0) throw new Error(`finish error: ${objRes.error}`);
const elfBytes = listLen(objRes.bytes);
objRes = null;

const totalMs = performance.now() - tTotal0;
const row = {
  api: API_PATH,
  name,
  live_segments: liveSegs,
  priv_fns: privCount,
  pub_segs: pubCount,
  tables: tableCount,
  names_count: namesCount,
  relocs_count: relocsCount,
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
    finish_elf_total: Number(finishMs.toFixed(1)),
    total_sum: Number(totalMs.toFixed(1)),
  },
  ms_per_1k: {
    priv_total: Number(((privEmitMs + privBuildMs) / k).toFixed(1)),
    pub_total: Number(((pubEmitMs + pubBuildMs) / k).toFixed(1)),
    table_total: Number(((tableEmitMs + tableBuildMs) / k).toFixed(1)),
    finish_elf_total: Number((finishMs / k).toFixed(1)),
    total_sum: Number((totalMs / k).toFixed(1)),
  },
};
fs.writeSync(2, `[after ${name}] segs=${liveSegs} total=${row.ms.total_sum}ms (${row.ms_per_1k.total_sum} ms/1k) names=${namesCount} relocs=${relocsCount} priv=${row.ms.priv_total}ms pub=${row.ms.pub_total}ms finish+elf=${row.ms.finish_elf_total}ms bytes=${elfBytes}\n`);
console.log(JSON.stringify(row, null, 2));
