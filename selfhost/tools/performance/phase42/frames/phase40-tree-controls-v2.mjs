// Checked compiler output controls. No optimization replacement and no timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'usage: tree-nat-actual-controls.mjs DERIVED NEW_OUT');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase40-actual-nat-component');assert.equal(manifest.complete,true);assert.equal(manifest.checked,true);
const variants=['original','direct'],files=variants.map(v=>path.join(base,v+'.mjs'));
const inputs=[import.meta.filename,manifestFile,...files,manifest.typescript.path].map(identity);
for(const row of manifest.inputs){assert.equal(identity(row.path).sha256,row.sha256);inputs.push(identity(row.path));}
for(let i=0;i<files.length;i++)assert.equal(identity(files[i]).sha256,manifest.modules.find(m=>m.variant===variants[i]&&m.counters).sha256);
assert.equal(identity(manifest.typescript.path).sha256,manifest.typescript.sha256);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-phase40-tree-controls-v2.mjs'));
const report={kind:'phase40-actual-nat-component-controls',complete:false,pass:false,node:process.version,inputs,
 attempt:manifest.attempt,compiler:manifest.compiler,variants,oracle:[],boundaries:[],admission:[]};
const modules=[];for(const file of files)modules.push(await import(pathToFileURL(file)));
const typescript=await import(pathToFileURL(manifest.typescript.path));
function normalize(x,seen=new Set()){if(typeof x==='bigint')return String(x)+'n';if(typeof x==='function')return '[Function]';
 if(x===undefined)return '[Undefined]';if(typeof x==='number'&&(!Number.isFinite(x)||Object.is(x,-0)))return {number:String(x),negativeZero:Object.is(x,-0)};
 if(x===null||typeof x!=='object')return x;if(seen.has(x))return '[Cycle]';seen.add(x);
 const r=Array.isArray(x)?x.map(v=>normalize(v,seen)):Object.fromEntries(Object.keys(x).sort().map(k=>[k,normalize(x[k],seen)]));seen.delete(x);return r;}
function snapshot(m){const gd=Object.getOwnPropertyDescriptors(m.G),objects=[];
 for(const d of Object.values(gd)){const f=d.value;if(f&&typeof f==='object')for(const value of [f,f.code,f.bound])if(value&&(typeof value==='object'||typeof value==='function'))objects.push([value,Object.getOwnPropertyDescriptors(value)]);}
 return()=>{for(const [object,descs]of objects){for(const k of Reflect.ownKeys(object))if(!Object.hasOwn(descs,k))delete object[k];Object.defineProperties(object,descs);}
 for(const k of Reflect.ownKeys(m.G))if(!Object.hasOwn(gd,k))delete m.G[k];Object.defineProperties(m.G,gd);};}
function observe(m,action){const restore=snapshot(m),events=[],before=m.privateComponentCounts();let value,error;
 try{value=action(m,events);}catch(e){error={name:e.name,message:e.message};}finally{restore();}
 assert.equal(m.privateProofActive(),false,'proof leaked across boundary');
 const after=m.privateComponentCounts();return {value:normalize(value),error,events:normalize(events),counts:Object.fromEntries(Object.keys(before).map(k=>[k,after[k]-before[k]]))};}
function boundary(name,action,{live=false,refuse=true}={}){const observations=modules.map(m=>observe(m,action));report.current={name,observations};
 const comparable=row=>({value:row.value,error:row.error,events:row.events});assert.deepEqual(comparable(observations[1]),comparable(observations[0]),name);
 if(live)assert(observations[0].events.length>0,'inactive witness '+name);
 if(refuse)assert.equal(observations[1].counts.component,0,'actual worker despite refusal '+name);
 report.boundaries.push(report.current);delete report.current;return observations;}
function changed(m,e,name,kind='wrap'){const f=m.G[name],code=f.code;
 if(kind==='binding')Object.defineProperty(m.G,name,{configurable:true,get(){e.push('G:'+name);return f;}});
 else if(kind==='getter')Object.defineProperty(f,'code',{configurable:true,get(){e.push('code:'+name);return code;}});
 else f.code=function(a){e.push('invoke:'+name);return Reflect.apply(code,this,[a]);};}
function hook(object,key,descriptor,action){const old=Object.getOwnPropertyDescriptor(object,key);try{Object.defineProperty(object,key,{configurable:true,...descriptor});return action();}
 finally{if(old)Object.defineProperty(object,key,old);else delete object[key];}}
