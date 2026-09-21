import assert from 'node:assert/strict';
const {default:K}=await import(process.env.BEND_INDEX_API || '../build/index-test.mjs');
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const atom=name=>({$:'KTerm',tag:'Ref',name,id:0,quant:0,kids:nil,removed:nil});
const def=(name,value)=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ:atom('Type'),value:atom(value),ctors:nil,native:false,unsafe:false});
const ds=Array.from({length:2000},(_,i)=>def('key'+i,'value'+i)),raw=list(ds),cached=K.book_cached(raw,0);
for(let i=0;i<2000;i+=7)assert.equal(K.lookup(cached,'key'+i).value.name,'value'+i);
assert.equal(K.lookup(cached,'missing').kind,'Absent');
assert.equal(K.lookup(K.book_cached(list([def('same','first'),def('same','last')]),0),'same').value.name,'first');
const changed=K.book_put(cached,def('key77','updated'));
assert.equal(K.lookup(changed,'key77').value.name,'updated');
assert.equal(K.lookup(cached,'key77').value.name,'value77');
const fnv=s=>{let h=2166136261;for(const c of s)h=Math.imul((h^c.codePointAt(0))>>>0,16777619)>>>0;return h};
const pair=['costarring','liquid'];assert.equal(fnv(pair[0]),fnv(pair[1]),'test keys have the same hash');
const collided=K.book_cached(list(pair.map((name,i)=>def(name,'collision-value'+i))),0);
for(let i=0;i<2;i++)assert.equal(K.lookup(collided,pair[i]).value.name,'collision-value'+i);
assert.equal(K.lookup(K.book_put(collided,def(pair[0],'replaced')),pair[1]).value.name,'collision-value1');
console.log('PASS persistent indexed lookup, overrides, first-match order and exact hash collisions');

if(K.book_context){
 const context=K.book_context(raw);
 assert.equal(context.head.kind,'BookCache');
 assert.deepEqual(K.book_context(context),context,'prepared context does not nest indexes');
 assert.equal(K.lookup(context,'key77').value.name,'value77');
 assert.equal(K.lookup(K.book_context(list([])),'missing').kind,'Absent');
 console.log('PASS prepared context identity and empty lookup');
}
