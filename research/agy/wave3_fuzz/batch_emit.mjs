import fs from 'node:fs';
import {pathToFileURL} from 'node:url';

const [apiPath, manifestPath] = process.argv.slice(2);
const api = (await import(pathToFileURL(apiPath))).default;
const baseText = fs.readFileSync('/home/ai/bend2_agy/selfhost/dist/base.bend', 'utf8');
const carrier = fs.readFileSync('/home/ai/bend2_agy/selfhost/build/agy/bootstrap/base.p130', 'utf8');
const basePath = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const stamp = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';

const prep = api.p88_cache_prepare(basePath, baseText, carrier, stamp);
if (prep.$ !== 'P86PreparationReady') {
  throw Error('prep failed: ' + prep.$);
}

const jobs = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const results = [];

for (const job of jobs) {
  try {
    const src = fs.readFileSync(job.src, 'utf8');
    const plan = api.p86_plan(prep.seed, job.src, src);
    if (plan.$ !== 'P86PlanReady') {
      results.push({id: job.id, ok: false, stage: 'plan', error: String(plan.error ?? plan.$)});
      continue;
    }
    const obj = api.x187_prepared(api.x198pw_plan(plan));
    if (obj.error !== '') {
      results.push({id: job.id, ok: false, stage: 'emit', error: String(obj.error)});
      continue;
    }
    const bytes = [];
    let list = obj.bytes;
    while (list?.$ === 'Con') {
      bytes.push(list.head);
      list = list.tail;
    }
    if (list?.$ !== 'Nil' || bytes.length < 64) {
      results.push({id: job.id, ok: false, stage: 'bytes', error: 'invalid object list'});
      continue;
    }
    fs.writeFileSync(job.out, Buffer.from(bytes));
    results.push({id: job.id, ok: true, bytes: bytes.length});
  } catch (e) {
    results.push({id: job.id, ok: false, stage: 'exception', error: String(e?.message ?? e)});
  }
}

process.stdout.write(JSON.stringify(results));
