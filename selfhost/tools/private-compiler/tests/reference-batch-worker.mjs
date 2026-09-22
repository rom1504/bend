// Controlled test oracle: identical frozen host, ordinary public H or checked
// initial B1, reused only inside a finite process. No changed compiler logic.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {identity,verifyIdentity,verifyImage,readJson,writeJson,digest} from '../common.mjs';import {validateBatchRequests} from '../transport.mjs';
const [directory,requestFile,out,variant]=process.argv.slice(2);if(!['public','b1'].includes(variant))throw Error('Unknown reference compiler');
const before=verifyImage(directory),node={...identity(process.execPath),version:process.version},input=identity(requestFile),requests=validateBatchRequests(readJson(requestFile)),{root,manifest}=before;
process.env.BEND_TYPED_API=path.join(root,variant==='public'?'provenance/public-api.mjs':'provenance/initial-compiler.mjs');process.env.BEND_TYPED_RUNTIME=path.join(root,'runtime.mjs');process.env.BEND_BASE=manifest.base.file;delete process.env.BEND_TYPED_TRACE;
const D=await import(pathToFileURL(path.join(root,'host/tools/typed-driver.mjs'))),api=await D.loadApi(),rows=[];
for(const [i,{request}] of requests.entries()){
 const start=performance.now(),result=await D.inspect(request.input,{api,mode:request.mode,withReport:request.withReport}),row={index:i,request,result,requestMs:performance.now()-start};
 if(result.code!==undefined){const file=path.join(out,String(i)+'.mjs');fs.writeFileSync(file,result.code,{flag:'wx'});row.emitted={file,sha256:digest(result.code),bytes:Buffer.byteLength(result.code)};delete result.code;}
 rows.push(row);
}
verifyIdentity(input);verifyIdentity(node);verifyIdentity(before.manifestIdentity);verifyImage(directory);writeJson(path.join(out,'reference.json'),{complete:true,variant,node,image:before.manifestIdentity,rows});
