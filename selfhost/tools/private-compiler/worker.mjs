// Internal process entry. Never import the compiler image into the client.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {identity,verifyIdentity,verifyImage,writeJson,readJson,digest} from './common.mjs';
import {validateInspectRequest} from './transport.mjs';
import {auditReads} from './input-audit.mjs';
const [imageDirectory,requestFile,out]=process.argv.slice(2);
if(!out)throw Error('Internal worker requires IMAGE REQUEST NEW_OUTPUT_DIRECTORY');
const before=verifyImage(imageDirectory),requestIdentity=identity(requestFile),request=validateInspectRequest(readJson(requestFile,16384));
const {root,manifest}=before;
// Explicitly overwrite all compiler configuration consumed by the allowed host
// path. User callbacks/JS/effects never execute during these inspect modes.
process.env.BEND_TYPED_API=path.join(root,'image.mjs');process.env.BEND_TYPED_RUNTIME=path.join(root,'runtime.mjs');process.env.BEND_BASE=manifest.base.file;delete process.env.BEND_TYPED_TRACE;
const D=await import(pathToFileURL(path.join(root,'host/tools/typed-driver.mjs'))),api=await D.loadApi();
const started=performance.now(),audit=auditReads({cacheDirectory:path.join(root,'host/build/typed/cache')});
let result,inputs;
try{result=await D.inspect(request.input,{api,mode:request.mode,withReport:request.withReport});inputs=audit.finish();}finally{audit.stop();}
const requestMs=performance.now()-started;
verifyIdentity(before.manifestIdentity);verifyImage(root);verifyIdentity(requestIdentity);
const report={kind:'bend-private-compiler-request',version:1,complete:true,request,result,requestMs,inputs,proofStatus:manifest.proofStatus,
 imageManifest:before.manifestIdentity,node:{...identity(process.execPath),version:process.version,args:process.execArgv},
 affinity:fs.existsSync('/proc/self/status')?fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:')):null};
if(result.code!==undefined){
 if(result.status!=='ok'||result.phase!=='compile'||result.checked!==true||!['compile','library'].includes(request.mode))throw Error('Unexpected code outside successful checked emission');
 const code=result.code;if(Buffer.byteLength(code)>64*1024*1024)throw Error('Emitted source exceeded 64 MiB output limit');
 const file=path.join(out,'generated.mjs.pending');fs.writeFileSync(file,code,{flag:'wx'});
 report.emitted={file,sha256:digest(code),bytes:Buffer.byteLength(code)};delete result.code;
}
writeJson(path.join(out,'result.json'),report);
