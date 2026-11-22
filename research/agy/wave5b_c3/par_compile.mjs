#!/usr/bin/env node
/**
 * Wave 5B Engine A Track W5B-C3: Multi-Core Parallel Sharded Compiler Driver.
 *
 * Architecture:
 *   - Spawns K Node `worker_threads` immediately (overlapping worker `import(api.mjs)`
 *     with main-thread `p88_cache_prepare` + `p86_plan` + `x198pw_plan`).
 *   - Caps per-worker V8 old-generation heap via `resourceLimits` so total heap across
 *     all workers stays <= 4 GiB (e.g. 1024 MiB/worker for 4 workers).
 *   - Main thread runs frontend/lowering ONCE, then estimates per-function IR weight
 *     and LPT-packs `P134Private` & `P134Public` functions across K shards.
 *   - Sends each worker ONLY its 1/K pre-sliced cursor + `available` index; workers emit
 *     `shard_0.o .. shard_{K-1}.o` in parallel via `agy_parcg_emit_presliced`.
 *   - Links `shard_*.o + runtime-agy.o` via `gcc-10 -no-pie ... -lm -lpthread`.
 *
 * Usage:
 *   taskset -c 0,1,4,5 bash research/agy/locked_node.sh research/agy/wave5b_c3/par_compile.mjs \
 *     --api selfhost/build/agy/wave5b_c3/api.mjs \
 *     --shards 4 \
 *     --src <input.bend> \
 *     --out <exe> \
 *     [--rt selfhost/build/agy/unified/runtime-agy.o] \
 *     [--work-dir <dir>] \
 *     [--no-link] \
 *     [--manifest <jobs.json>]
 */
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {Worker} from 'node:worker_threads';
import {fileURLToPath, pathToFileURL} from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const WORKER_SCRIPT = path.join(__dirname, 'par_worker.mjs');
const ROOT = '/home/ai/bend2_agy';
const DEFAULT_RT = path.join(ROOT, 'selfhost/build/agy/unified/runtime-agy.o');
const BASE_FILE = path.join(ROOT, 'selfhost/dist/base.bend');
const CARRIER_FILE = path.join(ROOT, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';
const CC = '/usr/bin/x86_64-linux-gnu-gcc-10';

function parseArgs(argv) {
  const args = {
    api: null,
    shards: 4,
    src: null,
    out: null,
    rt: DEFAULT_RT,
    workDir: null,
    noLink: false,
    manifest: null,
    strategy: 'lpt', // 'lpt' or 'rr'
  };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--api') args.api = argv[++i];
    else if (a === '--shards') args.shards = Number(argv[++i]);
    else if (a === '--src') args.src = argv[++i];
    else if (a === '--out') args.out = argv[++i];
    else if (a === '--rt') args.rt = argv[++i];
    else if (a === '--work-dir') args.workDir = argv[++i];
    else if (a === '--no-link') args.noLink = true;
    else if (a === '--manifest') args.manifest = argv[++i];
    else if (a === '--strategy') args.strategy = argv[++i];
    else throw Error(`Unknown arg: ${a}`);
  }
  if (!args.api) throw Error('Missing --api');
  if (!args.manifest && !args.src) throw Error('Specify --src or --manifest');
  if (!Number.isInteger(args.shards) || args.shards < 1 || args.shards > 16) {
    throw Error(`Invalid --shards: ${args.shards}`);
  }
  return args;
}

// Fast IR statement weight estimator for LPT bin-packing (counts N111Stmt nodes in body).
function bodyWeight(stmt) {
  let w = 1;
  const stack = [stmt];
  let steps = 0;
  while (stack.length > 0 && steps < 4096) {
    steps++;
    const cur = stack.pop();
    if (!cur || typeof cur !== 'object') continue;
    w++;
    // Handle Con/Nil lists and nested branch bodies
    if (cur.$ === 'Con') {
      stack.push(cur.head, cur.tail);
    } else if (cur.body) {
      stack.push(cur.body);
    } else if (cur.then_body || cur.else_body) {
      if (cur.then_body) stack.push(cur.then_body);
      if (cur.else_body) stack.push(cur.else_body);
    } else {
      // Check common N111Stmt fields
      for (const k of Object.keys(cur)) {
        if (k === '$' || k === 'name' || k === 'dest' || k === 'op') continue;
        const v = cur[k];
        if (v && typeof v === 'object' && (v.$ === 'Con' || v.$ === 'N111If' || v.$ === 'N111Switch' || v.$ === 'N111Loop' || v.$ === 'N111Case')) {
          stack.push(v);
        }
      }
    }
  }
  return w;
}

