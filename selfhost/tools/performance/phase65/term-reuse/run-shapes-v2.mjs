// Root-only supervised diagnostic. No timings from this program are benchmarks.
// node run.mjs PHASE65_PREPARATION_REPORT NEW_PHASE65_OUT CASE_ID [CASE_ID...]
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
import {instrument} from './instrument.mjs';import {makeObserver,symbol} from './observe-shapes-v2.mjs';import {controls} from './controls-shapes-v2.mjs';
const [prepArg,outArg,...wanted]=process.argv.slice(2);assert(prepArg&&outArg&&wanted.length);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const inputs=new Map();function pin(file,want){const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(x,inputs.get(x.file));inputs.set(x.file,x);return x}
const read=(f,w)=>{pin(f,w);return JSON.parse(fs.readFileSync(f,'utf8'))};
const report={kind:'phase65-unchanged-term-shape-diagnostic-v2',complete:false,pass:false,diagnosticOnly:true,productionQualified:false,rows:[],copies:[],scope:'Logical original-compiler work and conservative no-op eligibility, grouped by API. Observer never changes semantic results. Warm prepared derivative cache; request-local diagnostic caches reset per source. No runtime, clean compile-time, allocation-byte or qualified optimization claim.'};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n')}save();
try{
  for(const name of ['run-shapes-v2.mjs','observe-shapes-v2.mjs','controls-shapes-v2.mjs','run.mjs','observe.mjs','instrument.mjs','controls.mjs'])pin(path.join(import.meta.dirname,name));pin(process.execPath);
  const parent=read(prepArg);assert(parent.complete&&parent.pass);
  const prep=parent.preparations?.map(x=>x.observation).find(x=>x.role==='baseline')??parent;
  assert(prep.complete&&prep.pass&&prep.stage==='prepare');
  assert.equal(prep.image.api.sha256,'b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e');
  const cfg=read(prep.config.file,prep.config);assert.equal(pin(process.execPath).sha256,cfg.node.sha256);report.image=prep.image;report.preparation=identity(prepArg);
  const project=path.join(out,'project');
  for(const item of prep.copies){const before=pin(item.after.file,item.after),rel=path.relative(prep.project,before.file);assert(rel&&!rel.startsWith('..')&&!path.isAbsolute(rel));const file=path.join(project,rel);fs.mkdirSync(path.dirname(file),{recursive:true});fs.copyFileSync(before.file,file,fs.constants.COPYFILE_EXCL);report.copies.push({before,after:identity(file)})}
  for(const k of ['api','source','emission','checkedGenerator','base','runtime','directRuntime','driver'])pin(prep.image[k].file,prep.image[k]);
  const observer=makeObserver();globalThis[Symbol.for(symbol)]=observer;
  const derived=instrument(fs.readFileSync(prep.image.api.file,'utf8')),apiFile=path.join(project,'dist/term-reuse-api.mjs');fs.writeFileSync(apiFile,derived.output,{flag:'wx'});report.derivation={...derived.derivation,parent:prep.image.api,output:identity(apiFile)};save();
  for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
  process.env.BEND_TYPED_API=apiFile;process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');process.env.BEND_BASE=prep.image.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));assert.equal(D.apiPath,apiFile);
  const api=await D.loadApi();assert.equal(typeof api.subst,'function');assert.equal(typeof api.core_beta,'function');await D.prepareBase(api);assert.equal(await D.loadApi(),api);report.derivativeCachePrimed=true;
  report.controls=controls(api,observer);save();
  const ids=wanted[0]==='all'?cfg.cases.map(x=>x.id):wanted;assert.equal(new Set(ids).size,ids.length);
  for(const id of ids){
    const spec=cfg.cases.find(x=>x.id===id),oracle=prep.outputs.find(x=>x.id===id);assert(spec&&oracle?.oracle.pass,id);
    for(const x of [spec.source,...spec.files,...spec.emissionInputs,oracle.output])pin(x.file,x);
    observer.reset();observer.active(true);let result;try{result=await D.inspect(spec.source.file,{mode:'library',backend:'direct'})}finally{observer.active(false)}
    assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(Buffer.from(result.code).compare(fs.readFileSync(oracle.output.file)),0);
    for(const file of result.files)pin(file);report.rows.push({id,source:spec.source,rawBytesEqual:true,output:{sha256:hash(result.code),bytes:Buffer.byteLength(result.code)},counts:observer.snapshot()});save();console.log(JSON.stringify({id,pass:true,capped:observer.snapshot().capped}));
  }
  for(const x of inputs.values())assert.deepEqual(identity(x.file),x);assert.deepEqual(identity(report.derivation.output.file),report.derivation.output);
  report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1}finally{save()}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.rows.length,error:report.error}));
