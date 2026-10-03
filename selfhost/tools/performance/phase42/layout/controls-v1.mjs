import fs from 'node:fs';
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [arg,outArg]=process.argv.slice(2);assert(arg&&outArg);
const mods={};for(const role of ['original','flat','direct'])mods[role]=await import(pathToFileURL(path.resolve(arg,role+'.mjs')));
function decode(x){if(!x||typeof x!=='object')return x;if(x.$==='Leaf')return {tag:'Leaf',v:x.a?x.a[0]:x._0};if(x.$==='Node')return {tag:'Node',l:decode(x.a?x.a[0]:x._0),r:decode(x.a?x.a[1]:x._1)};if(x.$==='St')return {tag:'St',values:x.a??[x._0,x._1,x._2,x._3]};throw Error('unexpected ADT');}
let completeValues=0,boundaries=0;
for(const d of [0,1,2,3,5])for(const x of [0,17,123,4294967295])for(const s of [false,true]){
 const expected=mods.original.p42Complete(d,x,s);for(const role of ['flat','direct']){assert.deepEqual(decode(mods[role].p42Complete(d,x,s).tree),decode(expected.tree));assert.deepEqual(decode(mods[role].p42Complete(d,x,s).stat),decode(expected.stat));assert.equal(mods[role].p42ProofActive(),false);}++completeValues;
}
for(const role of Object.keys(mods))assert.equal(mods[role].default.bench(8,0),971629740);
const names=['bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
for(const name of names)for(const mode of ['binding','getter','throw','reentry']){
 const observations=[];for(const role of Object.keys(mods)){
  const mod=mods[role],saved=Object.getOwnPropertyDescriptor(mod.G,name),events=[];
  const wrapped={...saved.value,code:function(...args){events.push('code');return saved.value.code.apply(this,args);}};
  if(mode==='binding')Object.defineProperty(mod.G,name,{...saved,value:wrapped});
  else Object.defineProperty(mod.G,name,{configurable:true,enumerable:true,get(){events.push('get');if(mode==='throw')throw Error('layout sentinel');if(mode==='reentry')events.push(['inner',mod.default.bench(0,17)]);return wrapped;}});
  let value,error;try{value=mod.default.bench(2,17);}catch(e){error=e.message;}finally{Object.defineProperty(mod.G,name,saved);}
  assert.equal(mod.p42ProofActive(),false);observations.push({value,error,events});
 }assert.deepEqual(observations[1],observations[0]);assert.deepEqual(observations[2],observations[0]);++boundaries;
}
for(const role of Object.keys(mods)){
 const mod=mods[role],events=[],leaf=mod.ctor('Leaf',[7]);
 assert.deepEqual(leaf,{$:'Leaf',a:[7]});
 const host={$:'Node',get a(){events.push('a');return[leaf,leaf];},get _p42(){throw Error('must not demand marker');},get _0(){throw Error('must not demand private slot');}};
 const result=mod.default.flow(0n,false,host);assert.deepEqual(result,{$:'Node',a:[leaf,leaf]});assert(events.length>0);assert.equal(mod.p42ProofActive(),false);++boundaries;
}
const report={kind:'phase42-layout-controls',complete:true,checked:false,completeValues,boundaries,knownChecksum:971629740,scope:'Selected full trees/statistics and public fallback observations only; direct role assumes closed compiler-owned worker trees.'};
fs.writeFileSync(outArg,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
