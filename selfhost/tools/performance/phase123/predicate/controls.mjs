// Host transports checked Bend output and evaluates finite integer controls.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receiptFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
const root=path.resolve(import.meta.dirname,'../../../../..');
assert(out.startsWith(root+'/selfhost/build/phase123/')&&!fs.existsSync(out));
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=x=>assert.deepEqual(pin(x.file),x);
const list=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head);xs=xs.tail}assert.equal(xs?.$,'Nil');return a};
const receipt=JSON.parse(fs.readFileSync(receiptFile));assert(receipt.complete&&receipt.checked);
const inputs=[pin(import.meta.filename),pin(receiptFile),receipt.api,...receipt.inputs,pin(process.execPath)];inputs.forEach(verify);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={complete:false,inputs,rows:[],scope:'Independent BigInt semantics for finite scalar IR, plus literal transform/refusal expectations and unchanged full-function verifier.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const value=(v,e)=>{if(v.$==='N111Const')return BigInt(v.lo)+(BigInt(v.hi)<<32n);assert.equal(v.$,'N111Local');assert(e.has(v.name));return e.get(v.name)};
function run(body,e){
 for(const s of list(body)){
  if(s.$==='N111If'){run(value(s.condition,e)!==0n?s.yes:s.no,e);continue}
  const bits=s.typ.$==='N111U32'?32:64;assert(['N111U32','N111U64'].includes(s.typ.$));
  let answer;
  if(s.$==='N111Set')answer=value(s.value,e);
  else{
   assert.equal(s.$,'N111Bin');const a=BigInt.asUintN(bits,value(s.left,e)),b=BigInt.asUintN(bits,value(s.right,e));
   if(s.op==='eq')answer=BigInt(a===b);else if(s.op==='ne')answer=BigInt(a!==b);
   else if(s.op==='ult')answer=BigInt(a<b);else if(s.op==='xor')answer=a^b;
   else throw Error('Unsupported independent opcode '+s.op);
  }
  e.set(s.name,BigInt.asUintN(bits,answer));
 }
 return e.get('test');
}
try{
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 const expected=['comparison-diamond-copy-eq1','inverted-diamond-copy-eq1','root-overwrite-refused','unknown-value-refused','branch-unknown-refused','nonzero-high-constant-refused','whole-function-original-and-after-verifies'].map(s=>'PASS '+s);
 report.verifierAndAdmission=list(api.p123_predicate_controls({$:'Unit'}));assert.deepEqual(report.verifierAndAdmission,expected);
 const values=[0n,1n,2n,0x7fffffffn,0x80000000n,0xffffffffn,0x100000000n,0x100000001n,0xffffffff00000000n,0xffffffffffffffffn];
 for(let which=0;which<6;which++){
  const before=api.p123pt_case(which),after=api.p123pt_after(which);let checks=0;
  for(const a of values)for(const b of values){
   const original=run(before,new Map([['a',a],['b',b]])),changed=run(after,new Map([['a',a],['b',b]]));
   const expected=which===0||which===2?BigInt(a<b):which===1?BigInt(a>=b):which===3?BigInt(a===1n):which===4?BigInt((a<b?a:b)===1n):0n;
   assert.equal(original,expected,`${which}:original ${a},${b}`);assert.equal(changed,expected,`${which}:after ${a},${b}`);checks++;
  }
  report.rows.push({which,checks,before,after});save();
 }
 inputs.forEach(verify);report.complete=true;report.independentPairs=600;
}catch(error){report.error=String(error);report.stack=error.stack;process.exitCode=1}finally{save();console.log(JSON.stringify({complete:report.complete,independentPairs:report.independentPairs,error:report.error}))}
