// Paired host adapter: all construction, transformations and emission are Bend.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const [apiFile,name,policy,format,output,reportFile]=process.argv.slice(2),start=performance.now();
if(!['raw','pure','memory','checked','fast','promote'].includes(policy)||!['json','qbe'].includes(format)||!output||!reportFile)throw Error('Usage: kernel.mjs API WORKLOAD raw|pure|memory|checked|fast|promote json|qbe OUTPUT REPORT');
const pin=file=>{const data=fs.readFileSync(file);return{file:path.resolve(file),bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')};};
const api=(await import(pathToFileURL(path.resolve(apiFile)))).default,apiLoadSeconds=(performance.now()-start)/1000;
let before=performance.now();const selected=api.nx_workload(name),constructSeconds=(performance.now()-before)/1000;
if(selected.$!=='Some')throw Error('Unknown workload '+name);
before=performance.now();const program=api.nx_kernel_policy(selected.value,policy),optimizeSeconds=(performance.now()-before)/1000;
before=performance.now();if(api.nx_verify(program)!==true)throw Error('Kernel IR verifier refused');const verifySeconds=(performance.now()-before)/1000;
before=performance.now();const text=api.nx_kernel_text(program,format,policy!=='raw'),emitSeconds=(performance.now()-before)/1000;
fs.writeFileSync(output,text+'\n',{flag:'wx'}); // Match native IO.print's newline.
const report={complete:true,name,policy,format,api:pin(apiFile),method:pin(import.meta.filename),output:pin(output),apiLoadSeconds,constructSeconds,optimizeSeconds,verifySeconds,emitSeconds,seconds:(performance.now()-start)/1000};
fs.writeFileSync(reportFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
