// Small filesystem/JSON transport controls; no Bend compiler API calls or builds.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {encodeBaseCacheFrame,decodeBaseCacheFrame} from './base-cache-frame.mjs';
const [outArg]=process.argv.slice(2);assert(outArg,'controls04.mjs NEW_OUT');
const root=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase61'));
const out=path.resolve(outArg);assert(out.startsWith(root+path.sep));assert(!fs.existsSync(out));let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);assert(fs.realpathSync(ancestor)===root||fs.realpathSync(ancestor).startsWith(root+path.sep));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),pins=new Map();
function pin(f,want){f=fs.realpathSync(f);const b=fs.readFileSync(f),r={file:f,sha256:hash(b),bytes:b.length};if(want){assert.equal(r.sha256,want.sha256);assert.equal(r.bytes,want.bytes);}if(pins.has(f))assert.deepEqual(r,pins.get(f));pins.set(f,r);return r;}
const source=JSON.parse(fs.readFileSync(pin(path.join(import.meta.dirname,'source01.json')).file));
const combined=JSON.parse(fs.readFileSync(pin(path.join(import.meta.dirname,'combined03.json')).file));source.candidate=combined.candidate;
const project=path.resolve(import.meta.dirname,'../../../..'),originalTools=path.join(project,'tools');
const report={kind:'phase61-cache-frame-io-controls',version:4,complete:false,pass:false,rows:[],copies:[],inputs:[],scope:'Small independent JSON/source-span/corruption/invalidation filesystem tests. No compiler calls, requests, cache permission proof, or performance claim.'};
const save=()=>{report.inputs=[...pins.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
function copy(f,to){const r=pin(f);fs.mkdirSync(path.dirname(to),{recursive:true});fs.copyFileSync(f,to,fs.constants.COPYFILE_EXCL);const t=pin(to);assert.equal(t.sha256,r.sha256);report.copies.push({source:r,destination:t});}
try{
 pin(import.meta.filename);report.parentController=pin(path.join(import.meta.dirname,'controls03.mjs'));pin(process.execPath);pin(path.join(import.meta.dirname,'base-cache-frame.mjs'),source.helper);
 const mods={};for(const role of ['baseline','candidate']){
  const dir=path.join(out,role),tools=path.join(dir,'tools');
  for(const name of ['assemble','native-build','node-resource-args','compiler-abi'])copy(path.join(originalTools,name+'.mjs'),path.join(tools,name+'.mjs'));
  copy(path.join(project,'src/compiler.json'),path.join(dir,'src/compiler.json'));
  const f=pin(source[role].file,source[role]);let s=fs.readFileSync(f.file,'utf8');
  if(role==='candidate') {
    const manifest=JSON.parse(fs.readFileSync(pin(path.join(project,'src/compiler.json')).file,'utf8'));
    const inventory=[['src/check/prefix-state.bend',['base_prefix_prepare','check_program_diagnostic_seed']],['src/load/prefix.bend',['f_fresh_prefix_prepare','f_graph_trace_from_prefix']]];
    for(const [module,names]of inventory){assert(manifest.modules.includes(module),'Missing source manifest '+module);const line="if(files.includes('"+module+"'))exports.push("+names.map(n=>"'"+n+"'").join(',')+");";assert.equal(s.split(line).length-1,1,'Missing exact bootstrap export branch '+module);const body=fs.readFileSync(pin(path.join(project,module)).file,'utf8');for(const name of names)assert(new RegExp('^def '+name+'\\(', 'm').test(body),'Missing actual source method '+name);}
    report.bootstrapExportInventory={modules:inventory,scope:'Exact conditional export branches, manifest membership and source definitions; actual checked bootstrap export receipt is separately required'};
  }

  s+='\nexport const p61CacheProbe={read:readBaseCache};\n';
  const dst=path.join(tools,'typed-driver.mjs');fs.writeFileSync(dst,s,{flag:'wx'});pin(dst);
  const baseFile=path.join(dir,'Base.bend');fs.writeFileSync(baseFile,'private host control Base');
  const oldBase=process.env.BEND_BASE;process.env.BEND_BASE=baseFile;
  try{mods[role]=await import(pathToFileURL(dst));}finally{if(oldBase===undefined)delete process.env.BEND_BASE;else process.env.BEND_BASE=oldBase;}
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
 // Synthetic host transport/schema only; source checker permission is separately gated.
 const goodState={$:'KBasePrefixState',bound:7,delta:3,stamp:2,patches:{$:'Nil'},ready:true};
 const withState=(state,extra={})=>({...seal(base()),checkedPrefixStateVersion:1,checkedPrefixStateProducer:'base_prefix_prepare',checkedPrefixState:state,checkedPrefixStateSha256:hash(JSON.stringify(state)),...extra});
 const stateTests=[['ready',goodState,{},true],['not-ready',{...goodState,ready:false},{},false],['wrong-tag',{...goodState,$:'Other61'},{},false],['negative-bound',{...goodState,bound:-1},{},false],['too-large-bound',{...goodState,bound:1048577},{},false],['fraction-delta',{...goodState,delta:0.5},{},false],['stamp-over-delta',{...goodState,stamp:4},{},false],['malformed-patches',{...goodState,patches:{$:'Con',head:{},tail:{$:'Nil'}}},{},false],['wrong-producer',goodState,{checkedPrefixStateProducer:'check_book'},false],['wrong-schema',goodState,{checkedPrefixStateVersion:0},false],['digest-drift',goodState,{checkedPrefixStateSha256:'0'.repeat(64)},false]];
 for(const [name,state,extra,expected]of stateTests){const result=observe('candidate',withState(state,extra));assert.equal(result.error,undefined);assert.deepEqual(result.value.book,payload);assert.equal(result.value.checkedPrefixState!==undefined,expected);report.rows.push({name:'state-'+name,admitted:expected,scope:'Host shape/invalidation only, no source proof'});}
 const memo={entry:null};const admitted=observe('candidate',withState(goodState),null,memo);assert(Object.isFrozen(admitted.value.checkedPrefixState));assert(Object.isFrozen(admitted.value.checkedPrefixState.patches));assert(Object.isFrozen(admitted.value.book));report.rows.push({name:'state-deep-freeze'});
 const fresh={$:'FFreshPrefixState',next:7,ready:true};
 const withFresh=(state,extra={})=>({...seal(base()),freshPrefixStateVersion:1,freshPrefixStateProducer:'f_fresh_prefix_prepare',freshPrefixState:state,freshPrefixStateSha256:hash(JSON.stringify(state)),...extra});
 const freshTests=[['ready',fresh,{},true],['not-ready',{...fresh,ready:false},{},false],['wrong-tag',{...fresh,$:'Other61'},{},false],['zero-next',{...fresh,next:0},{},false],['negative-next',{...fresh,next:-1},{},false],['too-large-next',{...fresh,next:4294967296},{},false],['fraction-next',{...fresh,next:0.5},{},false],['wrong-producer',fresh,{freshPrefixStateProducer:'f_graph_trace'},false],['wrong-schema',fresh,{freshPrefixStateVersion:0},false],['digest-drift',fresh,{freshPrefixStateSha256:'0'.repeat(64)},false]];
 for(const [name,state,extra,expected]of freshTests){const result=observe('candidate',withFresh(state,extra));assert.equal(result.error,undefined);assert.deepEqual(result.value.book,payload);assert.equal(result.value.freshPrefixState!==undefined,expected);report.rows.push({name:'fresh-'+name,admitted:expected,scope:'Host predicate only, not freshener proof'});}
 const freshMemo={entry:null};const freshRead=observe('candidate',withFresh(fresh),null,freshMemo);assert(Object.isFrozen(freshRead.value.freshPrefixState));assert(Object.isFrozen(freshRead.value.book));report.rows.push({name:'fresh-deep-freeze'});
 // Public discoverSources must ignore raw optional state, even with matched Base seed.
 // These are host mocks, not compiler APIs or semantic/proof oracle substitutes.
 for(const role of ['baseline','candidate']){
  const baseFile=mods[role].basePath,main=path.join(out,role,'main.bend');fs.writeFileSync(main,'private host control main');let ordinary=0,privileged=0;
  const nil={$:'Nil'},graph={$:'FGraph',book:nil,error:'',done:nil},parsed={book:nil,error:'',imports:nil};
  const api={compiler_load_abi:()=>2,f_source_header:()=>({imports:{$:'Con',head:{name:'Base'},tail:nil}}),f_complete_source:()=>({graph,parsed}),f_complete_seed:()=>({graph,parsed}),f_import_namespace_at:()=>'',f_graph_trace:()=>{ordinary++;return {kind:'ordinary'};},f_graph_trace_from_prefix:()=>{privileged++;throw Error('Raw public seed obtained permission');},f_load_graph:()=>graph,f_source_located:s=>s,f_source_completed:(name,path,text)=>({$: 'FSource',name,path,text})};
  const seed={sourcePath:fs.realpathSync(baseFile),sourceText:fs.readFileSync(baseFile,'utf8'),book:nil,freshPrefixState:fresh};
  for(const permission of [undefined,{}]){const result=mods[role].discoverSources(api,main,{seed,freshPrefixPermission:permission});assert.equal(result.loadTrace.kind,'ordinary');}
  assert.equal(ordinary,2);assert.equal(privileged,0);report.rows.push({name:role+'-public-raw-fresh-state-refusal',ordinary,privileged});
 }
 // Public validators keep cyclic/aliased object behavior and getter visitation.
 for(const role of ['baseline','candidate']){const shared={a:payload.head,b:payload.head};shared.self=shared;assert.equal(mods[role].validateSpanBook(shared,[{begin:1,end:13}],1),true);let reads=0;const live={get x(){reads++;return payload.head;}};assert.equal(mods[role].validateSpanBook(live,[{begin:1,end:13}],1),true);assert.equal(reads,1);assert.equal(mods[role].validateSpanCache(c,info),true);report.rows.push({name:role+'-public-cycle-alias-getter'});}
 for(const r of pins.values())pin(r.file,r);report.complete=true;report.pass=true;save();
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};save();throw e;}
