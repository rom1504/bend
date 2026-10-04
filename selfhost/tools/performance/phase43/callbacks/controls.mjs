// Untimed exact-source prototype controls; no production callback admission claim.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash}from'node:crypto';import{pathToFileURL}from'node:url';
const[dirArg,outArg]=process.argv.slice(2);assert(dirArg&&outArg,'callback-controls.mjs DERIVED NEW_OUT');
const dir=fs.realpathSync(dirArg),out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const manifestFile=path.join(dir,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
const report={kind:'phase43-known-callback-controls',complete:false,pass:false,inputs:[identity(import.meta.filename),identity(manifestFile)],oracles:[],boundaries:[],admission:[]};
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const normalize=x=>typeof x==='bigint'?String(x)+'n':x===undefined?'[Undefined]':x;
function values(t){const a=[];while(t.$==='Con'){a.push(Array.isArray(t.a)?t.a[0]:t.head);t=Array.isArray(t.a)?t.a[1]:t.tail;}assert.equal(t.$,'Nil');return a;}
function snapshot(m){const ds=Object.getOwnPropertyDescriptors(m.G),objects=[];
 for(const d of Object.values(ds)){const f=d.value;if(f&&typeof f==='object')for(const o of[f,f.code,f.bound])if(o&&(typeof o==='function'||typeof o==='object'))objects.push([o,Object.getOwnPropertyDescriptors(o)]);}
 return()=>{for(const[o,old]of objects){for(const key of Reflect.ownKeys(o))if(!Object.hasOwn(old,key))delete o[key];Object.defineProperties(o,old);}for(const key of Reflect.ownKeys(m.G))if(!Object.hasOwn(ds,key))delete m.G[key];Object.defineProperties(m.G,ds);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
try{
 assert.equal(manifest.kind,'phase43-known-callback-prototype');assert.equal(manifest.complete,true);assert.equal(manifest.certified,false);
 for(const row of manifest.inputs){assert.deepEqual(identity(row.path),row);report.inputs.push(row);}
 const mods={};for(const row of manifest.modules.filter(r=>r.counters)){assert.deepEqual(identity(row.path),{path:row.path,sha256:row.sha256});report.inputs.push(identity(row.path));mods[row.variant]=await import(pathToFileURL(row.path));}
 assert.deepEqual(identity(manifest.typescript.module.path),manifest.typescript.module);report.inputs.push(manifest.typescript.module);
 const ts=await import(pathToFileURL(manifest.typescript.module.path)),catalog=JSON.parse(fs.readFileSync(manifest.catalog.path));
 for(const point of[...catalog.validationPoints,...catalog.cases.map(c=>({args:c.point.args,expected:c.point.expected}))]){
  const observed={};for(const[name,m]of Object.entries(mods)){m.callbackReset();const value=m.default.bench(...point.args),state=m.callbackState();assert.equal(value,point.expected);assert.equal(state.active,false);
   assert.equal(state.direct,name==='direct'?point.args[0]:0);assert.equal(state.generic,name==='direct'?0:point.args[0]);assert.equal(state.roots,name==='original'?0:1);observed[name]={value,state};}
  observed.typescript=ts.default.bench(...point.args);assert.equal(observed.typescript,point.expected);report.oracles.push({kind:'bench',...point,observed});
 }
 for(const point of catalog.validationPoints){const observed={};for(const[name,m]of Object.entries(mods)){m.callbackReset();const result=values(m.callbackOwnedResult(...point.args)),state=m.callbackState();assert.deepEqual(result,point.result);assert.equal(state.active,false);assert.equal(state.direct,name==='direct'?point.args[0]:0);observed[name]={result,state};}
  assert.deepEqual(values(ts.default['callback.result'](...point.args)),point.result);report.oracles.push({kind:'complete-materialized-list',...point,observed,scope:'Separate diagnostic scalar proof entry, not actual compiler admission.'});}
 for(const [name,m] of Object.entries(mods))for(const [n,seed] of [[0,17],[1,17],[3,4294967295],[7,12345]]){
  const one=m.callbackStages(n,seed),two=m.callbackStages(n,seed),captures=[];
  let fs=one.fs;while(fs.$==='CallbackMore'){captures.push(fs.a[0].bound[0]);fs=fs.a[1];}assert.equal(fs.$,'CallbackEnd');
  assert.deepEqual(captures,Array.from({length:n},(_,i)=>(seed+n-1-i)>>>0));
  const input=values(one.xs),result=values(one.result);assert.equal(input.length,n);assert.deepEqual(result,input.map((x,i)=>(x+captures[i])>>>0));
  assert.deepEqual(values(two.result),result);assert.notEqual(one.fs,two.fs);assert.notEqual(one.xs,two.xs);assert.notEqual(one.result,two.result);
  if(n){assert.notEqual(one.fs.a[0],two.fs.a[0]);assert.notEqual(one.fs.a[0].bound,two.fs.a[0].bound);assert.notEqual(one.result,one.xs);}
  report.oracles.push({kind:'complete-three-materialized-stages-and-fresh-captures',variant:name,n,seed,captures,input,result});
 }
 const observe=(m,action)=>{const restore=snapshot(m),events=[];m.callbackReset();let value,error;try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}const state=m.callbackState();assert.equal(state.active,false);return{value:normalize(value),error,events,state};};
 const boundary=(name,action,{live=false,refuse=false}={})=>{const observations=Object.fromEntries(Object.entries(mods).map(([n,m])=>[n,observe(m,action)]));report.current={name,observations};
  const comparable=x=>({value:x.value,error:x.error,events:x.events});for(const variant of['scoped','direct']){assert.deepEqual(comparable(observations[variant]),comparable(observations.original),name);if(refuse)assert.equal(observations[variant].state.roots,0);}
  if(live)assert(observations.original.events.length>0,'inactive control '+name);report.boundaries.push(report.current);delete report.current;};
 for(const name of manifest.dependencies)for(const mode of['code','code-getter','binding'])boundary('dependency:'+name+':'+mode,(m,e)=>{
  m.default.bench(2,17);m.callbackReset();const f=m.G[name],code=f.code;
  if(mode==='code')f.code=function(a){e.push('call:'+name);return Reflect.apply(code,this,[a]);};
  if(mode==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
  if(mode==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
  return m.default.bench(3,17);
 },{live:true,refuse:true});
 for(const name of['imul','number-bounce'])boundary('host:'+name,(m,e)=>{let entered=false;const event=()=>{e.push(name);if(!entered){entered=true;e.push(['nested',m.default.bench(0,17)]);}};
  if(name==='imul'){const old=Math.imul;return hook(Math,'imul',{value:function(a,b){event();return old(a,b);}},()=>m.default.bench(2,17));}
  return hook(Number.prototype,'bounce',{get(){event();return undefined;}},()=>m.default.bench(2,17));
 },{live:true,refuse:true});
 const force=(m,value)=>m.call({arity:0,code:()=>value,env:null,bound:[]},[]);
 for(const mode of['raw','forged','construct','partial','extra','slot-throw','slot-reentry','slot-mutation'])boundary('entry:'+mode,(m,e)=>{
  const f=m.G.bench,code=f.code;if(mode==='partial')return m.call(m.call(f,[3]),[17]);if(mode==='extra')return m.call(f,[3,17,0]);
  const args={length:2,0:3,1:17};if(mode.startsWith('slot-'))Object.defineProperty(args,'0',{get(){e.push('slot');if(mode==='slot-throw')throw Error('slot sentinel');if(mode==='slot-reentry')e.push(['nested',m.default.bench(0,17)]);if(mode==='slot-mutation'){const old=m.G['callback.offset'].code;m.G['callback.offset'].code=function(a){e.push('offset');return Reflect.apply(old,this,[a]);};}return 3;}});
  return force(m,mode==='construct'?Reflect.construct(code,[args]):Reflect.apply(code,null,[args,mode==='forged']));
 });
 const end=()=>({$:'CallbackEnd',a:[]}),more=(f,rest)=>({$:'CallbackMore',a:[f,rest]}),nil=()=>({$:'Nil',a:[]}),con=(x,rest)=>({$:'Con',a:[x,rest]});
 for(const mode of['distinct','retained-capture','code-getter','field-getter','early-error','late-error','callback-reentry'])boundary('public-callback:'+mode,(m,e)=>{
  const first=m.call(m.G['callback.offset'],[7]),second=m.call(m.G['callback.offset'],[19]);if(mode==='retained-capture')first.bound[0]=23;
  if(mode==='code-getter'){const code=first.code;Object.defineProperty(first,'code',{configurable:true,get(){e.push('callback.code');return code;}});}
  if(mode==='early-error'||mode==='late-error'){const target=mode==='early-error'?first:second;target.code=function(){e.push(mode);throw Error(mode+' sentinel');};}
  if(mode==='callback-reentry'){const code=first.code;first.code=function(a){e.push(['nested',m.default.bench(1,17)]);return Reflect.apply(code,this,[a]);};}
  const fs=more(first,more(second,end())),xs=con(3,con(5,nil()));if(mode==='field-getter')Object.defineProperty(fs.a,'0',{get(){e.push('callback.field');return first;}});
  return values(m.default['callback.map'](fs,xs));
 },{live:false});
 for(const mode of['early-error','late-error','callback-reentry','code-getter','field-getter']){const row=report.boundaries.find(r=>r.name==='public-callback:'+mode);assert(row.observations.original.events.length>0,'live public callback witness '+mode);}
 const selected=manifest.modules.find(r=>r.variant==='direct'&&r.counters),source=fs.readFileSync(selected.path,'utf8');
 const marker='try{return run();}';assert.equal(source.split(marker).length-1,1);const fault=source.replace(marker,'try{if(!$p43FaultEntered){$p43FaultEntered=true;bad("callback injected failure");}return run();}')+'\nlet $p43FaultEntered=false;\n',faultFile=path.join(out,'fault.mjs');fs.writeFileSync(faultFile,fault,{flag:'wx'});report.inputs.push(identity(faultFile));
 const fm=await import(pathToFileURL(faultFile)),OldError=Error;let during,nested,alienResult,alienEvents=[];
 assert.throws(()=>hook(globalThis,'Error',{value:function(message){during=fm.callbackState().active;nested=fm.default.bench(0,17);const alien={arity:2,bound:[7],env:null,code(a){alienEvents.push(a.slice());return 999;}};alienResult=values(fm.default['callback.map'](more(alien,end()),con(3,nil())));return new OldError(message);}},()=>fm.default.bench(1,17)),/callback injected failure/);
 assert.equal(during,false);assert.equal(nested,0);assert.deepEqual(alienResult,[999]);assert.deepEqual(alienEvents,[[7,3]]);assert.equal(fm.callbackState().active,false);
 report.admission.push({kind:'injected-error-reentry',proofDuring:during,nested,alienResult,alienEvents,state:fm.callbackState(),scope:'Fault inserted only into prototype admitted try; not a source-legal private callback error.'});
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
