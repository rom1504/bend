// Independent pinned TypeScript / Phase39 / candidate public values. No timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [tsArg,baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(tsArg&&baselineArg&&candidateArg&&outArg,'usage: list-typescript-controls.mjs TYPESCRIPT BASELINE CANDIDATE NEW_OUT');
const files=[tsArg,baselineArg,candidateArg].map(p=>fs.realpathSync(p)),out=path.resolve(outArg);
assert(!fs.existsSync(out),'output must be fresh');
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex'),bytes:fs.statSync(p).size});
const inputs=[],seen=new Set();
function bind(p){const r=identity(p);if(!seen.has(r.path)){seen.add(r.path);inputs.push(r);}return r;}
function pointers(x){if(!x||typeof x!=='object')return;if(x.canonicalPath&&x.sha256)assert.equal(bind(x.canonicalPath).sha256,x.sha256);for(const v of Object.values(x))pointers(v);}
const receipts=files.map(file=>{const receiptFile=file+'.json';bind(file);bind(receiptFile);const r=JSON.parse(fs.readFileSync(receiptFile));assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');assert.equal(fs.realpathSync(r.output.canonicalPath),file);pointers(r);return r;});
assert.equal(receipts[0].compiler.kind,'checked-pinned-typescript');
for(const r of receipts.slice(1))assert.equal(r.compiler.kind,'checked-development-attempt');
for(const r of receipts.slice(1))assert.equal(r.input.sha256,receipts[0].input.sha256);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));bind(path.join(out,'consumed-controls.mjs'));
const report={kind:'phase40-list-typescript-controls',complete:false,pass:false,node:process.version,inputs,oracle:[]};
const variants=['typescript','phase39','candidate'],modules=[];
for(const file of files)modules.push((await import(pathToFileURL(file))).default);
function expected(n,seed){let s=BigInt(seed),produced=[];for(let i=0;i<n;i++){produced.push(Number(s%16n));s=BigInt.asUintN(32,s*1664525n+1013904223n);}const filtered=produced.filter(x=>x>1),mapped=filtered.map(x=>Number(BigInt.asUintN(32,BigInt(x)*2n))),sum=Number(BigInt.asUintN(32,mapped.reduce((a,x)=>a+BigInt(x),0n)));return {produced,filtered,mapped,sum};}
// Each compiler owns its representation; compare all heads and terminal tags.
function canonical(v,chain,typescript,n){const result=[],cons=chain?'Link':'Con',nil=chain?'End':'Nil';while(v.$===cons){assert(result.length<=n,'cyclic or overlong value');if(typescript){assert.equal(typeof v.head,'number');result.push(v.head);v=v.tail;}else{assert.equal(v.a.length,2);assert.equal(typeof v.a[0],'number');result.push(v.a[0]);v=v.a[1];}}assert.equal(v.$,nil);assert.deepEqual(v,typescript?{$:nil}:{$:nil,a:[]});return result;}
try{
 for(const n of [0,1,2,7,16,128,512])for(const seed of [0,1,2,17,123,4294967294,4294967295]){
  const oracle=expected(n,seed),observations=[];
  for(let i=0;i<modules.length;i++){
   const m=modules[i],row={variant:variants[i],pipelines:{}};
   for(const owner of ['ground','chain']){
    const chain=owner==='chain',p=m[owner+'.make'](BigInt(n),seed),f=m[owner+'.select'](p),q=m[owner+'.twice'](f),sum=m[owner+'.add'](q,0);
    for(const [value,key]of [[p,'produced'],[f,'filtered'],[q,'mapped']])assert.deepEqual(canonical(value,chain,i===0,n),oracle[key],variants[i]+':'+owner+':'+key);
    assert.equal(sum,oracle.sum);assert.equal(m[owner+'_bench'](n,seed),oracle.sum);
    assert.equal(m[owner+'.choose'](7,p,false),p,'false combiner child alias');
    row.pipelines[owner]={sum};
   }
   row.bench=m.bench(n,seed);assert.equal(row.bench,Number(BigInt.asUintN(32,BigInt(oracle.sum)*2n)));observations.push(row);
  }
  report.oracle.push({n,seed,oracle,observations});
 }
 for(const row of inputs)assert.deepEqual(identity(row.path),row);
 report.complete=true;report.pass=true;
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};throw e;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify({pass:report.pass,oracle:report.oracle.length,report:path.join(out,'report.json')}));
