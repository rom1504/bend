// Independent complete-stage values plus hostile public boundary controls. No timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'usage: list-controls.mjs DERIVED NEW_OUT');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=p=>({path:fs.realpathSync(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex'),bytes:fs.statSync(p).size});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase42-fusion-saved-js');assert.equal(manifest.complete,true);
const variants=['original','fused-bigint','fused-number'],files=variants.map(v=>path.join(base,v+'.mjs'));
const inputs=[identity(import.meta.filename),identity(manifestFile),...files.map(identity),manifest.parent,manifest.manifest,manifest.producer];
for(const row of inputs)assert.deepEqual(identity(row.path),row);
for(let i=0;i<files.length;i++)assert.equal(identity(files[i]).sha256,manifest.modules.find(r=>r.variant===variants[i]&&r.counters).sha256);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase42-fusion-controls',complete:false,pass:false,node:process.version,inputs,oracle:[],admission:[],boundaries:[]};
const modules=[];for(const file of files)modules.push(await import(pathToFileURL(file)));
const u32=x=>Number(BigInt.asUintN(32,x));
function oracle(n,seed){let s=BigInt(seed),produced=[];for(let i=0;i<n;i++){produced.push(Number(s%16n));s=BigInt.asUintN(32,s*1664525n+1013904223n);}
 const filtered=produced.filter(x=>x>1),mapped=filtered.map(x=>u32(BigInt(x)*2n));
 return {produced,filtered,mapped,sum:u32(mapped.reduce((a,x)=>a+BigInt(x),0n))};}
function canonical(v){const result=[];while(v.$==='Con'){assert.equal(v.a.length,2);assert.equal(typeof v.a[0],'number');result.push(v.a[0]);v=v.a[1];}assert.deepEqual(v,{$:'Nil',a:[]});return result;}
function normalize(v){if(typeof v==='bigint')return String(v)+'n';if(v===undefined)return '[Undefined]';if(typeof v==='function')return '[Function]';if(v===null||typeof v!=='object')return v;if(Array.isArray(v))return v.map(normalize);return Object.fromEntries(Object.keys(v).sort().map(k=>[k,normalize(v[k])]));}
function snapshot(m){const rows=manifest.dependencies.map(name=>{const d=Object.getOwnPropertyDescriptor(m.G,name),f=d.value;return {name,d,objects:[f,f.code,f.bound].map(v=>[v,Object.getOwnPropertyDescriptors(v)])};});
 return()=>{for(const row of rows){for(const [v,d]of row.objects){for(const k of Reflect.ownKeys(v))if(!Object.hasOwn(d,k))delete v[k];Object.defineProperties(v,d);}Object.defineProperty(m.G,row.name,row.d);}};}
function observe(m,action){const restore=snapshot(m),events=[],before=m.privateListCounts();let value,error;try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
 const after=m.privateListCounts();return {value:normalize(value),error,events:normalize(events),counts:Object.fromEntries(Object.keys(before).map(k=>[k,after[k]-before[k]]))};}
function boundary(name,action,{live=false,refuse=true}={}){const observations=modules.map(m=>observe(m,action));report.current={name,observations};
 const comparable=r=>({value:r.value,error:r.error,events:r.events});for(let i=1;i<modules.length;i++)assert.deepEqual(comparable(observations[i]),comparable(observations[0]),name+':'+variants[i]);
 if(live)assert(observations[0].events.length>0,'inactive witness '+name);
 if(refuse)for(let i=1;i<modules.length;i++)assert.equal(observations[i].counts.root,0,'private despite refusal '+name);
 report.boundaries.push(report.current);delete report.current;return observations;}
