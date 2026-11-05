// Bounded IO transport. Original Bend frontend and backends make every decision.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {pin,verify,items,root} from '../phase147/tools/support.mjs';

const [planFile,outArg]=process.argv.slice(2),plan=JSON.parse(fs.readFileSync(planFile));
assert(plan.kind==='phase166-lookup-three-path-plan'&&plan.complete);
const out=path.resolve(outArg);assert(out.startsWith(root+'/selfhost/build/phase166/')&&!fs.existsSync(out));
plan.inputs.forEach(verify);assert.equal(pin(process.execPath).sha256,plan.providers.bun.sha256);
const receipt=JSON.parse(fs.readFileSync(plan.apiReceipt.file));assert(receipt.complete&&receipt.checked);
for(const name of plan.exports)assert(receipt.exports.includes(name));
assert.equal(receipt.api.sha256,plan.api.sha256);
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase166-lookup-ours-emission',complete:false,inputs:[pin(import.meta.filename),pin(planFile),...plan.inputs],source:plan.source,products:{},scope:'One original live checked request passed unchanged to complete QBE and mature-C backends. No native execution or timing claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  const api=(await import(pathToFileURL(plan.api.file))).default;
  const prepared=api.p86_prepare(plan.providers.base.file,fs.readFileSync(plan.providers.base.file,'utf8'));
  assert.equal(prepared.$,'P86PreparationReady',prepared.error);
  const checked=api.p86_plan(prepared.seed,plan.source.file,fs.readFileSync(plan.source.file,'utf8'));
  assert.equal(checked.$,'P86PlanReady',checked.error);assert.equal(checked.request.$,'NR_Request');
  assert.equal(items(checked.request.paths).length,0,'This pure lookup source must need no foreign effect adapter');
  report.verdict=checked.verdict;
  for(const role of ['qbe','c']){
    const file=path.join(out,role==='qbe'?'program.ssa':'program.c'),fd=fs.openSync(file,'wx');
    let bytes=0,pieces=0;const begin=performance.now();
    const write=text=>{assert.equal(typeof text,'string');bytes+=Buffer.byteLength(text);assert(bytes<=8*1024**2&&++pieces<=100000);fs.writeSync(fd,text);};
    try{
      if(role==='qbe'){
        const emission=api.p134e_plan(checked);
        if(emission.$==='P111Emission'){assert.equal(emission.error,'');for(const text of items(emission.chunks)){write(text);write('\n');}}
        else{assert.equal(emission.$,'P134Planned');let cursor=api.p134e_begin(emission.plan);
          for(;;){const step=api.p134e_next(cursor);if(step.$==='P134Done')break;assert.equal(step.$,'P134Piece');write(step.text);if(step.legacy_end)write('\n');cursor=step.next;}}
      }else{
        const runtime=api.ne_runtime_prepare(fs.readFileSync(plan.providers['c-runtime'].file,'utf8'));
        const result=api.nr_compile_prepared(checked.request,runtime,'',true);
        assert.equal(result.$,'NC_Result');assert.equal(result.error,'');write(result.source);
      }
    }finally{fs.closeSync(fd);}
    assert(bytes>0);report.products[role]={file:pin(file),seconds:(performance.now()-begin)/1000,bytes,pieces};save();
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,products:report.products,error:report.error}));}
