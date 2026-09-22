// Worker-internal state only. Each request receives a fresh source graph and
// diagnostic trace; only the checked API and ordinary validated Base cache stay.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {verifyImage,writeJson,digest} from './common.mjs';import {validateInspectRequest} from './transport.mjs';import {auditReads} from './input-audit.mjs';
export async function createPrivateSession(image) {
 const before=verifyImage(image),{root,manifest}=before;
 process.env.BEND_TYPED_API=path.join(root,'image.mjs');process.env.BEND_TYPED_RUNTIME=path.join(root,'runtime.mjs');process.env.BEND_BASE=manifest.base.file;delete process.env.BEND_TYPED_TRACE;
 const D=await import(pathToFileURL(path.join(root,'host/tools/typed-driver.mjs'))),api=await D.loadApi();
 return {manifestIdentity:before.manifestIdentity,async inspect(value,directory){
  const request=validateInspectRequest(value),out=fs.realpathSync(directory),started=performance.now(),audit=auditReads({cacheDirectory:path.join(root,'host/build/typed/cache')});
  let result,inputs;try{result=await D.inspect(request.input,{api,mode:request.mode,withReport:request.withReport});inputs=audit.finish();}finally{audit.stop();}
  const report={kind:'bend-private-compiler-request',version:1,complete:true,request,result,requestMs:performance.now()-started,inputs,proofStatus:manifest.proofStatus,imageManifest:before.manifestIdentity,
   node:{file:process.execPath,version:process.version,args:process.execArgv,identityVerifiedBy:'batch supervisor before/after this worker lifetime'}};
  if(result.code!==undefined){
   if(result.status!=='ok'||result.phase!=='compile'||result.checked!==true||!['compile','library'].includes(request.mode))throw Error('Unexpected code outside successful checked emission');
   const code=result.code;if(Buffer.byteLength(code)>64*1024*1024)throw Error('Emitted source exceeded 64 MiB output limit');
   const file=path.join(out,'generated.mjs.pending');fs.writeFileSync(file,code,{flag:'wx'});report.emitted={file,sha256:digest(code),bytes:Buffer.byteLength(code)};delete result.code;
  }
  writeJson(path.join(out,'result.json'),report);return report;
 }};
}
