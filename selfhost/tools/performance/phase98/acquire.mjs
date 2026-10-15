// Root-run checked upstream acquisition of an isolated Bend candidate/control.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [sourceArg,outArg]=process.argv.slice(2);
const source=fs.realpathSync(sourceArg),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase98/'));fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const baseline=JSON.parse(fs.readFileSync(root+'/selfhost/build/phase86/upstream.json'));
assert.equal(baseline.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');
for(const p of baseline.inputs)assert.deepEqual(pin(p.file),p);
const upstream=root+'/selfhost/.bootstrap/upstream-phase66/bend2';
const B=await import(pathToFileURL(upstream+'/bend.ts'));
const C=await import(pathToFileURL(upstream+'/comp.ts'));
const report={complete:false,source:pin(source),method:pin(import.meta.filename),host:pin(process.execPath),upstream:baseline,phases:[]};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
async function phase(name,fn){const t=performance.now();report.currentPhase=name;save();const x=await fn();report.phases.push({name,ms:performance.now()-t});delete report.currentPhase;save();return x;}
try{
  const book=B.book_nil(),seen=new Map();
  await phase('load',()=>B.book_load(book,source,'',seen));
  report.loadedFiles=[...seen.keys()].map(pin);
  await phase('check',()=>{B.book_valid(book);assert.equal(book.hols,0);});report.holes=book.hols;
  const code=await phase('emit-c',()=>C.compile_book(book));assert.equal(typeof code,'string');assert(code.length);
  fs.writeFileSync(out+'/program.c',code,{flag:'wx'});report.c=pin(out+'/program.c');
  for(const p of [...baseline.inputs,report.source,...report.loadedFiles])assert.deepEqual(pin(p.file),p);
  report.complete=true;
}catch(e){report.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);process.exitCode=1;console.error(report.error);}
report.maxRssKiB=process.resourceUsage().maxRSS;save();console.log(JSON.stringify({complete:report.complete,phases:report.phases,c:report.c,error:report.error}));
