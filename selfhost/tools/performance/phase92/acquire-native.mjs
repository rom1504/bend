// ROOT-RUN TARGET: recheck an exact native89 source derivative with pinned upstream.
// PARENT_CHECKED_REPORT SOURCE_DERIVATION NEW_OUTPUT_DIRECTORY. No C build/admission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

Error.stackTraceLimit=100;
const [parentArg,derivationArg,outArg]=process.argv.slice(2);
assert.equal(process.argv.length,5,'PARENT_CHECKED_REPORT SOURCE_DERIVATION NEW_OUTPUT_DIRECTORY');
const root=path.resolve(import.meta.dirname,'../../../..');
const out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase92/')),'Fresh Phase92 output required');
fs.mkdirSync(out,{recursive:false});
const upstream=path.join(root,'selfhost/.bootstrap/upstream-phase66/bend2');
const REVISION='059266225b77c8ca256ac6b25ee5c21449bab151';
const SOURCE_SHA='4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618';
const PARENT_SHA='eb6d743504b7636fd6dc7fdf176586ca4380d46ea25965f5c1a2b35a5c1a2743';
const UPSTREAM_SHA='32bb9a91f0c81d175e63d2211a74fc4f7abe61ef76ebe966be2d27f53ff34ead';
const NODE_SHA='41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c';
const hash=data=>createHash('sha256').update(data).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,sha256:hash(bytes),bytes:bytes.length};};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const report={kind:'phase92-checked-upstream-native-source-derivative',version:1,complete:false,
  upstream:REVISION,started:new Date().toISOString(),inputs:[],phases:[],nativeB2:false,cacheAdmitted:false,
  scope:'Actual pinned upstream load/check/JS-and-C emission of an exact frozen native89 source derivative. Historical parent checkout inputs are provenance, not currently consumed source. No native execution, self-emission, cache admission or release promotion.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const bind=(record,expected)=>{const p=pin(record.file??record.path);assert.equal(p.sha256,record.sha256,p.file);
  if(record.bytes!==undefined)assert.equal(p.bytes,record.bytes,p.file);if(expected)assert.equal(p.sha256,expected,p.file);
  if(!report.inputs.some(old=>old.file===p.file))report.inputs.push(p);return p;};
const add=(file,expected)=>bind(pin(file),expected);
const phase=async(name,body)=>{const start=performance.now();report.currentPhase=name;save();console.log('START '+name);
  const value=await body();report.phases.push({name,ms:performance.now()-start});delete report.currentPhase;save();console.log('DONE '+name);return value;};
