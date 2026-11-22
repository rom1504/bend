/**
 * Wave 6: Incremental Frontend + Lowering + Content-Addressed Object Cache Engine.
 *
 * Eliminates the Wave 5 `p86_plan` + `x198pw_plan` + `node`/`api.mjs` startup bottleneck:
 *   - Path 0 (`whole_prog_hit`): SHA256(api + rt + src) hit -> copy cached exe (< 5 ms).
 *   - Path 1 (`incr_fe_lower`): Soundness-gated def-level incremental pipeline:
 *       1. Top-level source diff: verifies imports, types, laws, def-set, and all def
 *          headers/signatures are unchanged (explicit return type required on edited defs).
 *       2. Dependent-type guard: verifies no edited def is referenced in any other def's type.
 *       3. Incremental parse: parses ONLY edited def(s) via `f_prefix_complete_source`
 *          with strictly fresh binder IDs (> maxBinderId).
 *       4. Incremental typecheck + annotate: verifies edited def(s)'s `typ`, arity, reachability,
 *          and runs `check_definition_body` + `ka_def` + `driver_emit_owned` + opt-pass guards
 *          ONLY on edited def(s).
 *       5. Incremental `p113pl_candidates`: lowers ONLY edited def(s) and splices into cached
 *          candidate table.
 *       6. Incremental `p169o_selected`: topological inline walk that skips every unchanged
 *          function whose callees do not intersect `dirtyTableNames` (eliminating 99% of
 *          the 160-1200 ms `p169o_walk` cost!).
 *       7. Incremental verify + cursor splice: runs `p168v_functions` + `p118b_verify_functions`
 *          on ONLY dirty functions, splices into cached `P134Private`, runs `x198pw_after`
 *          and enriches ONLY dirty items with `agy_enrich_cursor`.
 *       8. Incremental hash + warm-JIT inline x86 emit + fast link (`gcc-10 -fuse-ld=gold`).
 *   - Path 2 (`full_warm`): Automatic conservative fallback on cold build or any structural /
 *     signature / type / reachability / opt-pass / error change. Updates session state so the
 *     next edit hits Path 1.
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

export function sha256File(p) {
  const h = crypto.createHash('sha256');
  h.update(fs.readFileSync(p));
  return h.digest('hex');
}

export function hashValue(val, h) {
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

export function digestObj(salt, obj) {
  const h = crypto.createHash('sha256');
  h.update(salt);
  hashValue(obj, h);
  return h.digest('hex').slice(0, 32);
}

export function listToArray(list) {
  const out = [];
  for (let cur = list; cur && cur.$ === 'Con'; cur = cur.tail) out.push(cur.head);
  return out;
}

export function arrayToList(arr) {
  let acc = {$: 'Nil'};
  for (let i = arr.length - 1; i >= 0; i--) acc = {$: 'Con', head: arr[i], tail: acc};
  return acc;
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

/**
 * Split Bend source into top-level blocks.
 * Decorators (@unsafe, @meta, etc.) attach to the immediately following top-level item.
 */
export function splitTopLevelBlocks(src) {
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
        header: (pendingDecorators.length ? pendingDecorators.join('\n') + '\n' : '') + line,
        lines: [...pendingDecorators, line],
      };
      pendingDecorators = [];
    } else if (cur) {
      cur.lines.push(line);
    }
  }
  if (cur) blocks.push(cur);
  for (const b of blocks) {
    while (b.lines.length > 0) {
      const t = b.lines[b.lines.length - 1].trim();
      if (t === '' || t.startsWith('#')) b.lines.pop();
      else break;
    }
    b.text = b.lines.join('\n') + '\n';
    // Compute full multi-line header for `def` (through the first `:` at paren depth 0)
    if (b.kind === 'def') {
      const hdrLines = [];
      let depth = 0;
      for (const ln of b.lines) {
        hdrLines.push(ln);
        if (ln.startsWith('@')) continue;
        let done = false;
        for (let j = 0; j < ln.length; j++) {
          const ch = ln[j];
          if (ch === '#') break;
          if (ch === '(' || ch === '[' || ch === '{' || ch === '<') depth++;
          else if (ch === ')' || ch === ']' || ch === '}' || ch === '>') depth = Math.max(0, depth - 1);
          else if (ch === ':' && depth === 0) { done = true; break; }
        }
        if (done) break;
      }
      b.header = hdrLines.join('\n');
    }
  }
  return blocks;
}

/** Collect all `Ref` names and maximum binder `id` in a KTerm tree (iterative, stack-safe). */
function scanKTermRefsAndMaxId(root, refsSet) {
  let maxId = 0;
  const stack = [root];
  while (stack.length > 0) {
    const v = stack.pop();
    if (!v || typeof v !== 'object') continue;
    if (v.$ === 'KTerm') {
      if (v.tag === 'Ref' && typeof v.name === 'string') refsSet.add(v.name);
      if (typeof v.id === 'number' && v.id > maxId) maxId = v.id;
      if (v.kids) stack.push(v.kids);
    } else if (v.$ === 'KLambda') {
      if (typeof v.id === 'number' && v.id > maxId) maxId = v.id;
      if (v.kids) stack.push(v.kids);
    } else if (v.$ === 'Con') {
      stack.push(v.tail);
      stack.push(v.head);
    }
  }
  return maxId;
}

