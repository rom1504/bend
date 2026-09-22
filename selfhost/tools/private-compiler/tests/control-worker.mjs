// Test oracle only: the original public checked H, through the identical host.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {verifyImage,readJson,writeJson,digest} from '../common.mjs';
import {validateInspectRequest} from '../transport.mjs';
const [directory,requestFile,out,variant="public"]=process.argv.slice(2),{root,manifest}=verifyImage(directory),request=validateInspectRequest(readJson(requestFile));
if(!['public','b1'].includes(variant))throw Error('Unknown reference compiler');
process.env.BEND_TYPED_API=path.join(root,variant==='b1'?'provenance/initial-compiler.mjs':'provenance/public-api.mjs');process.env.BEND_TYPED_RUNTIME=path.join(root,'runtime.mjs');process.env.BEND_BASE=manifest.base.file;delete process.env.BEND_TYPED_TRACE;
const D=await import(pathToFileURL(path.join(root,'host/tools/typed-driver.mjs'))),api=await D.loadApi(),start=performance.now(),result=await D.inspect(request.input,{api,mode:request.mode,withReport:request.withReport});
const report={result,requestMs:performance.now()-start};
if(result.code!==undefined){const file=path.join(out,'control.mjs');fs.writeFileSync(file,result.code,{flag:'wx'});report.emitted={file,sha256:digest(result.code),bytes:Buffer.byteLength(result.code)};delete result.code;}
verifyImage(root);writeJson(path.join(out,'control.json'),report);
