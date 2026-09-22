// Independent complete raw-observation, verdict, replay and provenance audit.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {gzipSync} from 'node:zlib';
import {pathToFileURL} from 'node:url';
const [finalArg,previousArg,outputArg]=process.argv.slice(2);
if(!outputArg)throw Error('Usage: private-frontend-audit.mjs FINAL_DIRECTORY PREVIOUS_DIRECTORY NEW_ARCHIVE');
const out=path.resolve(outputArg);fs.mkdirSync(out);fs.mkdirSync(path.join(out,'objects'));
const sha=b=>createHash('sha256').update(b).digest('hex'),captured=new Map(),objects=new Map();
function capture(file,expected,archive=true){file=path.resolve(file);const bytes=fs.readFileSync(file),actual=sha(bytes),canonicalPath=fs.realpathSync(file);if(expected)assert.equal(actual,expected,file);if(captured.has(file))assert.deepEqual(captured.get(file),{file,canonicalPath,sha256:actual,bytes:bytes.length});else captured.set(file,{file,canonicalPath,sha256:actual,bytes:bytes.length});if(archive&&!objects.has(actual)){const compressed=gzipSync(bytes,{level:9,mtime:0});fs.writeFileSync(path.join(out,'objects',actual+'.gz'),compressed);objects.set(actual,{object:'objects/'+actual+'.gz',sha256:actual,bytes:bytes.length,gzipSha256:sha(compressed),gzipBytes:compressed.length});}return bytes;}
function read(file){return JSON.parse(capture(file));}
function verify(i,archive=false){capture(i.file,i.sha256,archive);if(i.canonicalPath)assert.equal(fs.realpathSync(i.file),i.canonicalPath);}
const result={kind:'phase4-private-final-frontend-audit',complete:false,started:new Date().toISOString(),scope:'All pinned parse/check raw results and verdicts; this is behavior preservation, not full-language conformance or paired timing.'};
try{
 capture(import.meta.filename);const dirs=[finalArg,previousArg].map(p=>fs.realpathSync(p)),executions=dirs.map(d=>read(path.join(d,'execution.json'))),reports=[];
 for(let di=0;di<dirs.length;di++){
  const e=executions[di];assert.equal(e.complete,true);assert.equal(e.rows.length,2);
  for(const [file,i]of Object.entries(e.identities))verify({file,...i},!file.endsWith('/node')&&!file.endsWith('/api.mjs')&&!file.endsWith('/image.mjs'));
  const group=[];
  for(const row of e.rows){
   assert.equal(row.signal,null);assert.equal(row.timedOut,false);assert.equal(row.observationsComplete,true);assert.ok([0,1].includes(row.status));capture(row.report,row.reportSha256);
   const r=read(row.report);assert.equal(r.results.length,2756);assert.equal(r.inventory.total,1378);assert.equal(r.inventory.revision,'6018e28ecc67cf1fffc0c20c64b11023474c2df8');assert.deepEqual(r.changedInputs,[]);assert.deepEqual(r.identity.changedArtifacts,[]);assert.equal(r.identity.adapterChangedDuringRun,false);assert.deepEqual(r.summary,row.summary);
   for(const w of r.workers){assert.deepEqual(w.errors,[]);assert.equal(w.stats.timeouts,0);assert.equal(w.stats.failures,0);}
   capture(r.options.adapter,r.identity.adapterSha256);assert.equal(r.identity.finalAdapterSha256,r.identity.adapterSha256);
   for(const i of Object.values(r.identity.artifacts))verify(i,!['compiler'].some(k=>i===r.identity.artifacts[k]));
   for(const [file,hash]of Object.entries(r.inputHashes)){capture(file,hash,false);assert.equal(fs.realpathSync(file),r.inputPaths[file]);}
   const keys=new Set(),sessions=new Map();
   for(const z of r.results){const key=z.id+'::'+z.lane;assert.ok(!keys.has(key));keys.add(key);assert.ok(['parse','check'].includes(z.lane));assert.ok(!['timeout','crash','unsupported'].includes(z.result?.status));assert.ok(!['timeout','crash','unsupported'].includes(z.status));const list=sessions.get(z.worker.session)||[];list.push(z);sessions.set(z.worker.session,list);}
   const replay=await import(pathToFileURL(path.join(dirs[di],'harness/tools/conformance/persistent-probe.mjs')));
   for(const [file,rows]of sessions){const s=read(file);assert.equal(s.closed,true);assert.equal(s.requests.length,rows.length);rows.sort((a,b)=>a.worker.index-b.worker.index);for(let j=0;j<rows.length;j++){const z=rows[j],q=s.requests[j];assert.equal(z.worker.index,j);assert.equal(q.request.test.id,z.id);assert.equal(q.request.lane,z.lane);assert.equal(q.resultDigest,sha(JSON.stringify(z.result)));}const n=s.requests.length-1;assert.equal(replay.validatePersistentReplay({...s.requests[n].request,workerSession:{file,index:n,prefixDigest:s.requests[n].prefixDigest}},s,r.host.workerNodeArgs),n);}
   group.push({report:r,identity:captured.get(path.resolve(row.report)),sessions:sessions.size,wallMs:row.wallMs});
  }reports.push(group);
 }
 const [fresh,old]=reports,changes=[];
 for(let i=0;i<2;i++){
  const a=fresh[i].report,b=old[i].report;assert.deepEqual(a.inventory,b.inventory);assert.deepEqual(a.inputHashes,b.inputHashes);assert.deepEqual(a.inputPaths,b.inputPaths);
  const common=Object.keys(a.identity.artifacts).filter(k=>k!=='compiler');for(const k of common)assert.equal(a.identity.artifacts[k].sha256,b.identity.artifacts[k].sha256,'Shared artifact '+k);
  const map=new Map(b.results.map(z=>[z.id+'::'+z.lane,z]));
  for(const z of a.results){const p=map.get(z.id+'::'+z.lane);assert.ok(p);for(const f of ['result','status','reason','evidence'])if(JSON.stringify(z[f])!==JSON.stringify(p[f]))changes.push({variant:i===0?'typescript':'bend',id:z.id,lane:z.lane,field:f,before:p[f],after:z[f]});}
 }
 const image=executions[0].config.variants.find(v=>v.kind==='bend'),m=read(image.provenance);assert.equal(m.complete,true);assert.equal(m.proofStatus,'fixedpoint');assert.equal(m.optimizationProfile,'phase4-boolean-stable');verify(m.proof);verify(m.proof.selectedApi);verify(m.proof.initialCompiler);verify(m.proof.source);verify(m.base);verify(m.runtime);
 assert.equal(fresh[1].report.identity.artifacts.compiler.sha256,'4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3');
 assert.equal(old[1].report.identity.artifacts.compiler.sha256,m.proof.initialCompiler.sha256);
 assert.equal(m.proof.selectedApi.sha256,'b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8');
 const proof=read(m.proof.file);assert.equal(proof.complete,true);assert.equal(proof.stages.length,2);for(const stage of proof.stages){assert.equal(stage.code,0);assert.equal(stage.signal,null);assert.equal(stage.inputsVerified,true);capture(stage.output,stage.outputSha256,false);assert.equal(stage.outputSha256,m.proof.selectedApi.sha256);}
 for(const a of m.artifacts){const f=path.resolve(path.dirname(image.provenance),a.relative);assert.ok(f.startsWith(path.dirname(image.provenance)+'/'));assert.equal(capture(f,a.sha256,false).length,a.bytes);}
 for(const i of [...m.inputs,...m.tools])verify(i,false);
 result.rawResultAndVerdictChanges=changes;result.behaviorPreserved=changes.length===0;assert.equal(changes.length,0);
 result.fixtureCount=1378;result.probeCountPerRun=2756;result.verifiedRuns=reports.flat().map(x=>({identity:x.identity,sessions:x.sessions,summary:x.report.summary,fullConformance:x.report.complete,workflowWallMs:x.wallMs}));result.publicH=m.proof;result.profile=m.optimizationProfile;result.completedPublicProofVerified=true;result.workerReplayHistoriesVerified=true;
 for(const i of captured.values()){assert.equal(fs.realpathSync(i.file),i.canonicalPath);assert.equal(sha(fs.readFileSync(i.file)),i.sha256);}
 result.inputsUnchanged=true;result.complete=true;
}catch(e){result.error=String(e.stack);process.exitCode=1;}
result.finished=new Date().toISOString();result.inputs=[...captured.values()];result.objects=[...objects.values()];result.gzipBytes=result.objects.reduce((n,x)=>n+x.gzipBytes,0);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({complete:result.complete,error:result.error,gzipBytes:result.gzipBytes,changes:result.rawResultAndVerdictChanges?.length}));
