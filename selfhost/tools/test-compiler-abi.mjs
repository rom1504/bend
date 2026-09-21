import assert from 'node:assert/strict';
import {createCompilerAbi} from './compiler-abi.mjs';

const fields={Nil:[],Con:['head','tail'],Box:['value'],Pair:['left','right']};
const ctor=($,a)=>({$,a});
const abi=createCompilerAbi({fields,ctor});
const nil=ctor('Nil',[]),shared=ctor('Box',[17]);
const raw=ctor('Pair',[shared,shared]);
const view=abi.decode(raw);
assert.equal(abi.stats().views,1,'decoding a root must not visit its children');
assert.equal(view.left,view.right,'shared fields have identical views');
assert.equal(abi.decode(raw),view);
assert.equal(abi.encode(view),raw,'phase handoff retains exact raw graph');
assert.deepEqual(Object.keys(view),['$','left','right']);
assert.equal('left' in view,true);
assert.equal('missing' in view,false);
assert.deepEqual({...view},{$:'Pair',left:view.left,right:view.right});
assert.equal(Object.getOwnPropertyDescriptor(view,'left').value,view.left);
assert.equal(JSON.stringify(view),'{"$":"Pair","left":{"$":"Box","value":17},"right":{"$":"Box","value":17}}');
assert.throws(()=>{view.left=nil;},/read-only/);

const host={$:'Pair',left:view,right:view};
const encoded=abi.encode(host);
assert.equal(encoded.a[0],raw);
assert.equal(encoded.a[0],encoded.a[1]);
host.left={$:'Box',value:19};
assert.equal(abi.encode(host).a[0].a[0],19,'host input changes must be observed');
const hostCycle={$:'Box'};hostCycle.value=hostCycle;
const encodedCycle=abi.encode(hostCycle);
assert.equal(encodedCycle.a[0],encodedCycle);
const cyclic=abi.decode(encodedCycle);
assert.equal(cyclic.value,cyclic);
assert.throws(()=>JSON.stringify(cyclic),/circular/i);

const rawArray=[raw,raw];rawArray.push(rawArray);rawArray.length=5;
const array=abi.decode(rawArray);
assert.ok(Array.isArray(array));
assert.equal(array.length,5);
assert.equal(array[Symbol.unscopables],Array.prototype[Symbol.unscopables]);
assert.equal(Object.getPrototypeOf(array),Array.prototype);
assert.equal(array[0],view);
assert.equal(array[2],array);
assert.equal(3 in array,false);
assert.deepEqual(array.slice(0,2),[view,view]);
assert.equal([...array][2],array);
assert.equal(Object.getOwnPropertyDescriptor(array,'0').value,view);
assert.equal(abi.encode(array),rawArray);
assert.throws(()=>array.push(nil),/read-only/);
const sparse=[];sparse.length=3;sparse[1]=view;
const encodedSparse=abi.encode(sparse);
assert.equal(0 in encodedSparse,false);
assert.equal(encodedSparse[1],raw);
assert.equal(2 in encodedSparse,false);

const phases=[];
const wrappedAbi=createCompilerAbi({fields,ctor,onPhase:event=>phases.push(event.phase)});
const wrapped=wrappedAbi.wrap({identity:x=>x,head:x=>x.a[0],fail:()=>{throw Error('original failure');}});
const wrappedView=wrappedAbi.decode(raw);
assert.equal(wrapped.identity(wrappedView),wrappedView);
assert.equal(wrapped.head(wrappedView),wrappedView.left);
assert.deepEqual(phases.slice(0,4),['encode','invoke','decode','return']);
assert.throws(()=>wrapped.fail(),/original failure/);

// Large/deep pass-through reproduces the failing phase boundary without a
// compiler restart. The child getter also proves it cannot inspect the graph.
const lazyRaw=ctor('Box',[]);
Object.defineProperty(lazyRaw.a,0,{get(){throw Error('eager traversal');}});
assert.equal(abi.encode(abi.decode(lazyRaw)),lazyRaw);
let deep=nil;
for(let i=0;i<100000;i++)deep=ctor('Con',[i,deep]);
const before=abi.stats();
const deepView=abi.decode(deep);
assert.equal(abi.encode(deepView),deep);
const after=abi.stats();
assert.equal(after.views-before.views,1);
assert.equal(after.encoded-before.encoded,0);
assert.equal(deepView.head,99999);
assert.equal(deepView.tail.head,99998);

