import path from 'node:path';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {inspect,execute,apiPath,basePath,project,runtimePath,driverPath,compilerAbiPath} from '../../typed-driver.mjs';
// Resolve environment paths before isolated workers change their directory.
process.env.BEND_TYPED_API=apiPath;
process.env.BEND_TYPED_RUNTIME=runtimePath;
process.env.BEND_BASE=basePath;
process.env.BEND_TYPED_TRACE??='1';
export const name='typed-bend';
export const artifacts={compiler:apiPath,base:basePath,runtime:runtimePath,driver:driverPath,compilerAbi:compilerAbiPath,nativeRuntime:path.join(project,'src/runtime/native/runtime.c')};
const driverDigest=crypto.createHash('sha256').update(fs.readFileSync(driverPath)).digest('hex');
const adapterDigest=crypto.createHash('sha256').update(fs.readFileSync(new URL(import.meta.url))).digest('hex');
const digest=crypto.createHash('sha256').update(fs.readFileSync(apiPath)).digest('hex');
const livePath=path.join(project,'build/typed',`live-${digest.slice(0,12)}.jsonl`);
export const capabilities={parse:true,check:true,interpreter:true,js:true,native:true,metal:true,cuda:true,
  modules:true,foreign:true,dependentTypes:true,affine:true,termination:true,proofs:true};
export async function probe({test,lane,workdir,timeoutMs}) {
  if(!capabilities[lane]) return {status:'unsupported',reason:'Typed driver does not implement '+lane};
  const result=['js','native','metal','cuda'].includes(lane)?await execute(test.file,{workdir,timeoutMs:Math.max(100,timeoutMs-250),backend:lane,combinedOutput:true}):
    await inspect(test.file,{mode:lane==='parse'?'parse':lane==='interpreter'?'interpreter':'check',timeoutMs:Math.max(100,timeoutMs-250),combinedOutput:true});
  result.hostProvenance={driverSha256:driverDigest,adapterSha256:adapterDigest};
  fs.mkdirSync(path.dirname(livePath),{recursive:true});
  fs.appendFileSync(livePath,JSON.stringify({id:test.id,lane,negative:test.negative,expected:test.expected,compilerSha256:digest,run:path.dirname(workdir),result})+'\n');
  return result;
}
