// Measure the actual documented bootstrap + phase2-rules commands, not a substitute compiler loop.
import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
const [launchArg,outputArg]=process.argv.slice(2);
if(!outputArg)throw Error('usage: development-final.mjs COMBINED_LAUNCH.json NEW_DIRECTORY');
const root=path.resolve(import.meta.dirname,'../../..'),out=path.resolve(outputArg);fs.mkdirSync(out,{recursive:false});
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const identity=file=>({file:path.resolve(file),canonicalPath:fs.realpathSync(file),sha256:sha(file)});
const inputs=new Map(),capture=file=>{const r=identity(file);inputs.set(r.file,r);return r.file;};
const verify=()=>{for(const r of inputs.values())assert.deepEqual(identity(r.file),r,'Input changed: '+r.file);};
const report={kind:'phase4-normal-development-loop',complete:false,started:new Date().toISOString(),cpu:0,node:{file:process.execPath,version:process.version,parentArgs:process.execArgv,childArgs:['--stack-size=4096','--max-old-space-size=4096']},rows:[]};
const flush=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
const start=performance.now();
async function command(label,args,env,timeoutMs=180000) {
 const stdout=path.join(out,label+'.stdout'),stderr=path.join(out,label+'.stderr');const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx'),before=performance.now();
 try{return await new Promise(resolve=>{
  let timedOut=false,error;const child=spawn('taskset',['-c','0',process.execPath,...report.node.childArgs,...args],{env,detached:true,stdio:['ignore',a,b]});
  const timer=setTimeout(()=>{timedOut=true;try{process.kill(-child.pid,'SIGKILL');}catch{child.kill('SIGKILL');}},timeoutMs);
  child.on('error',e=>{error=e.message;});child.on('close',(status,signal)=>{clearTimeout(timer);resolve({args:['taskset','-c','0',process.execPath,...report.node.childArgs,...args],status,signal,error,timedOut,processWallMs:performance.now()-before,stdout,stderr});});
 });}finally{fs.closeSync(a);fs.closeSync(b);}
}
function successful(row){assert.equal(row.error,undefined);assert.equal(row.timedOut,false);assert.equal(row.signal,null);assert.equal(row.status,0,'Command failed: '+row.stderr);capture(row.stdout);capture(row.stderr);}
function observation(value){const result=structuredClone(value);delete result.ms;return result;}
try {
 const launch=JSON.parse(fs.readFileSync(capture(launchArg)));capture(import.meta.filename);capture(process.execPath);capture(launch.checked);
 const checked=JSON.parse(fs.readFileSync(launch.checked));assert.equal(checked.kind,'phase4-checked-overlay');assert.equal(checked.complete,true);assert.equal(checked.inputsUnchanged,true);
 assert.deepEqual(identity(launch.source.file),launch.source);assert.deepEqual(identity(launch.api.file),launch.api);capture(launch.source.file);capture(launch.api.file);
 const upstream=checked.upstream.path,base=fs.realpathSync(launch.base),runtime=capture(path.join(root,'src/runtime.mjs'));
 assert.equal(sha(runtime),sha(launch.runtime));capture(base);
 const runner=capture(path.join(root,'tests/frontend/phase2-rules.mjs')),driver=capture(path.join(root,'tools/typed-driver.mjs'));
 for(const name of ['stage0-library.mjs','assemble.mjs','compiler-abi.mjs','native-build.mjs','node-resource-args.mjs'])capture(path.join(root,'tools',name));
 const casesFile=capture(path.join(root,'tests/frontend/phase2-rules/cases.json'));for(const c of JSON.parse(fs.readFileSync(casesFile)))capture(path.join(path.dirname(casesFile),c.file));
 const api=path.join(out,'api.mjs'),env={...process.env,BEND_TYPED_API:api,BEND_TYPED_RUNTIME:runtime,BEND_BASE:base,BEND_UPSTREAM:upstream};delete env.NODE_OPTIONS;delete env.BEND_TYPED_TRACE;
 report.environment={BEND_TYPED_API:api,BEND_TYPED_RUNTIME:runtime,BEND_BASE:base,BEND_UPSTREAM:upstream,NODE_OPTIONS:'removed',BEND_TYPED_TRACE:'removed'};
 report.scope='Actual typed-driver --bootstrap followed by actual phase2-rules CLI, one cold compiler-side Base-cache process then three warm-cache fresh processes. No persistent compiler process; OS caches are not flushed. Both live TS and checked Bend results are measured. Normal bootstrap stage0 child uses its existing default Node flags; parent flags are not claimed to propagate.';
 report.bootstrap=await command('bootstrap',[driver,'--bootstrap'],env);flush();successful(report.bootstrap);
 const bootstrapFile=capture(api+'.bootstrap.json'),build=JSON.parse(fs.readFileSync(bootstrapFile));capture(api);
 assert.equal(build.stage,'upstream-bootstrap');assert.equal(build.revision,checked.upstream.pin);assert.equal(build.provenance.verifiedAfterBuild,true);assert.equal(build.apiSha256,sha(api));assert.equal(build.sourceSha256,launch.source.sha256);assert.equal(build.exports.length,54);assert.equal(new Set(build.exports).size,54);capture(build.source);
 for(const m of build.modules){const file=path.join(path.dirname(build.source),m.file);assert.equal(sha(file),m.sha256);capture(file);}
 for(const r of build.provenance.inputs){assert.equal(sha(r.file),r.sha256);capture(r.file);}
 report.source=identity(build.source);report.api=identity(api);report.bootstrapReport=identity(bootstrapFile);report.exports=build.exports;
 const baseHash=sha(base),location=crypto.createHash('sha256').update(base).digest('hex');const cache=path.join(root,'build/typed/cache',`base-${build.apiSha256}-${baseHash}-${location}.json`);
 report.baseCache={file:cache,initiallyAbsent:!fs.existsSync(cache)};assert.equal(report.baseCache.initiallyAbsent,true,'A true cold Base-cache run requires a new API cache key');flush();
 let expected;
 for(let run=0;run<4;run++) {
  verify();const resultFile=path.join(out,`rules-${run}.json`);const row={run,cache:run===0?'cold':'warm',cachePresentBefore:fs.existsSync(cache),resultFile,process:await command('rules-'+run,[runner,resultFile],env)};report.rows.push(row);flush();successful(row.process);capture(resultFile);
  const result=JSON.parse(fs.readFileSync(resultFile));assert.equal(result.pass,true);assert.equal(result.results.length,21);assert.equal(result.changedArtifacts.length,0);
  row.pass=true;row.innerReferenceMs=result.results.reduce((s,r)=>s+r.reference.ms,0);row.innerCandidateMs=result.results.reduce((s,r)=>s+r.candidate.ms,0);row.innerObservationMs=row.innerReferenceMs+row.innerCandidateMs;
  const observations=result.results.map(r=>({id:r.id,reference:observation(r.reference),candidate:observation(r.candidate)}));if(!expected)expected=observations;assert.deepEqual(observations,expected);row.exactObservationsAcrossRuns=true;
  const cached=JSON.parse(fs.readFileSync(cache));assert.equal(cached.compilerSha256,build.apiSha256);assert.equal(cached.baseSha256,baseHash);assert.equal(cached.sourcePath,base);assert.equal(cached.validatedBy,'check_book');assert.equal(cached.bookSha256,crypto.createHash('sha256').update(JSON.stringify(cached.book)).digest('hex'));row.cache=run===0?'cold':'warm';row.cacheAfter=identity(cache);flush();
 }
 report.coldBuildAndValidationProcessMs=report.bootstrap.processWallMs+report.rows[0].process.processWallMs;
 const historicalFile=path.resolve(root,'../implementation/phase3/evidence/cold-edit-loop.json');if(fs.existsSync(historicalFile)){
  capture(historicalFile);const historical=JSON.parse(fs.readFileSync(historicalFile));const rows=historical.results??historical.rows;assert.equal(rows.length,21);
  report.historical={report:identity(historicalFile),scope:'Exact individual reference/candidate observations excluding ms; distinct source/build/timing workflow, so no speedup ratio.',deltas:[]};
  for(const row of expected){const old=rows.find(x=>x.id===row.id);assert.ok(old);for(const variant of ['reference','candidate'])if(JSON.stringify(observation(old[variant]))!==JSON.stringify(row[variant]))report.historical.deltas.push({id:row.id,variant,old:observation(old[variant]),current:row[variant]});}
  report.historical.exact=report.historical.deltas.length===0;
 }
 verify();report.inputsUnchanged=true;report.complete=true;
}catch(error){report.error=error.stack||String(error);process.exitCode=1;}
report.toolWallMs=performance.now()-start;report.finished=new Date().toISOString();flush();console.log(JSON.stringify({complete:report.complete,bootstrapMs:report.bootstrap?.processWallMs,rows:report.rows.map(r=>({run:r.run,cache:r.cache,wallMs:r.process.processWallMs,innerMs:r.innerObservationMs,pass:r.pass})),error:report.error}));
