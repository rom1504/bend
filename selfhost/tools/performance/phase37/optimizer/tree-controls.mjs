// Complete-tree oracle and public-boundary observations; no timing claims.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);
assert(baseArg&&outArg,'usage: tree-controls.mjs DERIVED NEW_OUT');
const base=path.resolve(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase37-private-tree-prototype');assert.equal(manifest.complete,true);
const variants=['original','guard','zip','finite','warp','component'];
const files=variants.map(v=>path.join(base,v+'.mjs'));
for(let i=0;i<files.length;i++)assert.equal(identity(files[i]).sha256,manifest.modules.find(m=>m.variant===variants[i]&&m.counters).sha256);
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase37-private-tree-controls',complete:false,pass:false,node:process.version,
 inputs:[import.meta.filename,manifestFile,...files].map(identity),variants,oracle:[],boundaries:[],admission:[]};
const modules=[];for(const f of files)modules.push(await import(pathToFileURL(f)));
const u32=x=>x>>>0,mul=(x,y)=>Math.imul(x,y)>>>0;
function key(x){x=mul(u32(x+1),2654435761);x=u32(x^(x<<13));x=u32(x^(x>>>17));return u32(x^(x<<5));}
// Independent sorted-array model: no bitonic warp, recursive sort or generated ABI.
function modelBench(depth,seed){const n=2**depth,first=u32(seed*n),values=Array.from({length:n},(_,i)=>key(u32(first+i))).sort((a,b)=>a-b);
 let summaries=values.map(v=>[v,v,1,v]);
 while(summaries.length>1){const next=[];for(let i=0;i<summaries.length;i+=2){const a=summaries[i],b=summaries[i+1];
  next.push([a[0],b[1],a[2]&b[2]&Number(a[1]<=b[0]),u32(mul(a[3],2654435761)+b[3])]);}summaries=next;}
 const [lo,hi,ok,mx]=summaries[0];return u32(u32(mul(mx,2654435761)^u32(hi+mul(lo,340573321)))+mul(ok,2246822519));}
// The shape oracle uses nested arrays and immutable recursive equations. The
// mechanism uses tagged objects and an explicit mutable frame stack.
function tree(d,x,shared){if(d===0)return [x];const left=tree(d-1,u32(x*3+1),shared);return [left,shared?left:tree(d-1,u32(x*5+7),shared)];}
function zip(a,b){return a.length===2&&b.length===2?[[a[0],b[0]],[a[1],b[1]]]:[0];}
function warp(a,b,s){if(a.length===1&&b.length===1)return s!==(a[0]>b[0])?[[b[0]],[a[0]]]:[[a[0]],[b[0]]];
 return a.length===2&&b.length===2?zip(warp(a[0],b[0],s),warp(a[1],b[1],s)):[0];}
function canonical(t){assert.equal(typeof t,'object');assert(Array.isArray(t.a));
 if(t.$==='Leaf'){assert.equal(t.a.length,1);return [t.a[0]];}
 assert.equal(t.$,'Node');assert.equal(t.a.length,2);return [canonical(t.a[0]),canonical(t.a[1])];}
function normalize(x,seen=new Set()){if(typeof x==='bigint')return String(x)+'n';if(typeof x==='function')return '[Function]';
 if(x===undefined)return '[Undefined]';if(typeof x==='number'&&!Number.isFinite(x))return String(x);
 if(x===null||typeof x!=='object')return x;if(seen.has(x))return '[Cycle]';seen.add(x);
 const r=Array.isArray(x)?x.map(v=>normalize(v,seen)):Object.fromEntries(Object.keys(x).sort().map(k=>[k,normalize(x[k],seen)]));seen.delete(x);return r;}
function snapshot(m){const rows=manifest.dependencies.map(name=>{const gd=Object.getOwnPropertyDescriptor(m.G,name),f=gd.value,c=f.code,b=f.bound;
 return {name,gd,f,fd:Object.getOwnPropertyDescriptors(f),c,cd:Object.getOwnPropertyDescriptors(c),b,bd:Object.getOwnPropertyDescriptors(b)};});
 return()=>{for(const r of rows){for(const [v,d]of[[r.f,r.fd],[r.c,r.cd],[r.b,r.bd]]){for(const k of Reflect.ownKeys(v))if(!Object.hasOwn(d,k))delete v[k];Object.defineProperties(v,d);}
 Object.defineProperty(m.G,r.name,r.gd);}};}
function observe(m,action){const restore=snapshot(m),events=[];let value,error;try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
 return {value:normalize(value),error,events:normalize(events)};}
function boundary(name,action){const observations=modules.map(m=>observe(m,action));report.current={name,observations};
 for(let i=1;i<observations.length;i++)assert.deepEqual(observations[i],observations[0],name+':'+variants[i]);
 report.boundaries.push(report.current);delete report.current;return observations;}
