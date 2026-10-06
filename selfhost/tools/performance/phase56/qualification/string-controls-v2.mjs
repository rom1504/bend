// Root-supervised focused gate. Each checked image gets a private ordinary driver/cache.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash} from '../../phase54/bootstrap/adapter.mjs';

const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&outArg,'string-controls-v1.mjs BASELINE_ATTEMPT CANDIDATE_ATTEMPT NEW_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase56')+path.sep));assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const begin=performance.now(),inputs=new Map(),copies=[];
const pin=file=>{const row=identity(file);if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(x=>x.isDirectory()?walk(path.join(dir,x.name)):[path.join(dir,x.name)]);
const report={kind:'phase56-string-definition-controls-v2',complete:false,pass:false,roles:{},observations:[],scope:'Primitive JavaScript String inputs, including arbitrary UTF-16 code units; no boxed strings or arbitrary builtin prototype-hook contract. All values/events are independent oracles. This gate separately checks ordinary source declarations and duplicate-Base refusal.'};
const progressFile=path.join(out,'progress.jsonl');fs.writeFileSync(progressFile,'',{flag:'wx'});
const progress=(role,event)=>fs.appendFileSync(progressFile,JSON.stringify({role,event,seconds:(performance.now()-begin)/1000})+'\n');
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parserBox={exports:{}};parserBox.module={exports:parserBox.exports};vm.runInNewContext(parserSource,parserBox);const acorn=parserBox.exports;assert.equal(typeof acorn.parse,'function');
const parse=code=>acorn.parse(code,{ecmaVersion:'latest',sourceType:'module'});
const write=(name,text)=>{const file=path.join(out,name);fs.writeFileSync(file,text,{flag:'wx'});return pin(file);};
const fixtures=[['values',path.join(import.meta.dirname,'string-values-v1.bend')],['user-name',path.join(import.meta.dirname,'string-user-name-v1.bend')],['duplicate',path.join(root,'tests/check/data_table_checked_000.bend')]];
for(const file of [import.meta.filename,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../../development/process.mjs',import.meta.url),new URL('../../../conformance/inventory.mjs',import.meta.url),process.execPath,...fixtures.map(x=>x[1])])pin(file);
report.predecessor=pin(new URL('./string-controls-v1.mjs',import.meta.url));
report.parser={version:acorn.version,sourceSha256:hash(Buffer.from(parserSource))};
async function stage(role,directory){
 const attempt=await verifyAttempt(directory);assert(attempt.checked);const attemptId=pin(path.join(directory,'attempt.json'));
 if(role==='baseline')assert.equal(attempt.api.sha256,'cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62');
 const project=path.join(out,role,'project');
 function copy(file,relative){const before=pin(file),target=path.join(project,relative);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(file,target,fs.constants.COPYFILE_EXCL);const after=pin(target);assert.equal(after.sha256,before.sha256);copies.push({before,after});return after;}
 for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])copy(path.join(attempt.snapshot.root,'tools',name+'.mjs'),'tools/'+name+'.mjs');
 copy(path.join(attempt.snapshot.root,'src/compiler.json'),'src/compiler.json');
 const runtime=copy(attempt.runtime.file,'src/runtime.mjs');
 for(const file of walk(path.join(attempt.snapshot.root,'src/runtime')))copy(file,path.relative(attempt.snapshot.root,file));
 const api=copy(attempt.api.file,'dist/api.mjs');pin(attempt.base.file);pin(attempt.bootstrapReport.file);
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
 process.env.BEND_TYPED_API=api.file;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=attempt.base.file;
 const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
 assert.equal(D.apiPath,api.file);assert(!fs.existsSync(path.join(project,'build/typed/cache')));
 const roleReport=report.roles[role]={attempt:attemptId,api,runtime,base:pin(attempt.base.file),driver:pin(path.join(project,'tools/typed-driver.mjs')),directRuntime:pin(D.directRuntimePath),emissions:[],modules:{}};
 for(const [id,source] of fixtures){
  progress(role,'compile-'+id);const result=await D.inspect(source,{mode:'library',backend:'direct'});const {code,...observation}=result;
  const receipt={source:pin(source),attempt:attemptId,observation,emissionInputs:(result.files??[]).map(pin)};
  roleReport.emissions.push(receipt);
  if(id==='duplicate'){assert.equal(result.status,'error');assert.match(result.diagnostic,/duplicate declaration: String\.eq/);continue;}
  assert.equal(result.status,'ok',result.diagnostic??JSON.stringify(observation));assert.equal(result.exitCode,0);assert.equal(result.checked,true);assert.equal(result.typeAccepted,true);assert.equal(result.backend,'direct');assert.equal(typeof code,'string');
  assert(receipt.emissionInputs.some(x=>x.file===roleReport.directRuntime.file));assert(code.startsWith(fs.readFileSync(D.directRuntimePath,'utf8')+'\n'));
  parse(code);receipt.output=write(role+'-'+id+'.mjs',code);roleReport.modules[id]=receipt.output;
 }
 await verifyAttempt(directory);
 roleReport.cacheFiles=walk(path.join(project,'build/typed/cache')).map(pin);
 for(const row of roleReport.cacheFiles){const c=JSON.parse(fs.readFileSync(row.file,'utf8'));assert.equal(c.compilerSha256,api.sha256);assert.equal(c.baseSha256,attempt.base.sha256);assert.equal(c.validatedBy,'check_book');assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));}
 return roleReport;
}
function shape(row,role){
 const code=fs.readFileSync(row.modules.values.file,'utf8'),tree=parse(code);
 const defs=tree.body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name==='$jd$String_46_eq');assert.equal(defs.length,1);
 const fn=defs[0],body=fn.body.body;
 const strict=body.length===1&&body[0].type==='ReturnStatement'&&body[0].argument?.type==='BinaryExpression'&&body[0].argument.operator==='===';
 assert.equal(strict,role==='candidate','Exact native definition specialization');
 if(strict){assert.equal(body[0].argument.left.name,fn.params[0].name);assert.equal(body[0].argument.right.name,fn.params[1].name);}
 const user=parse(fs.readFileSync(row.modules['user-name'].file,'utf8')).body.filter(n=>n.type==='FunctionDeclaration'&&n.id?.name==='$jd$String_46_eq');assert.equal(user.length,1);assert(!fs.readFileSync(row.modules['user-name'].file,'utf8').slice(user[0].start,user[0].end).includes('==='));
 return {code,fn,strict,nativeDefinitionSha256:hash(Buffer.from(code.slice(fn.start,fn.end)))};
}
// Equality oracle compares integer code units without using String.eq or JavaScript === on the strings.
const unitEqual=(a,b)=>a.length===b.length&&Array.from({length:a.length},(_,i)=>a.charCodeAt(i)===b.charCodeAt(i)).every(Boolean);
const words=['','a','b','\0','a\0b','a\0c','λ','🧭','é','e\u0301','\ud800','\ud801','\udc00','\udc01','\ud800\udc00','\ud800x','x\udc00','\udc00\ud800','🧭λ\0','\ufffd','a'.repeat(1024),'a'.repeat(1023)+'b'];
function observe(api,id){
 const events=[],f=x=>{events.push(['f',x]);return '';},g=x=>{events.push(['g',x]);return '';},n=x=>{events.push(['g',x]);return 7;};
 const left=x=>{events.push(['f',x]);throw Error('left');},right=x=>{events.push(['g',x]);throw Error('right');};
 let value,error;
 try{
  if(id==='callback-order')value=api.callbacks(f,g,3);
  else if(id==='left-throw')value=api.callbacks(left,g,3);
  else if(id==='right-throw')value=api.callbacks(f,right,3);
  else if(id==='packed-order')value=api.packed(f,n,3);
  else if(id==='packed-later-throw')value=api.packed(f,right,3);
  else if(id==='packed-earlier-throw')value=api.packed(left,n,3);
  else {const throws=id==='partial-throw';const box=api.deferred(throws?left:f,3);assert.deepEqual(events,[],'Supplied partial expression stays deferred');events.push(['created']);value=api.apply(box,'');}
 }catch(e){error=e.message;}
 return {events,...(error?{error}:{value})};
}
const controls=[['callback-order',{events:[['f',3],['g',3]],value:true}],['left-throw',{events:[['f',3]],error:'left'}],['right-throw',{events:[['f',3],['g',3]],error:'right'}],['packed-order',{events:[['g',3],['f',3]],value:{$:'Tuple',fst:true,snd:7}}],['packed-later-throw',{events:[['g',3]],error:'right'}],['packed-earlier-throw',{events:[['g',3],['f',3]],error:'left'}],['partial-deferred',{events:[['created'],['f',3]],value:true}],['partial-throw',{events:[['created'],['f',3]],error:'left'}]];
try{
 const roles={};for(const [role,directory]of [['baseline',baselineArg],['candidate',candidateArg]])roles[role]=await stage(role,path.resolve(directory));
 assert.equal(roles.baseline.directRuntime.sha256,roles.candidate.directRuntime.sha256);assert.equal(roles.baseline.driver.sha256,roles.candidate.driver.sha256);assert.equal(roles.baseline.base.sha256,roles.candidate.base.sha256);
 const apis={};for(const role of ['baseline','candidate']){report.roles[role].shape=shape(roles[role],role);const {code,fn}=report.roles[role].shape;delete report.roles[role].shape.code;delete report.roles[role].shape.fn;apis[role]=(await import(pathToFileURL(roles[role].modules.values.file))).default;const user=(await import(pathToFileURL(roles[role].modules['user-name'].file))).default;assert.deepEqual(user.witness(),{$:'Different'});report.observations.push({id:'user-native-name-'+role,value:{$:'Different'}});}
 for(let i=0;i<words.length;i++)for(let j=0;j<words.length;j++){const expected=unitEqual(words[i],words[j]),values={};for(const role of ['baseline','candidate']){values[role]=apis[role].equal(words[i],words[j]);assert.equal(values[role],expected,role+' string pair '+i+','+j);}report.observations.push({id:'units-'+i+'-'+j,inputs:[words[i],words[j]],expected,values});}
 for(const [id,expected]of controls){const values={};for(const role of ['baseline','candidate']){values[role]=observe(apis[role],id);assert.deepEqual(values[role],expected,role+' '+id);}report.observations.push({id,expected,values});}
 // Separate untimed activation derivative; original modules supplied every value/order observation above.
 const source=fs.readFileSync(roles.candidate.modules.values.file,'utf8'),fn=parse(source).body.find(n=>n.type==='FunctionDeclaration'&&n.id?.name==='$jd$String_46_eq');
 const derived=source.slice(0,fn.body.start+1)+'++$stringEqEntries;'+source.slice(fn.body.start+1)+'\nlet $stringEqEntries=0;export const stringEqEntries=()=>$stringEqEntries;\n';parse(derived);
 const derivative=write('candidate-values-counter.mjs',derived),m=await import(pathToFileURL(derivative.file));assert.equal(m.stringEqEntries(),0);assert.equal(m.default.equal('🧭','🧭'),true);assert.equal(m.stringEqEntries(),1);assert.deepEqual(observe(m.default,'packed-order'),controls[3][1]);assert.equal(m.stringEqEntries(),2);assert.deepEqual(observe(m.default,'partial-deferred'),controls[6][1]);assert.equal(m.stringEqEntries(),3);
 report.activation={derivative,original:roles.candidate.modules.values,entries:3,scope:'Only native definition entry is counted; diagnostic derivative is not timing evidence.'};
 for(const row of inputs.values())verify(row);await verifyAttempt(path.resolve(baselineArg));await verifyAttempt(path.resolve(candidateArg));
 report.complete=true;report.pass=true;report.counts={stringPairs:words.length**2,orderedControls:controls.length,userNativeName:2,duplicateRefusals:2,activationEntries:3};
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally{report.inputs=[...inputs.values()];report.copies=copies;report.seconds=(performance.now()-begin)/1000;report.progress=identity(progressFile);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error?.message}));}
