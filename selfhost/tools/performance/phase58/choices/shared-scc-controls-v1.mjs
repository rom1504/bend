// Root executes this after checked acquisition. No compiler or source rewriting.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
import {identity,verify,hash} from '../../phase54/bootstrap/adapter.mjs';
import {verifyAttempt} from '../../../development/workflow.mjs';

const [baseline,candidate,typescript,outArg]=process.argv.slice(2);
assert(baseline&&candidate&&typescript&&outArg,'shared-scc-controls-v1.mjs BASELINE_LIBRARY CANDIDATE_LIBRARY TS_LIBRARY NEW_OUT');
const out=path.resolve(outArg),root=path.resolve(import.meta.dirname,'../../../../..');
assert(out.startsWith(path.join(root,'selfhost/build/phase58')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
assert.equal(process.version,'v24.18.0');
const inputs=new Map(),pin=file=>{const row=identity(file);if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
const catalogFile=path.join(import.meta.dirname,'shared-scc-catalog-v1.json'),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert.equal(catalog.cases.length,2);
const fixture=catalog.cases[0],source=pin(path.join(import.meta.dirname,fixture.source.path));assert.equal(source.sha256,fixture.source.sha256);
const shadowFixture=catalog.cases[1],shadowSource=pin(path.join(import.meta.dirname,shadowFixture.source.path));assert.equal(shadowSource.sha256,shadowFixture.source.sha256);
for(const file of [import.meta.filename,catalogFile,process.execPath,new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),new URL('../../../development/workflow.mjs',import.meta.url)])pin(file);
for(const [name,sha256]of [["controls-v1.mjs", "1f6c15a131d94b14466d73fe2370c585163bc91ddb93b518fb17b2465dcefd61"], ["catalog-v1.json", "8ec51e13e461508956bddc8324339ee5f73086c573c7633f926bda168342b7de"], ["non-native-v1.bend", "ab1c148529ba3eac698679bf7b76de68c49eb680ea6e888bef71be1f0afe5790"]])assert.equal(pin(path.join(import.meta.dirname,name)).sha256,sha256);
const attempts=new Map();
const producers={direct:{file:path.resolve(import.meta.dirname,'../qualification/paired-fixtures-v2.mjs'),sha256:'6a2947f7a3c9fd84f7a78215c607fd5f90773e1edddf31376828d2d1f7fe0fe7'},typescript:{file:path.resolve(import.meta.dirname,'../../phase52/emit-worker-v2.mjs'),sha256:'f730abcde7203c61339f4eafefa144bc5c01031d5a1936c88d493afd5fe2d4a1'}};
for(const row of Object.values(producers))assert.deepEqual(pin(row.file),row);
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const box={exports:{}};box.module={exports:box.exports};vm.runInNewContext(parserSource,box);const parse=code=>box.exports.parse(code,{ecmaVersion:'latest',sourceType:'module'});
const walk=(n,f)=>{if(!n||typeof n!=='object')return;f(n);for(const v of Object.values(n)){if(Array.isArray(v))for(const x of v)walk(x,f);else if(v&&typeof v==='object')walk(v,f);}};
const report={kind:'phase58-shared-scc-controls-v1',complete:false,pass:false,roles:{},observations:[],activation:[],scope:'Checked same-source library and sole-root program emissions; unequal arities, active callback reentry/throw/replay, lexical captures and unknown closure tails. Static exact-loop sharing and complete member retention are independently required. Standard builtins; default Node stack.'};
const started=performance.now();
const encode=x=>typeof x==='bigint'?{$bigint:String(x)}:x&&typeof x==='object'?Object.fromEntries(Object.entries(x).map(([k,v])=>[k,encode(v)])):x;
function decode(x,events){if(x&&typeof x==='object'){if('$bigint'in x)return BigInt(x.$bigint);if('$callback'in x){assert.equal(x.$callback,'plus7');return n=>{events.push(['callback',n]);return (n+7)>>>0;};}return Object.fromEntries(Object.entries(x).map(([k,v])=>[k,decode(v,events)]));}return x;}
function runCase(api,test){const events=[];let value=api[test.exportName],error;try{for(const group of test.groups)value=value(...group.map(x=>decode(x,events)));}catch(e){error=e;}
 if(test.expectedError){assert.notEqual(error,undefined);assert(String(error?.message??error).includes(test.expectedError));}
 else{if(error!==undefined)throw error;assert.deepEqual(encode(value),test.expected,test.id);}
 assert.deepEqual(events,test.expectedEvents??[],test.id+' events');return {value:test.expectedError?null:encode(value),error:error===undefined?null:String(error?.message??error),events};}
async function load(role,file,source,library=true){
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
 const code=fs.readFileSync(file,'utf8');return {module,receipt:receiptId,compiler:receipt.compiler,code,tree:parse(code),api:library?(await import(pathToFileURL(path.resolve(file)))).default:null};
}

const name=s=>'$jd$'+[...s].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
function component(before,after,members){
 const find=(m,n)=>{const rows=m.tree.body.filter(f=>f.type==='FunctionDeclaration'&&f.id.name===n);assert.equal(rows.length,1,n);return rows[0];};
 const workers=new Set();let width;
 for(let pc=0;pc<members.length;pc++){
  const old=find(before,name(members[pc])),entry=find(after,name(members[pc]));assert.deepEqual(Array.from(entry.params,p=>{assert.equal(p.type,'Identifier');return p.name;}),Array.from(old.params,p=>{assert.equal(p.type,'Identifier');return p.name;}));
  assert.equal(entry.body.body.length,1);const ret=entry.body.body[0];assert.equal(ret.type,'ReturnStatement');const call=ret.argument;
  assert.equal(call.type,'CallExpression');assert.equal(call.callee.type,'Identifier');assert.equal(call.callee.name,name(members[0])+'$scc');
  assert.equal(call.arguments[0].type,'Literal');assert.equal(call.arguments[0].value,pc);assert.deepEqual(Array.from(call.arguments).slice(1).map(a=>{assert.equal(a.type,'Identifier');return a.name;}),Array.from(entry.params,p=>{assert.equal(p.type,'Identifier');return p.name;}));
  assert(after.code.slice(entry.start,entry.end).includes('\n/*JD_REF:'+name(members[0])+'*/'));const worker=find(after,call.callee.name);workers.add(worker);
  assert.deepEqual(Array.from(worker.params,p=>{assert.equal(p.type,'Identifier');return p.name;}),['$pc',...Array.from(entry.params,p=>{assert.equal(p.type,'Identifier');return p.name;})]);assert.equal(worker.body.body.length,1);
  const loop=worker.body.body[0];assert.equal(loop.type,'ForStatement');assert.equal(loop.body.type,'SwitchStatement');assert.equal(loop.body.cases.length,members.length);loop.body.cases.forEach((c,i)=>assert.equal(c.test.value,i));
  assert.equal(old.body.body[0].type,'VariableDeclaration');assert.equal(old.body.body[0].declarations[0].init.value,pc);
  assert.equal(after.code.slice(loop.start,loop.end),before.code.slice(old.body.body[1].start,old.body.body[1].end),'exact old component loop');
  const refs=[...after.code.slice(worker.body.start,loop.start).matchAll(/\n\/\*JD_REF:([^*]+)\*\//g)].map(x=>x[1]);assert.deepEqual(refs,members.map(name));width=entry.params.length;
 }
 assert.equal(workers.size,1);return {members,width,worker:[...workers][0].id.name,exactLoopBody:true,completeMemberRefs:true};
}
function hostCases(api){
 const rows=[],outer=[],inner=[];let first=true;
 const value=api['relay.a'](4n,10,n=>{outer.push(n);if(first){first=false;assert.equal(api['relay.b'](3n,100,x=>{inner.push(x);return x+2;},9),118);}return n+1;});
 assert.equal(value,20);assert.deepEqual(outer,[10,14,15,19]);assert.deepEqual(inner,[109,111,116]);rows.push({id:'active-component-reentry',value,outer,inner});
 const sentinel={shared:'throw'},events=[];let caught;try{api['relay.a'](4n,10,n=>{events.push(n);if(events.length===2)throw sentinel;return n+1;});}catch(e){caught=e;}assert.equal(caught,sentinel);assert.deepEqual(events,[10,14]);rows.push({id:'active-component-throw',events,identity:true});
 assert.equal(api['relay.a'](4n,10,n=>n+1),20);rows.push({id:'replay-after-throw',value:20});
 assert.equal(api['relay.a'](4n)(10)(n=>n+1),20);rows.push({id:'partial-entry',value:20});
 for(const entry of ['stash.a','stash.b'])for(const n of [0,1,2,100000]){let calls=0;const got=api[entry](BigInt(n),10,u=>{calls++;assert.deepEqual(u,{$:'Unit'});return 900;});const expected=n?10+n-1:900;assert.equal(got,expected);assert.equal(calls,n?0:1);rows.push({id:entry+'-capture-'+n,value:got,calls});}
 return rows;
}
try{
 const modules={};
 const programWorker=pin(path.resolve(import.meta.dirname,'../../phase52/semantic-program-worker-v2.mjs'));
 for(const [role,file]of Object.entries({baseline,candidate,typescript})){
  const library=await load(role,file,source),program=await load(role,path.join(path.dirname(file),'shared-scc-program.mjs'),source,false);
  assert.deepEqual(library.compiler,program.compiler,'Both modes use the same role compiler image');
  for(const m of [library,program])if(role==='typescript'){assert.equal(m.compiler.kind,'checked-pinned-typescript');assert.equal(m.compiler.upstreamCommit,catalog.upstreamCommit);}
  modules[role]={library,program};report.roles[role]={library:{module:library.module,receipt:library.receipt},program:{module:program.module,receipt:program.receipt},compiler:library.compiler};
 }
 for(const test of fixture.tests){const values=Object.fromEntries(Object.entries(modules).map(([role,m])=>[role,runCase(m.library.api,test)]));assert.deepEqual(values.candidate,values.baseline);assert.deepEqual(values.candidate,values.typescript);report.observations.push({id:test.id,values});}
 report.host=Object.fromEntries(Object.entries(modules).map(([role,m])=>[role,hostCases(m.library.api)]));assert.deepEqual(report.host.candidate,report.host.baseline);assert.deepEqual(report.host.candidate,report.host.typescript);
 report.programs=[];for(const [role,m]of Object.entries(modules)){const args=['--max-old-space-size=1024',...(role==='typescript'?[programWorker.file]:[]),m.program.module.file],r=spawnSync(process.execPath,args,{encoding:'utf8',timeout:20000,maxBuffer:1024*1024});assert.ifError(r.error);assert.equal(r.signal,null);assert.equal(r.status,0);assert.equal(r.stdout,shadowFixture.tests[0].stdout);assert.equal(r.stderr,'');report.programs.push({role,command:[process.execPath,...args],status:r.status,stdout:r.stdout,stderr:r.stderr});}
 const b=modules.baseline,c=modules.candidate;
 report.activation.push({mode:'library',...component(b.library,c.library,['relay.a','relay.b'])});
 report.activation.push({mode:'library',...component(b.library,c.library,['stash.a','stash.b'])});
 report.activation.push({mode:'program',...component(b.program,c.program,['relay.a','relay.b'])});
 assert.equal(report.activation[0].width,4);assert.equal(report.activation[1].width,3);
 for(const role of ['baseline','candidate'])for(const id of ['stash.a','stash.b'])assert(!modules[role].program.tree.body.some(f=>f.type==='FunctionDeclaration'&&f.id.name===name(id)),'program root does not retain unrelated component');
 const main=c.program.tree.body.find(f=>f.type==='FunctionDeclaration'&&f.id.name===name('main'));assert(main);const mainText=c.program.code.slice(main.start,main.end);assert(mainText.includes('\n/*JD_REF:'+name('relay.a')+'*/'));assert(!mainText.includes('\n/*JD_REF:'+name('relay.b')+'*/'));
 for(const row of inputs.values())verify(row);for(const file of attempts.keys())await verifyAttempt(path.dirname(file));report.complete=report.pass=true;
}catch(error){report.error={message:error.message,stack:error.stack};process.exitCode=1;}
finally{report.seconds=(performance.now()-started)/1000;report.inputs=[...inputs.values()];report.parser={version:box.exports.version,sha256:hash(Buffer.from(parserSource))};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.observations.length,host:report.host?.candidate.length,activation:report.activation.length,programs:report.programs?.length,error:report.error?.message}));}
