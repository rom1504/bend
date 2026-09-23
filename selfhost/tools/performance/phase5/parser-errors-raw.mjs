// Exact accepted raw frontend results, plus explicit malformed-input fallback controls.
import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import{createHash}from'node:crypto';import{pathToFileURL}from'node:url';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex'),id=f=>({file:path.resolve(f),sha256:hash(f)}),digest=x=>createHash('sha256').update(x).digest('hex');
const[aArg,bArg,outArg]=process.argv.slice(2);assert.ok(outArg);const out=path.resolve(outArg);fs.mkdirSync(out);const proofs=[aArg,bArg].map(x=>JSON.parse(fs.readFileSync(x))),report={kind:'phase5-parser-raw-book-equality',complete:false,started:new Date().toISOString(),inputs:[id(import.meta.filename),id(process.execPath),id(aArg),id(bArg)],rows:[]};
try{
 for(const p of proofs){assert.equal(p.stage,'upstream-bootstrap');assert.equal(p.provenance.verifiedAfterBuild,true);assert.equal(hash(p.apiPath),p.apiSha256);assert.equal(hash(p.source),p.sourceSha256);report.inputs.push(id(p.apiPath),id(p.source),...p.provenance.inputs);}
 const apis=await Promise.all(proofs.map(async p=>(await import(pathToFileURL(p.apiPath))).default));
 const upstream=fs.realpathSync(process.env.BEND_UPSTREAM),sources=[['base',path.join(upstream,'bend2/base.bend')],['frozen-compiler',proofs[0].source],['list',path.join(upstream,'tests/base/list_sort.bend')]];
 for(const[name,file]of sources){report.inputs.push(id(file));const text=fs.readFileSync(file,'utf8');const a=apis[0].f_parse(text),b=apis[1].f_parse(text);assert.equal(a.error,'',name);assert.equal(b.error,'',name);assert.deepEqual(b,a,name);const json=JSON.stringify(a);report.rows.push({id:name,source:id(file),exact:true,rawJsonBytes:Buffer.byteLength(json),rawJsonSha256:digest(json)});}
 const observed=(api,text)=>{try{return{kind:'return',value:api.f_parse(text)}}catch(error){return{kind:'throw',value:String(error)}}};
 for(const[which,char]of[['high','\ud800'],['low','\udfff']]){const text='import Base\ndef main() -> U32:\n  (0'+char+')\n';const a=observed(apis[0],text),b=observed(apis[1],text);assert.deepEqual(b,a,which);report.rows.push({id:'malformed-UTF16-'+which,exact:true,scope:'Same raw API input string; cannot encode isolated surrogate as a normal UTF8 source file.',outcome:a.kind,...a.kind==='throw'?{throw:a.value}:{error:a.value.error}});}
 for(const x of report.inputs)assert.equal(hash(x.file),x.sha256,'changed input '+x.file);report.complete=true;
}catch(error){report.error=String(error.stack);process.exitCode=1;}
report.finished=new Date().toISOString();fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:report.complete,rows:report.rows,error:report.error}));
