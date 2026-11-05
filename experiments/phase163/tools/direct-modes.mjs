// Scheduling, exact inputs/artifacts and syntax census only. Compilation stays
// inside the checked Bend API. Run this command under the maintained disk guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,items} from '../../phase147/tools/support.mjs';

const own=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(own),'../../..');
const [receiptFile,originalFile,baseFile,outFile,...selected]=process.argv.slice(2);
assert(receiptFile&&originalFile&&baseFile&&outFile,
  'Usage: direct-modes.mjs API_RECEIPT ORIGINAL_EMISSION_REPORT BASE FRESH_OUT [CASE_NAME ...]');
const receipt=JSON.parse(fs.readFileSync(receiptFile)),original=JSON.parse(fs.readFileSync(originalFile));
assert(receipt.kind==='bend-checked-hosted-api'&&receipt.complete&&receipt.checked,'Checked API required');
assert(original.complete,'Complete original emission report required');
const base=pin(baseFile),baseOriginal=original.inputs.find(x=>x.file===base.file);
assert(baseOriginal,'Base absent from original input identity');verify(baseOriginal);
for(const row of [receipt.api,receipt.source])verify(row);
for(const name of ['p86_prepare','p86_plan','p163o_executable_mode','p163o_controls','p163dc_controls','p163x_controls'])
  assert(receipt.exports.includes(name),'Missing checked API export '+name);
const names=selected.length?selected:['reverse-runtime-10000-source01','lookup-runtime-10000-source01'];
assert(names.length>0&&names.length<=8&&new Set(names).size===names.length,'Bounded unique cases required');
const cases=names.map(name=>{
  const matches=original.rows.filter(row=>row.name===name);assert.equal(matches.length,1,'Unknown/duplicate case '+name);
  const row=matches[0];assert(row.complete&&row.direct&&row.baseline,'Incomplete original case '+name);
  for(const value of [row.source,row.direct,row.baseline])verify(value);
  assert(/^[A-Za-z0-9._-]+$/.test(name),'Unsafe case filename');return row;
});
const out=path.resolve(outFile);
assert(out.startsWith(root+'/selfhost/build/')&&!fs.existsSync(out),'Fresh build output required');
assert.equal(fs.realpathSync(path.dirname(out)),path.dirname(out),'Output parent must not be a symlink');
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase163-direct-modes',version:1,complete:false,
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../phase147/tools/support.mjs')),
    pin(receiptFile),receipt.api,receipt.source,pin(originalFile),base,
    ...cases.flatMap(row=>[row.source,row.direct,row.baseline])],
  controls:[],controlGroups:[],sources:[],rows:[],
  modes:{0:'original direct',1:'bounded inlining/scalar facts',2:'rederived cold constructors',3:'both'},
  timingScope:'One shared Base preparation and one checked frontend plan per source; every mode reruns full direct semantic planning, optional transformations, final verification and Bend rendering. directSeconds excludes host chunk transport/artifact hashing. Serial single observations, reversed mode order on alternating sources; no cold-process or statistical speed claim.',
  baselineScope:'Immutable original baseline QBE is reused, not recompiled or retimed. Native construction and full output comparison remain separate.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const elapsed=start=>(performance.now()-start)/1000;
