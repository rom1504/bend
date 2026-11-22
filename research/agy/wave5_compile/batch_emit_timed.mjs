import fs from 'node:fs';
import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';

const [apiPath, manifestPath] = process.argv.slice(2);
const tImport0 = performance.now();
const api = (await import(pathToFileURL(apiPath))).default;
const tImportMs = performance.now() - tImport0;

const baseText = fs.readFileSync('/home/ai/bend2_agy/selfhost/dist/base.bend', 'utf8');
const carrier = fs.readFileSync('/home/ai/bend2_agy/selfhost/build/agy/bootstrap/base.p130', 'utf8');
const basePath = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const stamp = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const tPrep0 = performance.now();
const prep = api.p88_cache_prepare(basePath, baseText, carrier, stamp);
const tPrepMs = performance.now() - tPrep0;
if (prep.$ !== 'P86PreparationReady') {
  throw Error('prep failed: ' + prep.$);
}

const jobs = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const results = [];
const tJobs0 = performance.now();

for (const job of jobs) {
  const t0 = performance.now();
  try {
    const src = fs.readFileSync(job.src, 'utf8');
    const tPlan0 = performance.now();
    const plan = api.p86_plan(prep.seed, job.src, src);
    const planMs = performance.now() - tPlan0;
    if (plan.$ !== 'P86PlanReady') {
      results.push({id: job.id, ok: false, stage: 'plan', plan_ms: planMs, emit_ms: 0, total_ms: performance.now() - t0, error: String(plan.error ?? plan.$)});
      continue;
    }
    const tEmit0 = performance.now();
    const obj = api.x187_prepared(api.x198pw_plan(plan));
    const emitMs = performance.now() - tEmit0;
    if (obj.error !== '') {
      results.push({id: job.id, ok: false, stage: 'emit', plan_ms: planMs, emit_ms: emitMs, total_ms: performance.now() - t0, error: String(obj.error)});
      continue;
    }
    const bytes = [];
    let list = obj.bytes;
    while (list?.$ === 'Con') {
      bytes.push(list.head);
      list = list.tail;
    }
    if (list?.$ !== 'Nil' || bytes.length < 64) {
      results.push({id: job.id, ok: false, stage: 'bytes', plan_ms: planMs, emit_ms: emitMs, total_ms: performance.now() - t0, error: 'invalid object list'});
      continue;
    }
    fs.writeFileSync(job.out, Buffer.from(bytes));
    results.push({
      id: job.id,
      ok: true,
      bytes: bytes.length,
      plan_ms: planMs,
      emit_ms: emitMs,
      total_ms: performance.now() - t0,
    });
  } catch (e) {
    results.push({id: job.id, ok: false, stage: 'exception', plan_ms: 0, emit_ms: 0, total_ms: performance.now() - t0, error: String(e?.message ?? e)});
  }
}

const tJobsMs = performance.now() - tJobs0;
process.stdout.write(JSON.stringify({
  import_ms: tImportMs,
  prep_ms: tPrepMs,
  jobs_ms: tJobsMs,
  results,
}));
