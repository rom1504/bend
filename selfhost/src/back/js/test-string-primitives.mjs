// Every newly enabled primitive must agree with pinned Base through public APIs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {inspect,project} from '../../../tools/typed-driver.mjs';
assert.ok(process.env.BEND_UPSTREAM,'Pinned BEND_UPSTREAM is required');
const directory=path.join(project,'build/string-primitives');fs.mkdirSync(directory,{recursive:true});
const source=path.join(project,'tests/fixtures/string-primitives.bend'),oracleFile=path.join(directory,'oracle.mjs'),candidate=path.join(directory,'candidate.mjs');
const names=['contains','starts_with','reverse','is_empty','length'];
const result=spawnSync(process.execPath,[path.join(project,'tools/stage0-library.mjs'),source,oracleFile,...names],{encoding:'utf8',timeout:120000});
assert.equal(result.error,undefined);assert.equal(result.status,0,result.stderr);
const compiled=await inspect(source,{mode:'library'});assert.equal(compiled.status,'ok',JSON.stringify(compiled));fs.writeFileSync(candidate,compiled.code);
const oracle=(await import(pathToFileURL(oracleFile))).default,actual=(await import(pathToFileURL(candidate))).default;
const observe=f=>{try{return {value:f()}}catch(e){return {error:String(e?.message??e).replace(/^bend: /,'')}}};
const strings=['','a','b','aa','ab','aab','abc','é','é','🙂','🙂a','a🙂b','\0','\ud800','\udc00','a\ud800','🙂\udc00'];
// Add a deterministic small alphabet product to cover prefix/substring boundaries.
for(const a of ['a','b','🙂'])for(const b of ['a','b','🙂'])for(const c of ['','a','b'])strings.push(a+b+c);
let cases=0;
for(const name of names)for(const a of strings)for(const b of (['contains','starts_with'].includes(name)?strings:[''])){
 const args=['contains','starts_with'].includes(name)?[a,b]:[a];
 assert.deepEqual(observe(()=>actual[name](...args)),observe(()=>oracle[name](...args)),JSON.stringify({name,a,b}));cases++;
}
// A same-spelled user definition must retain its implementation and provenance.
const custom=path.join(directory,'custom.bend'),customOutput=path.join(directory,'custom.mjs');
fs.writeFileSync(custom,'type Answer is Data:\n  Yes{}\n  No{}\ndef String.contains(x: Answer) -> Answer:\n  match x:\n    case Yes{}: No{}\n    case No{}: Yes{}\ndef answer() -> Answer:\n  String.contains(Yes{})\n');
const c=await inspect(custom,{mode:'library'});assert.equal(c.status,'ok',JSON.stringify(c));fs.writeFileSync(customOutput,c.code);
assert.deepEqual((await import(pathToFileURL(customOutput))).default.answer(),{$:'No',a:[]});
console.log(cases+' primitive comparisons passed; user String.contains preserved');
