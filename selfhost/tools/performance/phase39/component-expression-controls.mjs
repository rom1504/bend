// Full structures, live boundary observations and explicit frames. No timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'usage: component-expression-controls.mjs DERIVED NEW_OUT');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase39-private-expression-prototype');assert.equal(manifest.complete,true);
const variants=['original','producer','component'],files=variants.map(v=>path.join(base,v+'.mjs'));
const inputs=[import.meta.filename,manifestFile,...files].map(identity);
for(const row of manifest.verifiedInputs){assert.deepEqual(identity(row.path),row);inputs.push(row);}
for(let i=0;i<files.length;i++)assert.equal(identity(files[i]).sha256,manifest.modules.find(m=>m.variant===variants[i]&&m.counters).sha256);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase39-private-expression-controls',complete:false,pass:false,node:process.version,inputs,variants,oracle:[],boundaries:[],admission:[]};
const modules=[];for(const file of files)modules.push(await import(pathToFileURL(file)));
const word=x=>Number(BigInt.asUintN(32,x));
// Independent value oracle uses integer arithmetic, not emitted U32 operators.
function valueOracle(n,seed){let value=BigInt(word(BigInt(seed)+BigInt(n)));
 for(let k=n-1;k>=0;k--){const s=BigInt(word(BigInt(seed)+BigInt(k)));
  value=BigInt.asUintN(32,s%3n===0n?value+s*3n:s%3n===1n?value*(s%5n+1n):value-s-7n);
 }return Number(value);}
// Abstract arrays preserve every constructor/field; no generated tagged ABI.
function shapeOracle(n,seed){if(n===0)return ['Lit',seed];const inner=shapeOracle(n-1,word(BigInt(seed)+1n));
 if(seed%3===0)return ['Add',inner,['Mul',['Lit',seed],['Lit',3]]];
 if(seed%3===1)return ['Mul',inner,['Add',['Lit',seed%5],['Lit',1]]];
 return ['Sub',inner,['Add',['Lit',seed],['Lit',7]]];}
function canonical(value){assert(value&&typeof value==='object');assert(Array.isArray(value.a));
 if(value.$==='Lit'){assert.equal(value.a.length,1);assert.equal(typeof value.a[0],'number');return ['Lit',value.a[0]];}
 assert(['Add','Mul','Sub'].includes(value.$));assert.equal(value.a.length,2);return [value.$,canonical(value.a[0]),canonical(value.a[1])];}
function normalize(x,seen=new Set()){if(typeof x==='bigint')return String(x)+'n';if(typeof x==='function')return '[Function]';
 if(x===undefined)return '[Undefined]';if(typeof x==='number'&&(!Number.isFinite(x)||Object.is(x,-0)))return {number:String(x),negativeZero:Object.is(x,-0)};
 if(x===null||typeof x!=='object')return x;if(seen.has(x))return '[Cycle]';seen.add(x);
 const r=Array.isArray(x)?x.map(v=>normalize(v,seen)):Object.fromEntries(Object.keys(x).sort().map(k=>[k,normalize(x[k],seen)]));seen.delete(x);return r;}
function snapshot(m){const rows=manifest.dependencies.map(name=>{const gd=Object.getOwnPropertyDescriptor(m.G,name),f=gd.value,c=f.code,b=f.bound;
 return {name,gd,objects:[[f,Object.getOwnPropertyDescriptors(f)],[c,Object.getOwnPropertyDescriptors(c)],[b,Object.getOwnPropertyDescriptors(b)]]};});
 return()=>{for(const row of rows){for(const [v,d]of row.objects){for(const k of Reflect.ownKeys(v))if(!Object.hasOwn(d,k))delete v[k];Object.defineProperties(v,d);}Object.defineProperty(m.G,row.name,row.gd);}};}
function observe(m,action){const restore=snapshot(m),events=[],before=m.privateComponentCounts();let value,error;
 try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
 const after=m.privateComponentCounts();return {value:normalize(value),error,events:normalize(events),counts:Object.fromEntries(Object.keys(before).map(k=>[k,after[k]-before[k]]))};}
function boundary(name,action,{live=false,refuse=true}={}){const observations=modules.map(m=>observe(m,action));report.current={name,observations};
 const comparable=row=>({value:row.value,error:row.error,events:row.events});for(let i=1;i<observations.length;i++)assert.deepEqual(comparable(observations[i]),comparable(observations[0]),name+':'+variants[i]);
 if(live)assert(observations[0].events.length>0,'inactive witness '+name);
 if(refuse)for(let i=1;i<observations.length;i++)assert.equal(observations[i].counts.producer,0,'private producer despite refusal '+name);
 report.boundaries.push(report.current);delete report.current;return observations;}