function census(text){
  const descriptor=text.match(/(?:export )?data \$p111_program =[^\n]+/g);
  const hot=text.match(/(?:export )?data \$p111_cid_hot =[^\n]+/g);
  assert.equal(descriptor?.length,1,'Exactly one actual program descriptor required');
  assert.equal(hot?.length,1,'Exactly one actual CID-hot table required');
  const words=[...descriptor[0].matchAll(/\bl (\d+)/g)].map(x=>Number(x[1]));
  const flags=[...hot[0].matchAll(/\bb (\d+)/g)].map(x=>Number(x[1]));
  assert(words.length>=12&&words[0]===11101&&words[1]===192,'Unexpected descriptor syntax/ABI');
  assert(flags.length===words[3]&&flags.every(x=>x===0||x===1),'CID table/descriptor mismatch');
  const calls=[...text.matchAll(/\bcall \$([A-Za-z0-9_]+)/g)].map(x=>x[1]);
  return {scope:'Static emitted syntax only; not executed call/allocation counts',
    bytes:Buffer.byteLength(text),functions:[...text.matchAll(/^(?:export )?function /gm)].length,
    segments:words[2],constructors:words[3],coldConstructors:flags.filter(x=>x===0).length,
    hotConstructors:flags.filter(x=>x===1).length,capabilities:words[11],staticWords:words[8],
    runtimeCallSites:Object.fromEntries(['p111_rt_keep','p111_rt_sink','p111_rt_ctor','p111_rt_take','p118_rt_borrow']
      .map(prefix=>[prefix,calls.filter(name=>name.startsWith(prefix)).length]))};
}
save();let bytesWritten=0;
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  for(const [name,count] of [['p163dc_controls',14],['p163x_controls',4],['p163o_controls',4]]){
    const start=performance.now(),rows=items(api[name]());
    report.controlGroups.push({name,expected:count,seconds:elapsed(start),rows});report.controls.push(...rows);save();
    assert.equal(rows.length,count,name+' control count');assert(rows.every(x=>typeof x==='string'&&x.endsWith(':pass')),name+' failed');
  }
  let start=performance.now();const prepared=api.p86_prepare(base.file,fs.readFileSync(base.file,'utf8'));
  report.basePreparationSeconds=elapsed(start);assert.equal(prepared.$,'P86PreparationReady',prepared.error);save();
  for(let index=0;index<cases.length;index++){
    const old=cases[index],source={name:old.name,source:old.source,complete:false,
      modeOrder:index%2?[3,2,1,0]:[0,1,2,3],baseline:old.baseline,originalDirect:old.direct};
    report.sources.push(source);save();verify(old.source);
    start=performance.now();const plan=api.p86_plan(prepared.seed,old.source.file,fs.readFileSync(old.source.file,'utf8'));
    source.frontendSeconds=elapsed(start);assert.equal(plan.$,'P86PlanReady',plan.error);save();
    source.baselineCensus=census(fs.readFileSync(old.baseline.file,'utf8'));
    for(const mode of source.modeOrder){
      const row={name:old.name+'-mode'+mode,case:old.name,mode,source:old.source,
        baseline:old.baseline,complete:false,frontendReference:old.name,
        historicalBaselineSeconds:old.baselineSeconds};
      report.rows.push(row);save();const begin=performance.now();
      const emitted=api.p163o_executable_mode(mode,plan.request);row.directSeconds=elapsed(begin);
      assert.equal(emitted.$,'P111Emission','Unexpected emission variant');row.directError=emitted.error;save();
      assert.equal(emitted.error,'','Mode '+mode+' refused '+old.name);
      const transportStart=performance.now(),chunks=items(emitted.chunks);assert(chunks.every(x=>typeof x==='string'));
      const text=chunks.join(''),bytes=Buffer.byteLength(text);bytesWritten+=bytes;
      assert(bytes>0&&bytes<=8*1024**2&&bytesWritten<=32*1024**2,'Bounded emitted artifact size exceeded');
      const file=path.join(out,row.name+'-direct.ssa');fs.writeFileSync(file,text,{flag:'wx'});row.direct=pin(file);
      row.materializationSeconds=elapsed(transportStart);row.compileAndArtifactSeconds=elapsed(begin);
      const inspectStart=performance.now();row.census=census(text);row.inspectionSeconds=elapsed(inspectStart);
      if(mode===0){
        row.mode0MatchesOriginal=row.direct.sha256===old.direct.sha256&&row.direct.bytes===old.direct.bytes;
        assert(row.mode0MatchesOriginal,'Mode0 changed previously qualified direct output');
      }
      row.complete=true;save();
    }
    source.complete=true;save();
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{
  try{report.inputs.forEach(verify);}catch(error){report.inputRecheckError=String(error.stack??error);report.complete=false;process.exitCode=1;}
  save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,controls:report.controls.length,error:report.error??report.inputRecheckError??null,report:path.join(out,'report.json')}));
}
