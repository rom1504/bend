// Bootstrap-only: type-check compiler modules and expose a JS testing API.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const upstream=process.env.BEND_UPSTREAM||path.resolve(import.meta.dirname,'../.bootstrap/upstream');
const B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
try{
  const book=B.book_nil();await B.book_load(book,path.resolve(process.argv[2]),'',new Map());
  B.book_valid(book);C.book_owned(book,C.SYNTH);
  if(book.hols+book.open)throw Error('Unresolved laws/holes: '+(book.hols+book.open));
  const roots=process.argv.slice(4);
  const names=roots.length?roots:[...new Set(book.order)].filter(k=>{
    const d=book.tlds[k];return d.$==='Def'&&d.v!==null&&!d.b&&!d.i&&!d.x&&C.io_base(book,d.T)===null;
  });
  fs.writeFileSync(process.argv[3],C.js_lib(book,names,names));
  console.error(`Checked ${names.length} API exports`);
}catch(e){console.error(e?.$==='Err'?B.err_show(e):String(e));process.exitCode=1}
