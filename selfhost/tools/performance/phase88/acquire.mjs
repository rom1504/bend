// Phase88 checked current-source native/JS acquisition; entry and source are frozen in output.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {assemble} from '../../assemble.mjs';
const root=path.resolve(import.meta.dirname,'../../../..');
const project=path.join(root,'selfhost'),upstream=path.join(project,'.bootstrap/upstream-phase66');
const out=path.resolve(process.argv[2]);fs.mkdirSync(out,{recursive:false});
fs.copyFileSync(import.meta.filename,path.join(out,'acquire.mjs'));
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const manifestFile=path.join(project,'src/compiler.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));
const entry=path.resolve(process.argv[3]??path.join(root,'selfhost/tools/performance/phase86/entry.bend'));
const mode=process.argv[4]??'both';assert(['both','js','c'].includes(mode));
const inputs=[manifestFile,...manifest.modules.map(f=>path.join(project,f)),entry,
  path.join(project,'tools/assemble.mjs'),import.meta.filename,process.execPath,
  ...['bend.ts','comp.ts','base.bend'].map(f=>path.join(upstream,'bend2',f)),
  ...fs.readdirSync(path.join(upstream,'bend2/effs')).sort().filter(f=>/\.(c|js)$/.test(f)).map(f=>path.join(upstream,'bend2/effs',f))].map(pin);
const report={kind:'phase88-checked-native-bootstrap',mode,complete:false,started:new Date().toISOString(),inputs,upstream:manifest.upstream,phases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
let B;
const phase=async(name,fn)=>{report.currentPhase=name;save();console.log('START '+name);const at=performance.now();const result=await fn();report.phases.push({name,ms:performance.now()-at});delete report.currentPhase;save();console.log('DONE '+name);return result;};
try {
  // Bind exact upstream source bytes to the retained checked toolchain receipt;
  // this worker need not spawn git inside the restricted Node sandbox.
  const provenance=path.join(project,'build/phase86/upstream.json');
  const previous=JSON.parse(fs.readFileSync(provenance));
  assert.equal(previous.revision,manifest.upstream);assert.equal(previous.status,'');
  for(const p of inputs.filter(p=>p.file.startsWith(upstream+'/'))){
    const old=previous.inputs.find(i=>i.file===p.file);assert(old,'Missing pinned upstream input '+p.file);
    assert.equal(old.sha256,p.sha256,p.file);
  }
  report.upstreamPinEvidence=pin(provenance);save();
  fs.copyFileSync(entry,path.join(out,'entry.bend'));
  const source=path.join(out,'compiler.bend');
  report.assembly=assemble([...manifest.modules,path.join(out,'entry.bend')],source,{root:project});report.source=pin(source);save();
  B=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
  const C=await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
  const book=B.book_nil();
  await phase('load',()=>B.book_load(book,source,'',new Map()));
  await phase('check',()=>{B.book_valid(book);assert.equal(book.hols,0);});
  if(mode!=='c'){
  const js=path.join(out,'compiler.cjs');
  fs.writeFileSync(js,await phase('emit-js',()=>C.js_book(book)),{flag:'wx'});report.js=pin(js);save();
  }
  if(mode!=='js'){
  const c=path.join(out,'compiler.c');
  fs.writeFileSync(c,await phase('emit-c',()=>C.compile_book(book)),{flag:'wx'});report.c=pin(c);save();
  }
  for(const p of inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;
} catch(e) {report.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);process.exitCode=1;console.error(report.error);}
report.finished=new Date().toISOString();report.maxRssKiB=process.resourceUsage().maxRSS;save();
