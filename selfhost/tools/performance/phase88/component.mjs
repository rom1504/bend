// Checked standalone Bend controls; no full compiler manifest or source rewriting.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [sourceArg,outArg]=process.argv.slice(2);
assert(sourceArg&&outArg);
const source=path.resolve(sourceArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const up=path.join(root,'selfhost/.bootstrap/upstream-phase66/bend2');
const inputs=[source,import.meta.filename,process.execPath,...['bend.ts','comp.ts','base.bend'].map(n=>path.join(up,n))].map(pin);
const report={complete:false,inputs};
const B=await import(pathToFileURL(path.join(up,'bend.ts'))),C=await import(pathToFileURL(path.join(up,'comp.ts')));
try{
  fs.copyFileSync(source,path.join(out,'source.bend'));
  const book=B.book_nil();await B.book_load(book,source,'',new Map());B.book_valid(book);assert.equal(book.hols,0);
  for(const [name,emit] of [['program.cjs',C.js_book],['program.c',C.compile_book]]){
    const file=path.join(out,name);fs.writeFileSync(file,emit(book),{flag:'wx'});report[name]=pin(file);
  }
  for(const p of inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;
}catch(e){report.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