/** Alpha-normalized structural hash of a KTerm (ignores binder numeric ids and source spans). */
function hashKTermAlpha(root, salt) {
  const h = crypto.createHash('sha256');
  h.update(salt);
  const binderMap = new Map();
  let nextIdx = 1;
  const stack = [root];
  while (stack.length > 0) {
    const v = stack.pop();
    if (!v || typeof v !== 'object') { h.update(String(v) + ';'); continue; }
    if (v.$ === 'KTerm') {
      h.update('KT:' + v.tag + ':' + v.quant + ':');
      if (v.tag === 'All' || v.tag === 'Let' || v.tag === 'Use' || v.tag === 'Lam') {
        if (!binderMap.has(v.id)) binderMap.set(v.id, nextIdx++);
        h.update('B' + binderMap.get(v.id) + ';');
      } else if (v.tag === 'Var') {
        h.update('V' + (binderMap.get(v.id) ?? ('F' + v.id)) + ';');
      } else {
        h.update('N' + v.name + ':' + v.id + ';');
      }
      if (v.kids) stack.push(v.kids);
    } else if (v.$ === 'KLambda') {
      if (!binderMap.has(v.id)) binderMap.set(v.id, nextIdx++);
      h.update('KL:' + v.quant + ':B' + binderMap.get(v.id) + ';');
      if (v.kids) stack.push(v.kids);
    } else if (v.$ === 'KLiteral') {
      h.update('LIT:' + v.kind + ':' + v.number + ':' + v.text + ';');
    } else if (v.$ === 'Con') {
      h.update('C:');
      stack.push(v.tail);
      stack.push(v.head);
    } else if (v.$ === 'Nil') {
      h.update('N;');
    }
  }
  return h.digest('hex').slice(0, 32);
}

/** Check if two KTerm types are alpha-equivalent. */
function kTermTypeAlphaEq(t1, t2) {
  return hashKTermAlpha(t1, 'TY:') === hashKTermAlpha(t2, 'TY:');
}

function round1(x) { return Math.round(x * 10) / 10; }

