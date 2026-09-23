import test from 'node:test';import assert from 'node:assert/strict';
import {exactRows} from './equality-frontend.mjs';
const row={id:'negative',lane:'check',status:'fail',reason:'Expected checker error',evidence:'none',result:{status:'error',phase:'parse',checked:false,diagnostic:'exact text'}};
test('known failures remain exact failures rather than normalized passing rejections',()=>{
 assert.deepEqual(exactRows([row],[structuredClone(row)]),[]);
 for(const change of [{status:'pass'},{reason:'another rule'},{result:{...row.result,phase:'check',checked:true}},{result:{...row.result,diagnostic:'different text'}}])assert.equal(exactRows([row],[{...row,...change}]).length,1);
});
test('observation identity and full coverage are mandatory',()=>{
 assert.throws(()=>exactRows([row],[]));assert.throws(()=>exactRows([row,row],[row,row]));
 assert.equal(exactRows([row],[{...row,id:'another fixture'}]).length,1);
});