const only=(text,needle)=>{assert(needle.length>0);assert.equal(text.split(needle).length-1,1,'Replacement must be unique');};
const replace=(text,before,after)=>{only(text,before);return text.replace(before,()=>after);};
function definition(text,name){
  assert(/^[a-z_][a-z_0-9]*$/.test(name));
  const re=new RegExp('^@unsafe\\ndef '+name+'\\([^\\n]*\\) -> String:\\n(?:  [^\\n]*\\n|\\n)*','gm');
  const hits=[...text.matchAll(re)];assert.equal(hits.length,1,'Unique definition '+name);return hits[0][0];
}
let B;
save();
try{
  report.method=add(import.meta.filename);report.node=add(process.execPath,NODE_SHA);
  assert.equal(process.version,'v24.18.0');
  report.parent=add(parentArg,PARENT_SHA);const parent=read(report.parent.file);
  assert(parent.complete);assert.equal(parent.upstream,REVISION);
  assert(['load','check','emit-js','emit-c'].every(name=>parent.phases.some(p=>p.name===name)));
  const parentSource=bind(parent.source,SOURCE_SHA);
  report.historicalParent={receipt:report.parent,source:parentSource,inheritedInputCount:parent.inputs.length,
    inputPolicy:'The original receipt is preserved exactly. Its original checkout input hashes are not requirements on current production files and are not inserted into this acquisition input set.'};
  report.derivation=add(derivationArg);const derivative=read(report.derivation.file);
  assert(derivative.complete);assert.equal(derivative.acquisitionComplete,false);
  assert.equal(derivative.inputs[0].sha256,SOURCE_SHA);
  for(const item of derivative.inputs)bind(item);
  const subject=bind(derivative.output);
  const original=fs.readFileSync(parentSource.file,'utf8');
  const changes=[];
  if(derivative.kind==='phase90-five-table-functions-assembly'){
    assert.equal(derivative.exactOutsideDefinitions,true);
    const functions=['nb_seg_ids_go','nb_arities_go','nb_result_words_go','nb_flags_go','nb_dispatch_go'];
    assert.deepEqual(derivative.functions,functions);
    const baseline=fs.readFileSync(derivative.inputs[1].file,'utf8'),candidate=fs.readFileSync(derivative.inputs[2].file,'utf8');
    let current=original;
    for(const name of functions){
      const old=definition(current,name);assert.equal(old.trimEnd(),definition(baseline,name).trimEnd());
      const helper=definition(candidate,name.replace(/_go$/,'_chunks')).trimEnd();
      const wrapper=definition(candidate,name).trimEnd();
      const replacement=helper+'\n\n'+wrapper+'\n\n';
      changes.push({old,new:replacement});current=replace(current,old,replacement);
    }
    assert.equal(current,fs.readFileSync(subject.file,'utf8'),'Five-definition derivation differs');
  }else{
    // Optional combined source must carry replayable exact replacements from S.
    assert.equal(derivative.kind,'phase90-native-source-assembly');
    assert.equal(derivative.exactOutsideDefinitions,true);
    assert(Array.isArray(derivative.replacements)&&derivative.replacements.length>0&&derivative.replacements.length<=64);
    for(const change of derivative.replacements){assert.equal(typeof change.old,'string');assert.equal(typeof change.new,'string');
      assert(change.old&&change.new);changes.push({old:change.old,new:change.new});}
  }
  let forward=original;for(const change of changes)forward=replace(forward,change.old,change.new);
  const text=fs.readFileSync(subject.file,'utf8');assert.equal(forward,text,'Complete source differs from replay');
  let inverse=text;for(const change of [...changes].reverse())inverse=replace(inverse,change.new,change.old);
  assert.equal(inverse,original,'Inverse must recover exact frozen S');
  assert.deepEqual(text.match(/^import .*$/gm),['import Base'],'No extra source imports');
  report.sourceDerivation={kind:derivative.kind,replacements:changes.length,forwardSha256:hash(forward),inverseSha256:hash(inverse),
    inverseRecoversParent:true,exactOutsideReplacements:true};

  report.upstreamPinEvidence=add(path.join(root,'selfhost/build/phase86/upstream.json'),UPSTREAM_SHA);
  const reference=read(report.upstreamPinEvidence.file);assert.equal(reference.revision,REVISION);assert.equal(reference.status,'');
  assert.equal(reference.inputs.length,67);const upstreamFiles=new Map();
  for(const item of reference.inputs){const p=bind(item);assert(p.file.startsWith(upstream+'/'),'Unexpected upstream path');upstreamFiles.set(p.file,p);}
  for(const name of ['bend.ts','comp.ts','base.bend'])assert(upstreamFiles.has(fs.realpathSync(path.join(upstream,name))));
  assert.equal(upstreamFiles.get(fs.realpathSync(path.join(upstream,'base.bend'))).sha256,'99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf');
  // Do not inherit an unrelated BEND/NODE_OPTIONS override into this real check.
  report.removedEnvironment=Object.keys(process.env).filter(k=>k.startsWith('BEND_')||k==='NODE_OPTIONS');
  for(const key of report.removedEnvironment)delete process.env[key];
  const source=path.join(out,'compiler.bend');fs.copyFileSync(subject.file,source,fs.constants.COPYFILE_EXCL);
  report.source=add(source);assert.equal(report.source.sha256,subject.sha256);save();
  B=await import(pathToFileURL(path.join(upstream,'bend.ts')));
  const C=await import(pathToFileURL(path.join(upstream,'comp.ts')));
  const book=B.book_nil(),seen=new Map();
  await phase('load',()=>B.book_load(book,source,'',seen));
  report.loadedFiles=[...seen.keys()].map(file=>{
    const p=pin(file);assert(p.file===report.source.file||p.file===path.join(upstream,'base.bend'),'Unexpected source dependency');
    bind(p);return p;
  });
  assert.equal(report.loadedFiles.length,2,'Expected source plus pinned Base');
  // Foreign path declarations come from the real loaded book, not a text parser.
  const foreign=new Set();for(const tld of Object.values(book.tlds))for(const file of tld.i??[]){
    const canonical=fs.realpathSync(file);assert(upstreamFiles.has(canonical),'Unpinned foreign provider '+canonical);foreign.add(canonical);
  }
  report.declaredForeignProviders=[...foreign].sort().map(file=>upstreamFiles.get(file));save();
  await phase('check',()=>{B.book_valid(book);assert.equal(book.hols,0,'Unfilled holes');});report.holes=book.hols;save();
  for(const [key,name,emit] of [['c','compiler.c',C.compile_book]]){
    const file=path.join(out,name),code=await phase('emit-'+key,()=>emit(book));
    assert.equal(typeof code,'string');assert(code.length>0);
    fs.writeFileSync(file,code,{flag:'wx'});report[key]=pin(file);save();
  }
  for(const record of report.inputs)assert.deepEqual(pin(record.file),record);
  report.inputsUnchanged=true;report.complete=true;
}catch(error){report.error=error?.$==='Err'&&B?B.err_show(error):error.stack??String(error);console.error(report.error);process.exitCode=1;}
report.finished=new Date().toISOString();report.maxRssKiB=process.resourceUsage().maxRSS;save();
console.log(JSON.stringify({complete:report.complete,source:report.source,c:report.c,js:report.js,error:report.error}));
