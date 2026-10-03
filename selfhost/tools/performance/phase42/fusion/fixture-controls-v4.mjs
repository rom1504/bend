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
const report={kind:'phase42-fusion-fixture-controls',complete:false,pass:false,node:process.version,inputs,oracle:[]};
const variants=['typescript','phase41','candidate'],modules=[];
for(const file of files)modules.push((await import(pathToFileURL(file))).default);
const admittedNames=['pipeline','ordered_pipeline','modzero_pipeline'];
let countedSource=fs.readFileSync(files[2],'utf8');
for(const name of admittedNames){const line=countedSource.split('\n').find(line=>line.startsWith('G["'+name+'"]=scalarCapture'));assert(line?.includes('/* private total scalar fusion */'),'missing compiler root '+name);assert(line.includes('try{')&&line.includes('finally{regionProofClose($previousProof);'),'counter outside complete proof '+name);countedSource=countedSource.replace(line,line.replace('/* private total scalar fusion */','/* private total scalar fusion */++$p42FixtureCounts['+JSON.stringify(name)+'];'));}
countedSource+='\nconst $p42FixtureCounts={pipeline:0,ordered_pipeline:0,modzero_pipeline:0};export function fixtureFusionCounts(){return {...$p42FixtureCounts};}\n';
const countedFile=path.join(out,'candidate-counted.mjs');fs.writeFileSync(countedFile,countedSource,{flag:'wx'});bind(countedFile);const countedCandidate=await import(pathToFileURL(countedFile));modules[2]=countedCandidate.default;
report.admission=[];

