// Isolated origin proof: actual source positions survive imports, beta
// substitution and global freshening; erased origins are not invented.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const project=path.resolve(import.meta.dirname,'../..');
const {default:api}=await import(pathToFileURL(process.env.BEND_FRONT_API||path.join(project,'build/front-origins.mjs')));
const nil={$:'Nil'},list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),array=x=>{const a=[];for(;x.$==='Con';x=x.tail)a.push(x.head);return a;};
const dep='# Unicode before the failing terms: 😀\ntype Flag is Data:\n  On{}\ntype OtherType is Data:\n  Other{}\ndef missing() -> Flag:\n  (x => x)(Missing)\ndef wrong() -> Flag:\n  Other{}\n';
const main='import ./dep.bend as D\ndef entry() -> D.Flag:\n  D.missing()\n';
const sources=list([{$:'FSource',name:'/origins/main.bend',path:'/origins/main.bend',text:main},{$:'FSource',name:'/origins/dep.bend',path:'/origins/dep.bend',text:dep}]);
const r=api.f_load_origins('/origins/main.bend',sources);assert.equal(r.result.error,'');assert.deepEqual(r.result,api.f_load_graph('/origins/main.bend',sources));
const origins=array(r.origins),book=array(r.result.book);
for(const [definition,name,text,token] of [['dep.missing','Missing',dep,'Missing'],['dep.wrong','dep.Other',dep,'Other'],['entry','dep.missing',main,'D.missing']]){
 const found=origins.filter(o=>o.definition===definition&&o.term.name===name);assert.equal(found.length,1,definition);const o=found[0];assert.equal(o.source,text);assert.equal(text.slice(o.begin,o.end),token);assert.equal(o.begin,text.indexOf(token,definition==='dep.wrong'?text.indexOf('def wrong'):0));
 const route=array(o.path),d=book.find(d=>d.name===definition);let node=route.shift()===0?d.typ:d.value;for(const index of route)node=array(node.kids)[index];assert.deepEqual(o.term,node,'origin indexes final freshened core');
}
assert.ok(origins.every(o=>['Ref','ADT','Ctr'].includes(o.term.tag)&&o.term.id>=65536),'only retained lexer provenance');
for(const name of ['dep.missing','dep.wrong','entry','not-a-definition']){
 const filtered=api.f_load_origins_for('/origins/main.bend',sources,name);assert.deepEqual(filtered.result,r.result);assert.deepEqual(array(filtered.origins),origins.filter(o=>o.definition===name),'definition-filtered origins');
}
console.log('final graph equality; imported beta-substituted reference; wrong constructor; qualified call; UTF16 offsets; exact definition filters: pass');
