// Checked-source regression for the shared emission layout gate.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {loadApi,inspect,apiPath} from '../../../tools/typed-driver.mjs';
const api=await loadApi();
const backendPath=process.env.BEND_JS_BACKEND||process.env.BEND_JS_BACKEND_API;
if(backendPath)Object.assign(api,(await import(pathToFileURL(path.resolve(backendPath)))).default);
const dir=path.resolve(import.meta.dirname,'../../../build/js-layout');fs.mkdirSync(dir,{recursive:true});
const wrap='def wrap(-T: Type, x: T) -> Array<T>:\n  ALeaf{x}\n\n';
const fixtures={
 identity:['def keep(-T: Type, a: Array<T>) -> Array<T>:\n  a\n\ndef main() -> Array<U32>:\n  keep(U32, ALeaf{3})\n',false],
 dead:[wrap+'def main() -> U32:\n  7\n',false],
 erased:[wrap+'def sink(-x: Array<U32>) -> U32:\n  7\n\ndef main() -> U32:\n  sink(wrap(U32, 3))\n',false],
 'erased-costly':['def burn(n: Nat) -> U32:\n  match n:\n    case 0n:\n      0\n    case 1n+p:\n      burn(p)\n\ndef ignore(-x: U32) -> U32:\n  7\n\ndef main() -> U32:\n  ignore(burn(U32.to_nat(1000000000)))\n',false],
 constructor:[wrap+'def main() -> Array<U32>:\n  wrap(U32, 3)\n',true],
 primitive:['def size(-T: Type, a: Array<T>) -> Array<T> & U32:\n  Array.size(T, a)\n\ndef main() -> Array<U32> & U32:\n  size(U32, ALeaf{3})\n',true],
 clone:['def dup(-T: Data, a: Array<T>) -> Array<T> & Array<T>:\n  Array.clone(T, a)\n\ndef main() -> Array<U32> & Array<U32>:\n  dup(U32, ALeaf{3})\n',false],
 match:['def count(-T: Type, a: Array<T>) -> U32:\n  match a:\n    case ALeaf{x}:\n      d = x\n      1\n    case ANode{xs, ys}:\n      U32.add(count(T, xs), count(T, ys))\n\ndef main() -> IO(Unit):\n  IO.print(U32.show(count(U32, ANode{ALeaf{3}, ALeaf{4}})))\n',true]
};
const cases=Object.entries(fixtures).map(([name,[source,error]])=>{const file=path.join(dir,name+'.bend');fs.writeFileSync(file,'import Base\n\n'+source);return {name,file,error}});
if(process.env.BEND_UPSTREAM)cases.push({name:'pinned-match',file:path.join(process.env.BEND_UPSTREAM,'tests/reg/array_open_element.bend'),error:true});
const rows=[];
for(const row of cases){const checked=await inspect(row.file,{mode:'check',api});assert.equal(checked.status,'ok',JSON.stringify(checked));const emitted=await inspect(row.file,{mode:'compile',api});delete emitted.code;assert.equal(emitted.status,row.error?'error':'ok',row.name+JSON.stringify(emitted));if(row.error)assert.equal(emitted.diagnostic,'Error: an open Array element type');rows.push({...row,checked:checked.status,emitted});console.log(row.name,'PASS')}
fs.writeFileSync(path.join(dir,'report.json'),JSON.stringify({apiPath,apiSha256:crypto.createHash('sha256').update(fs.readFileSync(apiPath)).digest('hex'),backendPath,backendSha256:backendPath?crypto.createHash('sha256').update(fs.readFileSync(backendPath)).digest('hex'):null,rows},null,2)+'\n');
