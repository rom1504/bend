// Root executes this after checked acquisition. No compiler or source rewriting.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {pathToFileURL} from 'node:url';
import {identity,verify,hash} from '../../phase54/bootstrap/adapter.mjs';
import {verifyAttempt} from '../../../development/workflow.mjs';

const [baseline,candidate,typescript,outArg]=process.argv.slice(2);
assert(baseline&&candidate&&typescript&&outArg,'controls-v3.mjs BASELINE_REACH_MODULE CANDIDATE_SHARED_MODULE TS_MODULE NEW_OUT');
const out=path.resolve(outArg),root=path.resolve(import.meta.dirname,'../../../../..');
assert(out.startsWith(path.join(root,'selfhost/build/phase58')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
assert.equal(process.version,'v24.18.0');
const inputs=new Map(),pin=file=>{const row=identity(file);if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
const catalogFile=path.join(import.meta.dirname,'catalog-v2.json'),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert.equal(catalog.cases.length,2);
const fixture=catalog.cases[0],source=pin(path.join(import.meta.dirname,fixture.source.path));assert.equal(source.sha256,fixture.source.sha256);
const shadowFixture=catalog.cases[1],shadowSource=pin(path.join(import.meta.dirname,shadowFixture.source.path));assert.equal(shadowSource.sha256,shadowFixture.source.sha256);
for(const file of [import.meta.filename,catalogFile,process.execPath,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),new URL('../../../development/workflow.mjs',import.meta.url)])pin(file);
for(const [name,sha256]of [["controls-v1.mjs", "1f6c15a131d94b14466d73fe2370c585163bc91ddb93b518fb17b2465dcefd61"], ["catalog-v1.json", "8ec51e13e461508956bddc8324339ee5f73086c573c7633f926bda168342b7de"], ["non-native-v1.bend", "ab1c148529ba3eac698679bf7b76de68c49eb680ea6e888bef71be1f0afe5790"]])assert.equal(pin(path.join(import.meta.dirname,name)).sha256,sha256);
for(const [name,sha256]of [['controls-v2.mjs','1e78aef0f9e1dd6d31dc4e84dc2d70657f535dfdba84015d6dba8f53da6ad44e'],['catalog-v2.json','5977f9481cf8c9a04dced3b154225021fdc8ed2df950b45113fe3b638b9975d8']])assert.equal(pin(path.join(import.meta.dirname,name)).sha256,sha256);
const attempts=new Map();
const producers={direct:{file:path.resolve(import.meta.dirname,'../qualification/paired-fixtures-v2.mjs'),sha256:'6a2947f7a3c9fd84f7a78215c607fd5f90773e1edddf31376828d2d1f7fe0fe7'},typescript:{file:path.resolve(import.meta.dirname,'../../phase52/emit-worker-v2.mjs'),sha256:'f730abcde7203c61339f4eafefa144bc5c01031d5a1936c88d493afd5fe2d4a1'}};
for(const row of Object.values(producers))assert.deepEqual(pin(row.file),row);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const box={exports:{}};box.module={exports:box.exports};vm.runInNewContext(parserSource,box);const parse=code=>box.exports.parse(code,{ecmaVersion:'latest',sourceType:'module'});
const walk=(n,f)=>{if(!n||typeof n!=='object')return;f(n);for(const v of Object.values(n)){if(Array.isArray(v))for(const x of v)walk(x,f);else if(v&&typeof v==='object')walk(v,f);}};
const report={kind:'phase58-literal-choice-controls-v3',complete:false,pass:false,roles:{},observations:[],activation:[],scope:'Checked source, primitive scalar host inputs, arbitrary source callbacks and standard builtins. Private trampoline/closure packaging and inherited Function.prototype j/f hooks are not public invariants.'};
const started=performance.now();
const encode=x=>typeof x==='bigint'?{$bigint:String(x)}:x&&typeof x==='object'?Object.fromEntries(Object.entries(x).map(([k,v])=>[k,encode(v)])):x;
function decode(x,events){if(x&&typeof x==='object'){if('$bigint'in x)return BigInt(x.$bigint);if('$callback'in x){assert.equal(x.$callback,'plus7');return n=>{events.push(['callback',n]);return (n+7)>>>0;};}return Object.fromEntries(Object.entries(x).map(([k,v])=>[k,decode(v,events)]));}return x;}
function runCase(api,test){const events=[];let value=api[test.exportName],error;try{for(const group of test.groups)value=value(...group.map(x=>decode(x,events)));}catch(e){error=e;}
 if(test.expectedError){assert.notEqual(error,undefined);assert(String(error?.message??error).includes(test.expectedError));}
 else{if(error!==undefined)throw error;assert.deepEqual(encode(value),test.expected,test.id);}
 assert.deepEqual(events,test.expectedEvents??[],test.id+' events');return {value:test.expectedError?null:encode(value),error:error===undefined?null:String(error?.message??error),events};}
function hostCases(api){
 const rows=[];for(const b of [false,true]){const events=[],a=api.nonliteral(b,u=>{assert.deepEqual(u,{$:'Unit'});events.push('yes');return 31;},u=>{assert.deepEqual(u,{$:'Unit'});events.push('no');return 37;});assert.equal(a,b?31:37);assert.deepEqual(events,[b?'yes':'no']);rows.push({id:'nonliteral-'+b,value:a,events});}
 const a=api.unit_value(true),b=api.unit_value(false);assert.deepEqual(a,{$:'Unit'});assert.deepEqual(b,{$:'Unit'});assert.notEqual(a,b);rows.push({id:'fresh-unit',pass:true});
 const saved=api.captured(true,17),other=api.captured(false,90);assert.equal(other(3),87);assert.equal(saved(8),25);rows.push({id:'capture-survives-later-call',pass:true});
 for(const where of ['probe','yes','no']){const sentinel={where},events=[];let caught;const x=where==='no'?4:3;
  const call=(name,n)=>{events.push([name,n]);if(name===where)throw sentinel;return n+7;};
  try{api.observed(n=>call('probe',n),n=>call('yes',n),n=>call('no',n),x);}catch(e){caught=e;}
  assert.equal(caught,sentinel);assert.deepEqual(events,where==='probe'?[['probe',3]]:[['probe',x],[where,x+(where==='yes'?100:200)]]);rows.push({id:'throw-'+where,events,identity:true});}
 {const events=[],sentinel={later:true};let caught;try{api.composed(n=>{events.push(['probe',n]);return 8;},n=>{events.push(['later',n]);throw sentinel;});}catch(e){caught=e;}assert.equal(caught,sentinel);assert.deepEqual(events,[['probe',1],['later',2]]);rows.push({id:'sibling-prefix-throw',events,identity:true});}
 {const events=[];const value=api.observed(n=>{events.push(['probe',n]);assert.equal(api.countdown(32n,5),37);return 10;},n=>{events.push(['yes',n]);return api.selected(false,n);},()=>{throw Error('unselected callback');},3);assert.equal(value,110);assert.deepEqual(events,[['probe',3],['yes',103]]);rows.push({id:'source-callback-reentry',value,events});}
 return rows;
}
async function load(role,file,source){
 const module=pin(file),receiptId=pin(file+'.json'),receipt=JSON.parse(fs.readFileSync(file+'.json','utf8'));
 assert.equal(receipt.kind,'bend-program-checked-emission');assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert.equal(receipt.input.sha256,source.sha256);assert.equal(pin(receipt.input.file??receipt.input.path).file,source.file);assert.equal(receipt.output.sha256,module.sha256);
 assert.equal(receipt.catalog.sha256,pin(catalogFile).sha256);assert.equal(pin(receipt.catalog.file??receipt.catalog.path).file,pin(catalogFile).file);
 const producer=producers[role==='typescript'?'typescript':'direct'];assert.equal(receipt.producer.sha256,producer.sha256);assert.equal(pin(receipt.producer.file??receipt.producer.path).file,producer.file);
 if(role!=='typescript'){
  assert.equal(receipt.compiler.kind,'checked-development-attempt');assert.equal(receipt.compiler.backend,'direct');assert.equal(receipt.observation.backend,'direct');assert.equal(receipt.observation.typeAccepted,true);assert.equal(receipt.observation.exitCode,0);
  const aid=pin(receipt.attempt.file);assert.equal(aid.sha256,receipt.attempt.sha256);
  if(!attempts.has(aid.file))attempts.set(aid.file,await verifyAttempt(path.dirname(aid.file)));const attempt=attempts.get(aid.file);
  for(const key of ['api','runtime','base'])assert.equal(receipt.compiler[key].sha256,attempt[key].sha256);
  assert.equal(receipt.compiler.driver.sha256,pin(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')).sha256);
  assert.equal(receipt.compiler.directRuntime.sha256,pin(path.join(attempt.snapshot.root,'src/runtime/js/direct.mjs')).sha256);
  for(const copy of receipt.privateCopies){assert.equal(pin(copy.before.file).sha256,copy.before.sha256);assert.equal(pin(copy.after.file).sha256,copy.after.sha256);assert.equal(copy.before.sha256,copy.after.sha256);}
  const bootstrap=JSON.parse(fs.readFileSync(attempt.bootstrapReport.file,'utf8'));const checkedSource=pin(bootstrap.source);assert.equal(checkedSource.sha256,bootstrap.sourceSha256);
  report.attempts??={};report.attempts[role]={attempt:aid,api:attempt.api,source:checkedSource,strictExact:attempt.config.strictExact??false};
 }
 assert.equal(pin(receipt.output.file??receipt.output.path).sha256,module.sha256);
 for(const id of [...['api','runtime','base','driver','directRuntime'].map(k=>receipt.compiler[k]).filter(Boolean),...(receipt.compiler.sources??[]),...(receipt.emissionInputs??[])])assert.equal(pin(id.file??id.path??id.canonicalPath).sha256,id.sha256);
 const code=fs.readFileSync(file,'utf8');return {module,receipt:receiptId,compiler:receipt.compiler,code,tree:parse(code),api:(await import(pathToFileURL(path.resolve(file)))).default};
}
try{
 const apis={},trees={},codes={},shadows={};
 for(const [role,file]of Object.entries({baseline,candidate,typescript})){
  const main=await load(role,file,source),shadow=await load(role,path.join(path.dirname(file),'non-native-choice.mjs'),shadowSource);
  if(role==='typescript')for(const m of [main,shadow]){assert.equal(m.compiler.kind,'checked-pinned-typescript');assert.equal(m.compiler.upstreamCommit,catalog.upstreamCommit);}
  report.roles[role]={module:main.module,receipt:main.receipt,compiler:main.compiler,shadow:{module:shadow.module,receipt:shadow.receipt,compiler:shadow.compiler}};
  codes[role]=main.code;trees[role]=main.tree;apis[role]=main.api;shadows[role]=shadow.api;
  if(role==='candidate')assert(!shadow.code.includes('/* direct literal choice */'),'ordinary user datatypes refuse scalar choice');
 }
 for(const test of fixture.tests){const values=Object.fromEntries(Object.entries(apis).map(([role,api])=>[role,runCase(api,test)]));assert.deepEqual(values.candidate,values.baseline);assert.deepEqual(values.candidate,values.typescript);report.observations.push({id:test.id,values});}
 for(const test of shadowFixture.tests){const values=Object.fromEntries(Object.entries(shadows).map(([role,api])=>[role,runCase(api,test)]));report.observations.push({id:test.id,values});}
 const host=Object.fromEntries(Object.entries(apis).map(([role,api])=>[role,hostCases(api)]));assert.deepEqual(host.candidate,host.baseline);assert.deepEqual(host.candidate,host.typescript);report.host=host;
 const name=s=>'$jd$'+[...s].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
 const declaration=(role,id)=>{const found=trees[role].body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===id);assert.equal(found.length,1,id);return found[0];};
 const slices=(role,node)=>codes[role].slice(node.start,node.end);
 const metrics=(role,f)=>{const text=slices(role,f);let closures=0,continues=0,switches=0;walk(f,n=>{if(n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name==='jd_clo')closures++;if(n.type==='ContinueStatement')continues++;if(n.type==='SwitchStatement')switches++;});return {markers:text.split('/* direct literal choice */').length-1,closures,continues,switches};};
 function sharedEntry(id){
  const old=declaration('baseline',name(id)),entry=declaration('candidate',name(id));
  assert.deepEqual(entry.params.map(x=>x.name),old.params.map(x=>x.name),'same maximum-width entry ABI');
  assert.equal(entry.body.body.length,1);const ret=entry.body.body[0];assert.equal(ret.type,'ReturnStatement');const call=ret.argument;
  assert.equal(call.type,'CallExpression');assert.equal(call.callee.type,'Identifier');assert(call.callee.name.endsWith('$scc'));
  assert.equal(old.body.body[0].type,'VariableDeclaration');const pc=old.body.body[0].declarations[0];assert.equal(pc.id.name,'$pc');
  assert.equal(call.arguments[0].type,'Literal');assert.equal(call.arguments[0].value,pc.init.value);
  assert.deepEqual(call.arguments.slice(1).map(x=>{assert.equal(x.type,'Identifier');return x.name;}),entry.params.map(x=>x.name));
  const worker=declaration('candidate',call.callee.name);assert.deepEqual(worker.params.map(x=>x.name),['$pc',...entry.params.map(x=>x.name)]);
  assert.equal(worker.body.body.length,1);const loop=worker.body.body[0];assert.equal(loop.type,'ForStatement');assert.equal(loop.body.type,'SwitchStatement');
  assert.equal(slices('candidate',loop),slices('baseline',old.body.body[1]),'exact original loop body');
  const leader=call.callee.name.slice(0,-4),prefix=codes.candidate.slice(worker.body.start,loop.start),refs=[...prefix.matchAll(/\n\/\*JD_REF:([^*]+)\*\//g)].map(x=>x[1]);
  assert(slices('candidate',entry).includes('\n/*JD_REF:'+leader+'*/'));
  assert.deepEqual(refs,[name('orbit.a'),name('orbit.b')]);assert.equal(leader,refs[0]);
  assert.equal(loop.body.cases.length,refs.length);loop.body.cases.forEach((c,i)=>assert.equal(c.test.value,i));
  assert.equal(declaration('candidate',name('orbit.a')).params.length,3);assert.equal(declaration('candidate',name('orbit.b')).params.length,3);
  return {entry,worker,leader,refs,pc:pc.init.value};
 }
 const componentA=sharedEntry('orbit.a'),componentB=sharedEntry('orbit.b');assert.equal(componentA.worker,componentB.worker);
 report.sharedComponents=[{members:componentA.refs,leader:componentA.leader,worker:componentA.worker.id.name,entryPcs:[componentA.pc,componentB.pc],width:3,exactLoopBody:true,completeMemberRefs:true}];
 function shape(role,id){const f=role==='candidate'&&id==='orbit.a'?componentA.worker:declaration(role,name(id));return metrics(role,f);}
 for(const id of ['selected','composed','countdown','orbit.a','nested']){const old=shape('baseline',id),now=shape('candidate',id);assert(old.markers>0,id);assert.deepEqual(now,old,id+' preserved effective-body shape');if(id==='selected')assert.equal(now.closures,0);if(id==='countdown'||id==='orbit.a')assert(now.continues>0);if(id==='orbit.a')assert(now.switches>0);report.activation.push({id,baseline:old,candidate:now});}
 for(const id of ['counterfeit','nonliteral','partial_make']){const now=shape('candidate',id);assert.equal(now.markers,0,id);report.activation.push({id,candidate:now,refused:true});}
 for(const row of inputs.values())verify(row);for(const file of attempts.keys())await verifyAttempt(path.dirname(file));report.complete=true;report.pass=true;
}catch(error){report.error={message:error.message,stack:error.stack};process.exitCode=1;}
finally{report.seconds=(performance.now()-started)/1000;report.inputs=[...inputs.values()];report.parser={version:box.exports.version,sha256:hash(Buffer.from(parserSource))};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.observations.length,host:report.host?.candidate.length,activation:report.activation.length,error:report.error?.message}));}
