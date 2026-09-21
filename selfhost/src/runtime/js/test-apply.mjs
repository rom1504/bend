// Argument ownership and trampoline ordering across the public function ABI.
import fs from 'node:fs';import path from 'node:path';import os from 'node:os';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
const runtime=fs.readFileSync(process.env.BEND_JS_RUNTIME?path.resolve(process.env.BEND_JS_RUNTIME):new URL('../../runtime.mjs',import.meta.url),'utf8');
const checks=String.raw`
import assert from 'node:assert/strict';
const supplied=[1];const mutated=call(fn(1,a=>{a[0]=7;a.push(8);return a}),supplied);
assert.deepEqual(mutated,[7,8]);assert.deepEqual(supplied,[1]);
assert.equal(call(fn(0,a=>{a.push(8);return 7}),[]),7);
const prefix=[1],suffix=[2];const partial=call(fn(2,a=>{a[0]=7;return a}),prefix);
prefix[0]=99;assert.deepEqual(call(partial,suffix),[7,2]);assert.deepEqual(partial.bound,[1]);assert.deepEqual(suffix,[2]);
assert.equal(call(fn(1,a=>{a.push(99);return fn(1,b=>b[0])}),[1,2]),2);
const over=[1,2];assert.equal(call(fn(1,a=>{over[1]=99;return fn(1,b=>b[0])}),over),2);
const trace=[];assert.deepEqual(force(build('Tuple',[
 ()=>{trace.push('left');return jump(fn(0,()=>{trace.push('left result');return 1}),[])},
 ()=>{trace.push('right');return 2}
])),[1,2]);assert.deepEqual(trace,['left','left result','right']);
const value=pure(3);assert.equal(call(value,[]),value);
assert.equal(call(value,[null,fn(1,a=>pure(a[0]+1))]).pureValue,4);
assert.throws(()=>call(fn(1,a=>{throw Error('first')}),[1,2]),/first/);
console.log('argument isolation, partial ownership, oversaturation, constructor ordering, IO application passed');
`;
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-apply-'));try{const file=path.join(dir,'test.mjs');fs.writeFileSync(file,runtime+'\n'+checks);const r=spawnSync(process.execPath,[file],{stdio:'inherit',timeout:10000});assert.equal(r.error,undefined);assert.equal(r.status,0);}finally{fs.rmSync(dir,{recursive:true,force:true});}
