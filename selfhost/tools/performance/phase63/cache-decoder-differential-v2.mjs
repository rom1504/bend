#!/usr/bin/env node
// Semantic/shape differential for host codec variants; no compiler image runs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [oldFile,newFile,frameFile,outputFile]=process.argv.slice(2).map(x=>path.resolve(x));
if(!outputFile)throw Error('Usage: cache-decoder-differential.mjs OLD_HELPER NEW_HELPER FRAME3 OUTPUT.json');
const old=await import(pathToFileURL(oldFile)),candidate=await import(pathToFileURL(newFile));
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
function exact(a,b){
  const seen=new WeakMap(),pending=[[a,b]];
  while(pending.length){
    const [x,y]=pending.pop();
    if(x===null||typeof x!=='object'){assert.ok(Object.is(x,y));continue;}
    assert.ok(y!==null&&typeof y==='object');
    if(seen.has(x)){assert.equal(seen.get(x),y);continue;}seen.set(x,y);
    assert.deepEqual(Object.keys(x),Object.keys(y));
    for(const key of Object.keys(x))pending.push([x[key],y[key]]);
  }
}
const rows=[[0],[2,'Ref','Base.X',0,0,0,0,1,1],[3,'x',1,0,0,0,1,1,true],[4,'U32',0,'',1,1],
  [5,'A','Def',0,0,1,2,0,true,false],[1,4,0],[1,1,0],[1,'x',0],[6,0,5],[7,0,1,8,4],
  [8,1,2,1,5,true],[9,2,true],[10,10,5,5,5,5,5],[11,8,9,1,true]];
const kinds=['defs','term','term','term','def','defs','terms','strings','def','def','checked','fresh','world','frontend'];
const wire=[1,0,rows.map((_,i)=>i),rows],options={range:{begin:1,end:100},termAbi:1,rootKinds:kinds};
let controls=0,accepted=0,rejected=0;
function compare(w=wire,o=options){
  const bytes=Buffer.from(JSON.stringify(w));
  const run=fn=>{try{return {ok:true,roots:fn(bytes,o).roots};}catch(error){return {ok:false,error:{name:error.name,message:error.message}};}};
  const a=run(old.decodeBaseGraph),b=run(candidate.decodeBaseGraph);controls++;
  assert.equal(a.ok,b.ok,JSON.stringify({wire:w,options:o}));
  if(a.ok){exact(a.roots,b.roots);accepted++;}else {assert.deepEqual(a.error,b.error);rejected++;}
}
compare();
const values=[null,false,true,-1,-0,0,1,1.5,4294967295,4294967296,'','x',[],{},{valueOf:0,toString:0},{valueOf:null,toString:null},'\ud800'];
for(let i=0;i<rows.length;i++)for(let j=0;j<rows[i].length;j++)for(const value of [...values,i,i+1]){
  const w=structuredClone(wire);w[3][i][j]=value;compare(w);
}
for(const abi of [0,1,2,null])compare(wire,{...options,termAbi:abi});
for(const rootKind of ['empty','term','def','terms','defs','strings','checked','fresh','world','frontend','list','unknown'])for(const root of [0,1,4,5,6,7,10,11,12,13,null])compare([1,0,[root],rows],{...options,rootKinds:[rootKind]});
for(const root of [null,-1,0,0.5,100,'x',false,{}]){const w=structuredClone(wire);w[2][0]=root;compare(w);}
for(const change of [w=>w[0]=2,w=>w[1]=1,w=>w[2].pop(),w=>w.push(null),w=>w[3].push([99])]){const w=structuredClone(wire);change(w);compare(w);}
const bytes=fs.readFileSync(frameFile),cut=bytes.indexOf(10),header=JSON.parse(bytes.subarray(0,cut));
assert.equal(header.format,'bend-base-cache-frame-3');
const bookBytes=bytes.subarray(cut+1,cut+1+header.segments[0]),stateBytes=bytes.subarray(cut+1+header.segments[0]);
assert.equal(sha(bookBytes),header.bookGraphSha256);assert.equal(sha(stateBytes),header.preparedGraphSha256);
const common={range:{begin:header.sourceBegin,end:header.sourceEnd},termAbi:header.termAbi??0};
const a=old.decodeBaseGraph(bookBytes,{...common,rootKinds:['defs']}),b=candidate.decodeBaseGraph(bookBytes,{...common,rootKinds:['defs']});
exact(a.roots,b.roots);
const roots=['checked','fresh','world','frontend'];
const as=old.decodeBaseGraph(stateBytes,{...common,base:a,rootKinds:roots}),bs=candidate.decodeBaseGraph(stateBytes,{...common,base:b,rootKinds:roots});
exact([a.roots,...as.roots],[b.roots,...bs.roots]);
assert.equal(a.nodes.length,b.nodes.length);assert.equal(as.nodes.length,bs.nodes.length);
const report={schema:'phase63-cache-decoder-differential-2',pass:true,controls,accepted,rejected,realFrameExact:true,bookNodes:a.nodes.length,totalNodes:as.nodes.length,
  old:{file:oldFile,sha256:sha(fs.readFileSync(oldFile))},candidate:{file:newFile,sha256:sha(fs.readFileSync(newFile))},frame:{file:frameFile,sha256:sha(bytes)},
  limits:['Field-domain differential and exact graph/sharing values; not compiler semantic equivalence.','Same helper decodes book and optional segments; internal kind arrays are private and may differ.']};
fs.mkdirSync(path.dirname(outputFile),{recursive:true});fs.writeFileSync(outputFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:true,controls,accepted,rejected,bookNodes:a.nodes.length,totalNodes:as.nodes.length}));
