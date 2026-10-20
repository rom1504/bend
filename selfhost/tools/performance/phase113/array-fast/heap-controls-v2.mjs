// Text-only entry/base lifetime controls. Synthetic owning graphs never execute.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('heap-controls-v2.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),file=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(file),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
if(!receipt.complete||!receipt.checked||!receipt.exports?.includes('p113ah_control_text')||receipt.api.sha256!==pin(file).sha256)throw Error('Checked API/export pin mismatch');
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-array-heap-structural-controls-v2',complete:false,inputs:[pin(file),pin(receiptFile),pin(import.meta.filename)],controls:[],scope:'Exact emitted text checks only; no synthetic graph/native execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const api=(await import(pathToFileURL(file))).default;
for(const arrays of [false,true])for(const loop of [false,true]){
 const name=`arrays-${arrays}-loop-${loop}`;
 try{
  const text=api.p113ah_control_text(loop,arrays);
  const start=text.indexOf('@p113_loop\n');assert(start>=0);
  const loads=[...text.matchAll(/%v_p113a_heap_base =l loadl %state\n/g)];
  assert.equal(loads.length,arrays?1:0);
  if(arrays){
   assert(loads[0].index<start);assert(!text.slice(start).includes('loadl %state'));
   assert(text.includes('copy %v_p113a_heap_base'));
   assert(text.includes('ceql')&&text.includes(', 6\n')); // raw ARR guard retained
   assert(text.includes('51413504')); // dynamic allocation boundary retained
   assert(text.includes('culel')&&text.includes(', 1\n')); // scalar old-field guard retained
   assert(text.includes('call $p113_rt_array_pair(')); // exact fallback retained
  }else assert(!text.includes('p113a_heap_base'));
  if(loop)assert(text.slice(start+13).includes('jmp @p113_loop'));
  else assert(text.includes('ret %v_a\n'));
  report.controls.push({name,pass:true,textBytes:Buffer.byteLength(text),sha256:crypto.createHash('sha256').update(text).digest('hex')});
 }catch(e){report.controls.push({name,pass:false,error:String(e)});save();throw e;}
}
report.complete=true;report.count=report.controls.length;save();
process.stdout.write(JSON.stringify({complete:true,controls:report.count,report:path.join(out,'report.json')})+'\n');
