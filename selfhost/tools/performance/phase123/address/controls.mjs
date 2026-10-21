// Transport checked Bend analysis output; independently evaluate finite bitvectors.
// Never compile or execute generated native code, and never dereference a pointer.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [receiptArg,outArg]=process.argv.slice(2);
assert(receiptArg&&outArg,'Usage: controls.mjs CHECKED_RECEIPT NEW_OUTPUT_DIR');
const root=path.resolve(import.meta.dirname,'../../../../..');
const receiptFile=path.resolve(receiptArg),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase123/')&&!fs.existsSync(out));
const pin=file=>{file=path.resolve(file);const bytes=fs.readFileSync(file);return{file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')}};
const verify=x=>assert.deepEqual(pin(x.file),x);
const list=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head);xs=xs.tail}assert.equal(xs?.$,'Nil');return a};
const receipt=JSON.parse(fs.readFileSync(receiptFile));assert(receipt.complete&&receipt.checked);
const inputs=[pin(import.meta.filename),pin(receiptFile),receipt.api,...receipt.inputs,pin(process.execPath),pin(path.join(root,'selfhost/tools/performance/phase123/scaled-address02.bend'))];
inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,inputs,scaleRows:[],addressRows:[],scope:'Finite modulo64 arithmetic plus exact returned IR structure. No memory access, compiler acquisition, generated-program execution or speed claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const u64={$:'N111U64'},u32={$:'N111U32'};
const local=name=>({$:'N111Local',name}),constant=(lo,hi=0)=>({$:'N111Const',lo,hi});
const bin=(name,op,left,right)=>({$:'N111Bin',name,typ:u64,op,left,right});
const values=[0n,1n,2n,0x7fffffffn,0x80000000n,0xffffffffn,0x100000000n,0x7fffffffffffffffn,0x8000000000000000n,0xffffffffffffffffn];
const shifts=[0,1,2,3,4,31,32,63];
const read=(v,env)=>{if(v.$==='N111Const')return BigInt(v.lo)+(BigInt(v.hi)<<32n);assert.equal(v.$,'N111Local');assert(env.has(v.name));return env.get(v.name)};
function evalBin(s,env){
 assert.equal(s.$,'N111Bin');assert.deepEqual(s.typ,u64);
 const a=read(s.left,env),b=read(s.right,env);let answer;
 if(s.op==='mul')answer=a*b;else if(s.op==='shl')answer=a<<b;else if(s.op==='and')answer=a&b;
 else throw Error('Unexpected arithmetic '+s.op);
 answer=BigInt.asUintN(64,answer);env.set(s.name,answer);return answer;
}
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 assert.equal(typeof api.p123a_scale,'function');assert.equal(typeof api.p117h_address,'function');
 for(const shift of shifts){
  const actual=api.p123a_scale('scaled',local('input'),shift);
  const expected=shift<=3?bin('scaled','mul',local('input'),constant([1,2,4,8][shift])):bin('scaled','shl',local('input'),constant(shift));
  assert.deepEqual(actual,expected,'Exact admission/fallback IR at shift '+shift);
  for(const value of values)assert.equal(evalBin(actual,new Map([['input',value]])),BigInt.asUintN(64,value<<BigInt(shift)),`shift ${shift}, value ${value}`);
  report.scaleRows.push({shift,checks:values.length,admitted:shift<=3,exactFallback:shift>3,actual});
 }
 for(const id of [72,73,74])for(const [site,origin] of [[0,1],[17,3],[4294967295,8]]){
  const name=role=>`p113a_${site}_${role}`,hoist=role=>`p113a_${origin}_hoist_${role}`;
  const actual=list(api.p117h_address(id,site,origin));
  const expected=[bin(name('index'),'and',local(name('index')),local(hoist('mask'))),
   bin(name('bytes'),'mul',local(name('index')),constant(4)),
   {$:'N111Offset',name:name('cell'),base:local(hoist('base')),bytes:local(name('bytes'))}];
  if(id!==73)expected.push({$:'N111Load',name:name('old'),typ:u32,base:local(name('cell')),offset:0});
  assert.deepEqual(actual,expected,'Exact packed32 GET/SET/SWAP order '+id);
  let checks=0;
  for(const value of values)for(const mask of [0n,1n,7n,255n,0xffffffffn]){
   const env=new Map([[name('index'),value],[hoist('mask'),mask]]);
   evalBin(actual[0],env);const bytes=evalBin(actual[1],env);
   assert.equal(bytes,BigInt.asUintN(64,(value&mask)*4n));checks++;
  }
  report.addressRows.push({id,site,origin,checks,loadCount:actual.filter(x=>x.$==='N111Load').length,actual});
 }
 inputs.forEach(verify);report.complete=true;
 report.arithmeticChecks=report.scaleRows.reduce((n,r)=>n+r.checks,0);
 report.addressChecks=report.addressRows.reduce((n,r)=>n+r.checks,0);
}catch(error){report.error=String(error);report.stack=error.stack;process.exitCode=1}
finally{save();console.log(JSON.stringify({complete:report.complete,arithmeticChecks:report.arithmeticChecks,addressChecks:report.addressChecks,error:report.error}))}
