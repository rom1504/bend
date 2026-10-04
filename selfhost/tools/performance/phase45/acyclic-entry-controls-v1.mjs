// Untimed renamed acyclic entry: checked modules, clean values, separate counters.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'acyclic-entry-controls-v1.mjs BASELINE_MODULE CANDIDATE20_MODULE TYPESCRIPT_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-acyclic-entry-controls',complete:false,pass:false,inputs:[],modules:[],oracles:[],activation:[],boundaries:[],abi:[],scope:'Untimed acyclic scalar source graph; supported post-import boundaries, no hostile-preimport or timing claim.'};
const identity=p=>{const file=fs.realpathSync(p),b=fs.readFileSync(file);return {path:file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const pinned=new Map();
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file??v.canonicalPath;if(file&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const oracle=(x,y)=>((x^5)>>>0)<y?(x+7)>>>0:(y-3)>>>0;
function observe(m,mode){const f=m.G['quartz.branch'],code=f.code,events=[],objects=[m.G,f,code];const saved=objects.map(o=>[o,Object.getOwnPropertyDescriptors(o)]);let value,error;
  try{
    if(mode==='global-getter')Object.defineProperty(m.G,'quartz.branch',{configurable:true,get(){events.push('G');return f;}});
    for(const key of ['code','env','bound','arity'])if(mode===key+'-getter'){const old=f[key];Object.defineProperty(f,key,{configurable:true,get(){events.push(key);return old;}});}
    if(mode==='env-value')f.env={tag:'acyclic-env'};
    if(mode==='code-value')f.code=function(a){events.push('code');return Reflect.apply(code,this,[a]);};
    if(mode==='global-value')m.G['quartz.branch']={...f,code:function(a){events.push('replacement');return Reflect.apply(code,this,[a]);}};
    const call=function(receiver,a){events.push('call');return Reflect.apply(code,receiver,[a]);};
    if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:call});
    if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){events.push('get-call');return call;}});
    value=m.default.glint(0,9);
  }catch(e){error={name:e.name,message:e.message};}finally{for(const [o,d]of saved){for(const key of Reflect.ownKeys(o))if(!Object.hasOwn(d,key))delete o[key];Object.defineProperties(o,d);}}
  return {value,error,events};}
function abi(m){const root=m.G.glint,partial=m.call(root,[0]),staged=m.call(partial,[9]);assert.equal(staged,7);
  const raw=m.call(Reflect.apply(root.code,null,[[17,4]]),[]);assert.equal(raw,1);let over;
  try{m.call(root,[0,9,0]);}catch(e){over={name:e.name,message:e.message};}assert.deepEqual(over,{name:'Error',message:'attempt to call non-function 7'});
  return {arity:root.arity,codeLength:root.code.length,codeName:root.code.name,codeType:typeof root.code,env:root.env,bound:root.bound,partialArity:partial.arity,staged,raw,over};}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogId=pin(path.join(import.meta.dirname,'acyclic-entry-catalog-v1.json')),catalog=JSON.parse(fs.readFileSync(catalogId.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);audit(emission);
    report.modules.push({role:['baseline','candidate20','typescript'][i],module,receipt,compiler:emission.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const row of catalog.cases)for(const m of modules)assert.equal(m.default.glint(...row.point.args),row.point.expected,row.id);
  for(const x of [0,1,5,9,17,4294967295])for(const y of [0,1,9,32,4294967295]){const expected=oracle(x,y),values=modules.map(m=>m.default.glint(x,y));for(const value of values)assert.equal(value,expected);report.oracles.push({x,y,expected,values});}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function assignments(text){const todo=[parse(text)],found=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;
    if(n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.property.type==='Literal'&&n.left.property.value==='glint')found.push(n);
    for(const v of Object.values(n))if(Array.isArray(v))todo.push(...v);else if(v&&typeof v==='object')todo.push(v);}assert.equal(found.length,1);return found[0];}
  const marker='/* private contextual instances */',selected=assignments(texts[1]),body=texts[1].slice(selected.start,selected.end),old=assignments(texts[0]);
  assert.equal(texts[0].slice(old.start,old.end).split(marker).length-1,0,'Baseline acyclic entry stays generic');assert.equal(body.split(marker).length-1,1,'Candidate20 admits renamed acyclic root');
  assert(!body.includes('private first-order continuation component')&&!body.includes('private first-order native component'),'Graph has no recursive component');
  assert(body.includes('regionHostGuard()&&stringHostGuard()'),'Full host guards retained');assert(!texts[1].includes('$p45Acyclic'));
  const offset=selected.start+body.indexOf(marker)+marker.length,derived='let $p45Acyclic=0;\n'+texts[1].slice(0,offset)+'++$p45Acyclic;'+texts[1].slice(offset)+'\nexport const p45AcyclicCount=()=>$p45Acyclic;\n';parse(derived);
  const derivativeFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivativeFile,derived,{flag:'wx'});report.derivative={module:identity(derivativeFile),source:report.modules[1].module,offset,performanceEvidence:false,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}};
  const witness=await import(pathToFileURL(derivativeFile));assert.equal(witness.p45AcyclicCount(),0);
  for(const [x,y]of [[0,9],[17,4],[4294967295,0],[0,9]]){const before=witness.p45AcyclicCount(),value=witness.default.glint(x,y);assert.equal(value,oracle(x,y));assert.equal(witness.p45AcyclicCount()-before,1);report.activation.push({x,y,value,entries:1});}
  for(const mode of ['global-getter','code-getter','env-getter','bound-getter','arity-getter','env-value','code-value','global-value','own-call','call-getter']){
    const values=modules.slice(0,2).map(m=>observe(m,mode));report.current={mode,values};assert.deepEqual(values[1],values[0]);assert.equal(values[0].error,undefined);assert.equal(values[0].value,7);if(mode!=='env-value')assert(values[0].events.length);
    const before=witness.p45AcyclicCount();assert.deepEqual(observe(witness,mode),values[1]);assert.equal(witness.p45AcyclicCount(),before,'Mutation refuses private root');report.boundaries.push(report.current);delete report.current;
  }
  const observations=modules.slice(0,2).map(abi);assert.deepEqual(observations[1],observations[0]);const before=witness.p45AcyclicCount();assert.deepEqual(abi(witness),observations[1]);assert.equal(witness.p45AcyclicCount()-before,1,'Only completed exact partial application enters; raw/overapplied calls stay generic');report.abi.push({observations,completedPartialEntries:1});
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row);assert.deepEqual(identity(derivativeFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,boundaries:report.boundaries.length,error:report.error}));
