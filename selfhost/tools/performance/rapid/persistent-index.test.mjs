import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {performance} from 'node:perf_hooks';
if(!process.argv[2]||!process.argv[3])throw Error('usage: node persistent-index.test.mjs CANDIDATE_API CONTROL_API');
const input=path.resolve(process.argv[2]);
const controlPath=path.resolve(process.argv[3]);
const component=await import(pathToFileURL(input));
const {createCompilerAbi}=await import('../../compiler-abi.mjs');
const fields={Nil:[],Con:['head','tail'],KTerm:['tag','name','id','quant','kids','removed'],KDef:['name','kind','arity','templates','typ','value','ctors','native','unsafe']};
const named=m=>m.G?createCompilerAbi({fields,ctor:m.ctor}).wrap(m.default):(m.rapidIndexControl??m.default);
const P=named(component);
const control=await import(pathToFileURL(controlPath));
const C=named(control);
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const unlist=xs=>{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail}assert.equal(xs.$,'Nil');return out};
const atom=(name,id=0)=>({$:'KTerm',tag:'Ref',name,id,quant:0,kids:nil,removed:nil});
const def=(name,value,id=0)=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:atom('Type',id),value:atom(value),ctors:nil,native:false,unsafe:false});
const hash=name=>{let h=2166136261;for(const c of name)h=Math.imul(h^c.codePointAt(0),16777619)>>>0;return h};
const defs=Array.from({length:1024},(_,i)=>def(`namespace/key_${i}`,`value_${i}`,i));
const pairs=['costarring','liquid','__proto__','constructor','','🦀','α','a\0b'].map((name,i)=>def(name,`special_${i}`));
let checks=0;
function same(a,b,label){assert.deepEqual(a,b,label);checks++}
function structure(root){
 const hashes=new Set();let leaves=0,branches=0,maxDepth=0;
 const todo=[[root,0,0]];
 while(todo.length){const [node,parentMask,depth]=todo.pop();maxDepth=Math.max(maxDepth,depth);
  if(node.kind==='Absent'){assert.equal(depth,0);continue}
  if(node.kind==='IndexLeaf'){
   leaves++;assert.equal(node.templates,0);
   for(const d of unlist(node.ctors)){assert.equal(hash(d.name),node.arity);hashes.add(node.arity)}
  }else{assert.equal(node.kind,'IndexNode');branches++;const mask=node.templates;
   assert.ok(mask>parentMask);assert.equal((mask & (mask-1))>>>0,0);const children=unlist(node.ctors);assert.equal(children.length,2);
   todo.push([children[0],mask,depth+1],[children[1],mask,depth+1]);
  }
 }
 assert.equal(leaves,hashes.size);assert.equal(branches,Math.max(0,leaves-1));assert.ok(maxDepth<=32);
 return {leaves,branches,maxDepth};
}
let seed=0x4f91320b;
const random=()=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0};
const start=performance.now();
const snapshots=[];
for(const size of [0,1,2,8,128,1024]){
 const ds=[...defs.slice(0,size),...pairs,def('costarring','losing_duplicate')];
 let expected=[...ds],p=P.book_cached(list(ds),777),c=C.book_cached(list(ds),777);
 for(const name of [...ds.map(d=>d.name),'absent_key'])same(P.lookup(p,name),C.lookup(c,name),'initial lookup');
 same(P.book_context(p),p,'no nested sentinel');
 for(let i=0;i<80;i++){
  const slot=random()%Math.max(1,size+16),name=`namespace/key_${slot}`,d=def(name,`replacement_${size}_${i}`);
  snapshots.push({p,c,names:[name,'costarring','liquid','absent_key']});
  p=P.book_put(p,d);c=C.book_put(c,d);expected=[d,...expected.filter(old=>old.name!==name)];
  same(P.lookup(p,name),d,'insert replacement');
  same(p.head.arity,777,'cached bound');
  if(i%13===0){same(unlist(p.tail),expected,'declaration order');same(unlist(p.tail),unlist(c.tail),'control declaration order')}
 }
 structure(p.head.ctors.head);
 for(let i=0;i<256;i++){
  const name=`namespace/key_${random()%Math.max(1,size+32)}`;
  same(P.lookup(p,name),C.lookup(c,name),'random lookup');
 }
}
for(const {p,c,names} of snapshots)for(const name of names)same(P.lookup(p,name),C.lookup(c,name),'immutable snapshot');
// An absence fast path must preserve duplicate filtering even for empty names
// or a real definition whose kind happens to be the missing sentinel string.
for(const name of ['', 'sentinel-kind']){
 const weird={...def(name,'first'),kind:'Absent'};
 const raw=list([weird,def(name,'duplicate'),def('other','other')]);
 const replacement=def(name,'replacement');
 const p=P.book_put(P.book_cached(raw,99),replacement);
 const c=C.book_put(C.book_cached(raw,99),replacement);
 same(unlist(p.tail),unlist(c.tail),'generic sentinel-name replacement');
 same(P.lookup(p,name),C.lookup(c,name),'generic sentinel-name lookup');
}
// The low-level ABI is also used for native generated IDs. Exercise every split
// bit (including unsigned high bit), arbitrary supplied hashes, and collisions.
let p=P.missing(),c=C.missing();const low=[];
for(let bit=0;bit<32;bit++){
 const h=(2**bit)>>>0,d=def(`direct/bit_${bit}`,String(bit));
 p=P.index_set(p,d,h,32);c=C.index_set(c,d,h,32);low.push([h,d]);
}
for(const [h,d] of low)same(P.index_find(p,d.name,h,32),C.index_find(c,d.name,h,32),'direct root lookup');
for(const d of [def('direct/collision_a','a'),def('direct/collision_b','b')]){
 p=P.index_set(p,d,0xffffffff,32);c=C.index_set(c,d,0xffffffff,32);
 same(P.index_find(p,d.name,0xffffffff,32),C.index_find(c,d.name,0xffffffff,32),'direct collision');
}
same(P.index_find(p,'direct/bit_31',1,32),C.index_find(c,'direct/bit_31',1,32),'wrong supplied hash');
// Cache bound derives from ordinary declarations, never index metadata.
const context=P.book_context(list([def('id','v',0xf0000000)]));same(context.head.arity,0xf0000000,'computed bound');
const large=P.book_cached(list(defs),1024);const metrics=structure(large.head.ctors.head);
const report={passed:true,checks,seed:'0x4f91320b',component:input,control:controlPath,seconds:(performance.now()-start)/1000,metrics};
console.log(JSON.stringify(report));
if(process.env.RAPID_INDEX_BENCH==='1'){
 const size=Number(process.env.RAPID_INDEX_SIZE??1024),probes=Number(process.env.RAPID_INDEX_PROBES??4096);
 const book=list(Array.from({length:size},(_,i)=>def(`bench/name_${i}`,String(i))));
 const keys=Array.from({length:probes},(_,i)=>`bench/name_${i%size}`);
 for(let iteration=0;iteration<3;iteration++)for(const [label,K]of iteration%2?[['patricia',P],['control',C]]:[['control',C],['patricia',P]]){
  const begin=performance.now();let cached=K.book_cached(book,size);const built=performance.now();let sum=0;
  for(const name of keys)sum+=Number(K.lookup(cached,name).value.name);
  const looked=performance.now();
  for(let i=0;i<64;i++)cached=K.book_put(cached,def(`bench/name_${i%size}`,'replacement'));
  const updated=performance.now();
  for(let i=0;i<64;i++)cached=K.book_put(cached,def(`bench/new_name_${i}`,'inserted'));
  const inserted=performance.now();
  console.log(JSON.stringify({benchmark:'bend-patricia',label,iteration,size,probes,buildMs:built-begin,lookupMs:looked-built,update64Ms:updated-looked,insert64Ms:inserted-updated,checksum:sum}));
 }
}
