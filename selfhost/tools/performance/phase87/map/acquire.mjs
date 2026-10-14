// Small upstream-checked Map sharing controls. Does not execute generated code.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root=path.resolve(import.meta.dirname,'../../../../..');
const upstream=path.join(root,'selfhost/.bootstrap/upstream-phase66');
const manifest=JSON.parse(fs.readFileSync(path.join(root,'selfhost/src/compiler.json')));
assert.equal(process.argv.length,4,'Usage: acquire.mjs CASE.bend NEW_OUTPUT_DIR');
const fixture=fs.realpathSync(process.argv[2]),out=path.resolve(process.argv[3]);
assert.equal(path.dirname(fixture),fs.realpathSync(import.meta.dirname),'Only this lane\'s frozen fixtures');
fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const provenance=path.join(root,'selfhost/build/phase86/upstream.json');
const old=JSON.parse(fs.readFileSync(provenance));
assert.equal(old.revision,manifest.upstream);assert.equal(old.status,'');
const inputs=[fixture,import.meta.filename,process.execPath,provenance,
  ...['bend.ts','comp.ts','base.bend'].map(f=>path.join(upstream,'bend2',f))].map(pin);
for(const p of inputs.filter(p=>p.file.startsWith(upstream+'/'))){
  const frozen=old.inputs.find(i=>i.file===p.file);
  assert(frozen,'Missing pin '+p.file);assert.equal(frozen.sha256,p.sha256,p.file);
}
const report={kind:'phase87-map-minimal-checked-acquisition',complete:false,upstream:manifest.upstream,inputs,phases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();fs.copyFileSync(import.meta.filename,path.join(out,'acquire.mjs'));
const source=path.join(out,'main.bend');fs.copyFileSync(fixture,source);report.source=pin(source);save();
let B;
const phase=async(name,fn)=>{report.currentPhase=name;save();const at=performance.now();const result=await fn();report.phases.push({name,ms:performance.now()-at});delete report.currentPhase;save();return result;};
try {
  B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
  const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
  const book=B.book_nil();
  await phase('load',()=>B.book_load(book,source,'',new Map()));
  await phase('check',()=>{B.book_valid(book);assert.equal(book.hols,0);});
  for(const [name,emit,ext] of [['js',()=>C.js_book(book),'cjs'],['c',()=>C.compile_book(book),'c']]){
    const file=path.join(out,'program.'+ext);
    fs.writeFileSync(file,await phase('emit-'+name,emit),{flag:'wx'});report[name]=pin(file);save();
  }
  for(const p of inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;
} catch(e) {
  report.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);
  process.exitCode=1;console.error(report.error);
}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
