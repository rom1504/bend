// Authentication and reflection of checked Bend diagnostics only. No target run.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const root=path.resolve(path.dirname(import.meta.filename),'../../../../..');
const [apiArg,sourceArg,outArg,...fixtureArgs]=process.argv.slice(2);
assert(apiArg&&sourceArg&&outArg,'Usage: inspect.mjs API_REPORT SOURCE_MANIFEST FRESH_PHASE126_OUT [SOURCE.bend ...]');
const out=path.resolve(outArg),read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
assert(!fs.existsSync(out)&&out.startsWith(root+'/selfhost/build/phase126/'),'Fresh Phase126 output required');
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const verify=r=>{const actual=pin(r.file);assert.equal(actual.bytes,r.bytes,'Changed size: '+r.file);assert.equal(actual.sha256,r.sha256,'Changed hash: '+r.file)};
const apiReport=read(apiArg),source=read(sourceArg);
assert(apiReport.complete&&apiReport.checked&&source.complete,'Complete checked API and source required');
assert(apiReport.inputs.some(p=>p.file===source.source.file&&p.sha256===source.source.sha256),'API/source mismatch');
const selectionFile=path.join(root,'selfhost/tools/native/selection.json'),selection=read(selectionFile);
verify(selection.admission);const admission=read(selection.admission.file);
assert(admission.complete&&admission.qualified,'Qualified prepared Base required');
const {base,cache}=admission.assets;
const fixtures=(fixtureArgs.length?fixtureArgs:[
  path.join(root,'selfhost/build/phase93/fixtures01/coverage-record-aggregation-256.bend'),
  path.join(root,'selfhost/build/phase93/fixtures01/test-evening-program.bend')]).map(pin);
const inputs=[pin(import.meta.filename),pin(process.execPath),pin(apiArg),pin(sourceArg),apiReport.api,
  source.source,...apiReport.inputs,...source.inputs,pin(selectionFile),selection.admission,base,cache.carrier,...fixtures];
inputs.forEach(verify);fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase126-existing-worker-admission-inspection',complete:false,targetsRun:false,inputs,
  scope:'Exact existing Bend diagnostics and verified catalogues. Host only reflects records, filters names and compares exact symbol membership. Missing dependency labels are catalogue membership, not a new legality analysis.',
  cases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const tag=(v,t)=>{assert.equal(v?.$,t,'Expected '+t+', got '+v?.$+': '+(v?.error??''));return v};
const list=v=>{const result=[];while(v?.$==='Con'){result.push(v.head);v=v.tail}tag(v,'Nil');return result};
const interest=['Map.bit','Map.bit.at','Map.bit.go','U32.show.go','U32.show.fin','Nat.show.go','Nat.show.fin'];
const interesting=name=>interest.some(s=>name===s||name.endsWith('.'+s));
const signature=f=>({name:f.name,params:list(f.params).map(p=>({id:p.id,name:p.name,word:p.word,kind:p.kind})),result:f.result,public:f.public});
const start=performance.now();
try{
  const api=(await import(pathToFileURL(apiReport.api.file))).default;
  const needed=['p88_cache_prepare','p86_plan','p111_runtime_admission','p113pl_inspect_request',
    'p113a_lower_request','p113a_verify','p118b_plan','p118b_new_functions','p118b_verify_functions'];
  for(const name of needed)assert.equal(typeof api[name],'function','Missing checked export '+name);
  let t=performance.now();const preparation=tag(api.p88_cache_prepare(base.file,fs.readFileSync(base.file,'utf8'),
    fs.readFileSync(cache.carrier.file,'utf8'),cache.stamp),'P86PreparationReady');
  report.prepareSeconds=(performance.now()-t)/1000;save();
  for(const fixture of fixtures){
    const row={fixture,complete:false};report.cases.push(row);save();
    t=performance.now();const request=tag(api.p86_plan(preparation.seed,fixture.file,fs.readFileSync(fixture.file,'utf8')),'P86PlanReady').request;
    row.frontendSeconds=(performance.now()-t)/1000;assert.equal(api.p111_runtime_admission(request),'');
    t=performance.now();const candidates=list(api.p113pl_inspect_request(request));
    row.candidateSeconds=(performance.now()-t)/1000;row.candidateCount=candidates.length;save();
    t=performance.now();const lowered=tag(api.p113a_lower_request(request),'P113ALowered');
    row.loweringSeconds=(performance.now()-t)/1000;row.loweringError=lowered.error;assert.equal(lowered.error,'');
    const program=tag(lowered.program,'P113AProgram');
    row.originalVerification=api.p113a_verify(program);assert.equal(row.originalVerification,'');
    const direct=tag(program.original,'P113DProgram'),staticProgram=tag(direct.original,'P112StaticProgram');
    const original=list(direct.functions),oldNames=new Set(original.map(f=>f.name));
    t=performance.now();const plan=tag(api.p118b_plan(request),'P118BPlan'),workers=tag(api.p118b_new_functions(plan),'P118BWorkers');
    row.borrowSeconds=(performance.now()-t)/1000;row.borrowPlanError=plan.error;row.borrowError=workers.error;
    assert.equal(plan.error,'');assert.equal(workers.error,'');
    row.borrowVerification=api.p118b_verify_functions(workers.functions,staticProgram.program);assert.equal(row.borrowVerification,'');
    const added=list(workers.functions),addedNames=new Set(added.map(f=>f.name)),mergedNames=new Set([...oldNames,...addedNames]);
    row.originalCount=original.length;row.addedCount=added.length;row.borrowSelected=list(plan.names);
    row.original=original.filter(f=>interesting(f.name)).map(signature);
    row.borrowed=added.filter(f=>interesting(f.name)).map(signature);
    row.candidates=candidates.filter(c=>interesting(c.function.name)).map(c=>{
      const calls=list(c.calls);return{...signature(c.function),candidateError:c.error,calls,
        admittedOriginal:oldNames.has(c.function.name),replacedOrAdded:addedNames.has(c.function.name),
        missingOriginal:calls.filter(n=>!oldNames.has(n)),missingAfterBorrow:calls.filter(n=>!mergedNames.has(n))};
    });
    row.complete=true;save();console.log(JSON.stringify(row));
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error);report.stack=error?.stack;process.exitCode=1}
finally{report.seconds=(performance.now()-start)/1000;report.peakRss=process.resourceUsage().maxRSS*1024;save();console.log(JSON.stringify({complete:report.complete,error:report.error}))}
