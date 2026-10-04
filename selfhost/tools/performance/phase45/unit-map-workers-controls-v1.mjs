// Untimed canonical Unit/Map<Unit> private admission and public boundary controls.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'unit-map-workers-controls-v1.mjs BASELINE CANDIDATE TYPESCRIPT NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-unit-map-worker-controls',controllerVersion:1,complete:false,pass:false,inputs:[],modules:[],oracles:[],activation:[],boundaries:[],abi:[],
  scope:'Canonical Unit in private Map/List/Maybe graphs; clean three-role values, candidate deep50k, and observable public helper/object boundaries. No timing, arbitrary hostile-preimport, termination-proof or universal conformance claim.'};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);return {path:file,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const pinned=new Map();
function pin(file,want){const row=identity(file);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}
  if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file??v.canonicalPath;if(file&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
function oracle(name,n,seed){return (seed+(name==='bench'?(n===0?0:2):name==='boxed'?3:1))>>>0;}
function observe(m,mode){const f=m.G.grove,code=f.code,events=[],objects=[m.G,f,code];
  const saved=objects.map(o=>[o,Object.getOwnPropertyDescriptors(o)]);let value,error;
  try{
    if(mode==='global-getter')Object.defineProperty(m.G,'grove',{configurable:true,get(){events.push('G');return f;}});
    for(const key of ['code','env','bound','arity'])if(mode===key+'-getter'){const old=f[key];Object.defineProperty(f,key,{configurable:true,get(){events.push(key);return old;}});}
    if(mode==='env-value')f.env={tag:'unit-env'};
    if(mode==='code-value')f.code=function(a){events.push('code');return Reflect.apply(code,this,[a]);};
    if(mode==='global-value')m.G.grove={...f,code:function(a){events.push('replacement');return Reflect.apply(code,this,[a]);}};
    const call=function(receiver,a){events.push('call');return Reflect.apply(code,receiver,[a]);};
    if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:call});
    if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){events.push('get-call');return call;}});
    value=m.default.bench(3,7);
  }catch(e){error={name:e.name,message:e.message};}finally{
    for(const [o,descriptors]of saved){for(const key of Reflect.ownKeys(o))if(!Object.hasOwn(descriptors,key))delete o[key];Object.defineProperties(o,descriptors);}
  }return {value,error,events};}