function changed(m,e,name,kind='wrap'){const f=m.G[name],code=f.code;
 if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
 else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
 else f.code=function(a){e.push('invoke:'+name);return Reflect.apply(code,this,[a]);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
const ordinary=m=>m.default.bench(3,17),force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
try{
 for(const depth of [0,1,2,4,8])for(const seed of [0,1,17,4294967295]){
  const expected=modelBench(depth,seed),results=modules.map(m=>m.default.bench(depth,seed));
  report.current={kind:'sorted-array-bench',depth,seed,expected,results};for(const r of results)assert.equal(r,expected);
  if(depth===8&&seed===0)assert.equal(expected,971629740);report.oracle.push(report.current);delete report.current;
 }
 for(const da of [0,1,3,5])for(const db of [0,1,3,5])for(const s of [false,true])for(const seed of [0,17,4294967295])for(const sharing of [0,1,2]){
  const x=seed,y=u32(seed+23),a=tree(da,x,sharing===1),b=sharing===2?a:tree(db,y,sharing===1),expected=warp(a,b,s);
  const results=modules.slice(1).map(m=>canonical(m.privateWarpPoint(da,db,x,y,s,sharing)));
  report.current={kind:'complete-warp',da,db,s,x,y,sharing,expected,results};for(const r of results)assert.deepEqual(r,expected);
  report.oracle.push(report.current);delete report.current;
 }
 for(let i=1;i<modules.length;i++){const value=modules[i].privateZipPoint();assert.deepEqual(value.aliases,[true,true,true,true]);
  assert.deepEqual(canonical(value.value),[[[17],[23]],[[23],[17]]]);report.oracle.push({kind:'zip-alias',variant:variants[i],aliases:value.aliases});
  const before=modules[i].privateEntryCounts();modules[i].default.bench(4,17);const after=modules[i].privateEntryCounts();
  assert(after.root>before.root);if(['zip','finite'].includes(variants[i]))assert(after.zip>before.zip);
  if(['warp','component'].includes(variants[i]))assert(after.warp>before.warp);if(['finite','component'].includes(variants[i]))assert(after.leaf>before.leaf);
  report.admission.push({kind:'actual-bench-entry',variant:variants[i],before,after});
 }
 for(const name of manifest.dependencies)for(const kind of ['wrap','getter','binding'])boundary(name+':'+kind,(m,e)=>{changed(m,e,name,kind);return ordinary(m);});
 for(const count of [0,1,2])boundary('prefix:'+count,m=>{const p=m.call(m.G.bench,[3,17].slice(0,count));return count===2?p:m.call(p,[3,17].slice(count));});
 for(const kind of ['raw','forged','new','own-call','oversaturated','slot-getter','slot-mutation','slot-throw','slot-reentry'])boundary('entry:'+kind,(m,e)=>{
  const f=m.G.bench,code=f.code;let busy=false;const a={length:2,1:17};Object.defineProperty(a,'0',{get(){e.push('slot:0');
   if(kind==='slot-mutation')changed(m,e,'warp_zip');if(kind==='slot-throw')throw Error('slot sentinel');
   if(kind==='slot-reentry'&&!busy){busy=true;e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);}return 3;}});
  if(kind==='raw'||kind==='forged')return force(m,Reflect.apply(code,null,[a,kind==='forged']));
  if(kind==='new')return force(m,Reflect.construct(code,[a]));
  if(kind==='own-call'){code.call=function(env,a){e.push('call');return Reflect.apply(code,env,[a]);};return ordinary(m);}
  if(kind==='oversaturated')return m.call(f,[3,17,99]);return m.call(f,{slice(){e.push('slice');return a;}});
 });
 for(const kind of ['mutation','reentry','throw'])boundary('entry:slot1-'+kind,(m,e)=>{
  const f=m.G.bench,code=f.code,a={length:2,0:3};Object.defineProperty(a,'1',{get(){e.push('slot:1');
   if(kind==='mutation')changed(m,e,'warp_zip');if(kind==='throw')throw Error('second slot sentinel');
   if(kind==='reentry')e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);return 17;}});
  return m.call(f,{slice(){e.push('slice');return a;}});
 });
 for(const name of ['warp_zip','warp','warp_leaf.go','Bool.xor'])for(let i=1;i<modules.length;i++){
  const m=modules[i],restore=snapshot(m);try{const events=[];changed(m,events,name);const before=m.privateEntryCounts();ordinary(m);const after=m.privateEntryCounts();
   assert.deepEqual(after,before,'live mutation must refuse private root');assert(events.length>0,'mutation witness must execute');
   report.admission.push({kind:'live-mutation-refusal',variant:variants[i],name,events:events.length});}finally{restore();}
 }
 // Mutating a producer invalidates the whole boundary. Its deferred fields must
 // still run left before right, exactly once each, with the first error winning.
 for(const kind of ['deferred','left-error','right-error','alias','tag-getter','field-getter']){
 const observations=boundary('foreign-bsort:'+kind,(m,e)=>{
  const leaf={$:'Leaf',a:[7]},right={$:'Leaf',a:[13]};let value={$:'Node',a:[leaf,kind==='alias'?leaf:right]};
  if(kind==='tag-getter')Object.defineProperty(value,'$',{get(){e.push('tag');return 'Node';}});
  if(kind==='field-getter')Object.defineProperty(value.a,'0',{get(){e.push('field:0');return leaf;}});
  if(['deferred','left-error','right-error'].includes(kind))value={build:true,name:'Node',fields:[()=>{e.push('left');if(kind==='left-error')throw Error('left sentinel');return leaf;},
   ()=>{e.push('right');if(kind==='right-error')throw Error('right sentinel');return right;}]};
  m.G.bsort={arity:3,code(){e.push('foreign-bsort');return value;},env:null,bound:[]};return ordinary(m);
 });
 for(const observation of observations){
  if(['deferred','left-error','right-error'].includes(kind))assert.deepEqual(observation.events,kind==='left-error'?['foreign-bsort','left']:['foreign-bsort','left','right'],'nonvacuous forcing order');
  if(kind==='left-error'||kind==='right-error')assert.equal(observation.error?.message,kind==='left-error'?'left sentinel':'right sentinel');
  if(kind==='tag-getter')assert(observation.events.includes('tag'),'live foreign tag getter');
  if(kind==='field-getter')assert(observation.events.includes('field:0'),'live foreign field getter');
 }}
 for(const name of ['warp','warp_zip'])for(const kind of ['plain','deferred-fields','left-error','right-error','tag-getter','field-getter']){
 const observations=boundary('public-tree:'+name+':'+kind,(m,e)=>{
  const leaf={$:'Leaf',a:[7]};const a={$:'Node',a:[leaf,leaf]},b={$:'Node',a:[leaf,leaf]};
  if(kind==='tag-getter')Object.defineProperty(a,'$',{get(){e.push('left-tag');return 'Node';}});
  if(kind==='field-getter')Object.defineProperty(a.a,'0',{get(){e.push('left-field');return leaf;}});
  if(['deferred-fields','left-error','right-error'].includes(kind)){
   a.a[0]={build:true,name:'Leaf',fields:[()=>{e.push('left-deferred');if(kind==='left-error')throw Error('left sentinel');return 7;}]};
   b.a[0]={build:true,name:'Leaf',fields:[()=>{e.push('right-deferred');if(kind==='right-error')throw Error('right sentinel');return 13;}]};
  }
  return name==='warp'?m.default.warp(a,b,false):m.default.warp_zip(a,b);
 });
 for(const observation of observations){
  if(kind==='tag-getter')assert(observation.events.includes('left-tag'),'live public tag getter');
  if(kind==='field-getter')assert(observation.events.includes('left-field'),'live public field getter');
 }
 // Raw build descriptors embedded inside an already materialized public node
 // may be refused before their callback. These are paired fallback observations,
 // not the nonvacuous forcing-order witness established by foreign-bsort above.
 }
 for(const key of ['push','pop','concat','slice'])boundary('array:'+key,(m,e)=>{const old=Array.prototype[key];let n=0;
  const result=hook(Array.prototype,key,{value:function(...a){n++;return Reflect.apply(old,this,a);}},()=>ordinary(m));e.push(['calls',n]);return result;});
 for(const [label,p]of [['Object',Object.prototype],['Array',Array.prototype],['Number',Number.prototype],['Boolean',Boolean.prototype],['BigInt',BigInt.prototype]])for(const key of ['request','bounce','build','code'])boundary('marker:'+label+':'+key,(m,e)=>{
  let n=0;const result=hook(p,key,{get(){n++;return undefined;}},()=>ordinary(m));e.push(['calls',n]);return result;});
 for(const kind of ['wrap','getter','mutation','throw'])boundary('Math.imul:'+kind,(m,e)=>{const old=Math.imul;let n=0,once=false;
  const callback=function(...a){n++;if(kind==='throw')throw Error('Math sentinel');if(kind==='mutation'&&!once){once=true;changed(m,e,'warp');}return Reflect.apply(old,Math,a);};
  try{return hook(Math,'imul',kind==='getter'?{get(){n++;return old;}}:{value:callback},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const x of [null,undefined,1.1,NaN,Infinity,'17'])boundary('noncanonical-seed:'+String(x),m=>m.default.bench(2,x));
 for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