function listToArray(list) {
  const arr = [];
  let cur = list;
  while (cur?.$ === 'Con') {
    arr.push(cur.head);
    cur = cur.tail;
  }
  return arr;
}

function arrayToList(arr) {
  let acc = {$: 'Nil'};
  for (let i = arr.length - 1; i >= 0; i--) {
    acc = {$: 'Con', head: arr[i], tail: acc};
  }
  return acc;
}

// Partition items into K buckets using LPT (Longest Processing Time) greedy bin-packing.
function partitionItems(items, K, strategy) {
  const buckets = Array.from({length: K}, () => []);
  const loads = new Array(K).fill(0);
  if (strategy === 'rr') {
    for (let i = 0; i < items.length; i++) {
      buckets[i % K].push(items[i]);
    }
    return {buckets, loads};
  }
  const weighted = items.map((item, idx) => ({
    item,
    idx,
    w: bodyWeight(item?.body ?? item?.function?.body ?? item),
  }));
  weighted.sort((a, b) => b.w - a.w);
  for (const entry of weighted) {
    let best = 0;
    for (let k = 1; k < K; k++) {
      if (loads[k] < loads[best]) best = k;
    }
    buckets[best].push(entry.item);
    loads[best] += entry.w;
  }
  return {buckets, loads};
}

// Pre-slice P134Cursor into K independent shard cursors.
// Shard 0 keeps P134Tables + P134Main; shards 1..K-1 end at P134Main{} (skipped by isMain=false).
function sliceCursor(cursor, K, strategy) {
  // Collect segments along the cursor chain
  const segments = [];
  let cur = cursor;
  while (cur) {
    if (cur.$ === 'P134Private') {
      const items = listToArray(cur.functions ?? cur.entries ?? cur.a ?? cur[Object.keys(cur)[1]]);
      const fieldNames = Object.keys(cur).filter(k => k !== '$');
      segments.push({tag: 'P134Private', fieldNames, context: cur[fieldNames[1]], items});
      cur = cur[fieldNames[2]];
    } else if (cur.$ === 'P134Public') {
      const fieldNames = Object.keys(cur).filter(k => k !== '$');
      const items = listToArray(cur[fieldNames[0]]);
      segments.push({tag: 'P134Public', fieldNames, context: cur[fieldNames[1]], items});
      cur = cur[fieldNames[2]];
    } else if (cur.$ === 'P134Legacy') {
      const fieldNames = Object.keys(cur).filter(k => k !== '$');
      cur = cur[fieldNames[2]];
    } else if (cur.$ === 'P134Tables') {
      segments.push({tag: 'P134Tables', node: cur});
      break;
    } else if (cur.$ === 'P134Main') {
      segments.push({tag: 'P134Main', node: cur});
      break;
    } else {
      throw Error(`Unexpected cursor node: ${cur.$}`);
    }
  }

  // Partition each Private/Public segment across K shards
  const shardSegs = Array.from({length: K}, () => []);
  let totalFns = 0;
  const totalLoads = new Array(K).fill(0);
  for (const seg of segments) {
    if (seg.tag === 'P134Private' || seg.tag === 'P134Public') {
      totalFns += seg.items.length;
      const {buckets, loads} = partitionItems(seg.items, K, strategy);
      for (let k = 0; k < K; k++) {
        totalLoads[k] += loads[k];
        shardSegs[k].push({tag: seg.tag, fieldNames: seg.fieldNames, context: seg.context, list: arrayToList(buckets[k])});
      }
    } else if (seg.tag === 'P134Tables') {
      shardSegs[0].push(seg);
      for (let k = 1; k < K; k++) {
        shardSegs[k].push({tag: 'P134Main', node: {$: 'P134Main'}});
      }
    } else if (seg.tag === 'P134Main') {
      for (let k = 0; k < K; k++) {
        shardSegs[k].push(seg);
      }
    }
  }

  // Reconstruct K cursor chains
  const cursors = [];
  for (let k = 0; k < K; k++) {
    const segs = shardSegs[k];
    let tail = segs[segs.length - 1].node;
    for (let i = segs.length - 2; i >= 0; i--) {
      const s = segs[i];
      const node = {$: s.tag};
      node[s.fieldNames[0]] = s.list;
      node[s.fieldNames[1]] = s.context;
      node[s.fieldNames[2]] = tail;
      tail = node;
    }
    cursors.push(tail);
  }
  return {cursors, totalFns, totalLoads};
}

