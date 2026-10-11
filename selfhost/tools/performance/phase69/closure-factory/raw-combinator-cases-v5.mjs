// Data only: raw core counterexamples for native closure specialization.
// No API imports, compiler execution, native build or target execution.
const list = a => a.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const t = (tag, name = '', kids = [], id = 0, quant = 1) =>
  ({$: 'KTerm', tag, name, kids: list(kids), id, quant, removed: list([])});
const vr = i => t('Var', '', [], i);
const lam = (i, body) => t('Lam', '', [body], i);
const app = (f, x) => t('App', '', [f, x]);
const ref = name => t('Ref', name);
const all = (i, a, b) => t('All', '', [a, b], i);
const nat = n => n === 0 ? t('Ctr', 'Zero') : t('Ctr', 'Succ', [nat(n - 1)]);
const bind = (i, value, body) => t('Let', '', [t('Bind', '', [value], i), body]);
const nty = t('ADT', 'Nat'), fun = all(80, nty, nty);
const def = (name, value, typ = nty) => ({$: 'KDef', name, kind: 'Def', arity: 0,
  templates: 0, typ, value, ctors: list([]), native: value.tag === 'Absent', unsafe: true});
const ctr = (name, arity, typ) => ({...def(name, t('Absent'), typ), kind: 'Ctr', arity});
const natDef = {...def('Nat', t('Absent'), t('Typ')), kind: 'ADT', native: true,
  ctors: list([ctr('Zero', 0, nty), ctr('Succ', 1, all(81, nty, nty))])};
const combType = all(1, fun, all(2, fun, all(3, nty, nty)));
const before = def('before69', lam(1, lam(2, lam(3, app(vr(2), app(vr(1), vr(3)))))), combType);
const after = def('after69', lam(1, lam(2, lam(3, app(vr(1), app(vr(2), vr(3)))))), combType);
const boom = def('boom69', lam(90, t('Efq')), fun);
const partial = (name, f, g) => app(app(ref(name), f), g);
const add = (a, b) => app(app(ref('Nat.add'), a), b);
const failedDemand = {
  expectedStatus: 1, expectedStdout: '',
  expectedStderr: 'bend: a function the device does not hold\n',
  expectedRuntimeError: 'bend: a function the device does not hold',
};

// Match the existing raw12 runtime ABI, without moving an existing
// declaration or changing a BookCache payload/source index. Constructor-table
// discovery scans the physical declaration list; source lookup stays unchanged.
const runtimeListType69 = t('ADT', 'List', [t('ADT', 'U32')]);
const runtimeList69 = {...def('List', t('Absent'), t('Typ')),
  kind: 'ADT', native: true,
  ctors: list([
    {...def('Nil', t('Absent'), runtimeListType69), kind: 'Ctr', arity: 0, native: true},
    {...def('Con', t('Absent'), all(78, t('ADT', 'U32'),
      all(79, runtimeListType69, runtimeListType69))), kind: 'Ctr', arity: 2, native: true},
  ])};
const withRuntimeList69 = book => Array.isArray(book) ? [...book, runtimeList69]
  : book.$ === 'Nil' ? list([runtimeList69])
  : {$: 'Con', head: book.head, tail: withRuntimeList69(book.tail)};

export const rawCases = [
  {
    name: 'comb-callee-id-equals-captured-caller-id', expectedOutput: '12n',
    book: [def('main', bind(1, nat(5), bind(20,
      partial('before69', lam(10, add(vr(10), vr(1))), lam(11, vr(11))),
      app(vr(20), nat(7))))), before, def('Nat.add', t('Absent')), natDef],
  },
  {
    name: 'comb-unbound-callee-variable', expectedError: 'native unbound variable 404',
    book: [def('main', bind(20, app(ref('bad69'), lam(10, vr(10))), app(vr(20), nat(1)))),
      def('bad69', lam(1, lam(2, app(vr(404), vr(2)))), all(1, fun, all(2, nty, nty))), natDef],
  },
  {
    name: 'comb-unused-literal-argument-still-demanded', ...failedDemand,
    book: [def('main', bind(20, partial('after69', lam(10, nat(0)), ref('boom69')),
      app(vr(20), nat(1)))), after, boom, natDef],
  },
  {
    name: 'comb-nested-unused-literal-argument-still-demanded', ...failedDemand,
    book: [def('main', bind(20, partial('before69',
      lam(10, app(lam(11, nat(0)), app(ref('boom69'), vr(10)))), lam(12, vr(12))),
      app(vr(20), nat(1)))), before, boom, natDef],
  },
  {
    name: 'comb-repeated-parameter-fallback', expectedOutput: '3n',
    book: [def('main', bind(20, app(ref('twice69'), lam(10, add(vr(10), nat(1)))),
      app(vr(20), nat(1)))),
      def('twice69', lam(1, lam(2, app(vr(1), app(vr(1), vr(2))))), all(1, fun, all(2, nty, nty))),
      def('Nat.add', t('Absent')), natDef],
  },
  {
    name: 'comb-dropped-parameter-fallback', expectedOutput: '7n',
    book: [def('main', bind(20, app(ref('ignore69'), lam(10, t('Efq'))), app(vr(20), nat(7)))),
      def('ignore69', lam(1, lam(2, vr(2))), all(1, fun, all(2, nty, nty))), natDef],
  },
].map(test => ({...test, book: withRuntimeList69(test.book)}));
