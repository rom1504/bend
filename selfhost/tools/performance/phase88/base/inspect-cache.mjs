// Offline transport inspection only. Never imports or executes a compiler image.
// Output is not an admission certificate. Bind the complete file externally.
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {decodeBaseArena} from '../../../base-cache-graph.mjs';

const file=process.argv[2],expected=process.argv[3];
assert(file&&/^[0-9a-f]{64}$/.test(expected??''),'usage: inspect-cache.mjs FILE EXPECTED_SHA256');
assert(fs.statSync(file).size<=128*1024*1024,'cache exceeds transport bound');
const bytes=fs.readFileSync(file),sha=b=>createHash('sha256').update(b).digest('hex');
assert.equal(sha(bytes),expected);
const cut=bytes.indexOf(10);assert(cut>0&&cut<65536);
const h=JSON.parse(bytes.subarray(0,cut));
assert.equal(h.format,'bend-base-cache-frame-4');
assert.equal(h.segments.length,2);
const [nb,np]=h.segments;assert.equal(cut+1+nb+np,bytes.length);
const bookBytes=bytes.subarray(cut+1,cut+1+nb),preparedBytes=bytes.subarray(cut+1+nb);
assert.equal(sha(bookBytes),h.bookGraphSha256);assert.equal(sha(preparedBytes),h.preparedGraphSha256);
const opts={range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi};
const book=decodeBaseArena(bookBytes,{...opts,rootKinds:['defs']});
const state=decodeBaseArena(preparedBytes,{...opts,base:book,rootKinds:['checked','fresh','world','frontend']});
const roots=[book.roots[0],...state.roots],names=['book','checked','fresh','world','frontend'];
const ids=new Map(state.nodes.map((n,i)=>[n,i])),stats=[],tags={},cap=1e15;
for(const node of state.nodes){
  tags[node.$]=(tags[node.$]??0)+1;
  let expandedNodes=1,depth=1,literalBytes=Buffer.byteLength(node.$)+2;
  for(const [k,v] of Object.entries(node)){
    if(k==='$')continue;
    literalBytes+=1;
    if(v!==null&&typeof v==='object'){
      const id=ids.get(v);assert(id<stats.length,'not a backwards reference');
      const child=stats[id];expandedNodes=Math.min(cap,expandedNodes+child.expandedNodes);
      literalBytes=Math.min(cap,literalBytes+child.approxLiteralBytes);
      depth=Math.max(depth,1+child.depth);
    }else literalBytes+=typeof v==='boolean'?(v?6:7):Buffer.byteLength(JSON.stringify(v));
  }
  stats.push({expandedNodes,depth,approxLiteralBytes:literalBytes});
}
console.log(JSON.stringify({kind:'phase88-offline-base-shape',file,sha256:expected,bytes:bytes.length,
  metadata:h,uniqueNodes:state.nodes.length,tags,
  roots:roots.map((r,i)=>({name:names[i],id:ids.get(r),...stats[ids.get(r)]})),
  aliasChecks:{worldPrefixIsBook:roots[3].prefix===roots[0],worldStateIsChecked:roots[3].state===roots[1]},
  limitations:['No native decoding or compiler execution; no timing claim.',
    'Approximate literal bytes count scalar JSON spellings and tree expansion; excludes type annotations.',
    'Counts cap at 1e15. A checked literal may still exceed parser/checker stack or emitter budget.',
    'A matching digest and constructor shape are not proof that readiness was honestly produced.']},null,2));
