import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'..');
const upstream=process.env.BEND_UPSTREAM||path.join(root,'.bootstrap/upstream');
const B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-fixtures-'));
const results=[];
try{
 for(const t of JSON.parse(fs.readFileSync(path.join(root,'tests/cases.json'),'utf8'))){
  if(t.error)continue;
  const file=path.join(dir,'main.bend');fs.writeFileSync(file,t.source);
  try{const b=B.book_nil();await B.book_load(b,file,'',new Map());B.book_valid(b);if(b.hols+b.open)throw Error('unresolved laws or holes');results.push({name:t.name,status:'pass'})}
  catch(e){results.push({name:t.name,status:'fail',error:e?.$==='Err'?B.err_show(e):String(e)})}
 }
 fs.writeFileSync(path.join(root,'dist/fixture-typecheck-report.json'),JSON.stringify(results,null,2)+'\n');
 const passed=results.filter(x=>x.status==='pass').length;
 console.log(`${passed}/${results.length} positive fixtures accepted by upstream`);
 if(passed!==results.length){console.error(results.filter(x=>x.status==='fail'));process.exitCode=1}
}finally{fs.rmSync(dir,{recursive:true,force:true})}
