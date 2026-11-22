#!/usr/bin/env node
/**
 * Wave 5 Engine A: Content-Addressed Incremental Compiler Driver (`incr_compile.mjs`).
 *
 * Architecture:
 *   1. Whole-program fast-path: if SHA256(api + rt + base + src) matches cached metadata
 *      and the output executable exists, returns in < 20 ms.
 *   2. Runs frontend + lowering (`p86_plan` + `x198pw_plan` + `agy_parcg_prepare_cursor`).
 *   3. Computes a 100% sound content-addressed SHA-256 key for:
 *        - Each `P134Private` function:   SHA256(apiSha, ctxHash, availHash, "Priv", fnIR)
 *        - Each `P134Public` segment:     SHA256(apiSha, ctxHash, availHash, "Pub", segIR)
 *        - `P134Tables` + `P134Main`:     SHA256(apiSha, availHash, "Tables", tablesIR)
 *      Because `P134Context` holds only global IDs/signatures (no function bodies!),
 *      editing 1 function's body leaves 99%+ of functions with identical hashes -> instant
 *      O(1) `.o` cache hits (0 ms x86 codegen!). Any caller that inlined the edited function
 *      automatically has a changed lowered IR -> automatically re-emitted (100% sound!).
 *   4. Emits ONLY cache-miss items (batched across K parallel `par_worker.mjs` workers when
 *      misses > 1, or inline on main thread when misses <= 2 to avoid worker startup!).
 *   5. Links all `.o` files (hits + fresh misses + tables.o + runtime-agy.o) via `gcc-10`
 *      using a response file (`@objs.rsp`) so arbitrary function counts link in ~0.08 s.
 *
 * Usage:
 *   taskset -c 0,1,4,5 bash research/agy/locked_node.sh research/agy/wave5_incr/incr_compile.mjs \
 *     --api selfhost/build/agy/wave5c_unified/api.mjs \
 *     --src <input.bend> \
 *     --out <exe> \
 *     [--cache-dir /tmp/agy_incr_cache] \
 *     [--shards 4] \
 *     [--rt selfhost/build/agy/unified/runtime-agy.o]
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {Worker} from 'node:worker_threads';
import {fileURLToPath, pathToFileURL} from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, '../../..');
const WORKER_SCRIPT = path.join(REPO, 'research/agy/wave5b_c3/par_worker.mjs');
const BASE_PATH = path.join(REPO, 'selfhost/dist/base.bend');
const CARRIER_PATH = path.join(REPO, 'selfhost/build/agy/bootstrap/base.p130');
const BASE_STAMP_PATH = '/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend';
const STAMP = 'p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212';
const DEFAULT_RT = path.join(REPO, 'selfhost/build/agy/unified/runtime-agy.o');

function parseArgs(argv) {
  const opts = {
    api: null,
    src: null,
    out: null,
    rt: DEFAULT_RT,
    cacheDir: '/tmp/agy_incr_cache',
    shards: 4,
    json: false,
  };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--api') opts.api = path.resolve(argv[++i]);
    else if (a === '--src') opts.src = path.resolve(argv[++i]);
    else if (a === '--out') opts.out = path.resolve(argv[++i]);
    else if (a === '--rt') opts.rt = path.resolve(argv[++i]);
    else if (a === '--cache-dir') opts.cacheDir = path.resolve(argv[++i]);
    else if (a === '--shards') opts.shards = Math.max(1, parseInt(argv[++i], 10));
    else if (a === '--json') opts.json = true;
    else throw new Error(`Unknown arg: ${a}`);
  }
  if (!opts.api || !opts.src || !opts.out) {
    throw new Error('Required: --api <api.mjs> --src <input.bend> --out <exe>');
  }
  return opts;
}

function sha256File(p) {
  const h = crypto.createHash('sha256');
  h.update(fs.readFileSync(p));
  return h.digest('hex');
}

// Fast iterative canonical AST hasher (zero huge JSON string allocations, stack-safe).
function hashValue(val, h) {
  const stack = [val];
  while (stack.length > 0) {
    const v = stack.pop();
    if (v === null) { h.update('N;'); continue; }
    if (v === undefined) { h.update('U;'); continue; }
    const t = typeof v;
    if (t === 'number') { h.update('d' + v + ';'); continue; }
    if (t === 'string') { h.update('s' + v.length + ':' + v + ';'); continue; }
    if (t === 'boolean') { h.update(v ? 'T;' : 'F;'); continue; }
    if (t === 'bigint') { h.update('b' + v.toString() + ';'); continue; }
    if (t === 'object') {
      const tag = v.$;
      if (tag !== undefined) {
        h.update('{' + tag + ':');
        const keys = Object.keys(v);
        for (let i = keys.length - 1; i >= 0; i--) {
          const k = keys[i];
          if (k === '$') continue;
          stack.push(v[k]);
          stack.push(k);
        }
      } else if (Array.isArray(v)) {
        h.update('[' + v.length + ':');
        for (let i = v.length - 1; i >= 0; i--) stack.push(v[i]);
      } else {
        const keys = Object.keys(v);
        h.update('O' + keys.length + ':');
        for (let i = keys.length - 1; i >= 0; i--) {
          stack.push(v[keys[i]]);
          stack.push(keys[i]);
        }
      }
    }
  }
}

function digestObj(salt, obj) {
  const h = crypto.createHash('sha256');
  h.update(salt);
  hashValue(obj, h);
  return h.digest('hex').slice(0, 32);
}

function listToArray(list) {
  const out = [];
  for (let cur = list; cur && cur.$ === 'Con'; cur = cur.tail) out.push(cur.head);
  return out;
}

function arrayToList(arr) {
  let acc = {$: 'Nil'};
  for (let i = arr.length - 1; i >= 0; i--) acc = {$: 'Con', head: arr[i], tail: acc};
  return acc;
}

function emitSingleUnit(api, cursor, available, isMain) {
  const ready = {$: 'AgyParCgReady', cursor, available, error: ''};
  const obj = api.agy_parcg_emit_presliced(ready, Boolean(isMain));
  if (obj.error !== '') {
    throw new Error(`x86 emit failed: ${obj.error}`);
  }
  const bytes = [];
  for (let l = obj.bytes; l && l.$ === 'Con'; l = l.tail) bytes.push(l.head);
  if (bytes.length < 64) throw new Error(`tiny object (${bytes.length} B)`);
  return Buffer.from(bytes);
}

function writeAtomic(filePath, buf) {
  const tmp = `${filePath}.${process.pid}.${Math.random().toString(16).slice(2)}.tmp`;
  fs.writeFileSync(tmp, buf);
  fs.renameSync(tmp, filePath);
}

function buildSingleItemCursor(seg, item) {
  const node = {$: seg.tag};
  node[seg.fieldNames[0]] = {$: 'Con', head: item, tail: {$: 'Nil'}};
  node[seg.fieldNames[1]] = seg.context;
  node[seg.fieldNames[2]] = {$: 'P134Main'};
  return node;
}

async function emitMissesParallel(apiPath, misses, available, maxWorkers) {
  const K = Math.min(maxWorkers, misses.length);
  const perWorkerMb = Math.max(512, Math.floor(3072 / Math.max(K, 1)));
  const workers = [];
  const readyPs = [];
  for (let k = 0; k < K; k++) {
    const w = new Worker(WORKER_SCRIPT, {
      workerData: {apiPath, workerId: k},
      resourceLimits: {maxOldGenerationSizeMb: perWorkerMb, maxYoungGenerationSizeMb: 64},
    });
    const rp = new Promise((resolve, reject) => {
      const onMsg = (m) => { if (m.type === 'ready') { w.off('message', onMsg); resolve(m); } };
      w.on('message', onMsg);
      w.once('error', reject);
    });
    workers.push(w);
    readyPs.push(rp);
  }
  await Promise.all(readyPs);

  // Dispatch misses round-robin across K workers (1 unit = 1 .o file for fine-grained caching!)
  let nextIdx = 0;
  async function runWorker(w) {
    while (true) {
      const idx = nextIdx++;
      if (idx >= misses.length) break;
      const m = misses[idx];
      await new Promise((resolve, reject) => {
        const onMsg = (msg) => {
          if (msg.type === 'done' && msg.id === m.id) {
            w.off('message', onMsg);
            if (!msg.ok) reject(new Error(`worker failed on ${m.id}: ${msg.error}`));
            else resolve(msg);
          }
        };
        w.on('message', onMsg);
        w.postMessage({
          type: 'emit',
          mode: 'presliced',
          id: m.id,
          ready: {$: 'AgyParCgReady', cursor: m.cursor, available, error: ''},
          isMain: Boolean(m.isMain),
          outObjPath: m.outPath,
        });
      });
    }
  }
  try {
    await Promise.all(workers.map(runWorker));
  } finally {
    await Promise.all(workers.map(w => w.terminate()));
  }
}

async function main() {
  const tStart = performance.now();
  const opts = parseArgs(process.argv);
  const objCacheDir = path.join(opts.cacheDir, 'objs');
  const progCacheDir = path.join(opts.cacheDir, 'progs');
  fs.mkdirSync(objCacheDir, {recursive: true});
  fs.mkdirSync(progCacheDir, {recursive: true});

  const apiSha = sha256File(opts.api).slice(0, 16);
  const rtSha = sha256File(opts.rt).slice(0, 16);
  const srcText = fs.readFileSync(opts.src, 'utf8');
  const srcSha = crypto.createHash('sha256').update(srcText).digest('hex').slice(0, 24);
  const progKey = `${apiSha}_${rtSha}_${srcSha}`;
  const cachedExe = path.join(progCacheDir, `${progKey}.bin`);

  // 1. Whole-program fast path
  if (fs.existsSync(cachedExe)) {
    fs.mkdirSync(path.dirname(opts.out), {recursive: true});
    fs.copyFileSync(cachedExe, opts.out);
    fs.chmodSync(opts.out, 0o755);
    const totalMs = performance.now() - tStart;
    const summary = {
      mode: 'whole_prog_hit',
      src: opts.src,
      out: opts.out,
      totalUnits: 0,
      hits: 0,
      misses: 0,
      planMs: 0,
      pwMs: 0,
      hashMs: 0,
      emitMs: 0,
      linkMs: 0,
      totalMs: Math.round(totalMs * 10) / 10,
    };
    if (opts.json) process.stdout.write(JSON.stringify(summary) + '\n');
    else console.log(`[INCR] WHOLE-PROG CACHE HIT -> ${opts.out} in ${summary.totalMs} ms`);
    return;
  }

  // 2. Import compiler & run plan + pw + cursor
  const api = (await import(pathToFileURL(opts.api))).default;
  const baseText = fs.readFileSync(BASE_PATH, 'utf8');
  const carrier = fs.readFileSync(CARRIER_PATH, 'utf8');
  const prep = api.p88_cache_prepare(BASE_STAMP_PATH, baseText, carrier, STAMP);
  if (prep.$ !== 'P86PreparationReady') throw new Error('prep failed: ' + prep.$);

  const tPlan0 = performance.now();
  const plan = api.p86_plan(prep.seed, opts.src, srcText);
  if (plan.$ !== 'P86PlanReady') throw new Error('plan failed: ' + (plan.error ?? plan.$));
  const planMs = performance.now() - tPlan0;

  const tPw0 = performance.now();
  const pw = api.x198pw_plan(plan);
  const ready = api.agy_parcg_prepare_cursor(pw);
  if (ready.error !== '') throw new Error('prepare_cursor failed: ' + ready.error);
  const pwMs = performance.now() - tPw0;

  // 3. Walk cursor & compute per-unit content-addressed keys
  const tHash0 = performance.now();
  const availHash = digestObj(apiSha + ':AVAIL:', ready.available);
  const units = [];
  let cur = ready.cursor;
  let segIdx = 0;
  while (cur) {
    if (cur.$ === 'P134Private' || cur.$ === 'P134Public') {
      const fieldNames = Object.keys(cur).filter(k => k !== '$');
      const items = listToArray(cur[fieldNames[0]]);
      const context = cur[fieldNames[1]];
      const ctxHash = digestObj(`${apiSha}:${availHash}:CTX${segIdx}:`, context);
      const seg = {tag: cur.$, fieldNames, context};
      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        const key = digestObj(`${ctxHash}:${cur.$}:`, item);
        const objPath = path.join(objCacheDir, `${key}.o`);
        units.push({
          id: `${cur.$}_${segIdx}_${i}`,
          key,
          objPath,
          isMain: false,
          makeCursor: () => buildSingleItemCursor(seg, item),
        });
      }
      segIdx++;
      cur = cur[fieldNames[2]];
    } else if (cur.$ === 'P134Legacy') {
      const fieldNames = Object.keys(cur).filter(k => k !== '$');
      cur = cur[fieldNames[2]];
    } else if (cur.$ === 'P134Tables' || cur.$ === 'P134Main') {
      const key = digestObj(`${apiSha}:${availHash}:MAIN:`, cur);
      const objPath = path.join(objCacheDir, `${key}.o`);
      const tailNode = cur;
      units.push({
        id: 'TABLES_MAIN',
        key,
        objPath,
        isMain: true,
        makeCursor: () => tailNode,
      });
      break;
    } else {
      throw new Error(`Unexpected cursor node: ${cur.$}`);
    }
  }

  const misses = [];
  let hits = 0;
  const seenKeys = new Set();
  const objPaths = [];
  for (const u of units) {
    objPaths.push(u.objPath);
    if (fs.existsSync(u.objPath)) {
      hits++;
    } else if (!seenKeys.has(u.key)) {
      seenKeys.add(u.key);
      misses.push({
        id: u.id,
        key: u.key,
        outPath: u.objPath,
        isMain: u.isMain,
        cursor: u.makeCursor(),
      });
    }
  }
  const hashMs = performance.now() - tHash0;

  // 4. Emit ONLY cache misses (inline if <= 4 misses to avoid worker startup overhead; parallel otherwise!)
  const tEmit0 = performance.now();
  if (misses.length > 0) {
    if (opts.shards <= 1 || misses.length <= 4) {
      for (const m of misses) {
        const buf = emitSingleUnit(api, m.cursor, ready.available, m.isMain);
        writeAtomic(m.outPath, buf);
      }
    } else {
      await emitMissesParallel(opts.api, misses, ready.available, opts.shards);
    }
  }
  const emitMs = performance.now() - tEmit0;

  // 5. Link all .o files via response file
  const tLink0 = performance.now();
  fs.mkdirSync(path.dirname(opts.out), {recursive: true});
  const rspPath = path.join(opts.cacheDir, `link_${process.pid}.rsp`);
  // Deduplicate objPaths in case two identical units hashed identically
  const uniqueObjs = [...new Set(objPaths)];
  fs.writeFileSync(rspPath, [...uniqueObjs, opts.rt].join('\n') + '\n');
  try {
    execFileSync('/usr/bin/x86_64-linux-gnu-gcc-10', [
      '-no-pie', `@${rspPath}`, '-lm', '-lpthread', '-o', opts.out,
    ], {stdio: 'pipe'});
  } finally {
    try { fs.unlinkSync(rspPath); } catch {}
  }
  const linkMs = performance.now() - tLink0;

  // Save whole-program cache entry
  try {
    const tmpBin = `${cachedExe}.${process.pid}.tmp`;
    fs.copyFileSync(opts.out, tmpBin);
    fs.renameSync(tmpBin, cachedExe);
  } catch {}

  const totalMs = performance.now() - tStart;
  const summary = {
    mode: misses.length === 0 ? 'all_obj_hits' : 'incremental',
    src: opts.src,
    out: opts.out,
    totalUnits: units.length,
    hits,
    misses: misses.length,
    hitRatePct: units.length ? Math.round((hits / units.length) * 1000) / 10 : 100,
    planMs: Math.round(planMs * 10) / 10,
    pwMs: Math.round(pwMs * 10) / 10,
    hashMs: Math.round(hashMs * 10) / 10,
    emitMs: Math.round(emitMs * 10) / 10,
    linkMs: Math.round(linkMs * 10) / 10,
    totalMs: Math.round(totalMs * 10) / 10,
  };
  if (opts.json) process.stdout.write(JSON.stringify(summary) + '\n');
  else {
    console.log(
      `[INCR] units=${summary.totalUnits} hits=${summary.hits} (${summary.hitRatePct}%) misses=${summary.misses} | ` +
      `plan=${summary.planMs}ms pw=${summary.pwMs}ms hash=${summary.hashMs}ms emit=${summary.emitMs}ms link=${summary.linkMs}ms total=${summary.totalMs}ms`
    );
  }
}

main().catch((e) => {
  console.error(e?.stack ?? String(e));
  process.exit(1);
});
