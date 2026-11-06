// Checked Bend calls and byte transport only. Root owns guarded execution.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url),args={};
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i]?.replace(/^--/,'');
  need(process.argv[i]?.startsWith('--')&&process.argv[i+1]&&!Object.hasOwn(args,key),'Unique --key value arguments required');
  args[key]=process.argv[i+1];
}
need(['receipt','assembly','source','out'].every(k=>args[k]),'Required: --receipt --assembly --source --out');
need(Object.keys(args).every(k=>['receipt','assembly','source','out'].includes(k)),'Unknown argument');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a.file===b.file&&a.bytes===b.bytes&&a.sha256===b.sha256;
function* items(value){let n=0;while(value?.$==='Con'){need(++n<=1000000,'Unbounded Bend list');yield value.head;value=value.tail;}need(value?.$==='Nil','Malformed Bend list');}
const out=path.resolve(args.out);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh workspace build output required');
fs.mkdirSync(out,{recursive:true});
need(fs.realpathSync(out)===out,'Symlink output refused');
const report={kind:'phase171-import-inspection',version:1,complete:false,mode:'metadata',
  inputs:[pin(own),pin(path.resolve(path.dirname(own),'../../tools/build/hosted.mjs')),pin(args.receipt),pin(args.assembly),pin(args.source),pin(process.execPath)],stages:{},
  scope:'Authenticated producer metadata from a source-checked experimental API. Not final import/caller verification, native timing, runtime counts, or promotion.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();save();
try{
  const assembly=read(args.assembly),receipt=read(args.receipt);
  need(assembly.kind==='phase171-api-source'&&assembly.complete&&assembly.protectedUnchanged,'Invalid assembly receipt');
  need(receipt.kind==='bend-checked-hosted-api'&&receipt.version===1&&receipt.complete&&receipt.checked&&!receipt.error,'Checked successful acquisition required');
  need(same(assembly.source,receipt.source),'Acquisition is not of this assembled source');
  need(Array.isArray(receipt.exports)&&receipt.exports.length===assembly.exports.length&&receipt.exports.every((x,i)=>x===assembly.exports[i]),'Different exported API');
  report.inputs.push(...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,...receipt.inputs,receipt.api);
  report.inputs.forEach(verify);
  const binding=read(assembly.binding.file);
  need(binding.kind==='phase171-prepared-base'&&binding.version===1,'Missing prepared Base binding');
  report.inputs.push(binding.assets,binding.base,binding.carrier,binding.engine);
  report.inputs.forEach(verify);
  need(same(binding.engine,pin(process.execPath)),'Run with the pinned Bun executable');
  report.source=pin(args.source);report.assembly=pin(args.assembly);report.acquisition=pin(args.receipt);
  report.base=binding.base;report.carrier=binding.carrier;report.stamp=binding.stamp;
  report.preparationPolicy='authenticated prepared Base, fresh process';
  const known={
    ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3:{name:'captured-real-verifier',bytes:39333,stdout:'768\n'},
    cd22c831c180c0de12d84aeb80debf4881d08cbd18fcf8f6d634153fba2feb03:{name:'native45-map-churn-128',bytes:3659,oracle:'experiments/phase167/tools/map-oracle.py',scope:'Timed IO output: semantic fields checked by the native45 oracle, not exact timing text.'},
  };
  const fixture=known[report.source.sha256];
  if(fixture){need(fixture.bytes===report.source.bytes,'Fixed fixture size differs');report.independentRuntimeOracle={...fixture,executed:false};}
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  report.stages.loadSeconds=(performance.now()-start)/1000;
  for(const name of ['p88_cache_prepare','p86_plan','p171_request','p171c_summary'])need(receipt.exports.includes(name)&&typeof api[name]==='function','Required export missing: '+name);
  let t=performance.now();
  const prepared=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  report.stages.baseSeconds=(performance.now()-t)/1000;
  need(prepared?.$==='P86PreparationReady',prepared?.error??'Prepared Base refused');
  t=performance.now();
  const plan=api.p86_plan(prepared.seed,report.source.file,fs.readFileSync(report.source.file,'utf8'));
  report.stages.frontendSeconds=(performance.now()-t)/1000;save();
  need(plan?.$==='P86PlanReady',plan?.error??'Checked request refused');
  t=performance.now();
  const proposed=api.p171_request(plan.request);
  report.stages.proposalSeconds=(performance.now()-t)/1000;
  need(proposed?.$==='P171Program'&&proposed.error==='',proposed?.error??'Wrong proposal');
  const old=[...items(proposed.base.functions)], added=[...items(proposed.added)], imports=[...items(proposed.imports)];
  const summary=[...items(api.p171c_summary(proposed))];
  need(summary.length===4&&summary[0]===old.length&&summary[1]===imports.length&&summary[2]===added.length&&summary[3]===1,'Summary/structure mismatch');
  const names=new Set(imports.map(x=>x.segment.name));
  need(names.size===imports.length,'Repeated proposed import');
  const calls=body=>{
    const counts=new Map(),pending=[body];
    let visited=0;
    while(pending.length){
      for(const stmt of items(pending.pop())){
        need(++visited<=1000000,'Excessive direct body');
        if(stmt.$==='P113DCall')counts.set(stmt.target,(counts.get(stmt.target)||0)+1);
        else if(stmt.$==='P113DIf')pending.push(stmt.yes,stmt.no);
      }
    }
    return [...counts].sort((a,b)=>a[0].localeCompare(b[0])).map(([target,sites])=>({target,sites}));
  };
  report.summary={oldFunctions:old.length,imports:imports.length,addedFunctions:added.length};
  report.imports=imports.map(x=>({source:x.source,owner:x.segment.name,arity:x.segment.arity,
    result:x.segment.result,incoming:x.segment.incoming,flags:x.segment.flags,rank:x.rank,
    family:[...items(x.family)].map(s=>s.name),cases:[...items(x.plan.cases)].map(c=>({name:c.name,captures:[...items(c.captures)].length})),
    frozenDependencies:[...items(x.dependencies)].length}));
  report.added=added.map(f=>({name:f.name,arity:[...items(f.params)].length,result:f.result,public:f.public,calls:calls(f.body)}));
  const affected=new Set(names);
  let change=true;
  while(change){change=false;for(const f of report.added){if(!affected.has(f.name)&&f.calls.some(c=>affected.has(c.target))){affected.add(f.name);change=true;}}}
  report.staticEffects={
    addedWithDirectImportCall:report.added.filter(f=>f.calls.some(c=>names.has(c.target))).map(f=>f.name),
    addedTransitivelyDependingOnImport:report.added.filter(f=>affected.has(f.name)).map(f=>f.name),
    directImportCallSites:report.added.reduce((n,f)=>n+f.calls.filter(c=>names.has(c.target)).reduce((m,c)=>m+c.sites,0),0),
    limitations:'Syntactic sites and dependency closure, never dynamic frequency or runtime speed. Whole caller/import admission is a separate p171_plan emission gate.'};
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,summary:report.summary,error:report.error}));}
