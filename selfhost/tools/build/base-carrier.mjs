#!/usr/bin/env node
// Offline transport only: no compiler API import or semantic fact production.
// Extracted from commit 449b01ad25dcea16d20fb68c6a46937e4f542d91:
// selfhost/tools/performance/phase88/base/carrier.mjs (frame4 -> P88) and
// selfhost/tools/performance/phase130/base/carrier.mjs (P88 -> word pairs).
// Current codec/decoder and explicit preparation receipts replace historical paths.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {decodeBaseArena} from '../base-cache-graph.mjs';
import {options,preparation,pin,verify,requireThat,freshDirectory,save,digest} from './base-artifacts.mjs';

export function frameProducts({frame,api,base}){
  [frame,api,base].forEach(verify);
  requireThat(frame.bytes<=128*1024*1024&&base.bytes>0&&base.bytes<=16*1024*1024,'Frame/Base exceeds reader bounds');
  const bytes=fs.readFileSync(frame.file),cut=bytes.indexOf(10);
  requireThat(cut>0&&cut<65536,'Invalid frame header length');
  const h=JSON.parse(bytes.subarray(0,cut)),baseBytes=fs.readFileSync(base.file),text=baseBytes.toString('utf8');
  assert.deepEqual(Buffer.from(text),baseBytes,'Base must be valid UTF-8');
  assert.equal(h.format,'bend-base-cache-frame-4');assert.equal(h.version,6);
  assert.equal(h.termAbi,1);assert.equal(h.spanAbi,3);
  assert.equal(h.compilerSha256,api.sha256);assert.equal(h.baseSha256,base.sha256);
  assert.equal(h.sourcePath,base.file);assert.equal(h.validatedBy,'check_book');
  assert.equal(h.sourceBegin,1);assert.equal(h.sourceEnd,text.length+2);
  for(const [key,version,producer] of [
    ['checkedPrefixState',1,'base_prefix_prepare'],['freshPrefixState',1,'f_fresh_prefix_prepare'],
    ['preparedWorld',3,'base_prefix_world_prepare'],['frontendReadyState',1,'f_ready_prefix_prepare']]){
    assert.equal(h[key+'Version'],version);assert.equal(h[key+'Producer'],producer);
  }
  assert(Array.isArray(h.segments));
  assert.deepEqual(h.segments.map(n=>Number.isSafeInteger(n)&&n>=0),[true,true]);
  const [nb,np]=h.segments;assert.equal(cut+1+nb+np,bytes.length);
  const bb=bytes.subarray(cut+1,cut+1+nb),pb=bytes.subarray(cut+1+nb);
  assert.equal(digest(bb),h.bookGraphSha256);assert.equal(digest(pb),h.preparedGraphSha256);
  assert.equal(digest(pb),h.checkedPrefixStateSha256);assert.equal(digest(pb),h.freshPrefixStateSha256);
  const opts={range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi};
  const first=decodeBaseArena(bb,{...opts,rootKinds:['defs']});
  const all=decodeBaseArena(pb,{...opts,base:first,rootKinds:['checked','fresh','world','frontend']});
  const [checked,fresh,world,ready]=all.roots,book=first.roots[0];
  assert(book&&checked&&fresh&&world&&ready);
  assert.equal(world.prefix,book);assert.equal(world.state,checked);
  assert.equal(checked.ready,true);assert.equal(fresh.ready,true);assert.equal(ready.ready,true);
  assert(fresh.next>=1&&ready.count<=65536&&checked.bound<=1048576&&checked.stamp<=checked.delta);
  assert.equal(Object.keys(world).length,9);
  assert(all.nodes.length>=1&&all.nodes.length<=65536&&all.strings.length<=4096);
  return {header:h,all,roots:[book,checked,fresh,world,ready]};
}

