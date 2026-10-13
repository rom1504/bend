// Diagnostic only: observe actual conservative annotation versus runtime demand.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [planFile,caseName,out]=process.argv.slice(2);
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const plan=JSON.parse(fs.readFileSync(planFile)),role=plan.roles.b2,source=plan.cases[caseName];
const verify=p=>assert.equal(pin(p.file).sha256,p.sha256,p.file);
for(const p of plan.inputs)verify(p);
const prep=JSON.parse(fs.readFileSync(role.preparation));assert(prep.complete&&prep.pass);
assert.equal(prep.plan.sha256,pin(planFile).sha256);prep.cache.forEach(verify);
process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
const D=await import(pathToFileURL(role.driver.file)),api=await D.loadApi();
const list=xs=>{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return out;};
const report={case:caseName,plan:pin(planFile),method:pin(import.meta.filename),api:role.api,complete:false};
const original=api.annotate_selected;
api.annotate_selected=(book,defs,stops)=>{
 const stopped=new Set(list(stops)),selected=list(defs);
 report.selected=selected.map(d=>({name:d.name,kind:d.kind,templates:d.templates,stopped:stopped.has(d.name),valueTag:d.value?.tag??d.value?.$}));
 return original(book,defs,stops);
};
const prepare=api.nr_prepare_annotated;
api.nr_prepare_annotated=(...args)=>{
 const result=prepare(...args);report.runtimeNames=list(result.names);
 report.erasedFacts=list(result.book).filter(d=>d.kind==='NativeErasedBody').map(d=>d.name);
 return result;
};
const result=await D.inspect(source.input.file,{mode:'native',withReport:true});
assert.equal(result.status,'ok');assert(result.checked);assert.equal(hash(result.code),source.expected.b2.sha256);
for(const p of plan.inputs)verify(p);prep.cache.forEach(verify);
report.exactC=true;report.complete=true;report.pass=true;
report.scope='Observation of baseline B2 only, not timing. Selection may include type-only declarations; runtimeNames includes native/foreign names. No compiler or semantic algorithm changed.';
fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({case:caseName,selected:report.selected.length,runtime:report.runtimeNames.length,erasedFacts:report.erasedFacts.length}));
