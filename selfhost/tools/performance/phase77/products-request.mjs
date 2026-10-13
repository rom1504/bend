import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const [planFile,caseName,out]=process.argv.slice(2);fs.mkdirSync(out);const j=JSON.parse(fs.readFileSync(planFile)),r=j.roles.memo;const pin=f=>({file:path.resolve(f),sha256:createHash('sha256').update(fs.readFileSync(f)).digest('hex')});
for(const p of j.inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
process.env.BEND_TYPED_API=r.api.file;process.env.BEND_TYPED_RUNTIME=r.runtime.file;process.env.BEND_BASE=r.base.file;
const D=await import(pathToFileURL(r.driver.file));const api=await D.loadApi();let calls=0;const orig=api.annotate_selected_base;api.annotate_selected_base=(...xs)=>{calls++;return orig(...xs);};
const start=performance.now();await D.prepareBase(undefined,{backendProducts:true});const preparationMs=performance.now()-start;
const products=fs.readdirSync(D.baseAnnotationDirectory).map(n=>pin(path.join(D.baseAnnotationDirectory,n)));assert(products.length>0);
const rows=[];for(let i=0;i<3;i++){const at=performance.now();const result=await D.inspect(j.cases[caseName].input.file,{mode:'native',withReport:true});const ms=performance.now()-at;assert.equal(result.status,'ok');assert.equal(result.code,fs.readFileSync(j.cases[caseName].expected.b2.file,'utf8'));rows.push({round:i,requestMs:ms,exactC:true});}
assert.equal(calls,3,'Product was not admitted on every request');for(const p of j.inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,pass:true,case:caseName,preparationMs,products,calls,rows,plan:pin(planFile),method:pin(import.meta.filename),scope:'First request after explicit product preparation plus two warm requests, exact C. Diagnostic host derivative only.'},null,2)+'\n');console.log(JSON.stringify({case:caseName,preparationMs,rows}));
