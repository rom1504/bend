// Capture immutable compiler-owned renderer inputs. No host QBE construction.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [inputPath,outPath]=process.argv.slice(2);
assert(inputPath&&outPath);
const out=path.resolve(outPath);
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase144/'));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=p=>assert.deepEqual(pin(p.file),p);
const input=JSON.parse(fs.readFileSync(inputPath,'utf8'));
assert.equal(input.compilerSource.sha256,'a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e');
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(inputPath),...['api','compilerSource','source','base','carrier','expected'].map(k=>input[k])];
inputs.forEach(verify);fs.mkdirSync(out);
const report={kind:'phase144-native-render-fixture-input-capture',complete:false,inputs,fixtures:[],
 scope:'Actual checked Bend registry/cursor inputs and exact original wrapper bytes. Host selects data only; no QBE generation or native timing.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const tag=(v,n)=>{assert.equal(v?.$,n);return v};
const lists={P134Private:'functions',P134Legacy:'entries',P134Public:'segments'};
const samples={P134Private:[],P134Legacy:[],P134Public:[]};
const start=performance.now();
try{
 const api=(await import(pathToFileURL(input.api.file))).default;
 const preparation=tag(api.p88_cache_prepare(input.base.file,fs.readFileSync(input.base.file,'utf8'),fs.readFileSync(input.carrier.file,'utf8'),input.stamp),'P86PreparationReady');
 const plan=tag(api.p86_plan(preparation.seed,input.source.file,fs.readFileSync(input.source.file,'utf8')),'P86PlanReady');
 const emitted=tag(api.p134e_plan(plan),'P134Planned');
 let cursor=api.p134e_begin(emitted.plan),at=0,pieces=0;
 const expected=fs.readFileSync(input.expected.file,'utf8');
 while(true){
  while(lists[cursor.$]&&cursor[lists[cursor.$]].$==='Nil')cursor=cursor.next;
  const before=cursor,step=api.p134e_next(cursor);
  if(step.$==='P134Done')break;
  tag(step,'P134Piece');assert.equal(typeof step.text,'string');assert.equal(typeof step.legacy_end,'boolean');
  assert.equal(expected.slice(at,at+step.text.length),step.text);at+=step.text.length;
  if(step.legacy_end){assert.equal(expected[at],'\n');at++;}
  assert(++pieces<=10000,'Bounded ordinary-program capture only');
  if(lists[before.$]&&step.text.length&&Buffer.byteLength(step.text)<=256*1024){
   const head=tag(before[lists[before.$]],'Con').head;
   samples[before.$].push({kind:before.$,value:head,context:before.context,text:step.text,
     bytes:Buffer.byteLength(step.text),legacyEnd:step.legacy_end,ordinal:pieces-1});
  }
  cursor=step.next;
 }
 assert.equal(at,expected.length);report.completeParentProductExact=true;report.parentPieces=pieces;
 for(const [kind,all]of Object.entries(samples)){
  all.sort((a,b)=>a.bytes-b.bytes||a.ordinal-b.ordinal);
  const choices=[...new Set(all.length?[0,Math.floor((all.length-1)/2),all.length-1]:[])];
  for(const index of choices){
   const row=all[index],label=`${kind}-${index}-${row.ordinal}`;
   const data={kind:row.kind,value:row.value,context:row.context};
   const json=JSON.stringify(data,null,2)+'\n';assert(Buffer.byteLength(json)<=8*1024*1024,'Fixture data cap');
   const file=path.join(out,label+'.json'),oracle=path.join(out,label+'.expected');
   fs.writeFileSync(file,json);fs.writeFileSync(oracle,row.text);
   report.fixtures.push({name:label,kind,ordinal:row.ordinal,rank:index,totalFamily:all.length,
     data:pin(file),expected:pin(oracle),legacyEnd:row.legacyEnd,
     note:'Oracle is one actual wrapper text. Outer cursor legacy newline is deliberately outside this function-render boundary.'});
  }
 }
 assert(report.fixtures.length>0);inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack||error);process.exitCode=1;}
finally{report.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,fixtures:report.fixtures.length,error:report.error}));}
