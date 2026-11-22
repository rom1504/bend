import fs from 'node:fs';
import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';

const apiPath = process.argv[2] || '/home/ai/bend2_agy/selfhost/build/agy/wave4c_unified/api.mjs';
const outJson = process.argv[3] || '';
const saveObjDir = process.argv[4] || '';

const PROGRAMS = [
  ['lexer', '/home/ai/bend2_agy/selfhost/tests/consolidation/native-broad/lexer.bend'],
  ['raytrace', '/home/ai/bend2_agy/selfhost/tests/consolidation/native-broad/raytrace.bend'],
  ['gameoflife', '/home/ai/bend2_agy/research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend'],
  ['histogram', '/home/ai/bend2_agy/research/agy/wave4_bench/inputs/upstream/histogram/main.bend'],
  ['nbody', '/home/ai/bend2_agy/research/agy/wave4_bench/inputs/upstream/nbody/main.bend'],
  ['editdist', '/home/ai/bend2_agy/selfhost/tests/consolidation/native-broad/editdist.bend'],
];

const api = (await import(pathToFileURL(apiPath))).default;
const baseText = fs.readFileSync('/home/ai/bend2_agy/selfhost/dist/base.bend', 'utf8');
const carrier = fs.readFileSync('/home/ai/bend2_agy/selfhost/build/agy/bootstrap/base.p130', 'utf8');
const basePath = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const stamp = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const t0 = performance.now();
const prep = api.p88_cache_prepare(basePath, baseText, carrier, stamp);
const tPrep = performance.now() - t0;
if (prep.$ !== 'P86PreparationReady') throw Error('prep failed: ' + prep.$);

const results = {apiPath, prep_ms: +tPrep.toFixed(1), programs: {}};
let totalPlan = 0, totalPw = 0, totalEmit = 0;

if (saveObjDir) fs.mkdirSync(saveObjDir, {recursive: true});

for (const [name, inputPath] of PROGRAMS) {
  const src = fs.readFileSync(inputPath, 'utf8');
  const s0 = performance.now();
  const plan = api.p86_plan(prep.seed, inputPath, src);
  const s1 = performance.now();
  if (plan.$ !== 'P86PlanReady') throw Error(name + ' plan failed: ' + (plan.error ?? plan.$));
  const pw = api.x198pw_plan(plan);
  const s2 = performance.now();
  const obj = api.x187_prepared(pw);
  const s3 = performance.now();
  if (obj.error !== '') throw Error(name + ' x86 emit failed: ' + obj.error);
  const bytes = [];
  let list = obj.bytes;
  while (list?.$ === 'Con') { bytes.push(list.head); list = list.tail; }
  const s4 = performance.now();
  const buf = Buffer.from(bytes);
  if (saveObjDir) fs.writeFileSync(`${saveObjDir}/${name}.o`, buf);
  const crypto = await import('node:crypto');
  const sha = crypto.createHash('sha256').update(buf).digest('hex').slice(0, 16);
  const planMs = s1 - s0;
  const pwMs = s2 - s1;
  const emitMs = s3 - s2;
  const serMs = s4 - s3;
  totalPlan += planMs;
  totalPw += pwMs;
  totalEmit += emitMs;
  results.programs[name] = {
    plan_ms: +planMs.toFixed(1),
    pw_ms: +pwMs.toFixed(1),
    emit_ms: +emitMs.toFixed(1),
    ser_ms: +serMs.toFixed(1),
    total_ms: +(planMs + pwMs + emitMs).toFixed(1),
    bytes: bytes.length,
    sha256: sha,
  };
  console.log(`${name.padEnd(12)} plan=${planMs.toFixed(0).padStart(5)}ms  pw=${pwMs.toFixed(0).padStart(4)}ms  emit=${emitMs.toFixed(0).padStart(6)}ms  total=${(planMs+pwMs+emitMs).toFixed(0).padStart(6)}ms  size=${bytes.length}  sha=${sha}`);
}
results.totals = {
  plan_ms: +totalPlan.toFixed(1),
  pw_ms: +totalPw.toFixed(1),
  emit_ms: +totalEmit.toFixed(1),
  total_ms: +(totalPlan + totalPw + totalEmit).toFixed(1),
};
console.log(`TOTAL        plan=${totalPlan.toFixed(0).padStart(5)}ms  pw=${totalPw.toFixed(0).padStart(4)}ms  emit=${totalEmit.toFixed(0).padStart(6)}ms  total=${(totalPlan+totalPw+totalEmit).toFixed(0).padStart(6)}ms  (prep=${tPrep.toFixed(0)}ms)`);
if (outJson) fs.writeFileSync(outJson, JSON.stringify(results, null, 2));
