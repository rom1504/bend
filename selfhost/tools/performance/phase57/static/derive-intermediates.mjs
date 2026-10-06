#!/usr/bin/env node
// Replays existing B1 stages as data transformations. No compiler image is imported.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const [repoArg,outArg]=process.argv.slice(2);
assert(repoArg&&outArg,'usage: node derive-intermediates.mjs REPO FRESH_PHASE57_DIR');
const repo=path.resolve(repoArg),out=path.resolve(outArg);
assert(out.startsWith(path.join(repo,'selfhost/build/phase57')+path.sep));assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,sha256:hash(b),bytes:b.length};};
const inputs=[];
const read=(file,expected)=>{const i=identity(file);if(expected)assert.equal(i.sha256,expected);inputs.push(i);return fs.readFileSync(file,'utf8');};
const pin=ref=>read(ref.file,ref.sha256);
const reportFile=path.join(repo,'selfhost/build/phase56/checked-string01/equality/api.mjs.derivation.json');
const d=JSON.parse(read(reportFile,'5b0e2ecf90c7127cb122b6e56a119b7ca647216f804520fc202519388416308e'));
assert(d.complete&&d.newBootstrap===false&&d.transform.version===6);
const raw=pin(d.original.api),final=pin(d.output),tool=pin(d.tool);
const eq=s=>{const re=/^function \$String\$eq\$\([^\n]*\) \{\n[\s\S]*?^\}/gm;const m=[...s.matchAll(re)];assert.equal(m.length,1);return {start:m[0].index,text:m[0][0]};};
const old=eq(raw),selected=eq(final);
const equalityOnly=raw.slice(0,old.start)+selected.text+raw.slice(old.start+old.text.length);
assert.equal(hash(equalityOnly),d.transform.choices.inputSha256,'exact recorded equality-only image');
assert.equal(d.transform.choices.outputSha256,d.transform.tailChoices.inputSha256);
fs.mkdirSync(out,{recursive:true});
const helper=path.join(out,'frozen-equality-stages.mjs');
const suffix='\nexport {transformChoices,transformTailChoices};\n';
fs.writeFileSync(helper,tool+suffix,{flag:'wx'});
const report={kind:'phase57-existing-b1-intermediates',complete:false,pass:false,newBootstrap:false,scope:d.scope,inputs,helper:{...identity(helper),original:d.tool,appended:suffix},outputs:[]};
try{
 const stages=await import(pathToFileURL(helper).href);
 const choice=stages.transformChoices(equalityOnly,true);
 assert.equal(hash(choice.source),d.transform.choices.outputSha256);
 assert.deepEqual(choice.report,d.transform.choices);
 const tail=stages.transformTailChoices(choice.source);
 assert.equal(tail.source,final);assert.deepEqual(tail.report,d.transform.tailChoices);
 const variants={raw,equality:equalityOnly,choices:choice.source,source:tail.source};
 inputs.push(identity(fileURLToPath(import.meta.url)));
 for(const i of inputs)assert.deepEqual(identity(i.file),i);
 for(const [role,source] of Object.entries(variants)){
  const file=path.join(out,role+'.mjs');fs.writeFileSync(file,source,{flag:'wx'});report.outputs.push({role,...identity(file)});
 }
 report.complete=true;report.pass=true;
}catch(error){report.error=String(error?.stack??error);throw error;}
finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});}
console.log(JSON.stringify({report:identity(path.join(out,'report.json')),outputs:report.outputs}));
