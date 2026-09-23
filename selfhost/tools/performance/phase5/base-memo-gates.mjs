// P5-021 isolated correctness gates. Test-only exports never enter the host.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../development/workflow.mjs';

const [attemptArg,candidateArg,selectionArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('Usage: base-memo-gates.mjs ATTEMPT CANDIDATE_PROJECT SELECTION NEW_OUTPUT');
const attemptPath=fs.realpathSync(attemptArg),candidate=fs.realpathSync(candidateArg),selection=fs.realpathSync(selectionArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const inputs=new Map();
const capture=file=>{const canonicalPath=fs.realpathSync(file),row={file:canonicalPath,sha256:hash(fs.readFileSync(file))};inputs.set(canonicalPath,row);return row;};
const report={kind:'phase5-base-memo-correctness',complete:false,started:new Date().toISOString(),rows:[],contract:[],inputs:[],node:process.version};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};
save();
try {
  await verifyAttempt(attemptPath);
  const attempt=JSON.parse(fs.readFileSync(path.join(attemptPath,'attempt.json')));
  const apiFile=path.join(attemptPath,'api.mjs'),snapshot=path.join(attemptPath,'snapshot');
  const baseFile=path.join(snapshot,'dist/base.bend'),runtimeFile=path.join(snapshot,'src/runtime.mjs');
  for(const file of [import.meta.filename,selection,path.join(candidate,'preparation.json'),apiFile,baseFile,runtimeFile])capture(file);
  const control=path.join(out,'control');
  fs.mkdirSync(control);
  fs.cpSync(path.join(snapshot,'tools'),path.join(control,'tools'),{recursive:true});
  fs.mkdirSync(path.join(control,'build/typed'),{recursive:true});
  fs.cpSync(path.join(snapshot,'build/typed/cache'),path.join(control,'build/typed/cache'),{recursive:true});
  for(const project of [control,candidate])for(const name of ['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','native-build.mjs','assemble.mjs'])capture(path.join(project,'tools',name));
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  Object.assign(process.env,{BEND_TYPED_API:apiFile,BEND_BASE:baseFile,BEND_TYPED_RUNTIME:runtimeFile});
  const original=await import(pathToFileURL(path.join(control,'tools/typed-driver.mjs')));
  const changed=await import(pathToFileURL(path.join(candidate,'tools/typed-driver.mjs')));
  const api=await original.loadApi(),inspector=await changed.createPersistentInspector();
  const cases=JSON.parse(fs.readFileSync(selection)).map(row=>({...row,file:fs.realpathSync(path.resolve(path.dirname(selection),row.file))}));
  for(const test of cases)capture(test.file);
  for(const order of [cases,[...cases].reverse()])for(const test of order)for(const mode of ['parse','check']) {
    const expected=await original.inspect(test.file,{api,mode}),observed=await inspector.inspect(test.file,{mode});
    assert.deepEqual(observed,expected,test.id+' '+mode);
    for(const file of expected.files??[])capture(file);
    report.rows.push({id:test.id,mode,expected,observed});save();
  }
  assert.throws(()=>inspector.inspect(cases[0].file,{mode:'interpreter'}),/only parse\/check/);
  const supplied={f_load_graph_seed(){throw Error('caller supplied API was used');}};
  assert.deepEqual(await inspector.inspect(cases[0].file,{mode:'check',api:supplied}),await original.inspect(cases[0].file,{mode:'check',api}));
  const recycled=await changed.createPersistentInspector();
  assert.deepEqual(await recycled.inspect(cases[0].file,{mode:'check'}),await inspector.inspect(cases[0].file,{mode:'check'}));
  report.contract.push({name:'private API, lane boundary, recycled session',pass:true});

  // Copy the actual candidate for direct adversarial cache-contract tests.
  const testProject=path.join(out,'contract-project');
  fs.mkdirSync(testProject);fs.cpSync(path.join(candidate,'tools'),path.join(testProject,'tools'),{recursive:true});
  const testDriver=path.join(testProject,'tools/typed-driver.mjs');
  fs.appendFileSync(testDriver,'\nexport {readBaseCache as p5ReadBaseCache,baseCacheInfo as p5BaseCacheInfo};\n');capture(testDriver);
  const testHost=await import(pathToFileURL(testDriver));
  const info=testHost.p5BaseCacheInfo(api);
  const originalCache=path.join(candidate,'build/typed/cache',path.basename(info.file));capture(originalCache);
  const bytes=fs.readFileSync(originalCache),cached=JSON.parse(bytes);
  fs.mkdirSync(path.dirname(info.file),{recursive:true});
  const memo={entry:null};
  const write=value=>fs.writeFileSync(info.file,value);
  const read=()=>testHost.p5ReadBaseCache(info,memo);
  const cold=()=>testHost.p5ReadBaseCache(info);
  write(bytes);
  const first=read(),firstEntry=memo.entry;
  assert.ok(first);assert.ok(Object.isFrozen(first.book));assert.ok(Object.isFrozen(first.book.head));
  assert.throws(()=>{first.book.head.name='poison';},TypeError);
  assert.deepEqual(read(),cold());assert.equal(memo.entry,firstEntry);
  report.contract.push({name:'verified hit reuses immutable book',pass:true});
  const metadata=fs.statSync(info.file);
  for(const [name,transform] of [
    ['wrong version',x=>({...x,version:x.version+1})],
    ['wrong compiler',x=>({...x,compilerSha256:'0'.repeat(64)})],
    ['wrong Base',x=>({...x,baseSha256:'0'.repeat(64)})],
    ['wrong canonical source',x=>({...x,sourcePath:x.sourcePath+'x'})],
    ['unvalidated',x=>({...x,validatedBy:'not-check_book'})],
    ['wrong book digest',x=>({...x,bookSha256:'0'.repeat(64)})],
    ['same-size book tamper',x=>({...x,book:{...x.book,head:{...x.book.head,name:x.book.head.name.replace(/./,'?')}}})],
  ]) {
    write(bytes);assert.ok(read());
    const replacement=Buffer.from(JSON.stringify(transform(cached)));write(replacement);fs.utimesSync(info.file,metadata.atime,metadata.mtime);
    assert.equal(read(),null,name);assert.equal(cold(),null,name);assert.equal(memo.entry,null,name);
    report.contract.push({name,pass:true,originalBytes:bytes.length,replacementBytes:replacement.length,mtimeRestored:true});
    write(bytes);assert.ok(read());
  }
  for(const [name,replacement] of [['malformed','{'],['missing',null]]) {
    write(bytes);assert.ok(read());
    if(replacement===null)fs.unlinkSync(info.file);else write(replacement);
    assert.equal(read(),null);assert.equal(cold(),null);assert.equal(memo.entry,null);
    write(bytes);assert.ok(read());report.contract.push({name,pass:true});
  }
  const previous=memo.entry;
  write(Buffer.concat([bytes,Buffer.from(' ')]));assert.deepEqual(read(),cold());assert.notEqual(memo.entry,previous);
  report.contract.push({name:'changed but valid bytes decoded anew',pass:true});
  const savedInfo={...info};
  info.sourcePath+='-different';assert.equal(read(),null);assert.equal(memo.entry,null);Object.assign(info,savedInfo);
  write(bytes);assert.ok(read());
  assert.deepEqual(Object.keys(memo),['entry']);
  report.contract.push({name:'expected identity drift invalidates single entry',pass:true});

  // A real session checks API identity, including same-path replacement after
  // an ordinary import and before creation. Only private copies are modified.
  const mutableApi=path.join(out,'mutable-api.mjs');fs.copyFileSync(apiFile,mutableApi);
  process.env.BEND_TYPED_API=mutableApi;
  const driftProject=path.join(out,'drift-project');fs.mkdirSync(driftProject);fs.cpSync(path.join(candidate,'tools'),path.join(driftProject,'tools'),{recursive:true});
  const drift=await import(pathToFileURL(path.join(driftProject,'tools/typed-driver.mjs')));
  const initialApi=await drift.loadApi();
  const session=await drift.createPersistentInspector();
  fs.appendFileSync(mutableApi,'\n// test API identity replacement\n');
  const refusal=await session.inspect(cases[0].file,{mode:'parse'});
  assert.equal(refusal.status,'error');assert.match(refusal.diagnostic,/Compiler API changed/);
  // New content identity must cause a new Node module instance, never an older
  // cached module under a newly hashed file. A harmless marker is observable.
  fs.writeFileSync(mutableApi,"export default {f_load_graph_seed(){return {error:'fresh module marker'}},f_parse(){return {error:'fresh module marker'}}};\n");
  const newSession=await drift.createPersistentInspector();
  const fresh=await newSession.inspect(cases[0].file,{mode:'parse'});
  assert.match(fresh.diagnostic,/fresh module marker/);
  assert.ok(initialApi.f_parse);
  report.contract.push({name:'live API drift refused; new session imports current content',pass:true});
  const sameEntry="import marker from './marker.mjs'; export default {f_load_graph_seed(){return {error:marker}},f_parse(){return {error:marker}}};\n";
  for(const name of ['first-location','second-location']) {
    const directory=path.join(out,name);fs.mkdirSync(directory);
    fs.writeFileSync(path.join(directory,'api.mjs'),sameEntry);
    fs.writeFileSync(path.join(directory,'marker.mjs'),'export default '+JSON.stringify(name)+';\n');
  }
  fs.unlinkSync(mutableApi);fs.symlinkSync(path.join(out,'first-location/api.mjs'),mutableApi);
  const firstLocation=await drift.createPersistentInspector();
  assert.match((await firstLocation.inspect(cases[0].file,{mode:'parse'})).diagnostic,/first-location/);
  fs.unlinkSync(mutableApi);fs.symlinkSync(path.join(out,'second-location/api.mjs'),mutableApi);
  assert.match((await firstLocation.inspect(cases[0].file,{mode:'parse'})).diagnostic,/Compiler API changed/);
  const secondLocation=await drift.createPersistentInspector();
  assert.match((await secondLocation.inspect(cases[0].file,{mode:'parse'})).diagnostic,/second-location/);
  report.contract.push({name:'identical API bytes at changed canonical location import current relative dependency',pass:true});
  for(const row of inputs.values())assert.equal(hash(fs.readFileSync(row.file)),row.sha256,'Input drift '+row.file);
  await verifyAttempt(attemptPath);
  report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,observations:report.rows.length,contract:report.contract.length,error:report.error}));
