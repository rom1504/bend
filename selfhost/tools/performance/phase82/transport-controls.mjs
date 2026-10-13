// All mutations are confined to a new diagnostic project, never a frozen input.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptFile,sourceFile,outArg]=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>({file:path.resolve(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const a=JSON.parse(fs.readFileSync(attemptFile,'utf8')),project=path.join(out,'project');
const report={complete:false,pass:false,attempt:pin(attemptFile),source:pin(sourceFile),method:pin(import.meta.filename),rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
 assert(a.checked);assert.equal(pin(a.api.file).sha256,a.api.sha256);
 fs.cpSync(path.join(a.snapshot.root,'tools'),path.join(project,'tools'),{recursive:true});
 for(const rel of ['src/compiler.json','src/runtime.mjs','src/runtime/native']){
  const dest=path.join(project,rel);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.cpSync(path.join(a.snapshot.root,rel),dest,{recursive:true});
 }
 process.env.BEND_TYPED_API=a.api.file;process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');process.env.BEND_BASE=a.base.file;
 const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));
 await D.prepareBase(undefined,{backendProducts:false});
 const artifact=path.join(project,'src/runtime/native/runtime-template.json'),runtime=path.join(project,'src/runtime/native/runtime.c');
 const original=fs.readFileSync(artifact),text=fs.readFileSync(runtime,'utf8');
 const request=async name=>{
  const r=await D.inspect(sourceFile,{mode:'native',withReport:true});assert.equal(r.status,'ok');assert(r.checked);
  report.rows.push({name,template:r.files.includes(artifact),verdict:r.verdict,sha256:createHash('sha256').update(r.code).digest('hex')});return r;
 };
 const ordinary=await request('canonical');assert(report.rows.at(-1).template);
 fs.rmSync(artifact);const absent=await request('absent');assert.equal(absent.code,ordinary.code);assert(!report.rows.at(-1).template);
 fs.writeFileSync(artifact,'invalid artifact\n');const modified=await request('modified');assert.equal(modified.code,ordinary.code);assert(!report.rows.at(-1).template);
 fs.writeFileSync(artifact,original);fs.writeFileSync(runtime,text+'\n// custom runtime suffix\n');
 const custom=await request('custom-runtime');assert.equal(custom.code,ordinary.code+'\n// custom runtime suffix\n');assert(!report.rows.at(-1).template);
 fs.writeFileSync(runtime,text);
 const injected=await D.inspect(sourceFile,{mode:'native',withReport:true,api:await D.loadApi()});
 assert.equal(injected.status,'ok');assert.equal(injected.code,ordinary.code);assert(!injected.files.includes(artifact));
 report.rows.push({name:'injected-api',template:false,exactC:true});
 for(const row of report.rows.slice(0,4))assert.equal(row.verdict,ordinary.verdict);
 report.complete=true;report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.rows.length,error:report.error}));
