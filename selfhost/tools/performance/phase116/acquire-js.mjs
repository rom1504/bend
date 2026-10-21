import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';import assert from 'node:assert/strict';
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.join(root,'selfhost/build/phase116/js01');fs.mkdirSync(out);
const pin=p=>({file:p,bytes:fs.statSync(p).size,sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const manifest=JSON.parse(fs.readFileSync(path.join(root,'selfhost/build/phase116/manifest01.json')));for(const p of manifest.inputs)assert.equal(pin(p.file).sha256,p.sha256);
const report={complete:false,inputs:[pin(import.meta.filename),pin(path.join(root,'selfhost/build/phase116/manifest01.json'))],cases:[]};const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const B=await import(pathToFileURL(path.join(root,'selfhost/.bootstrap/upstream-phase66/bend2/bend.ts'))),C=await import(pathToFileURL(path.join(root,'selfhost/.bootstrap/upstream-phase66/bend2/comp.ts'))),D=await import(pathToFileURL(path.join(root,'selfhost/tools/typed-driver.mjs')));
for(const c of manifest.cases){let row={name:c.name,source:c.source,products:{}};report.cases.push(row);save();
 for(const role of ['upstream_js','selfhost_js']){const start=performance.now();let code;
 try{if(role==='upstream_js'){const book=B.book_nil();await B.book_load(book,c.source.file,'',new Map());B.book_valid(book);assert.equal(book.hols,0);code=C.js_book(book);}else{const r=await D.inspect(c.source.file,{mode:'compile',backend:'direct',withReport:true,timeoutMs:120000});assert.equal(r.status,'ok');assert.equal(r.checked,true);code=r.code;row.foreignInputs=r.files.map(pin);}
 const f=path.join(out,c.name+'-'+role+(role==='selfhost_js'?'.mjs':'.cjs'));fs.writeFileSync(f,code,{flag:'wx'});row.products[role]=pin(f);row[role+'Seconds']=(performance.now()-start)/1000;save();console.log(c.name,role,row[role+'Seconds']);
 }catch(e){row.error=e.stack??String(e);save();throw e;}}
}
for(const p of manifest.inputs)assert.equal(pin(p.file).sha256,p.sha256);report.complete=true;save();
