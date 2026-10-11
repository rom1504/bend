// Source/data only: export raw-core cases; no imports, compiler or target run.
const list = a => a.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const t = (tag, name = '', kids = [], id = 0, quant = 1) =>
  ({$: 'KTerm', tag, name, kids: list(kids), id, quant, removed: list([])});
const vr = id => t('Var', '', [], id);
const ref = (name, bang = false) => t('Ref', name, [], 0, bang ? 3 : 1);
const nat = n => n === 0 ? t('Ctr', 'Zero') : t('Ctr', 'Succ', [nat(n - 1)]);
const nty = t('ADT', 'Nat');
const all = (id, a, b) => t('All', '', [a, b], id);
const lam = (id, body) => t('Lam', '', [body], id);
const app = (f, x) => t('App', '', [f, x]);
const def = (name, value, typ = nty) => ({$: 'KDef', name, kind: 'Def', arity: 0,
  templates: 0, typ, value, ctors: list([]), native: false, unsafe: true});
const ctr = (name, arity, typ) => ({...def(name, t('Absent'), typ), kind: 'Ctr', arity, native: true});
const parent = {...def('Nat', t('Absent'), t('Typ')), kind: 'ADT', native: true,
  ctors: list([ctr('Zero', 0, nty), ctr('Succ', 1, all(80, nty, nty))])};
const worker = def('worker69', lam(3, vr(3)), all(3, nty, nty));
const main = def('main', app(ref('worker69'), nat(7)));
export const rawCases = [
  {name: 'dead-bang', book: list([main, worker, def('unused', app(ref('worker69', true), nat(1))), parent]),
    expectedOutput: '7n', expectedCandidateBangs: 0},
  {name: 'masked-duplicate-bang', book: list([main, worker,
    def('worker69', app(ref('worker69', true), nat(1))), parent]),
    expectedOutput: '7n', expectedCandidateBangs: 0},
  {name: 'dead-unbound-value', book: list([main, worker, def('unused', vr(99)), parent]),
    expectedOutput: '7n', expectedCandidateBangs: 0},
  {name: 'live-bang', book: list([def('main', app(ref('worker69', true), nat(7))), worker, parent]),
    expectedOutput: '7n', expectedCandidateBangs: 'positive'},
  {name: 'live-missing-reference', book: list([def('main', ref('missing69')), parent]),
    expectedError: 'native definition not found: missing69'},
];
