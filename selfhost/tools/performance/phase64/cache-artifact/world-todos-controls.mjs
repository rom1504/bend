#!/usr/bin/env node
// Exercise the real private admission functions through an export-only driver
// copy. No compiler image is imported; original source/cache files are untouched.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL,fileURLToPath} from 'node:url';

const [driverFile,cacheFile,baseFile,outputFile]=process.argv.slice(2).map(x=>path.resolve(x));
if(!outputFile)throw Error('Usage: world-todos-controls.mjs DRIVER FRAME3 BASE OUTPUT.json');
const directory=path.dirname(outputFile);fs.mkdirSync(directory,{recursive:true});
const sandbox=path.join(directory,'admission-scratch');fs.mkdirSync(sandbox,{recursive:false});
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const original=fs.readFileSync(driverFile,'utf8'),project=path.resolve(path.dirname(driverFile),'..');
assert.equal(original.split("export const project=path.resolve(import.meta.dirname,'..');").length,2);
let source=original.replace("export const project=path.resolve(import.meta.dirname,'..');",`export const project=${JSON.stringify(project)};`);
source=source.replace(/from '(\.\/[^']+)'/g,(_,name)=>`from '${pathToFileURL(path.resolve(path.dirname(driverFile),name)).href}'`);
source+='\nexport {readBaseCache};\n';
const instrumented=path.join(sandbox,'admission-driver.mjs');fs.writeFileSync(instrumented,source,{flag:'wx'});
const driver=await import(pathToFileURL(instrumented));
const bytes=fs.readFileSync(cacheFile),cut=bytes.indexOf(10),header=JSON.parse(bytes.subarray(0,cut));
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
check('world version2 unsigned fact admitted',()=>{const c=full(read());assert.equal(header.preparedWorldVersion,2);assert.ok(Number.isSafeInteger(c.preparedWorld.todos)&&c.preparedWorld.todos>=0&&c.preparedWorld.todos<=0xffffffff);});
for(const [key,value] of [['compilerSha256','bad'],['baseSha256','bad'],['sourcePath','/wrong/base.bend'],['sourceEnd',header.sourceEnd+1],['sourceBegin',2],['version',99],['termAbi',99],['spanAbi',99],['validatedBy','not-checked']])
  check('reject header '+key,()=>assert.throws(()=>read(frame({...header,[key]:value}))));
check('reject mandatory digest mismatch',()=>assert.throws(()=>read(frame({...header,bookGraphSha256:'bad'}))));
const editPrepared=edit=>{
  const wire=JSON.parse(preparedBytes);edit(wire);const p=Buffer.from(JSON.stringify(wire)),hash=sha(p);
  return frame({...header,preparedGraphSha256:hash,checkedPrefixStateSha256:hash,freshPrefixStateSha256:hash},bookBytes,p);
};
check('world version1 capability rejected',()=>{const c=read(frame({...header,preparedWorldVersion:1}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
check('legacy world missing TODO fact rejected by version2 host',()=>{const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,8);row.pop();}));assert.equal(c.preparedWorld,undefined);assert.ok(c.checkedPrefixState);assert.ok(c.frontendReadyState);});
for(const value of [-1,0.5,4294967296,'0',{},null])check('malformed TODO fact '+JSON.stringify(value),()=>{
  const c=read(editPrepared(w=>{const row=w[3][w[2][2]-w[1]];assert.equal(row.length,8);row[7]=value;}));
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
const report={schema:'phase64-cache-todos-admission-controls-1',pass:true,controls,driver:{file:driverFile,sha256:sha(original)},instrumented:{file:instrumented,sha256:sha(source)},cache:{file:cacheFile,sha256:sha(bytes)},base:{file:baseFile,sha256:info.baseSha256},
  limits:['No compiler image execution: these are host transport/admission controls.','Copied driver differs only in pinned import/project locations and extra private readBaseCache export.','Semantic world/index correctness remains the trusted bound producer obligation.','Request-level edited-source and private-API permission behavior require separate compiler integration controls.']};
fs.writeFileSync(outputFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({pass:true,controls:controls.length}));