function expected(n,seed,initial){let state=BigInt(seed),produced=[];for(let i=0;i<n;++i){produced.push(Number(state));state=BigInt.asUintN(32,BigInt.asUintN(32,state*1103515245n)+12345n);}const filtered=produced.filter(h=>h>2147483647),mapped=filtered.map(h=>Number(BigInt.asUintN(32,BigInt.asUintN(32,BigInt(h)*3n)+17n))),sum=Number(BigInt.asUintN(32,mapped.reduce((a,h)=>a+BigInt(h),BigInt(initial))));return {produced,filtered,mapped,sum};}
// Each compiler owns its representation; compare all heads and terminal tags.
function canonical(v,chain,typescript,n){const result=[],cons=chain?'Link':'Con',nil=chain?'End':'Nil';while(v.$===cons){assert(result.length<=n,'cyclic or overlong value');if(typescript){assert.equal(typeof v.head,'number');result.push(v.head);v=v.tail;}else{assert.equal(v.a.length,2);assert.equal(typeof v.a[0],'number');result.push(v.a[0]);v=v.a[1];}}assert.equal(v.$,nil);assert.deepEqual(v,typescript?{$:nil}:{$:nil,a:[]});return result;}
try{
 const candidateText=fs.readFileSync(files[2],'utf8');
 const admitted=['pipeline','ordered_pipeline','modzero_pipeline'];
 for(const name of admitted){const line=candidateText.split('\n').find(line=>line.startsWith('G["'+name+'"]=scalarCapture'));assert(line?.includes('/* private total scalar fusion */'),'ordinary pipeline lacks fusion '+name);assert(line.includes('exactCode(function(a,$entered)')&&line.includes('regionHostGuard()')&&line.includes('localGuard($guards)')&&line.includes('finally{regionProofClose($previousProof);'),'original guards/proof closure missing '+name);}
 assert.equal(candidateText.split('/* private total scalar fusion */').length-1,admitted.length,'unexpected fusion entries');
 for(const name of ['retained','alias_single','shared','refused_division']){const line=candidateText.split('\n').find(line=>line.startsWith('G["'+name+'"]='));assert(line,'missing refusal export '+name);assert(!line.includes('/* private total scalar fusion */'),'ineligible root fused '+name);}
 for(const n of [0,1,2,7,15,16,17,31,128,129,512,513])for(const seed of [0,1,2,17,123,4294967294,4294967295])for(const initial of [0,1,4294967295]){
  const oracle=expected(n,seed,initial),observations=[];
  for(let i=0;i<modules.length;i++){
   const before=i===2?countedCandidate.fixtureFusionCounts():null;const m=modules[i],p=m['chain.make'](BigInt(n),seed),f=m['chain.keep'](p),q=m['chain.bump'](f),sum=m['chain.fold'](q,initial);
   for(const [value,key]of [[p,'produced'],[f,'filtered'],[q,'mapped']])assert.deepEqual(canonical(value,true,i===0,n),oracle[key],variants[i]+':'+key);
   assert.equal(sum,oracle.sum);assert.equal(m.pipeline(n,seed,initial),oracle.sum);
   const ordered=xs=>Number(xs.reduce((acc,h)=>BigInt.asUintN(32,BigInt.asUintN(32,acc*3n)-BigInt(h)),BigInt(initial)));
   assert.equal(m.ordered_pipeline(n,seed,initial),ordered(oracle.mapped),'ordered accumulator traversal');
   assert.equal(m.modzero_pipeline(n,seed,initial),ordered(oracle.filtered),'mod-zero preserves scalar head');
   if(i===2){const after=countedCandidate.fixtureFusionCounts();for(const name of admittedNames)assert.equal(after[name]-before[name],1,'ordinary compiler admission '+name);report.admission.push({n,seed,initial,before,after});}
   const modzero=m['chain.modzero'](f);assert.deepEqual(canonical(modzero,true,i===0,n),oracle.filtered,'intrinsic zero-divisor heads');
   assert.equal(m['chain.orderedfold'](q,initial),ordered(oracle.mapped),'ordinary noncommutative fold');assert.equal(m.alias_single(n,seed,initial),oracle.sum);
   const retained=m.retained(n,seed);assert.deepEqual(canonical(retained,true,i===0,n),oracle.mapped);
   assert.equal(m['chain.keep.at'](7,p,false),p,'false combiner child alias');
   const sourceSum=Number(BigInt.asUintN(32,oracle.produced.reduce((a,h)=>a+BigInt(h),0n)));
   assert.equal(m.shared(n,seed,initial),Number(BigInt.asUintN(32,BigInt(oracle.sum)+BigInt(sourceSum))));
   const divided=oracle.filtered.map(h=>Math.floor(h/3)>>>0),divisionSum=Number(BigInt.asUintN(32,divided.reduce((a,h)=>a+BigInt(h),BigInt(initial))));assert.equal(m.refused_division(n,seed,initial),divisionSum);
   observations.push({variant:variants[i],sum});
  }
  report.oracle.push({n,seed,initial,oracle,observations});
 }
 for(const n of [1024,4096,8192]){const seed=4294967295,initial=4294967295,oracle=expected(n,seed,initial);const before=countedCandidate.fixtureFusionCounts();for(const m of modules){assert.equal(m.pipeline(n,seed,initial),oracle.sum);const ordered=xs=>Number(xs.reduce((acc,h)=>BigInt.asUintN(32,BigInt.asUintN(32,acc*3n)-BigInt(h)),BigInt(initial)));assert.equal(m.ordered_pipeline(n,seed,initial),ordered(oracle.mapped));assert.equal(m.modzero_pipeline(n,seed,initial),ordered(oracle.filtered));}const after=countedCandidate.fixtureFusionCounts();for(const name of admittedNames)assert.equal(after[name]-before[name],1,'large ordinary compiler admission '+name);report.admission.push({kind:'ordinary-large',n,seed,initial,before,after});report.oracle.push({kind:'ordinary-large',n,seed,initial,sum:oracle.sum});}
 for(const row of inputs)assert.deepEqual(identity(row.path),row);
 report.complete=true;report.pass=true;
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};throw e;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify({pass:report.pass,oracle:report.oracle.length,admission:report.admission.length,report:path.join(out,'report.json')}));
