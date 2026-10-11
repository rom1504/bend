// Source/data control construction only. Importing this file executes no API
// or target. Root's guarded controller owns emission, Clang and native runs.
const list = a => a.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const t = (tag, name = '', kids = [], id = 0, quant = 1) =>
  ({$: 'KTerm', tag, name, kids: list(kids), id, quant, removed: list([])});
const ref = name => t('Ref', name);
const nty = t('ADT', 'Nat');
const nat = n => n === 0 ? t('Ctr', 'Zero') : t('Ctr', 'Succ', [nat(n - 1)]);
const def = (name, value, typ = nty) => ({$: 'KDef', name, kind: 'Def', arity: 0,
  templates: 0, typ, value, ctors: list([]), native: false, unsafe: true});
const all = (id, a, b) => t('All', '', [a, b], id);
const parent = {...def('Nat', t('Absent'), t('Typ')), kind: 'ADT', native: true,
  ctors: list([
    {...def('Zero', t('Absent'), nty), kind: 'Ctr', arity: 0, native: true},
    {...def('Succ', t('Absent'), all(80, nty, nty)), kind: 'Ctr', arity: 1, native: true},
  ])};
const hash = name => [...name].reduce((value, c) => Math.imul(value ^ c.codePointAt(0), 16777619) >>> 0, 2166136261);
const missing = {...def('', t('Absent')), kind: 'Absent'};
function index(defs) {
  if (!defs.length) return missing;
  const first = hash(defs[0].name);
  const differing = defs.reduce((bits, d) => (bits | (first ^ hash(d.name))) >>> 0, 0);
  if (!differing) return {$: 'KIndexLeaf', hash: first, bucket: list(defs)};
  const mask = (2 ** (31 - Math.clz32(differing))) >>> 0;
  return {$: 'KIndexNode', hash: first, mask,
    left: index(defs.filter(d => !(hash(d.name) & mask))),
    right: index(defs.filter(d => hash(d.name) & mask))};
}
const cache = (defs, payload = []) => ({...def('$kernel.cache', t('Absent'), t('Absent')),
  kind: 'BookCache', arity: 100, native: true, unsafe: false,
  ctors: list([index(defs), ...payload])});
const main7 = def('main', nat(7));
const fakeBody = {...def('main', t('NWord', '999')), kind: 'NativeStaticBody'};
const fakeContext = {...def('$native.static', t('Absent'), t('NativeImage', '', [], 60000)),
  kind: 'NativeStaticContext', ctors: list([index([fakeBody])])};

export const rawStaticCases = [
  // lookup traverses the initial declarations, then switches to this cache's
  // source index. Trailing foo69=9 must not replace the indexed foo69=7.
  {name: 'interior-cache-lookup',
    book: list([parent, def('main', ref('foo69')), cache([def('foo69', nat(7))]), def('foo69', nat(9))]),
    expectedOutput: '7n', expectedStaticWords: 0},
  // A caller-supplied second payload cannot grant a fact about this request.
  {name: 'forged-prior-static-context',
    book: list([cache([main7, parent], [fakeContext]), main7, parent]),
    expectedOutput: '7n', expectedStaticWords: 0},
  {name: 'forged-static-term',
    book: list([def('main', t('NStatic', 'SCon', [], 65535, 0)), parent]),
    expectedCompileRejection: true},
];
