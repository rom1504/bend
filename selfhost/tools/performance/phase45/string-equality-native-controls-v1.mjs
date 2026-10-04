// Untimed isolated native String.eq proposal. Does not build or time compilers.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'string-equality-native-controls-v1.mjs BASELINE23 CANDIDATE TYPESCRIPT NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-native-string-equality-controls',version:1,complete:false,pass:false,inputs:[],modules:[],oracles:[],activation:[],boundaries:[],errors:[],
  scope:'Untimed independent renamed source; valid Unicode across three compilers, exact predecessor/candidate malformed public String ABI and source Char errors. No timing, malformed private String claim, arbitrary preimport contract or release qualification.'};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);return {path:file,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const pinned=new Map();
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}
  if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file??v.canonicalPath;if(file&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
function observe(f){try{return {value:f()};}catch(e){return {error:{name:e.name,message:e.message}};}}
function restore(object,descriptors){for(const key of Reflect.ownKeys(object))if(!Object.hasOwn(descriptors,key))delete object[key];Object.defineProperties(object,descriptors);}
function mutate(m,mode){const f=m.G['String.eq'],code=f.code,objects=[m.G,f,code],saved=objects.map(o=>[o,Object.getOwnPropertyDescriptors(o)]),events=[];let result;
  try{
    if(mode==='global-getter')Object.defineProperty(m.G,'String.eq',{configurable:true,get(){events.push('G');return f;}});
    for(const key of ['code','env','bound','arity'])if(mode===key+'-getter'){const old=f[key];Object.defineProperty(f,key,{configurable:true,get(){events.push(key);return old;}});}
    if(mode==='env-value')f.env={tag:'prism-env'};
    if(mode==='code-wrap')f.code=function(a){events.push('code');return Reflect.apply(code,this,[a]);};
    if(mode==='code-false')f.code=function(a){events.push('false');return false;};
    if(mode==='global-wrap')m.G['String.eq']={...f,code:function(a){events.push('replacement');return Reflect.apply(code,this,[a]);}};
    const ownCall=function(receiver,a){events.push('call');return Reflect.apply(code,receiver,[a]);};
    if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:ownCall});
    if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){events.push('get-call');return ownCall;}});
    result=observe(()=>m.default.bench(2,false));
  }finally{for(const [o,d]of saved)restore(o,d);}
  assert.deepEqual(result,{value:mode!=='code-false'});if(mode!=='env-value')assert(events.length,'Live native boundary hook');return {result,events};}
function host(m,property,getter,malformed){const descriptor=Object.getOwnPropertyDescriptor(String.prototype,property),original=descriptor.value,events=[];let result;
  const method=function(...args){events.push([property,'call',String(this),args]);return Reflect.apply(original,this,args);};
  try{Object.defineProperty(String.prototype,property,getter?{configurable:true,get(){events.push([property,'get',String(this)]);return method;}}:{...descriptor,value:method});
    result=observe(()=>malformed?m.default.public_eq('\ud800','\ud800'):m.default.bench(2,false));
  }finally{Object.defineProperty(String.prototype,property,descriptor);}
  return {result,events};}
