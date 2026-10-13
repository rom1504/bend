import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {verifyRelease} from '../../development/release.mjs';
import {prepareSelfRelease} from '../../development/self-release.mjs';
const root=path.resolve(import.meta.dirname,'../../..'),out=path.resolve(process.argv[2]);
assert(out.startsWith(path.join(root,'build/phase77/') ));assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const read=f=>JSON.parse(fs.readFileSync(f,'utf8')),sha=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const baseline=read(path.join(root,'dist/release.json'));
const extra=prepareSelfRelease(path.join(root,'build/phase76/compiler12'),path.join(root,'build/phase76/compiler12-b2/image-pins.json'),path.join(root,'build/phase76/compiler12-qualification'));
const copy=path.join(out,'relocated');fs.mkdirSync(copy);
const copyFile=(source,name)=>{const dest=path.join(copy,name);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.copyFileSync(source,dest);};
for(const r of [...baseline.files,...baseline.checkout])copyFile(path.join(root,r.path),r.path);
for(const [source,name] of extra.copies)copyFile(source,'dist/'+name);
for(const name of ['release','self-release'])copyFile(path.join(root,'tools/development/'+name+'.mjs'),'tools/development/'+name+'.mjs');
const item=name=>({path:name,sha256:sha(path.join(copy,name)),bytes:fs.statSync(path.join(copy,name)).size});
const manifest={...baseline,kind:'bend-default-selfhost-release',artifact:'self-emitted-b2',files:[...new Set([...baseline.files.map(x=>x.path),...extra.copies.map(([,n])=>'dist/'+n)])].map(item),checkout:[...new Set([...baseline.checkout.map(x=>x.path),'tools/development/release.mjs','tools/development/self-release.mjs'])].map(item),lineage:{...baseline.lineage,selfEmittedSha256:extra.apiSha256,generatorSha256:extra.generatorSha256}};
const file=path.join(copy,'dist/release.json'),write=m=>fs.writeFileSync(file,JSON.stringify(m));write(manifest);
const rows=[];function test(name,body){body();rows.push({name,pass:true});}
test('relocated-B2-lineage',()=>assert.equal(verifyRelease(copy).artifact,'self-emitted-b2'));
for(const name of ['typed-api.mjs','release-lineage/generator-api.mjs','release-lineage/self-source.bend','release-lineage/self-emission.json','release-lineage/self-fixed-point.json']){
 const f=path.join(copy,'dist',name),old=fs.readFileSync(f);
 test('tampered-'+name,()=>{try{fs.appendFileSync(f,' ');assert.throws(()=>verifyRelease(copy));}finally{fs.writeFileSync(f,old);}});
}
function invalidJson(name,mutate,label){const f=path.join(copy,'dist/release-lineage',name),bytes=fs.readFileSync(f);try{const j=read(f);mutate(j);fs.writeFileSync(f,JSON.stringify(j));const m=structuredClone(manifest);Object.assign(m.files.find(x=>x.path==='dist/release-lineage/'+name),item('dist/release-lineage/'+name));write(m);assert.throws(()=>verifyRelease(copy),label);}finally{fs.writeFileSync(f,bytes);write(manifest);}}
test('false-fixed-point',()=>invalidJson('self-fixed-point.json',j=>j.byteEquality=false));
test('wrong-B3',()=>invalidJson('self-fixed-point.json',j=>j.b3.sha256='0'.repeat(64)));
test('failed-own-source-check',()=>invalidJson('self-check.json',j=>j.freshTypeCheck=false));
test('missing-generator-inventory',()=>{const m=structuredClone(manifest);m.files=m.files.filter(x=>!x.path.endsWith('/generator-api.mjs'));write(m);assert.throws(()=>verifyRelease(copy));write(manifest);});
test('missing-source-binding',()=>{const m=structuredClone(manifest);m.checkout=m.checkout.filter(x=>x.path!=='src/back/native/bridge.bend');write(m);assert.throws(()=>verifyRelease(copy));write(manifest);});
test('missing-packager-binding',()=>{const m=structuredClone(manifest);m.checkout=m.checkout.filter(x=>x.path!=='tools/development/self-release.mjs');write(m);assert.throws(()=>verifyRelease(copy));write(manifest);});
test('restored-package',()=>verifyRelease(copy));
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,pass:true,checks:rows,scope:'Valid relocated B2 package and independent bad-byte, missing-entry, false-check and mismatched-image controls. Real installed release unchanged.'},null,2)+'\n');console.log(JSON.stringify({complete:true,checks:rows.length}));
