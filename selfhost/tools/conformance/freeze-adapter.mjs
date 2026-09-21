#!/usr/bin/env node
// Freeze the mutable IO shell before a long conformance run. Compiler/runtime
// paths remain explicit environment choices and are hashed by run.mjs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const project=path.resolve(import.meta.dirname,'../..');
const files=['tools/typed-driver.mjs','tools/compiler-abi.mjs','tools/native-build.mjs','tools/assemble.mjs','tools/conformance/adapters/typed.mjs'];
const inputs=files.map(file=>({file,source:fs.readFileSync(path.join(project,file),'utf8')}));
const digest=crypto.createHash('sha256');
for(const input of inputs)digest.update(input.file+'\0'+input.source+'\0');
const directory=path.join(project,'build/conformance-host',digest.digest('hex'));
fs.mkdirSync(directory,{recursive:true});
for(const input of inputs) {
  let source=input.source;
  if(input.file==='tools/typed-driver.mjs')source=source.replace("export const project=path.resolve(import.meta.dirname,'..');",'export const project='+JSON.stringify(project)+';');
  if(input.file==='tools/conformance/adapters/typed.mjs')source=source.replace("from '../../typed-driver.mjs'","from './typed-driver.mjs'");
  fs.writeFileSync(path.join(directory,path.basename(input.file)),source);
}
fs.writeFileSync(path.join(directory,'sources.json'),JSON.stringify(inputs.map(({file,source})=>({file,sha256:crypto.createHash('sha256').update(source).digest('hex')})),null,2)+'\n');
console.log(path.join(directory,'typed.mjs'));
