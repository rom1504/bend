// Fresh genuine-B2 emission against the qualified 23-source / 45-point JS corpus.
// This checks output identity, not compiler latency or fresh program timings.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {identity,verify} from '../phase54/bootstrap/adapter.mjs';
const [setupFile,pinsFile,manifestFile,outArg]=process.argv.slice(2);
assert(setupFile&&pinsFile&&manifestFile&&outArg);
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),rows=[];
const pin=(v,base='.')=>{
 const p=typeof v==='string'?path.resolve(base,v):path.resolve(base,v.file??v.path),r=identity(p);
 if(typeof v==='object'){assert.equal(r.sha256,v.sha256);if(v.bytes!==undefined)assert.equal(fs.statSync(p).size,v.bytes);}
 if(inputs.has(p))assert.deepEqual(inputs.get(p),r);inputs.set(p,r);return r;
};
const read=(v,base)=>JSON.parse(fs.readFileSync(pin(v,base).file,'utf8'));
const report={complete:false,pass:false,programsExecuted:false,rows,scope:'Fresh checked emission by genuine B2 compared with qualified Phase66 raw JS modules. Exact 23-source identity preserves those 45 benchmark points and unchanged adapter behavior; no new compiler or program timing claim.'};
try{
 pin(import.meta.filename);pin(setupFile);pin('../phase54/bootstrap/adapter.mjs',import.meta.dirname);pin(process.execPath);
 const {setup}=await import(pathToFileURL(path.resolve(setupFile)));
 const selected=await setup(pinsFile,path.join(out,'image'));report.image=selected.image;report.subject=selected.subject;
 for(const row of selected.inputs)pin(row);for(const row of selected.copies)pin(row.after);
 const origin=path.dirname(path.resolve(manifestFile)),manifest=read(manifestFile);
 assert.equal(manifest.kind,'bend-program-bundle');assert(manifest.complete);assert.equal(manifest.cases.length,45);
 const prep=read(manifest.preparation,origin);assert(prep.complete);assert.equal(prep.backend,'direct');assert.equal(prep.sources.length,23);
 const seen=new Set();
 for(const item of prep.sources){
  const receipt=read(item.emission,origin),source=pin(item.source),reference=pin(receipt.output);
  assert(receipt.complete&&receipt.observation.checked&&receipt.observation.status==='ok');assert(!seen.has(source.file));seen.add(source.file);
  const result=await selected.D.inspect(source.file,{mode:'library',backend:'direct'}),{code,...observation}=result;
  assert.equal(result.status,'ok',result.diagnostic);assert(result.checked&&result.typeAccepted);assert.equal(result.exitCode,0);assert.equal(result.backend,'direct');
  for(const file of result.files)pin(file);
  const target=path.join(out,`module-${rows.length}.mjs`);fs.writeFileSync(target,code,{flag:'wx'});
  const row={source,reference,output:pin(target),observation,exact:Buffer.from(code).equals(fs.readFileSync(reference.file))};rows.push(row);
  fs.writeFileSync(path.join(out,'progress.json'),JSON.stringify({completed:rows.length,last:source.file,exact:row.exact})+'\n');
  assert(row.exact,'Changed JavaScript output: '+source.file);
 }
 report.finalVerification=await selected.verifyFinal();for(const row of inputs.values())verify(row);
 report.complete=true;report.pass=true;report.counts={sources:23,benchmarkPoints:45};
}catch(error){report.error={message:error.message,stack:error.stack};process.exitCode=1;}
finally{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error?.message}));}