function describe(f){return {arity:f.arity,env:f.env,bound:f.bound.map(v=>typeof v==='bigint'?String(v)+'n':v),codeType:typeof f.code,codeLength:f.code.length};}
function publicAbi(m){
  assert.equal(m.G.bench.arity,2);assert.equal(m.G.boxed.arity,1);assert.equal(m.G.touch.arity,1);
  const metadata=Object.fromEntries(['bench','boxed','touch','public_size','echo_unit','new_unit'].map(name=>[name,describe(m.G[name])]));
  const original=Object.getOwnPropertyDescriptor(m.G,'grove'),events=[];let partialDescriptor,staged;
  try{Object.defineProperty(m.G,'grove',{configurable:true,get(){events.push('G');return original.value;}});
    const partial=m.call(m.G.bench,[3]);partialDescriptor=describe(partial);assert.deepEqual(events,[],'Partial bench must not demand grove');
    staged=m.call(partial,[7]);assert.equal(staged,9);assert(events.length,'Staged call must demand public grove');
  }finally{Object.defineProperty(m.G,'grove',original);}
  const raw=m.call(Reflect.apply(m.G.bench.code,null,[[3,7]]),[]);assert.equal(raw,9);
  let overapplication;try{m.call(m.G.bench,[3,7,0]);}catch(error){overapplication={name:error.name,message:error.message};}
  assert.deepEqual(overapplication,{name:'Error',message:'attempt to call non-function 9'});
  return {metadata,partialDescriptor,staged,events,raw,overapplication};
}
function publicObjects(m){
  const events=[],unit=m.ctor('Unit',[]),map=m.ctor('MLeaf',['λ',unit]);
  const unitArgs=unit.a,mapArgs=map.a;assert(Array.isArray(unitArgs));assert(Array.isArray(mapArgs));
  Object.defineProperty(unit,'a',{configurable:true,enumerable:true,get(){events.push('unit.a');return unitArgs;}});
  Object.defineProperty(map,'a',{configurable:true,enumerable:true,get(){events.push('map.a');return mapArgs;}});
  const touch=m.call(m.G.touch,[unit,7]),size=m.call(m.G.public_size,[map]),echo=m.call(m.G.echo_unit,[unit]);
  assert.equal(touch,8);assert.equal(size,1);assert.equal(echo,unit);assert(events.includes('map.a'),'Public Map field getter remains observable');
  const first=m.call(m.G.new_unit,[7]),second=m.call(m.G.new_unit,[7]);assert.notEqual(first,second,'Fresh public Unit allocation');
  for(const value of [first,second]){assert.equal(value.$,'Unit');assert(Array.isArray(value.a));assert.equal(value.a.length,0);}
  const shape=value=>({keys:Reflect.ownKeys(value),descriptors:Object.fromEntries(Object.entries(Object.getOwnPropertyDescriptors(value)).map(([key,d])=>[key,{...d,value:Array.isArray(d.value)?[...d.value]:d.value}]))});
  return {touch,size,identity:true,fresh:true,first:shape(first),second:shape(second),events};
}
try{
  pin(import.meta.filename);pin(process.execPath);
  const catalogFile=path.join(import.meta.dirname,'unit-map-workers-catalog-v1.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);
    assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);audit(emission);
    report.modules.push({role:['baseline','candidate','typescript'][i],module,receipt,compiler:emission.compiler});
    texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const row of catalog.cases){const p=row.point;for(const m of modules)assert.equal(m.default[p.exportName](...p.args),p.expected,row.id);}
  for(const name of ['bench','boxed','foreign_payload'])for(const n of (name==='bench'?[0,1,2,31,32,33,256]:[0]))for(const seed of [0,7,4294967295]){
    const args=name==='bench'?[n,seed]:[seed],expected=oracle(name,n,seed),values=modules.map(m=>m.default[name](...args));for(const value of values)assert.equal(value,expected);
    report.oracles.push({name,args,expected,values});}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const pending=[root],result=[];while(pending.length){const n=pending.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;
    result.push(n);for(const v of Object.values(n))if(Array.isArray(v))pending.push(...v);else if(v&&typeof v==='object')pending.push(v);}return result;}
  function assignments(text,name){return nodes(parse(text)).filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.property.type==='Literal'&&n.left.property.value===name);}
  const marker='/* private contextual instances */',edits=[];
  for(const name of ['bench','boxed'])for(const i of [0,1]){const found=assignments(texts[i],name);assert.equal(found.length,1,name+' definition');
    const item=found[0],body=texts[i].slice(item.start,item.end),count=body.split(marker).length-1;assert.equal(count,i,name+' canonical Unit admission');
    if(i===1)edits.push({name,offset:item.start+body.indexOf(marker)+marker.length});}
  for(const name of ['touch','public_size','echo_unit','new_unit','foreign_payload']){const found=assignments(texts[1],name);assert(found.length>0,name+' definition');
    for(const item of found)assert(!texts[1].slice(item.start,item.end).includes(marker),name+' public object or unsupported payload root remains excluded');}
  assert(!texts[1].includes('$p45Unit'),'Reserved diagnostic identifier');let derived=texts[1];
  for(const e of [...edits].sort((a,b)=>b.offset-a.offset))derived=derived.slice(0,e.offset)+'++$p45Unit['+JSON.stringify(e.name)+'];'+derived.slice(e.offset);
  derived='const $p45Unit={bench:0,boxed:0};\n'+derived+'\nexport const p45UnitCounts=()=>({...$p45Unit});\n';parse(derived);
  const derivativeFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivativeFile,derived,{flag:'wx'});
  report.derivative={source:report.modules[1].module,module:identity(derivativeFile),edits,performanceEvidence:false,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}};
  const witness=await import(pathToFileURL(derivativeFile));assert.deepEqual(witness.p45UnitCounts(),{bench:0,boxed:0});
  for(const name of ['bench','boxed'])for(const n of (name==='bench'?[3,50000,3]:[0])){
    const args=name==='bench'?[n,7]:[7],expected=oracle(name,n,7),before=witness.p45UnitCounts(),value=modules[1].default[name](...args),observed=witness.default[name](...args),after=witness.p45UnitCounts();
    assert.equal(value,expected);assert.equal(observed,expected);assert.equal(after[name]-before[name],1);
    report.activation.push({name,args,expected,value,entries:1});}
  for(const mode of ['global-getter','code-getter','env-getter','bound-getter','arity-getter','env-value','code-value','global-value','own-call','call-getter']){
    const values=modules.slice(0,2).map(m=>observe(m,mode));report.current={mode,values};assert.deepEqual(values[1],values[0],mode);assert.equal(values[0].error,undefined,mode);
    assert.equal(values[0].value,oracle('bench',3,7));if(mode!=='env-value')assert(values[0].events.length,mode+' live hook');
    const before=witness.p45UnitCounts(),observed=observe(witness,mode),after=witness.p45UnitCounts();assert.deepEqual(observed,values[1],mode+' derivative');assert.deepEqual(after,before,mode+' contextual refusal');
    report.boundaries.push({...report.current,countsBefore:before,countsAfter:after});delete report.current;
  }
  const abi=modules.slice(0,2).map(publicAbi);assert.deepEqual(abi[1],abi[0],'Public arity, staged demand, raw code and overapplication');
  const abiBefore=witness.p45UnitCounts(),abiWitness=publicAbi(witness),abiAfter=witness.p45UnitCounts();
  assert.deepEqual(abiWitness,abi[1]);assert.deepEqual(abiAfter,abiBefore,'Partial/refused/raw/oversaturated calls do not enter contextual root');
  report.abi.push({observations:abi,countsBefore:abiBefore,countsAfter:abiAfter});
  const objects=modules.slice(0,2).map(publicObjects);assert.deepEqual(objects[1],objects[0],'Public Unit/Map identity, shape and getters');
  const objectBefore=witness.p45UnitCounts(),objectWitness=publicObjects(witness),objectAfter=witness.p45UnitCounts();assert.deepEqual(objectWitness,objects[1]);assert.deepEqual(objectAfter,objectBefore,'Public objects never enter private Unit roots');
  report.abi.push({publicObjects:objects,countsBefore:objectBefore,countsAfter:objectAfter});
  const refusedBefore=witness.p45UnitCounts();assert.equal(witness.default.foreign_payload(7),8);assert.deepEqual(witness.p45UnitCounts(),refusedBefore,'Arbitrary payload remains outside Unit extension');
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row,'Changed input');assert.deepEqual(identity(derivativeFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,activation:report.activation.length,boundaries:report.boundaries.length,error:report.error}));
