#!/usr/bin/env node
// Make an immutable experimental compiler snapshot from a recorded bootstrap.
// No production module is edited, and upstream still checks the entire source.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {assemble} from '../assemble.mjs';
import {PIN} from './inventory.mjs';
const project=path.resolve(import.meta.dirname,'../..');
const [reportFile,outputDir,moduleName,replacement]=process.argv.slice(2);
if(!replacement)throw Error('Usage: bootstrap-variant.mjs REPORT OUTPUT_DIRECTORY MODULE REPLACEMENT');
const original=JSON.parse(fs.readFileSync(reportFile,'utf8'));
if(!original.modules.some(m=>m.file===moduleName))throw Error('Replacement module absent from source snapshot');
const upstream=path.resolve(process.env.BEND_UPSTREAM||path.join(project,'../upstream-bend'));
const revision=spawnSync('git',['-C',upstream,'rev-parse','HEAD'],{encoding:'utf8'}).stdout?.trim();
if(revision!==PIN)throw Error('Bootstrap requires pinned upstream '+PIN);
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const directory=path.resolve(outputDir),snapshot=path.dirname(original.source);
fs.mkdirSync(directory,{recursive:true});
const modules=original.modules.map(m=>{
  const bytes=fs.readFileSync(path.join(snapshot,m.file));
  if(hash(bytes)!==m.sha256)throw Error('Original snapshot changed: '+m.file);
  const selected=m.file===moduleName?fs.readFileSync(replacement):bytes;
  const target=path.join(directory,m.file);
  fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,selected);
  return {file:m.file,sha256:hash(selected)};
});
const source=path.join(directory,'compiler.bend'),api=path.join(directory,'bootstrap-api.mjs');
assemble(modules.map(m=>m.file),source,{root:directory});
const result=spawnSync(process.execPath,[path.join(project,'tools/stage0-library.mjs'),source,api,...original.exports],
  {cwd:project,env:{...process.env,BEND_UPSTREAM:upstream},encoding:'utf8',timeout:300000,maxBuffer:2**24});
if(result.error||result.status!==0)throw Error(result.error?.message||result.stderr||'Variant bootstrap failed');
const report={stage:'upstream-bootstrap-variant',revision,generated:new Date().toISOString(),parent:original.apiSha256,
  apiPath:api,apiSha256:hash(fs.readFileSync(api)),source,sourceSha256:hash(fs.readFileSync(source)),modules,exports:original.exports,
  replacement:{module:moduleName,file:path.resolve(replacement)},baseSha256:original.baseSha256};
fs.writeFileSync(api+'.bootstrap.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({api,source,sha256:report.apiSha256}));
