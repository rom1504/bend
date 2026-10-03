// Phase42 derivative: complete values and hostile boundaries; root executes.
// Parent: selfhost/tools/performance/phase41/tree/actual-controls.mjs (retained unchanged).
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const[baseArg,outArg]=process.argv.slice(2);assert(baseArg&&outArg,'usage: post-calls-controls.mjs DERIVED NEW_OUT');
const base=path.resolve(baseArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const receipt=JSON.parse(fs.readFileSync(path.join(base,'derive.json')));
assert.equal(receipt.kind,'phase42-post-calls-controls-derived');assert.equal(receipt.complete,true);
for(const row of receipt.modules)assert.equal(sha(fs.readFileSync(row.path)),row.sha256);
const roles=['original','live','hoisted','recursive-ceiling'],mods={};
for(const role of roles)mods[role]=await import(pathToFileURL(path.join(base,role+'.mjs')));
// Oracle uses independent nested arrays, no emitted constructors or workers.
const leaf=x=>[x],node=(l,r)=>[l,r];
function make(d,x,shared,uneven){if(d===0)return leaf(x);const l=make(d-1,(Number(BigInt(x)*3n+1n)&0xffffffff)>>>0,shared,uneven);
 return node(l,shared?l:make(uneven&&d%2===0?0:d-1,(Number(BigInt(x)*5n+7n)&0xffffffff)>>>0,shared,uneven));}
function warp(a,b,s){if(a.length===1&&b.length===1){const flip=s!==(a[0]>b[0]);return node(leaf(flip?b[0]:a[0]),leaf(flip?a[0]:b[0]));}
 if(a.length===1||b.length===1)return leaf(0);
 const l=warp(a[0],b[0],s),r=warp(a[1],b[1],s);
 return l.length===2&&r.length===2?node(node(l[0],r[0]),node(l[1],r[1])):leaf(0);}
function warpNode(t,s){return t.length===1?leaf(t[0]):warp(t[0],t[1],s);}
function flow(n,s,t){if(n===0||t.length===1)return t.length===1?leaf(t[0]):node(t[0],t[1]);
 return node(flow(n-1,s,warpNode(t[0],s)),flow(n-1,s,warpNode(t[1],s)));}
function decode(t){assert(t&&['Leaf','Node'].includes(t.$));return t.$==='Leaf'?leaf(t.a[0]):node(decode(t.a[0]),decode(t.a[1]));}
let oracles=0,boundaries=0;
for(const d of[0,1,2,3,5])for(const n of[0,1,2,4])for(const s of[false,true])for(const[shared,uneven]of[[false,false],[true,false],[false,true]]){
 const seed=(17+d*1234567+n*31)>>>0,expected=flow(n,s,make(d,seed,shared,uneven));
 for(const role of roles){assert.deepEqual(decode(mods[role].p41Flow(n,d,seed,s,shared,uneven)),expected);assert.equal(mods[role].p41ProofActive(),false);}
 ++oracles;
}
for(const role of roles){assert.deepEqual(mods[role].p41Fresh(),[true,true]);assert.deepEqual(mods[role].p41ZeroAliases(),[true,true,true]);assert.equal(mods[role].p41ProofActive(),false);}
oracles+=2;assert(mods.hoisted.p41Counts()>0,'actual wrapper entry required');
// Ordinary public scalar bench must enter optimized call sites.
const before=mods.hoisted.p41Counts();assert.equal(mods.hoisted.default.bench(8,0),971629740);assert(mods.hoisted.p41Counts()>before);assert(mods.hoisted.p42HelperCounts()>0,'actual inline helper entry required');++oracles;
const dependencies=receipt.dependencies;
for(const name of dependencies)for(const mode of['binding','getter']){
 const observations=[];
 for(const role of roles){const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[];
  const original=saved.value,wrapped={...original,code:function(...args){events.push('code');return original.code.apply(this,args);}};
  if(mode==='binding')Object.defineProperty(mod.G,name,{...saved,value:wrapped});
  else Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('get');return wrapped;}});
  const start=mod.p41Counts();let result;
  try{result=mod.default.bench(3,17);}finally{Object.defineProperty(mod.G,name,saved);}
  assert.equal(mod.p41ProofActive(),false);if(role!=='original')assert.equal(mod.p41Counts(),start,'mutation must refuse');
  observations.push({result,events});
 }
 for(const observation of observations.slice(1))assert.deepEqual(observations[0],observation);++boundaries;
}
// In-place wrapper metadata mutations refuse the same private entries.
for(const name of dependencies)for(const field of['code','env','bound']){
 const observations=[];
 for(const role of roles){const mod=mods[role],f=mod.G[name],saved=Object.getOwnPropertyDescriptor(f,field),events=[],start=mod.p41Counts();
  Object.defineProperty(f,field,{configurable:true,enumerable:true,get(){events.push(field);return saved.value;}});
  let result,error;try{result=mod.default.bench(3,17);}catch(e){error=e.message;}finally{Object.defineProperty(f,field,saved);}
  observations.push({result,error,events});assert.equal(mod.p41ProofActive(),false);if(role!=='original')assert.equal(mod.p41Counts(),start,'metadata getter must refuse');
 }
 for(const observation of observations.slice(1))assert.deepEqual(observations[0],observation);++boundaries;
}
// Host-owned input, including a demanded getter, retains generic demand order.
const hostObservations=[];
for(const role of roles){const mod=mods[role],events=[],a=mod.ctor('Leaf',[7]),b=mod.ctor('Leaf',[11]);
 const t={$:'Node',get a(){events.push('a');return[a,b];}},start=mod.p41Counts();
 assert.deepEqual(decode(mod.default.flow(1n,false,t)),flow(1,false,node(leaf(7),leaf(11))));
 assert(events.length>0);hostObservations.push(events);if(role!=='original')assert.equal(mod.p41Counts(),start);assert.equal(mod.p41ProofActive(),false);
}for(const observation of hostObservations.slice(1))assert.deepEqual(hostObservations[0],observation);++boundaries;
// Getter reentry, replacement during demand and a throwing getter preserve events.
for(const mode of['reentry','mutation','throw']){
 const observations=[];
 for(const role of roles){const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,'warp_node'),events=[],start=mod.p41Counts();
  Object.defineProperty(mod.G,'warp_node',{configurable:true,enumerable:true,get(){events.push('get');
   if(mode==='throw')throw Error('phase41 getter sentinel');
   if(mode==='reentry')events.push(['inner',mod.default.bench(0,17)]);
   if(mode==='mutation'){events.push('replace');Object.defineProperty(mod.G,'warp_node',saved);}
   return saved.value;}});
  let result,error;try{result=mod.default.bench(3,17);}catch(e){error=e.message;}finally{Object.defineProperty(mod.G,'warp_node',saved);}
  observations.push({result,error,events});assert.equal(mod.p41ProofActive(),false);
  if(role!=='original')assert.equal(mod.p41Counts(),start,'refused outer entry cannot regain proof');
 }
 for(const observation of observations.slice(1))assert.deepEqual(observations[0],observation);++boundaries;
}
// A throwing dependency preserves errors and closes the ordinary root proof.
for(const role of roles){const mod=mods[role],saved=mod.G.warp_node,start=mod.p41Counts();mod.G.warp_node={...saved,code(){throw Error('phase41 live sentinel');}};
 try{assert.throws(()=>mod.default.bench(3,17),/phase41 live sentinel/);}finally{mod.G.warp_node=saved;}
 assert.equal(mod.p41ProofActive(),false);if(role!=='original')assert.equal(mod.p41Counts(),start);
}++boundaries;
// Explicit iteration avoids native stack use when verifying deep results.
function summary(t){let nodes=0,leaves=0,sum=0n;const todo=[t];while(todo.length){const v=todo.pop();if(v.$==='Leaf'){++leaves;sum+=BigInt(v.a[0]);}else{assert.equal(v.$,'Node');++nodes;todo.push(v.a[1],v.a[0]);}}return{nodes,leaves,sum:String(sum)};}
const deep=roles.filter(role=>role!=='recursive-ceiling').map(role=>summary(mods[role].p41Deep(30000)));
let recursiveDeepError;try{mods['recursive-ceiling'].p41Deep(30000);}catch(e){recursiveDeepError={name:e.name,message:e.message};}
assert.equal(recursiveDeepError?.name,'RangeError','native recursion ceiling must retain deep-stack limitation');assert.equal(mods['recursive-ceiling'].p41ProofActive(),false);for(const result of deep.slice(1))assert.deepEqual(deep[0],result);
// W0 has one Node and two Leaves. zip removes both child-result roots,
// then creates three Nodes: N(Wd)=N(Wd-1)+2=2d+1. The outer
// flow adds one Node and one Leaf, so d=30000 gives these exact totals.
assert.deepEqual(deep[0],{nodes:60002,leaves:60003,sum:'420021'});++oracles;
for(const role of roles)assert.equal(mods[role].p41ProofActive(),false);
// Exhaust scalar leaf order and wraparound key edges inside the diagnostic proof.
for(const a of[0,1,17,2147483647,2147483648,4294967295])for(const b of[0,1,17,2147483648,4294967295])for(const s of[false,true]){
 const expected=warp(leaf(a),leaf(b),s);
 for(const role of roles)assert.deepEqual(decode(mods[role].p42Leaf(a,b,s)),expected);
 ++oracles;
}
for(const x of[0,1,17,2147483647,2147483648,4294967294,4294967295]){
 let a=Number(((BigInt(x)+1n)&0xffffffffn)*2654435761n&0xffffffffn);
 a=Number((BigInt(a)^(BigInt(a)<<13n))&0xffffffffn);
 a=Number((BigInt(a)^(BigInt(a)>>17n))&0xffffffffn);
 const expected=Number((BigInt(a)^(BigInt(a)<<5n))&0xffffffffn);
 for(const role of roles)assert.equal(mods[role].p42Key(x),expected);
 ++oracles;
}
fs.mkdirSync(out,{recursive:false});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
const report={kind:'phase42-post-calls-controls',complete:true,checked:false,parentChecked:true,producer:identity(import.meta.filename),derivation:identity(path.join(base,'derive.json')),modules:receipt.modules,oracles,boundaries,deep:deep[0],nativeRecursionCeiling:{scalarPointsDepthAtMost:12,recursiveDeepError},counts:mods.hoisted.p41Counts()};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
