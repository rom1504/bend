// Offline serialization only. It never imports or executes a compiler API.
// Usage: node carrier.mjs CACHE EXPECTED_CACHE_SHA API BASE NEW_OUTPUT_DIRECTORY
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {decodeBaseArena} from '../../../base-cache-graph.mjs';
const [cache,expected,api,base,out]=process.argv.slice(2);
assert(out&&/^[0-9a-f]{64}$/.test(expected??''),'usage: carrier.mjs CACHE EXPECTED_CACHE_SHA API BASE NEW_OUT');
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=f=>{f=fs.realpathSync(f);const b=fs.readFileSync(f);return {file:f,sha256:hash(b),bytes:b.length};};
assert(fs.statSync(cache).size<=128*1024*1024);
const bytes=fs.readFileSync(cache);assert.equal(hash(bytes),expected);
const cut=bytes.indexOf(10);assert(cut>0&&cut<65536);
const h=JSON.parse(bytes.subarray(0,cut)),apiPin=pin(api),basePin=pin(base);
assert.equal(h.format,'bend-base-cache-frame-4');assert.equal(h.version,6);
assert.equal(h.termAbi,1);assert.equal(h.spanAbi,3);
assert.equal(h.compilerSha256,apiPin.sha256);assert.equal(h.baseSha256,basePin.sha256);
assert.equal(h.sourcePath,basePin.file);assert.equal(h.validatedBy,'check_book');
assert.equal(h.sourceBegin,1);assert.equal(h.sourceEnd,fs.readFileSync(base,'utf8').length+2);
for(const [key,version,producer] of [
  ['checkedPrefixState',1,'base_prefix_prepare'],['freshPrefixState',1,'f_fresh_prefix_prepare'],
  ['preparedWorld',3,'base_prefix_world_prepare'],['frontendReadyState',1,'f_ready_prefix_prepare']]){
  assert.equal(h[key+'Version'],version);assert.equal(h[key+'Producer'],producer);
}
assert.deepEqual(h.segments.map(n=>Number.isSafeInteger(n)&&n>=0),[true,true]);
const [nb,np]=h.segments;assert.equal(cut+1+nb+np,bytes.length);
const bb=bytes.subarray(cut+1,cut+1+nb),pb=bytes.subarray(cut+1+nb);
assert.equal(hash(bb),h.bookGraphSha256);assert.equal(hash(pb),h.preparedGraphSha256);
assert.equal(hash(pb),h.checkedPrefixStateSha256);assert.equal(hash(pb),h.freshPrefixStateSha256);
const opts={range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi};
const first=decodeBaseArena(bb,{...opts,rootKinds:['defs']});
const all=decodeBaseArena(pb,{...opts,base:first,rootKinds:['checked','fresh','world','frontend']});
const [checked,fresh,world,ready]=all.roots,book=first.roots[0];
assert(book&&checked&&fresh&&world&&ready);
assert.equal(world.prefix,book);assert.equal(world.state,checked);
assert.equal(checked.ready,true);assert.equal(fresh.ready,true);assert.equal(ready.ready,true);
assert(fresh.next>=1&&ready.count<=65536&&checked.bound<=1048576&&checked.stamp<=checked.delta);
assert.equal(Object.keys(world).length,9);
assert(all.nodes.length<=65536&&all.strings.length<=4096);
const ids=new Map(all.nodes.map((n,i)=>[n,i])),strings=new Map(all.strings.map((s,i)=>[s,i]));
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
const tags=new Map(schema.map((s,i)=>[s[0],i]));
const inputPins={cache:{...pin(cache)},api:apiPin,base:basePin,codec:pin(new URL('../../../base-cache-graph.mjs',import.meta.url)),serializer:pin(import.meta.filename),decoder:pin(new URL('./decoder.bend',import.meta.url))};
const stampBinding={format:'p88-private-base-text-1',cache:expected,api:apiPin.sha256,base:basePin.sha256,path:basePin.file,begin:h.sourceBegin,end:h.sourceEnd,termAbi:1,spanAbi:3,worldVersion:3};
const stamp='p88-private-base-text-1:'+hash(JSON.stringify(stampBinding));
const parts=[];
const num=n=>{assert(Number.isInteger(n)&&n>=0&&n<=0xffffffff);parts.push(String(n)+'\n');};
const text=s=>{
  const chars=[...s];assert(chars.length<=1048576);
  assert(chars.every(c=>c.codePointAt(0)<0xd800||c.codePointAt(0)>0xdfff));
  num(chars.length);parts.push(s+'\n');
};
text(stamp);num(all.nodes.length);num(all.strings.length);
all.strings.forEach(text);
const rows=all.nodes.map((node,i)=>{
  const tag=tags.get(node.$);assert.notEqual(tag,undefined);
  const fields=schema[tag][1];assert.equal(Object.keys(node).length,fields.length+1);
  const row=fields.map((key,j)=>{
    const v=node[key];
    if(typeof v==='string'){
      const id=strings.get(v);assert.notEqual(id,undefined);
      return id+(tag===1&&j===0?0x80000000:0);
    }
    if(typeof v==='boolean')return Number(v);
    if(typeof v==='number')return v;
    const id=ids.get(v);assert(Number.isInteger(id)&&id<i);return id;
  });
  num(tag);num(row.length);row.forEach(num);return [tag,...row];
});
const roots=[book,checked,fresh,world,ready].map(r=>ids.get(r));roots.forEach(num);
const carrier=Buffer.from(parts.join(''));assert(carrier.length<=16*1024*1024);
// Pin every input again before publishing this private build artifact.
for(const p of Object.values(inputPins))assert.deepEqual(pin(p.file),p);
fs.mkdirSync(out,{recursive:false});
const file=path.resolve(out,'base.p88');fs.writeFileSync(file,carrier,{flag:'wx'});
const receipt={kind:'phase88-private-base-carrier',complete:true,inputPins,cacheHeader:h,
  stamp,stampBinding,carrier:pin(file),nodeCount:all.nodes.length,stringCount:all.strings.length,roots,
  producer:'Existing checked B2 prepared-cache artifact; this tool only serializes it.',
  nativeAdmission:'Not granted. Root must bind consumer image and authenticate full carrier bytes before launch; compare against fresh native preparation. Stamp equality alone is insufficient.',
  aliases:{worldPrefixIsBook:true,worldStateIsChecked:true},
  canonicalGraphSha256:hash(JSON.stringify({rows,strings:all.strings,roots})),
  instructions:'Load <=16MiB text, call p88_decode_admitted(text, receipt.stamp, sourceBegin, sourceEnd). Keep Base FSource construction/source identity unchanged.'};
fs.writeFileSync(path.join(out,'receipt.json'),JSON.stringify(receipt,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({receipt:path.resolve(out,'receipt.json'),carrier:receipt.carrier,stamp,nodeCount:receipt.nodeCount,stringCount:receipt.stringCount}));
