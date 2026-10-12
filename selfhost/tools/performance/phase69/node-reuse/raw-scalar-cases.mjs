// Data only. Raw declared scalar types do not authorize truncating actual words.
// Root's guarded custom-raw controller owns API, Clang and native execution.
const list = a => a.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const t = (tag, name = '', kids = [], id = 0, quant = 1) =>
  ({$: 'KTerm', tag, name, kids: list(kids), id, quant, removed: list([])});
const ref = name => t('Ref', name), vr = id => t('Var', '', [], id);
const app = (f, x) => t('App', '', [f, x]);
const lam = (id, body) => t('Lam', '', [body], id);
const all = (id, a, b) => t('All', '', [a, b], id);
const nty = t('ADT', 'Nat'), uty = t('ADT', 'U32'), bty = t('ADT', 'Bool');
const literal = number => ({$: 'KLiteral', kind: 'Nat', number, text: '', begin: 0, end: 0});
const def = (name, value, typ = nty) => ({$: 'KDef', name, kind: 'Def', arity: 0,
  templates: 0, typ, value, ctors: list([]), native: value.tag === 'Absent', unsafe: true});
const ctor = (name, arity, typ) => ({...def(name, t('Absent'), typ), kind: 'Ctr', arity});
const adt = (name, ctors) => ({...def(name, t('Absent'), t('Typ')), kind: 'ADT', native: true, ctors: list(ctors)});
const ndef = adt('Nat', [ctor('Zero', 0, nty), ctor('Succ', 1, all(80, nty, nty))]);
const udef = adt('U32', []);
const bdef = adt('Bool', [ctor('False', 0, bty), ctor('True', 0, bty)]);
// Required physical runtime List ABI, matching existing raw12 controls.
const lty = t('ADT', 'List', [uty]);
const ldef = adt('List', [ctor('Nil', 0, lty), ctor('Con', 2, all(78, uty, all(79, lty, lty)))]);
const binary = name => def(name, t('Absent'), all(100, nty, all(101, nty, nty)));
const add = (a, b) => app(app(ref('Nat.add'), a), b);
const mul = (a, b) => app(app(ref('Nat.mul'), a), b);
const high = add(mul(literal(65536), literal(65536)), literal(7));
const make = (name, declared) => ({
  name, expectedOutput: '4294967303n',
  book: [def('main', app(ref(name), high)),
    def(name, lam(200, vr(200)), all(200, declared, nty)),
    binary('Nat.add'), binary('Nat.mul'), ndef, udef, bdef, ldef],
});
export const rawCases = [
  make('raw-declared-u32-retains-high-nat', uty),
  make('raw-declared-bool-retains-high-nat', bty),
];
