import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const [planFile,extraFile,role,out]=process.argv.slice(2);fs.mkdirSync(out);const plan=JSON.parse(fs.readFileSync(planFile)),extra=JSON.parse(fs.readFileSync(extraFile));const r=plan.roles[role];
const pin=f=>({file:path.resolve(f),sha256:createHash('sha256').update(fs.readFileSync(f)).digest('hex')});
const inputs=[...plan.inputs,...extra.inputs];for(const p of inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
const report={complete:false,pass:false,role,plans:[pin(planFile),pin(extraFile)],method:pin(import.meta.filename),records:[]};const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 let session,B,C;if(role==='b2'){
  process.env.BEND_TYPED_API=r.api.file;process.env.BEND_TYPED_RUNTIME=r.runtime.file;process.env.BEND_BASE=r.base.file;
  const tool=path.resolve('selfhost/tools/native-session.mjs'),copy=path.join(r.project,'tools/native-session.mjs');assert(!fs.existsSync(copy));fs.copyFileSync(tool,copy);report.tool=pin(tool);report.toolCopy=pin(copy);
  const S=await import(pathToFileURL(copy));session=await S.createNativeSession({maxRequests:40});
 }else{B=await import(pathToFileURL(r.bend.file));C=await import(pathToFileURL(r.compiler.file));}
 const cases={...plan.cases,...extra.cases};let names=Object.keys(cases);
 for(let round=0;round<6;round++){
  const order=names.slice(round%names.length).concat(names.slice(0,round%names.length));
  for(const name of order){const c=cases[name];const start=performance.now();let code,internal;
   if(session){const result=await session.compile(c.input.file);assert.equal(result.status,'ok');assert.equal(result.recycle,false);code=result.code;internal=result.requestMs;}
   else{const book=B.book_nil();await B.book_load(book,c.input.file,'',new Map());B.book_valid(book);assert.equal(book.hols,0);code=C.compile_book(book);}
   const elapsedMs=performance.now()-start;assert.equal(code,fs.readFileSync(c.expected[role].file,'utf8'));
   report.records.push({round,case:name,elapsedMs,requestMs:internal??elapsedMs,rssBytes:process.memoryUsage().rss,exactC:true});save();
  }
 }
 for(const p of inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);report.complete=report.pass=true;
}catch(error){report.error=error.stack;process.exitCode=1;}save();console.log(JSON.stringify({role,pass:report.pass,requests:report.records.length,error:report.error}));
