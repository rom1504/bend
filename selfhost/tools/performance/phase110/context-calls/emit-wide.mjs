// Root-run transport for a synthetic owning ABI fixture; no actual-source claim.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import {pathToFileURL,fileURLToPath} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2),apiFile=path.resolve(apiArg),out=path.resolve(outArg);
const pin=file=>{const raw=fs.readFileSync(file);return{file:path.resolve(file),bytes:raw.length,sha256:crypto.createHash('sha256').update(raw).digest('hex')};};
const reportFile=path.join(path.dirname(apiFile),'report.json'),prior=JSON.parse(fs.readFileSync(reportFile));
if(!prior.complete||JSON.stringify(prior.api)!==JSON.stringify(pin(apiFile)))throw Error('checked source-bound wide API required');
const api=(await import(pathToFileURL(apiFile))).default;
const controls=api.nx110ctx_wide_report(),expected=['wide-baseline-owned-eight-args PASS','wide-threaded-eleven-machine-args PASS','wide-context-nine-machine-args PASS'];
if(controls.trimEnd().split('\n').join('|')!==expected.join('|'))throw Error('wide structural controls failed');
fs.mkdirSync(out,{recursive:false});
const record={kind:'phase110-context-wide-emission',complete:false,synthetic:true,targetsRun:true,inputs:[pin(apiFile),pin(reportFile),prior.source,pin(fileURLToPath(import.meta.url))],controls,rows:[]};
for(const mode of ['baseline','threaded','context']){
 const qbe=api.nx110ctx_wide_qbe(mode),c=api.nx110ctx_wide_c(mode);
 if(qbe.includes('INVALID_')||c.includes('INVALID_'))throw Error('wide emission refused');
 const qfile=path.join(out,mode+'.ssa'),cfile=path.join(out,mode+'.c');fs.writeFileSync(qfile,qbe);fs.writeFileSync(cfile,c);
 record.rows.push({mode,qbe:pin(qfile),c:pin(cfile)});
}
record.complete=true;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(record,null,2)+'\n');
console.log(JSON.stringify({complete:true,synthetic:true,modes:3,controls:3}));