function changed(m,e,name,kind='wrap'){const f=m.G[name],code=f.code;
 if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
 else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
 else f.code=function(a){e.push('invoke:'+name);return Reflect.apply(code,this,[a]);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
const ordinary=m=>m.default.bench(4,17),force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
try{
 for(const n of [0,1,2,7,32,128])for(const seed of [0,1,2,17,123,4294967294,4294967295]){
  const expected=valueOracle(n,seed),shape=shapeOracle(n,seed),results=modules.map(m=>m.default.bench(n,seed));
  for(let i=0;i<modules.length;i++){assert.equal(results[i],expected);assert.deepEqual(canonical(modules[i].privateExprPoint(n,seed)),shape);}
  report.oracle.push({kind:'complete-expression-and-value',n,seed,expected,results,shape});
 }
 for(const op of [0,1,2])for(const seed of [0,17,4294967295])for(let i=0;i<modules.length;i++){
  const r=modules[i].privatePickPoint(op,seed);assert.deepEqual(r.aliases,[true,true,true]);
  const shared=['Add',['Lit',seed],['Lit',seed]],arm=op===0?['Mul',['Lit',seed],['Lit',3]]:op===1?['Add',['Lit',seed%5],['Lit',1]]:['Add',['Lit',seed],['Lit',7]];
  assert.deepEqual(canonical(r.value),[['Add','Mul','Sub'][op],shared,arm]);report.oracle.push({kind:'shared-picker',variant:variants[i],op,seed,aliases:r.aliases});
 }
 for(let i=1;i<modules.length;i++){const m=modules[i],before=m.privateComponentCounts();assert.equal(m.default.bench(7,17),valueOracle(7,17));const after=m.privateComponentCounts();
  assert.equal(after.root-before.root,1);assert.equal(after.producer-before.producer,1);assert.equal(after.pick-before.pick,i===2?7:0);
  report.admission.push({kind:'actual-bench-entry',variant:variants[i],before,after});}
 for(const name of manifest.dependencies)for(const kind of ['wrap','getter','binding'])boundary(name+':'+kind,(m,e)=>{changed(m,e,name,kind);return ordinary(m);},{live:true});
 for(const count of [0,1,2])boundary('prefix:'+count,m=>{const p=m.call(m.G.bench,[4,17].slice(0,count));return count===2?p:m.call(p,[4,17].slice(count));},{refuse:false});
 for(const kind of ['raw','forged','new','own-call','oversaturated','slot-mutation','slot-throw','slot-reentry'])boundary('entry:'+kind,(m,e)=>{
  const f=m.G.bench,code=f.code;let busy=false;const a={length:2,1:17};Object.defineProperty(a,'0',{get(){e.push('slot:0');
   if(kind==='slot-mutation')changed(m,e,'p37.expr.pick');if(kind==='slot-throw')throw Error('slot sentinel');
   if(kind==='slot-reentry'&&!busy){busy=true;e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);}return 4;}});
  if(kind==='raw'||kind==='forged')return force(m,Reflect.apply(code,null,[a,kind==='forged']));
  if(kind==='new')return force(m,Reflect.construct(code,[a]));
  if(kind==='own-call'){code.call=function(env,a){e.push('call');return Reflect.apply(code,env,[a]);};return ordinary(m);}
  if(kind==='oversaturated')return m.call(f,[4,17,99]);return m.call(f,{slice(){e.push('slice');return a;}});
 },{refuse:kind!=='slot-reentry'});
 for(const kind of ['mutation','throw','reentry'])boundary('entry:slot1-'+kind,(m,e)=>{
  const code=m.G.bench.code,a={length:2,0:4};Object.defineProperty(a,'1',{get(){e.push('slot:1');
   if(kind==='mutation')changed(m,e,'p37.expr.pick');if(kind==='throw')throw Error('second slot sentinel');
   if(kind==='reentry')e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);return 17;}});
  return m.call(m.G.bench,{slice(){e.push('slice');return a;}});
 },{refuse:kind!=='reentry'});
 for(const kind of ['deferred','left-error','right-error','alias','tag-getter','field-getter']){
  const observations=boundary('foreign-producer:'+kind,(m,e)=>{
   const leaf={$:'Lit',a:[7]},right={$:'Lit',a:[13]};let value={$:'Add',a:[leaf,kind==='alias'?leaf:right]};
   if(kind==='tag-getter')Object.defineProperty(value,'$',{get(){e.push('tag');return 'Add';}});
   if(kind==='field-getter')Object.defineProperty(value.a,'0',{get(){e.push('field:0');return leaf;}});
   if(['deferred','left-error','right-error'].includes(kind))value={build:true,name:'Add',fields:[()=>{e.push('left');if(kind==='left-error')throw Error('left sentinel');return leaf;},()=>{e.push('right');if(kind==='right-error')throw Error('right sentinel');return right;}]};
   m.G['p37.expr']={arity:2,code(){e.push('foreign-producer');return value;},env:null,bound:[]};return ordinary(m);
  },{live:true});
  for(const o of observations){if(['deferred','left-error','right-error'].includes(kind))assert.deepEqual(o.events,kind==='left-error'?['foreign-producer','left']:['foreign-producer','left','right']);
   if(kind.endsWith('-error'))assert.equal(o.error?.message,kind==='left-error'?'left sentinel':'right sentinel');
   if(kind==='tag-getter')assert(o.events.includes('tag'));if(kind==='field-getter')assert(o.events.includes('field:0'));}
 }
 for(const kind of ['plain','deferred-fields','left-error','right-error','tag-getter','field-getter'])boundary('public-eval:'+kind,(m,e)=>{
  const leaf={$:'Lit',a:[7]},a={$:'Add',a:[leaf,leaf]};
  if(kind==='tag-getter')Object.defineProperty(a,'$',{get(){e.push('tag');return 'Add';}});
  if(kind==='field-getter')Object.defineProperty(a.a,'0',{get(){e.push('field');return leaf;}});
  if(['deferred-fields','left-error','right-error'].includes(kind))for(let i=0;i<2;i++)a.a[i]={build:true,name:'Lit',fields:[()=>{e.push('deferred:'+i);if(kind===(i===0?'left-error':'right-error'))throw Error(i===0?'left sentinel':'right sentinel');return 7+i;}]};
  return m.call(m.G.eval,[a]);
 }); // Raw embedded descriptors are paired fallback controls, not forcing witnesses.
 for(const key of ['push','pop','concat','slice'])boundary('array:'+key,(m,e)=>{const old=Array.prototype[key];let n=0;const value=hook(Array.prototype,key,{value:function(...a){n++;return Reflect.apply(old,this,a);}},()=>ordinary(m));e.push(['calls',n]);return value;});
 for(const [label,p]of [['Object',Object.prototype],['Array',Array.prototype],['Number',Number.prototype],['Boolean',Boolean.prototype],['BigInt',BigInt.prototype]])for(const key of ['request','bounce','build','code'])boundary('marker:'+label+':'+key,(m,e)=>{
  let n=0;const value=hook(p,key,{get(){n++;return undefined;}},()=>ordinary(m));e.push(['calls',n]);return value;});
 for(const key of ['imul'])for(const kind of ['wrap','getter','mutation','throw'])boundary('Math.'+key+':'+kind,(m,e)=>{const old=Math[key];let n=0,once=false;
  const callback=function(...a){n++;if(kind==='throw')throw Error('Math sentinel');if(kind==='mutation'&&!once){once=true;changed(m,e,'p37.expr');}return Reflect.apply(old,Math,a);};
  try{return hook(Math,key,kind==='getter'?{get(){n++;return old;}}:{value:callback},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const kind of ['wrap','getter','mutation','throw'])boundary('BigInt:'+kind,(m,e)=>{const old=BigInt;let n=0,once=false;
  const callback=function(...a){n++;if(kind==='throw')throw Error('BigInt sentinel');if(kind==='mutation'&&!once){once=true;changed(m,e,'p37.expr');}return Reflect.apply(old,null,a);};
  try{return hook(globalThis,'BigInt',kind==='getter'?{get(){n++;return old;}}:{value:callback},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const x of [null,undefined,1.1,NaN,Infinity,'17'])boundary('noncanonical-seed:'+String(x),m=>m.default.bench(2,x));
 // Every node in the 30,000-deep constructor is inspected iteratively. This is
 // an explicit-frame guarantee, not an assertion that old non-tail JS can do it.
 for(let i=1;i<modules.length;i++){let tree=modules[i].privateExprPoint(30000,17),seed=17,nodes=0;
  for(let n=30000;n>0;n--){const op=seed%3;assert.equal(tree.$,['Add','Mul','Sub'][op]);assert.equal(tree.a.length,2);
   const right=tree.a[1];assert.equal(right.$,op===0?'Mul':'Add');assert.equal(right.a.length,2);
   assert.deepEqual(right.a[0],{$:'Lit',a:[op===1?seed%5:seed]});assert.deepEqual(right.a[1],{$:'Lit',a:[op===0?3:op===1?1:7]});
   nodes+=4;tree=tree.a[0];seed=word(BigInt(seed)+1n);
  }assert.deepEqual(tree,{$:'Lit',a:[seed]});++nodes;assert.equal(nodes,120001);assert.equal(modules[i].privateProofActive(),false);
  report.oracle.push({kind:'deep-explicit-constructor',variant:variants[i],depth:30000,nodes,finalSeed:seed});}
 for(const m of modules)assert.equal(m.privateProofActive(),false);
 for(const row of inputs)assert.deepEqual(identity(row.path),row);report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
