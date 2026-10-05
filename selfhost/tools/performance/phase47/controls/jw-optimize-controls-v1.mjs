// Untimed checked-source controls for composable worker helper/aggregate passes.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [baseline,candidate,output]=process.argv.slice(2);assert(output,'jw-optimize-controls-v1.mjs BASELINE_MODULE CANDIDATE_MODULE NEW_OUT');
const out=path.resolve(output);fs.mkdirSync(out);
const report={kind:'phase47-worker-optimization-source-controls',complete:false,pass:false,inputs:[],modules:[],oracles:[],boundaries:[],
  scope:'Checked Bend values, checked-error preservation and public ABI/host observations. No timing; pass activation requires separate IR evidence.'};
const pinned=new Map(),apply=Reflect.apply,define=Object.defineProperty,desc=Object.getOwnPropertyDescriptor;
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{path:file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes);}if(pinned.has(x.path))assert.deepEqual(x,pinned.get(x.path));else{pinned.set(x.path,x);report.inputs.push(x);}return x;}
function audit(v){if(Array.isArray(v))v.forEach(audit);else if(v&&typeof v==='object'){const file=v.path??v.file??v.canonicalPath;if(typeof file==='string'&&v.sha256)pin(file,v);Object.values(v).forEach(audit);}}
const MAX=281474976710655n,wrap=x=>x>>>0,tagged=x=>wrap(wrap(x+2)*2+wrap(x+7));
function recurrence(n,x){for(let i=0;i<n;i++)x=(wrap(x+1)^Math.imul(x,3))>>>0;return x;}
const errorView=e=>({type:typeof e,name:e?.name??null,message:e?.message??String(e)});
function boundary(m,mode){const events=[],restore=[],token=new Error('worker field sentinel');let value,error,caughtToken=false;
  function patch(owner,key,d){const old=desc(owner,key);restore.push(()=>old?define(owner,key,old):delete owner[key]);define(owner,key,{configurable:true,...d});}
  function instrument(name,throws=false){const f=m.G[name];assert(f,'Missing '+name);const code=f.code;
    patch(f,'code',{writable:true,value:function(args){events.push(name);if(throws)throw token;return apply(code,this,[args]);}});}
  try{
    if(mode==='field-order'||mode==='left-throws'||mode==='right-throws'){
      instrument('signal.left',mode==='left-throws');instrument('signal.right',mode==='right-throws');value=m.default.ordered(5);
    }else if(mode==='unused-field-throws'){instrument('Nat.add',true);value=m.default.checked_field(7,0n);}
    else if(mode==='reentry'){
      const f=m.G['signal.left'],code=f.code;let busy=false;patch(f,'code',{writable:true,value:function(args){events.push('left');if(!busy){busy=true;events.push(['nested',m.default.tagged(9)]);busy=false;}return apply(code,this,[args]);}});value=m.default.ordered(5);
    }else if(mode==='public-projection-getters'){
      const x=m.default.public_record(5);for(const i of [0,1]){const v=x.a[i];define(x.a,String(i),{configurable:true,get(){events.push(['field',i]);return v;}});}value=m.default.public_consume(x);
    }else{
      const name='prism.pair',f=m.G[name],code=f.code;
      if(mode==='source-global-getter')patch(m.G,name,{get(){events.push('global');return f;}});
      else if(mode==='source-code-getter')patch(f,'code',{get(){events.push('code');return code;}});
      else if(mode==='source-call')patch(code,'call',{writable:true,value:function(env,args){events.push('call');return apply(code,env,[args]);}});
      else if(mode==='source-unknown-result')patch(f,'code',{writable:true,value:function(){events.push('replacement');return [101,211];}});
      else throw Error('Unknown mode '+mode);
      value=m.default.bench(3,5);
    }
  }catch(e){error=errorView(e);caughtToken=e===token;}finally{for(let i=restore.length-1;i>=0;i--)restore[i]();}
  if(mode.endsWith('throws')){assert(error);assert(caughtToken,'Thrown field identity must survive');}
  else assert.equal(error,undefined,mode+' unexpected error');
  if(mode==='field-order')assert.deepEqual(events,['signal.left','signal.right']);
  if(mode==='left-throws')assert.deepEqual(events,['signal.left']);
  if(mode==='right-throws')assert.deepEqual(events,['signal.left','signal.right']);
  assert(events.length,mode+' witness must run');return{value,error,caughtToken,events};
}
try{
  pin(import.meta.filename);pin(process.execPath);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  const cat=pin(path.join(import.meta.dirname,'jw-optimize-catalog-v1.json')),catalog=JSON.parse(fs.readFileSync(cat.path,'utf8'));
  assert.equal(catalog.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');
  const source=pin(path.join(import.meta.dirname,catalog.cases[0].source.path),catalog.cases[0].source),modules=[];
  for(const [i,file]of [baseline,candidate].entries()){
    const module=pin(file),receipt=pin(module.path+'.json'),r=JSON.parse(fs.readFileSync(receipt.path,'utf8'));
    assert.equal(r.kind,'bend-program-checked-emission');assert.equal(r.complete,true);assert.equal(r.observation.checked,true);assert.equal(r.observation.status,'ok');
    assert.equal(r.output.sha256,module.sha256);assert.equal(r.input.sha256,source.sha256);assert.equal(r.catalog.sha256,cat.sha256);
    assert.equal(r.compiler.upstreamCommit,catalog.upstreamCommit);assert(['checked-development-attempt','installed-checked-release'].includes(r.compiler.kind));audit(r);
    report.modules.push({role:i?'candidate':'baseline',module,receipt,compiler:r.compiler});modules.push(await import(pathToFileURL(module.path)));
  }
  const check=(name,args,want)=>{const values=modules.map(m=>m.default[name](...args));for(const v of values)assert.deepEqual(v,want,name);report.oracles.push({name,args,expected:want,values});};
  for(const n of [0,1,2,5,33,129])for(const x of [0,1,17,4294967295])check('bench',[n,x],recurrence(n,x));
  for(const x of [0,1,17,4294967295]){
    check('tagged',[x],tagged(x));check('mismatch',[x],wrap(x^85));check('ordered',[x],wrap(wrap(x+11)*2+wrap(x+23)));
    for(const flag of [true,false,true])check('branch',[flag,x],flag?tagged(wrap(x+3)):wrap((x^9)^85));
    check('public_pair',[x],[wrap(x+1),Math.imul(x,3)>>>0]);
    for(const n of [0n,1n,4294967296n,MAX-1n])check('checked_field',[x,n],x);
    for(const m of modules){const v=m.default.public_record(x);assert.equal(v.$,'Lantern');assert.deepEqual(v.a,[wrap(x+2),wrap(x+7)]);v.a[0]=41;assert.equal(m.default.public_consume(v),wrap(82+wrap(x+7)));}
    report.oracles.push({name:'public_record',args:[x],publicTag:'Lantern',fields:[wrap(x+2),wrap(x+7)],mutatedField:41});
  }
  const errors=modules.map(m=>{try{m.default.checked_field(7,MAX);return null;}catch(e){return errorView(e);}});assert(errors[0]);assert.deepEqual(errors[1],errors[0]);
  assert.equal(errors[0].message,'a Nat past the largest immediate 2^48-1');report.boundaries.push({name:'unused-checked-overflow',errors});
  for(const name of ['field-order','left-throws','right-throws','unused-field-throws','reentry','public-projection-getters','source-global-getter','source-code-getter','source-call','source-unknown-result']){
    const observations=modules.map(m=>boundary(m,name));assert.deepEqual(observations[1],observations[0],name);report.boundaries.push({name,observations});}
  for(const x of pinned.values())assert.deepEqual(identity(x.path),x);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,(_k,v)=>typeof v==='bigint'?{$bigint:String(v)}:v,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,error:report.error}));
