// Recheck an explicitly recorded Bend source derivative; upstream stays unchanged.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [parentFile,derivationFile,outArg]=process.argv.slice(2);assert(outArg);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const verify=p=>{const v=pin(p.file);assert.equal(v.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(v.bytes,p.bytes);return v;};
const parent=JSON.parse(fs.readFileSync(parentFile)),derivation=JSON.parse(fs.readFileSync(derivationFile));
assert(parent.complete&&derivation.complete);
assert.equal(parent.upstream,'059266225b77c8ca256ac6b25ee5c21449bab151');
assert(['phase89-native-owned01-body-chunks-derivative','phase89-native-nine-effect-entry-derivative'].includes(derivation.kind));
assert(derivation.inverseRecoversParent===true || derivation.remainingBytesExact===true);
assert.equal(derivation.inputs[0].sha256,parent.source.sha256);
const inputs=[...parent.inputs,...derivation.inputs,parent.source,derivation.output].map(verify);
inputs.push(...[parentFile,derivationFile,import.meta.filename,process.execPath].map(pin));
const report={kind:'phase89-checked-native-source-derivative',derivation:pin(derivationFile),parent:pin(parentFile),complete:false,upstream:parent.upstream,inputs,phases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const phase=async(name,fn)=>{const at=performance.now();report.currentPhase=name;save();console.log('START '+name);const v=await fn();report.phases.push({name,ms:performance.now()-at});delete report.currentPhase;save();console.log('DONE '+name);return v;};
const root=path.resolve(import.meta.dirname,'../../../..'),up=path.join(root,'selfhost/.bootstrap/upstream-phase66/bend2');
const B=await import(pathToFileURL(path.join(up,'bend.ts'))),C=await import(pathToFileURL(path.join(up,'comp.ts')));
try{
  const source=path.join(out,'compiler.bend');fs.copyFileSync(derivation.output.file,source);report.source=pin(source);save();
  const book=B.book_nil();await phase('load',()=>B.book_load(book,source,'',new Map()));
  await phase('check',()=>{B.book_valid(book);assert.equal(book.hols,0);});
  for(const [key,name,emit] of [['js','compiler.cjs',C.js_book],['c','compiler.c',C.compile_book]]){
    const file=path.join(out,name);fs.writeFileSync(file,await phase('emit-'+key,()=>emit(book)),{flag:'wx'});report[key]=pin(file);save();
  }
  for(const p of inputs)verify(p);report.complete=true;
}catch(e){report.error=e?.$==='Err'?B.err_show(e):e.stack??String(e);console.error(report.error);process.exitCode=1;}
report.maxRssKiB=process.resourceUsage().maxRSS;save();
