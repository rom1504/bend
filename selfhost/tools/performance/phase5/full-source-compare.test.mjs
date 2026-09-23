// Pure protocol/configuration tests; no compiler is launched.
import test from 'node:test';
import assert from 'node:assert/strict';
import {settings,summarize,ORDER} from './full-source-compare.mjs';
const valid={attempt:'/frozen/checked',cpu:1,timeoutMs:900000,heapMb:12288,deadline:'2026-09-23T01:45:00.000Z'};
const rows=()=>ORDER.map((variant,index)=>({variant,index,passed:true,observation:{requestMs:variant==='derived'?60:100,maxRssKiB:1024},execution:{wallMs:variant==='derived'?65:110}}));
test('only one finite UTC campaign and bounded resources are accepted',()=>{
 assert.deepEqual(settings(valid),valid);
 for(const changes of [{deadline:'tomorrow'},{deadline:'2026-09-23T01:45:00+00:00'},{timeoutMs:900001},{timeoutMs:0},{heapMb:32768},{cpu:-1},{attempt:''},{repetitions:1}])assert.throws(()=>settings({...valid,...changes}));
});
test('full six-row ordering supplies both checked/derived pair directions',()=>{
 const s=summarize(rows());assert.equal(s.validComparison,true);assert.deepEqual(s.pairs.map(x=>[x.checkedIndex,x.derivedIndex]),[[1,2],[4,3]]);assert.equal(s.pairs[0].requestReductionPercent,40);assert.equal(s.variants.derived.samples,2);
});
test('partial observations and failed compilation never publish a complete ratio',()=>{
 for(let n=0;n<6;n++)assert.equal(summarize(rows().slice(0,n)).validComparison,false);
 const failed=rows();failed[5].passed=false;assert.equal(summarize(failed).validComparison,false);
});
test('duplicate or reordered rows cannot look like opposite-order completion',()=>{
 const duplicate=rows();duplicate[5]={...duplicate[0]};assert.equal(summarize(duplicate).validComparison,false);
 const reordered=rows();[reordered[1],reordered[4]]=[reordered[4],reordered[1]];assert.equal(summarize(reordered).validComparison,false);
});
test('missing, nonfinite and zero timing fields withhold summary',()=>{
 for(const value of [undefined,NaN,Infinity,0,-1]){const malformed=rows();malformed[0].observation.requestMs=value;assert.equal(summarize(malformed).validComparison,false);}
});
