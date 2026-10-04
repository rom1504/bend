// Finite checked-module observations; this controller is never timing evidence.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'nullary-demand21-controls-v2.mjs BASELINE_MODULE CANDIDATE_MODULE TS_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-nullary21-demand-controls',controllerVersion:2,complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],activation:[],metadata:[],
  scope:'Independent contextual-nullary source; exact public descriptor metadata, value/order/mutation/source-error/reentry observations. Counter derivatives are untimed. No arbitrary source-text or timing equivalence claim.'};
const identity=p=>{const file=fs.realpathSync(p),b=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const pinned=new Map();
function pin(p,want){const row=identity(p);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(row.bytes,want.bytes);}
  if(pinned.has(row.path))assert.deepEqual(row,pinned.get(row.path));else{pinned.set(row.path,row);report.inputs.push(row);}return row;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const p=v.canonicalPath??v.path??v.file;if(typeof p==='string'&&v.sha256)pin(p,v);Object.values(v).forEach(audit);}}
function snapshot(m){const objects=[m.G];for(const d of Object.values(Object.getOwnPropertyDescriptors(m.G))){const f=d.value;
  if(f&&typeof f==='object')for(const o of [f,f.code,f.bound])if(o&&(typeof o==='object'||typeof o==='function'))objects.push(o);}
  const rows=[...new Set(objects)].map(o=>[o,Object.getOwnPropertyDescriptors(o),Object.getPrototypeOf(o)]);
  return ()=>{for(const [o,ds,proto]of rows){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];Object.setPrototypeOf(o,proto);Object.defineProperties(o,ds);}};}
function observe(m,action){const restore=snapshot(m),events=[];let value,error;
  try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}return {value,error,events};}
