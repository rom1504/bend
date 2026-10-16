// Checked testing API -> one pinned Base preparation -> independent native requests.
// Usage: bun compile-batch.mjs CHECKED_API.mjs BATCH_INPUTS.json FRESH_BATCH_DIR
// Parent owns the serial guard and authenticates the API acquisition receipt.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [apiArg,planArg,outArg]=process.argv.slice(2);
assert(apiArg&&planArg&&outArg,'API, batch inputs, fresh batch directory required');
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(outArg);
assert(out.startsWith(root+'/selfhost/build/phase102/'));
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:hash(b)};};
const inputs=new Map(),bind=file=>{const p=pin(file);inputs.set(p.file,p);return p;};
const verify=p=>{const actual=pin(p.file);assert.equal(actual.sha256,p.sha256,p.file);assert.equal(actual.bytes,p.bytes,p.file);inputs.set(actual.file,actual);};
const save=(file,value)=>{fs.writeFileSync(file+'.tmp',JSON.stringify(value,null,2)+'\n');fs.renameSync(file+'.tmp',file);};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=xs=>{const a=[];while(xs?.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;};
const at=performance.now();
const report={kind:'phase102-discovery-prepared-C-batch',complete:false,releaseQualified:false,
  api:bind(apiArg),batchInputs:bind(planArg),method:bind(import.meta.filename),programs:[],phase:'setup',
  scope:'One checked JS testing API process and one Base preparation; each source has its own plan, effects and native emission. Not native B1/B2 qualification or independent cold-request timing.'};
const saveBatch=()=>{report.wallMs=performance.now()-at;report.inputs=[...inputs.values()];save(out+'/report.json',report);};
saveBatch();
try{
  const plan=JSON.parse(fs.readFileSync(report.batchInputs.file,'utf8'));
  assert.equal(plan.kind,'phase102-batch-emission-inputs');assert.equal(plan.complete,true);
  assert.deepEqual(plan.api,report.api);assert(Array.isArray(plan.programs)&&plan.programs.length>0);
  const names=new Set();
  for(const item of plan.programs){
    assert(/^[A-Za-z0-9][A-Za-z0-9_.-]*$/.test(item.id)&&!names.has(item.id),'invalid or duplicate program id');
    assert.equal(path.resolve(item.output),path.join(path.dirname(out),item.id,'emitted'));
    assert(!fs.existsSync(item.output),'program output exists');names.add(item.id);verify(item.source);
    report.programs.push({id:item.id,source:item.source,complete:false,status:'not-run'});
  }
  const transport=bind(root+'/selfhost/build/phase90/runtime-accessor-transport02/transport.json');
  assert.equal(transport.sha256,'07c49e15a8cfce79b12a2909edd4015876725bc2f099d855b8dcd58ef21d5510');
  const t=JSON.parse(fs.readFileSync(transport.file,'utf8'));assert.equal(t.complete,true);
  for(const p of [t.base,t.runtime,t.template,...t.parts,...t.effects])verify(p);
  const template=JSON.parse(fs.readFileSync(t.template.file,'utf8'));
  const parts=t.parts.map(p=>fs.readFileSync(p.file,'utf8'));
  assert.deepEqual(parts,template.parts);assert.equal(parts.length,5);
  assert.equal(template.runtimeSha256,t.runtime.sha256);assert.equal(hash(parts.join('')),t.runtime.sha256);
  const module=await import(pathToFileURL(report.api.file));assert(!module.G,'requires named-field stage0 API');
  const api=module.default;
  for(const name of ['p86_prepare','p86_plan','p86_effect_file','kf_source','nc_foreign_source','nr_compile_prepared'])assert.equal(typeof api[name],'function',name);
  report.phase='basePrepare:start';saveBatch();
  const start=performance.now(),prepared=api.p86_prepare(t.base.file,fs.readFileSync(t.base.file,'utf8'));
  report.basePrepareMs=performance.now()-start;assert.equal(prepared.$,'P86PreparationReady',prepared.error);
  for(const p of [...inputs.values()])verify(p);
  const preparation={kind:'phase102-shared-Base-preparation',complete:true,calls:1,
    api:report.api,method:report.method,batchInputs:report.batchInputs,transport,
    base:t.base,basePrepareMs:report.basePrepareMs,inputs:[...inputs.values()],
    scope:'One p86_prepare result reused through the borrowed +seed parameter of p86_plan; no source request or effect result is reused.'};
  fs.writeFileSync(out+'/preparation.json',JSON.stringify(preparation,null,2)+'\n',{flag:'wx'});
  report.sharedPreparation=bind(out+'/preparation.json');report.phase='basePrepare:end';saveBatch();
  const permitted=new Map(t.effects.map(p=>[path.basename(p.file),p]));

  function emitOne(item,row){
    fs.mkdirSync(path.dirname(item.output),{recursive:false});fs.mkdirSync(item.output,{recursive:false});
    const began=performance.now(),record={kind:'phase102-discovery-prepared-C',complete:false,releaseQualified:false,
      api:report.api,source:item.source,method:report.method,batchInputs:report.batchInputs,
      sharedPreparation:report.sharedPreparation,basePrepareMs:0,sharedBasePrepareMs:report.basePrepareMs,
      effects:[],phases:[],phase:'setup',scope:report.scope};
    const saveOne=()=>{record.wallMs=performance.now()-began;record.inputs=[...inputs.values()];save(item.output+'/report.json',record);};
    const mark=(phase,event)=>{record.phase=phase+':'+event;record.phases.push({phase,event,elapsedMs:performance.now()-began,at:new Date().toISOString()});saveOne();};
    row.status='running';report.phase=item.id;saveBatch();saveOne();
    try{
      verify(item.source);verify(report.sharedPreparation);
      mark('plan','start');let started=performance.now();
      const planned=api.p86_plan(prepared.seed,item.source.file,fs.readFileSync(item.source.file,'utf8'));
      record.planMs=performance.now()-started;mark('plan','end');assert.equal(planned.$,'P86PlanReady',planned.error);
      record.verdict=planned.verdict;const request=planned.request;assert.equal(request.$,'NR_Request');
      const seen=new Set(),chunks=[];mark('effects','start');started=performance.now();
      for(const foreignPath of array(request.paths)){
        if(seen.has(foreignPath))continue;
        const name=api.p86_effect_file(t.base.file,foreignPath),provider=permitted.get(name);
        assert(name&&provider,'compile: pilot rejects foreign path '+foreignPath);verify(provider);
        const baseDir=path.dirname(t.base.file);
        assert(foreignPath===baseDir+'/effs/'+name||foreignPath===baseDir+'/./effs/'+name,'effect must originate in pinned Base');
        const text=fs.readFileSync(provider.file,'utf8');
        const parsed=api.kf_source(request.source,request.scope,foreignPath,text);
        assert.equal(parsed.$,'KF_Source');assert.equal(parsed.error,'');
        chunks.push(api.nc_foreign_source(request.source,request.scope,foreignPath,text,parsed));
        seen.add(foreignPath);record.effects.push({path:foreignPath,provider});
      }
      record.effectsMs=performance.now()-started;mark('effects','end');mark('emit','start');started=performance.now();
      const result=api.nr_compile_prepared(request,{$:'NE_Parts',parts:list(parts)},chunks.join('\n'),true);
      record.emitMs=performance.now()-started;mark('emit','end');assert.equal(result.$,'NC_Result');assert.equal(result.error,'');
      assert(result.source.length>0);for(const p of [...inputs.values()])verify(p);
      fs.writeFileSync(item.output+'/program.c',result.source,{flag:'wx'});record.output=pin(item.output+'/program.c');
      record.complete=true;record.phase='complete';row.complete=true;row.status='complete';row.c=record.output;
    }catch(error){record.error=error.stack??String(error);record.phase='failed';row.status='failed';throw error;}
    finally{record.maxRssKiB=process.resourceUsage().maxRSS;saveOne();row.receipt=pin(item.output+'/report.json');saveBatch();}
    console.log(JSON.stringify({id:item.id,complete:row.complete,output:row.c}));
  }
  for(let i=0;i<plan.programs.length;i++){
    emitOne(plan.programs[i],report.programs[i]);
    // Drop per-request graphs between programs while retaining only the Base seed.
    if(typeof globalThis.Bun?.gc==='function'){
      const began=performance.now();globalThis.Bun.gc(true);report.programs[i].gcMs=performance.now()-began;saveBatch();
    }
  }
  for(const p of [...inputs.values()])verify(p);
  for(const row of report.programs){verify(row.source);verify(row.c);verify(row.receipt);}
  report.complete=true;report.phase='complete';
}catch(error){report.error=error.stack??String(error);report.phase='failed';process.exitCode=1;}
report.maxRssKiB=process.resourceUsage().maxRSS;saveBatch();
console.log(JSON.stringify({complete:report.complete,programs:report.programs.length,basePrepareMs:report.basePrepareMs,error:report.error}));
