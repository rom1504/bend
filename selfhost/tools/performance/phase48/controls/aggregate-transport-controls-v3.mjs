// Untimed source, allocation and public-boundary controls. No timing authority.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';import vm from 'node:vm';
const [baseline,candidate,output]=process.argv.slice(2);assert(output,'aggregate-transport-controls-v3.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase48-aggregate-transport-source-controls',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],activation:[],
  scope:'Independent renamed state graph, non-tail private returns, record shell, demand/errors, persistent aliases and mutable public ABI; diagnostic allocation counts, no timing.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,desc=Object.getOwnPropertyDescriptor;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const MAX=281474976710655n,wrap=x=>x>>>0;
function oracle(n,seed){let previous=seed%5,runs=1,sum=0;for(let i=0;i<n;i++){const value=wrap(seed+i)%5;if(value!==previous)runs++;previous=value;sum=wrap(sum+value);}return wrap(runs*1009+sum);}
function deepOracle(n,x){let sum=0;for(let i=0;i<=n;i++){const y=wrap(x+i);sum=wrap(sum+wrap(wrap(y*2)^wrap(y+1)));}return sum;}
const recordOracle=x=>wrap(wrap(wrap(x+2)*2)+wrap(x+7)+Math.imul(x,3));
const errorView=e=>({name:e?.name??null,message:e?.message??String(e)});
function boundary(m,mode){const events=[],restore=[],token=new Error('aggregate field sentinel');let value,error,caughtToken=false;
  function patch(owner,key,d){const old=desc(owner,key);restore.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...d});}
  function instrument(name,throws=false){const f=m.G[name];assert(f,'Missing '+name);const code=f.code;patch(f,'code',{writable:true,value:function(args){events.push(name);if(throws)throw token;return apply(code,this,[args]);}});}
  try{
    if(['field-order','left-throws','right-throws'].includes(mode)){instrument('signal.left',mode==='left-throws');instrument('signal.right',mode==='right-throws');value=m.default.ordered(5);}
    else if(mode==='unused-field-throws'){instrument('Nat.add',true);value=m.default.checked_field(7,0n);}
    else if(mode==='error-reentry'){
      const Original=globalThis.Error;let busy=false;patch(globalThis,'Error',{writable:true,value:function(message){events.push(['error',String(message)]);if(!busy){busy=true;events.push(['nested',m.default.deep(73,9),m.default.bench(8,3)]);busy=false;}return new Original(message);}});value=m.default.checked_field(7,MAX);
    }else if(mode==='public-projection-getters'){
      const p=m.default.public_pair(5);for(const i of [0,1]){const v=p[i];define(p,String(i),{configurable:true,get(){events.push(['field',i]);return v;}});}value=m.default['tower.read'](p);
    }else{
      const name='parcel.step',f=m.G[name],code=f.code;
      if(mode==='source-global-getter')patch(m.G,name,{get(){events.push('global');return f;}});
      else if(mode==='source-code-getter')patch(f,'code',{get(){events.push('code');return code;}});
      else if(mode==='source-env-getter'){const env=f.env;patch(f,'env',{get(){events.push('env');return env;}});}
      else if(mode==='source-bound-getter'){const bound=f.bound;patch(f,'bound',{get(){events.push('bound');return bound;}});}
      else if(mode==='source-call')patch(code,'call',{writable:true,value:function(env,args){events.push('call');return apply(code,env,[args]);}});
      else if(mode==='source-delegating-reentry'){let busy=false;patch(f,'code',{writable:true,value:function(args){events.push('step');if(!busy){busy=true;events.push(['nested',m.default.deep(41,7)]);busy=false;}return apply(code,this,[args]);}});}
      else throw Error('Unknown mode '+mode);
      value=m.default.bench(3,5);
    }
  }catch(e){error=errorView(e);caughtToken=e===token;}finally{for(let i=restore.length-1;i>=0;i--)restore[i]();}
  if(mode.endsWith('throws')){assert(error);assert(caughtToken,'Thrown field identity must survive');}
  else if(mode==='error-reentry'){assert.equal(error?.message,'a Nat past the largest immediate 2^48-1');assert(events.some(x=>Array.isArray(x)&&x[0]==='nested'));}
  else assert.equal(error,undefined,mode+' unexpected error');
  if(mode==='field-order')assert.deepEqual(events,['signal.left','signal.right']);
  if(mode==='left-throws')assert.deepEqual(events,['signal.left']);
  if(mode==='right-throws')assert.deepEqual(events,['signal.left','signal.right']);
  assert(events.length,mode+' witness must run');return{value,error,caughtToken,events};
}
function nodes(node){const result=[];function visit(x){if(!x||typeof x!=='object')return;if(typeof x.type==='string')result.push(x);for(const y of Object.values(x))if(Array.isArray(y))y.forEach(visit);else if(y&&typeof y==='object')visit(y);}visit(node);return result;}
try{
  pin(import.meta.filename);pin(process.execPath);
  pin(path.join(import.meta.dirname,"aggregate-transport-controls-v1.mjs"));
  pin(path.join(import.meta.dirname,"aggregate-transport-controls-v2.mjs"));fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const cat=pin(path.join(import.meta.dirname,'aggregate-transport-catalog-v3.json')),catalog=JSON.parse(fs.readFileSync(cat.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[],files=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,cat.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});files.push(module.path);modules.push(await import(pathToFileURL(module.path)));
  }
  const check=(name,args,want)=>{const values=modules.map(m=>m.default[name](...args));for(const v of values)assert.deepEqual(v,want,name);report.oracles.push({name,args,expected:want,values});};
  for(const n of [0,1,2,8,33,129])for(const seed of [0,3,17,4294967295])check('bench',[n,seed],oracle(n,seed));
  for(const n of [0,1,7,33,129,513])for(const x of [0,9,4294967295])check('deep',[n,x],deepOracle(n,x));
  for(const x of [0,1,17,4294967295]){
    check('record',[x],recordOracle(x));check('ordered',[x],wrap(wrap(wrap(x+11)*2)^wrap(x+23)));
    check('public_pair',[x],[wrap(x+11),wrap(x+23)]);
    for(const n of [0n,1n,4294967296n,MAX-1n])check('checked_field',[x,n],x);
    for(const m of modules){const v=m.default.public_record(x);assert.equal(v.$,'Drawer');assert.deepEqual(v.a,[wrap(x+2),wrap(x+7)]);
      const shared=m.default.public_shared(x);assert.equal(shared[0],shared[1]);shared[0].a[0]=41;assert.equal(shared[1].a[0],41);}
    report.oracles.push({name:'public_record+shared',args:[x],publicTag:'Drawer',sharedIdentity:true});
  }
  const errors=modules.map(m=>{try{m.default.checked_field(7,MAX);return null;}catch(e){return errorView(e);}});assert(errors[0]);assert.deepEqual(errors[1],errors[0]);
  assert.equal(errors[0].message,'a Nat past the largest immediate 2^48-1');report.boundaries.push({name:'unused-checked-overflow',errors});
  for(const name of ['field-order','left-throws','right-throws','unused-field-throws','error-reentry','public-projection-getters','source-global-getter','source-code-getter','source-env-getter','source-bound-getter','source-call','source-delegating-reentry']){
    const observations=modules.map(m=>boundary(m,name));assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});
    for(const m of modules){assert.equal(m.default.bench(8,3),oracle(8,3));assert.equal(m.default.deep(73,9),deepOracle(73,9));}
  }
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parserModule={exports:{}};
  vm.runInThisContext('(function(exports,module){'+parserSource+'\n})')(parserModule.exports,parserModule);
  const parse=text=>parserModule.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'}),diagnostics=[];
  for(const [role,file]of files.entries()){
    const text=fs.readFileSync(file,'utf8'),all=nodes(parse(text)),edits=[];
    for(const name of ['bench','deep']){
      const found=all.filter(n=>n.type==='AssignmentExpression'&&n.operator==='='&&n.left.type==='MemberExpression'&&n.left.computed&&n.left.object.name==='G'&&n.left.property.value===name);
      assert.equal(found.length,1,'unique selected '+name);const rhs=found[0].right,part=text.slice(rhs.start,rhs.end),marker='/* private contextual instances */';
      assert.equal(part.split(marker).length-1,1,'one contextual '+name);if(role)assert(part.includes('/* private scalar tuple transport */'),'actual transformed '+name);
      const at=rhs.start+part.indexOf(marker)+marker.length;edits.push([at,'$p48Entries++;']);
      for(const n of nodes(rhs))if(n.type==='ArrayExpression'){edits.push([n.start,'($p48Arrays++,'],[n.end,')']);}
    }
    let instrumented=text;for(const [at,s]of edits.sort((a,b)=>b[0]-a[0]))instrumented=instrumented.slice(0,at)+s+instrumented.slice(at);
    instrumented='let $p48Arrays=0,$p48Entries=0;\n'+instrumented+'\nexport const p48Counters=()=>({arrays:$p48Arrays,entries:$p48Entries});export function p48Reset(){$p48Arrays=0;$p48Entries=0;}\n';parse(instrumented);
    const derivative=path.join(out,(role?'candidate':'baseline')+'-diagnostic.mjs');fs.writeFileSync(derivative,instrumented,{flag:'wx'});report.modules[role].diagnostic=identity(derivative);diagnostics.push(await import(pathToFileURL(derivative)));
  }
  for(const n of [0,1,8]){const observations=diagnostics.map(m=>{m.p48Reset();const value=m.default.bench(n,3);assert.equal(value,oracle(n,3));return{value,...m.p48Counters()};});
    for(const o of observations)assert.equal(o.entries,1);assert.equal(observations[0].arrays-observations[1].arrays,2*n+2,'two transient shells per step plus initial state');
    report.activation.push({name:'state-allocation',n,expectedRemoved:2*n+2,observations});}
  for(const m of diagnostics){m.p48Reset();assert.equal(m.default.deep(513,9),deepOracle(513,9));assert.equal(m.p48Counters().entries,1);}
  report.activation.push({name:'non-tail-multiple-results',depth:513,expected:deepOracle(513,9)});
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);
  for(const row of report.modules)assert.deepEqual(identity(row.diagnostic.path),row.diagnostic);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,activation:report.activation.length,error:report.error}));
