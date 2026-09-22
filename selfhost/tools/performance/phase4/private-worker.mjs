// Process boundary for a compiler-private image. Requests contain paths/modes,
// never function values, compiler graphs, prototype hooks or runtime globals.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {types} from 'node:util';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
export function validateInspectRequest(value) {
  if(!value||typeof value!=='object'||types.isProxy(value)||Object.getPrototypeOf(value)!==Object.prototype)throw Error('Private request must be a plain data record');
  const descriptors=Object.getOwnPropertyDescriptors(value),allowed=new Set(['input','mode','withReport']);
  for(const key of Reflect.ownKeys(descriptors))if(typeof key!=='string'||!allowed.has(key)||!Object.hasOwn(descriptors[key],'value'))throw Error('Unsupported private request field');
  if(typeof descriptors.input?.value!=='string'||!path.isAbsolute(descriptors.input.value))throw Error('Private input must be an absolute path');
  if(!['parse','check','compile','library'].includes(descriptors.mode?.value))throw Error('Unsupported private request mode');
  if(descriptors.withReport&&typeof descriptors.withReport.value!=='boolean')throw Error('Private withReport must be Boolean');
  return {input:descriptors.input.value,mode:descriptors.mode.value,withReport:descriptors.withReport?.value??false};
}
const sha=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
function verify(identities) {
  for(const [file,before] of Object.entries(identities))assert.deepEqual({path:fs.realpathSync(file),sha256:sha(file)},before,'Artifact changed: '+file);
}
export async function runPrivateRequest(config,request) {
  const safe=validateInspectRequest(request);verify(config.identities);
  process.env.BEND_TYPED_API=config.api;process.env.BEND_TYPED_RUNTIME=config.runtime;process.env.BEND_BASE=config.base;delete process.env.BEND_TYPED_TRACE;
  const D=await import(pathToFileURL(config.host)),api=await D.loadApi();
  const started=performance.now(),result=await D.inspect(safe.input,{api,mode:safe.mode,withReport:safe.withReport}),requestMs=performance.now()-started;
  verify(config.identities);
  return {requestMs,result,apiSha256:sha(config.api),node:{version:process.version,args:process.execArgv},affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href) {
  const [configFile,requestFile,output]=process.argv.slice(2);if(!output)throw Error('Usage: private-worker.mjs INTERNAL_CONFIG REQUEST OUTPUT');
  const config=JSON.parse(fs.readFileSync(configFile)),request=JSON.parse(fs.readFileSync(requestFile));
  let result;
  if(process.argv[5]==='--prime'){
    verify(config.identities);process.env.BEND_TYPED_API=config.api;process.env.BEND_TYPED_RUNTIME=config.runtime;process.env.BEND_BASE=config.base;delete process.env.BEND_TYPED_TRACE;
    const D=await import(pathToFileURL(config.host)),api=await D.loadApi(),start=performance.now(),cache=await D.prepareBase(api);
    result={primeMs:performance.now()-start,validatedBy:cache.validatedBy,compilerSha256:cache.compilerSha256,baseSha256:cache.baseSha256,bookSha256:cache.bookSha256,sourcePath:cache.sourcePath,result:{status:'primed'}};verify(config.identities);
  }else result=await runPrivateRequest(config,request);
  if(result.result.code!==undefined){const code=output+'.mjs';fs.writeFileSync(code,result.result.code);result.emitted={file:code,sha256:sha(code),bytes:Buffer.byteLength(result.result.code)};delete result.result.code;}
  fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n');
}
