// Root-run source-check + identical C compiler, diagnostic message on refusal.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../../../..');
const [manifestArg]=process.argv.slice(2);
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const m=JSON.parse(fs.readFileSync(manifestArg,'utf8'));
assert(m.complete&&m.inverseByteIdentical&&!m.targetsRun&&!m.compilerAlgorithmChanged&&!m.arityLimitChanged);
assert.equal(m.kind,'phase144-upstream-arity-observer-preparation');
assert.equal(m.upstream.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');
assert.deepEqual(pin(import.meta.filename),m.runner);assert.deepEqual(pin(process.execPath),m.host);
for(const p of [m.source,m.original,m.clone,m.bend,m.method,...m.upstream.inputs])assert.deepEqual(pin(p.file),p);
let text=fs.readFileSync(m.clone.file,'utf8');
for(const p of [...m.changes].reverse()){assert.equal(text.split(p.after).length,2);text=text.replace(p.after,p.before);}
assert.equal(text,fs.readFileSync(m.original.file,'utf8'));
const out=path.resolve(m.outputDirectory);assert(out.startsWith(root+'/selfhost/build/phase144/'));
assert(!fs.existsSync(out+'/report.json'));
const r={kind:'phase144-upstream-arity-diagnostic',complete:false,compilerSucceeded:false,producedC:false,
  source:m.source,preparation:pin(manifestArg),method:pin(import.meta.filename),host:m.host,
  original:m.original,clone:m.clone,bend:m.bend,upstream:m.upstream,phases:[]};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(r,null,2)+'\n');save();
async function phase(name,fn){const start=performance.now();r.currentPhase=name;save();try{const value=await fn();r.phases.push({name,ms:performance.now()-start,complete:true});delete r.currentPhase;save();return value;}catch(e){r.phases.push({name,ms:performance.now()-start,complete:false});save();throw e;}}
const B=await import(pathToFileURL(m.bend.file));
const C=await import(pathToFileURL(m.clone.file));
try{
 const book=B.book_nil(),seen=new Map();
 await phase('load',()=>B.book_load(book,m.source.file,'',seen));r.loadedFiles=[...seen.keys()].map(pin);
 await phase('check',()=>{B.book_valid(book);assert.equal(book.hols,0);});r.sourceChecked=true;r.holes=book.hols;
 const code=await phase('emit-c',()=>C.compile_book(book));
 r.compilerSucceeded=true;r.unexpectedSuccess=true;r.codeBytes=Buffer.byteLength(code);r.codeSha256=createHash('sha256').update(code).digest('hex');
 r.error='Expected the original arity refusal; no C artifact is written by this observer.';process.exitCode=1;
}catch(e){
 r.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);
 const marker='\nP144_ARITY=';const message=e?.message??'';const at=message.indexOf(marker);
 if(message.startsWith('an arity over 247')&&at>=0){r.diagnostic=JSON.parse(message.slice(at+marker.length));assert.equal(r.diagnostic.kind,'phase144-upstream-live-arity-refusal');r.expectedRefusal=true;r.complete=true;}
 else process.exitCode=1;
}
for(const p of [m.source,m.original,m.clone,m.bend,m.method,m.runner,...m.upstream.inputs,...r.loadedFiles??[]])assert.deepEqual(pin(p.file),p);
r.maxRssKiB=process.resourceUsage().maxRSS;save();
console.log(JSON.stringify({complete:r.complete,compilerSucceeded:r.compilerSucceeded,expectedRefusal:r.expectedRefusal??false,
 phases:r.phases,oversizedEntries:r.diagnostic?.oversizedEntryCount,owners:r.diagnostic?.oversizedEntries.map(x=>({owner:x.sourceOwner,fid:x.fid,words:x.paramsWords})),maxRssKiB:r.maxRssKiB}));
