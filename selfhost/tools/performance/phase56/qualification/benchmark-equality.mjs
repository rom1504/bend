// Root-supervised B2 checking/emission; no generated benchmark program is executed.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {setup} from '../bootstrap/setup-v2.mjs';
import {identity,verify} from '../../phase54/bootstrap/adapter.mjs';
const [pinsFile,manifestFile,outArg]=process.argv.slice(2);
assert(pinsFile&&manifestFile&&outArg,'benchmark-equality.mjs IMAGE_PINS SELECTED_B1_MANIFEST NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const started=performance.now(),inputs=new Map(),raw=new Map();
const pin=(item,base='.')=>{const file=typeof item==='string'||item instanceof URL?item:path.resolve(base,item.file??item.path),row=identity(file);if(typeof item==='object'&&!(item instanceof URL)){assert.equal(row.sha256,item.sha256);if(item.bytes!==undefined)assert.equal(fs.statSync(row.file).size,item.bytes);}if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
const read=(item,base)=>JSON.parse(fs.readFileSync(pin(item,base).file,'utf8'));
const report={kind:'phase56-b2-benchmark-byte-equality',complete:false,pass:false,programsExecuted:false,emissions:[],points:[],scope:'B2 freshly checks and emits all 23 sources through the private ordinary driver. Raw modules and the unchanged named-field row observer must equal selected B1 exactly. This transfers only evidence applicable to those selected B1 bytes; no historical speed result or new timing is inferred.'};
const progressFile=path.join(out,'progress.jsonl');fs.writeFileSync(progressFile,'',{flag:'wx'});
const progress=(phase,event,extra={})=>fs.appendFileSync(progressFile,JSON.stringify({phase,event,seconds:(performance.now()-started)/1000,...extra})+'\n');
try{
 for(const f of [import.meta.filename,new URL('../bootstrap/setup-v2.mjs',import.meta.url),new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),process.execPath])pin(f);
 const selected=await setup(pinsFile,path.join(out,'image'),{progress});report.image=selected.image;report.subject=selected.subject;report.generator=selected.emission.generator;
 for(const row of selected.inputs)pin(row);for(const row of selected.copies)pin(row.after);
 const origin=path.dirname(path.resolve(manifestFile)),manifest=read(manifestFile);report.reference=pin(manifestFile);
 assert.equal(manifest.kind,'bend-program-bundle');assert.equal(manifest.complete,true);assert.equal(manifest.cases.length,45);assert.equal(manifest.comparisonContract,'upstream-compatible-direct-v1');
 const prep=read(manifest.preparation,origin);assert.equal(prep.kind,'bend-program-preparation');assert.equal(prep.complete,true);assert.equal(prep.backend,'direct');assert.equal(prep.sources.length,23);
 const catalog=read(prep.catalog);assert.equal(pin(prep.catalog).sha256,manifest.catalogSha256);assert.equal(catalog.upstreamCommit,manifest.upstreamCommit);
 assert.deepEqual(manifest.cases.map(c=>c.id),catalog.sets.full);assert.equal(new Set(manifest.cases.map(c=>c.sourceSha256)).size,23);
 const compiler=manifest.roles.candidate.compiler;assert.equal(compiler.backend,'direct');assert.equal(compiler.callingContract,'upstream-compatible-direct-v1');assert.equal(compiler.kind,'checked-development-attempt');
 for(const key of ['api','runtime','base','driver','directRuntime'])pin(compiler[key]);
 assert.equal(compiler.api.sha256,selected.emission.generator.api.sha256);assert.equal(compiler.runtime.sha256,selected.image.runtime.sha256);assert.equal(compiler.base.sha256,selected.image.base.sha256);assert.equal(compiler.driver.sha256,selected.image.driver.sha256);assert.equal(compiler.directRuntime.sha256,selected.image.directRuntime.sha256);
 const modules=path.join(out,'modules');fs.mkdirSync(modules);
 for(const item of prep.sources){
  const receipt=read(item.emission,origin);assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.deepEqual(receipt.compiler,compiler);assert.equal(pin(receipt.attempt).sha256,selected.subject.attempt.sha256);
  const source=pin(item.source);assert.equal(pin(receipt.input).sha256,source.sha256);assert.equal(pin(receipt.catalog).sha256,manifest.catalogSha256);const reference=pin(receipt.output);for(const row of receipt.emissionInputs)pin(row);
  const expectedCases=catalog.cases.filter(c=>c.source.sha256===source.sha256);assert(expectedCases.length);for(const c of expectedCases)assert.equal(pin(c.source,path.dirname(pin(prep.catalog).file)).file,source.file);assert(!raw.has(source.sha256));
  progress(path.basename(source.file),'start');const begin=performance.now(),result=await selected.D.inspect(source.file,{mode:'library',backend:'direct'}),{code,...observation}=result;
  const row={source,reference,checkedB1Receipt:pin(item.emission,origin),observation,seconds:(performance.now()-begin)/1000};report.emissions.push(row);
  assert.equal(result.status,'ok',result.diagnostic??JSON.stringify(observation));assert.equal(result.checked,true);assert.equal(result.typeAccepted,true);assert.equal(result.exitCode,0);assert.equal(result.backend,'direct');assert.equal(typeof code,'string');
  row.emissionInputs=result.files.map(f=>pin(f));assert(row.emissionInputs.some(x=>x.file===selected.image.directRuntime.file));assert(code.startsWith(fs.readFileSync(selected.D.directRuntimePath,'utf8')+'\n'));
  const target=path.join(modules,path.basename(reference.file));fs.writeFileSync(target,code,{flag:'wx'});row.output=pin(target);row.byteEqual=fs.readFileSync(reference.file).equals(fs.readFileSync(target));assert(row.byteEqual,'B2 differs: '+source.file);raw.set(source.sha256,row);progress(path.basename(source.file),'complete',{seconds:row.seconds});
 }
 for(const c of manifest.cases){
  const expected=catalog.cases.find(x=>x.id===c.id);assert.deepEqual(c.point,expected.point);assert.equal(c.sourceSha256,expected.source.sha256);const row=raw.get(c.sourceSha256);assert(row);let output=row.output;
  if(expected.adapter){assert.equal(expected.adapter,'generic-row');const source=fs.readFileSync(row.output.file,'utf8'),marker='export default ';assert.equal(source.split(marker).length,2);const adapted=source.replace(marker,'const $Owned_exports = ')+'\nexport default {...$Owned_exports,bench:(n,seed)=>{const st=$Owned_exports["row.probe"](n,seed);return JSON.stringify([st.a,st.b,st.prev,st.cur]);}};\n';const target=path.join(modules,path.basename(row.output.file,'.mjs')+'-observed.mjs');assert(!fs.existsSync(target));fs.writeFileSync(target,adapted,{flag:'wx'});output=pin(target);}
  const reference=pin(c.modules.candidate,origin);assert.equal(output.sha256,reference.sha256);report.points.push({id:c.id,sourceSha256:c.sourceSha256,point:c.point,output,reference,byteEqual:true});
 }
 assert.equal(raw.size,23);assert.equal(new Set(report.points.map(x=>x.output.sha256)).size,24);assert.equal(prep.adapters.length,1);const adapter=prep.adapters[0];assert.equal(adapter.kind,'complete-generic-row-serialization');assert.equal(adapter.callableContract,'upstream-compatible-direct-v1');pin(adapter.raw,origin);pin(adapter.adapted,origin);
 report.finalVerification=await selected.verifyFinal();for(const row of inputs.values())verify(row);report.complete=true;report.pass=true;report.counts={freshCheckedSources:23,rawByteEqualModules:23,pointByteEqual:45,uniquePointModules:24,observerModules:1};
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally{report.inputs=[...inputs.values()];report.seconds=(performance.now()-started)/1000;report.progress=identity(progressFile);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,seconds:report.seconds,error:report.error?.message}));}