const ordinary=m=>m.default.bench(4,17);
const u=x=>Number(BigInt.asUintN(32,BigInt(x)));
function input(d,seed,sharing=0){let t=['L',u(BigInt(seed)+BigInt(d))];for(let i=d-1;i>=0;i--){const leaf=['L',u(BigInt(seed+i)^91n)];t=['N',t,sharing?t:leaf];}return t;}
function turn(t,flag){return t[0]==='L'?['L',u(BigInt(t[1])+7n)]:['N',flag?t[2]:t[1],flag?t[1]:t[2]];}
function flow(n,t,flag){if(n===0)return t[0]==='L'?['L',t[1]]:['N',t[1],t[2]];if(t[0]==='L')return ['L',t[1]];
 const left=flow(n-1,turn(t[1],flag),flag),right=flow(n-1,turn(t[2],flag),flag);return ['N',left,flag?left:right];}
function score(t){return t[0]==='L'?t[1]:u(BigInt(score(t[1]))+1n+BigInt(score(t[2])));}
function canonical(t){assert(t&&typeof t==='object');assert(Array.isArray(t.a));if(t.$==='NEnd'){assert.equal(t.a.length,1);return ['L',t.a[0]];}assert.equal(t.$,'NFork');assert.equal(t.a.length,2);return ['N',canonical(t.a[0]),canonical(t.a[1])];}
function aliases(t,n,flag){if(t.$==='NEnd')return;if(n>0)assert.equal(t.a[0]===t.a[1],flag);aliases(t.a[0],n-1,flag);if(!flag)aliases(t.a[1],n-1,flag);}
const tsCall=(name,args)=>typescript.default[name](...args.map(x=>typeof x==='bigint'?Number(x):x));
try{
 for(const n of [0,1,2,4,7])for(const d of [0,1,3,7])for(const seed of [0,17,4294967295])for(const flag of [false,true])for(const sharing of [0,1]){
  const expected=flow(n,input(d,seed,sharing),flag),results=[];for(const m of modules){const t=m.privateComponentPoint(n,d,seed,flag,sharing);assert.deepEqual(canonical(t),expected);aliases(t,n,flag);results.push(canonical(t));}
  report.oracle.push({kind:'full-nat-coordinate-flow',n,d,seed,flag,sharing,expected,results});
 }
 for(const d of [0,1,3,7])for(const seed of [0,17,4294967295]){
  const expected=score(flow(d,input(d,seed),seed%2===0)),results=[...modules.map(m=>m.default.bench(d,seed)),tsCall('bench',[d,seed])];for(const r of results)assert.equal(r,expected);report.oracle.push({kind:'three-role-independent-bench',d,seed,expected,results});
  for(const name of ['computed_check','parent_check','dependent_check','back_check']){const expected=score(input(d,seed)),results=[...modules.map(m=>m.default[name](d,seed)),tsCall(name,[d,seed])];for(const r of results)assert.equal(r,expected);report.oracle.push({kind:'refused-shape-execution',name,d,seed,expected,results});}
 }
 for(const m of modules)assert.deepEqual(m.privateZeroAliases(),[true,true,true]);report.oracle.push({kind:'zero-root-fresh-children-aliased'});
 {const m=modules[1],before=m.privateComponentCounts();assert(before.globalComponent>0,'owned diagnostics enter original global worker');m.default.bench(4,17);const after=m.privateComponentCounts();assert(after.root>before.root);assert(after.component>before.component);assert(after.lexicalComponent>before.lexicalComponent,'ordinary scalar bench enters lexical flat clone');assert.equal(after.component,after.globalComponent+after.lexicalComponent);report.admission.push({kind:'ordinary-entry',before,after});}
 for(const name of manifest.dependencies)for(const kind of ['wrap','getter','binding'])boundary(name+':'+kind,(m,e)=>{changed(m,e,name,kind);const exportName=name.includes('computed')?'computed_check':name.includes('parent')?'parent_check':name.includes('dependent')?'dependent_check':name.includes('back')||name.includes('redirect')?'back_check':'bench';return m.default[exportName](4,17);},{live:true});
 for(const key of ['push','pop','concat','slice'])boundary('Array:'+key,(m,e)=>{const old=Array.prototype[key];let n=0;const value=hook(Array.prototype,key,{value:function(...a){n++;return Reflect.apply(old,this,a);}},()=>ordinary(m));e.push(['calls',n]);return value;});
 for(const [label,p]of [['Object',Object.prototype],['Array',Array.prototype],['Number',Number.prototype],['Boolean',Boolean.prototype],['BigInt',BigInt.prototype]])for(const key of ['request','bounce','build','code'])boundary('marker:'+label+':'+key,(m,e)=>{let n=0;const value=hook(p,key,{get(){n++;return undefined;}},()=>ordinary(m));e.push(['calls',n]);return value;});
 for(const kind of ['deferred','left-error','right-error']){
  const observations=boundary('caseorder:'+kind,(m,e)=>{let index=0;m.G['natflow.turn']={arity:2,code(a){const i=index++;e.push(['turn',i]);return {build:true,name:'NEnd',fields:[()=>{e.push(['field',i]);if(kind==='left-error'&&i===0)throw Error('left sentinel');if(kind==='right-error'&&i===1)throw Error('right sentinel');return a[0].a[0];}]};},env:null,bound:[]};return m.default.bench(1,17);},{live:true});
  for(const o of observations){assert.deepEqual(o.events,kind==='left-error'?[['turn',0],['field',0]]:[['turn',0],['field',0],['turn',1],['field',1]]);if(kind!=='deferred')assert.equal(o.error?.message,kind==='left-error'?'left sentinel':'right sentinel');}
 }
 for(const kind of ['raw','forged','new','slot-throw','slot-mutation','slot-reentry'])boundary('entry:'+kind,(m,e)=>{
  const f=m.G.bench,code=f.code;let busy=false;const slots={length:2,1:17};Object.defineProperty(slots,'0',{get(){e.push('slot0');if(kind==='slot-throw')throw Error('slot sentinel');if(kind==='slot-mutation')changed(m,e,'natflow.join');if(kind==='slot-reentry'&&!busy){busy=true;e.push(['nested',m.call({arity:0,code:()=>Reflect.apply(code,null,[[1,7]]),env:null,bound:[]},[])]);}return 3;}});
  const value=kind==='new'?Reflect.construct(code,[slots]):Reflect.apply(code,null,[slots,kind==='forged']);return m.call({arity:0,code:()=>value,env:null,bound:[]},[]);
 });
 for(const kind of ['plain','tag-getter','field-getter','left-deferred','left-error','right-error'])boundary('public-tree:'+kind,(m,e)=>{
  const leaf={$:'NEnd',a:[7]},other={$:'NEnd',a:[11]},t={$:'NFork',a:[leaf,other]};
  if(kind==='tag-getter')Object.defineProperty(t,'$',{get(){e.push('tag');return 'NFork';}});
  if(kind==='field-getter')Object.defineProperty(t.a,'0',{get(){e.push('field0');return leaf;}});
  if(['left-deferred','left-error','right-error'].includes(kind)){t.a[0]={build:true,name:'NEnd',fields:[()=>{e.push('left');if(kind==='left-error')throw Error('left sentinel');return 7;}]};t.a[1]={build:true,name:'NEnd',fields:[()=>{e.push('right');if(kind==='right-error')throw Error('right sentinel');return 11;}]};}
  return m.default['natflow.flow'](1n,false,t);
 },{live:kind==='tag-getter'||kind==='field-getter'});
 {const m=modules[1],before=m.privateComponentCounts(),depth=30000,value=m.privateComponentPoint(depth,depth,17,false),todo=[value];let nodes=0,leaves=0,sum=0n;
  while(todo.length){const t=todo.pop();if(t.$==='NEnd'){assert.equal(t.a.length,1);leaves++;sum+=BigInt(t.a[0]);}else{assert.equal(t.$,'NFork');assert.equal(t.a.length,2);nodes++;todo.push(t.a[1],t.a[0]);}}
  let expected=BigInt(u(17+depth+7));for(let i=0;i<depth;i++)expected+=BigInt(u(BigInt(u(17+i)^91)+7n));
  assert.equal(nodes,depth);assert.equal(leaves,depth+1);assert.equal(sum,expected);const after=m.privateComponentCounts();assert(after.component>before.component);assert.equal(m.privateProofActive(),false);report.oracle.push({kind:'deep-native-nat-explicit-frame',depth,nodes,leaves,sum:String(sum),expected:String(expected)});
 }
 for(const m of modules)assert.equal(m.privateProofActive(),false);for(const row of report.inputs)assert.deepEqual(identity(row.path),row);report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,error:report.error}));
