// The compiler executes natively; the selected conformance lane executes emitted
// JavaScript. An explicit graph manifest is mandatory and there is no fallback.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {runNativeGraph,loadNativeGraphManifest} from '../../performance/rapid/native-graph-run.mjs';
import {walk} from '../inventory.mjs';
import {nodeResourceArgs} from '../../node-resource-args.mjs';
const required=key=>{if(!process.env[key])throw Error('Set '+key);return fs.realpathSync(process.env[key])};
const binary=required('BEND_NATIVE_BINARY'),runtime=required('BEND_NATIVE_RUNTIME'),directory=required('BEND_NATIVE_MANIFEST_DIRECTORY');
export const name='bend-native-graph-host';
export const capabilities={parse:false,check:false,interpreter:false,js:true,native:false,metal:false,cuda:false,modules:true,foreign:true,dependentTypes:true,affine:true,termination:true,proofs:true};
export const artifacts={binary,runtime,launcher:path.resolve(import.meta.dirname,'../../performance/rapid/native-graph-run.mjs'),nodeResources:path.resolve(import.meta.dirname,'../../node-resource-args.mjs')};
for(const file of walk(directory))if(file.endsWith('.json'))artifacts['manifest/'+path.relative(directory,file)]=file;
for(const file of [binary+'.build.json',path.join(path.dirname(binary),'native-build-report.json')])if(fs.existsSync(file))artifacts['build/'+path.basename(file)]=file;
export function inputFiles({tests}) {
  const files=[];
  for(const test of tests){
    const manifest=path.resolve(directory,test.id+'.json');
    if(!manifest.startsWith(directory+path.sep))continue;
    files.push(manifest);
    if(!fs.existsSync(manifest))continue;
    try{const graph=loadNativeGraphManifest(manifest);for(const input of [...graph.modules,...graph.assets])files.push(input.lexical,input.path);}catch{/* The probe records malformed-manifest failure. */}
  }
  return [...new Set(files)];
}
export function validateGraphFixture(graph,test,upstream){
  const main=graph.modules.find(module=>module.name===graph.main),base=graph.modules.find(module=>module.name==='Base');
  if(main?.path!==fs.realpathSync(test.file))throw Error('Native manifest main differs from selected fixture');
  if(base?.path!==fs.realpathSync(path.join(upstream,'bend2/base.bend')))throw Error('Native manifest Base differs from pinned reference Base path');
}
export async function probe({test,lane,workdir,timeoutMs,upstream}){
  if(lane!=='js')return {status:'unsupported',reason:'Native graph host currently exposes only checked JavaScript emission/execution; no lane fallback.'};
  const manifest=path.resolve(directory,test.id+'.json');
  if(!manifest.startsWith(directory+path.sep)||!fs.existsSync(manifest))return {status:'unsupported',reason:'No explicit native graph manifest for '+test.id};
  const graph=loadNativeGraphManifest(manifest);validateGraphFixture(graph,test,upstream);
  const output=path.join(workdir,'program.mjs');
  const native=runNativeGraph({binary,manifest,runtime,output,timeoutMs:Math.max(100,timeoutMs-250)});
  fs.writeFileSync(path.join(workdir,'native-compile.json'),JSON.stringify(native,null,2)+'\n');
  if(!native.published){
    if(native.error||native.signal)return {status:native.error?.includes('ETIMEDOUT')?'timeout':'crash',phase:native.phase,checked:native.checked,reason:native.error||native.signal,nativeProvenance:native};
    return {status:'error',phase:native.phase,checked:native.checked,diagnostic:native.diagnostic.startsWith('Error:')?native.diagnostic:'Error: '+native.diagnostic,exitCode:native.status??1,nativeProvenance:native};
  }
  const log=path.join(workdir,'program.output'),fd=fs.openSync(log,'w'),executionArgs=nodeResourceArgs();let child;
  try{child=spawnSync(process.execPath,[...executionArgs,output],{cwd:workdir,stdio:['ignore',fd,fd],timeout:Math.max(100,timeoutMs-250)})}finally{fs.closeSync(fd)}
  const bytes=fs.statSync(log).size;if(bytes>2**20){fs.truncateSync(log,2**20);return {status:'crash',phase:'runtime',checked:true,reason:'Program exceeded output limit.',outputBytes:bytes,nativeProvenance:native};}
  const text=fs.readFileSync(log,'utf8');
  if(child.error||child.signal)return {status:child.error?.code==='ETIMEDOUT'?'timeout':'crash',phase:'runtime',checked:true,reason:child.error?.message||child.signal,output:text,executionArgs,nativeProvenance:native};
  return {status:child.status===0?'ok':'error',phase:'runtime',checked:true,output:text,stdout:text,stderr:'',exitCode:child.status,executionArgs,compilerExecution:'native',programExecution:'node-js',nativeProvenance:native};
}
