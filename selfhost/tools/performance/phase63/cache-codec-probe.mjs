#!/usr/bin/env node
// Standalone transport experiment; does not load or execute a compiler image.
import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';
import assert from 'node:assert/strict';
import {performance} from 'node:perf_hooks';
import {encodeBaseGraph,decodeBaseGraph} from '../../base-cache-graph.mjs';
import {decodeBaseCacheFrame} from '../../typed-driver.mjs';

const [input,output]=process.argv.slice(2);
if(!input||!output)throw Error('Usage: cache-codec-probe.mjs FRAME2 OUTPUT.json');
const bytes=fs.readFileSync(input),header=JSON.parse(bytes.subarray(0,bytes.indexOf(10)).toString());
assert.equal(header.format,'bend-base-cache-frame-2');
const source=decodeBaseCacheFrame(bytes),range={begin:source.sourceBegin,end:source.sourceEnd};
const identity=file=>({file,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const options={range,termAbi:source.termAbi??0};
const begin=performance.now(),book=encodeBaseGraph([source.book]);
const state=encodeBaseGraph([source.checkedPrefixState??null,source.freshPrefixState??null,null,null],book);
const encodeMs=performance.now()-begin;
const decode=()=>{
  const b=decodeBaseGraph(book.bytes,{...options,rootKinds:['defs']});
  const s=decodeBaseGraph(state.bytes,{...options,base:b,rootKinds:['checked','fresh','world','frontend']});
  return {book:b.roots[0],checkedPrefixState:s.roots[0],freshPrefixState:s.roots[1]};
};
const decoded=decode();
for(const key of ['book','checkedPrefixState','freshPrefixState'])assert.equal(JSON.stringify(decoded[key]),JSON.stringify(source[key]),key);

// The frame2 comparison includes its private JSON-tree span/literal validator,
// without public validateSpanCache's extra JSON.stringify/digest operation.
function validateTree(root) {
  const pending=[root];
  while(pending.length){
    const v=pending.pop();if(v===null||typeof v!=='object')continue;
    if(v.$==='KLiteral'){
      if(options.termAbi!==1||!['Nat','U32','F32','String'].includes(v.kind)||!Number.isSafeInteger(v.number)||v.number<0||v.number>0xffffffff||typeof v.text!=='string'||(v.kind==='String'?(v.number!==0||Array.from(v.text).some(c=>{const n=c.codePointAt(0);return n>=0xd800&&n<=0xdfff;})):v.text!==''))throw Error('Invalid literal');
    }
    if(v.$==='KLambda'&&(options.termAbi!==1||typeof v.quantityPresent!=='boolean'))throw Error('Invalid lambda');
    if(['KTerm','KLiteral','KLambda'].includes(v.$)){
      const a=v.originBegin,b=v.originEnd;
      if(!Number.isSafeInteger(a)||!Number.isSafeInteger(b)||a<0||b<0||a>0xffffffff||b>0xffffffff||!((a===0&&b===0)||(a>=range.begin&&b>=a&&b<range.end)))throw Error('Invalid range');
    }
    if(Array.isArray(v)){for(let i=0;i<v.length;i++){const x=v[i];if(x!==null&&typeof x==='object')pending.push(x);}}
    else for(const key in v)if(Object.hasOwn(v,key)){const x=v[key];if(x!==null&&typeof x==='object')pending.push(x);}
  }
}
const baseline=()=>{const value=decodeBaseCacheFrame(bytes);validateTree(value.book);if(value.checkedPrefixState)validateTree(value.checkedPrefixState.patches);return value;};
const controls=[];
function reject(name,wire,config={...options,rootKinds:['defs']}) {
  assert.throws(()=>decodeBaseGraph(Buffer.from(JSON.stringify(wire)),config),undefined,name);controls.push(name);
}
reject('forward reference',[1,0,[0],[[1,1,1],[0]]]);
reject('self reference',[1,0,[0],[[1,0,0]]]);
reject('invalid root',[1,0,[1],[[0]]]);
reject('base count mismatch',[1,1,[0],[[0]]]);
reject('wrong constructor length',[1,0,[0],[[0,123]]]);
reject('unknown constructor',[1,0,[0],[[99]]]);
reject('mixed list type',[1,0,[1],[[0],[1,'name',0]]]);
reject('negative U32',[1,0,[1],[[0],[4,'U32',-1,'',0,0]]],{...options,rootKinds:['term']});
reject('out of source interval',[1,0,[0],[[4,'U32',1,'',range.end,range.end]]],{...options,rootKinds:['term']});
reject('unpaired surrogate',[1,0,[0],[[4,'String',0,'\ud800',0,0]]],{...options,rootKinds:['term']});
const nil={$:'Nil'};assert.equal(decodeBaseGraph(encodeBaseGraph([nil,nil]).bytes,{...options,rootKinds:['defs','terms']}).nodes.length,1);controls.push('shared nil roots');
const rows=[];
for(let round=0;round<5;round++)for(const variant of round%2?['graph','frame2']:['frame2','graph']){
  const start=performance.now();const value=variant==='graph'?decode():baseline();
  rows.push({round,variant,ms:performance.now()-start});assert.equal(value.book.$,'Con');
}
const median=values=>values.sort((a,b)=>a-b)[Math.floor(values.length/2)];
const frame2Ms=median(rows.filter(x=>x.variant==='frame2').map(x=>x.ms)),graphMs=median(rows.filter(x=>x.variant==='graph').map(x=>x.ms));
const report={schema:'phase63-cache-codec-probe-1',input:identity(input),helper:identity(new URL('../../base-cache-graph.mjs',import.meta.url)),
  controls,exactValues:true,bytes:{frame2:bytes.length,graph:book.bytes.length+state.bytes.length},nodes:{book:book.records.length,prepared:state.records.length-book.records.length},encodeMs,rows,median:{frame2Ms,graphMs,graphOverFrame2:graphMs/frame2Ms},
  limits:['Transport only; no compiler image or end-to-end speed claim.','Frame2 baseline includes parse/digests plus source-span/literal validation; graph sample excludes outer frame hashing/header dispatch.','Five alternating same-process rounds retain first-run effects; this is not a clean fresh-process benchmark.','Existing cache supplies no new KBasePreparedWorld/frontend state; integration requires separate admission and output controls.']};
fs.mkdirSync(path.dirname(output),{recursive:true});
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:true,controls:controls.length,...report.bytes,...report.median}));