try{
  pin(import.meta.filename);pin(process.execPath);report.previousController=pin(path.join(import.meta.dirname,'nullary-demand21-controls-v1.mjs'));
  const catalogFile=path.join(import.meta.dirname,'nullary-demand21-catalog-v1.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7','Exact pinned upstream');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],texts=[];
  for(const [i,file]of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);
    assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');audit(emission);
    report.modules.push({role:['baseline','candidate','typescript'][i],module,receipt,compiler:emission.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const row of catalog.cases){const {exportName,args,expected}=row.point,values=modules.map(m=>m.default[exportName](...args));
    for(const value of values)assert.equal(value,expected,row.id);report.oracles.push({id:row.id,expected,values});}
  for(const m of modules){const a=m.default.returned(),b=m.default.returned();assert.notEqual(a,b);assert.equal(a.$,'Coin');assert.equal((a.a??[a.face])[0],9);}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
  function nodes(root){const pending=[root],result=[];while(pending.length){const node=pending.pop();if(!node||typeof node!=='object'||typeof node.type!=='string')continue;
    result.push(node);for(const value of Object.values(node))if(Array.isArray(value))pending.push(...value);else if(value&&typeof value==='object')pending.push(value);}return result;}
  const assignments=nodes(parse(texts[1])).filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.type==='Identifier'&&n.left.object.name==='G');
  const marker='/* private contextual instances */';let derived=texts[1];const edits=[];
  assert(!derived.includes('$p45Nullary'),'Reserved diagnostic name collision');
  for(const name of ['bench','ordered','text','inside','overflow','returned','returned_closure','action','plain']){
    const matches=assignments.filter(n=>n.left.property.type==='Literal'&&n.left.property.value===name);assert.equal(matches.length,1,'Unique root '+name);
    const assignment=matches[0],text=texts[1].slice(assignment.start,assignment.end),hits=text.split(marker).length-1,admitted=['bench','ordered','text','inside','overflow'].includes(name);
    assert.equal(hits,admitted?1:0,name+' admission');if(admitted)edits.push({name,offset:assignment.start+text.indexOf(marker)+marker.length});
  }
  for(const {name,offset}of [...edits].sort((a,b)=>b.offset-a.offset))derived=derived.slice(0,offset)+'++$p45Nullary['+JSON.stringify(name)+'];'+derived.slice(offset);
  derived='const $p45Nullary={bench:0,ordered:0,text:0,inside:0,overflow:0};\n'+derived+'\nexport const p45NullaryCounts=()=>({...$p45Nullary});\n';
  parse(derived);
  const derivativeFile=path.join(out,'candidate-counter.mjs');fs.writeFileSync(derivativeFile,derived,{flag:'wx'});
  report.derivative={module:identity(derivativeFile),source:report.modules[1].module,edits,performanceEvidence:false,
    parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')}};const witness=await import(pathToFileURL(derivativeFile));
  assert.deepEqual(witness.p45NullaryCounts(),{bench:0,ordered:0,text:0,inside:0,overflow:0},'No source-body entry at import');
  for(const {name}of edits.filter(x=>x.name!=='overflow')){const expected=catalog.cases.find(row=>row.point.exportName===name).point.expected,before=witness.p45NullaryCounts();
    assert.equal(witness.default[name](),expected);assert.equal(witness.default[name](),expected);const after=witness.p45NullaryCounts();assert.equal(after[name]-before[name],2);
    report.activation.push({name,entries:2});}
  function metadata(m,name){const f=m.G[name],c=f.code,ds=Object.getOwnPropertyDescriptors(c),arity=name==='returned_closure'?1:0;
    assert.equal(f.arity,arity,name+' descriptor arity');assert.equal(c.length,arity?1:0,name+' code length');assert.equal(c.name,'',name+' code name');
    assert(Object.hasOwn(c,'prototype'),name+' normal function prototype');assert.equal(c.prototype.constructor,c);assert.equal(Object.getPrototypeOf(c),Function.prototype);
    return {arity:f.arity,codeKeys:Reflect.ownKeys(c).map(String),length:{...ds.length},name:{...ds.name},prototype:{writable:ds.prototype.writable,enumerable:ds.prototype.enumerable,configurable:ds.prototype.configurable},env:f.env,bound:[...f.bound]};}
  for(const name of ['bench','ordered','text','inside','overflow','returned','returned_closure','action','plain']){
    const rows=modules.slice(0,2).map(m=>metadata(m,name));assert.deepEqual(rows[1],rows[0],name+' complete code metadata');report.metadata.push({name,observations:rows});}
  for(const [i,m]of modules.entries()){const f=m.default.returned_closure();assert.equal(i===2?f(5):m.call(f,[5]),14,'Returned closure value');}
  const specs=[];const add=(name,action,{throws=false,live=true,refuses=true}={})=>specs.push({name,action,throws,live,refuses});
  add('twice-repeated',(m,e)=>{let n=0;m.G['demand.left'].code=()=>{e.push(++n);return n;};const values=[m.default.bench(),m.default.bench()];assert.deepEqual(values,[8,26]);assert.deepEqual(e,[1,2,3,4]);return values;});
  add('text-twice',(m,e)=>{let n=0;m.G['demand.word'].code=()=>{e.push(++n);return n===1?'u':'v';};const value=m.default.text();assert.equal(value,'uv');assert.deepEqual(e,[1,2]);return value;});
  add('left-right-order',(m,e)=>{m.G['demand.left'].code=()=>{e.push('left');return 9;};m.G['demand.right'].code=()=>{e.push('right');return 4;};const value=m.default.ordered();assert.deepEqual(e,['left','right']);return value;});
  for(const helper of ['demand.left','demand.right'])add(helper+':throw-order',(m,e)=>{const token=new Error('nullary sentinel');
    m.G['demand.left'].code=()=>{e.push('left');if(helper==='demand.left')throw token;return 9;};m.G['demand.right'].code=()=>{e.push('right');throw token;};
    try{m.default.ordered();assert.fail('Expected sentinel');}catch(error){assert.equal(error,token);}assert.deepEqual(e,helper==='demand.left'?['left']:['left','right']);return 'same-error';});
  add('helper-reentry',(m,e)=>{const f=m.G['demand.left'],old=f.code;let active=false;
    f.code=function(a){if(!active){active=true;try{e.push(m.default.ordered());}finally{active=false;}}return Reflect.apply(old,this,[a]);};const value=m.default.bench();assert.deepEqual(e,[5,5]);return value;});
  for(const name of ['bench','demand.left'])for(const mode of ['global-getter','code-getter','env-getter','env-value','bound-getter','arity-getter','own-call','call-getter'])
    add(name+':'+mode,(m,e)=>{const f=m.G[name],code=f.code,env=f.env,bound=f.bound,arity=f.arity;
      if(mode==='global-getter')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
      for(const [key,value]of [['code',code],['env',env],['bound',bound],['arity',arity]])if(mode===key+'-getter')Object.defineProperty(f,key,{configurable:true,get(){e.push(key+':'+name);return value;}});
      if(mode==='env-value')f.env={tag:'nullary-env'};
      const call=function(receiver,a){e.push('call:'+name);return Reflect.apply(code,receiver,[a]);};
      if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:call});
      if(mode==='call-getter')Object.defineProperty(code,'call',{configurable:true,get(){e.push('get-call:'+name);return call;}});
      return m.default.bench();},{live:mode!=='env-value'});
  for(const [name,args]of [['no-arguments',[]],['vector',[[]]],['forged-permission',[[],true]]])
    add('raw-code:'+name,(m,e)=>m.call(Reflect.apply(m.G.bench.code,{rawReceiver:true},args),[]),{live:false});
  add('raw-code-call',(m,e)=>m.call(m.G.bench.code.call({rawReceiver:true},[]),[]),{live:false});
  for(const args of [[],[[]],[[],true]])add('construct-code:'+args.length,(m,e)=>{
    const code=m.G.bench.code,value=Reflect.construct(code,args),forced=m.call(value,[]);
    return forced===value&&Object.getPrototypeOf(value)===code.prototype?{kind:'instance',keys:Reflect.ownKeys(value).map(String)}:{kind:'result',value:forced};},{live:false});
  add('bound-value',(m,e)=>{m.G.bench.bound=[1];return m.default.bench();},{live:false,throws:true});
  add('root-code-replacement',(m,e)=>{m.G.bench.code=function(){e.push('root');return 73;};return m.default.bench();});
  add('root-global-replacement',(m,e)=>{m.G.bench={arity:0,code:function(){e.push('root');return 73;},env:null,bound:[]};return m.default.bench();});
  add('overapplied-root',(m,e)=>m.call(m.G.bench,[1]),{live:false,throws:true});
  add('helper-replacement',(m,e)=>{const old=m.G['demand.left'];m.G['demand.left']={...old,code:()=>{e.push('replacement');return 12;}};return m.default.bench();});
  // Observe raw demand before forcing. Read own data fields only after restoring
  // the host prototype; never compare generated function source text.
  function rawShape(m,value,seen=new Map()){
    if(value===null||typeof value!=='object'&&typeof value!=='function')return typeof value==='bigint'?{$bigint:String(value)}:value;
    if(typeof value==='function')return {function:true,name:value.name,length:value.length,owners:Object.entries(Object.getOwnPropertyDescriptors(m.G)).filter(([_k,d])=>d.value?.code===value).map(([k])=>k).sort()};
    if(seen.has(value))return {ref:seen.get(value)};const id=seen.size;seen.set(value,id);
    const fields=[];for(const key of Reflect.ownKeys(value)){const d=Object.getOwnPropertyDescriptor(value,key);assert(Object.hasOwn(d,'value'),'Raw data-only message');fields.push([String(key),rawShape(m,d.value,seen)]);}
    return {id,kind:Array.isArray(value)?'array':'object',fields};}
  for(const mode of ['direct','call','construct'])add('missing-vector-inherited-zero:'+mode,(m,e)=>{
    let reads=0,demand='';m.G['demand.left'].code=()=>{demand+='L';return 9;};
    const prototype=Object.prototype,saved=Object.getOwnPropertyDescriptor(prototype,'0'),code=m.G.bench.code;let raw;
    try{Object.defineProperty(prototype,'0',{configurable:true,get(){reads++;return undefined;}});
      raw=mode==='direct'?code():mode==='call'?code.call({rawReceiver:true}):Reflect.construct(code,[]);
    }finally{if(saved)Object.defineProperty(prototype,'0',saved);else delete prototype[0];}
    // All assertion/array work occurs after restoration. The missing arguments
    // vector must not be fetched through Object.prototype by the wrapper.
    assert.equal(reads,0,'No inherited missing argument read');assert.equal(demand,'LL','Both nullary loads demanded before raw return');
    assert.equal(raw?.bounce,true,'Original unforced tail message');const shape=rawShape(m,raw),beforeForce=demand;
    const result=m.call(raw,[]);assert.equal(result,81);assert.equal(demand,'LL','No new helper demand from forcing');
    return {reads,beforeForce,afterForce:demand,shape,result};},{live:false});
  for(const spec of specs){const observations=modules.slice(0,2).map(m=>observe(m,spec.action));report.current={name:spec.name,observations};assert.deepEqual(observations[1],observations[0],spec.name);
    assert.equal(Boolean(observations[0].error),spec.throws,spec.name+' throw');if(spec.live)assert(observations[0].events.length,spec.name+' live hook');
    const before=witness.p45NullaryCounts(),observed=observe(witness,spec.action),after=witness.p45NullaryCounts();assert.deepEqual(observed,observations[1],spec.name+' derivative');
    if(spec.refuses)assert.deepEqual(after,before,spec.name+' private refusal');report.boundaries.push({...report.current,countsBefore:before,countsAfter:after});delete report.current;}
  function sourceError(m,reenter){const descriptor=Object.getOwnPropertyDescriptor(globalThis,'Error'),OriginalError=Error,events=[];let caught;
    const message='a Nat past the largest immediate 2^48-1';
    try{Object.defineProperty(globalThis,'Error',{configurable:true,writable:true,value:function(...args){events.push(['Error',String(args[0])]);
      if(reenter)events.push(['reentry',m.default.bench()]);return Reflect.apply(OriginalError,this,args);}});
      try{m.default.overflow();}catch(error){caught={name:error.name,message:error.message};}
    }finally{Object.defineProperty(globalThis,'Error',descriptor);}
    assert.equal(caught?.message,message);assert.deepEqual(events,reenter?[['Error',message],['reentry',81]]:[['Error',message]]);
    const replay=m.default.ordered();assert.equal(replay,5);return {caught,events,replay};}
  for(const reenter of [false,true]){const observations=modules.slice(0,2).map(m=>sourceError(m,reenter));assert.deepEqual(observations[1],observations[0]);
    const before=witness.p45NullaryCounts(),actual=sourceError(witness,reenter),after=witness.p45NullaryCounts();assert.deepEqual(actual,observations[1]);
    assert.equal(after.overflow-before.overflow,1,'Real failing private entry');assert.equal(after.bench-before.bench,reenter?1:0);assert.equal(after.ordered-before.ordered,1,'Restored permission replay');
    report.boundaries.push({name:'source-overflow-reentry:'+reenter,observations});report.activation.push({name:'source-overflow-reentry:'+reenter,before,after});}
  for(const row of pinned.values())assert.deepEqual(identity(row.path),row,'Input changed');assert.deepEqual(identity(derivativeFile),report.derivative.module);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,error:report.error}));
