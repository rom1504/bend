import test from 'node:test';
import assert from 'node:assert/strict';
import {convertCompilerAbi} from '../../tools/typed-driver.mjs';
test('compiler ABI conversion handles deeply nested shared graphs without recursion',()=>{
  const fields={Con:['head','tail'],Nil:[],Pair:['left','right']};
  const ctor=($,a)=>({$,a});
  let value={$:'Nil'};
  for(let i=0;i<50000;i++)value={$:'Con',head:i,tail:value};
  const graph={$:'Pair',left:value,right:value};
  const encoded=convertCompilerAbi(graph,true,fields,ctor);
  assert.equal(encoded.a[0],encoded.a[1]);
  const decoded=convertCompilerAbi(encoded,false,fields,ctor);
  assert.equal(decoded.left,decoded.right);
  let count=0;
  for(let node=decoded.left;node.$==='Con';node=node.tail)count++;
  assert.equal(count,50000);
});
