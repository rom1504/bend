#!/usr/bin/env node
// Focused semantic witnesses; this is not an exact-diagnostic or full-suite gate.
// Run with an explicitly selected checked BEND_TYPED_API. Artifact/source hashes
// and the live pinned upstream result are retained in a new report file.
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {performance} from 'node:perf_hooks';

const output=path.resolve(process.argv[2]||'');
if(!process.argv[2]||fs.existsSync(output))throw Error('Usage: BEND_TYPED_API=CHECKED_API node phase2-rules.mjs NEW_REPORT.json');
if(!process.env.BEND_TYPED_API)throw Error('Explicit BEND_TYPED_API required');
const project=path.resolve(import.meta.dirname,'../..');
const upstream=path.resolve(process.env.BEND_UPSTREAM||path.join(project,'.bootstrap/upstream'));
const pin='6018e28ecc67cf1fffc0c20c64b11023474c2df8';
function checkedGit(args) {
  const directory=fs.mkdtempSync(path.join(os.tmpdir(),'bend-frontend-git-'));
  const stdout=path.join(directory,'stdout'),stderr=path.join(directory,'stderr');
  const a=fs.openSync(stdout,'wx'),b=fs.openSync(stderr,'wx');
  try {
    const result=spawnSync('git',['-C',upstream,...args],{timeout:30000,stdio:['ignore',a,b]});
    if(fs.statSync(stdout).size>2**20||fs.statSync(stderr).size>2**20)throw Error('Upstream Git output exceeded 1 MiB');
    const text=fs.readFileSync(stdout,'utf8'),error=fs.readFileSync(stderr,'utf8');
    if(result.error||result.signal||result.status!==0)
      throw Error('Upstream Git verification failed: '+(result.error?.message||result.signal||`status ${result.status}: ${error}`));
    return text.trim();
  } finally {fs.closeSync(a);fs.closeSync(b);fs.rmSync(directory,{recursive:true,force:true});}
}
function verifyUpstream() {
  const revision=checkedGit(['rev-parse','HEAD']);
  if(revision!==pin)throw Error('Unexpected upstream revision '+revision);
  if(checkedGit(['status','--porcelain','--untracked-files=no']))throw Error('Upstream tracked checkout differs from pinned HEAD');
  return {revision,trackedClean:true};
}
const upstreamBefore=verifyUpstream(),revision=upstreamBefore.revision;
const B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
const driver=await import('../../tools/typed-driver.mjs');
const api=await driver.loadApi();
const casesDir=path.join(import.meta.dirname,'phase2-rules');
const cases=JSON.parse(fs.readFileSync(path.join(casesDir,'cases.json'),'utf8'));
const hash=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const artifact={api:path.resolve(process.env.BEND_TYPED_API),apiSha256:hash(process.env.BEND_TYPED_API),
  bootstrapReportSha256:hash(process.env.BEND_TYPED_API+'.bootstrap.json'),
  runtimeSha256:hash(driver.runtimePath),driverSha256:hash(driver.driverPath),
  upstreamBendSha256:hash(path.join(upstream,'bend2/bend.ts')),upstreamCompSha256:hash(path.join(upstream,'bend2/comp.ts'))};
const build=JSON.parse(fs.readFileSync(process.env.BEND_TYPED_API+'.bootstrap.json','utf8'));
if(build.apiSha256!==artifact.apiSha256||build.revision!==pin)throw Error('Bootstrap report does not identify selected API');
if(hash(build.source)!==build.sourceSha256||!build.modules?.length)throw Error('Missing or changed checked compiler source');
for(const entry of build.modules){
  if(hash(path.join(path.dirname(build.source),entry.file))!==entry.sha256)throw Error('Changed checked compiler module: '+entry.file);
}
const immutable=[artifact.api,artifact.api+'.bootstrap.json',build.source,driver.runtimePath,driver.driverPath,
  path.join(upstream,'bend2/bend.ts'),path.join(upstream,'bend2/comp.ts'),path.join(upstream,'bend2/base.bend')]
  .map(file=>({file,sha256:hash(file)}));
artifact.checkedSource={file:build.source,sha256:build.sourceSha256};
const report={schemaVersion:1,upstreamVerification:{before:upstreamBefore},purpose:'Focused frontend acceptance and rejection-phase regression witnesses',revision,
  started:new Date().toISOString(),node:process.version,execArgv:process.execArgv,artifact,results:[]};
for(const test of cases){
  const file=path.join(casesDir,test.file),sourceSha256=hash(file);
  let phase='parse',reference;
  const before=performance.now();
  try{
    const book=B.book_nil();await B.book_load(book,file,'',new Map());
    phase='check';B.book_valid(book);C.book_owned(book,C.SYNTH);
    if(book.hols+book.open)throw Error('Unresolved laws/holes: '+(book.hols+book.open));
    reference={status:'ok',phase,checked:true};
  }catch(error){reference={status:'error',phase,checked:phase==='check',diagnostic:error?.$==='Err'?B.err_show(error):String(error)};}
  reference.ms=performance.now()-before;
  const start=performance.now(),candidate=await driver.inspect(file,{mode:'check',api,timeoutMs:120000});
  candidate.ms=performance.now()-start;
  const expected=r=>test.accept?r.status==='ok':r.status==='error'&&r.phase===test.rejectPhase;
  const row={...test,file,source:fs.readFileSync(file,'utf8'),sourceSha256,reference,candidate,referenceMatches:expected(reference),candidateMatches:expected(candidate)};
  if(sourceSha256!==hash(file)||artifact.apiSha256!==hash(artifact.api))throw Error('Inputs changed during test');
  report.results.push(row);fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
  console.log(`${test.id}: reference=${reference.status}/${reference.phase} candidate=${candidate.status}/${candidate.phase}`);
}
report.upstreamVerification.after=verifyUpstream();
report.finished=new Date().toISOString();
report.changedArtifacts=immutable.filter(entry=>hash(entry.file)!==entry.sha256);
report.pass=report.results.every(r=>r.referenceMatches&&r.candidateMatches);
if(report.changedArtifacts.length)report.pass=false;
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
if(!report.pass)process.exitCode=1;
