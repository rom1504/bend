// Source-only controls. Importing invokes no compiler API or native target.
// The root's guarded helper runner supplies checked compiler closures.
import assert from 'node:assert/strict';

const list = xs => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const t = (tag, name = '', children = [], id = 0, quant = 0) => ({
  $: 'KTerm', tag, name, id, quant, kids: list(children), removed: list([]),
  originBegin: 0, originEnd: 0,
});
const literal = (kind, number = 0, text = '') => ({
  $: 'KLiteral', kind, number, text, originBegin: 43, originEnd: 51,
});
const ctor = (name, kids = []) => t('Ctr', name, kids);
const vr = id => t('Var', '', [], id);
const word = n => t('NWord', String(n));
const def = (name, value, typ = t('Typ'), native = false) => ({
  $: 'KDef', name, kind: 'Def', arity: 0, templates: 0,
  typ, value, ctors: list([]), native, unsafe: true,
});
const all = (id, type, body, quant = 1) => t('All', '', [type, body], id, quant);
const nilImage = api => ({$: 'NS_Image', size: 0, words: list([]), index: api.missing()});

export const requiredCompactBodyHelpers = {
  missing: 0, ns_ctor_index: 2, ns_static_term: 3, nc_compact: 1,
  ns_source: 1, ns_prepare: 2, ns_body: 2, lookup: 2,
  nc_definition: 3, nc_compact_definition: 3,
};

export function runCompactBodyControls(api) {
  for (const name of Object.keys(requiredCompactBodyHelpers)) {
    assert.equal(typeof api[name], 'function', 'missing checked helper: ' + name);
  }
  const rows = [];
  const cs = api.ns_ctor_index(list([
    {$: 'N_Constructor', name: 'Tuple', arity: 2, hot: true},
    {$: 'N_Constructor', name: 'SNil', arity: 0, hot: true},
  ]), api.missing());
  const terms = [
    ['literal-nat-max', literal('Nat', 4294967295)],
    ['literal-u32', literal('U32', 4294967295)],
    ['literal-string', literal('String', 0, 'a\u{1f642}')],
    ['static-pair', ctor('Tuple', [word(1), word(2)])],
    ['static-nullary', ctor('SNil')],
    ['static-dynamic-parent', ctor('Tuple', [vr(7), ctor('SNil')])],
    ['foreign-source-marker', t('NStatic', 'Tuple', [word(1)], 17)],
    ['legacy-lambda', t('Lam', 'legacy', [vr(7)], 7, 1)],
    ['explicit-lambda', {$: 'KLambda', name: 'explicit', id: 7, quant: 1,
      kids: list([vr(7)]), removed: list(['old']), originBegin: 12, originEnd: 24,
      quantityPresent: false}],
    ['error-in-child', ctor('Tuple', [t('Efq'), ctor('SNil')])],
    ['malformed-var-children', t('Var', 'odd', [literal('Nat', 9)], 41)],
    ['metadata', {...ctor('Unknown', [vr(9)]), removed: list(['x']), originBegin: 2, originEnd: 8}],
  ];
  const atoms = [ctor('Zero'), ctor('True'), ctor('False'), ctor('WNil'),
    vr(9), word(1), literal('Nat', 4294967295), t('Efq')];
  for (const name of ['Succ', 'U32', 'F32', 'Chr', 'True', 'Zero', 'WCon']) {
    for (let i = 0; i < atoms.length; ++i) {
      terms.push([`malformed-${name}-${i}`, ctor(name, [atoms[i], ctor('Zero')])]);
      terms.push([`nested-${name}-${i}`, ctor(name, [ctor('Succ', [atoms[i]])])]);
    }
  }
  for (const [name, input] of terms) {
    const result = api.ns_static_term(cs, api.nc_compact(input), nilImage(api));
    assert.deepEqual(api.nc_compact(result.term), result.term, name + ' fixed point');
    rows.push({name, category: 'fresh-producer-fixed-point', pass: true});
  }

  const compare = (name, book, entry, fresh, expectFact) => {
    const d = api.lookup(book, entry);
    const fact = api.ns_body(book, entry);
    assert.equal(fact.kind === 'NativeStaticBody', expectFact, name + ' admission');
    const expected = api.nc_compact(api.nc_definition(book, d, fresh));
    const actual = api.nc_compact_definition(book, d, fresh);
    assert.deepEqual(actual, expected, name + ' exact legacy body');
    rows.push({name, category: expectFact ? 'prepared-accessor' : 'fallback', fresh, pass: true});
  };
  const dynamic = t('Lam', '', [t('App', '', [vr(7), literal('Nat', 3)])], 7, 1);
  for (const [name, value] of [['dynamic', dynamic], ['literal', literal('Nat', 9)],
      ['source-static-rejected', t('NStatic', 'Tuple', [word(1)], 99)]]) {
    const source = api.ns_source(list([def('main', value)]));
    const prepared = api.ns_prepare(source, list(['main']));
    for (const fresh of [0, 17, 1024]) {
      compare(name + '-prepared-' + fresh, prepared, 'main', fresh, true);
      compare(name + '-unprepared-' + fresh, source, 'main', fresh, false);
    }
    const stripped = api.ns_source(prepared);
    assert.notEqual(api.ns_body(stripped, 'main').kind, 'NativeStaticBody');
    compare(name + '-old-payload-stripped', stripped, 'main', 19, false);
  }
  const nat = t('ADT', 'Nat');
  const foreignType = all(10, t('Typ'), all(11, nat, nat), 0);
  for (const [name, d] of [
    ['foreign', def('main', t('Foreign'), foreignType)],
    ['absent', def('main', t('Absent'), foreignType)],
    ['intrinsic', def('Nat.add', t('Absent'), all(1, nat, all(2, nat, nat)), true)],
  ]) {
    const source = api.ns_source(list([d]));
    const prepared = api.ns_prepare(source, list([d.name]));
    for (const fresh of [0, 17, 1024]) compare(name + '-' + fresh, prepared, d.name, fresh, false);
  }
  const source = api.ns_source(list([def('main', literal('Nat', 1))]));
  compare('missing-definition', source, 'missing', 23, false);
  return {kind: 'phase70-compact-body-helper-controls', pass: true,
    scope: 'Actual prepared-body fixed points and accessor equality to legacy checked closures; no C/native execution.', rows};
}
