// Observation only: checked Bend owns Base preparation and complete parsing.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [manifestArg,oldArg,newArg,outArg]=process.argv.slice(2);
assert(manifestArg&&oldArg&&newArg&&outArg,'MANIFEST OLD_API NEW_API FRESH_OUT');
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(!fs.existsSync(out)&&out.startsWith(ROOT+'/selfhost/build/phase144/'));
const read=f=>JSON.parse(fs.readFileSync(f));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const inputs=new Map(),add=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p};
const manifest=read(manifestArg),selection=ROOT+'/implementation/phase143/candidate.json',selected=read(selection);
assert(manifest.complete&&!manifest.checked);manifest.inputs.forEach(add);
const carrier=read(selected.preferredCarrierReceipt.file),base=carrier.inputs.find(p=>p.file.endsWith('/bend2/base.bend'));assert(base&&carrier.complete);
for(const f of [manifestArg,oldArg,newArg,selection,selected.preferredCarrierReceipt.file,import.meta.filename,process.execPath])add(pin(f));
add(base);add(selected.preferredCarrier);add(manifest.request);
const receipts={original:read(oldArg),candidate:read(newArg)};
for(const[role,r]of Object.entries(receipts)){assert(r.complete&&r.checked);for(const k of manifest.exports)assert(r.exports.includes(k));assert(r.inputs.some(p=>p.sha256===manifest.sourcePair[role].source.sha256));r.inputs.forEach(add);add(r.api)}
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase144-native-parser-hosted-oracle',complete:false,request:manifest.request,rows:[],
 scope:'Complete external parse trace and prepared seed equality on the fixed full compiler input. Independent host typed-field checksum agrees with checked Bend checksum; the 32-bit checksum alone is not a semantic proof. Hosted time is not native time.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
const tag=(v,t)=>{assert.equal(v?.$,t);return v};
const timed=f=>{const t=performance.now(),value=f();return{value,seconds:(performance.now()-t)/1000}};
function exact(a,b){const todo=[[a,b]],seen=new WeakMap();let pairs=0;while(todo.length){const[x,y]=todo.pop();if(Object.is(x,y))continue;
 assert(x&&y&&typeof x==='object'&&typeof y==='object','Different scalar');let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys)}ys.add(y);
 assert(++pairs<12000000,'Oracle graph bound');const akeys=Object.keys(x).sort(),bkeys=Object.keys(y).sort();assert.deepEqual(akeys,bkeys);for(const k of akeys)todo.push([x[k],y[k]])}return pairs}
function digest(result){let h=2166136261,words=0;const todo=[['result',result]];
 const word=n=>{assert(Number.isInteger(n)&&n>=0&&n<=4294967295);h=Math.imul((h^n)>>>0,16777619)>>>0;words++};
 const push=items=>{for(let i=items.length-1;i>=0;i--)todo.push(items[i])};
 while(todo.length){const[k,v]=todo.pop();
  if(k==='word'){word(v);continue}if(k==='bool'){assert.equal(typeof v,'boolean');word(+v);continue}
  if(k==='text'){assert.equal(typeof v,'string');for(const c of v)word(c.codePointAt(0));word(1100000);continue}
  if(['defs','terms','texts'].includes(k)){const code={defs:40,terms:20,texts:10}[k];if(v.$==='Nil')word(code);else{tag(v,'Con');word(code+1);push([[{defs:'def',terms:'term',texts:'text'}[k],v.head],[k,v.tail]])}continue}
  if(k==='result'){tag(v,'FResult');push([['defs',v.book],['text',v.error],['terms',v.imports]]);continue}
  if(k==='def'){
   if(v.$==='KDef'){word(50);push([['text',v.name],['text',v.kind],['word',v.arity],['word',v.templates],['term',v.typ],['term',v.value],['defs',v.ctors],['bool',v.native],['bool',v.unsafe]])}
   else if(v.$==='KIndexLeaf'){word(51);push([['word',v.hash],['defs',v.bucket]])}
   else{tag(v,'KIndexNode');word(52);push([['word',v.hash],['word',v.mask],['def',v.left],['def',v.right]])}continue
  }
  assert.equal(k,'term');
  if(v.$==='KTerm'){word(30);push([['text',v.tag],['text',v.name],['word',v.id],['word',v.quant],['terms',v.kids],['texts',v.removed],['word',v.originBegin],['word',v.originEnd]])}
  else if(v.$==='KLambda'){word(31);push([['text',v.name],['word',v.id],['word',v.quant],['terms',v.kids],['texts',v.removed],['word',v.originBegin],['word',v.originEnd],['bool',v.quantityPresent]])}
  else{tag(v,'KLiteral');word(32);push([['text',v.kind],['word',v.number],['text',v.text],['word',v.originBegin],['word',v.originEnd]])}
 }
 return{hash:h,words}
}
save();const started=performance.now();
try{
 const products={};
 for(const[role,rec]of Object.entries(receipts)){
  const api=(await import(pathToFileURL(rec.api.file))).default;
  const prep=timed(()=>tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),fs.readFileSync(selected.preferredCarrier.file,'utf8'),selected.preferredStamp),'P86PreparationReady'));
  const parsed=timed(()=>tag(api.p144pn_parse(prep.value.seed,manifest.request.file,fs.readFileSync(manifest.request.file,'utf8')),'P144PNParsed'));
  assert.equal(api.p144pn_error(parsed.value),'');const result=tag(tag(tag(parsed.value.load,'FPrefixLoad').trace,'FLoadTrace').result,'FResult');
  const observed=timed(()=>digest(result));const bend=timed(()=>api.p144pn_hash(parsed.value));assert.equal(bend.value,observed.value.hash);
  products[role]=parsed.value;report.rows.push({role,prepareSeconds:prep.seconds,parseSeconds:parsed.seconds,hostObserveSeconds:observed.seconds,bendObserveSeconds:bend.seconds,...observed.value});save();
 }
 const equality=timed(()=>exact(products.original,products.candidate));report.completeParseAndSeedEqual=true;report.equalGraphPairs=equality.value;report.equalitySeconds=equality.seconds;
 assert.equal(report.rows[0].hash,report.rows[1].hash);report.expectedHash=report.rows[0].hash;
 for(const p of inputs.values())add(p);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{report.seconds=(performance.now()-started)/1000;report.peakRssBytes=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows,expectedHash:report.expectedHash,error:report.error}))}
