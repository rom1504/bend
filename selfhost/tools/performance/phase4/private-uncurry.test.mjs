import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {flattenKnownPartialCalls} from './private-uncurry.mjs';

const runtime = `const G=Object.create(null),trace=[];
const fn=(arity,code,bound=[])=>({arity,code,bound});
const get=(g,n)=>g[n];
function force(x){while(x?.bounce)x=apply(x.f,x.args);return x;}
const jump=(f,args)=>({bounce:true,f,args});
function apply(f,args){const all=[...f.bound,...args];if(all.length<f.arity)return fn(f.arity,f.code,all);const r=f.code(all.slice(0,f.arity));return all.length===f.arity?r:jump(force(r),all.slice(f.arity));}
const call=(f,args)=>force(apply(f,args));
const note=(name,value)=>{trace.push(name);return value;};
const fail=name=>{trace.push(name);throw Error(name);};
G["sum"]=fn(3,a=>{trace.push('body');return a.reduce((n,x)=>n+x,0);});
G["two"]=fn(2,a=>{trace.push('inner body');return fn(1,b=>a[0]+a[1]+b[0]);});
G["and"]=fn(2,a=>a[0]&&a[1]);
`;
const arities = new Map([['sum', 3], ['two', 2], ['and', 2]]);
function observe(source) {
  return JSON.parse(vm.runInNewContext(runtime + source + `
let value,error;try{value=call(G.entry,[]);}catch(e){error=e.message;}
JSON.stringify({value,error,trace});`));
}
function compare(expression, expected, chains) {
  const source = `G["entry"]=fn(0,function(a){return ${expression};});`;
  const transformed = flattenKnownPartialCalls(source, arities);
  assert.deepEqual(observe(transformed.source), observe(source));
  assert.deepEqual(observe(transformed.source), expected);
  assert.equal(transformed.stats.chains, chains);
}
test('saturated partial segments preserve argument and body order', () => {
  compare('call(call(call(get(G,"sum"),[note("a",1)]),[note("b",2)]),[note("c",3)])',
    {value: 6, trace: ['a', 'b', 'c', 'body']}, 1);
});
test('tail saturation retains the trampoline and argument order', () => {
  compare('jump(call(get(G,"sum"),[note("a",1)]),[note("b",2),note("c",3)])',
    {value: 6, trace: ['a', 'b', 'c', 'body']}, 1);
});
test('an earlier completed body still executes before overapplication arguments', () => {
  compare('call(call(call(get(G,"two"),[note("a",1)]),[note("b",2)]),[note("c",3)])',
    {value: 6, trace: ['a', 'b', 'inner body', 'c']}, 1);
});
test('Boolean arguments stay eager when the first one is false', () => {
  compare('call(call(get(G,"and"),[note("a",false)]),[fail("second argument")])',
    {error: 'second argument', trace: ['a', 'second argument']}, 1);
});
test('nested independent argument chains are both flattened', () => {
  compare('call(call(get(G,"sum"),[1]),[call(call(get(G,"sum"),[2]),[3,4]),5])',
    {value: 15, trace: ['body', 'body']}, 2);
});
test('incomplete, spread, empty and unknown chains remain unchanged', () => {
  for (const expression of [
    'call(call(get(G,"sum"),[1]),[2])',
    'call(call(get(G,"sum"),[1]),[...rest])',
    'call(call(get(G,"sum"),[]),[1,2,3])',
    'call(call(get(G,"unknown"),[1]),[2,3])',
    'receiver.call(call(get(G,"sum"),[1]),[2,3])',
  ]) {
    const source = `G["entry"]=fn(0,function(a){return ${expression};});`;
    assert.equal(flattenKnownPartialCalls(source, arities).source, source);
  }
});
test('quoted generated code and runtime definitions are not transformed', () => {
  const source = 'const untouched=call(call(get(G,"sum"),[1]),[2,3]);\nG["entry"]=fn(0,function(a){return "call(call(get(G,\\\"sum\\\"),[1]),[2,3])";});';
  assert.equal(flattenKnownPartialCalls(source, arities).source, source);
});
