// Small filesystem/JSON transport controls; no Bend compiler API calls or builds.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {encodeBaseCacheFrame,decodeBaseCacheFrame} from './base-cache-frame.mjs';
const [outArg]=process.argv.slice(2);assert(outArg,'controls01.mjs NEW_OUT');
const root=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase61'));
const out=path.resolve(outArg);assert(out.startsWith(root+path.sep));assert(!fs.existsSync(out));let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);assert(fs.realpathSync(ancestor)===root||fs.realpathSync(ancestor).startsWith(root+path.sep));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),pins=new Map();
function pin(f,want){f=fs.realpathSync(f);const b=fs.readFileSync(f),r={file:f,sha256:hash(b),bytes:b.length};if(want){assert.equal(r.sha256,want.sha256);assert.equal(r.bytes,want.bytes);}if(pins.has(f))assert.deepEqual(r,pins.get(f));pins.set(f,r);return r;}
const source=JSON.parse(fs.readFileSync(pin(path.join(import.meta.dirname,'source01.json')).file));
const project=path.resolve(import.meta.dirname,'../../../..'),originalTools=path.join(project,'tools');
const report={kind:'phase61-cache-frame-io-controls',complete:false,pass:false,rows:[],copies:[],inputs:[],scope:'Small independent JSON/source-span/corruption/invalidation filesystem tests. No compiler calls, requests, cache permission proof, or performance claim.'};
const save=()=>{report.inputs=[...pins.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
function copy(f,to){const r=pin(f);fs.mkdirSync(path.dirname(to),{recursive:true});fs.copyFileSync(f,to,fs.constants.COPYFILE_EXCL);const t=pin(to);assert.equal(t.sha256,r.sha256);report.copies.push({source:r,destination:t});}
try{
 pin(import.meta.filename);pin(process.execPath);pin(path.join(import.meta.dirname,'base-cache-frame.mjs'),source.helper);
 const mods={};for(const role of ['baseline','candidate']){
  const dir=path.join(out,role),tools=path.join(dir,'tools');
  for(const name of ['assemble','native-build','node-resource-args','compiler-abi'])copy(path.join(originalTools,name+'.mjs'),path.join(tools,name+'.mjs'));
  copy(path.join(project,'src/compiler.json'),path.join(dir,'src/compiler.json'));
  const f=pin(source[role].file,source[role]);let s=fs.readFileSync(f.file,'utf8');
  s+='\nexport const p61CacheProbe={read:readBaseCache};\n';
  const dst=path.join(tools,'typed-driver.mjs');fs.writeFileSync(dst,s,{flag:'wx'});pin(dst);
  mods[role]=await import(pathToFileURL(dst));
 }
 const payload={$:'Con',head:{$:'KTerm',tag:'Ref',name:'Quartz61',id:1,quant:0,kids:{$:'Nil'},removed:{$:'Nil'},originBegin:1,originEnd:4},tail:{$:'Nil'}};
 const info={version:6,termAbi:1,compilerSha256:'c'.repeat(64),baseSha256:'b'.repeat(64),sourcePath:'/private/Base.bend',sourceText:'type Base61',file:''};
 const base=()=>({version:6,termAbi:1,spanAbi:3,compilerSha256:info.compilerSha256,baseSha256:info.baseSha256,sourcePath:info.sourcePath,sourceBegin:1,sourceEnd:13,validatedBy:'check_book',book:structuredClone(payload),generated:'private-control'});
 const seal=c=>({...c,bookSha256:hash(JSON.stringify(c.book))});
 function bytes(c,role){return role==='baseline'?Buffer.from(JSON.stringify(c)):encodeBaseCacheFrame(c);}
 function observe(role,c,override=null,memo=null){const file=path.join(out,role,'cache.json');fs.writeFileSync(file,override??bytes(c,role));try{return {value:mods[role].p61CacheProbe.read({...info,file},memo)};}catch(e){return {error:{name:e.name,message:e.message}};}}
 const tests=[['valid',seal(base()),null],['wrong-api',seal({...base(),compilerSha256:'x'.repeat(64)}),'Invalid source-aware Base cache'],['wrong-base',seal({...base(),baseSha256:'x'.repeat(64)}),'Invalid source-aware Base cache'],['wrong-path',seal({...base(),sourcePath:'/other/Base.bend'}),'Invalid source-aware Base cache'],['wrong-end',seal({...base(),sourceEnd:12}),'Invalid source-aware Base cache'],['wrong-term-abi',seal({...base(),termAbi:0}),'Invalid source-aware Base cache'],['wrong-producer',seal({...base(),validatedBy:'parse_book'}),'Invalid source-aware Base cache']];
 const range=base();range.book.head.originEnd=100;tests.push(['invalid-range',seal(range),'Invalid compiler source range']);
 const literal=base();literal.book.head={$:'KLiteral',kind:'String',number:0,text:'\ud800',originBegin:1,originEnd:4};tests.push(['invalid-surrogate-literal',seal(literal),'Invalid compiler literal payload']);
 const lambda=base();lambda.book.head={$:'KLambda',quantityPresent:'yes',originBegin:1,originEnd:4};tests.push(['invalid-lambda',seal(lambda),'Invalid compiler Lambda payload']);
 for(const [name,c,error]of tests){const a=observe('baseline',c),b=observe('candidate',c);assert.deepEqual(b,a);if(error)assert.equal(a.error.message,error);else assert.deepEqual(a.value.book,payload);report.rows.push({name,error:a.error??null});save();}
 for(const role of ['baseline','candidate']){
  const c=seal(base()),memo={entry:null};const first=observe(role,c,null,memo);assert(first.value);assert(Object.isFrozen(first.value.book));const retained=memo.entry;const second=mods[role].p61CacheProbe.read({...info,file:path.join(out,role,'cache.json')},memo);assert.equal(memo.entry,retained);assert.equal(second.book,first.value.book);
  const changed=base();changed.book.head.name='Renamed61';const third=observe(role,seal(changed),null,memo);assert(third.value);assert.notEqual(memo.entry,retained);assert.equal(third.value.book.head.name,'Renamed61');
  const deleted=path.join(out,role,'cache.json');fs.unlinkSync(deleted);assert.equal(mods[role].p61CacheProbe.read({...info,file:deleted},memo),null);assert.equal(memo.entry,null);
  assert.deepEqual(observe(role,c,Buffer.from('{')), {value:null});report.rows.push({name:role+'-memo-change-missing-syntax'});
 }
 const c=seal(base()),badHash={...c,bookSha256:'0'.repeat(64)};const old=observe('baseline',badHash);let frame=encodeBaseCacheFrame(c).toString();frame=frame.replace(c.bookSha256,badHash.bookSha256);const newer=observe('candidate',c,Buffer.from(frame));assert.deepEqual(newer,old);assert.equal(old.error.message,'Invalid source-aware Base cache');report.rows.push({name:'payload-digest-mismatch',error:old.error});
 for(const version of [1,2])for(const role of ['baseline','candidate']){const legacy={...c,version},file=path.join(out,role,'legacy-'+version+'.json');fs.writeFileSync(file,JSON.stringify(legacy));const got=mods[role].p61CacheProbe.read({...info,version,file});assert.deepEqual(got.book,payload);report.rows.push({name:role+'-legacy-version-'+version});}
 const validFrame=encodeBaseCacheFrame(c).toString(),headerCut=validFrame.indexOf('\n'),header=JSON.parse(validFrame.slice(0,headerCut));header.book={forged:true};const forged=Buffer.from(JSON.stringify(header)+'\n'+validFrame.slice(headerCut+1));assert.equal(observe('candidate',c,forged).error.message,'Invalid source-aware Base cache');report.rows.push({name:'frame-header-cannot-shadow-book'});
 const framed=encodeBaseCacheFrame(c);assert.deepEqual(decodeBaseCacheFrame(framed),c);assert.deepEqual(JSON.parse(JSON.stringify(decodeBaseCacheFrame(framed).book)),payload);
 // Public validators keep cyclic/aliased object behavior and getter visitation.
 for(const role of ['baseline','candidate']){const shared={a:payload.head,b:payload.head};shared.self=shared;assert.equal(mods[role].validateSpanBook(shared,[{begin:1,end:13}],1),true);let reads=0;const live={get x(){reads++;return payload.head;}};assert.equal(mods[role].validateSpanBook(live,[{begin:1,end:13}],1),true);assert.equal(reads,1);assert.equal(mods[role].validateSpanCache(c,info),true);report.rows.push({name:role+'-public-cycle-alias-getter'});}
 for(const r of pins.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};save();throw e;}
