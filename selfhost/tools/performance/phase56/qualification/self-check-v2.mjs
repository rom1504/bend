// Root-supervised fresh check of the complete source through its real B2 image.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {setup} from '../bootstrap/setup-v2.mjs';
import {identity,verify} from '../../phase54/bootstrap/adapter.mjs';

const [pinsFile,outArgument]=process.argv.slice(2);
assert(pinsFile&&outArgument,'self-check.mjs B2_IMAGE_PINS NEW_DIRECTORY');
const out=path.resolve(outArgument);
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const started=performance.now(),progressFile=path.join(out,'progress.jsonl');
fs.writeFileSync(progressFile,'',{flag:'wx'});
let sequence=0;
const progress=(phase,event,extra={})=>fs.appendFileSync(progressFile,JSON.stringify({sequence:sequence++,phase,event,
 elapsedSeconds:(performance.now()-started)/1000,...extra})+'\n');
const report={kind:'phase56-b2-fresh-own-source-check',complete:false,pass:false,executed:true,
 producer:identity(import.meta.filename),imagePins:identity(pinsFile),inputs:[],
 scope:'The actual self-emitted B2 image checks its exact complete source through a private byte-identical ordinary driver. The private Base cache starts empty. Fresh type acceptance and the explicit unsafe proof-trust failure are separate outcomes; no checked development attempt, fixed point or mathematical proof is invented.'};
function files(directory){return !fs.existsSync(directory)?[]:fs.readdirSync(directory,{withFileTypes:true}).flatMap(e=>{
 const file=path.join(directory,e.name);assert(!e.isSymbolicLink());return e.isDirectory()?files(file):[file];});}
try{
 progress('private-image-setup','start');
 const selected=await setup(pinsFile,path.join(out,'image'),{progress});
 const {D,subject,emission,roots,inputs,copies,verifyFinal}=selected;
 report.subject=subject;report.generator=emission.generator;report.image=identity(D.apiPath);
 report.roots=roots;assert.equal(roots.length,77);
 report.inputs=[report.producer,report.imagePins,identity(new URL('../bootstrap/setup-v2.mjs',import.meta.url)),
  identity(new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url)),...inputs];
 report.copies=copies;
 const cache=path.join(D.project,'build/typed/cache');
 report.cacheBefore=files(cache).map(identity);assert.equal(report.cacheBefore.length,0,'Fresh own-source check must start with no Base cache');
 assert.equal(report.image.sha256,emission.module.sha256);
 verify(subject.source);report.source=identity(subject.source.file);
 const sourceText=fs.readFileSync(subject.source.file,'utf8');
 const definitions=[...sourceText.matchAll(/^def\s+([^\s(:]+)/gm)].map(m=>m[1]);
 const explicitlyUnsafe=[...sourceText.matchAll(/^@unsafe\s*\ndef\s+([^\s(:]+)/gm)].map(m=>m[1]);
 assert.equal(definitions.length,3012);assert.equal(new Set(definitions).size,3012);
 assert.deepEqual([...explicitlyUnsafe].sort(),[...definitions].sort());
 report.sourceTrustOracle={method:'Every one of the exact checked assembly\'s 3012 unique def declarations is explicitly annotated @unsafe.',definitions:3012,explicitlyUnsafe:3012};
 progress('private-image-setup','complete',{imageSha256:report.image.sha256,sourceSha256:report.source.sha256});
 progress('ordinary-full-source-check','start');
 const begin=performance.now();
 const result=await D.inspect(subject.source.file,{mode:'check'});
 const observations={...result};
 if(observations.files){report.inputs.push(...observations.files.map(identity));observations.files=observations.files.map(identity);}
 report.observation=observations;report.checkSeconds=(performance.now()-begin)/1000;
 progress('ordinary-full-source-check','complete',{seconds:report.checkSeconds,status:result.status,phase:result.phase,checked:result.checked});
 assert.equal(result.checked,true);assert.equal(result.typeAccepted,true);
 assert.equal(result.kernelChecked,false);assert.equal(result.status,'error');assert.equal(result.exitCode,1);
 assert.equal(result.phase,'verdict');assert.equal(result.proofTrust,'failed');
 assert(Array.isArray(result.unsafeDefinitions));
 const unsafeNames=new Set(result.unsafeDefinitions);assert.equal(unsafeNames.size,result.unsafeDefinitions.length);
 for(const name of explicitlyUnsafe)assert(unsafeNames.has(name),'Missing explicit unsafe declaration: '+name);
 report.additionalUnsafeDeclarations=result.unsafeDefinitions.filter(name=>!explicitlyUnsafe.includes(name));
 const expectedVerdict='SOME PROOFS FAIL\nError: '+result.unsafeDefinitions.length+' defs rely on unsafe or foreign code:\n'+result.unsafeDefinitions.map(n=>'- '+n+'\n').join('');
 assert.equal(result.diagnostic,expectedVerdict);
 report.cacheAfter=files(cache).map(identity);assert(report.cacheAfter.length>0,'Expected fresh B2 Base-check cache');
 await verifyFinal();for(const row of report.inputs)verify(row);verify(report.image);
 report.freshSelfCheck=true;report.freshTypeCheck=true;report.mathematicalProof=false;
 report.expectedProofTrustFailure=true;report.complete=true;report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
finally{
 report.seconds=(performance.now()-started)/1000;
 progress('self-check',report.pass?'complete':'error',{pass:report.pass,error:report.error?.message});
 report.progress=identity(progressFile);
 fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
 console.log(JSON.stringify({complete:report.complete,pass:report.pass,seconds:report.seconds,error:report.error?.message}));
}
