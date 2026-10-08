#!/usr/bin/env node
// Exercise the real private admission functions through an export-only driver
// copy. No compiler image is imported; original source/cache files are untouched.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL,fileURLToPath} from 'node:url';

const [driverFile,cacheFile,baseFile,outputFile]=process.argv.slice(2).map(x=>path.resolve(x));
if(!outputFile)throw Error('Usage: constructor-host-v1.mjs STAGED_DRIVER FRAME3_OR_FRAME4 BASE OUTPUT.json');
const directory=path.dirname(outputFile);fs.mkdirSync(directory,{recursive:true});
const sandbox=path.join(directory,'admission-scratch');fs.mkdirSync(sandbox,{recursive:false});
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const original=fs.readFileSync(driverFile,'utf8'),project=path.resolve(path.dirname(driverFile),'..');
const helperFile=path.join(path.dirname(driverFile),'base-cache-graph.mjs'),helperBytes=fs.readFileSync(helperFile),controllerBytes=fs.readFileSync(import.meta.filename);
const derivationFile=path.join(import.meta.dirname,'constructor-host-v1.derivation.json'),derivationBytes=fs.readFileSync(derivationFile);
assert.equal(original.split("export const project=path.resolve(import.meta.dirname,'..');").length,2);
let source=original.replace("export const project=path.resolve(import.meta.dirname,'..');",`export const project=${JSON.stringify(project)};`);
source=source.replace(/from '(\.\/[^']+)'/g,(_,name)=>`from '${pathToFileURL(path.resolve(path.dirname(driverFile),name)).href}'`);
source+='\nexport {readBaseCache,encodeBaseCacheArenaFrame,encodeBaseCacheFrame};\n';
const instrumented=path.join(sandbox,'admission-driver.mjs');fs.writeFileSync(instrumented,source,{flag:'wx'});
const driver=await import(pathToFileURL(instrumented));
const inputBytes=fs.readFileSync(cacheFile),inputDecoded=driver.decodeBaseCacheFrame(inputBytes);assert.ok(inputDecoded.preparedWorld);assert.ok(inputDecoded.frontendReadyState);
const bytes=driver.encodeBaseCacheFrame(inputDecoded),cut=bytes.indexOf(10),header=JSON.parse(bytes.subarray(0,cut));
assert.equal(header.format,'bend-base-cache-frame-3');
const nb=header.segments[0],bookBytes=bytes.subarray(cut+1,cut+1+nb),preparedBytes=bytes.subarray(cut+1+nb);
const initial=driver.decodeBaseCacheFrame(bytes);assert.ok(initial.preparedWorld);assert.ok(initial.frontendReadyState);
const file=path.join(sandbox,'base-frame3.json');
const info={version:header.version,termAbi:header.termAbi??0,compilerSha256:header.compilerSha256,baseSha256:header.baseSha256,
  sourcePath:fs.realpathSync(baseFile),sourceText:fs.readFileSync(baseFile,'utf8'),file,directory:sandbox};
assert.equal(info.baseSha256,sha(fs.readFileSync(baseFile)));assert.equal(info.sourcePath,header.sourcePath);
const controls=[];
const frame=(h=header,b=bookBytes,p=preparedBytes)=>Buffer.concat([Buffer.from(JSON.stringify({...h,segments:[b.length,p.length]})+'\n'),b,p]);
function read(value=bytes,memo=null){fs.writeFileSync(file,value);return driver.readBaseCache(info,memo);}
function check(name,body){body();controls.push({name,pass:true});}
const full=value=>{assert.ok(value.book);assert.ok(value.checkedPrefixState);assert.ok(value.freshPrefixState);assert.ok(value.preparedWorld);assert.ok(value.frontendReadyState);return value;};
check('valid producer roots coupled',()=>{const c=full(read());assert.equal(c.preparedWorld.prefix,c.book);assert.equal(c.preparedWorld.state,c.checkedPrefixState);});
check('world version4 unsigned facts and constructor index admitted',()=>{const c=full(read());assert.equal(header.preparedWorldVersion,4);assert.ok(['KDef','KIndexLeaf','KIndexNode'].includes(c.preparedWorld.constructorIndex?.$));for(const key of ['todos','checkedBound'])assert.ok(Number.isSafeInteger(c.preparedWorld[key])&&c.preparedWorld[key]>=0&&c.preparedWorld[key]<=0xffffffff);});
for(const [key,value] of [['compilerSha256','bad'],['baseSha256','bad'],['sourcePath','/wrong/base.bend'],['sourceEnd',header.sourceEnd+1],['sourceBegin',2],['version',99],['termAbi',99],['spanAbi',99],['validatedBy','not-checked']])
  check('reject header '+key,()=>assert.throws(()=>read(frame({...header,[key]:value}))));