class WorkerPool {
  constructor(apiPath, count) {
    this.count = count;
    this.workers = [];
    this.readyPromises = [];
    // Cap total heap across workers to <= 4 GiB (leaving ~1 GiB for main thread).
    const perWorkerMb = Math.max(512, Math.floor(3072 / Math.max(count, 1)));
    for (let k = 0; k < count; k++) {
      const w = new Worker(WORKER_SCRIPT, {
        workerData: {apiPath, workerId: k},
        resourceLimits: {
          maxOldGenerationSizeMb: perWorkerMb,
          maxYoungGenerationSizeMb: 64,
        },
      });
      const readyP = new Promise((resolve, reject) => {
        const onMsg = (m) => {
          if (m.type === 'ready') {
            w.off('message', onMsg);
            resolve(m);
          }
        };
        w.on('message', onMsg);
        w.once('error', reject);
      });
      this.workers.push(w);
      this.readyPromises.push(readyP);
    }
  }

  async waitReady() {
    return Promise.all(this.readyPromises);
  }

  emitShard(workerIdx, payload) {
    const w = this.workers[workerIdx];
    return new Promise((resolve, reject) => {
      const onMsg = (m) => {
        if (m.type === 'done' && m.id === payload.id) {
          w.off('message', onMsg);
          w.off('error', onErr);
          resolve(m);
        }
      };
      const onErr = (err) => {
        w.off('message', onMsg);
        reject(err);
      };
      w.on('message', onMsg);
      w.once('error', onErr);
      w.postMessage({type: 'emit', ...payload});
    });
  }

  async shutdown() {
    for (const w of this.workers) {
      w.postMessage({type: 'shutdown'});
    }
    await Promise.all(this.workers.map(w => new Promise(r => w.once('exit', r))));
  }
}

function bytesListToBuffer(list) {
  const bytes = [];
  let cur = list;
  while (cur?.$ === 'Con') {
    bytes.push(cur.head);
    cur = cur.tail;
  }
  return Buffer.from(bytes);
}

