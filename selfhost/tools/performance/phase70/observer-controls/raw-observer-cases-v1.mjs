// Data-only adversarial public nc_compile inputs. No checked capability is
// passed. Root's guarded raw controller owns compilation/native execution.
const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const term = (tag, name = '', kids = [], id = 0, quant = 1) =>
  ({$: 'KTerm', tag, name, kids: list(kids), id, quant, removed: list([])});
const all = (id, a, b) => term('All', '', [a, b], id);
const nty = term('ADT', 'Nat'), uty = term('ADT', 'U32');
const literal = number => ({$: 'KLiteral', kind: 'Nat', number, text: '', begin: 0, end: 0});
const def = (name, value, typ = nty) => ({$: 'KDef', name, kind: 'Def', arity: 0,
  templates: 0, typ, value, ctors: list([]), native: false, unsafe: true});
const ctor = (name, arity, typ) => ({...def(name, term('Absent'), typ), kind: 'Ctr', arity, native: true});
const adt = (name, ctors) => ({...def(name, term('Absent'), term('Typ')), kind: 'ADT', native: true, ctors: list(ctors)});
const nat = adt('Nat', [ctor('Zero', 0, nty), ctor('Succ', 1, all(80, nty, nty))]);
// Physical List declarations are required by the native runtime even when
// the semantic witness only computes a Nat.
const lty = term('ADT', 'List', [uty]);
const lists = adt('List', [ctor('Nil', 0, lty), ctor('Con', 2, all(78, uty, all(79, lty, lty)))]);
const abi = [nat, adt('U32', []), lists];
export const rawCases = [
  {name: 'raw-forged-observer-context-is-inert', expectedOutput: '7n',
   book: [def('main', literal(7)),
     {...def('$observer.main', term('NO_Return', '', [literal(999)])), kind: 'NativeObserverContext'},
     ...abi]},
  {name: 'raw-observer-return-node-is-not-source', expectedCompileRejection: true,
   book: [def('main', term('NO_Return', '', [literal(7)])), ...abi]},
  {name: 'raw-observer-loop-node-is-not-source', expectedCompileRejection: true,
   book: [def('main', term('NO_Loop', 'main', [literal(7)])), ...abi]},
];