check('reject mandatory digest mismatch',()=>assert.throws(()=>read(frame({...header,bookGraphSha256:'bad'}))));
const editPrepared=edit=>{
  const wire=JSON.parse(preparedBytes);edit(wire);const p=Buffer.from(JSON.stringify(wire)),hash=sha(p);
  return frame({...header,preparedGraphSha256:hash,checkedPrefixStateSha256:hash,freshPrefixStateSha256:hash},bookBytes,p);
};
check('world version1 capability rejected',()=>{const c=read(frame({...header,preparedWorldVersion:1}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('world version2 capability rejected',()=>{const c=read(frame({...header,preparedWorldVersion:2}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('legacy world missing all three facts rejected by version4 host',()=>{const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,10);row.length=7;}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('legacy world missing checkedBound and constructor index rejected by version4 host',()=>{const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,10);row.length=8;}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('world version3 capability rejected',()=>{const c=read(frame({...header,preparedWorldVersion:3}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('legacy world missing constructor index rejected by version4 host',()=>{const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,10);row.length=9;}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
for(const value of [-1,0.5,4294967296,'0',{},null])check('malformed constructor index reference '+JSON.stringify(value),()=>{
  const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,10);row[9]=value;}));
  assert.ok(c.book);for(const key of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert.equal(c[key],undefined);
});
for(const tag of [0,2])check('constructor index rejects wrong graph subtype '+tag,()=>{
  const wire=JSON.parse(bookBytes),id=wire[3].findIndex(row=>row[0]===tag);assert.ok(id>=0);
  const c=read(editPrepared(w=>{w[3][w[2][2]-w[1]][9]=id;}));
  assert.ok(c.book);for(const key of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert.equal(c[key],undefined);
});
for(const value of [-1,0.5,4294967296,'0',{},null])check('malformed TODO fact '+JSON.stringify(value),()=>{
  const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,10);row[7]=value;}));
  assert.ok(c.book);for(const key of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert.equal(c[key],undefined);
});
for(const value of [-1,0.5,4294967296,'0',{},null])check('malformed checkedBound fact '+JSON.stringify(value),()=>{
  const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,10);row[8]=value;}));
  assert.ok(c.book);for(const key of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert.equal(c[key],undefined);
});
check('optional digest mismatch drops all acceleration',()=>{const c=read(frame({...header,preparedGraphSha256:'bad'}));assert.ok(c.book);for(const key of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert.equal(c[key],undefined);});
check('optional graph malformed drops all acceleration',()=>{const c=read(editPrepared(w=>w[3].push([999])));assert.ok(c.book);for(const key of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'])assert.equal(c[key],undefined);});
check('mandatory root null refused',()=>{const w=JSON.parse(bookBytes);w[2][0]=null;const b=Buffer.from(JSON.stringify(w));assert.throws(()=>read(frame({...header,bookGraphSha256:sha(b)},b)));});
check('optional world mismatched prefix dropped',()=>{
  const b=JSON.parse(bookBytes),nil=b[3].findIndex(row=>row[0]===0);assert.ok(nil>=0);
  const c=read(editPrepared(w=>{const old=w[3][w[2][2]-w[1]];assert.equal(old[0],10);const row=old.slice();row[2]=nil;w[2][2]=w[1]+w[3].length;w[3].push(row);}));
  assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);
});
check('optional world mismatched state dropped',()=>{
  const c=read(editPrepared(w=>{const state=w[3][w[2][0]-w[1]].slice();assert.equal(state[0],8);state[1]+=1;
    const world=w[3][w[2][2]-w[1]].slice();assert.equal(world[0],10);world[1]=w[1]+w[3].length;w[3].push(state);w[2][2]=w[1]+w[3].length;w[3].push(world);}));
  assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);
});
for(const key of ['preparedWorldVersion','preparedWorldProducer','frontendReadyStateVersion','frontendReadyStateProducer'])
  check('drop incorrect '+key,()=>{const c=read(frame({...header,[key]:'wrong'}));assert.equal(c[key.startsWith('preparedWorld')?'preparedWorld':'frontendReadyState'],undefined);assert.ok(c.checkedPrefixState);});
check('state binding digest mismatch drops checked world',()=>{const c=read(frame({...header,checkedPrefixStateSha256:'bad'}));assert.equal(c.checkedPrefixState,undefined);assert.equal(c.preparedWorld,undefined);assert.ok(c.frontendReadyState);});
check('optional null roots use ordinary path',()=>{const c=read(editPrepared(w=>w[2]=[null,null,null,null]));assert.ok(c.book);assert.equal(c.preparedWorld,undefined);assert.equal(c.frontendReadyState,undefined);});
check('persistent cache same bytes reuses frozen graph',()=>{const memo={entry:null};const a=full(read(bytes,memo)),b=full(driver.readBaseCache(info,memo));assert.equal(a.book,b.book);assert.ok(Object.isFrozen(b.preparedWorld));assert.ok(Object.isFrozen(b.frontendReadyState));assert.throws(()=>{b.preparedWorld.state.ready=false;});});
check('persistent cache changed bytes readmitted',()=>{const memo={entry:null},a=full(read(bytes,memo)),b=full(read(frame({...header,generated:'changed bytes'}),memo));assert.notEqual(a.book,b.book);});
check('persistent optional corruption clears old capability',()=>{const memo={entry:null};full(read(bytes,memo));const c=read(frame({...header,preparedGraphSha256:'bad'}),memo);assert.equal(c.preparedWorld,undefined);assert.equal(c.frontendReadyState,undefined);});
check('persistent cache deletion clears memo',()=>{const memo={entry:null};full(read(bytes,memo));fs.unlinkSync(file);assert.equal(driver.readBaseCache(info,memo),null);assert.equal(memo.entry,null);});
check('frame2 fallback when frame3 absent',()=>{
  const b=Buffer.from(JSON.stringify(initial.book)),c=Buffer.from(JSON.stringify(initial.checkedPrefixState)),f=Buffer.from(JSON.stringify(initial.freshPrefixState));
  const h={...header,format:'bend-base-cache-frame-2',segments:[b.length,c.length,f.length],bookSha256:sha(b),checkedPrefixStateSha256:sha(c),freshPrefixStateSha256:sha(f)};
  fs.writeFileSync(file.replace('-frame3.json','-frame2.json'),Buffer.concat([Buffer.from(JSON.stringify(h)+'\n'),b,c,f]));
  fs.rmSync(file,{force:true});const result=driver.readBaseCache(info);assert.ok(result.checkedPrefixState);assert.equal(result.preparedWorld,undefined);assert.equal(result.frontendReadyState,undefined);
});
check('present corrupt frame3 does not fall through to frame2',()=>assert.throws(()=>read(frame({...header,bookGraphSha256:'bad'}))));
// Preserve the JSON-frame tests above, then exercise the actual binary driver
// boundary. The raw arena decoder's scalar/UTF16 domain has separate controls.
const optionalKeys=['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'];
const arenaBytes=driver.encodeBaseCacheArenaFrame(initial),arenaCut=arenaBytes.indexOf(10),arenaHeader=JSON.parse(arenaBytes.subarray(0,arenaCut));
assert.equal(arenaHeader.format,'bend-base-cache-frame-4');
const arenaBook=arenaBytes.subarray(arenaCut+1,arenaCut+1+arenaHeader.segments[0]),arenaPrepared=arenaBytes.subarray(arenaCut+1+arenaHeader.segments[0]);
const arenaFile=file.replace('-frame3.json','-frame4.json'),arenaInfo={...info,file:arenaFile};
const packArena=(h=arenaHeader,b=arenaBook,p=arenaPrepared)=>Buffer.concat([Buffer.from(JSON.stringify({...h,segments:[b.length,p.length]})+'\n'),b,p]);
const readArena=(b=arenaBytes,memo=null)=>{fs.writeFileSync(arenaFile,b);return driver.readBaseCache(arenaInfo,memo);};
const noOptional=c=>{assert.ok(c.book);for(const k of optionalKeys)assert.equal(c[k],undefined);};
const optionalMutation=mutate=>{const p=Buffer.from(arenaPrepared);mutate(p);const hash=sha(p);return packArena({...arenaHeader,preparedGraphSha256:hash,checkedPrefixStateSha256:hash,freshPrefixStateSha256:hash},arenaBook,p);};
const mandatoryMutation=mutate=>{const b=Buffer.from(arenaBook);mutate(b);return packArena({...arenaHeader,bookGraphSha256:sha(b)},b);};
check('frame4 exact decoded roots and identity sharing',()=>{const c=full(readArena());for(const k of ['book',...optionalKeys])assert.deepEqual(c[k],initial[k],k);assert.equal(c.preparedWorld.prefix,c.book);assert.equal(c.preparedWorld.state,c.checkedPrefixState);});
for(const [key,value]of [['compilerSha256','bad'],['baseSha256','bad'],['sourcePath','/wrong/base.bend'],['sourceEnd',arenaHeader.sourceEnd+1],['sourceBegin',2],['version',99],['termAbi',99],['spanAbi',99],['validatedBy','not-checked']])check('frame4 reject header '+key,()=>assert.throws(()=>readArena(packArena({...arenaHeader,[key]:value}))));
check('frame4 reject mandatory digest',()=>assert.throws(()=>readArena(packArena({...arenaHeader,bookGraphSha256:'bad'}))));
check('frame4 reject mandatory binary magic with valid digest',()=>assert.throws(()=>readArena(mandatoryMutation(b=>b.writeUInt32LE(0,0)))));
check('frame4 reject mandatory null root with valid digest',()=>assert.throws(()=>readArena(mandatoryMutation(b=>b.writeUInt32LE(0xffffffff,32)))));
check('frame4 optional digest failure drops all capabilities',()=>noOptional(readArena(packArena({...arenaHeader,preparedGraphSha256:'bad'}))));
check('frame4 optional binary magic with valid digest drops all capabilities',()=>noOptional(readArena(optionalMutation(p=>p.writeUInt32LE(0,0)))));
check('frame4 optional forward reference with valid digest drops all capabilities',()=>{
 const bytes=optionalMutation(p=>{const bn=p.readUInt32LE(4),n=p.readUInt32LE(8),nr=p.readUInt32LE(28),world=p.readUInt32LE(40)-bn;assert(world>=0&&world<n);const offsetsAt=32+nr*4+((n+3)&~3),fieldsAt=offsetsAt+(n+1)*4,at=p.readUInt32LE(offsetsAt+world*4);p.writeUInt32LE(bn+n,fieldsAt+(at+4)*4);});noOptional(readArena(bytes));
});
check('frame4 constructor index rejects forward reference with valid digest',()=>{
 const bytes=optionalMutation(p=>{const bn=p.readUInt32LE(4),n=p.readUInt32LE(8),nr=p.readUInt32LE(28),world=p.readUInt32LE(40)-bn;assert(world>=0&&world<n);const offsetsAt=32+nr*4+((n+3)&~3),fieldsAt=offsetsAt+(n+1)*4,at=p.readUInt32LE(offsetsAt+world*4);assert.equal(p.readUInt32LE(offsetsAt+(world+1)*4)-at,9);p.writeUInt32LE(bn+n,fieldsAt+(at+8)*4);});noOptional(readArena(bytes));
});
check('frame4 constructor index rejects wrong term subtype with valid digest',()=>{
 const b=arenaBook,n=b.readUInt32LE(8),tags=32+b.readUInt32LE(28)*4;let id=0;while(id<n&&b[tags+id]!==2)id++;assert(id<n);
 const bytes=optionalMutation(p=>{const bn=p.readUInt32LE(4),n=p.readUInt32LE(8),nr=p.readUInt32LE(28),world=p.readUInt32LE(40)-bn,offsetsAt=32+nr*4+((n+3)&~3),fieldsAt=offsetsAt+(n+1)*4,at=p.readUInt32LE(offsetsAt+world*4);p.writeUInt32LE(id,fieldsAt+(at+8)*4);});noOptional(readArena(bytes));
});
check('frame4 mismatched prefix loses only world capability',()=>{const c=readArena(driver.encodeBaseCacheArenaFrame({...initial,preparedWorld:{...initial.preparedWorld,prefix:{$:'Nil'}}}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('frame4 mismatched checked state loses only world capability',()=>{const c=readArena(driver.encodeBaseCacheArenaFrame({...initial,preparedWorld:{...initial.preparedWorld,state:{...initial.checkedPrefixState,bound:(initial.checkedPrefixState.bound^1)>>>0}}}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
for(const version of [1,2,3])check('frame4 rejects old world version '+version,()=>{const c=readArena(packArena({...arenaHeader,preparedWorldVersion:version}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('frame4 bad state digest removes checked and world capability',()=>{const c=readArena(packArena({...arenaHeader,checkedPrefixStateSha256:'bad'}));assert.equal(c.checkedPrefixState,undefined);assert.equal(c.preparedWorld,undefined);assert.ok(c.frontendReadyState);});
check('frame4 null optional roots use ordinary checker',()=>noOptional(readArena(driver.encodeBaseCacheArenaFrame({...initial,...Object.fromEntries(optionalKeys.map(k=>[k,undefined]))}))));
check('frame4 memo same bytes shares frozen graph',()=>{const memo={entry:null},a=full(readArena(arenaBytes,memo)),b=full(driver.readBaseCache(arenaInfo,memo));assert.equal(a.book,b.book);assert.ok(Object.isFrozen(b.preparedWorld));assert.ok(Object.isFrozen(b.preparedWorld.constructorIndex));assert.throws(()=>{b.preparedWorld.constructorIndex.$='Nil';});assert.throws(()=>{b.preparedWorld.checkedBound=1;});});
check('frame4 changed bytes readmitted',()=>{const memo={entry:null},a=full(readArena(arenaBytes,memo)),b=full(readArena(packArena({...arenaHeader,generated:'different'}),memo));assert.notEqual(a.book,b.book);});
check('frame4 memo drops corrupt optional capability',()=>{const memo={entry:null};full(readArena(arenaBytes,memo));noOptional(readArena(packArena({...arenaHeader,preparedGraphSha256:'bad'}),memo));});
// Keep filename precedence explicit, including a present corrupt newer file.
const frame2File=file.replace('-frame3.json','-frame2.json'),frame1File=file.replace('-frame3.json','-frame1.json');
for(const f of [arenaFile,file,frame2File,frame1File])fs.rmSync(f,{force:true});
check('frame4 takes precedence over valid frame3',()=>{fs.writeFileSync(file,frame({...header,generated:'legacy3'}));const c=full(readArena(packArena({...arenaHeader,generated:'arena4'})));assert.equal(c.generated,'arena4');});
check('present corrupt frame4 does not fall through to valid frame3',()=>assert.throws(()=>readArena(packArena({...arenaHeader,bookGraphSha256:'bad'}))));
check('absent frame4 falls through to valid frame3',()=>{fs.rmSync(arenaFile);const c=full(driver.readBaseCache(arenaInfo));assert.equal(c.generated,'legacy3');});
check('memo transitions between frame3 and frame4',()=>{const memo={entry:null},a=full(driver.readBaseCache(arenaInfo,memo)),b=full(readArena(packArena({...arenaHeader,generated:'arena4'}),memo));assert.notEqual(a.book,b.book);assert.equal(b.generated,'arena4');fs.rmSync(arenaFile);const c=full(driver.readBaseCache(arenaInfo,memo));assert.equal(c.generated,'legacy3');assert.notEqual(c.book,b.book);});
check('present corrupt frame4 clears prior frame3 memo',()=>{const memo={entry:null};full(driver.readBaseCache(arenaInfo,memo));assert.throws(()=>readArena(packArena({...arenaHeader,bookGraphSha256:'bad'}),memo));assert.equal(memo.entry,null);fs.rmSync(arenaFile);});
const legacyBook=Buffer.from(JSON.stringify(initial.book)),legacyChecked=Buffer.from(JSON.stringify(initial.checkedPrefixState)),legacyFresh=Buffer.from(JSON.stringify(initial.freshPrefixState));
check('absent frame4 and frame3 fall through to frame2',()=>{fs.rmSync(file);const h={...header,format:'bend-base-cache-frame-2',generated:'legacy2',segments:[legacyBook.length,legacyChecked.length,legacyFresh.length],bookSha256:sha(legacyBook),checkedPrefixStateSha256:sha(legacyChecked),freshPrefixStateSha256:sha(legacyFresh)};fs.writeFileSync(frame2File,Buffer.concat([Buffer.from(JSON.stringify(h)+'\n'),legacyBook,legacyChecked,legacyFresh]));const c=driver.readBaseCache(arenaInfo);assert.equal(c.generated,'legacy2');assert.ok(c.checkedPrefixState);assert.equal(c.preparedWorld,undefined);});
check('absent frames4 through2 fall through to frame1',()=>{fs.rmSync(frame2File);const h={...header,format:'bend-base-cache-frame-1',generated:'legacy1',bookSha256:sha(legacyBook)};fs.writeFileSync(frame1File,Buffer.concat([Buffer.from(JSON.stringify(h)+'\n'),legacyBook]));const c=driver.readBaseCache(arenaInfo);assert.equal(c.generated,'legacy1');assert.ok(c.book);assert.equal(c.preparedWorld,undefined);});
check('present corrupt frame4 does not fall through to frame1',()=>assert.throws(()=>readArena(packArena({...arenaHeader,bookGraphSha256:'bad'}))));
check('all frames missing clears memo',()=>{fs.rmSync(arenaFile);const memo={entry:null};assert.ok(driver.readBaseCache(arenaInfo,memo));fs.rmSync(frame1File);assert.equal(driver.readBaseCache(arenaInfo,memo),null);assert.equal(memo.entry,null);});
assert.equal(sha(fs.readFileSync(driverFile)),sha(original),'driver unchanged');assert.equal(sha(fs.readFileSync(helperFile)),sha(helperBytes),'graph helper unchanged');assert.equal(sha(fs.readFileSync(cacheFile)),sha(inputBytes),'frame unchanged');assert.equal(sha(fs.readFileSync(baseFile)),info.baseSha256,'Base unchanged');assert.equal(sha(fs.readFileSync(import.meta.filename)),sha(controllerBytes),'controller unchanged');assert.equal(sha(fs.readFileSync(derivationFile)),sha(derivationBytes),'derivation unchanged');
const report={schema:'phase65-constructor-index-cache-controls-1',normalizedLegacyFrameSha256:sha(bytes),arenaFrameSha256:sha(arenaBytes),helper:{file:helperFile,sha256:sha(helperBytes)},controller:{file:import.meta.filename,sha256:sha(controllerBytes)},derivation:{file:derivationFile,sha256:sha(derivationBytes)},pass:true,controls,driver:{file:driverFile,sha256:sha(original)},instrumented:{file:instrumented,sha256:sha(source)},cache:{file:cacheFile,sha256:sha(inputBytes)},base:{file:baseFile,sha256:info.baseSha256},
  limits:['No compiler image execution: these are host transport/admission controls.','Copied driver differs only in pinned import/project locations and extra private readBaseCache and encoder exports.','Semantic constructor membership remains the trusted bound Bend producer obligation; a valid arbitrary KDef is not a proof of correct index contents.','Request-level edited-source and private-API permission behavior require separate compiler integration controls.']};
fs.writeFileSync(outputFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({pass:true,controls:controls.length}));
