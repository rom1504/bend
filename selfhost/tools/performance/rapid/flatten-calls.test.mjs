import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import {transformFlattenCalls} from './flatten-calls.mjs';
const runtimeText=fs.readFileSync(new URL('../../../dist/phase1/runtime.mjs',import.meta.url),'utf8');
const runtime=runtimeText.slice(runtimeText.indexOf('const G='),runtimeText.indexOf('function ctor('));
const definitions=`
const events=[];
G["add"]=fn(2,a=>{events.push("add");return a[0]+a[1]});
G["entry"]=fn(1,a=>call(call(get(G,"add"),[(events.push("left"),2)]),[(events.push("right"),3)]));
G["nested"]=fn(1,a=>call(call(get(G,"add"),[call(call(get(G,"add"),[1]),[2])]),[4]));
G["factory"]=fn(1,a=>{events.push("factory");return fn(1,b=>a[0]+b[0])});
G["boundary"]=fn(1,a=>call(call(get(G,"factory"),[2]),[(events.push("after factory"),3)]));
G["over"]=fn(1,a=>call(call(get(G,"add"),[1,2]),[3]));
G["triple"]=fn(3,a=>a[0]+a[1]+a[2]);
G["three"]=fn(1,a=>jump(call(call(get(G,"triple"),[1]),[2]),[3]));
G["literal"]=fn(1,a=>'call(call(get(G,"add"),[1]),[2])');
`;
const arities={add:2,factory:1,triple:3};
assert.throws(()=>transformFlattenCalls(runtime+definitions,{arities}),/explicit/);
const r=transformFlattenCalls(runtime+definitions,{arities,assumeImmutableGlobals:true});
assert.equal(r.stats.sites,4);assert.equal(r.stats.partialStagesRemoved,5);
const exports='\n({G,call,events})';const original=vm.runInNewContext(runtime+definitions+exports),candidate=vm.runInNewContext(r.source+exports);
for(const name of ['entry','nested','boundary','three','literal']){
 original.events.length=0;candidate.events.length=0;
 assert.equal(candidate.call(candidate.G[name],[0]),original.call(original.G[name],[0]));
 assert.equal(JSON.stringify(candidate.events),JSON.stringify(original.events));
}
assert.throws(()=>candidate.call(candidate.G.over,[0]),/non-function/);
assert.match(r.source,/call\(call\(get\(G,"factory"\)/);
console.log('immutable-global flattening: saturation boundaries, effects, nested calls, tail results, quoted text, and explicit assumption passed');
