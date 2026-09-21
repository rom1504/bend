// Match the pinned loader's main-module order boundary, including imported
// unsafe claims and foreign declarations, without changing FResult's ABI.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const project = path.resolve(import.meta.dirname, '../..');
const apiPath = process.env.BEND_FRONT_API || path.join(project, 'dist/typed-api.mjs');
const upstream = process.env.BEND_UPSTREAM || path.join(project, '.bootstrap/upstream');
const {default: api} = await import(pathToFileURL(apiPath));
const B = await import(pathToFileURL(path.join(upstream, 'bend2/bend.ts')));
const list = a => a.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const array = x => {const out=[];for(;x.$==='Con';x=x.tail)out.push(x.head);return out;};
const source = (name, pathname, text) => ({$: 'FSource', name, path: pathname, text});
const cases = ['check/unsafe_field.bend', 'check/unsafe_relies.bend', 'import/unsafe_lib.bend', 'import/unsafe_used.bend', 'io/far_types.bend', 'io/marshal_imported_nullary_type.bend'];
for (const id of cases) {
  const file = fs.realpathSync(path.join(upstream, 'tests', id));
  const book = B.book_nil();
  const boundary = await B.book_load(book, file, '', new Map());
  const expected = [...new Set(book.order.slice(boundary))];
  const sources = list([source(file, file, fs.readFileSync(file, 'utf8'))]);
  assert.deepEqual(array(api.f_main_names(file, sources)), expected, id);
  console.log(id, expected.join(', '));
}
// An alias for the main source selects its canonical source record. Repeated
// law/fill events occur once and constructor names never become own claims.
const main='/report/main.bend', dep='/report/dep.bend';
const sources=list([
  source('/report/main-alias.bend', main, 'import ./dep.bend as D\nlaw own:\n  D.Bit\ndef own():\n  D.On{}\ntype Local is Data:\n  Made{}\ndef foreign() -> Local:\n  import "./foreign.js"\n'),
  source(dep, dep, 'type Bit is Data:\n  On{}\n@unsafe\ndef hidden() -> Bit:\n  On{}\n'),
]);
assert.deepEqual(array(api.f_main_names(main, sources)), ['own', 'Local', 'foreign']);
const loaded=api.f_load_graph(main,sources);
assert.equal(loaded.error,'');
const defs=array(loaded.book);
assert.ok(defs.some(d=>d.name==='dep.hidden'),'dependency was actually loaded');
assert.equal(defs.find(d=>d.name==='foreign').native,false,'user foreign is not a Base intrinsic');
console.log('canonical main alias, dependency exclusion, duplicate fill, nested constructor, foreign origin: pass');
