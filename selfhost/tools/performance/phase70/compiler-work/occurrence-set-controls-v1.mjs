// Source-only until root calls this with append-only checked-B1 query exports.
import assert from 'node:assert/strict';
const nil = () => ({$: 'Nil'});
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), nil());
const array = xs => {
  const out = [];
  while (xs.$ === 'Con') { out.push(xs.head); xs = xs.tail; }
  assert.equal(xs.$, 'Nil');
  return out;
};
const term = (tag, id = 0, kids = []) => ({$: 'KTerm', tag, name: 'metadata',
  id, quant: 2, kids: list(kids), removed: list(['metadata']), originBegin: 4, originEnd: 9});
const variable = (id, kids = []) => term('Var', id, kids);
const binding = (id, word) => ({$: 'NC_Binding', id, word});
const occurrences = t => {
  const ids = new Set(), todo = [t];
  while (todo.length) {
    const node = todo.pop();
    if (node.$ === 'KTerm' && node.tag === 'Var') { ids.add(node.id); continue; }
    if (node.$ === 'KLiteral') continue;
    assert(['KTerm', 'KLambda'].includes(node.$));
    todo.push(...array(node.kids));
  }
  return ids;
};

export const requiredOccurrenceSetHelpers = {
  uses: ['nc_uses', 1], has: ['nc_uses_has', 2], live: ['nc_live_env', 2],
  partition: ['nc_prepare_env', 2], share: ['nc_share_env', 3],
};

export function runOccurrenceSetControls(api) {
  for (const name of Object.keys(requiredOccurrenceSetHelpers)) assert.equal(typeof api[name], 'function');
  const ids = [...new Set([0, 1, 2, 3, 2147483647, 2147483648, 4294967294, 4294967295,
    ...Array.from({length: 32}, (_, i) => 2 ** i),
    ...Array.from({length: 32}, (_, i) => (4294967295 ^ (2 ** i)) >>> 0)])];
  const terms = [
    ['absent', term('Absent')], ['zero', variable(0)], ['last', variable(4294967295)],
    ['var-is-leaf', variable(1, [variable(2)])],
    ['lambda', term('Lam', 3, [variable(4), variable(3)])],
    ['annotation', term('Ann', 0, [variable(1), variable(2147483648)])],
    ['unknown', term('Unknown', 99, [term('Qnt', 99, [variable(2)]), variable(4294967295)])],
    ['literal', {$: 'KLiteral', kind: 'U32', number: 4294967295, text: 'ignored', originBegin: 0, originEnd: 0}],
    ['lambda-variant', {$: 'KLambda', name: 'x', id: 9, quant: 2,
      kids: list([variable(9), variable(1)]), removed: nil(), originBegin: 0,
      originEnd: 0, quantityPresent: true}],
    ['unique-ids', term('Many', 0, ids.map(id => variable(id)))],
    ['repeated-ids', term('Many', 0, ids.flatMap(id => Array.from({length: 4}, () => variable(id))))],
    ['repeated-single', term('Many', 0, Array.from({length: 64}, () => variable(4294967295)))],
    ['mat-branches', term('Mat', 0, [term('Many', 0, ids.map(id => variable(id))),
      term('Many', 0, [...ids].reverse().map(id => variable(id)))])],
  ];
  let deep = variable(17);
  for (let i = 0; i < 128; ++i) deep = term('Wrap', i, [deep]);
  terms.push(['deep', deep]);
  let seed = 0x700006;
  const random = () => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed; };
  const generate = depth => {
    const id = ids[random() % ids.length];
    if (!depth || random() % 4 === 0) return variable(id);
    return term(['App', 'Ann', 'Lam', 'Qnt', 'Unknown'][random() % 5], id,
      Array.from({length: random() % 4}, () => generate(depth - 1)));
  };
  for (let i = 0; i < 24; ++i) terms.push(['generated-' + i, generate(5)]);
  const envs = [[], [binding(0, 'zero')], [binding(4294967295, 'last')],
    [binding(1, 'same'), binding(2, 'same'), binding(1, 'other'), binding(1, 'same')],
    [binding(9, 'a\nb'), binding(2147483648, 'high'), binding(0, 'zero'), binding(4294967295, 'last')],
    ids.map((id, i) => binding(id, 'word_' + i))];
  const rows = [];
  for (let i = 0; i < terms.length; ++i) {
    const [name, t] = terms[i], other = terms[(i + 7) % terms.length][1];
    const before = JSON.stringify(t), want = occurrences(t), otherIds = occurrences(other);
    api.resetCounters();
    const uses = api.uses(t), counters = api.readCounters();
    const unchangedUses = JSON.stringify(uses);
    for (const id of ids) assert.equal(api.has(uses, id), want.has(id), name + ' membership ' + id);
    const partitions = [];
    for (const rows of envs) {
      const env = list(rows), live = list(rows.filter(x => want.has(x.id)));
      const drop = rows.filter(x => !want.has(x.id)).map(x => 'term_sink(e, ' + x.word + ');\n').join('');
      const sharing = rows.filter(x => want.has(x.id) && otherIds.has(x.id))
        .map(x => x.word + ' = term_keep(e, ' + x.word + ');\n').join('');
      assert.deepEqual(api.live(env, t), live);
      const partition = api.partition(env, t), share = api.share(env, t, other);
      assert.deepEqual(partition, {$: 'NC_EnvPartition', live, drop});
      assert.equal(share, sharing);
      partitions.push({partition, share});
    }
    assert.equal(JSON.stringify(t), before);
    assert.equal(JSON.stringify(uses), unchangedUses);
    rows.push({name, uses, partitions, counters, pass: true});
  }
  const poison = {$: 'KTerm', get tag() { throw Error('Empty environment touched term'); },
    get kids() { throw Error('Empty environment touched children'); }};
  assert.deepEqual(api.live(nil(), poison), nil());
  assert.deepEqual(api.partition(nil(), poison), {$: 'NC_EnvPartition', live: nil(), drop: ''});
  assert.equal(api.share(nil(), poison, poison), '');
  assert.equal(api.share(list([binding(123456789, 'unused')]), variable(1), poison), '');
  return {kind: 'phase70-occurrence-set-controls', pass: true, rows,
    counts: {terms: terms.length, ids: ids.length, queries: terms.length * ids.length,
      partitions: terms.length * envs.length, shares: terms.length * envs.length},
    emptyEnvNonDemand: true, unusedSecondShareNonDemand: true};
}
