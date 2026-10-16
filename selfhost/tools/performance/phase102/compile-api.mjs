// Discovery only: checked stage0 API -> exact native p86 request path -> C.
// Required exports: p86_prepare p86_plan p86_effect_file kf_source
//                   nc_foreign_source nr_compile_prepared
// Usage: bun discovery-compile-v2.mjs CHECKED_API.mjs COMPILER.bend FRESH_OUT_DIR
// The caller retains the checked API acquisition's source binding separately.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,sourceArg,outArg]=process.argv.slice(2);
assert(apiArg&&sourceArg&&outArg,'API, source, fresh output directory required');
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase102/'));
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:hash(b)};};
const inputs=new Map(),bind=file=>{const p=pin(file);inputs.set(p.file,p);return p;};
const verify=p=>{const actual=pin(p.file);assert.equal(actual.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(actual.bytes,p.bytes,p.file);inputs.set(actual.file,actual);};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const report={kind:'phase102-discovery-prepared-C',complete:false,releaseQualified:false,
  api:bind(apiArg),source:bind(sourceArg),method:bind(import.meta.filename),effects:[],
  scope:'Discovery emission only. API/source relationship needs the separate checked stage0 acquisition receipt; no B1/B2 or native timing claim.'};
const at=performance.now();
report.phase='setup';report.phases=[];
const save=()=>{report.inputs=[...inputs.values()];
  fs.writeFileSync(out+'/report.json.tmp',JSON.stringify(report,null,2)+'\n');
  fs.renameSync(out+'/report.json.tmp',out+'/report.json');};
const mark=(phase,event)=>{report.phase=phase+':'+event;
  report.phases.push({phase,event,elapsedMs:performance.now()-at,at:new Date().toISOString()});save();};
save();
try{
  const transport=bind(root+'/selfhost/build/phase90/runtime-accessor-transport02/transport.json');
  assert.equal(transport.sha256,'07c49e15a8cfce79b12a2909edd4015876725bc2f099d855b8dcd58ef21d5510');
  const t=JSON.parse(fs.readFileSync(transport.file,'utf8'));assert.equal(t.complete,true);
  for(const p of [t.base,t.runtime,t.template,...t.parts,...t.effects])verify(p);
  const template=JSON.parse(fs.readFileSync(t.template.file,'utf8'));
  const parts=t.parts.map(p=>fs.readFileSync(p.file,'utf8'));
  assert.deepEqual(parts,template.parts);assert.equal(parts.length,5);
  assert.equal(template.runtimeSha256,t.runtime.sha256);
  assert.equal(hash(parts.join('')),t.runtime.sha256);
  const module=await import(pathToFileURL(report.api.file));assert(!module.G,'requires named-field stage0 API');
  const api=module.default;
  for(const name of ['p86_prepare','p86_plan','p86_effect_file','kf_source','nc_foreign_source','nr_compile_prepared'])assert.equal(typeof api[name],'function',name);
  const baseText=fs.readFileSync(t.base.file,'utf8'),sourceText=fs.readFileSync(report.source.file,'utf8');
  mark('basePrepare','start');
  let start=performance.now();const prepared=api.p86_prepare(t.base.file,baseText);
  report.basePrepareMs=performance.now()-start;mark('basePrepare','end');
  assert.equal(prepared.$,'P86PreparationReady',prepared.error);
  mark('plan','start');
  start=performance.now();const plan=api.p86_plan(prepared.seed,report.source.file,sourceText);
  report.planMs=performance.now()-start;mark('plan','end');assert.equal(plan.$,'P86PlanReady',plan.error);
  report.verdict=plan.verdict;const request=plan.request;assert.equal(request.$,'NR_Request');
  const permitted=new Map(t.effects.map(p=>[path.basename(p.file),p])),seen=new Set(),chunks=[];
  mark('effects','start');start=performance.now();
  for(const foreignPath of array(request.paths)){
    if(seen.has(foreignPath))continue;
    const name=api.p86_effect_file(t.base.file,foreignPath),provider=permitted.get(name);
    assert(name&&provider,'compile: pilot rejects foreign path '+foreignPath);verify(provider);
    const baseDir=path.dirname(t.base.file);
    assert(foreignPath===baseDir+'/effs/'+name||foreignPath===baseDir+'/./effs/'+name,'effect must originate in pinned Base');
    const text=fs.readFileSync(provider.file,'utf8');
    // p86_effect_parsed binds NR_Request's FIRST field as local book.
    const parsed=api.kf_source(request.source,request.scope,foreignPath,text);
    assert.equal(parsed.$,'KF_Source');assert.equal(parsed.error,'');
    chunks.push(api.nc_foreign_source(request.source,request.scope,foreignPath,text,parsed));
    seen.add(foreignPath);report.effects.push({path:foreignPath,provider});
  }
  report.effectsMs=performance.now()-start;mark('effects','end');
  mark('emit','start');start=performance.now();
  const result=api.nr_compile_prepared(request,{$:'NE_Parts',parts:list(parts)},chunks.join('\n'),true);
  report.emitMs=performance.now()-start;mark('emit','end');assert.equal(result.$,'NC_Result');assert.equal(result.error,'');
  assert(result.source.length>0);for(const p of [...inputs.values()])verify(p);
  fs.writeFileSync(out+'/program.c',result.source,{flag:'wx'});report.output=pin(out+'/program.c');
  report.complete=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
report.wallMs=performance.now()-at;report.maxRssKiB=process.resourceUsage().maxRSS;
report.phase=report.complete?'complete':'failed';save();
console.log(JSON.stringify({complete:report.complete,output:report.output,error:report.error}));
