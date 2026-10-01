// Untimed controls for the saved-output prototype. Root owns execution.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [derivedArg,outArg]=process.argv.slice(2);
assert(derivedArg&&outArg,'usage: countdown-controls.mjs DERIVED NEW_OUT');
const derived=fs.realpathSync(derivedArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=f=>({path:fs.realpathSync(f),sha256:createHash('sha256').update(fs.readFileSync(f)).digest('hex'),bytes:fs.statSync(f).size});
const manifestFile=path.join(derived,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase39-countdown-ablation');assert.equal(manifest.complete,true);
const variants=['original','nested','both'],modules=[],inputs=[identity(import.meta.filename),identity(manifestFile)];
for(const variant of variants){const row=manifest.modules.find(x=>x.variant===variant&&x.counters);assert(row);const actual=identity(row.path);
 assert.deepEqual(actual,{path:row.path,sha256:row.sha256,bytes:row.bytes});inputs.push(actual);modules.push(await import(pathToFileURL(row.path)));}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase39-countdown-controls',complete:false,pass:false,node:process.version,inputs,
 scope:'Saved-output arithmetic, public-boundary and capped high-counter diagnostics; not actual compiler admission evidence.',oracles:[],boundaries:[],admission:[],bounded:[]};
function model(n,seed){let x=Math.fround(Math.fround((seed%97+1)>>>0)/100),h=seed;
 for(let i=0;i<n;i++){x=Math.fround(Math.fround(3.75*x)*Math.fround(1-x));const z=Math.fround(x*1000000);h=(Math.imul(h,16777619)^(Number.isFinite(z)&&z>=0&&z<2**32?Math.trunc(z):0))>>>0;}return h;}
function normalize(x,seen=new Set()){
 if(x===undefined)return {undefined:true};if(typeof x==='bigint')return {bigint:String(x)};if(typeof x==='function')return {function:true};
 if(typeof x==='number'&&(!Number.isFinite(x)||Object.is(x,-0)))return {number:String(x),negativeZero:Object.is(x,-0)};
 if(x===null||typeof x!=='object')return x;if(seen.has(x))return {cycle:true};seen.add(x);
 const y=Array.isArray(x)?x.map(v=>normalize(v,seen)):Object.fromEntries(Object.keys(x).sort().map(k=>[k,normalize(x[k],seen)]));seen.delete(x);return y;
}
function snapshot(m){const saved=manifest.dependencies.map(name=>{const gd=Object.getOwnPropertyDescriptor(m.G,name),f=gd.value;return {name,gd,parts:[f,f.code,f.bound].map(o=>[o,Object.getOwnPropertyDescriptors(o)])};});
 return()=>{for(const row of saved){for(const [o,ds]of row.parts){for(const k of Reflect.ownKeys(o))if(!Object.hasOwn(ds,k))delete o[k];Object.defineProperties(o,ds);}Object.defineProperty(m.G,row.name,row.gd);}};}
function observe(m,action){const restore=snapshot(m),events=[],before=m.countdownCounts();let value,error;
 try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
 const after=m.countdownCounts();return {value:normalize(value),error,events:normalize(events),counts:Object.fromEntries(Object.keys(before).map(k=>[k,after[k]-before[k]]))};}
function boundary(name,action,{live=false,refuse=false}={}){const observations=modules.map(m=>observe(m,action));report.current={name,observations};
 const comparable=x=>({value:x.value,error:x.error,events:x.events});for(let i=1;i<observations.length;i++)assert.deepEqual(comparable(observations[i]),comparable(observations[0]),name);
 if(live)assert(observations[0].events.length>0,'inactive control: '+name);
 if(refuse)for(const x of observations)assert.equal(x.counts.public+x.counts.nested,0,'private loop despite refusal: '+name);
 report.boundaries.push(report.current);delete report.current;}
function hook(o,k,descriptor,action){const old=Object.getOwnPropertyDescriptor(o,k);try{Object.defineProperty(o,k,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(o,k,old);else delete o[k];}}
const ordinary=m=>m.default.bench(4,17),force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
try{
 for(const n of [0,1,2,3,7,17,31,64,256,1024])for(const seed of [0,1,17,123,4294967295]){
  const expected=model(n,seed),results=modules.map(m=>m.default.bench(n,seed));for(const r of results)assert.equal(r,expected);
  report.oracles.push({n,seed,expected,results});
 }
 for(const entry of ['public','nested'])for(const n of [0,1,7])for(let i=0;i<modules.length;i++){
  const m=modules[i],before=m.countdownCounts();
  if(entry==='nested')m.default.bench(n,17);else m.call(m.G['p37.numeric'],[BigInt(n),0.25,17]);
  const after=m.countdownCounts(),steps=after[entry]-before[entry],numbers=after[entry+'Number']-before[entry+'Number'];
  assert.equal(steps,n);assert.equal(numbers,(variants[i]==='both'||entry==='nested'&&variants[i]==='nested')?n:0);
  report.admission.push({entry,n,variant:variants[i],steps,numbers});
 }
 for(const entry of ['public','nested'])for(const n of [0n,1n,2n,4n,17n,4294967295n,281474976710653n,281474976710654n,281474976710655n]){
  const observations=modules.map(m=>m.countdownBounded(entry,n,3));
  const expected=Array.from({length:Number(n<4n?n:4n)},(_,i)=>String(n-1n-BigInt(i)));
  for(let i=0;i<observations.length;i++){const x=observations[i];assert.equal(x.admitted,true);assert.deepEqual(x.trace.map(t=>t.value),expected);
   for(const t of x.trace)assert.equal(t.kind,variants[i]==='both'||entry==='nested'&&variants[i]==='nested'?'number':'bigint');}
  for(let i=1;i<observations.length;i++)assert.deepEqual(normalize(observations[i].result),normalize(observations[0].result));
  report.bounded.push({entry,n:String(n),observations:normalize(observations)});
 }
 for(const input of [-1n,281474976710656n,1,NaN,'1',{},null])for(const entry of ['public','nested']){
  const observations=modules.map(m=>m.countdownBounded(entry,input,3));for(const x of observations)assert.deepEqual(x,{admitted:false,trace:[]});
  report.bounded.push({entry,invalid:normalize(input),observations});
 }
 for(const name of ['bench','p37.numeric','F32.to_u32'])for(const kind of ['code','code-getter','binding-getter'])boundary(name+':'+kind,(m,e)=>{
  const f=m.G[name],code=f.code;
  if(kind==='code')f.code=function(a){e.push(name);return Reflect.apply(code,this,[a]);};
  if(kind==='code-getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
  if(kind==='binding-getter')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
  return ordinary(m);
 },{live:true});
 for(const [owner,key]of [[Math,'fround'],[Math,'imul'],[Math,'trunc'],[Number,'isFinite'],[DataView.prototype,'setUint32'],[DataView.prototype,'getFloat32']])
  for(const mode of ['wrap','throw','reentry','mutation'])boundary('host:'+key+':'+mode,(m,e)=>{
   const original=owner[key];let inside=false;
   return hook(owner,key,{value:function(...args){e.push(key);if(mode==='throw')throw Error('host '+key+' sentinel');
    if(mode==='reentry'&&!inside){inside=true;e.push(['nested',m.default.bench(1,7)]);}
    if(mode==='mutation'&&!inside){inside=true;const f=m.G['F32.to_u32'],code=f.code;f.code=function(a){e.push('mutated-native');return Reflect.apply(code,this,[a]);};}
    return Reflect.apply(original,this,args);}},()=>ordinary(m));
  },{live:true,refuse:true});
 // The countdown uses captured Number, not the replaceable global conversion.
 boundary('global-Number',(m,e)=>{const old=Number;function Replacement(...args){e.push('Number');return Reflect.apply(old,this,args);}
  Object.setPrototypeOf(Replacement,old);Replacement.prototype=old.prototype;
  return hook(globalThis,'Number',{value:Replacement},()=>ordinary(m));});
 for(const mode of ['raw','forged','construct','partial','extra','slot0','slot1','slot-throw','slot-reentry','slot-mutation'])boundary('root:'+mode,(m,e)=>{
  const f=m.G.bench,code=f.code;if(mode==='partial')return m.call(m.call(f,[4]),[17]);if(mode==='extra')return m.call(f,[4,17,0]);
  const args={length:2,0:4,1:17},slot=mode==='slot1'?'1':'0';Object.defineProperty(args,slot,{get(){e.push('slot:'+slot);
   if(mode==='slot-throw')throw Error('slot sentinel');if(mode==='slot-reentry')e.push(['nested',m.default.bench(1,7)]);
   if(mode==='slot-mutation'){const native=m.G['F32.to_u32'],old=native.code;native.code=function(a){e.push('slot-native');return Reflect.apply(old,this,[a]);};}
   return slot==='0'?4:17;}});
  if(mode==='raw'||mode==='forged')return force(m,Reflect.apply(code,null,[args,mode==='forged']));
  if(mode==='construct')return force(m,Reflect.construct(code,[args]));
  return m.call(f,{slice(){e.push('slice');return args;}});
 });
 for(const mode of ['raw','forged','construct','staged','extra'])boundary('successor:'+mode,(m,e)=>{
  const f=m.call(m.G['p37.numeric'],[2n]);
  if(mode==='staged')return m.call(m.call(f,[0.25]),[17]);
  if(mode==='extra')return m.call(f,[0.25,17,0]);
  const args={length:3,1:0.25,2:17};Object.defineProperty(args,'0',{get(){e.push('predecessor');return 1n;}});
  return force(m,mode==='construct'?Reflect.construct(f.code,[args]):Reflect.apply(f.code,null,[args,mode==='forged']));
 });
 boundary('Error-reentry',(m,e)=>{const OldError=Error;let entered=false;
  return hook(globalThis,'Error',{value:function(message){e.push('Error');if(!entered){entered=true;e.push(['nested',m.default.bench(1,7)]);}return new OldError(message);}},()=>m.call(m.G.bench,[2,17,0]));
 },{live:true});
 // Negative/huge raw sizes could enter an unbounded generic countdown. Their
 // representation refusal is covered by countdownBounded, never a full run.
 for(const value of [1.5,NaN,Infinity,'1',{},null])boundary('raw-size:'+String(value),m=>m.default.bench(value,17));
 for(const x of inputs)assert.deepEqual(identity(x.path),x);
 report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracles:report.oracles.length,admission:report.admission.length,bounded:report.bounded.length,boundaries:report.boundaries.length,error:report.error}));
