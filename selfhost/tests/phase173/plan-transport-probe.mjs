// Tiny generic-data transport control; no compiler import or target execution.
// Run under the ordinary resource guard using the exact pinned Bun executable.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {serialize,deserialize} from 'bun:jsc';
import * as v8 from 'node:v8';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';
import {encodeGraph,decodeGraph} from '../../../experiments/phase154/tools/graph.mjs';

assert.equal(process.argv.length,4);assert.equal(process.argv[2],'--out');
const out=path.resolve(process.argv[3]);
assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});assert.equal(fs.realpathSync(out),out);
const report={kind:'phase173-plan-transport-probe',version:1,complete:false,
  compilerTargetsRun:false,engine:pin(process.execPath),
  inputs:[pin(fileURLToPath(import.meta.url)),pin(path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../tools/build/hosted.mjs')),
    pin(path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../../experiments/phase154/tools/graph.mjs'))],results:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  assert.equal(typeof Bun?.version,'string');report.bunVersion=Bun.version;
  const leaf={$:'KTerm',name:'Module/name_λ',number:4294967295,removed:false,
    text:'nul\u0000 astral\ud83d\ude42 lone\ud800',origin:null,negativeZero:-0};
  const rows=Array.from({length:4096},(_,i)=>({$:i%2?'Pair':'Node',id:i,left:leaf,right:leaf}));
  let chain={$:'Nil'};for(let i=0;i<16384;i++)chain={$:'Con',head:rows[i%rows.length],tail:chain};
  const value={$:'P86PlanReady',request:{$:'NR_Request',book:rows,first:rows[0],leaf,chain},verdict:'checked'};
  value.self=value;value.request.alias=value.request;
  // Compare valid deep graphs iteratively; recursive assert.deepEqual would
  // test the assertion library's stack, rather than the transport's behavior.
  const check=copy=>{
    const forward=new Map(),reverse=new Map(),todo=[[value,copy]];let objects=0;
    while(todo.length){
      const [left,right]=todo.pop();
      if(left===null||typeof left!=='object'){assert(Object.is(left,right));continue;}
      assert(right!==null&&typeof right==='object');assert.notEqual(left,right);
      if(forward.has(left)){assert.equal(forward.get(left),right);continue;}
      assert(!reverse.has(right));forward.set(left,right);reverse.set(right,left);
      assert(++objects<=65536);assert.equal(Array.isArray(left),Array.isArray(right));
      const keys=Object.keys(left);assert.deepEqual(keys,Object.keys(right));
      for(const key of keys)todo.push([left[key],right[key]]);
    }
    assert.equal(copy.self,copy);assert.equal(copy.request.alias,copy.request);
    assert.equal(copy.request.first,copy.request.book[0]);
    assert.equal(copy.request.leaf,copy.request.book[4095].left);
    assert.equal(copy.request.book[0].left,copy.request.book[0].right);
    return objects;
  };
  for(const codec of [
    {name:'bun:jsc',encode:x=>serialize(x,{binaryType:'nodebuffer'}),decode:deserialize},
    {name:'node:v8-on-bun',encode:v8.serialize,decode:v8.deserialize},
  ]){
    const t=performance.now(),bytes=codec.encode(value),encoded=performance.now();
    assert(Buffer.isBuffer(bytes));assert(bytes.length<16*1024**2);
    const file=path.join(out,codec.name==='bun:jsc'?'probe.jsc':'probe.v8');
    fs.writeFileSync(file,bytes,{flag:'wx'});const artifact=pin(file);verify(artifact);
    const loaded=fs.readFileSync(file),copy=codec.decode(loaded),decoded=performance.now();const objects=check(copy);
    copy.request.leaf.name='mutated replay';check(codec.decode(fs.readFileSync(file)));verify(artifact);
    report.results.push({codec:codec.name,objects,linkedListDepth:16384,artifact,encodeSeconds:(encoded-t)/1000,
      writeDecodeSeconds:(decoded-encoded)/1000,exactValues:true,sharing:true,cycle:true,freshDecode:true});
  }
  // JSON reference has no negative-zero promise; use a separate finite control.
  leaf.negativeZero=0;
  const t=performance.now(),graph=encodeGraph(value,{nodeLimit:65536}),json=JSON.stringify(graph);
  assert(json.length<16*1024**2);const copy=decodeGraph(JSON.parse(json));
  check(copy);
  report.jsonReference={nodes:graph.nodes.length,bytes:Buffer.byteLength(json),
    bytesPerNode:Buffer.byteLength(json)/graph.nodes.length,seconds:(performance.now()-t)/1000};
  report.inputs.forEach(verify);verify(report.engine);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify(report));}