const schema=[
  ['Nil',[]],['Con',['head','tail']],
  ['KTerm',['tag','name','id','quant','kids','removed','originBegin','originEnd']],
  ['KLambda',['name','id','quant','kids','removed','originBegin','originEnd','quantityPresent']],
  ['KLiteral',['kind','number','text','originBegin','originEnd']],
  ['KDef',['name','kind','arity','templates','typ','value','ctors','native','unsafe']],
  ['KIndexLeaf',['hash','bucket']],['KIndexNode',['hash','mask','left','right']],
  ['KBasePrefixState',['bound','delta','stamp','patches','ready']],
  ['FFreshPrefixState',['next','ready']],
  ['KBasePreparedWorld',['state','prefix','final','book','checked','seen','todos','checkedBound']],
  ['FReadyPrefixState',['names','ctors','count','ready']],
];
function decimalCarrier(all,rootValues,stamp){
  const ids=new Map(all.nodes.map((n,i)=>[n,i])),strings=new Map(all.strings.map((s,i)=>[s,i]));
  const tags=new Map(schema.map((s,i)=>[s[0],i])),parts=[];
  const number=n=>{assert(Number.isInteger(n)&&n>=0&&n<=0xffffffff&&!Object.is(n,-0));parts.push(String(n)+'\n');};
  const text=s=>{
    const chars=[...s];assert(chars.length<=1048576);
    assert(chars.every(c=>c.codePointAt(0)<0xd800||c.codePointAt(0)>0xdfff));
    number(chars.length);parts.push(s+'\n');
  };
  text(stamp);number(all.nodes.length);number(all.strings.length);all.strings.forEach(text);
  const rows=all.nodes.map((node,i)=>{
    const tag=tags.get(node.$);assert.notEqual(tag,undefined);
    const fields=schema[tag][1];assert.equal(Object.keys(node).length,fields.length+1);
    const row=fields.map((key,j)=>{
      const v=node[key];
      if(typeof v==='string'){
        const id=strings.get(v);assert.notEqual(id,undefined);return id+(tag===1&&j===0?0x80000000:0);
      }
      if(typeof v==='boolean')return Number(v);
      if(typeof v==='number')return v;
      const id=ids.get(v);assert(Number.isInteger(id)&&id<i);return id;
    });
    number(tag);number(row.length);row.forEach(number);return [tag,...row];
  });
  const roots=rootValues.map(r=>ids.get(r));roots.forEach(number);
  const bytes=Buffer.from(parts.join(''));assert(bytes.length<=16*1024*1024);
  return {bytes,roots,canonicalGraphSha256:digest(JSON.stringify({rows,strings:all.strings,roots}))};
}

function wordCarrier(input,stamp,nodeCount,stringCount){
  const chars=[...input];let at=0,numericTokens=0;
  assert(chars.every(c=>{const n=c.codePointAt(0);return n<0xd800||n>0xdfff;}));
  const parts=[],inverse=[];
  const word=n=>{
    assert(Number.isInteger(n)&&n>=0&&n<=0xffffffff);
    const s=String.fromCodePoint(65536+n%65536,65536+Math.floor(n/65536));
    const pair=[...s].map(c=>c.codePointAt(0)-65536);assert.equal(pair[0]+pair[1]*65536,n);return s;
  };
  const decimal=()=>{
    let text='';while(at<chars.length&&chars[at]!=='\n'){assert(text.length<10);text+=chars[at++];}
    assert.equal(chars[at++],'\n');assert(/^(0|[1-9][0-9]{0,9})$/.test(text));
    const n=Number(text);assert(n<=0xffffffff);return n;
  };
  const number=n=>{parts.push(word(n));inverse.push(String(n)+'\n');numericTokens++;};
  const string=()=>{
    const n=decimal();assert(n<=1048576&&at+n<chars.length);
    const text=chars.slice(at,at+n).join('');at+=n;assert.equal(chars[at++],'\n');return text;
  };
  assert.equal(string(),stamp);
  const newStamp='p130-word-pair-v1:'+stamp;
  parts.push(word([...newStamp].length),newStamp,'\n');inverse.push(String([...stamp].length)+'\n',stamp,'\n');numericTokens++;
  const nodes=decimal(),strings=decimal();assert.equal(nodes,nodeCount);assert.equal(strings,stringCount);
  number(nodes);number(strings);
  for(let i=0;i<strings;i++){const text=string();number([...text].length);parts.push(text,'\n');inverse.push(text,'\n');}
  while(at<chars.length)number(decimal());
  assert.equal(inverse.join(''),input,'Inverse must recover every canonical decimal carrier byte');
  const bytes=Buffer.from(parts.join(''));assert(bytes.length<=16*1024*1024);
  return {bytes,stamp:newStamp,numericTokens,unicodeScalars:{before:chars.length,after:[...parts.join('')].length}};
}

