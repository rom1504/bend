// Exact old/new structure, errors and rendered products. No target IR execution.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import * as S from './support.mjs';
const a=S.options();for(const k of ['api','fixtures','capture','out'])assert(a[k],'Missing --'+k);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(import.meta.dirname,'support.mjs')),S.pin(a.fixtures),S.pin(a.capture)];
const report={kind:'phase148-unit-controls',version:1,complete:false,passed:false,inputs,rows:[],scope:'Full structured scalar equality, exact independent admission diagnostics, complete optimized direct rendering; no malformed code executed.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 const checked=await S.checked(a.api),api=checked.api;inputs.push(...checked.inputs);report.api=checked.receipt.api;report.source=checked.receipt.source;
 const fixtures=S.read(a.fixtures),capture=S.read(a.capture);assert(fixtures.kind==='phase148-independent-unit-controls'&&fixtures.complete);
 assert(capture.kind==='phase147-verifier-input-capture'&&capture.complete);
 function packed(fn){const roundtrip=api.p148_pack(fn);assert.equal(roundtrip.$,'P148Good','Actual function refused packing: '+JSON.stringify(roundtrip));assert.deepEqual(api.p148_unpack(roundtrip),fn,'Complete encode/decode');
  const fresh=api.p148_pack(fn);assert.equal(fresh.$,'P148Good');return fresh;}
 function census(unit){const{used,valueUsed,nameUsed}=unit.tape;for(const value of [used,valueUsed,nameUsed])assert(Number.isSafeInteger(value)&&value>=0);
  return{used,valueUsed,nameUsed,factCellsRequested:16*nameUsed,factCellsRounded:2**Math.ceil(Math.log2(Math.max(1,16*nameUsed)))};}
 function admission(name,fn,ctx,expected){
  const original=api.p113e_function(fn,ctx.ids,ctx.ready),current=api.p147d_function(fn,ctx.ids,ctx.ready);
  assert.equal(original,expected,name+' fixed original diagnostic');assert.equal(current,expected,name+' current diagnostic');
  const unit=packed(fn),next=api.p148v_function(unit,ctx.ids,ctx.ready);assert.equal(next,expected,name+' compact diagnostic');
  const returned=api.p148v_check(packed(fn),ctx.ids,ctx.ready);assert.equal(returned.$,'P148Checked');assert.equal(returned.error,expected,name+' consuming diagnostic');
  assert.deepEqual(api.p148_unpack(returned.unit),fn,name+' returned admission unit');
  report.rows.push({name,kind:'admission',original,current,candidate:next,passed:true});save();
 }
 function scalar(name,fn,expected){
  const before=JSON.stringify(fn),old=api.p113k_function(fn);if(expected)assert.deepEqual(old,expected,name+' literal scalar oracle');
  const fresh=packed(fn),packedCensus=census(fresh);
  // The optimizer consumes its tape. Only copied scalar metadata survives here.
  const unit=api.p148o_function(fresh);assert.equal(unit.$,'P148Good',name+' optimizer refused');
  const optimizedCensus=census(unit),next=api.p148_unpack(unit);assert.deepEqual(next,old,name+' whole optimized structure');assert.equal(JSON.stringify(fn),before,name+' source mutated');
  return{old,next,packedCensus,optimizedCensus};
 }
 function optimizedAdmission(name,fn,ctx,expected,optimized){
  const next=api.p148v_function(api.p148o_function(packed(fn)),ctx.ids,ctx.ready);assert.equal(next,expected,name+' optimized adapter diagnostic');
  const returned=api.p148v_check(api.p148o_function(packed(fn)),ctx.ids,ctx.ready);assert.equal(returned.$,'P148Checked');assert.equal(returned.error,expected,name+' optimized consuming diagnostic');
  assert.deepEqual(api.p148_unpack(returned.unit),optimized,name+' complete consuming pipeline');
 }
 for(const source of fixtures.admissionSources){S.verify(source);inputs.push(source);for(const row of S.read(source.file).cases.filter(x=>x.kind==='direct')){
  admission(row.name,row.function,S.context(api,row.segments,row.constructors,row.ready),row.expectedError);
 }}
 for(const row of fixtures.cases){const value=scalar(row.name,row.function,row.expectedOptimized);const ctx=S.context(api,S.list([]),S.list([]),S.list([]));
  assert.equal(api.p113e_function(value.old,ctx.ids,ctx.ready),row.expectedError);optimizedAdmission(row.name,row.function,ctx,row.expectedError,value.old);
  report.rows.push({name:row.name,kind:'literal-scalar',packed:value.packedCensus,optimized:value.optimizedCensus,passed:true});save();}
 for(const family of capture.rows){S.verify(family.data);inputs.push(family.data);const packet=S.read(family.data.file);assert(packet.complete&&packet.originalAccepted);
  const segments=S.list(packet.segments),constructors=S.list(packet.constructors),rids=S.renderIds(api,segments,constructors);
  for(const row of packet.direct){const ctx=S.context(api,segments,constructors,S.list(packet.directHeaders.slice(0,row.index))),name=family.name+'/'+row.index;
   admission(name,row.function,ctx,'');const value=scalar(name,row.function);
   assert.equal(api.p147d_function(value.old,ctx.ids,ctx.ready),'');assert.equal(api.p113e_function(value.old,ctx.ids,ctx.ready),'');
   optimizedAdmission(name,row.function,ctx,'',value.old);assert.equal(api.p113e_function(value.next,ctx.ids,ctx.ready),'');
   const old=api.p113e_private(value.old,rids),next=api.p113e_private(value.next,rids);
   assert.equal(typeof old,'string');assert(old.length&&!old.includes('INVALID_'));assert.equal(next,old,name+' complete rendered output');
   const oldFile=path.join(out,family.name+'-'+row.index+'-old.ssa'),newFile=path.join(out,family.name+'-'+row.index+'-new.ssa');
   fs.writeFileSync(oldFile,old,{flag:'wx'});fs.writeFileSync(newFile,next,{flag:'wx'});
   report.rows.push({name,kind:'actual-scalar-render',family:family.name,index:row.index,functionName:row.function.name,
    capture:family.data,census:row.census,packed:value.packedCensus,optimized:value.optimizedCensus,old:S.pin(oldFile),candidate:S.pin(newFile),structureExact:true,textExact:true,passed:true});save();
  }
 }
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.length,error:report.error}))}
