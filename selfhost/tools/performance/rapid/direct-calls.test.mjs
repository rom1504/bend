import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {transformDirectCalls} from './direct-calls.mjs';

const runtimeText=fs.readFileSync(new URL('../../../dist/phase1/runtime.mjs',import.meta.url),'utf8');
const runtime=runtimeText.slice(runtimeText.indexOf('const G='),runtimeText.indexOf('function ctor('));
const definitions=`
const events=[];
G["add"]=fn(2,function(a){return a[0]+a[1]});
G["target"]=fn(1,function(a){return a[0]+1});
G["entry"]=fn(1,function(a){return call(get(G,"target"),[(events.push("arg"),a[0])]);});
G["nested"]=fn(1,function(a){return call(get(G,"add"),[call(get(G,"target"),[a[0]]),2,]);});
G["partial"]=fn(1,function(a){return call(get(G,"add"),[a[0]]);});
G["over"]=fn(1,function(a){return call(get(G,"target"),[a[0],4]);});
G["owned"]=fn(1,function(a){a.push(99);return a.length;});
G["owns"]=fn(1,function(a){return call(get(G,"owned"),[a[0]]);});
G["tail"]=fn(1,function(a){return a[0]===0?0:jump(get(G,"tail"),[a[0]-1]);});
G["capture"]=fn(1,function(a){return call(get(G,"target"),[(G["target"]=fn(1,b=>100+b[0]),a[0])]);});
G["mutateArity"]=fn(1,function(a){return call(get(G,"target"),[(G["target"].arity=2,a[0])]);});
G["literal"]=fn(1,function(a){return 'call(get(G,"target"),[1])';});
`;
const arities={add:2,target:1,owned:1,tail:1};
function load(tail,original=false,owned=false){
  const source=runtime+definitions;
  const transformed=transformDirectCalls(source,{arities,tail,owned});
  return {...vm.runInNewContext((original?source:transformed.source)+'\n({G,fn,call,get,events})'),stats:transformed.stats};
}
for(const owned of [false,true])for(const tail of [false,true]){
  test(`exact calls and nested calls, tail=${tail}, owned=${owned}`,()=>{
    const x=load(tail,false,owned);assert.equal(x.call(x.G.nested,[5]),8);
    assert.equal(x.stats.calls,owned?8:6);assert.equal(x.stats.tailCalls,tail?1:0);
    assert.equal(x.call(x.G.literal,[0]),'call(get(G,"target"),[1])');
  });
  test(`partial and overapplication stay generic, tail=${tail}, owned=${owned}`,()=>{
    const x=load(tail,false,owned);assert.equal(x.call(x.call(x.G.partial,[3]),[4]),7);
    x.G.target=x.fn(1,a=>x.fn(1,b=>a[0]*b[0]));assert.equal(x.call(x.G.over,[3]),12);
  });
  test(`live global rebinding and fn0 initializer order, tail=${tail}, owned=${owned}`,()=>{
    const x=load(tail,false,owned);x.G.target=x.fn(1,a=>20+a[0]);assert.equal(x.call(x.G.entry,[3]),23);
    x.events.length=0;x.G.target=x.fn(0,()=>{x.events.push('init');return x.fn(1,a=>a[0]*2)});
    assert.equal(x.call(x.G.entry,[3]),6);assert.equal(JSON.stringify(x.events),'["init","arg"]');
    x.G.target=x.fn(0,()=>{throw Error('initializer failure')});x.events.length=0;
    assert.throws(()=>x.call(x.G.entry,[3]),/initializer failure/);assert.equal(x.events.length,0);
  });
  test(`callee captured before argument mutation and arity rechecked, tail=${tail}, owned=${owned}`,()=>{
    const x=load(tail,false,owned);assert.equal(x.call(x.G.capture,[7]),8);assert.equal(x.call(x.G.target,[7]),107);
    x.G.target=x.fn(1,a=>a[0]+a[1]);const partial=x.call(x.G.mutateArity,[2]);
    assert.equal(x.call(partial,[3]),5);
  });
  test(`fresh argument ownership and deep tail calls, tail=${tail}, owned=${owned}`,()=>{
    const x=load(tail,false,owned);const original=load(tail,true,owned);const args=[7];
    assert.equal(x.call(x.G.owns,args),original.call(original.G.owns,args));
    assert.equal(x.call(x.G.owns,args),2);assert.deepEqual(args,[7]);assert.equal(x.call(x.G.tail,[50000]),0);
  });
  test(`bound functions and environments preserve ABI, tail=${tail}, owned=${owned}`,()=>{
    const x=load(tail,false,owned);x.G.target=x.fn(2,function(a){return this.offset+a[0]+a[1]}, {offset:10},[5]);
    assert.equal(x.call(x.G.entry,[3]),18);
    x.G.target=x.fn(1,function(a){return this.offset+a[0]}, {offset:10});assert.equal(x.call(x.G.entry,[3]),13);
  });
}