function emitSingleUnit(api, cursor, available, isMain) {
  const ready = {$: 'AgyParCgReady', cursor, available, error: ''};
  const obj = api.agy_parcg_emit_presliced(ready, Boolean(isMain));
  if (obj.error !== '') throw new Error(`x86 emit failed: ${obj.error}`);
  const bytes = [];
  for (let l = obj.bytes; l && l.$ === 'Con'; l = l.tail) bytes.push(l.head);
  if (bytes.length < 64) throw new Error(`tiny object (${bytes.length} B)`);
  return Buffer.from(bytes);
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

export class IncrCompilerEngine {
  constructor(apiPath) {
    this.apiPath = path.resolve(apiPath);
    this.api = null;
    this.apiSha = null;
    this.seed = null;
    this.sessions = new Map(); // srcPath -> SessionState
    this.rtShaCache = new Map();
    this.hasGold = fs.existsSync('/usr/bin/ld.gold');
  }

  async init() {
    const t0 = performance.now();
    this.apiSha = sha256File(this.apiPath).slice(0, 16);
    this.api = (await import(pathToFileURL(this.apiPath))).default;
    const tImp = performance.now() - t0;

    const t1 = performance.now();
    const baseText = fs.readFileSync(BASE_PATH, 'utf8');
    const carrier = fs.readFileSync(CARRIER_PATH, 'utf8');
    const prep = this.api.p88_cache_prepare(BASE_STAMP_PATH, baseText, carrier, STAMP);
    if (prep.$ !== 'P86PreparationReady') throw new Error('p88_cache_prepare failed: ' + prep.$);
    this.seed = prep.seed;
    const tPrep = performance.now() - t1;
    return {apiLoadMs: round1(tImp), prepMs: round1(tPrep)};
  }

  getRtSha(rtPath) {
    const st = fs.statSync(rtPath);
    const prev = this.rtShaCache.get(rtPath);
    if (prev && prev.mtimeMs === st.mtimeMs && prev.size === st.size) return prev.sha;
    const sha = sha256File(rtPath).slice(0, 16);
    this.rtShaCache.set(rtPath, {mtimeMs: st.mtimeMs, size: st.size, sha});
    return sha;
  }

  /**
   * Run incremental `p169o_selected` (exact topological inline walk).
   * Reuses cached `outFn` for every function whose pre-inline hash is unchanged
   * and whose calls (both original and previously-inlined) do not touch `dirtyTableNames`.
   */
  runIncrementalP169o(fns1Arr, readyIdx, zipOwners, sel, prevCache, changedOwnerSet = null) {
    const api = this.api;
    const targets = sel.targets;
    let table = {$: 'P113IEmpty'};
    const nextCache = new Map();
    const dirtyTableNames = new Set();
    const outArr = [];
    const dirtyFns = [];
    let recomputedCount = 0;

    for (let i = 0; i < fns1Arr.length; i++) {
      const head = fns1Arr[i];
      const name = head.name;
      const prev = prevCache ? prevCache.get(name) : null;
      const owner = name.startsWith('$direct.') ? name.slice(8)
        : name.startsWith('$product.') ? name.slice(9) : name;
      const definitelyUnchanged = Boolean(prev && (prev.headRef === head || (changedOwnerSet && !changedOwnerSet.has(owner))));
      const headHash = definitelyUnchanged ? prev.headHash : digestObj('H:', head);
      const isSeed = definitelyUnchanged ? prev.isSeed : Boolean(api.p113d_ready(readyIdx, name));
      const isTarget = definitelyUnchanged ? prev.isTarget : (!isSeed && Boolean(api.p168t_has(targets, name)));

      let hit = false;
      if (prev && prev.headHash === headHash && prev.isSeed === isSeed && prev.isTarget === isTarget) {
        hit = true;
        if (dirtyTableNames.size > 0) {
          for (const c of prev.depCalls) {
            if (dirtyTableNames.has(c)) { hit = false; break; }
          }
        }
      }

      let outFn;
      let outHash;
      let depCalls;
      let inTable = false;

      if (hit) {
        outFn = prev.outFn;
        outHash = prev.outHash;
        depCalls = prev.depCalls;
        inTable = prev.inTable;
        if (inTable) {
          table = api.p113i_table_function(outFn, table);
        }
      } else {
        recomputedCount++;
        if (isSeed) {
          outFn = head;
          const clean = !api.w4i_is_borrow_worker(name) && !api.p113d_ready(zipOwners, name) && api.p113i_original_clean(head);
          if (clean) {
            const t2 = api.p113i_table_function(head, table);
            inTable = (t2 !== table);
            table = t2;
          }
        } else if (isTarget) {
          outFn = api.p168t_target(head, table);
          inTable = false;
        } else {
          outFn = api.p113i_function(api.p113i_function(head, table), table);
          const clean = !api.p113d_ready(zipOwners, name) && api.p113i_original_clean(head);
          if (clean) {
            const t2 = api.p113i_table_function(outFn, table);
            inTable = (t2 !== table);
            table = t2;
          }
        }
        outHash = digestObj('O:', outFn);
        // Track calls in BOTH `head.body` (what might be inlined) AND `outFn.body` (residual calls)
        // plus any calls that were previously inlined (if prev existed and had transitive deps).
        depCalls = new Set(listToArray(api.p113j_calls(head.body)));
        for (const c of listToArray(api.p113j_calls(outFn.body))) depCalls.add(c);

        const prevInTable = prev ? prev.inTable : false;
        const prevOutHash = prev ? prev.outHash : null;
        if (inTable || prevInTable) {
          if (inTable !== prevInTable || outHash !== prevOutHash) {
            dirtyTableNames.add(name);
          }
        }
        if (outHash !== prevOutHash) {
          dirtyFns.push({idx: i, fn: outFn});
        }
      }

      nextCache.set(name, {headRef: head, headHash, outFn, outHash, isSeed, isTarget, depCalls, inTable});
      outArr.push(outFn);
    }

    return {outArr, nextCache, dirtyFns, recomputedCount};
  }

  /**
   * Check whether we can take the incremental frontend + lowering fast path for `srcPath`.
   * Returns `{ok: true, changedBlocks}` or `{ok: false, reason}`.
   */
  checkIncrementalEligibility(session, newBlocks) {
    if (!session || !session.valid) return {ok: false, reason: 'no_session'};
    const oldBlocks = session.blocks;
    if (oldBlocks.length !== newBlocks.length) return {ok: false, reason: 'block_count_changed'};

    const changedBlocks = [];
    for (let i = 0; i < newBlocks.length; i++) {
      const ob = oldBlocks[i];
      const nb = newBlocks[i];
      if (ob.kind !== nb.kind || ob.name !== nb.name) {
        return {ok: false, reason: `structure_changed:${ob.kind}:${ob.name}`};
      }
      if (ob.text === nb.text) continue;
      if (ob.kind !== 'def') {
        return {ok: false, reason: `non_def_changed:${ob.kind}:${ob.name}`};
      }
      if (ob.header !== nb.header) {
        return {ok: false, reason: `header_changed:${ob.name}`};
      }
      // Require explicit return type annotation in header (`-> ...:`) so type cannot drift via inference
      if (!ob.header.includes('->')) {
        return {ok: false, reason: `unannotated_def:${ob.name}`};
      }
      // Dependent-type soundness guard: if edited def is referenced in any other def's type, fall back!
      if (session.defTypeDeps.has(ob.name)) {
        return {ok: false, reason: `dep_type_ref:${ob.name}`};
      }
      // Ensure edited def is in our private lowering domain (not in retry/public-only)
      if (!session.remNamesSet.has(ob.name) || session.retryOwnersSet.has(ob.name)) {
        return {ok: false, reason: `not_private_rem:${ob.name}`};
      }
      // Ensure edited def was not modified by whole-program opt passes
      if (session.optTouchedNames.has(ob.name)) {
        return {ok: false, reason: `opt_touched:${ob.name}`};
      }
      changedBlocks.push(nb);
    }

    if (changedBlocks.length === 0) return {ok: false, reason: 'no_diff_blocks'};
    if (changedBlocks.length > 8) return {ok: false, reason: 'too_many_changed_defs'};
    return {ok: true, changedBlocks};
  }

  /**
   * Attempt Path 1: Incremental frontend + incremental lowering + incremental cursor splice.
   * Returns `{ok: true, ...}` or `{ok: false, reason}` (which seamlessly falls back to Path 2).
   */
  tryIncrementalFrontAndLower(session, srcPath, newBlocks, changedBlocks, objCacheDir) {
    const api = this.api;
    const seed = this.seed;
    const base = seed.source;

    // --- Stage A: Incremental Parse (ONLY changed defs) ---
    const tFe0 = performance.now();
    const miniText = changedBlocks.map(b => b.text).join('\n');
    const begin = api.f_source_end(base);
    const miniSrc = api.f_source_located(
      {$: 'FSource', name: srcPath, path: srcPath, text: miniText},
      begin,
      begin + api.p86_width(miniText, 0) + 1
    );
    const header = api.f_source_header(miniSrc);
    if (header.error !== '') return {ok: false, reason: 'mini_header_err'};

    const seeded = api.f_prefix_complete_ready_seed(
      base, '', api.f_prefix_graph_empty(), api.f_source_path(base), api.f_source_text(base), seed.book, seed.ready
    );
    const sourcesList = {$: 'Con', head: miniSrc, tail: {$: 'Con', head: base, tail: {$: 'Nil'}}};
    const completed = api.f_prefix_complete_source(
      miniSrc, '', header, sourcesList, seeded.carrier, api.f_path_dir(api.f_source_path(miniSrc))
    );
    const freshBumped = {$: 'FFreshPrefixState', next: session.maxBinderId + 16, ready: seed.fresh.ready};
    const load = api.f_prefix_graph_trace(completed.carrier, sourcesList, freshBumped);
    if (load.trace.result.error !== '') return {ok: false, reason: 'mini_parse_err'};

    const parsedDefs = listToArray(load.suffix);
    if (parsedDefs.length !== changedBlocks.length) return {ok: false, reason: 'parsed_count_mismatch'};

    // Verify each parsed def matches name, kind, arity, native, unsafe, and alpha-eq type,
    // and only references already-reachable symbols!
    let newMaxId = session.maxBinderId + 16;
    const parsedMap = new Map();
    for (let i = 0; i < parsedDefs.length; i++) {
      const d = parsedDefs[i];
      const prevDef = session.bookMap.get(d.name);
      if (!prevDef) return {ok: false, reason: `unknown_def:${d.name}`};
      if (d.kind !== prevDef.kind || d.arity !== prevDef.arity ||
          d.native !== prevDef.native || d.unsafe !== prevDef.unsafe) {
        return {ok: false, reason: `meta_changed:${d.name}`};
      }
      if (!kTermTypeAlphaEq(d.typ, prevDef.typ)) {
        return {ok: false, reason: `type_changed:${d.name}`};
      }
      const refs = new Set();
      const id1 = scanKTermRefsAndMaxId(d.typ, refs);
      const id2 = scanKTermRefsAndMaxId(d.value, refs);
      if (id1 > newMaxId) newMaxId = id1;
      if (id2 > newMaxId) newMaxId = id2;
      for (const r of refs) {
        if (!session.bookMap.has(r)) return {ok: false, reason: `new_unknown_ref:${r}`};
        // If edited def now calls a user def that wasn't previously reachable, fall back!
        const rd = session.bookMap.get(r);
        if (rd.kind === 'Def' && !session.reqNamesSet.has(r) && !session.stopsSet.has(r) && !rd.native) {
          return {ok: false, reason: `new_reachable_def:${r}`};
        }
      }
      parsedMap.set(d.name, d);
    }

    // --- Stage B: Incremental Typecheck + Annotate (ONLY changed defs) ---
    let splicedRawBook = session.book;
    for (const d of parsedDefs) splicedRawBook = api.book_put(splicedRawBook, d);
    const world = api.kw_initial(splicedRawBook);
    const checkedListArr = [];
    for (const d of parsedDefs) {
      const chk = api.check_definition_body(world, d, 0);
      if (!api.good(chk)) return {ok: false, reason: `typecheck_failed:${d.name}`};
      checkedListArr.push({...d, value: api.ct(chk)});
    }
    const checkedList = arrayToList(checkedListArr);
    const ownErr = api.driver_emit_owned(checkedList);
    if (ownErr !== '') return {ok: false, reason: `owned_err:${ownErr}`};

    let checkedBook = session.book;
    for (const cd of checkedListArr) checkedBook = api.book_put(checkedBook, cd);
    const ctx = api.book_context(checkedBook);
    const annDefsArr = checkedListArr.map(d => api.ka_def(ctx, d));
    const annList = arrayToList(annDefsArr);

    // Verify jl_checked_error on edited defs
    const editedNamesList = arrayToList(changedBlocks.map(b => b.name));
    const jlErr = api.jl_checked_error(ctx, annList, editedNamesList, session.stops);
    if (jlErr !== '') return {ok: false, reason: `jl_err:${jlErr}`};

    // Guard: check if agy_bf_pass, agy_abs_pass, or w2d_pass wants to rewrite any edited def
    const bfRes = api.agy_bf_pass(ctx, annList);
    if (bfRes.changed) return {ok: false, reason: 'bf_pass_rewrote_def'};
    const absRes = api.agy_abs_pass(ctx, annList);
    if (absRes.changed) return {ok: false, reason: 'abs_pass_rewrote_def'};
    const w2dRes = api.w2d_pass(ctx, annList);
    if (w2dRes.changed) return {ok: false, reason: 'w2d_pass_rewrote_def'};

    let newBook = session.book;
    for (const ad of annDefsArr) newBook = api.book_put(newBook, ad);
    const annMap = new Map(annDefsArr.map(d => [d.name, d]));
    const newBookArr = session.bookArr.map(d => annMap.has(d.name) ? annMap.get(d.name) : d);
    const planMs = performance.now() - tFe0;

    // --- Stage C: Incremental Lowering (`p113pl_candidates` + `p169o_selected` + splice) ---
    const tPw0 = performance.now();
    // Verify static prep / bangs / sigs didn't change for edited defs
    const sPrepMini = api.p112s_prepare(newBook, editedNamesList, session.ctors);
    if (sPrepMini.error !== '' || listToArray(sPrepMini.nodes).length > 0) {
      return {ok: false, reason: 'static_nodes_changed'};
    }
    const newBangsMini = listToArray(api.nc_bangs_names(newBook, editedNamesList));
    for (const b of newBangsMini) {
      if (!session.bangsSet.has(b)) return {ok: false, reason: `bang_changed:${b}`};
    }

    // Recompute ONLY `p113pl_candidates` for the edited def(s)!
    const newCands = listToArray(api.p113pl_candidates(newBook, editedNamesList, session.bangs, session.sigs));
    const newCandsByOwner = new Map();
    for (const c of newCands) {
      const fnName = c.function.name;
      // Map `$direct.foo` or `$product.foo` back to `foo`
      const owner = fnName.startsWith('$direct.') ? fnName.slice(8)
        : fnName.startsWith('$product.') ? fnName.slice(9) : fnName;
      if (!newCandsByOwner.has(owner)) newCandsByOwner.set(owner, []);
      newCandsByOwner.get(owner).push(c);
    }

    // Splice into cached `rawCandByName` preserving exact order!
    const nextRawCandByName = new Map(session.rawCandByName);
    const editedSet = new Set(changedBlocks.map(b => b.name));
    for (const ename of editedSet) {
      nextRawCandByName.set(ename, newCandsByOwner.get(ename) ?? []);
    }
    const allRawCands = [];
    for (const rname of session.remNamesArr) {
      const arr = nextRawCandByName.get(rname);
      if (arr) for (const c of arr) allRawCands.push(c);
    }

    // Run fast toposort + w4p adapter (~2-8 ms total)
    const sc = api.p126sc_candidates(arrayToList(allRawCands));
    const fns0 = api.p113d_passes(sc, session.readyIdx, api.nt_reverse(session.workers, {$: 'Nil'}), 32);
    const fns1 = api.w4p_adapt_functions(fns0, session.readyIdx, session.workers, session.sigs);
    const fns1Arr = listToArray(fns1);

    // Verify function set & order stability (if a new product/direct function appeared/disappeared, fall back)
    if (fns1Arr.length !== session.fns1Names.length) {
      return {ok: false, reason: 'fns1_count_changed'};
    }
    for (let i = 0; i < fns1Arr.length; i++) {
      if (fns1Arr[i].name !== session.fns1Names[i]) {
        return {ok: false, reason: `fns1_order_changed:${fns1Arr[i].name}`};
      }
    }

    // Incremental `p169o_selected` (re-inlines ONLY edited functions + callers of changed table entries!)
    const p169o = this.runIncrementalP169o(fns1Arr, session.readyIdx, session.zipOwners, session.sel, session.p169oCache, editedSet);
    if (p169o.dirtyFns.length === 0) {
      // Technically possible if edit was dead/folded identically! Still valid.
    }

    // Verify ONLY dirty functions (`p168v_functions` + `p118b_project_function` + `p113e_functions` with cached prefixSigs)!
    const dirtyOnlyFns = p169o.dirtyFns.map(d => d.fn);
    const dirtyViewList = api.p168v_functions(arrayToList(dirtyOnlyFns), session.adapters);
    const dirtyViewArr = listToArray(dirtyViewList);
    for (let k = 0; k < dirtyViewArr.length; k++) {
      const idx = p169o.dirtyFns[k].idx;
      const proj = api.p118b_project_function(dirtyViewArr[k], session.verifyIds);
      if (proj.error !== '') return {ok: false, reason: `project_failed:${proj.error}`};
      const vErr = api.p113e_functions(proj.functions, session.verifyIds, session.prefixSigs[idx]);
      if (vErr !== '') return {ok: false, reason: `verify_failed:${vErr}`};
    }

    // Enrich ONLY dirty functions via `x198pw_after` + `agy_enrich_cursor`!
    const updatedReq = {...session.plan.request, book: newBook};

    // Build mini cursor for just the dirty functions so `x198pw_after` + `agy_enrich_cursor` run in < 1 ms!
    let enrichedDirtyMap = new Map();
    if (dirtyViewArr.length > 0) {
      const miniCursor = {
        $: 'P134Private',
        functions: dirtyViewList,
        context: session.privContext,
        next: {$: 'P134Main'},
      };
      const miniP169 = {$: 'P169Prepared', forwarders: session.prevP169.forwarders, cursor: miniCursor, error: ''};
      const miniPw = api.x198pw_after(miniP169, updatedReq);
      if (miniPw.error !== '') return {ok: false, reason: `mini_pw_err:${miniPw.error}`};
      const enrichedMini = api.agy_enrich_cursor(miniPw.cursor, session.prevReady.available);
      for (const f of listToArray(enrichedMini.functions)) {
        enrichedDirtyMap.set(f.name, f);
      }
    }

    const pwMs = performance.now() - tPw0;

    // --- Stage D: Incremental Hash (ONLY dirty items!) ---
    const tHash0 = performance.now();
    const nextUnits = session.units.slice();
    const misses = [];
    let hits = 0;
    const seenKeys = new Set();
    const objPaths = [];

    for (let i = 0; i < nextUnits.length; i++) {
      let u = nextUnits[i];
      if (u.fnName && enrichedDirtyMap.has(u.fnName)) {
        const newItem = enrichedDirtyMap.get(u.fnName);
        const key = digestObj(`${u.ctxHash}:${u.segTag}:`, newItem);
        const objPath = path.join(objCacheDir, `${key}.o`);
        u = {
          ...u,
          key,
          objPath,
          item: newItem,
          makeCursor: () => buildSingleItemCursor(u.seg, newItem),
        };
        nextUnits[i] = u;
      }
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

    // Update session state in-place for subsequent incremental edits!
    session.blocks = newBlocks;
    session.maxBinderId = newMaxId;
    session.book = newBook;
    session.bookArr = newBookArr;
    session.bookMap = new Map(newBookArr.map(d => [d.name, d]));
    session.plan = {...session.plan, request: updatedReq};
    session.rawCandByName = nextRawCandByName;
    session.p169oCache = p169o.nextCache;
    session.units = nextUnits;

    return {
      ok: true,
      mode: 'incr_fe_lower',
      available: session.prevReady.available,
      units: nextUnits,
      objPaths,
      hits,
      misses,
      planMs,
      pwMs,
      hashMs,
      recomputedP169o: p169o.recomputedCount,
      dirtyFnsCount: dirtyViewArr.length,
    };
  }

  /**
   * Path 2: Full compile (warm JIT) + populate SessionState for future incremental edits.
   */
  runFullCompile(srcPath, srcText, newBlocks, objCacheDir) {
    const api = this.api;
    const tPlan0 = performance.now();
    const plan = api.p86_plan(this.seed, srcPath, srcText);
    if (plan.$ !== 'P86PlanReady') {
      throw new Error('plan failed: ' + (plan.error ?? plan.$));
    }
    const planMs = performance.now() - tPlan0;

    const tPw0 = performance.now();
    const req = plan.request;
    const admErr = api.p111_runtime_admission(req);
    if (admErr !== '') throw new Error('admission failed: ' + admErr);

    // Run `p168_request_mode` step-by-step so we capture per-def caches for future incremental edits
    // WITHOUT any duplicate work!
    const ctors = api.nc_add_ctors(
      api.nc_default_ctors(),
      api.p144o_constructors(req.source, req.source, api.p144o_payload(api.nc_ctor_context(req.book)))
    );
    const mode = api.p169o_certified(1, api.p113a_certificate(req));
    const sPrep = api.p112s_prepare(req.book, req.names, ctors);
    if (sPrep.error !== '') throw new Error('p112s_prepare: ' + sPrep.error);
    const bangs = api.nc_bangs_names(sPrep.book, req.names);
    const cand = api.no_candidate_names(sPrep.book, req.names, bangs);
    const scan = api.p128br_scan(sPrep.book, cand, {$: 'Nil'}, {$: 'Nil'}, {$: 'Nil'}, {$: 'Nil'});
    const sf = Object.keys(scan).filter(k => k !== '$');
    const workers = scan[sf[0]], helpers = scan[sf[1]], retry = scan[sf[2]], scanErr = scan[sf[3]];
    if (scanErr !== '') throw new Error('p128br_scan: ' + scanErr);

    const readyIdx = api.p113e_signatures(workers, api.missing());
    const rem = api.p167ob_remaining(sPrep.book, req.names, bangs, readyIdx);
    const sigs = api.book_cached(api.nq_signatures(sPrep.book, req.names), 0);

    // Populate `rawCandByName` by calling `p113pl_candidates` once on `rem`
    const remNamesArr = listToArray(rem);
    const raw = api.p113pl_candidates(sPrep.book, rem, bangs, sigs);
    const rawArr = listToArray(raw);
    const rawCandByName = new Map();
    for (const c of rawArr) {
      const fnName = c.function.name;
      const owner = fnName.startsWith('$direct.') ? fnName.slice(8)
        : fnName.startsWith('$product.') ? fnName.slice(9) : fnName;
      if (!rawCandByName.has(owner)) rawCandByName.set(owner, []);
      rawCandByName.get(owner).push(c);
    }

    const sc = api.p126sc_candidates(raw);
    const fns0 = api.p113d_passes(sc, readyIdx, api.nt_reverse(workers, {$: 'Nil'}), 32);
    const fns1 = api.w4p_adapt_functions(fns0, readyIdx, workers, sigs);
    const fns1Arr = listToArray(fns1);

    const qPlans = api.p169q_plans(sPrep.book, retry);
    const sel = api.p169q_selection(sPrep.book, qPlans, api.missing(), api.missing());
    const zipOwners = api.w4c_zip_owners_map(sPrep.book);

    let fns2;
    let p169oCache = null;
    if (mode === 2) {
      const p169o = this.runIncrementalP169o(fns1Arr, readyIdx, zipOwners, sel, null);
      fns2 = arrayToList(p169o.outArr);
      p169oCache = p169o.nextCache;
    } else {
      fns2 = api.p168t_selected(fns1, readyIdx, sel);
    }

    const scalars = api.p169q_scalars(sPrep.book, qPlans, fns2, {$: 'Nil'}, api.nt_reverse(helpers, {$: 'Nil'}), {$: 'Nil'});
    const scF = Object.keys(scalars).filter(k => k !== '$');
    const added = scalars[scF[0]], h2 = scalars[scF[1]], r2 = scalars[scF[2]], scErr = scalars[scF[3]];
    if (scErr !== '') throw new Error('p169q_scalars: ' + scErr);
    const mergedFns = api.nt_append(added, api.p118b_without(fns2, api.p113e_signatures(added, api.missing())));
    const stats = arrayToList([mode, 0, 0, 0, 0]);
    const lowered = api.p168_retry(req.source, sPrep.book, req.names, ctors, sPrep.nodes, bangs, stats, mergedFns, h2, r2);
    if (lowered.error !== '') throw new Error('p168_retry: ' + lowered.error);

    const vOrigErr = api.p167v_original(req.book, api.nc_bangs_names(req.book, req.names), lowered.program, lowered.adapters);
    const p169 = api.p169a_original(req, lowered.adapters, lowered.program, vOrigErr);
    const pw = api.x198pw_after(p169, req);
    const ready = api.agy_parcg_prepare_cursor(pw);
    if (ready.error !== '') throw new Error('prepare_cursor failed: ' + ready.error);
    const pwMs = performance.now() - tPw0;

    // Walk cursor & compute per-unit content-addressed keys
    const tHash0 = performance.now();
    const availHash = digestObj(this.apiSha + ':AVAIL:', ready.available);
    const units = [];
    let privContext = null;
    let cur = ready.cursor;
    let segIdx = 0;
    while (cur) {
      if (cur.$ === 'P134Private' || cur.$ === 'P134Public') {
        const fieldNames = Object.keys(cur).filter(k => k !== '$');
        const items = listToArray(cur[fieldNames[0]]);
        const context = cur[fieldNames[1]];
        if (cur.$ === 'P134Private' && !privContext) privContext = context;
        const ctxHash = digestObj(`${this.apiSha}:${availHash}:CTX${segIdx}:`, context);
        const seg = {tag: cur.$, fieldNames, context};
        for (let i = 0; i < items.length; i++) {
          const item = items[i];
          const key = digestObj(`${ctxHash}:${cur.$}:`, item);
          const objPath = path.join(objCacheDir, `${key}.o`);
          units.push({
            id: `${cur.$}_${segIdx}_${i}`,
            fnName: cur.$ === 'P134Private' ? item.name : null,
            segTag: cur.$,
            ctxHash,
            seg,
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
        const key = digestObj(`${this.apiSha}:${availHash}:MAIN:`, cur);
        const objPath = path.join(objCacheDir, `${key}.o`);
        const tailNode = cur;
        units.push({
          id: 'TABLES_MAIN',
          fnName: null,
          segTag: cur.$,
          ctxHash: null,
          seg: null,
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

    // Build SessionState for subsequent incremental edits (only if mode === 2 && privContext)
    if (mode === 2 && privContext && p169oCache) {
      const bookArr = listToArray(req.book);
      const bookMap = new Map(bookArr.map(d => [d.name, d]));
      const stops = api.nc_annotation_stops(req.book);
      const stopsSet = new Set(listToArray(stops));
      const reqNamesSet = new Set(listToArray(req.names));
      const defTypeDeps = new Map();
      let maxBinderId = 4096;
      const userDefNames = new Set(newBlocks.filter(b => b.kind === 'def').map(b => b.name));

      for (const d of bookArr) {
        const typeRefs = new Set();
        const id1 = scanKTermRefsAndMaxId(d.typ, typeRefs);
        if (id1 > maxBinderId) maxBinderId = id1;
        if (userDefNames.has(d.name)) {
          const valRefs = new Set();
          const id2 = scanKTermRefsAndMaxId(d.value, valRefs);
          if (id2 > maxBinderId) maxBinderId = id2;
        }
        for (const r of typeRefs) {
          if (r !== d.name && userDefNames.has(r)) {
            if (!defTypeDeps.has(r)) defTypeDeps.set(r, new Set());
            defTypeDeps.get(r).add(d.name);
          }
        }
      }

      // Track only defs that `p169q_plans` marked eligible (or `p169q_scalars` added) so we fall back if those are edited
      const retryOwnersSet = new Set();
      for (const qp of listToArray(qPlans)) {
        if (qp.eligible) {
          try { retryOwnersSet.add(api.no_plan_owner(qp.plan)); } catch {}
        }
      }
      for (const af of listToArray(added)) {
        const nm = af.name;
        const own = nm.startsWith('$direct.') ? nm.slice(8) : nm.startsWith('$product.') ? nm.slice(9) : nm;
        retryOwnersSet.add(own);
      }

      // Track any user def that appears to have been synthesized/modified by w2d/bf/abs
      const optTouchedNames = new Set();
      for (const d of bookArr) {
        if (d.name.startsWith('$w2d.') || d.name.startsWith('$bf.') || d.name.startsWith('$abs.') || d.name.startsWith('$p205v.')) {
          // Mark any user def referenced by a synthesized helper or whose name is a prefix
          const refs = new Set();
          scanKTermRefsAndMaxId(d.value, refs);
          for (const r of refs) if (userDefNames.has(r)) optTouchedNames.add(r);
        }
      }

      const origProg = lowered.program.original.program;
      // Precompute `verifyIds` and per-index `prefixSigs` for exact O(1) incremental verification
      const verifyIds = {
        $: 'N111Ids',
        functions: api.p113e_originals(origProg.segments, api.missing()),
        constructors: api.ns_ctor_index(origProg.constructors, api.missing()),
      };
      const fullViewArr = listToArray(api.p168v_functions(fns2, lowered.adapters));
      const prefixSigs = [];
      let sigAcc = api.missing();
      for (let i = 0; i < fullViewArr.length; i++) {
        prefixSigs.push(sigAcc);
        sigAcc = api.p113e_signatures({$: 'Con', head: fullViewArr[i], tail: {$: 'Nil'}}, sigAcc);
      }
      this.sessions.set(srcPath, {
        valid: true,
        blocks: newBlocks,
        maxBinderId,
        plan,
        book: sPrep.book,
        bookArr,
        bookMap,
        stops,
        stopsSet,
        reqNamesSet,
        defTypeDeps,
        optTouchedNames,
        ctors,
        bangs,
        bangsSet: new Set(listToArray(bangs)),
        sigs,
        workers,
        readyIdx,
        remNamesArr,
        remNamesSet: new Set(remNamesArr),
        retryOwnersSet,
        rawCandByName,
        fns1Names: fns1Arr.map(f => f.name),
        sel,
        zipOwners,
        p169oCache,
        adapters: lowered.adapters,
        original: origProg,
        verifyIds,
        prefixSigs,
        prevP169: p169,
        prevReady: ready,
        privContext,
        units,
      });
    }

    return {
      mode: misses.length === 0 ? 'all_obj_hits' : 'full_warm',
      available: ready.available,
      units,
      objPaths,
      hits,
      misses,
      planMs,
      pwMs,
      hashMs,
    };
  }

  async compile(opts) {
    const tStart = performance.now();
    const srcPath = path.resolve(opts.src);
    const outPath = path.resolve(opts.out);
    const rtPath = path.resolve(opts.rt ?? DEFAULT_RT);
    const cacheDir = path.resolve(opts.cacheDir ?? '/tmp/agy_w6_incr_fe/cache');
    const shards = Math.max(1, opts.shards ?? 4);
    const useGold = opts.useGold !== false && this.hasGold;

    const objCacheDir = path.join(cacheDir, 'objs');
    const progCacheDir = path.join(cacheDir, 'progs');
    fs.mkdirSync(objCacheDir, {recursive: true});
    fs.mkdirSync(progCacheDir, {recursive: true});

    const rtSha = this.getRtSha(rtPath);
    const srcText = opts.srcText ?? fs.readFileSync(srcPath, 'utf8');
    const srcSha = crypto.createHash('sha256').update(srcText).digest('hex').slice(0, 24);
    const progKey = `${this.apiSha}_${rtSha}_${srcSha}`;
    const cachedExe = path.join(progCacheDir, `${progKey}.bin`);

    // Path 0: Whole-program exact match
    if (fs.existsSync(cachedExe)) {
      fs.mkdirSync(path.dirname(outPath), {recursive: true});
      fs.copyFileSync(cachedExe, outPath);
      fs.chmodSync(outPath, 0o755);
      const totalMs = performance.now() - tStart;
      return {
        mode: 'whole_prog_hit',
        src: srcPath,
        out: outPath,
        totalUnits: 0,
        hits: 0,
        misses: 0,
        hitRatePct: 100,
        planMs: 0,
        pwMs: 0,
        hashMs: 0,
        emitMs: 0,
        linkMs: 0,
        totalMs: round1(totalMs),
      };
    }

    const newBlocks = splitTopLevelBlocks(srcText);
    const session = this.sessions.get(srcPath);
    let res = null;
    let fallbackReason = null;

    if (session) {
      const elig = this.checkIncrementalEligibility(session, newBlocks);
      if (elig.ok) {
        const inc = this.tryIncrementalFrontAndLower(session, srcPath, newBlocks, elig.changedBlocks, objCacheDir);
        if (inc.ok) res = inc;
        else fallbackReason = inc.reason;
      } else {
        fallbackReason = elig.reason;
      }
    }

    if (!res) {
      res = this.runFullCompile(srcPath, srcText, newBlocks, objCacheDir);
      if (fallbackReason) res.fallbackReason = fallbackReason;
    }

    // Emit ONLY cache misses (inline when <= 6 misses to avoid worker startup overhead;
    // on large cold builds, emit 1 unit on main thread in parallel with workers to warm V8 JIT!)
    const tEmit0 = performance.now();
    if (res.misses.length > 0) {
      if (shards <= 1 || res.misses.length <= 6) {
        for (const m of res.misses) {
          const buf = emitSingleUnit(this.api, m.cursor, res.available, m.isMain);
          writeAtomic(m.outPath, buf);
        }
      } else {
        const firstMiss = res.misses[0];
        const restMisses = res.misses.slice(1);
        const workersP = emitMissesParallel(this.apiPath, restMisses, res.available, shards);
        const buf0 = emitSingleUnit(this.api, firstMiss.cursor, res.available, firstMiss.isMain);
        writeAtomic(firstMiss.outPath, buf0);
        await workersP;
      }
    }
    const emitMs = performance.now() - tEmit0;

    // Link all .o files via response file (bundle unchanged P134Public .o files via `ld -r`!)
    const tLink0 = performance.now();
    fs.mkdirSync(path.dirname(outPath), {recursive: true});
    const publicObjs = [];
    const otherObjs = [];
    const seenObj = new Set();
    for (const u of res.units) {
      if (seenObj.has(u.objPath)) continue;
      seenObj.add(u.objPath);
      if (u.segTag === 'P134Public') publicObjs.push(u.objPath);
      else otherObjs.push(u.objPath);
    }
    let linkInputs;
    if (publicObjs.length >= 16) {
      const pubKey = crypto.createHash('sha256').update(publicObjs.join('\n')).digest('hex').slice(0, 24);
      const pubBundle = path.join(objCacheDir, `pub_bundle_${pubKey}.o`);
      if (!fs.existsSync(pubBundle)) {
        const pubRsp = path.join(cacheDir, `pub_${process.pid}_${Math.random().toString(16).slice(2)}.rsp`);
        const tmpBundle = `${pubBundle}.${process.pid}.tmp`;
        fs.writeFileSync(pubRsp, publicObjs.join('\n') + '\n');
        try {
          execFileSync('/usr/bin/ld', ['-r', `@${pubRsp}`, '-o', tmpBundle], {stdio: 'pipe'});
          fs.renameSync(tmpBundle, pubBundle);
        } finally {
          try { fs.unlinkSync(pubRsp); } catch {}
        }
      }
      linkInputs = [...otherObjs, pubBundle, rtPath];
    } else {
      linkInputs = [...otherObjs, ...publicObjs, rtPath];
    }
    const rspPath = path.join(cacheDir, `link_${process.pid}_${Math.random().toString(16).slice(2)}.rsp`);
    fs.writeFileSync(rspPath, linkInputs.join('\n') + '\n');
    const linkArgs = ['-no-pie'];
    if (useGold) linkArgs.push('-fuse-ld=gold');
    linkArgs.push(`@${rspPath}`, '-lm', '-lpthread', '-o', outPath);
    try {
      execFileSync('/usr/bin/x86_64-linux-gnu-gcc-10', linkArgs, {stdio: 'pipe'});
    } finally {
      try { fs.unlinkSync(rspPath); } catch {}
    }
    const linkMs = performance.now() - tLink0;

    // Save whole-program cache entry
    try {
      const tmpBin = `${cachedExe}.${process.pid}.tmp`;
      fs.copyFileSync(outPath, tmpBin);
      fs.renameSync(tmpBin, cachedExe);
    } catch {}

    const totalMs = performance.now() - tStart;
    return {
      mode: res.mode,
      fallbackReason: res.fallbackReason ?? null,
      src: srcPath,
      out: outPath,
      totalUnits: res.units.length,
      hits: res.hits,
      misses: res.misses.length,
      hitRatePct: res.units.length ? round1((res.hits / res.units.length) * 100) : 100,
      recomputedP169o: res.recomputedP169o ?? null,
      dirtyFnsCount: res.dirtyFnsCount ?? null,
      planMs: round1(res.planMs),
      pwMs: round1(res.pwMs),
      hashMs: round1(res.hashMs),
      emitMs: round1(emitMs),
      linkMs: round1(linkMs),
      totalMs: round1(totalMs),
    };
  }
}
