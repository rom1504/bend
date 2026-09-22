// Real-image failure-isolation and fresh-graph tests. No synthetic checked image.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawn} from 'node:child_process';
import {runPrivateBatch} from '../batch.mjs';import {identity,verifyImage,verifyIdentity,writeJson,readJson} from '../common.mjs';
const [imageArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: batch-behavior.mjs REAL_IMAGE NEW_DIRECTORY');
const image=fs.realpathSync(imageArg),out=path.resolve(outArg);fs.mkdirSync(out);const imageIdentity=verifyImage(image).manifestIdentity,good=path.join(out,'good.bend'),bad=path.join(out,'bad.bend');
const source=text=>'import Base\nlaw main:\n  IO(Unit)\ndef main():\n  IO.print('+JSON.stringify(text)+')\n';fs.writeFileSync(good,source('before'));fs.writeFileSync(bad,'def main(:\n');
const report={kind:'private-batch-behavior-validation',complete:false,image:imageIdentity,cases:[]},flush=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');flush();
try{
 const recovery=await runPrivateBatch({image,output:path.join(out,'timeout-recovery'),cpu:0,requests:[{input:good,mode:'compile',timeoutMs:1},{input:bad,mode:'check'},{input:good,mode:'compile'}]});
 assert.equal(recovery.complete,false);assert.equal(recovery.rows[0].timedOut,true);assert.equal(recovery.rows[0].published,false);assert.equal(recovery.lifetimes.length,2);assert.equal(recovery.rows[1].observation.result.status,'error');assert.equal(recovery.rows[1].observation.result.phase,'parse');assert.equal(recovery.rows[1].complete,true);assert.equal(recovery.rows[2].observation.result.status,'ok');assert.equal(recovery.rows[2].published,true);report.cases.push({name:'timeout-recovery-rejection-continuation-order',passed:true,report:path.join(out,'timeout-recovery/batch.json')});flush();
 const recycling=await runPrivateBatch({image,output:path.join(out,'recycle'),cpu:0,recycle:1,heapMb:1024,requests:[{input:bad,mode:'check'},{input:bad,mode:'check'}]});
 assert.equal(recycling.complete,true);assert.equal(recycling.lifetimes.length,2);assert.ok(recycling.lifetimes.every(x=>x.args.includes('--max-old-space-size=1024')));assert.deepEqual(recycling.rows.map(r=>r.index),[0,1]);report.cases.push({name:'explicit-recycle-resource-flags',passed:true,report:path.join(out,'recycle/batch.json')});flush();
 // Kill only the process group this test just created. The next request must
 // receive a fresh worker; the interrupted request must never become a pass.
 const crashOut=path.join(out,'crash');let killed=false;
 const killer=setInterval(()=>{try{const p=readJson(path.join(crashOut,'batch.json'));if(!killed&&p.rows.length===1&&p.lifetimes[0]?.pid){process.kill(-p.lifetimes[0].pid,'SIGKILL');killed=true;}}catch{}},10);
 let crash;try{crash=await runPrivateBatch({image,output:crashOut,cpu:0,requests:[{input:good,mode:'compile'},{input:bad,mode:'check'}]});}finally{clearInterval(killer);}
 assert.equal(killed,true);assert.equal(crash.complete,false);assert.equal(crash.rows[0].complete,false);assert.equal(crash.rows[1].complete,true);assert.equal(crash.lifetimes.length,2);report.cases.push({name:'unexpected-crash-recovers-only-later-request',passed:true,report:path.join(crashOut,'batch.json')});flush();
 // Mutate a completed request's source while the same lifetime handles another
 // request. Its pending output must remain unpublished at the final check.
 const driftOut=path.join(out,'late-source-change'),slow=path.join(out,'other.bend');fs.writeFileSync(slow,source('other'));let changed=false;
 const changer=setInterval(()=>{if(!changed&&fs.existsSync(path.join(driftOut,'000/result.json'))){fs.writeFileSync(good,source('after'));changed=true;}},10);
 let drift;try{drift=await runPrivateBatch({image,output:driftOut,cpu:0,requests:[{input:good,mode:'compile'},{input:slow,mode:'compile'}]});}finally{clearInterval(changer);}
 assert.equal(changed,true);assert.equal(drift.complete,false);assert.equal(drift.rows[0].complete,false);assert.match(drift.rows[0].error,/Artifact changed/);assert.equal(fs.existsSync(path.join(driftOut,'000/generated.mjs')),false);assert.equal(drift.rows[1].complete,true);report.cases.push({name:'late-source-drift-refuses-deferred-publication',passed:true,report:path.join(driftOut,'batch.json')});flush();
 verifyIdentity(imageIdentity);verifyImage(image);report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}report.tool=identity(new URL(import.meta.url));flush();console.log(JSON.stringify({complete:report.complete,cases:report.cases.length,error:report.error}));
