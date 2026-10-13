// Diagnostic request only: compare the owned preparation to the raw consumer.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [planFile,roleName,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>({file:path.resolve(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),role=plan.roles[roleName];
const report={complete:false,pass:false,plan:pin(planFile),method:pin(import.meta.filename),role:roleName,rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
 for(const p of plan.inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
 process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
 const D=await import(pathToFileURL(role.driver.file)),api=await D.loadApi(),prepare=api.nr_prepare_annotated;
 assert.equal(typeof prepare,'function');let calls=0;
 api.nr_prepare_annotated=(...args)=>{
  const owned=prepare(...args),raw=api.nr_prepare(owned.source);
  for(const key of ['source','book','names','paths','scope'])assert.deepEqual(owned[key],raw[key],key);
  assert.equal(owned.bound.$,'Some');assert.equal(raw.bound.$,'None');calls++;
  return owned;
 };
 for(const [name,source] of Object.entries(plan.cases)){
  const result=await D.inspect(source.input.file,{mode:'native',withReport:true});
  assert.equal(result.status,'ok');assert.equal(result.checked,true);
  assert.equal(createHash('sha256').update(result.code).digest('hex'),source.expected[roleName].sha256);
  report.rows.push({name,exactPreparation:true,exactC:true,verdict:result.verdict});
 }
 assert.equal(calls,report.rows.length);report.complete=true;report.pass=true;
 for(const p of plan.inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
}catch(error){report.error=error.stack;process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.rows.length,error:report.error}));
