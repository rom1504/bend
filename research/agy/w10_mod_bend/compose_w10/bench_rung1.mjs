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

function listLen(xs) {
  let n = 0;
  let cur = xs;
  while (cur && cur.$ === 'Con') {
    n++;
    cur = cur.tail ?? cur.rest ?? cur.t ?? cur[1];
  }
  return n;
}

function cursorCounts(cursor) {
  let pubSegs = 0;
  let privFns = 0;
  let tables = 0;
  let cur = cursor;
  while (cur) {
    if (cur.$ === 'P134Private') {
      privFns += listLen(cur.functions ?? cur.entries ?? cur.items ?? cur[0]);
      cur = cur.next;
    } else if (cur.$ === 'P134Public') {
      pubSegs += listLen(cur.segments ?? cur.entries ?? cur.items ?? cur[0]);
      cur = cur.next;
    } else if (cur.$ === 'P134Legacy') {
      cur = cur.next;
    } else if (cur.$ === 'P134Tables') {
      tables += listLen(cur.tables ?? cur.entries ?? cur.items ?? cur[0]);
      break;
    } else {
      break;
    }
  }
  return {pubSegs, privFns, tables};
}

function countBytes(objRes) {
  if (!objRes) return 0;
  if (objRes.error && objRes.error.length > 0) {
    throw new Error('x187 error: ' + objRes.error);
  }
  const b = objRes.bytes ?? objRes.output ?? objRes[0];
  if (typeof b === 'string') return b.length;
  if (b instanceof Uint8Array || Array.isArray(b)) return b.length;
  return listLen(b);
}

const baseText = fs.readFileSync(BASE_FILE, 'utf8');
const carrierText = fs.readFileSync(CARRIER_FILE, 'utf8');
const tPrep0 = performance.now();
const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrierText, STAMP);
const prepMs = performance.now() - tPrep0;
if (prep.$ !== 'P86PreparationReady') {
  throw new Error('p88_cache_prepare failed: ' + JSON.stringify(prep));
}

const srcText = fs.readFileSync(SRC_PATH, 'utf8');

const t0 = performance.now();
let plan = api.p86_plan(prep.seed, SRC_PATH, srcText);
const p86Ms = performance.now() - t0;
if (plan.$ !== 'P86PlanReady') {
  throw new Error('p86_plan failed: ' + plan.error);
}
const annotatedDefs = listLen(plan.request.book);

const t1 = performance.now();
let prepared = api.x198pw_plan(plan);
plan = null;
const pwMs = performance.now() - t1;
if (prepared.error && prepared.error.length > 0) {
  throw new Error('x198pw_plan failed: ' + prepared.error);
}
const counts = cursorCounts(prepared.cursor);
const liveSegs = api.w8_cursor_seg_count ? api.w8_cursor_seg_count(prepared.cursor) : counts.pubSegs;

const t2 = performance.now();
let objFast = api.x187_prepared_fast(prepared);
const fastMs = performance.now() - t2;
const fastBytes = countBytes(objFast);
objFast = null;

console.log(JSON.stringify({
  api: API_PATH,
  src: SRC_PATH,
  prep_ms: Number(prepMs.toFixed(1)),
  annotated_defs: annotatedDefs,
  live_segments: liveSegs,
  private_functions: counts.privFns,
  tables: counts.tables,
  p86_plan_ms: Number(p86Ms.toFixed(1)),
  x198pw_plan_ms: Number(pwMs.toFixed(1)),
  x187_prepared_fast_ms: Number(fastMs.toFixed(1)),
  total_fast_ms: Number((p86Ms + pwMs + fastMs).toFixed(1)),
  obj_bytes_fast: fastBytes,
}, null, 2));
