// Direct JS only. The unchanged conformance harness owns fixtures and judging.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const attempt=fs.realpathSync(process.env.BEND_DIRECT_ATTEMPT);
const manifest=JSON.parse(fs.readFileSync(path.join(attempt,'attempt.json'),'utf8'));
assert.equal(manifest.checked,true);assert.equal(manifest.config.strictExact,true);
const pin=row=>{const file=fs.realpathSync(row.file??row.canonicalPath??row.path);
  assert.equal(createHash('sha256').update(fs.readFileSync(file)).digest('hex'),row.sha256);return file;};
process.env.BEND_TYPED_API=pin(manifest.api);
process.env.BEND_TYPED_RUNTIME=pin(manifest.runtime);
process.env.BEND_BASE=pin(manifest.base);
process.env.BEND_TYPED_TRACE='';
const host=fs.realpathSync(manifest.snapshot.root);
const driver=path.join(host,'tools/typed-driver.mjs');
const D=await import(pathToFileURL(driver));
assert.equal(typeof D.directRuntimePath,'string');
export const name='checked-bend-direct-js';
export const capabilities={js:true,parse:false,check:false,interpreter:false,native:false,
  metal:false,cuda:false,modules:true,foreign:true,dependentTypes:true,affine:true,
  termination:true,proofs:true,proofKernel:false,checkOracle:'validation-plus-declaration-verdict'};
export const artifacts={attempt:path.join(attempt,'attempt.json'),compiler:process.env.BEND_TYPED_API,
  runtime:process.env.BEND_TYPED_RUNTIME,base:process.env.BEND_BASE,driver,
  directRuntime:D.directRuntimePath,compilerManifest:path.join(host,'src/compiler.json'),
  compilerAbi:D.compilerAbiPath,nodeResources:D.nodeResourceArgsPath};
export async function probe({test,lane,workdir,timeoutMs}) {
  assert.equal(lane,'js','This gate executes only the new direct JavaScript backend');
  return D.execute(test.file,{workdir,timeoutMs:Math.max(100,timeoutMs-250),
    backend:'direct',combinedOutput:true});
}
