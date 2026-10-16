// Cheap independent frontend checks for every control before native emission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../..');
const [manifestArg,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase102/'));fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const upstream=root+'/selfhost/.bootstrap/upstream-phase66/bend2';
const B=await import(pathToFileURL(upstream+'/bend.ts'));
const baseline=JSON.parse(fs.readFileSync(root+'/selfhost/build/phase86/upstream.json'));
assert.equal(baseline.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');
for(const p of baseline.inputs) assert.deepEqual(pin(p.file),p);
const manifest=JSON.parse(fs.readFileSync(manifestArg));
const report={complete:false,allPassed:false,method:pin(import.meta.filename),manifest:pin(manifestArg),upstream:baseline,rows:[],scope:'Independent pinned-upstream frontend preflight only, no native emission or behavioral qualification.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
for(const source of new Set(manifest.records.map(r=>r.source))){
  const row={source:pin(source),passed:false};report.rows.push(row);
  try{const book=B.book_nil(),seen=new Map();await B.book_load(book,source,'',seen);B.book_valid(book);assert.equal(book.hols,0);row.loaded=[...seen.keys()].map(pin);row.passed=true;}
  catch(e){row.error=e?.$==='Err'?B.err_show(e):String(e.stack??e);}
  console.log(JSON.stringify({source,passed:row.passed,error:row.error}));save();
  if(typeof Bun.gc==='function')Bun.gc(true);
}
for(const p of baseline.inputs)assert.deepEqual(pin(p.file),p);
assert.deepEqual(pin(manifestArg),report.manifest);
for(const row of report.rows)assert.deepEqual(pin(row.source.file),row.source);
report.complete=true;report.allPassed=report.rows.every(r=>r.passed);save();
