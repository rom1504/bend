// Context controls: ordinary current B2 host and pinned handwritten TypeScript.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [role,input,output,callsArg]=process.argv.slice(2),calls=Number(callsArg);
const root=path.resolve(import.meta.dirname,'../../../..');
const parent=JSON.parse(fs.readFileSync(path.join(root,'selfhost/build/phase83/survey01/plan.json')));
const r=parent.roles[role];assert(r&&calls>=1&&calls<=5);
const hash=s=>createHash('sha256').update(s).digest('hex');
const verify=p=>assert.equal(hash(fs.readFileSync(p.file)),p.sha256,p.file);
const report={role,calls:[],complete:false};
let D,B,C;
const at=performance.now();
if(role==='typescript'){
  verify(r.bend);verify(r.compiler);verify(r.base);
  B=await import(pathToFileURL(r.bend.file));C=await import(pathToFileURL(r.compiler.file));
}else{
  assert.equal(role,'b2');verify(r.api);verify(r.driver);verify(r.runtime);verify(r.base);
  process.env.BEND_TYPED_API=r.api.file;process.env.BEND_TYPED_RUNTIME=r.runtime.file;process.env.BEND_BASE=r.base.file;
  D=await import(pathToFileURL(r.driver.file));await D.loadApi();
}
report.importsMs=performance.now()-at;
for(let i=1;i<=calls;i++){
  let code,observation;const start=performance.now();
  try{
    if(role==='typescript'){
      const book=B.book_nil();await B.book_load(book,input,'',new Map());B.book_valid(book);assert.equal(book.hols,0);
      code=C.compile_book(book);observation={status:'ok',checked:true};
    }else{const result=await D.inspect(input,{mode:'native',withReport:true});({code,...observation}=result);}
    const requestMs=performance.now()-start;
    const row={index:i,requestMs,observation};
    if(code!==undefined){fs.writeFileSync(output+'.'+i+'.c',code,{flag:'wx'});row.sha256=hash(code);row.bytes=Buffer.byteLength(code);}
    report.calls.push(row);assert.equal(observation.status,'ok');
  }catch(e){report.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);process.exitCode=1;break;}
}
report.complete=!report.error;report.maxRssKiB=process.resourceUsage().maxRSS;
fs.writeFileSync(output+'.json',JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(report));