function changed(m,e,name,kind){const f=m.G[name],code=f.code;
 if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
 else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
 else f.code=function(a){e.push('invoke:'+name);return Reflect.apply(code,this,[a]);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
const ordinary=m=>m.default.bench(7,17),force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
try{
 for(const n of [0,1,2,7,15,16,17,31,128,129,512,513])for(const seed of [0,1,2,17,123,4294967294,4294967295]){
  const expected=oracle(n,seed),results=[];
  for(const m of modules){const stages=m.privateListStages(n,seed);for(const key of ['produced','filtered','mapped'])assert.deepEqual(canonical(stages[key]),expected[key]);assert.equal(stages.sum,expected.sum);const value=m.default.bench(n,seed);assert.equal(value,expected.sum);results.push(value);}
  report.oracle.push({kind:'full-stage-and-export',n,seed,expected,results});
 }
 for(let i=1;i<modules.length;i++){const m=modules[i],before=m.privateListCounts();assert.equal(ordinary(m),oracle(7,17).sum);const after=m.privateListCounts();assert.equal(after.root-before.root,1);report.admission.push({variant:variants[i],before,after});}
 for(const m of modules){const r=m.privateListAlias();assert.equal(r.sourceUnchanged,true);assert.equal(r.emptyFresh,true);assert.deepEqual(canonical(r.value),[7]);}
 for(const values of [[],[0],[1],[2],[4294967295],[0,1,2,4294967295,2147483648,2147483647],[7,0,7,1,7]])for(const initial of [0,1,4294967295,4294967280]){
  const expected=values.filter(h=>h>1).map(h=>u32(BigInt(h)*2n));
  const sum=u32(expected.reduce((a,h)=>a+BigInt(h),BigInt(initial)));
  for(const m of modules){const v=m.privateListScalar(values,initial);assert.deepEqual(canonical(v.source),values);assert.deepEqual(canonical(v.filtered),values.filter(h=>h>1));assert.deepEqual(canonical(v.mapped),expected);assert.equal(v.scalar,sum);assert.equal(v.fused,sum);}
  report.oracle.push({kind:'arbitrary-u32-overflow-diagnostic',values,initial,expected,sum});
 }
 for(const m of modules){const stages=m.privateListStages(17,4294967295);const retained=stages.produced,tail=retained.a[1],before=canonical(retained);m.default.bench(31,17);assert.strictEqual(stages.produced,retained);assert.strictEqual(retained.a[1],tail);assert.deepEqual(canonical(retained),before);}
 for(const failing of [2,7,15])boundary('strict-filter-error:'+failing,(m,e)=>{const f=m.G['keep_gt1.at'],old=f.code;f.code=function(a){e.push(['predicate',a[0]]);if(a[0]===failing)throw Error('predicate '+failing);return Reflect.apply(old,this,[a]);};return m.default.bench(17,17);},{live:true});
 boundary('strict-map-error-after-filter',(m,e)=>{const f=m.G['keep_gt1.at'],old=f.code;f.code=function(a){e.push(['predicate',a[0]]);return Reflect.apply(old,this,[a]);};m.G.dbl.code=function(){e.push('map-error');throw Error('mapping sentinel');};return m.default.bench(17,17);},{live:true});
 for(const name of manifest.dependencies)for(const kind of ['wrap','getter','binding'])boundary(name+':'+kind,(m,e)=>{changed(m,e,name,kind);return ordinary(m);},{live:true});
 for(const count of [0,1,2])boundary('prefix:'+count,m=>{const v=m.call(m.G.bench,[7,17].slice(0,count));return count===2?v:m.call(v,[7,17].slice(count));},{refuse:false});
 for(const kind of ['raw','forged','new','own-call','oversaturated','slot-mutation','slot-throw','slot-reentry'])boundary('entry:'+kind,(m,e)=>{
  const f=m.G.bench,code=f.code;let busy=false;const a={length:2,1:17};Object.defineProperty(a,'0',{get(){e.push('slot:0');if(kind==='slot-mutation')changed(m,e,'dbl','wrap');if(kind==='slot-throw')throw Error('slot sentinel');if(kind==='slot-reentry'&&!busy){busy=true;e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);}return 7;}});
  if(kind==='raw'||kind==='forged')return force(m,Reflect.apply(code,null,[a,kind==='forged']));if(kind==='new')return force(m,Reflect.construct(code,[a]));if(kind==='own-call'){code.call=function(env,a){e.push('call');return Reflect.apply(code,env,[a]);};return ordinary(m);}if(kind==='oversaturated')return m.call(f,[7,17,99]);return m.call(f,{slice(){e.push('slice');return a;}});
 },{refuse:kind!=='slot-reentry'});
 for(const kind of ['mutation','throw','reentry'])boundary('entry:slot1-'+kind,(m,e)=>{const code=m.G.bench.code,a={length:2,0:7};Object.defineProperty(a,'1',{get(){e.push('slot:1');if(kind==='mutation')changed(m,e,'dbl','wrap');if(kind==='throw')throw Error('second slot sentinel');if(kind==='reentry')e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);return 17;}});return m.call(m.G.bench,{slice(){e.push('slice');return a;}});},{refuse:kind!=='reentry'});
 for(const key of ['push','pop','concat','slice'])boundary('array:'+key,(m,e)=>{const old=Array.prototype[key];let n=0;const v=hook(Array.prototype,key,{value:function(...a){n++;return Reflect.apply(old,this,a);}},()=>ordinary(m));e.push(['calls',n]);return v;});
 for(const [label,p]of [['Object',Object.prototype],['Array',Array.prototype],['Number',Number.prototype],['Boolean',Boolean.prototype],['BigInt',BigInt.prototype]])for(const key of ['request','bounce','build','code'])boundary('marker:'+label+':'+key,(m,e)=>{let n=0;const v=hook(p,key,{get(){n++;return undefined;}},()=>ordinary(m));e.push(['calls',n]);return v;});
 for(const kind of ['wrap','getter','mutation','throw'])boundary('Math.imul:'+kind,(m,e)=>{const old=Math.imul;let n=0,once=false;const f=function(...a){n++;if(kind==='throw')throw Error('Math sentinel');if(kind==='mutation'&&!once){once=true;changed(m,e,'dbl','wrap');}return Reflect.apply(old,Math,a);};try{return hook(Math,'imul',kind==='getter'?{get(){n++;return old;}}:{value:f},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const kind of ['wrap','getter','mutation','throw'])boundary('BigInt:'+kind,(m,e)=>{const old=BigInt;let n=0,once=false;const f=function(...a){n++;if(kind==='throw')throw Error('BigInt sentinel');if(kind==='mutation'&&!once){once=true;changed(m,e,'dbl','wrap');}return Reflect.apply(old,null,a);};try{return hook(globalThis,'BigInt',kind==='getter'?{get(){n++;return old;}}:{value:f},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const x of [null,undefined,1.1,NaN,Infinity,'17'])boundary('noncanonical-seed:'+String(x),m=>m.default.bench(2,x));
 for(const kind of ['deferred','head-error','tail-error','tag-getter','field-getter']){const observations=boundary('foreign-producer:'+kind,(m,e)=>{
  let value={$:'Con',a:[7,{$:'Nil',a:[]}]};if(kind==='tag-getter')Object.defineProperty(value,'$',{get(){e.push('tag');return 'Con';}});if(kind==='field-getter')Object.defineProperty(value.a,'0',{get(){e.push('head');return 7;}});
  if(['deferred','head-error','tail-error'].includes(kind))value={build:true,name:'Con',fields:[()=>{e.push('head');if(kind==='head-error')throw Error('head sentinel');return 7;},()=>{e.push('tail');if(kind==='tail-error')throw Error('tail sentinel');return {$:'Nil',a:[]};}]};
  m.G['p37.list']={arity:2,env:null,bound:[],code(){e.push('producer');return value;}};return ordinary(m);
 },{live:true});
  for(const o of observations){if(['deferred','head-error','tail-error'].includes(kind))assert.deepEqual(o.events,kind==='head-error'?['producer','head']:['producer','head','tail']);if(kind==='head-error'||kind==='tail-error')assert.equal(o.error?.message,kind==='head-error'?'head sentinel':'tail sentinel');if(kind==='tag-getter')assert(o.events.includes('tag'));if(kind==='field-getter')assert(o.events.includes('head'));}
 }
 for(let i=1;i<modules.length;i++){const m=modules[i],n=30000,stages=m.privateListStages(n,4294967295),expected=oracle(n,4294967295);for(const key of ['produced','filtered','mapped'])assert.deepEqual(canonical(stages[key]),expected[key]);assert.equal(stages.sum,expected.sum);assert.equal(m.privateProofActive(),false);report.oracle.push({kind:'explicit-stack-full-stages',variant:variants[i],n,sum:stages.sum});}
 for(let i=1;i<modules.length;i++){const produced=modules[i].privateListProducer(30000,17);assert.deepEqual(canonical(produced),oracle(30000,17).produced);report.oracle.push({kind:'explicit-stack-producer',variant:variants[i],n:30000});}
 for(let i=0;i<modules.length;++i){const m=modules[i],before=m.privateListCounts(),expected=oracle(30000,4294967295).sum;assert.equal(m.default.bench(30000,4294967295),expected);const after=m.privateListCounts();assert.equal(after.root-before.root,i===0?0:1);report.oracle.push({kind:'ordinary-root-depth',variant:variants[i],n:30000,sum:expected,entryDelta:after.root-before.root});}
 for(const m of modules)assert.equal(m.privateProofActive(),false);for(const row of inputs)assert.deepEqual(identity(row.path),row);report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
