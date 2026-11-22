import fs from 'node:fs';
import {pathToFileURL} from 'node:url';

const [apiPath, inputPath, outObjPath, shardStr = '0', shardsStr = '1'] = process.argv.slice(2);
const shard = Number(shardStr);
const shards = Number(shardsStr);
if (!Number.isInteger(shard) || !Number.isInteger(shards) || shards < 1 || shard < 0 || shard >= shards) {
  throw Error(`invalid shard/shards: ${shardStr}/${shardsStr}`);
}

const t0 = performance.now();
const api = (await import(pathToFileURL(apiPath))).default;
const baseText = fs.readFileSync('/home/ai/bend2_agy/selfhost/dist/base.bend', 'utf8');
const carrier = fs.readFileSync('/home/ai/bend2_agy/selfhost/build/agy/bootstrap/base.p130', 'utf8');
const basePath = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const stamp = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const tPrep0 = performance.now();
const prep = api.p88_cache_prepare(basePath, baseText, carrier, stamp);
if (prep.$ !== 'P86PreparationReady') throw Error('prep failed: ' + prep.$);
const tPlan0 = performance.now();
const plan = api.p86_plan(prep.seed, inputPath, fs.readFileSync(inputPath, 'utf8'));
if (plan.$ !== 'P86PlanReady') throw Error('plan failed: ' + (plan.error ?? plan.$));
const tLower0 = performance.now();
const prepared = api.x198pw_plan(plan);
const tEmit0 = performance.now();
const obj = shards <= 1
  ? api.x187_prepared(prepared)
  : api.x187_prepared_shard(prepared, shard, shards);
const tEmit1 = performance.now();
if (obj.error !== '') throw Error('x86 emit failed: ' + obj.error);

const bytes = [];
let list = obj.bytes;
while (list?.$ === 'Con') {
  bytes.push(list.head);
  list = list.tail;
}
if (list?.$ !== 'Nil' || bytes.length < 64) throw Error('invalid object list');
fs.writeFileSync(outObjPath, Buffer.from(bytes));
const tEnd = performance.now();

console.log(JSON.stringify({
  out: outObjPath,
  shard,
  shards,
  bytes: bytes.length,
  prepMs: +(tPlan0 - tPrep0).toFixed(1),
  planMs: +(tLower0 - tPlan0).toFixed(1),
  lowerMs: +(tEmit0 - tLower0).toFixed(1),
  emitMs: +(tEmit1 - tEmit0).toFixed(1),
  totalMs: +(tEnd - t0).toFixed(1),
}));
