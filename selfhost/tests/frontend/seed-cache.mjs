// The seed API must preserve full graph output, including binder identities.
// Run after bootstrap, or set BEND_FRONT_API to a frontend API build.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const project = path.resolve(import.meta.dirname, '../..');
const apiFile = process.env.BEND_FRONT_API || path.join(project, 'dist/typed-api.mjs');
const {default: api} = await import(pathToFileURL(apiFile));
assert.equal(typeof api.f_load_graph_seed, 'function', 'bootstrap must export f_load_graph_seed');
const basePath = fs.realpathSync(process.env.BEND_BASE || path.join(project, 'dist/base.bend'));
const baseText = fs.readFileSync(basePath, 'utf8');
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'}),source=(name,path,text)=>({$:'FSource',name,path,text}),base=source('Base',basePath,baseText);
const seed=api.f_load_graph('Base',list([base])).book;
function test(name,text,extras=[],opts={}){const main='/test/main.bend',sources=list([source(main,main,text),base,...extras]);let t=performance.now();const normal=api.f_load_graph(main,sources),normalMs=performance.now()-t;t=performance.now();const cached=api.f_load_graph_seed(main,sources,opts.path??basePath,opts.text??baseText,opts.book??seed),seedMs=performance.now()-t;assert.equal(normal.error, '', name + ' normal load');assert.deepEqual(cached,normal,name);console.log(name,Math.round(normalMs),Math.round(seedMs),normal.error)}
test('exact Base seed','import Base\ndef main() -> U32:\n  42\n');
test('mismatched bytes fall back','import Base\ndef main() -> U32:\n  42\n',[],{text:baseText+'#changed',book:{$:'Nil'}});
test('mismatched path falls back','import Base\ndef main() -> U32:\n  42\n',[],{path:'/different/base.bend',book:{$:'Nil'}});
test('unused Base remains absent','type Bit is Data:\n  On{}\ndef main() -> Bit:\n  On{}\n');
test('dependency order preserved','import ./first.bend as F\nimport Base\ndef main() -> F.Bit:\n  F.On{}\n',[source('/test/first.bend','/test/first.bend','type Bit is Data:\n  On{}\n')]);
test('nested Base import','import ./child.bend as C\ndef main() -> U32:\n  C.answer()\n',[source('/test/child.bend','/test/child.bend','import Base\ndef answer() -> U32:\n  42\n')]);