function sourceError(m,reentry){const descriptor=Object.getOwnPropertyDescriptor(globalThis,'Error'),OriginalError=Error,events=[];let result;
  try{Object.defineProperty(globalThis,'Error',{configurable:true,writable:true,value:function(...args){events.push(['Error',String(args[0])]);
    if(reentry)events.push(['reentry',m.default.bench(2,false)]);return Reflect.apply(OriginalError,this,args);}});
    result=observe(()=>m.default.scalar(0xd800));
  }finally{Object.defineProperty(globalThis,'Error',descriptor);}
  assert.equal(result.error?.name,'Error');assert.match(result.error.message,/55296 is not a Unicode scalar value/);assert.equal(events.filter(e=>e[0]==='Error').length,1);
  if(reentry)assert.deepEqual(events[1],['reentry',true]);return {result,events};}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'string-equality-native-catalog-v1.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);audit(emission);
    report.modules.push({role:['baseline23','candidate','typescript'][i],module,receipt,compiler:emission.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const row of catalog.cases)for(const m of modules)assert.equal(m.default[row.point.exportName](...row.point.args),row.point.expected,row.id);
  for(const n of [0,1,2,31,32,33,128])for(const different of [false,true]){const expected=!different,values=modules.map(m=>m.default.bench(n,different));for(const v of values)assert.equal(v,expected);report.oracles.push({name:'bench',args:[n,different],expected,values});}
  const valid=['','a','aa','b','λ','🧭','🧬','🧭a','é','e\u0301','\0'];
  for(const a of valid)for(const b of valid){const expected=a===b,values=modules.map(m=>m.default.public_eq(a,b));for(const v of values)assert.equal(v,expected);report.oracles.push({name:'public_eq',args:[a,b],expected,values});}
  const malformed=[['\ud800','\ud800',55296],['\udc00','\udc00',56320],['a\ud800','a\udc00',55296],['\ud800','',false],['','\ud800',false],['a\ud800','b\udc00',false]];
  for(const [a,b,want]of malformed){const values=modules.slice(0,2).map(m=>observe(()=>m.default.public_eq(a,b)));assert.deepEqual(values[1],values[0]);
    if(typeof want==='number'){assert.equal(values[0].error?.name,'Error');assert(values[0].error.message.includes(want+' is not a Unicode scalar value'));}else assert.deepEqual(values[0],{value:want});
    report.errors.push({kind:'public-malformed-string',args:[a,b],expected:want,values});}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const todo=[root],out=[];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;out.push(n);for(const v of Object.values(n))if(Array.isArray(v))todo.push(...v);else if(v&&typeof v==='object')todo.push(v);}return out;}
  function assignments(text,name){return nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.property.type==='Literal'&&n.left.property.value===name);}
  const marker='/* private contextual instances */',edits=[];
  for(const name of ['bench','scalar'])for(const i of [0,1]){const found=assignments(texts[i],name);assert.equal(found.length,1);const item=found[0],body=texts[i].slice(item.start,item.end);assert.equal(body.split(marker).length-1,i,name+' admission');
    if(i===1)edits.push({name,offset:item.start+body.indexOf(marker)+marker.length});}
  const publicEntries=assignments(texts[1],'public_eq');assert.equal(publicEntries.length,1,'Unique public equality definition');
  for(const item of publicEntries)assert(!texts[1].slice(item.start,item.end).includes(marker),'Public String arguments remain generic');
  assert(!texts[1].includes('$p45Equality'));let derived=texts[1];for(const e of [...edits].sort((a,b)=>b.offset-a.offset))derived=derived.slice(0,e.offset)+'++$p45Equality['+JSON.stringify(e.name)+'];'+derived.slice(e.offset);
  derived='const $p45Equality={bench:0,scalar:0};\n'+derived+'\nexport const p45EqualityCounts=()=>({...$p45Equality});\n';parse(derived);
  const derivativeFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivativeFile,derived,{flag:'wx'});
  report.derivative={source:report.modules[1].module,module:identity(derivativeFile),edits,performanceEvidence:false,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}};
  const witness=await import(pathToFileURL(derivativeFile));
  for(const [name,args,expected]of [['bench',[3,false],true],['bench',[3,true],false],['scalar',[120],true],['scalar',[121],false]]){
    const before=witness.p45EqualityCounts(),value=witness.default[name](...args),after=witness.p45EqualityCounts();assert.equal(value,expected);assert.equal(after[name]-before[name],1);report.activation.push({name,args,value,before,after});}
  const beforeError=witness.p45EqualityCounts(),invalid=observe(()=>witness.default.scalar(0xd800)),afterError=witness.p45EqualityCounts();assert.match(invalid.error?.message,/55296 is not a Unicode scalar value/);assert.equal(afterError.scalar-beforeError.scalar,1);
  report.activation.push({name:'scalar-source-error',invalid,before:beforeError,after:afterError});
  for(const mode of ['global-getter','code-getter','env-getter','bound-getter','arity-getter','env-value','code-wrap','code-false','global-wrap','own-call','call-getter']){
    const values=modules.slice(0,2).map(m=>mutate(m,mode));assert.deepEqual(values[1],values[0],mode);const before=witness.p45EqualityCounts(),observed=mutate(witness,mode),after=witness.p45EqualityCounts();assert.deepEqual(observed,values[1]);assert.deepEqual(after,before,mode+' guarded refusal');report.boundaries.push({mode,values});}
  for(const property of ['isWellFormed','codePointAt'])for(const getter of [false,true])for(const malformed of [false,true]){
    const values=modules.slice(0,2).map(m=>host(m,property,getter,malformed));assert.deepEqual(values[1],values[0]);const before=witness.p45EqualityCounts(),observed=host(witness,property,getter,malformed),after=witness.p45EqualityCounts();assert.deepEqual(observed,values[1]);assert.deepEqual(after,before);report.boundaries.push({property,getter,malformed,values});}
  for(const reentry of [false,true]){const values=modules.slice(0,2).map(m=>sourceError(m,reentry));assert.deepEqual(values[1],values[0]);const before=witness.p45EqualityCounts(),observed=sourceError(witness,reentry),after=witness.p45EqualityCounts();assert.deepEqual(observed,values[1]);assert.equal(after.scalar-before.scalar,1,'Source error enters private graph');assert.equal(after.bench-before.bench,reentry?1:0,'bad suspends proof for supported reentry');report.errors.push({kind:'source-error-hook',reentry,values,before,after});}
  const beforeReplay=witness.p45EqualityCounts();assert.equal(witness.default.bench(3,false),true);assert.equal(witness.default.scalar(120),true);const afterReplay=witness.p45EqualityCounts();assert.equal(afterReplay.bench-beforeReplay.bench,1);assert.equal(afterReplay.scalar-beforeReplay.scalar,1);report.activation.push({name:'replay',before:beforeReplay,after:afterReplay});
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row,'Changed input');assert.deepEqual(identity(derivativeFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,boundaries:report.boundaries.length,error:report.error}));
