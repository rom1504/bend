// Root runs this under the existing CPU3 resource guard. No clean timings.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
import {instrument,symbol} from './instrument.mjs';
const [prepArg,outArg,...wanted]=process.argv.slice(2);assert(prepArg&&outArg&&wanted.length);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase62')+path.sep));assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const inputs=new Map();function pin(file,want){const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(x,inputs.get(x.file));inputs.set(x.file,x);return x}
const read=(f,w)=>{pin(f,w);return JSON.parse(fs.readFileSync(f,'utf8'))};
const report={kind:'phase62-diagnostic-logical-work-counts',complete:false,pass:false,diagnosticOnly:true,productionQualified:false,rows:[],derivations:[],copies:[],scope:'Operation counts only. Derivative Base cache is primed on its real API identity before counters reset. Requests reuse one process; output bytes are checked against qualified uninstrumented output. Instrumented times are not performance claims.'};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n')};save();
try{
 pin(import.meta.filename);pin(new URL('./instrument.mjs',import.meta.url).pathname);report.node=pin(process.execPath);report.nodeVersion=process.version;
 const prep=read(prepArg);assert(prep.complete&&prep.pass&&prep.stage==='prepare'&&prep.role==='candidate');
 assert.equal(prep.image.api.sha256,'23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477');
 const cfg=read(prep.config.file,prep.config);report.preparation=identity(prepArg);report.image=prep.image;
 const project=path.join(out,'project');
 for(const item of prep.copies){const before=pin(item.after.file,item.after),rel=path.relative(prep.project,before.file);assert(rel&&!rel.startsWith('..')&&!path.isAbsolute(rel));const file=path.join(project,rel);fs.mkdirSync(path.dirname(file),{recursive:true});fs.copyFileSync(before.file,file,fs.constants.COPYFILE_EXCL);report.copies.push({before,after:identity(file)})}
 for(const k of ['api','base','runtime','directRuntime','driver'])pin(prep.image[k].file,prep.image[k]);
 const control={modules:{}};globalThis[Symbol.for(symbol)]=control;
 const derived=instrument(fs.readFileSync(prep.image.api.file,'utf8'),'bend'),apiFile=path.join(project,'dist/work-counts-api.mjs');fs.writeFileSync(apiFile,derived.output,{flag:'wx'});report.derivations.push({...derived.derivation,parent:prep.image.api,output:identity(apiFile)});
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=apiFile;process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');process.env.BEND_BASE=prep.image.base.file;
 const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));assert.equal(D.apiPath,apiFile);
 const api=await D.loadApi();await D.prepareBase(api);report.derivativeCachePrimed=true;save();
 const tsDir=path.join(out,'upstream/bend2');fs.mkdirSync(tsDir,{recursive:true});
 for(const [name,role] of [['bend.ts','theory'],['comp.ts','backend']]){const parent=pin(path.join(cfg.upstream,'bend2',name)),d=instrument(fs.readFileSync(parent.file,'utf8'),role),file=path.join(tsDir,name);fs.writeFileSync(file,d.output,{flag:'wx'});report.derivations.push({...d.derivation,parent,output:identity(file)})}
 // Relative BASE_BEND lookup must see the exact pinned bytes. No source paths are rewritten.
 const base=path.join(tsDir,'base.bend');fs.copyFileSync(prep.image.base.file,base,fs.constants.COPYFILE_EXCL);report.copies.push({before:prep.image.base,after:identity(base)});
 const B=await import(pathToFileURL(path.join(tsDir,'bend.ts'))),C=await import(pathToFileURL(path.join(tsDir,'comp.ts')));
 const ids=wanted[0]==='all'?cfg.cases.map(x=>x.id):wanted;assert.equal(new Set(ids).size,ids.length);
 function reset(phase){for(const m of Object.values(control.modules)){m.reset();m.phase(phase)}}
 function snap(){return Object.fromEntries(Object.entries(control.modules).map(([k,m])=>[k,{names:m.names,phases:m.snapshot()}]))}
 for(const id of ids){const spec=cfg.cases.find(x=>x.id===id),oracle=prep.outputs.find(x=>x.id===id);assert(spec&&oracle?.oracle.pass);for(const x of [spec.source,...spec.files,...spec.emissionInputs,oracle.output,spec.references.typescript])pin(x.file,x);
  reset('load');const result=await D.inspect(spec.source.file,{mode:'library',backend:'direct'});assert.equal(result.status,'ok');assert.equal(result.checked,true);assert.equal(Buffer.from(result.code).compare(fs.readFileSync(oracle.output.file)),0);const bend=snap().bend;
  reset('load');const book=B.book_nil();await B.book_load(book,spec.source.file,'',new Map());for(const m of Object.values(control.modules))m.phase('check');B.book_valid(book);assert.equal(book.hols,0);for(const m of Object.values(control.modules))m.phase('emit');const code=C.js_lib(book,true);assert.equal(Buffer.from(code).compare(fs.readFileSync(spec.references.typescript.file)),0);const counts=snap();
  report.rows.push({id,source:spec.source,bendOutput:{sha256:hash(result.code),bytes:Buffer.byteLength(result.code)},typescriptOutput:{sha256:hash(code),bytes:Buffer.byteLength(code)},bend,theory:counts.theory,backend:counts.backend,rawBytesEqual:true});save();console.log(JSON.stringify({id,pass:true}));
 }
 for(const x of inputs.values())assert.deepEqual(identity(x.file),x);for(const d of report.derivations)assert.deepEqual(identity(d.output.file),d.output);
 report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1}finally{save()}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.rows.length,error:report.error}));
