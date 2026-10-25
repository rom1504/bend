// A lexer landmark selects a hint; only the real parser produces a checkpoint.
import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import crypto from'node:crypto';import{pathToFileURL}from'node:url';
const[apiFile,outArg]=process.argv.slice(2),out=path.resolve(outArg),rec=JSON.parse(fs.readFileSync(apiFile));const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};const verify=p=>assert.deepEqual(pin(p.file),p);assert(rec.complete&&rec.checked);rec.inputs.forEach(verify);verify(rec.api);assert(!fs.existsSync(out));fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase140-parser-hint-controls',complete:false,inputs:[pin(import.meta.filename),pin(apiFile),rec.api,...rec.inputs],rows:[]};const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
try{const api=(await import(pathToFileURL(rec.api.file))).default;const scope=api.f_parse_scope_empty();
 for(const[name,prefix,suffix,position,expected]of[
 ['body-offset','def first(x: U32) -> U32:\n  x\n\n','def main() -> U32:\n  1\n','  1',true],
 ['unsafe-body-offset','@unsafe\ndef first(x: U32) -> U32:\n  x\n\n@unsafe\n','def main() -> U32:\n  1\n','  1',true],
 ['unicode-body-offset','# 😀\ndef first(x: U32) -> U32:\n  x\n\n','def main() -> U32:\n  1\n','  1',true],
 ['at-keyword','def first(x: U32) -> U32:\n  x\n\n','def main() -> U32:\n  1\n','def main',true],
 ['disabled','def first(x: U32) -> U32:\n  x\n\n','def main() -> U32:\n  1\n',null,false],
 ['before-first-keyword','','def main() -> U32:\n  1\n','def main',false]
 ]){const a=prefix+suffix,b=prefix+suffix.replace('  1','  2'),hint=position===null?0:a.indexOf(position)+1;const seeded=api.p140p_seed_before(a,api.p140pt_header(a,1),scope,1,hint);assert(api.p140pt_same(seeded.result,api.p140pt_fresh(a,scope,1)));const warm=api.p140p_resume(b,api.p140pt_header(b,1),scope,1,seeded.cache);assert.equal(warm.hit,expected,name);assert(api.p140pt_same(warm.result,api.p140pt_fresh(b,scope,1)));const cut=seeded.cache.$==='Some'?seeded.cache.value.token.begin:null;if(cut!==null)assert(cut<=hint);report.rows.push({name,hint,cut,hit:warm.hit,exactFresh:true});}
 const tok=(text,begin,col=0)=>({$:'FToken',text,line:1,col,kind:0,begin,end:begin+text.length,previousEnd:begin-1});const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
 for(const[name,tokens,hint,want]of[['nearest',[tok('def',10),tok('law',20),tok('type',30)],29,20],['ignore-inner-column',[tok('def',10),tok('law',20,2)],29,10],['not-a-keyword',[tok('def',10),tok('define',20)],29,10],['early-hint',[tok('def',10)],5,0]]){assert.equal(api.p140p_landmark(list(tokens),hint,0),want);report.rows.push({name,want,pass:true});}
 report.inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1;}finally{save();console.log(JSON.stringify(report));}
