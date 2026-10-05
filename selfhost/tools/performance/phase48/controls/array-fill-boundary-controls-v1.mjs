// New semantic control for a previously admitted U32 handle domain. Historical
// private behavior is recorded separately; ordinary ungranted source execution
// defines the mutation/error observation that the corrected candidate must match.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);
assert(output,'array-fill-boundary-controls-v1.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-array-fill-boundary-controls-v1',complete:false,pass:false,inputs:[],modules:[],observations:[],
  scope:'Old U32 new/get/set private handle admission versus independently forced ordinary source execution. Historical mismatch is reported, never credited as candidate conformance. No timing.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,descriptor=Object.getOwnPropertyDescriptor;
const N=Number,A=Array,E=Error;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}
  if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(A.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){
  const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
function scenario(m,ordinary,hook){const events=[],sentinel=new E('late allocation helper sentinel'),f=m.G['river.read'],code=descriptor(f,'code');
  const owner=hook==='fill'?A.prototype:N,key=hook==='fill'?'fill':'isSafeInteger',old=descriptor(owner,key),original=old.value;let value,error,sameError=false,installed=false;
  function callback(...args){events.push(hook);const result=apply(original,this,args);if(!installed){installed=true;define(f,'code',{configurable:true,writable:true,value:function(){events.push('helper');throw sentinel;}});}return result;}
  try{define(owner,key,{configurable:true,writable:true,value:callback});
    value=ordinary?m.call(apply(m.G.bench.code,null,[[3,2]]),[]):m.default.bench(3,2);
  }catch(e){error={name:e.name,message:e.message};sameError=e===sentinel;}finally{define(owner,key,old);define(f,'code',code);}
  return {value,error,sameError,events};
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const catId=pin(path.join(import.meta.dirname,'array-fill-boundary-catalog-v1.json')),cat=JSON.parse(fs.readFileSync(catId.path,'utf8'));
  assert.equal(cat.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,cat.cases[0].source.path),cat.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,catId.sha256);
    assert.equal(r.compiler.upstreamCommit,cat.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const m of modules){assert.equal(m.default.bench(3,2),6);assert.equal(m.default.bench(0,2),0);}
  for(const hook of ['fill','isSafeInteger']){
    const ordinary=modules.map(m=>scenario(m,true,hook)),publicCalls=modules.map(m=>scenario(m,false,hook));
    for(const row of ordinary){assert.equal(row.sameError,true);assert.deepEqual(row.events,[hook,'helper']);assert.equal(row.value,undefined);}
    assert.deepEqual(ordinary[1],ordinary[0]);assert.deepEqual(publicCalls[1],ordinary[1],'Corrected private admission must preserve ordinary source observations');
    report.observations.push({hook,ordinary,publicCalls,historicalMatchesOrdinary:JSON.stringify(publicCalls[0])===JSON.stringify(ordinary[0]),candidateMatchesOrdinary:true});
  }
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const todo=[root],found=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;found.push(n);
    for(const x of Object.values(n))if(A.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return found;}
  const roots=text=>nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal'&&n.left.property.value==='bench');
  const before=roots(texts[0]),after=roots(texts[1]);assert.equal(before.length,1);assert.equal(after.length,1);
  assert(texts[0].slice(before[0].start,before[0].end).includes('/* private scalar root */'),'Historical ordinary handle root is present');
  const body=texts[1].slice(after[0].start,after[0].end),marker='/* private raw array root */';assert.equal(body.split(marker).length-1,1);
  const guards=nodes(after[0].right).filter(n=>n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name==='arrayViewHostGuard');
  assert(guards.length>=2,'Both raw and ordinary handle entries carry the fresh guard');
  const at=after[0].start+body.indexOf(marker)+marker.length;assert(!texts[1].includes('$p48FillEntry'));
  const derived='let $p48FillEntry=0;\n'+texts[1].slice(0,at)+'++$p48FillEntry;'+texts[1].slice(at)+'\nexport const phase48FillEntries=()=>$p48FillEntry;\n';parse(derived);
  const file=path.join(out,'candidate-entry-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});report.derivative={module:identity(file),parent:report.modules[1].module,offset:at,performanceEvidence:false};
  const witness=await import(pathToFileURL(file));assert.equal(witness.default.bench(3,2),6);assert.equal(witness.phase48FillEntries(),1);
  for(const hook of ['fill','isSafeInteger']){const entered=witness.phase48FillEntries(),actual=scenario(witness,false,hook);assert.deepEqual(actual,report.observations.find(x=>x.hook===hook).ordinary[1]);assert.equal(witness.phase48FillEntries(),entered);}
  assert.deepEqual(identity(file),report.derivative.module);for(const x of pinned.values())assert.deepEqual(identity(x.path),x);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,observations:report.observations.length,error:report.error}));
