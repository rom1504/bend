// Finite exact Nat oracles and public-ABI controls; no timing or source fault injection.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseline,candidate,typescript,output]=process.argv.slice(2);
assert(output,'number-nat-controls-v2.mjs BASELINE_MODULE CANDIDATE_MODULE TS_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase45-number-nat-controls',controllerVersion:2,complete:false,pass:false,inputs:[],modules:[],oracles:[],errors:[],boundaries:[],activation:[],
  scope:'All16 public fixture roots. Exact BigInt mathematics and typed public Nat ABI across all3roles; exact selfhost predecessor/candidate mutation and error observations. Derivative counters are untimed.',
  boundaryCorrection:'Version1 confused TypeScript internal Number Nats with its exported typed ABI. Acquired wrappers use nat_host for inputs and BigInt for Nat outputs, including Counter fields. Version2 passes shared BigInt arguments and requires exact BigInt outputs; it does not accept arbitrary output coercions.'};
const identity=p=>{const file=fs.realpathSync(p),bytes=fs.readFileSync(file);return {path:file,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const pinned=new Map();
function pin(file,want){const got=identity(file);if(want){assert.equal(got.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(got.bytes,want.bytes);}
  if(pinned.has(got.path))assert.deepEqual(got,pinned.get(got.path));else{pinned.set(got.path,got);report.inputs.push(got);}return got;}
function audit(x){if(Array.isArray(x))x.forEach(audit);else if(x&&typeof x==='object'){const file=x.file??x.path;if(typeof file==='string'&&x.sha256)pin(file,x);Object.values(x).forEach(audit);}}
const scalar=x=>({type:typeof x,value:x===null?'null':String(x)});
const thrown=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function restorePoint(m){const objects=[m.G];for(const d of Object.values(Object.getOwnPropertyDescriptors(m.G)))if(d.value&&typeof d.value==='object')
  for(const x of [d.value,d.value.code,d.value.bound])if(x&&(typeof x==='object'||typeof x==='function'))objects.push(x);
  const saved=[...new Set(objects)].map(x=>[x,Object.getOwnPropertyDescriptors(x),Object.getPrototypeOf(x)]);
  return ()=>{for(const [x,ds,proto]of saved){for(const k of Reflect.ownKeys(x))if(!Object.hasOwn(ds,k))delete x[k];Object.setPrototypeOf(x,proto);Object.defineProperties(x,ds);}};}
function observe(m,action){const restore=restorePoint(m),events=[];let value,error;try{value=scalar(action(m,events));}catch(e){error=thrown(e);}finally{restore();}return {value,error,events};}
function nodes(root){const out=[],todo=[root];while(todo.length){const n=todo.pop();if(!n||typeof n!=='object'||typeof n.type!=='string')continue;out.push(n);
  for(const x of Object.values(n))if(Array.isArray(x))todo.push(...x);else if(x&&typeof x==='object')todo.push(x);}return out;}
const B=4294967296n,M=281474976710655n,mask=B-1n,overflowMessage='a Nat past the largest immediate 2^48-1';
const covered=new Set(),cases=[],failures=[];
const add=(name,args,expected)=>cases.push({name,args,expected});
for(const x of [0n,1n,B-1n,B,B+1n,M-1n,M]){add('identity',[x],x);add('to_word',[x],Number(x&mask));}
for(const x of [0,1,7,4294967295]){add('bench',[x],Number((mask+BigInt(x))&mask));add('from_word',[x],BigInt(x));}
for(const x of [0n,1n,M-B+1n])add('constructed',[x],mask+x);
for(const x of [0n,B-1n,B,M-1n])for(const name of ['successor','nested','error_check'])add(name,[x],x+1n);
for(const [a,b]of [[0n,M],[M,0n],[M-1n,1n],[B-1n,1n],[B,B+1n]]){add('add',[a,b],a+b);add('subtract',[a,b],a>b?a-b:0n);add('less',[a,b],a<b);}
for(const a of [0n,1n,B-1n,B,B+1n,M-1n,M])for(const b of [0n,1n,2n,3n,65537n,B,M-1n,M]){
  add('quotient',[a,b],b===0n?0n:a/b);add('remainder',[a,b],b===0n?a:a%b);}
for(const x of [0,1,2147483649,4294967295])for(const n of [0n,1n,31n,32n,B,M]){
  add('shift_left',[x,n],n>=32n?0:Number((BigInt(x)<<n)&mask));add('shift_right',[x,n],n>=32n?0:Number(BigInt(x)>>n));}
for(const [name,args]of [['add',[M,1n]],['successor',[M]],['constructed',[M-B+2n]],['nested',[M]],['error_check',[M]]])failures.push({name,args});
try{
  pin(import.meta.filename);pin(process.execPath);report.previousController=pin(path.join(import.meta.dirname,'number-nat-controls.mjs'));
  const catalogFile=path.join(import.meta.dirname,'number-nat-catalog.json'),catalogId=pin(catalogFile),catalog=JSON.parse(fs.readFileSync(catalogFile,'utf8'));
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source);
  report.parseRefusal={fixture:pin(path.join(import.meta.dirname,'fixtures/number-nat-too-large.bend')),executed:false,reason:'Requires separate checked frontend refusal run.'};
  const modules=[],texts=[];
  for(const [i,file]of [baseline,candidate,typescript].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),emission=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(emission.kind,'bend-program-checked-emission');assert.equal(emission.complete,true);assert.equal(emission.observation.checked,true);assert.equal(emission.observation.status,'ok');
    assert.equal(emission.input.sha256,source.sha256);assert.equal(emission.output.sha256,module.sha256);assert.equal(emission.catalog.sha256,catalogId.sha256);
    assert.equal(emission.compiler.upstreamCommit,catalog.upstreamCommit);assert.equal(emission.compiler.kind,i===2?'checked-pinned-typescript':'checked-development-attempt');audit(emission);
    report.modules.push({role:['baseline','candidate','typescript'][i],module,receipt,compiler:emission.compiler});texts.push(fs.readFileSync(module.path,'utf8'));modules.push(await import(pathToFileURL(module.path)));
  }
  for(const row of cases){const values=modules.map(m=>m.default[row.name](...row.args));
    assert.equal(values[0],row.expected,row.name);assert.equal(values[1],row.expected,row.name);assert.equal(values[2],row.expected,row.name+' TS typed ABI');
    covered.add(row.name);report.oracles.push({...row,values});}
  for(const x of [0n,B,M]){const values=modules.map(m=>m.default.public_counter(x));
    for(const [i,value]of values.entries()){assert.equal(value.$,'Counter');const field=i===2?value.value:value.a[0];assert.equal(field,x);assert.equal(typeof field,'bigint');}
    report.oracles.push({name:'public_counter',args:[x],expected:x,fields:values.map((v,i)=>i===2?v.value:v.a[0])});covered.add('public_counter');}
  const roots=['bench','identity','constructed','successor','add','subtract','less','quotient','remainder','to_word','from_word','shift_left','shift_right','error_check','nested','public_counter'];
  assert.deepEqual([...covered].sort(),[...roots].sort());report.coveredRoots=[...covered].sort();
  for(const row of failures){const errors=modules.map((m,i)=>{try{m.default[row.name](...row.args);return null;}catch(e){return thrown(e);}});
    assert.deepEqual(errors[1],errors[0],row.name);assert.equal(errors[0]?.name,'Error');assert.equal(errors[0]?.message,overflowMessage);assert(errors[2],row.name+' TS overflow');report.errors.push({...row,errors});}
  const specs=[];
  for(const x of [-1n,M+1n,0,'1',null])specs.push({name:'invalid-identity:'+String(x),action:m=>m.default.identity(x)});
  for(const name of ['Number','BigInt'])for(const mode of ['wrapper','getter'])for(const [root,arg]of [['identity',B+1n],['constructed',1n]])
    specs.push({name:name+':'+mode+':'+root,action:(m,e)=>{const old=Object.getOwnPropertyDescriptor(globalThis,name),original=old.value;
      const wrapped=function(...args){e.push([name,'call']);return Reflect.apply(original,this,args);};
      try{Object.defineProperty(globalThis,name,{configurable:true,...(mode==='getter'?{get(){e.push([name,'get']);return original;}}:{writable:true,value:wrapped})});
        return m.default[root](arg);}finally{Object.defineProperty(globalThis,name,old);}}});
  for(const [name,root,args]of [['nat.keep','constructed',[1n]],['Nat.add','constructed',[1n]],['Nat.divmod','quotient',[M,B]]])
    for(const mode of ['code','global-getter','code-getter','own-call'])specs.push({name:name+':'+mode,live:true,action:(m,e)=>{const f=m.G[name],code=f.code;
      if(mode==='code')f.code=function(a){e.push(name);return Reflect.apply(code,this,[a]);};
      if(mode==='global-getter')Object.defineProperty(m.G,name,{configurable:true,get(){e.push(name);return f;}});
      if(mode==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push(name);return code;}});
      if(mode==='own-call')Object.defineProperty(code,'call',{configurable:true,value:function(env,a){e.push(name);return Reflect.apply(code,env,[a]);}});
      return m.default[root](...args);}});
  specs.push({name:'native-thrown-identity',live:true,action:(m,e)=>{const token=new Error('Nat sentinel');m.G['Nat.add'].code=()=>{e.push('Nat.add');throw token;};
    let caught=false;try{m.default.constructed(1n);}catch(error){assert.equal(error,token);caught=true;}assert(caught);return 7n;}});
  for(const spec of specs){const observations=modules.slice(0,2).map(m=>observe(m,spec.action));assert.deepEqual(observations[1],observations[0],spec.name);
    if(spec.live)assert(observations[0].events.length,spec.name+' must execute hook');report.boundaries.push({name:spec.name,observations});}
  function overflow(m,reenter){const old=Object.getOwnPropertyDescriptor(globalThis,'Error'),OriginalError=Error,events=[];let error;
    try{Object.defineProperty(globalThis,'Error',{configurable:true,writable:true,value:function(...args){events.push(['Error',String(args[0])]);
      if(reenter)events.push(['nested',scalar(m.default.error_check(0n))]);return Reflect.apply(OriginalError,this,args);}});
      try{m.default.error_check(M);}catch(e){error=thrown(e);}
    }finally{Object.defineProperty(globalThis,'Error',old);}
    assert.equal(error?.message,overflowMessage);assert.deepEqual(events,reenter?[['Error',overflowMessage],['nested',scalar(1n)]]:[['Error',overflowMessage]]);
    const replay=m.default.error_check(7n);assert.equal(replay,8n);return {error,events,replay};}
  for(const reenter of [false,true]){const observations=modules.slice(0,2).map(m=>overflow(m,reenter));assert.deepEqual(observations[1],observations[0]);report.boundaries.push({name:'Error-hook:'+reenter,observations});}
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};new Function('module','exports',parserSource)(parserModule,parserModule.exports);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),ast=nodes(parse(texts[1]));
  const assignments=ast.filter(n=>n.type==='AssignmentExpression'&&n.left.type==='MemberExpression'&&n.left.object.type==='Identifier'&&n.left.object.name==='G'&&n.left.computed&&n.left.property.type==='Literal');
  const publicRows=assignments.filter(n=>n.left.property.value==='public_counter');assert(publicRows.length>0);
  for(const n of publicRows)assert(!/private contextual instances|private Number Nat/.test(texts[1].slice(n.right.start,n.right.end)),'Object result admitted privately');
  report.publicCounterAssignments=publicRows.map(n=>({start:n.start,end:n.end,generic:true}));
  const marker='/* private Number Nat */',entry='/* private contextual instances */',numberRows=assignments.filter(n=>texts[1].slice(n.right.start,n.right.end).includes(marker));
  assert(numberRows.length>0,'No Number-Nat root declarations');const edits=[];
  for(const n of numberRows){const text=texts[1].slice(n.right.start,n.right.end);assert.equal(text.split(entry).length-1,1);
    edits.push({at:n.right.start+text.indexOf(entry)+entry.length,name:n.left.property.value});}
  assert(!texts[1].includes('$p45NatEntries'));let derived=texts[1];
  for(const {at,name}of [...edits].sort((a,b)=>b.at-a.at)){const key=JSON.stringify(name);derived=derived.slice(0,at)+`$p45NatEntries[${key}]=($p45NatEntries[${key}]??0)+1;`+derived.slice(at);}
  derived='const $p45NatEntries=Object.create(null);\n'+derived+'\nexport const p45NatEntries=()=>({...$p45NatEntries});\n';parse(derived);
  const file=path.join(out,'candidate-counter.mjs');fs.writeFileSync(file,derived,{flag:'wx'});const witness=await import(pathToFileURL(file));
  report.derivative={module:identity(file),source:report.modules[1].module,edits,parser:{version:parserModule.exports.version,sha256:createHash('sha256').update(parserSource).digest('hex')},performanceEvidence:false};
  for(const row of cases.filter(x=>['bench','constructed','quotient','nested','error_check'].includes(x.name))){const before=witness.p45NatEntries()[row.name]??0,value=witness.default[row.name](...row.args),entries=(witness.p45NatEntries()[row.name]??0)-before;
    assert.equal(value,row.expected);assert.equal(entries,1,row.name+' Number-Nat entry');report.activation.push({name:row.name,args:row.args,entries});}
  for(const reenter of [false,true]){const before=witness.p45NatEntries().error_check??0,observation=overflow(witness,reenter),entries=(witness.p45NatEntries().error_check??0)-before;
    assert.deepEqual(observation,report.boundaries.find(x=>x.name==='Error-hook:'+reenter).observations[1]);assert.equal(entries,reenter?3:2);report.activation.push({name:'source-overflow:'+reenter,entries});}
  for(const item of pinned.values())assert.deepEqual(identity(item.path),item,'Changed input');assert.deepEqual(identity(file),report.derivative.module);
  report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,roots:report.coveredRoots?.length,oracles:report.oracles.length,errors:report.errors.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
