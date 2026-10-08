// Diagnostic semantics only: never used by the production compiler.
// Predicate true is sufficient, not necessary, for exact unchanged output.
export const symbol = 'bend.phase65.term-reuse';
export function makeObserver() {
  const limit = 5_000_000, cacheLimit = 250_000;
  let cache, betaCache, buckets, current, work, entries, enabled = false;
  const tag = t => t.$ === 'KLambda' ? 'Lam' : t.$ === 'KLiteral' ? 'Lit' : t.tag;
  const kids = t => t.$ === 'KLiteral' ? null : t.kids;
  function canonical(t) {
    const k = t.kids;
    return t.$ === 'KTerm' && t.tag === 'App' && t.name === '' && t.id === 0 && t.quant === 0 &&
      t.removed?.$ === 'Nil' && k?.$ === 'Con' && k.tail?.$ === 'Con' && k.tail.tail?.$ === 'Nil';
  }
  // -1 means unknown: capped or unsupported data. No unknown grants reuse.
  function stable(t, id, depth = 0) {
    if (!t || typeof t !== 'object' || depth > 256 || work >= limit) return -1;
    if (!['KTerm','KLambda','KLiteral'].includes(t.$)) return -1;
    const prior = cache.get(t)?.get(id); if (prior !== undefined) return prior;
    work++;
    let result = 1;
    if (tag(t) === 'Var') result = t.id === id ? 0 : 1; // Do not visit Var payloads.
    else if (t.$ !== 'KLiteral') {
      let k = kids(t), length = 0;
      while (k?.$ === 'Con') {
        if (++length > 65536 || work >= limit) { result = -1; break; }
        const child = stable(k.head, id, depth + 1);
        if (child !== 1) { result = child; break; }
        k = k.tail;
      }
      if (result === 1 && k?.$ !== 'Nil') result = -1;
      if (result === 1 && tag(t) === 'App')
        result = canonical(t) && tag(t.kids.head) !== 'Lam' ? 1 : 0;
    }
    if (entries < cacheLimit && result !== -1) {
      let ids = cache.get(t); if (!ids) { ids = new Map(); cache.set(t, ids); }
      ids.set(id, result); entries++;
    }
    return result;
  }
  function betaStable(t, depth = 0) {
    if (!t || typeof t !== 'object' || depth > 256 || work >= limit) return -1;
    if (!['KTerm','KLambda','KLiteral'].includes(t.$)) return -1;
    const prior = betaCache.get(t); if (prior !== undefined) return prior;
    work++;
    let result = 1;
    if (tag(t) === 'App') {
      if (!canonical(t) || tag(t.kids.head) === 'Lam') result = 0;
      else result = betaStable(t.kids.head, depth + 1); // Argument is not demanded.
    }
    if (entries < cacheLimit && result !== -1) { betaCache.set(t, result); entries++; }
    return result;
  }
  function count(name, n = 1) { const b = buckets.get(current); b[name] = (b[name] ?? 0) + n; }
  function note(op, t, id) {
    if (!enabled) return;
    count(op + '.entries');
    if (op === 'subst_terms') { if (t.$ === 'Con') count('subst_terms.cons'); return; }
    if (op === 'core_apply_span') { count('core_apply_span.' + (tag(t) === 'Lam' ? 'beta' : 'appBuild')); return; }
    if (op === 'subst') {
      count('subst.tag.' + tag(t));
      if (tag(t) === 'Var' || t.$ === 'KLiteral' || kids(t)?.$ !== 'Con') return;
      count('subst.composites');
      const result = stable(t, id); count('subst.composites.' + ({1:'stable',0:'changed',[-1]:'unknown'}[result]));
      if (result === 1) {
        let k = kids(t), length = 0;
        while (k?.$ === 'Con' && length <= 65536) { length++; k = k.tail; }
        count('subst.stableImmediateParents'); count('subst.stableImmediateChildCons', length);
        count('subst.stableTag.' + tag(t));
        if (tag(t) === 'App') { count('subst.stableAppExtraParents'); count('subst.stableAppExtraChildCons', 2); }
      }
    } else if (op === 'core_beta' && tag(t) === 'App') {
      const result = betaStable(t); count('core_beta.apps');
      count('core_beta.apps.' + ({1:'stable',0:'changed',[-1]:'unknown'}[result]));
    }
  }
  function phase(name) { const old = current; current = name; if (!buckets.has(name)) buckets.set(name, {}); return old; }
  function reset() { cache = new WeakMap(); betaCache = new WeakMap(); buckets = new Map(); current = 'outside-api'; buckets.set(current, {}); work = 0; entries = 0; }
  function snapshot() { return {phases:Object.fromEntries(buckets),predicateWork:work,cachedFacts:entries,limit,cacheLimit,capped:work>=limit}; }
  reset(); return {note, phase, reset, snapshot, stable, betaStable, active(value){enabled=value}};
}
