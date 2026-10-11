// Source-only focused boundary controls. Importing executes no compiler API.
// Root invokes runStaticImageBoundaries(candidateApi) inside its single guard.
import assert from 'node:assert/strict';
const list = values => values.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const term = (tag, name = '', children = [], id = 0, quant = 0) =>
  ({$: 'KTerm', tag, name, kids: list(children), id, quant, removed: list([]), begin: 0, end: 0});
const word = value => term('NWord', String(value));
const node = (a, b) => term('Ctr', 'Tuple', [word(a), word(b)]);
function count(values) {
  let n = 0;
  while (values.$ === 'Con') { ++n; values = values.tail; }
  assert.equal(values.$, 'Nil');
  return n;
}
export function runStaticImageBoundaries(api) {
  assert.equal(typeof api.ns_node, 'function', 'candidate must export native static helper');
  const rows = [];
  const check = (name, value, expectedTag, expectedSize, expectedOffset) => {
    assert.equal(value.term.tag, expectedTag, name);
    assert.equal(value.image.size, expectedSize, name);
    assert.equal(count(value.image.words), expectedSize, name + ' actual image length');
    if (expectedOffset !== undefined) assert.equal(value.term.id, expectedOffset, name);
    rows.push({name, pass: true, tag: value.term.tag, imageWords: value.image.size, offset: value.term.id});
    return value.image;
  };
  // The existing prefix is an explicitly materialized array of immortal scalar
  // words; this avoids a 32K-deep String or 32K reachable definitions. No
  // counter or empty-list shortcut lies about the image's actual size.
  const almost = {$: 'NS_Image', size: 65534, words: list(Array(65534).fill('0ull')), index: api.missing()};
  const full = check('exact-fit-at-bound', api.ns_node(node(1, 2), almost), 'NStatic', 65536, 65534);
  check('new-node-refused-after-bound', api.ns_node(node(3, 4), full), 'Ctr', 65536);
  check('interned-node-reused-at-bound', api.ns_node(node(1, 2), full), 'NStatic', 65536, 65534);
  const child = api.ns_node(node(1, 2), full).term;
  const parent = term('Ctr', 'Tuple', [word(5), child]);
  const fallback = api.ns_node(parent, full);
  check('dynamic-parent-retains-static-child', fallback, 'Ctr', 65536);
  assert.equal(fallback.term.kids.tail.head.tag, 'NStatic');
  assert.equal(fallback.term.kids.tail.head.id, 65534);
  check('nullary-still-packed-at-bound', api.ns_node(term('Ctr', 'SNil'), full), 'NStatic', 65536, 0);
  check('scalar-field-still-packed-at-bound', api.ns_node(term('Ctr', '$ctor.80_', [word(4294967295)]), full), 'NStatic', 65536, 0);
  const lastOne = {$: 'NS_Image', size: 65535, words: list(Array(65535).fill('0ull')), index: api.missing()};
  check('two-words-refused-with-one-free', api.ns_node(node(7, 8), lastOne), 'Ctr', 65535);
  return {kind: 'phase69-static-image-boundaries', scope: 'Pure candidate helper, actual 65534/65535-word prefixes; no C/native execution or whole-emitter cap claim.', pass: true, rows};
}
