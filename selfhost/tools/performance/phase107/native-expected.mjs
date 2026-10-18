// One Bun startup: checked-graph expected products; no native target execution.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import crypto from 'node:crypto';import {pathToFileURL} from 'node:url';
const args=process.argv.slice(2),prune=args.includes('--prune');if(prune)args.splice(args.indexOf('--prune'),1);
const excluded=[];for(let i=args.indexOf('--exclude');i>=0;i=args.indexOf('--exclude')){assert(args[i+1],'--exclude requires a name');excluded.push(args[i+1]);args.splice(i,2);}
assert.equal(args.length,4,'API SOURCE_GRAPHS REVIEW_GRAPHS FRESH_OUT [--prune] [--exclude NAME ...]');
const groups={positive:['arithmetic','branches','compiler_classify','erased','recurrence','default_bool_arm','erased_function','erased_local'],lowerer:['refuse_nat','refuse_shift','refuse_bool_entry','refuse_box','refuse_higher_order'],frontend:['refuse_named_u32']},all=Object.values(groups).flat();
for(const name of excluded)assert(all.includes(name),'unknown exclusion: '+name);
const selection={excluded:[...new Set(excluded)].sort(),included:all.filter(n=>!excluded.includes(n)).sort()};assert(groups.positive.some(n=>selection.included.includes(n)),'selection needs a positive case');
const [apiPath,original,review]=args.slice(0,3).map(p=>fs.realpathSync(p)),out=path.resolve(args[3]);fs.mkdirSync(out);
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const inputs=new Map(),verify=p=>{assert.deepEqual(pin(p.file),p);inputs.set(p.file,p);return p.file;};
const report={kind:'phase107-native-expected',complete:false,passed:false,prune,selection,inputs:[],rows:[],scope:'JS execution of checked Bend lowering/emission for explicitly included cases; exclusions are not passes. Independent runtime answers belong to native-controls.py.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');};
for(const f of [import.meta.filename,process.execPath,apiPath])verify(pin(f));fs.copyFileSync(import.meta.filename,out+'/method.mjs');save();
try{
 const api=(await import(pathToFileURL(apiPath))).default;
 for(const dir of [original,review])for(const name of fs.readdirSync(dir).filter(n=>fs.statSync(path.join(dir,n)).isDirectory()).sort()){
  assert(all.includes(name),'unknown case: '+name);if(selection.excluded.includes(name))continue;
  const folder=path.join(dir,name),receipt=pin(folder+'/report.json');verify(receipt);const captured=JSON.parse(fs.readFileSync(receipt.file));
  assert.equal(captured.kind,'phase107-checked-source-capture');const source=captured.inputs[0];verify(source);
  const row={name,source,capture:receipt,outputs:[]};report.rows.push(row);save();const begin=performance.now();
  if(!captured.complete){assert.equal(name,'refuse_named_u32');assert.equal(captured.result.status,'error');assert.equal(captured.result.phase,'compile');assert(captured.result.typeAccepted&&captured.result.diagnostic.includes('U32 is a name the compiler encodes itself'));assert(!fs.existsSync(folder+'/selected.json'));row.refusal='frontend';row.error=captured.result.diagnostic;save();continue;}
  assert(captured.result.checked&&captured.result.status==='ok');const graph=pin(folder+'/selected.json');assert(captured.products.some(p=>p.file===graph.file&&p.sha256===graph.sha256&&p.bytes===graph.bytes));verify(graph);row.graph=graph;
  const lowered=api.nxk_lower(JSON.parse(fs.readFileSync(graph.file)),'bench');row.lowerSeconds=(performance.now()-begin)/1000;
  if(name.startsWith('refuse_')){assert(lowered.error);row.refusal='lowerer';row.error=lowered.error;save();continue;}assert(!lowered.error,name+': '+lowered.error);
  for(const policy of ['raw','fast']){
   const start=performance.now();let program=lowered.program;
   if(policy==='fast'){program=api.nx_optimize(api.nx_inline_entry(api.nx_tail_optimize(program),4096));if(prune)program=api.nx_reachable(program);}
   assert.equal(api.nx_verify(program),true);const stem=path.join(out,name+'-'+policy);
   fs.writeFileSync(stem+'.json',api.nx_json_program(program),{flag:'wx'});
   fs.writeFileSync(stem+'.ssa',api[policy==='fast'?'nxq_program_fused':'nxq_program'](program),{flag:'wx'});
   row.outputs.push({policy,json:pin(stem+'.json'),qbe:pin(stem+'.ssa'),seconds:(performance.now()-start)/1000});
  }save();
 }
 assert.deepEqual(report.rows.map(r=>r.name).sort(),selection.included);
 for(const [kind,names] of Object.entries(groups))assert.deepEqual(report.rows.filter(r=>(r.refusal||'positive')===kind).map(r=>r.name).sort(),names.filter(n=>selection.included.includes(n)).sort());
 for(const p of inputs.values())assert.deepEqual(pin(p.file),p);report.complete=true;report.passed=true;
}catch(e){report.error=String(e);process.exitCode=1;}finally{save();}
console.log(JSON.stringify({complete:report.complete,passed:report.passed,selection,error:report.error??null,report:pin(out+'/report.json')}));
