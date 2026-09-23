// Preserve accepted raw parser graphs and earlier-error text across the narrow namespace fix.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const id=f=>({file:path.resolve(f),sha256:hash(f)});
const [beforeArg,afterArg,selectionArg,outArg]=process.argv.slice(2);
assert.ok(outArg,'BEFORE_PROOF AFTER_PROOF SELECTION NEW_REPORT');
const out=path.resolve(outArg);assert.ok(!fs.existsSync(out));
const report={kind:'phase5-namespace-raw-equality',complete:false,started:new Date().toISOString(),inputs:[id(import.meta.filename),id(process.execPath),id(beforeArg),id(afterArg),id(selectionArg)],rows:[]};
try {
 const proofs=[beforeArg,afterArg].map(f=>JSON.parse(fs.readFileSync(f)));
 for(const p of proofs){
  assert.equal(p.stage,'upstream-bootstrap');assert.equal(p.provenance.verifiedAfterBuild,true);
  assert.equal(hash(p.apiPath),p.apiSha256);assert.equal(hash(p.source),p.sourceSha256);
  report.inputs.push(id(p.apiPath),id(p.source),...p.provenance.inputs);
 }
 const apis=await Promise.all(proofs.map(async p=>(await import(pathToFileURL(p.apiPath))).default));
 const cases=JSON.parse(fs.readFileSync(selectionArg)).cases;
 for(const item of cases){
  if(!item.accept&&!item.id.includes('earlier-'))continue;
  const file=path.resolve(path.dirname(path.resolve(selectionArg)),item.file);report.inputs.push(id(file));
  const source=fs.readFileSync(file,'utf8'),a=apis[0].f_parse(source),b=apis[1].f_parse(source);
  if(item.accept){assert.equal(a.error,'',item.id);assert.equal(b.error,'',item.id);assert.deepEqual(b,a,item.id);}
  else {assert.notEqual(a.error,'',item.id);assert.equal(b.error,a.error,item.id);}
  const raw=JSON.stringify(b);report.rows.push({id:item.id,scope:item.accept?'exact accepted raw result':'exact earlier-error text',exact:true,error:b.error,rawJsonBytes:Buffer.byteLength(raw),rawJsonSha256:createHash('sha256').update(raw).digest('hex')});
 }
 assert.ok(report.rows.length>0);
 for(const x of report.inputs)assert.equal(hash(x.file),x.sha256,'input drift: '+x.file);
 report.complete=true;
}catch(error){report.error=String(error.stack);process.exitCode=1;}
report.finished=new Date().toISOString();fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