assert.throws(()=>abi.decode(ctor('Unknown',[])),/Unknown compiler ABI constructor/);
console.log(JSON.stringify({ok:true,cases:['lazy fields','sharing','pass-through','named JSON','read-only views','mutable host inputs','cycles','arrays','sparse arrays','wrapper phases','exceptions','100000-node handoff'],stats:abi.stats()}));

// Optional integration gate uses an existing self-emitted compiler, with no
// upstream compiler invocation or rebuild. Compare every phase to the former
// eager conversion as well as checking actual successful compilation.
if(process.env.BEND_COMPILER_ABI_MODULE) {
  const {pathToFileURL}=await import('node:url');
  const path=await import('node:path');
  const fs=await import('node:fs');
  const crypto=await import('node:crypto');
  const {convertCompilerAbi}=await import('./typed-driver.mjs');
  const module=await import(pathToFileURL(path.resolve(process.env.BEND_COMPILER_ABI_MODULE)));
  assert.ok(module.G,'integration test requires a self-emitted compiler');
  const compilerFields={Nil:[],Con:['head','tail'],FSource:['name','path','text'],FResult:['book','error','imports'],
    KTerm:['tag','name','id','quant','kids','removed'],KDef:['name','kind','arity','templates','typ','value','ctors','native','unsafe'],
    KSpecialized:['book','error']};
  const adapter=createCompilerAbi({fields:compilerFields,ctor:module.ctor});
  const api=adapter.wrap(module.default);
  const copy=(value,encode)=>convertCompilerAbi(value,encode,compilerFields,module.ctor);
  const eager=Object.fromEntries(Object.entries(module.default).map(([name,method])=>[name,(...args)=>copy(method(...copy(args,true)),false)]));
  const source='type Signal is Data:\n  Off{}\n  On{}\ndef identity(x: Signal) -> Signal:\n  x\ndef main() -> Signal:\n  identity(On{})\n';
  const stages=[];
  const compare=(name,args,otherArgs=args)=>{
    const result=api[name](...args),expected=eager[name](...otherArgs);
    assert.equal(JSON.stringify(result),JSON.stringify(expected),name+' differs from eager ABI');
    stages.push(name);return [result,expected];
  };
  const [parsed]=compare('f_parse',[source]);assert.equal(parsed.error,'');
  const inputs={$:'Con',head:{$:'FSource',name:'__main__',path:'/compiler-abi-test.bend',text:source},tail:{$:'Nil'}};
  const [loaded,loadedEager]=compare('f_load_graph',['__main__',inputs]);assert.equal(loaded.error,'');
  const [error]=compare('check_book',[loaded.book],[loadedEager.book]);assert.equal(error,'');
  const [specialized,specializedEager]=compare('specialize_book',[loaded.book],[loadedEager.book]);assert.equal(specialized.error,'');
  const book=specialized.book,bookEager=specializedEager.book;
  const [roots,rootsEager]=compare('j_roots',[book,true],[bookEager,true]);
  const [stops,stopsEager]=compare('j_stops',[book],[bookEager]);
  const [selected,selectedEager]=compare('reach_book',[book,roots,stops],[bookEager,rootsEager,stopsEager]);
  const beforeAnnotate=adapter.stats();
  const [annotated,annotatedEager]=compare('annotate_selected',[book,selected,stops],[bookEager,selectedEager,stopsEager]);
  const annotationEncodedObjects=adapter.stats().encoded-beforeAnnotate.encoded;
  assert.equal(annotationEncodedObjects,1,'annotation copies only its argument vector');
  const [layout]=compare('j_layout_error',[book,annotated,roots,stops],[bookEager,annotatedEager,rootsEager,stopsEager]);assert.equal(layout,'');
  const [emitted]=compare('j_library_selected',[book,annotated],[bookEager,annotatedEager]);assert.ok(emitted.includes('export default'));
  console.log(JSON.stringify({ok:true,integration:process.env.BEND_COMPILER_ABI_MODULE,
    compilerSha256:crypto.createHash('sha256').update(fs.readFileSync(path.resolve(process.env.BEND_COMPILER_ABI_MODULE))).digest('hex'),
    stages,annotationEncodedObjects,emittedSha256:crypto.createHash('sha256').update(emitted).digest('hex'),stats:adapter.stats()}));
}