function main(){
  const args=options('Usage: base-carrier.mjs --preparation FRESH_PREPARATION_REPORT --out FRESH_BUILD_DIRECTORY',['preparation','out']);
  const prepared=preparation(args.preparation),{frame,api,base,source}=prepared.report;
  const inputs=[pin(import.meta.filename),pin(new URL('./base-artifacts.mjs',import.meta.url)),
    pin(new URL('./hosted.mjs',import.meta.url)),pin(new URL('../bootstrap-config.mjs',import.meta.url)),
    pin(new URL('../base-cache-graph.mjs',import.meta.url)),pin(new URL('../../src/host/prepared-base.bend',import.meta.url)),
    pin(new URL('../../src/host/base-word-transport.bend',import.meta.url)),pin(process.execPath),prepared.receipt,...prepared.report.inputs,frame];
  const out=freshDirectory(args.out),report={kind:'bend-prepared-base-carrier',version:1,complete:false,targetsRun:false,
    preparation:prepared.receipt,authority:prepared.report.authority,frame,api,source,base,inputs,
    format:'p130-word-pair-v1',nativeAdmission:false,
    derivation:'Transport extracted from commit 449b01ad25dcea16d20fb68c6a46937e4f542d91, selfhost/tools/performance/phase88/base/carrier.mjs and phase130/base/carrier.mjs; maintained schema, decoder and explicit fresh producer identities.',
    scope:'Authenticated transport only. No compiler execution, semantic qualification, native admission or installation.'};
  try{
    const {header,all,roots}=frameProducts({frame,api,base});
    const sourceIdentity={format:'p88-private-base-text-1',cache:frame.sha256,api:api.sha256,base:base.sha256,path:base.file,
      begin:header.sourceBegin,end:header.sourceEnd,termAbi:1,spanAbi:3,worldVersion:3};
    const originalStamp='p88-private-base-text-1:'+digest(JSON.stringify(sourceIdentity));
    const decimal=decimalCarrier(all,roots,originalStamp);
    const word=wordCarrier(decimal.bytes.toString('utf8'),originalStamp,all.nodes.length,all.strings.length);
    inputs.forEach(verify);
    const p88=path.join(out,'base.p88'),p130=path.join(out,'base.p130');
    fs.writeFileSync(p88,decimal.bytes,{flag:'wx'});fs.writeFileSync(p130,word.bytes,{flag:'wx'});
    Object.assign(report,{decimalCarrier:pin(p88),carrier:pin(p130),sourceIdentity,sourceBegin:header.sourceBegin,sourceEnd:header.sourceEnd,
      originalStamp,stamp:word.stamp,nodeCount:all.nodes.length,stringCount:all.strings.length,roots:decimal.roots,
      canonicalGraphSha256:decimal.canonicalGraphSha256,numericTokens:word.numericTokens,unicodeScalars:word.unicodeScalars,
      inverseByteIdentity:true,aliases:{worldPrefixIsBook:true,worldStateIsChecked:true},complete:true});
  }catch(error){report.error=String(error.stack??error);process.exitCode=1;}
  save(path.join(out,'report.json'),report);
  console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),carrier:report.carrier,error:report.error}));
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url))main();
