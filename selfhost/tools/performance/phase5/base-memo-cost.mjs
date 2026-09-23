// P5-021 focused ABBA persistent-request pilot, under an external CPU/deadline.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache} from '../../development/workflow.mjs';
const [attemptArg,candidateArg,selectionArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('Usage: base-memo-cost.mjs ATTEMPT CANDIDATE_PROJECT SELECTION NEW_OUTPUT');
const attempt=fs.realpathSync(attemptArg),candidate=fs.realpathSync(candidateArg),selection=fs.realpathSync(selectionArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const inputs=[],capture=file=>{const row=identity(file);if(!inputs.some(x=>x.file===row.file))inputs.push(row);return row;};
const report={kind:'phase5-base-memo-focused-cost',complete:false,started:new Date().toISOString(),inputs,rows:[],
 scope:'Focused ABBA warmed persistent request pilot. One process, separate API module instances, fresh source graph each request. Preparation and warmup excluded. Full frontend workflow measured separately.',
 order:['control','memo','memo','control'],node:{...capture(process.execPath),version:process.version,args:process.execArgv},
 affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(s=>s.startsWith('Cpus_allowed_list:'))};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try {
 const m=await verifyAttempt(attempt);assert.equal(m.artifactKind,'checked-b1');report.api=m.api;
 for(const f of [import.meta.filename,selection,path.join(attempt,'attempt.json'),m.api.file,m.base.file,m.runtime.file])capture(f);
 const control=path.join(out,'control');fs.mkdirSync(path.join(control,'tools'),{recursive:true});
 for(const name of ['typed-driver','compiler-abi','node-resource-args','native-build','assemble']) {
   const source=path.join(m.snapshot.root,'tools',name+'.mjs'),copy=path.join(control,'tools',name+'.mjs');capture(source);fs.copyFileSync(source,copy);capture(copy);capture(path.join(candidate,'tools',name+'.mjs'));
 }
 fs.mkdirSync(path.join(control,'build/typed'),{recursive:true});fs.cpSync(path.join(m.snapshot.root,'build/typed/cache'),path.join(control,'build/typed/cache'),{recursive:true});
 for(const project of [control,candidate])capture(validatedCache(path.join(project,'build/typed/cache'),m.api.file,m.base.file).file);
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete process.env[k];
 Object.assign(process.env,{BEND_TYPED_API:m.api.file,BEND_BASE:m.base.file,BEND_TYPED_RUNTIME:m.runtime.file});
 const cases=JSON.parse(fs.readFileSync(selection)).map(row=>({...row,file:fs.realpathSync(path.resolve(path.dirname(selection),row.file))}));
 assert.equal(cases.length,21);for(const test of cases)capture(test.file);
 const before=await import(pathToFileURL(path.join(control,'tools/typed-driver.mjs'))),after=await import(pathToFileURL(path.join(candidate,'tools/typed-driver.mjs')));
 const api=await before.loadApi(),memo=await after.createPersistentInspector();
 const inspect={control:(f,o)=>before.inspect(f,{...o,api}),memo:(f,o)=>memo.inspect(f,o)};
 for(const variant of ['control','memo'])for(const i of [0,2,0,2])for(const mode of ['parse','check'])await inspect[variant](cases[i].file,{mode});
 report.prepared=new Date().toISOString();save();
 const expected=new Map();
 for(let block=0;block<report.order.length;block++) {
   const variant=report.order[block],order=block<2?cases:[...cases].reverse();
   for(const test of order)for(const mode of ['parse','check']) {
     const begin=performance.now(),result=await inspect[variant](test.file,{mode}),milliseconds=performance.now()-begin,key=test.id+'::'+mode;
     if(expected.has(key))assert.deepEqual(result,expected.get(key),key);else expected.set(key,result);
     for(const file of result.files??[])capture(file);
     report.rows.push({block,variant,id:test.id,mode,milliseconds,result});
   }
   save();
 }
 inputs.forEach(verifyIdentity);await verifyAttempt(attempt);
 const blocks=report.order.map((variant,block)=>({block,variant,milliseconds:report.rows.filter(r=>r.block===block).reduce((sum,r)=>sum+r.milliseconds,0)}));
 const sum=variant=>blocks.filter(b=>b.variant===variant).reduce((sum,b)=>sum+b.milliseconds,0);
 report.measurement={blocks,controlMs:sum('control'),memoMs:sum('memo'),reductionPercent:100*(1-sum('memo')/sum('control')),
   pairReductionPercent:[100*(1-blocks[1].milliseconds/blocks[0].milliseconds),100*(1-blocks[2].milliseconds/blocks[3].milliseconds)]};
 report.inputsVerified=true;report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,measurement:report.measurement,error:report.error}));
