// Focused production prototype gate. Set BEND_JS_RUNTIME to the copied runtime.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const filename=process.env.BEND_JS_RUNTIME;
if(!filename)throw Error('BEND_JS_RUNTIME must select the owned-call prototype');
const runtime=fs.readFileSync(filename,'utf8');
const checks=String.raw`
import assert from 'node:assert/strict';
const publicArgs=[1];const publicResult=call(fn(1,a=>{a.push(2);return a}),publicArgs);
assert.deepEqual(publicArgs,[1]);assert.deepEqual(publicResult,[1,2]);
const ownedArgs=[1];assert.equal(callOwned(fn(1,a=>a),ownedArgs),ownedArgs);
const bound=[2],right=[3];const partial=callOwned(fn(2,a=>a),bound);
bound[0]=9;assert.deepEqual(callOwned(partial,right),[2,3]);assert.deepEqual(partial.bound,[2]);assert.deepEqual(right,[3]);
const over=[1,2];assert.equal(callOwned(fn(1,a=>{a.push(99);over[1]=77;return fn(1,b=>b[0])}),over),2);
const env={offset:7};assert.equal(callOwned(fn(1,function(a){return this.offset+a[0]},env),[3]),10);
const captured=[];G.target=fn(1,a=>{captured.push('old');return a[0]+1});
assert.equal(callOwned(get(G,'target'),[(G.target=fn(1,a=>a[0]+100),captured.push('arg'),4)]),5);
assert.deepEqual(captured,['arg','old']);
const order=[];G.lazy=fn(0,()=>{order.push('init');return fn(1,a=>a[0])});
assert.equal(callOwned(get(G,'lazy'),[(order.push('arg'),4)]),4);assert.deepEqual(order,['init','arg']);
G.lazy=fn(0,()=>{throw Error('early')});assert.throws(()=>callOwned(get(G,'lazy'),[(order.push('bad'),4)]),/early/);assert.equal(order.length,2);
let loop;loop=fn(1,a=>a[0]===0?42:jumpOwned(loop,[a[0]-1]));assert.equal(callOwned(loop,[50000]),42);
assert.equal(call(loop,[50000]),42);assert.equal(force(jump(fn(1,a=>a[0]+1),[4])),5);
assert.deepEqual(force(build('Tuple',[()=>jumpOwned(fn(1,a=>a[0]),[7]),()=>8])),[7,8]);
const ioValue=pure(3);assert.equal(callOwned(ioValue,[]),ioValue);
assert.equal(callOwned(ioValue,[null,fn(1,a=>pure(a[0]+1))]).pureValue,4);
assert.deepEqual(callOwned({typeName:'T'},[3]),{typeName:'T',typeArgs:[3]});assert.equal(callOwned(null,[1]),null);
assert.throws(()=>callOwned(7,[1]),/non-function/);assert.equal(callOwned(7,[]),7);
assert.throws(()=>callOwned(fn(1,()=>{throw Error('body')}),[1,2]),/body/);
console.log('owned-call prototype: public isolation, exclusive ownership, partial/overapplication, bound/env, live globals, initializer order, 50k tail calls, mixed old/new runtime, constructors, IO, type application and exceptions passed');
`;
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-owned-test-'));
try {const file=path.join(dir,'test.mjs');fs.writeFileSync(file,runtime+'\n'+checks);await import(pathToFileURL(file).href);}
finally {fs.rmSync(dir,{recursive:true,force:true});}