async function compileOne(api, prepSeed, pool, job, args) {
  const t0 = performance.now();
  const srcText = fs.readFileSync(job.src, 'utf8');
  const tPlan0 = performance.now();
  const plan = api.p86_plan(prepSeed, job.src, srcText);
  if (plan.$ !== 'P86PlanReady') {
    throw Error(`plan failed on ${job.src}: ${plan.error ?? plan.$}`);
  }
  const tPw0 = performance.now();
  const prepared = api.x198pw_plan(plan);
  if (prepared.error !== '') {
    throw Error(`x198pw_plan failed on ${job.src}: ${prepared.error}`);
  }
  const tPrepCur0 = performance.now();
  const K = args.shards;

  const cleanup = !args.workDir && !job.workDir;
  const wd = job.workDir || args.workDir || fs.mkdtempSync(path.join(os.tmpdir(), 'w5b_parcg_'));
  fs.mkdirSync(wd, {recursive: true});

  try {
    let workerResults = [];
    let sliceMs = 0;
    let totalFns = 0;
    let objPaths = [];
    const tEmit0 = performance.now();

    if (K <= 1) {
      const obj = api.x187_prepared(prepared);
      if (obj.error !== '') throw Error(`x187_prepared failed: ${obj.error}`);
      const buf = bytesListToBuffer(obj.bytes);
      const outObj = job.outObj || path.join(wd, 'shard_0.o');
      fs.writeFileSync(outObj, buf);
      objPaths = [outObj];
      workerResults = [{shard: 0, ok: true, bytes: buf.length, emitMs: +(performance.now() - tEmit0).toFixed(1)}];
    } else {
      const ready = api.agy_parcg_prepare_cursor(prepared);
      if (ready.error !== '') throw Error(`prepare_cursor failed: ${ready.error}`);
      const tSlice0 = performance.now();
      const usePresliced = typeof api.agy_parcg_emit_presliced === 'function';
      let cursors = null;
      if (usePresliced) {
        const sliced = sliceCursor(ready.cursor, K, args.strategy);
        cursors = sliced.cursors;
        totalFns = sliced.totalFns;
      }
      sliceMs = +(performance.now() - tSlice0).toFixed(1);

      // Ensure workers finished importing api.mjs (usually already done during plan+pw!)
      await pool.waitReady();

      const tasks = [];
      for (let k = 0; k < K; k++) {
        const outObj = path.join(wd, `${job.id || 'prog'}_shard_${k}.o`);
        objPaths.push(outObj);
        const shardReady = usePresliced
          ? {$: 'AgyParCgReady', cursor: cursors[k], available: ready.available, error: ''}
          : ready;
        tasks.push(pool.emitShard(k, {
          id: `${job.id || 'p'}_${k}`,
          mode: usePresliced ? 'presliced' : 'rr',
          ready: shardReady,
          isMain: k === 0,
          shard: k,
          shards: K,
          outObjPath: outObj,
        }));
      }
      workerResults = await Promise.all(tasks);
      for (const r of workerResults) {
        if (!r.ok) throw Error(`shard ${r.shard} failed: ${r.error}`);
      }
    }
    const tEmit1 = performance.now();

    let linkMs = 0;
    if (!args.noLink && job.out) {
      const tLink0 = performance.now();
      fs.mkdirSync(path.dirname(job.out), {recursive: true});
      execFileSync(CC, ['-no-pie', ...objPaths, args.rt, '-lm', '-lpthread', '-o', job.out], {
        stdio: ['ignore', 'pipe', 'pipe'],
      });
      linkMs = +(performance.now() - tLink0).toFixed(1);
    }

    const tEnd = performance.now();
    return {
      id: job.id || path.basename(job.src, '.bend'),
      src: job.src,
      out: job.out || null,
      shards: K,
      totalFns,
      planMs: +(tPw0 - tPlan0).toFixed(1),
      pwMs: +(tPrepCur0 - tPw0).toFixed(1),
      sliceMs,
      emitWallMs: +(tEmit1 - tEmit0).toFixed(1),
      linkMs,
      totalMs: +(tEnd - t0).toFixed(1),
      totalObjBytes: workerResults.reduce((s, w) => s + w.bytes, 0),
      workerEmitMs: workerResults.map(w => w.emitMs),
    };
  } finally {
    if (cleanup) {
      fs.rmSync(wd, {recursive: true, force: true});
    }
  }
}

async function main() {
  const tStart = performance.now();
  const args = parseArgs(process.argv);

  // Start worker pool immediately so worker api.mjs import overlaps main-thread prep/plan!
  const pool = args.shards > 1 ? new WorkerPool(args.api, args.shards) : null;

  const tImp0 = performance.now();
  const api = (await import(pathToFileURL(args.api))).default;
  const importMs = +(performance.now() - tImp0).toFixed(1);

  const tPrep0 = performance.now();
  const baseText = fs.readFileSync(BASE_FILE, 'utf8');
  const carrier = fs.readFileSync(CARRIER_FILE, 'utf8');
  const prep = api.p88_cache_prepare(BASE_PATH, baseText, carrier, STAMP);
  if (prep.$ !== 'P86PreparationReady') throw Error(`p88_cache_prepare failed: ${prep.$}`);
  const prepMs = +(performance.now() - tPrep0).toFixed(1);

  const jobs = args.manifest
    ? JSON.parse(fs.readFileSync(args.manifest, 'utf8'))
    : [{id: path.basename(args.src, '.bend'), src: args.src, out: args.out}];

  const results = [];
  for (const job of jobs) {
    results.push(await compileOne(api, prep.seed, pool, job, args));
  }

  if (pool) await pool.shutdown();

  const wallMs = +(performance.now() - tStart).toFixed(1);
  console.log(JSON.stringify({
    api: args.api,
    shards: args.shards,
    strategy: args.strategy,
    importMs,
    prepMs,
    wallMs,
    results,
  }, null, 2));
}

main().catch((err) => {
  console.error(err?.stack || String(err));
  process.exit(1);
});
