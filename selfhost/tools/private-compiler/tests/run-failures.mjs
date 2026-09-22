// Real finalized image, bounded negative launcher checks; no fake proof/image.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {runPrivateCompiler} from '../run.mjs';import {identity,verifyImage,writeJson} from '../common.mjs';
const [imageArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: run-failures.mjs REAL_IMAGE NEW_DIRECTORY');
const image=fs.realpathSync(imageArg),out=path.resolve(outArg);fs.mkdirSync(out);const manifest=verifyImage(image),input=path.join(out,'main.bend');fs.writeFileSync(input,'import Base\ndef main() -> U32:\n  1\n');
const report={kind:'private-cli-failure-validation',complete:false,image:manifest.manifestIdentity,cases:[]};
try{
 const timed=await runPrivateCompiler({image,input,mode:'compile',output:path.join(out,'timeout'),cpu:0,timeoutMs:1});assert.equal(timed.complete,false);assert.equal(timed.timedOut,true);assert.equal(fs.existsSync(path.join(out,'timeout/generated.mjs')),false);report.cases.push({name:'timeout-unpublished',passed:true,launch:timed});
 const existing=path.join(out,'existing');fs.mkdirSync(existing);fs.writeFileSync(path.join(existing,'preserve'),'yes');await assert.rejects(runPrivateCompiler({image,input,mode:'check',output:existing}),/EEXIST/);assert.equal(fs.readFileSync(path.join(existing,'preserve'),'utf8'),'yes');report.cases.push({name:'existing-directory-preserved',passed:true});
 await assert.rejects(runPrivateCompiler({image,input,mode:'native',output:path.join(out,'native')}),/Unsupported private request mode/);assert.equal(fs.existsSync(path.join(out,'native')),false);report.cases.push({name:'native-mode-refused',passed:true});
 const copy=path.join(out,'changed-image');fs.cpSync(image,copy,{recursive:true});fs.appendFileSync(path.join(copy,'runtime.mjs'),'\n// drift\n');await assert.rejects(runPrivateCompiler({image:copy,input,mode:'compile',output:path.join(out,'changed-output')}),/Image artifact changed/);assert.equal(fs.existsSync(path.join(out,'changed-output')),false);report.cases.push({name:'runtime-drift-before-worker',passed:true});
 verifyImage(image);report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
report.tool=identity(new URL(import.meta.url));writeJson(path.join(out,'report.json'),report);console.log(JSON.stringify({complete:report.complete,cases:report.cases.length,error:report.error}));
