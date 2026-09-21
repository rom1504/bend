// Optional pinned-oracle comparison; production execution does not use upstream.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
if(!process.env.BEND_UPSTREAM){console.log('Set BEND_UPSTREAM to the pinned checkout to compare String.eq with Base.');process.exit(0)}
const project=path.resolve(import.meta.dirname,'../../..'),dir=path.join(project,'build/js-layout');fs.mkdirSync(dir,{recursive:true});
const source=path.join(dir,'string-eq.bend'),output=path.join(dir,'string-eq.mjs');fs.writeFileSync(source,'import Base\n');
const built=spawnSync(process.execPath,[path.join(project,'tools/stage0-library.mjs'),source,output,'String.eq'],{encoding:'utf8',env:process.env,timeout:120000});
assert.equal(built.status,0,built.error?.message||built.stderr);
const {default:oracle}=await import(pathToFileURL(output));
const runtime=path.join(dir,'string-eq-runtime.mjs');
fs.writeFileSync(runtime,fs.readFileSync(new URL('../../runtime.mjs',import.meta.url),'utf8')+'\nexport const eq=(a,b)=>call(G["String.eq"],[a,b]);');
const {eq}=await import(pathToFileURL(runtime));
const strings=['','a','aa','b','é','é','🙂','🙂a','\0',String.fromCharCode(0xd800),String.fromCharCode(0xdc00),String.fromCharCode(0xd83d,0xde42),'a'+String.fromCharCode(0xd800),'b'+String.fromCharCode(0xdc00)];
const observe=f=>{try{return {value:f()}}catch(e){return {error:String(e?.message??e).replace(/^bend: /,'')}}};
for(const a of strings)for(const b of strings)assert.deepEqual(observe(()=>eq(a,b)),observe(()=>oracle['String.eq'](a,b)),JSON.stringify([a,b]));
console.log(strings.length**2+' String.eq cases match pinned Base implementation');
