// Checked compiler output controls. No optimization replacement and no timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'usage: component-actual-controls.mjs DERIVED NEW_OUT');
const base=fs.realpathSync(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const manifestFile=path.join(base,'derive.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
assert.equal(manifest.kind,'phase39-actual-structural-component');assert.equal(manifest.complete,true);assert.equal(manifest.checked,true);
const variants=['original','direct'],files=variants.map(v=>path.join(base,v+'.mjs'));
const inputs=[import.meta.filename,manifestFile,...files,manifest.typescript.path].map(identity);
for(const row of manifest.inputs){assert.equal(identity(row.path).sha256,row.sha256);inputs.push(identity(row.path));}
for(let i=0;i<files.length;i++)assert.equal(identity(files[i]).sha256,manifest.modules.find(m=>m.variant===variants[i]&&m.counters).sha256);
assert.equal(identity(manifest.typescript.path).sha256,manifest.typescript.sha256);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase39-actual-structural-component-controls',complete:false,pass:false,node:process.version,inputs,
 attempt:manifest.attempt,compiler:manifest.compiler,variants,oracle:[],boundaries:[],admission:[]};
const modules=[];for(const file of files)modules.push(await import(pathToFileURL(file)));
const typescript=await import(pathToFileURL(manifest.typescript.path));
const word=x=>Number(BigInt.asUintN(32,x));
// Independent arrays and BigInt arithmetic describe source semantics, not JS ABI.
function inputOracle(kind,n,seed,sharing=0){const step=kind==='A'?1n:3n;
 let value=['L',word(BigInt(seed)+BigInt(n)*step)];
 for(let i=n-1;i>=0;i--){const s=word(BigInt(seed)+BigInt(i)*step),leaf=['L',kind==='A'?s:word(BigInt(s)^91n)];value=['N',value,sharing?value:leaf];}return value;}
function mixOracle(a,b,flag,mode='mix'){
 if(a[0]==='L'&&b[0]==='L')return ['L',word(mode==='mix'?BigInt(a[1])*3n^BigInt(b[1]):mode==='dependent'?BigInt(a[1])+BigInt(b[1]):BigInt(a[1])^BigInt(b[1]))];
 if(a[0]==='L')return ['L',word(BigInt(a[1])+(mode==='mix'?17n:0n))];
 if(b[0]==='L')return ['L',word(BigInt(b[1])+(mode==='mix'?23n:0n))];
 const left=mixOracle(a[1],b[1],flag,mode),right=mixOracle(a[2],b[2],mode==='dependent'?scoreOracle(left)===0:flag,mode);
 return ['N',left,flag?left:right];
}
function scoreOracle(value){return value[0]==='L'?value[1]:word(BigInt(scoreOracle(value[1]))+1n+BigInt(scoreOracle(value[2])));}
const benchOracle=(n,s,mode='mix')=>scoreOracle(mixOracle(inputOracle('A',n,s),inputOracle('B',n,s),mode==='mix'&&s%2===0,mode));
function canonical(value){assert(value&&typeof value==='object');assert(Array.isArray(value.a));
 if(value.$==='OEnd'){assert.equal(value.a.length,1);assert.equal(typeof value.a[0],'number');return ['L',value.a[0]];}
 assert.equal(value.$,'OFork');assert.equal(value.a.length,2);return ['N',canonical(value.a[0]),canonical(value.a[1])];}
function checkAliases(value,flag){if(value.$==='OEnd')return 1;assert.equal(value.a[0]===value.a[1],flag,'combine alias contract');
 return 1+checkAliases(value.a[0],flag)+(flag?0:checkAliases(value.a[1],flag));}
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
const ordinary=m=>m.default.bench(4,17),force=(m,x)=>m.call({arity:0,code:()=>x,env:null,bound:[]},[]);
const tsCall=(name,args)=>typescript.default[name](...args.map(x=>typeof x==='bigint'?Number(x):x));
function scalar(name,args,expected){const results=[...modules.map(m=>m.default[name](...args)),tsCall(name,args)];report.current={kind:'checked-three-role',name,args:normalize(args),expected,results};
 for(const result of results)assert.equal(result,expected,name);report.oracle.push(report.current);delete report.current;}
try{
 for(const n of [0,1,3,7])for(const seed of [0,17,4294967295]){
  scalar('bench',[n,seed],benchOracle(n,seed));
  scalar('tail_check',[n,seed],word(BigInt(seed)*2n+BigInt(n)));
  scalar('dependent_check',[n,seed],benchOracle(n,seed,'dependent'));
  scalar('back_check',[n,seed],benchOracle(n,seed,'back'));
 }
 for(const da of [0,1,3])for(const db of [0,1,3])for(const seed of [0,17,4294967295])for(const flag of [false,true])for(const sharing of [0,1]){
  const expected=mixOracle(inputOracle('A',da,seed,sharing),inputOracle('B',db,seed,sharing),flag),results=[];
  for(const m of modules){const value=m.privateComponentPoint(da,db,seed,flag,sharing);assert.deepEqual(canonical(value),expected);results.push({score:scoreOracle(canonical(value)),distinctVisited:checkAliases(value,flag)});}
  report.oracle.push({kind:'full-independent-mixed-ADT',da,db,seed,flag,sharing,expected,results});
 }
 {const m=modules[1],before=m.privateComponentCounts();assert.equal(m.default.bench(4,17),benchOracle(4,17));const after=m.privateComponentCounts();
  assert(after.root>before.root,'actual bench must open source proof');assert(after.component>before.component,'actual bench must enter emitted worker');
  report.admission.push({kind:'actual-source-entry',before,after});}
 for(const name of ['component.cycle','component.mutual']){
  const before=modules[1].privateComponentCounts();scalar(name,[30000n,17],benchOracle(3,30017));const after=modules[1].privateComponentCounts();
  assert(after.component>before.component,'deep tail terminal worker must enter');assert.equal(modules[1].privateProofActive(),false);
  report.admission.push({kind:'deep-tail-cycle',name,steps:30000,before,after});
 }
 for(const [name,root,args]of [
  ['bench','bench',[4,17]],['component.mix','bench',[4,17]],['component.join','bench',[4,17]],['component.makeA','bench',[4,17]],['component.makeB','bench',[4,17]],['component.score','bench',[4,17]],
  ['component.tail','tail_check',[4,17]],['tail_check','tail_check',[4,17]],['component.dependent','dependent_check',[4,17]],['dependent_check','dependent_check',[4,17]],
  ['component.back','back_check',[4,17]],['component.redirect','back_check',[4,17]],['back_check','back_check',[4,17]],['component.cycle','component.cycle',[3n,17]],['component.mutual','component.cycle',[3n,17]],
 ])for(const kind of ['wrap','getter','binding'])boundary(name+':'+kind,(m,e)=>{changed(m,e,name,kind);return m.default[root](...args);},{live:true,refuse:!['component.cycle','component.mutual'].includes(name)});
 for(const count of [0,1,2])boundary('prefix:'+count,m=>{const p=m.call(m.G.bench,[4,17].slice(0,count));return count===2?p:m.call(p,[4,17].slice(count));},{refuse:false});
 for(const kind of ['raw','forged','new','own-call','oversaturated','slot-mutation','slot-throw','slot-reentry'])boundary('entry:'+kind,(m,e)=>{
  const f=m.G.bench,code=f.code;let busy=false;const a={length:2,1:17};Object.defineProperty(a,'0',{get(){e.push('slot:0');
   if(kind==='slot-mutation')changed(m,e,'component.join');if(kind==='slot-throw')throw Error('slot sentinel');
   if(kind==='slot-reentry'&&!busy){busy=true;e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);}return 4;}});
  if(kind==='raw'||kind==='forged')return force(m,Reflect.apply(code,null,[a,kind==='forged']));
  if(kind==='new')return force(m,Reflect.construct(code,[a]));
  if(kind==='own-call'){code.call=function(env,a){e.push('call');return Reflect.apply(code,env,[a]);};return ordinary(m);}
  if(kind==='oversaturated')return m.call(f,[4,17,99]);return m.call(f,{slice(){e.push('slice');return a;}});
 },{refuse:kind!=='slot-reentry'});
 for(const kind of ['mutation','throw','reentry'])boundary('entry:slot1-'+kind,(m,e)=>{
  const code=m.G.bench.code,a={length:2,0:4};Object.defineProperty(a,'1',{get(){e.push('slot:1');
   if(kind==='mutation')changed(m,e,'component.join');if(kind==='throw')throw Error('second slot sentinel');
   if(kind==='reentry')e.push(['nested',force(m,Reflect.apply(code,null,[[1,7]]))]);return 17;}});
  return m.call(m.G.bench,{slice(){e.push('slice');return a;}});
 },{refuse:kind!=='reentry'});
 const leaf=(kind,value)=>({$:kind+'End',a:[value]}),fork=(kind,l,r)=>({$:kind+'Fork',a:[l,r]});
 for(const kind of ['plain','alias','tag-getter','field-getter','left-error','right-error']){
  const rows=boundary('public-mix:'+kind,(m,e)=>{
   const al=leaf('A',7),ar=kind==='alias'?al:leaf('A',13),bl=leaf('B',19),br=kind==='alias'?bl:leaf('B',23),a=fork('A',al,ar),b=fork('B',bl,br);
   if(kind==='tag-getter')Object.defineProperty(a,'$',{get(){e.push('tag');return 'AFork';}});
   if(['field-getter','left-error'].includes(kind))Object.defineProperty(a.a,'0',{get(){e.push('left');if(kind==='left-error')throw Error('left sentinel');return al;}});
   if(kind==='right-error')Object.defineProperty(b.a,'1',{get(){e.push('right');throw Error('right sentinel');}});
   return canonical(m.call(m.G['component.mix'],[a,b,false]));
  },{live:!['plain','alias'].includes(kind)});
  for(const row of rows){if(kind.endsWith('-error'))assert.equal(row.error?.message,kind==='left-error'?'left sentinel':'right sentinel');else assert.equal(row.error,undefined);}
 }
 for(const kind of ['deferred','left-error','right-error','tag-getter','field-getter']){
  const rows=boundary('foreign-producer:'+kind,(m,e)=>{
   const left=leaf('A',7),right=leaf('A',13);let value=fork('A',left,right);
   if(kind==='tag-getter')Object.defineProperty(value,'$',{get(){e.push('tag');return 'AFork';}});
   if(kind==='field-getter')Object.defineProperty(value.a,'0',{get(){e.push('field:0');return left;}});
   if(['deferred','left-error','right-error'].includes(kind))value={build:true,name:'AFork',fields:[()=>{e.push('left');if(kind==='left-error')throw Error('left sentinel');return left;},()=>{e.push('right');if(kind==='right-error')throw Error('right sentinel');return right;}]};
   m.G['component.makeA']={arity:2,code(){e.push('foreign-producer');return value;},env:null,bound:[]};return ordinary(m);
  },{live:true});
  for(const row of rows){if(['deferred','left-error','right-error'].includes(kind))assert.deepEqual(row.events,kind==='left-error'?['foreign-producer','left']:['foreign-producer','left','right']);
   if(kind.endsWith('-error'))assert.equal(row.error?.message,kind==='left-error'?'left sentinel':'right sentinel');
   if(kind==='tag-getter')assert(row.events.includes('tag'));if(kind==='field-getter')assert(row.events.includes('field:0'));}
 }
 // Raw delayed descriptors inside already-built fields are paired fallback
 // observations only; the complete foreign build above witnesses forcing order.
 for(const where of ['a-left','a-right','b-left','b-right'])boundary('embedded-delayed:'+where,(m,e)=>{
  const a=fork('A',leaf('A',7),leaf('A',13)),b=fork('B',leaf('B',19),leaf('B',23)),side=where[0]==='a'?a:b,index=where.endsWith('left')?0:1;
  side.a[index]={build:true,name:where[0]==='a'?'AEnd':'BEnd',fields:[()=>{e.push('delayed');return 29;}]};return m.call(m.G['component.mix'],[a,b,false]);
 });
 for(const key of ['push','pop','concat','slice'])boundary('array:'+key,(m,e)=>{const old=Array.prototype[key];let n=0;const value=hook(Array.prototype,key,{value:function(...a){n++;return Reflect.apply(old,this,a);}},()=>ordinary(m));e.push(['calls',n]);return value;});
 for(const [label,p]of [['Object',Object.prototype],['Array',Array.prototype],['Number',Number.prototype],['Boolean',Boolean.prototype],['BigInt',BigInt.prototype]])for(const key of ['request','bounce','build','code'])boundary('marker:'+label+':'+key,(m,e)=>{
  let n=0;const value=hook(p,key,{get(){n++;return undefined;}},()=>ordinary(m));e.push(['calls',n]);return value;});
 for(const kind of ['wrap','getter','mutation','throw','reentry'])boundary('Math.imul:'+kind,(m,e)=>{const old=Math.imul;let n=0,once=false;
  const callback=function(...a){n++;if(kind==='throw')throw Error('Math sentinel');if(!once){once=true;if(kind==='mutation')changed(m,e,'component.join');if(kind==='reentry')e.push(['nested',m.default.tail_check(2,3)]);}return Reflect.apply(old,Math,a);};
  try{return hook(Math,'imul',kind==='getter'?{get(){n++;return old;}}:{value:callback},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const kind of ['wrap','getter','mutation','throw'])boundary('BigInt:'+kind,(m,e)=>{const old=BigInt;let n=0,once=false;
  const callback=function(...a){n++;if(kind==='throw')throw Error('BigInt sentinel');if(kind==='mutation'&&!once){once=true;changed(m,e,'component.join');}return Reflect.apply(old,null,a);};
  try{return hook(globalThis,'BigInt',kind==='getter'?{get(){n++;return old;}}:{value:callback},()=>ordinary(m));}finally{e.push(['calls',n]);}});
 for(const x of [null,undefined,1.1,NaN,Infinity,'17'])boundary('noncanonical-seed:'+String(x),m=>m.default.bench(2,x));
 // No native-recursion assumption for the old generic algorithm: only the
 // candidate's explicit frame path gets the deep owned-input assertion.
 {const m=modules[1],before=m.privateComponentCounts();let value=m.privateComponentPoint(30000,30000,17,false),nodes=0;
  for(let i=0;i<30000;i++){assert.equal(value.$,'OFork');assert.equal(value.a.length,2);const side=value.a[1],a=word(17n+BigInt(i)),b=word(17n+3n*BigInt(i));
   assert.deepEqual(side,{$:'OEnd',a:[word(BigInt(a)*3n^(BigInt(b)^91n))]});nodes+=2;value=value.a[0];}
  assert.deepEqual(value,{$:'OEnd',a:[word((17n+30000n)*3n^(17n+90000n))]});++nodes;assert.equal(nodes,60001);
  const after=m.privateComponentCounts();assert(after.component>before.component);assert.equal(m.privateProofActive(),false);
  report.oracle.push({kind:'deep-explicit-component',depth:30000,nodes,before,after});
 }
 for(const m of modules)assert.equal(m.privateProofActive(),false);
 for(const row of inputs)assert.deepEqual(identity(row.path),row);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,oracle:report.oracle.length,boundaries:report.boundaries.length,admission:report.admission.length,error:report.error}));
