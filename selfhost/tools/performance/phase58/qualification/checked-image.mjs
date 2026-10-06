// Root-executed checked-image staging. Importing this module executes no compiler.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
import {identity,verify,hash} from '../../phase54/bootstrap/adapter.mjs';
const root=path.resolve(import.meta.dirname,'../../../../..');
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>{assert(!e.isSymbolicLink());const file=path.join(dir,e.name);return e.isDirectory()?walk(file):[file];});
export async function stageChecked(directory,freshOut){
 const out=path.resolve(freshOut),raw=fs.realpathSync(path.join(root,'selfhost/build/phase58'));
 assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});assert(fs.realpathSync(out).startsWith(raw+path.sep));
 const inputs=new Map(),copies=[];
 const pin=file=>{const row=identity(typeof file==='object'&&!(file instanceof URL)?file.file:file);if(typeof file==='object'&&!(file instanceof URL))assert.equal(row.sha256,file.sha256);if(inputs.has(row.file))assert.deepEqual(inputs.get(row.file),row);else inputs.set(row.file,row);return row;};
 const attempt=await verifyAttempt(directory);assert(attempt.checked);assert.equal(identity(process.execPath).sha256,attempt.node.sha256);const attemptId=pin(path.join(directory,'attempt.json'));
 for(const key of ['api','runtime','base','node','bootstrapReport'])pin(attempt[key]);
 for(const file of [import.meta.filename,new URL('../../../development/workflow.mjs',import.meta.url),new URL('../../phase54/bootstrap/adapter.mjs',import.meta.url),new URL('../../phase56/qualification/string-controls-v2.mjs',import.meta.url)])pin(file);
 function copy(file,relative){const before=pin(file),target=path.join(out,relative);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(before.file,target,fs.constants.COPYFILE_EXCL);const after=pin(target);assert.equal(before.sha256,after.sha256);copies.push({before,after});return after;}
 for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])copy(path.join(attempt.snapshot.root,'tools',name+'.mjs'),'tools/'+name+'.mjs');
 copy(path.join(attempt.snapshot.root,'src/compiler.json'),'src/compiler.json');
 const runtime=copy(attempt.runtime.file,'src/runtime.mjs');
 for(const file of walk(path.join(attempt.snapshot.root,'src/runtime')))copy(file,path.relative(attempt.snapshot.root,file));
 const actualApi=copy(attempt.api.file,'dist/api.mjs');assert(!fs.existsSync(actualApi.file+'.bootstrap.json'));
 for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
 process.env.BEND_TYPED_API=actualApi.file;process.env.BEND_TYPED_RUNTIME=runtime.file;process.env.BEND_BASE=attempt.base.file;
 const D=await import(pathToFileURL(path.join(out,'tools/typed-driver.mjs')));
 assert.equal(D.apiPath,actualApi.file);assert.equal(identity(D.runtimePath).sha256,runtime.sha256);assert(!fs.existsSync(path.join(out,'build/typed/cache')));
 const api=await D.loadApi();
 const image={kind:'private-copy-of-checked-attempt',attempt:attemptId,api:actualApi,runtime,base:pin(attempt.base),driver:pin(path.join(out,'tools/typed-driver.mjs')),directRuntime:pin(D.directRuntimePath)};
 async function verifyFinal(){
  const cache=path.join(out,'build/typed/cache'),cacheFiles=fs.existsSync(cache)?walk(cache).map(pin):[];
  for(const row of cacheFiles){const c=JSON.parse(fs.readFileSync(row.file,'utf8'));assert.equal(c.compilerSha256,actualApi.sha256);assert.equal(c.baseSha256,attempt.base.sha256);assert.equal(c.sourcePath,fs.realpathSync(attempt.base.file));assert.equal(c.validatedBy,'check_book');assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));}
  for(const row of inputs.values())verify(row);await verifyAttempt(directory);assert(!fs.existsSync(actualApi.file+'.bootstrap.json'));
  return {inputsUnchanged:true,copiesUnchanged:true,cacheFiles};
 }
 return {D,api,attempt,image,inputs:[...inputs.values()],copies,project:out,verifyFinal};
}
