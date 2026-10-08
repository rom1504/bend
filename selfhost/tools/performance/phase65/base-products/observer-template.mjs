// Appended to a copied compiler image by census.mjs. Diagnostic only.
import {createHash as phase65CreateHash} from 'node:crypto';
import {performance as phase65Clock} from 'node:perf_hooks';
export const phase65BaseProducts = (() => {
  const force = value => __FORCE__;
  const call = (fn, ...args) => force(fn(...args));
  const digestCache = new WeakMap();
  let hashed = 0;
  function digest(value) {
    if (value === null || typeof value !== 'object') return typeof value + ':' + String(value);
    if (digestCache.has(value)) return digestCache.get(value);
    const pending = [[value, false]], active = new WeakSet();
    while (pending.length) {
      const [node, finish] = pending.pop();
      if (digestCache.has(node)) continue;
      const keys = Object.keys(node).sort();
      if (!finish) {
        if (active.has(node)) throw Error('Cyclic product graph');
        if (++hashed > 2000000) throw Error('Product graph budget');
        active.add(node); pending.push([node, true]);
        for (let i = keys.length - 1; i >= 0; --i) {
          const child = node[keys[i]];
          if (child && typeof child === 'object' && !digestCache.has(child)) pending.push([child, false]);
        }
      } else {
        const h = phase65CreateHash('sha256');
        for (const key of keys) {
          const child = node[key];
          const text = child && typeof child === 'object' ? digestCache.get(child) : digest(child);
          if (text === undefined) throw Error('Incomplete product digest');
          h.update(JSON.stringify([key, text]));
        }
        digestCache.set(node, h.digest('hex')); active.delete(node);
      }
    }
    return digestCache.get(value);
  }
  const array = list => {
    const out = [];
    while (list?.$ === 'Con') { if (out.length >= 65536) throw Error('List budget'); out.push(list.head); list = list.tail; }
    if (list?.$ !== 'Nil') throw Error('Expected named list'); return out;
  };
  const list = values => values.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
  let enabled = false, prepared = null, base = new Map(), annotated = new Map(), events = [], selected = [];
  let worldCalls = 0, baseOracle = [], rowOwners = [], layoutDefinitions = new WeakMap(), callDepth = 0, layoutDepth = 0;
  const original = {
    world: __RESUME_WORLD__, annotation: __KA_DEF__, row: __CALL_ROW__, calls: __CALL_BODY__,
    layout: __LAYOUT_TERM__, lowering: __LOWERING__, context: __BOOK_CONTEXT__,
  };
  function ownership(d) {
    const saved = base.get(d?.name);
    if (!saved) return d?.name?.includes('~') ? 'specialized-source' : 'source';
    const actual = digest(d);
    return actual === digest(saved) || actual === annotated.get(d.name) ? 'base-exact' : 'base-name-modified';
  }
  function record(stage, d, book, output, elapsedMs, extra = {}) {
    if (events.length >= 8192) throw Error('Definition event budget');
    const row = {stage, name: d?.name ?? '(unknown)', ownership: ownership(d), input: digest(d),
      bound: book?.head?.kind === 'BookCache' ? book.head.arity : null,
      product: digest(output), elapsedMs, ...extra};
    events.push(row); return row;
  }
  __RESUME_WORLD__ = function (world, ...args) {
    if (enabled) {
      if (++worldCalls !== 1 || world?.$ !== 'KBasePreparedWorld' || !world.state.ready) throw Error('Expected one ready world');
      prepared = world; base = new Map(array(world.checked).map(d => [d.name, d]));
    }
    return original.world(world, ...args);
  };
  __KA_DEF__ = function (book, d) {
    if (!enabled) return original.annotation(book, d);
    const start = phase65Clock.now(), output = call(original.annotation, book, d), elapsed = phase65Clock.now() - start;
    const row = record('annotation', d, book, output, elapsed);
    if (row.ownership === 'base-exact') {
      annotated.set(d.name, row.product); baseOracle.push({d, actual: row.product, requestBound: row.bound});
    }
    return output;
  };
  __CALL_ROW__ = function (book, d, ...args) {
    if (!enabled) return original.row(book, d, ...args);
    rowOwners.push(d); try { return call(original.row, book, d, ...args); } finally { rowOwners.pop(); }
  };
  __CALL_BODY__ = function (...args) {
    if (!enabled || callDepth || !rowOwners.length) return original.calls(...args);
    callDepth++;
    try {
      const start = phase65Clock.now(), output = call(original.calls, ...args), elapsed = phase65Clock.now() - start;
      record('call-body', rowOwners.at(-1), args[0], output, elapsed,
        {liveArguments: args[4], initialFuel: args[5].fuel, remainingFuel: output.fuel});
      return output;
    } finally { callDepth--; }
  };
  __LAYOUT_TERM__ = function (...args) {
    if (!enabled || layoutDepth || args[1]?.$ !== 'Nil') return original.layout(...args);
    const owners = layoutDefinitions.get(args[2])?.filter(d => d.typ === args[3]);
    if (!owners?.length) return original.layout(...args);
    if (owners.length !== 1) throw Error('Ambiguous layout root ownership');
    layoutDepth++;
    try {
      const start = phase65Clock.now(), output = call(original.layout, ...args), elapsed = phase65Clock.now() - start;
      const local = []; let tail = output;
      while (tail !== args[4] && tail?.$ === 'Con') {
        if (local.length >= 65536) throw Error('Layout edge budget'); local.push(tail.head); tail = tail.tail;
      }
      if (tail !== args[4]) throw Error('Layout did not retain its input todo tail');
      record('layout-body', owners[0], args[0], local, elapsed, {edges: local.length});
      return output;
    } finally { layoutDepth--; }
  };
  __LOWERING__ = function (book, d) {
    if (!enabled) return original.lowering(book, d);
    const start = phase65Clock.now(), output = call(original.lowering, book, d), elapsed = phase65Clock.now() - start;
    record('lowering', d, book, output, elapsed); return output;
  };
  return {
    start() {
      prepared = null; base = new Map(); annotated = new Map(); events = []; selected = [];
      worldCalls = 0; baseOracle = []; rowOwners = []; layoutDefinitions = new WeakMap(); callDepth = 0; layoutDepth = 0; enabled = true;
    },
    stop() { enabled = false; },
    select(defs, stops) {
      if (!enabled) return;
      const skipped = new Set(array(stops));
      selected = array(defs).map(d => ({name: d.name, ownership: ownership(d), stopped: skipped.has(d.name)}));
    },
    layouts(defs) {
      if (!enabled) return;
      layoutDefinitions = new WeakMap();
      for (const d of array(defs)) if (d.kind === 'Def' && d.templates === 0) {
        const owners = layoutDefinitions.get(d.value) ?? []; owners.push(d); layoutDefinitions.set(d.value, owners);
      }
    },
    finish() {
      enabled = false;
      if (worldCalls !== 1 || !prepared) throw Error('Private ready world did not execute');
      // This is a falsifier, not a claim that the raw closed-prefix proof is sufficient.
      const context = call(original.context, list(array(prepared.checked).reverse()));
      const comparisons = baseOracle.map(({d, actual, requestBound}) => {
        const expected = digest(call(original.annotation, context, d));
        return {name: d.name, equal: actual === expected, actual, expected, requestBound,
          baseBound: context.head.arity};
      });
      const summaries = {};
      for (const row of events) {
        const key = row.stage + '/' + row.ownership;
        const s = summaries[key] ??= {calls: 0, diagnosticMs: 0}; s.calls++; s.diagnosticMs += row.elapsedMs;
      }
      for (const stage of ['annotation', 'call-body', 'layout-body', 'lowering'])
        if (!events.some(row => row.stage === stage)) throw Error('No observed ' + stage + ' roots');
      return {worldCalls, baseDefinitions: base.size, selected, events, summaries, comparisons,
        allBaseAnnotationsEqual: comparisons.every(x => x.equal),
        scope: 'Instrumented per-definition operation times only. Forcing trampolines and hashing products affects execution; these are not clean speed estimates. Layout products exclude the original todo tail. Cross-request digest agreement is not a universal reuse proof.'};
    },
  };
})();
