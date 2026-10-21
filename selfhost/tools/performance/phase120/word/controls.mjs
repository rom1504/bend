// Checked Bend executes the transformation. Host code transports its results
// and independently interprets only finite integer analysis controls.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [receiptArg,outArg]=process.argv.slice(2);
if(!receiptArg||!outArg)throw Error('CHECKED_API_REPORT FRESH_OUTPUT_DIRECTORY');
const root=path.resolve(import.meta.dirname,'../../../../..');
const receipt=path.resolve(receiptArg),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase120/'));
const pin=file=>{file=path.resolve(file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=p=>{const q=pin(p.file);assert.equal(q.bytes,p.bytes,p.file);assert.equal(q.sha256,p.sha256,p.file);};
const list=value=>{const out=[];while(value?.$==='Con'){out.push(value.head);value=value.tail;}assert.equal(value?.$,'Nil');return out;};
const receiptData=JSON.parse(fs.readFileSync(receipt,'utf8'));
assert(receiptData.complete&&receiptData.checked&&receiptData.exports.includes('p120w_controls'));
const inputs=[pin(import.meta.filename),pin(receipt),receiptData.api,...receiptData.inputs,pin(process.execPath)];
inputs.forEach(verify);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase120-signed-word-finite-controls',complete:false,inputs,rows:[],scope:'Pure checked Bend analysis, literal hit expectations, independent BigInt interpretation of admitted finite controls; no generated target execution or host transformation.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const start=performance.now();
const width=t=>{assert(['N111U32','N111U64'].includes(t.$));return t.$==='N111U32'?32:64;};
const value=(v,env)=>{if(v.$==='N111Const')return BigInt(v.lo)+(BigInt(v.hi)<<32n);assert.equal(v.$,'N111Local');assert(env.has(v.name),'Undefined finite local '+v.name);return env.get(v.name);};
function scalar(s,env){
  if(s.$==='N111If'){for(const x of list(value(s.condition,env)!==0n?s.yes:s.no))scalar(x,env);return;}
  const bits=width(s.typ);let result;
  if(s.$==='N111Set')result=value(s.value,env);
  else{
    assert.equal(s.$,'N111Bin');const a=BigInt.asUintN(bits,value(s.left,env)),b=BigInt.asUintN(bits,value(s.right,env));
    switch(s.op){
      case 'and':result=a&b;break;case 'or':result=a|b;break;case 'xor':result=a^b;break;
      case 'eq':result=BigInt(a===b);break;case 'ne':result=BigInt(a!==b);break;
      case 'shl':result=a<<(b%BigInt(bits));break;case 'shr':result=a>>(b%BigInt(bits));break;
      case 'sar':result=BigInt.asIntN(bits,a)>>(b%BigInt(bits));break;
      default:throw Error('Unsupported finite operation '+s.op);
    }
  }
  env.set(s.name,BigInt.asUintN(bits,result));
}
function evaluate(body,env){
  for(const s of list(body)){
    if(s.$==='P113DScalar')scalar(s.stmt,env);
    else if(s.$==='P113DIf'){const result=evaluate(value(s.condition,env)!==0n?s.yes:s.no,env);if(result!==undefined)return result;}
    else{assert.equal(s.$,'P113DResult');const values=list(s.values);assert.equal(values.length,1);return value(values[0],env);}
  }
}
try{
  const api=(await import(pathToFileURL(receiptData.api.file))).default;
  const raw=api.p120w_controls({$:'Unit'}),cases=list(raw);
  const names=['constant-shift8','commuted-or','constant-shift1','constant-shift16','wrong-mask-refused','different-origin-refused','overwritten-origin-refused','retained-alias-accepted','partial-join-refused','inverse-fill-refused','unknown-call-invalidates','unknown-memory-invalidates','shift32-refused','sign-only-shift31-fallback'];
  const expected=[1,1,1,1,0,0,0,1,0,0,0,0,0,0];
  assert.deepEqual(cases.map(x=>x.name),names);const rawFile=path.join(out,'controls.json');fs.writeFileSync(rawFile,JSON.stringify(raw,null,2)+'\n');report.raw=pin(rawFile);
  const boundary=[0n,1n,255n,256n,0x7fffff00n,0x7fffffffn,0x80000000n,0x80000001n,0xffffff00n,0xffffffffn,0x180000000n,0xffffffffffffffffn];
  for(let i=0;i<cases.length;i++){
    const c=cases[i];assert.equal(c.$,'P120WControl');assert.equal(c.expectedHits,expected[i]);assert.equal(c.actualHits,expected[i],c.name);
    const row={name:c.name,actualHits:c.actualHits,expectedHits:expected[i],passed:true,independentValues:0};report.rows.push(row);
    if(expected[i]===1){
      const shift=c.name==='constant-shift1'?1n:c.name==='constant-shift16'?16n:8n;
      for(const x of boundary){const actual=evaluate(c.body,new Map([['a',x],['b',0x76543210n]]));const expectedValue=BigInt.asUintN(32,BigInt.asIntN(32,x)>>shift);assert.equal(actual,expectedValue,c.name+' at '+x);row.independentValues++;}
    }
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error);report.stack=error?.stack;process.exitCode=1;}
finally{report.seconds=(performance.now()-start)/1000;report.peakRss=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,cases:report.rows.length,error:report.error,out}));}
