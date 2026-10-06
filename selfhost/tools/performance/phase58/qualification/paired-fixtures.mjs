// Root-supervised paired checked fixture acquisition; executes no generated output.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {stageChecked} from './checked-image.mjs';import {identity,verify} from '../../phase54/bootstrap/adapter.mjs';
const [baseline,candidate,catalogFile,outArg]=process.argv.slice(2);assert(baseline&&candidate&&catalogFile&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);assert(out.startsWith(path.join(root,'selfhost/build/phase58')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),pin=item=>{const row=identity(typeof item==='object'?item.file??item.path:item);if(typeof item==='object')assert.equal(row.sha256,item.sha256);if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
const catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogId.file,'utf8'));assert.equal(catalog.kind,'phase52-direct-semantic-catalog');assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert(catalog.cases.length>0&&catalog.cases.length<=8);
const report={kind:'phase58-private-paired-checked-acquisition',complete:false,passed:false,programsExecuted:false,catalog:catalogId,roles:{},cases:[],scope:'Fresh checked baseline/candidate fixture emissions through private ordinary drivers/caches. Independent generated-program oracles and activation are separate controller jobs.'};
const save=()=>fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 for(const file of [import.meta.filename,path.join(import.meta.dirname,'checked-image.mjs'),process.execPath])pin(file);
 const ids=new Set();for(const c of catalog.cases){assert(!ids.has(c.id)&&/^[a-zA-Z0-9_-]+$/.test(c.id));ids.add(c.id);}
 for(const [role,directory]of [['baseline',baseline],['candidate',candidate]]){
  const state=await stageChecked(path.resolve(directory),path.join(out,role,'project'));for(const item of state.inputs)pin(item);
  const rr=report.roles[role]={attempt:state.image.attempt,image:state.image,copies:state.copies,modules:{}};
  const compiler={kind:'checked-development-attempt',backend:'direct',callingContract:'upstream-compatible-direct-v1',upstreamCommit:catalog.upstreamCommit,...Object.fromEntries(['api','runtime','base','driver','directRuntime'].map(k=>[k,state.image[k]]))};
  for(const c of catalog.cases){
   const source=pin({file:path.resolve(path.dirname(catalogId.file),c.source.file??c.source.path),sha256:c.source.sha256});
   for(const input of c.auxiliary??[])pin({file:path.resolve(path.dirname(catalogId.file),input.file??input.path),sha256:input.sha256});
   const output=path.join(out,role,c.id+'.mjs'),receipt={kind:'bend-program-checked-emission',complete:false,input:source,catalog:catalogId,attempt:state.image.attempt,compiler,privateCopies:state.copies,producer:pin(import.meta.filename)};
   try{
    const result=await state.D.inspect(source.file,{mode:c.mode==='program'?'compile':'library',backend:'direct'}),{code,...observation}=result;receipt.observation=observation;
    assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(result.typeAccepted,true);assert.equal(result.exitCode,0);assert.equal(result.backend,'direct');assert.equal(typeof code,'string');
    receipt.emissionInputs=result.files.map(pin);assert(receipt.emissionInputs.some(x=>x.file===state.image.directRuntime.file));
    const prefix='import {createRequire as $jdCreateRequire} from "node:module";\nconst require=$jdCreateRequire(import.meta.url);\n',offset=code.startsWith(prefix)?prefix.length:0;assert(code.startsWith(fs.readFileSync(state.D.directRuntimePath,'utf8')+'\n',offset));
    fs.writeFileSync(output,code,{flag:'wx'});receipt.output=pin(output);receipt.complete=true;rr.modules[c.id]=output;
   }finally{fs.writeFileSync(output+'.json',JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});report.cases.push({id:c.id,role,receipt:pin(output+'.json'),complete:receipt.complete});save();}
  }
  rr.verification=await state.verifyFinal();save();
 }
 for(const item of inputs.values())verify(item);assert.equal(report.cases.length,catalog.cases.length*2);report.complete=report.passed=report.cases.every(x=>x.complete);report.inputsUnchanged=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,emissions:report.cases.length,error:report.error?.message}));
