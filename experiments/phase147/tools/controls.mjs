// Exact independent errors and complete semantic schema/live-state comparisons.
import path from 'node:path';
import assert from 'node:assert/strict';
import * as S from './support.mjs';
const a=S.options();for(const key of ['baseline','candidate','cases','out'])assert(a[key],'Missing --'+key);
const out=S.output(a.out),inputs=[S.pin(import.meta.filename),S.pin(path.join(import.meta.dirname,'support.mjs')),S.pin(a.cases)];
const report={kind:'phase147-complete-verifier-controls',version:1,complete:false,passed:false,inputs,rows:[],scope:'Independent fixed errors plus complete schema/error/count and final live/terminal/error projections. Invalid IR is never executed. Not a theorem or compiler promotion.'};
const save=()=>S.save(out+'/report.json',report);save();
function states(api,row,ctx){
 const raw=row.kind==='raw',f=row.function;
 const seed=raw?{$:'P111VScan',index:api.p111v_put(api.missing(),'state','parameter',3,2088),error:'',count:1}:api.p113e_seed(f.params);
 const nextSeed=raw?{$:'P147VScan',index:api.p147v_put({$:'P147VEmpty'},'state',0,2,3,2088),error:'',count:1}:api.p147d_seed(f.params);
 const projection=api.p147test_scan(nextSeed);
 assert.deepEqual([S.semanticRows(seed.index),seed.error,seed.count],[S.semanticRows(projection.index),projection.error,projection.count],'Complete parameter seed');
 const oldScan=api[raw?'p111v_schema':'p113e_schema'](f.body,seed),nextScan=api[raw?'p147v_schema':'p147d_schema'](f.body,nextSeed);
 const scan=api.p147test_scan(nextScan);
 assert.deepEqual([S.semanticRows(oldScan.index),oldScan.error,oldScan.count],[S.semanticRows(scan.index),scan.error,scan.count],'Complete schema');
 let count=2;
 if(!oldScan.error){
  const oldFlow={$:'P111VFlow',live:seed.index,terminal:false,error:''};
  const nextFlow={$:'P147VFlow',live:{$:'P147VEnv',schema:nextScan.index,assigned:api.p147n_seed(nextSeed.index,{$:'P147VNone'})},terminal:false,error:''};
  const old=raw?api.p111v_body(f.body,oldScan.index,oldFlow,ctx.ids,f.arity,f.incoming,f.result):api.p113e_body(f.body,oldScan.index,oldFlow,ctx.ids,ctx.ready,S.items(f.params).length,f.result);
  const next=raw?api.p147v_body(f.body,nextScan.index,nextFlow,ctx.ids,f.arity,f.incoming,f.result):api.p147d_body(f.body,nextScan.index,nextFlow,ctx.ids,ctx.ready,S.items(f.params).length,f.result);
  const projected=api.p147test_flow(next);
  assert.deepEqual([S.semanticRows(old.live),old.terminal,old.error],[S.semanticRows(projected.live),projected.terminal,projected.error],'Complete flow');count++;
 }
 return count;
}
try{
 const baseline=await S.checked(a.baseline),candidate=await S.checked(a.candidate);inputs.push(...baseline.inputs,...candidate.inputs);S.originalIdentity(baseline,candidate);
 report.baseline=baseline.receipt.api;report.candidate=candidate.receipt.api;
 const fixtures=S.read(a.cases);assert(fixtures.kind==='phase147-verifier-cases'&&fixtures.complete&&fixtures.cases.length>0&&fixtures.cases.length<=128);
 for(const row of fixtures.cases){
  const record={name:row.name,kind:row.kind,passed:false,expectedError:row.expectedError};report.rows.push(record);
  const originalCtx=S.context(baseline.api,row),candidateCtx=S.context(candidate.api,row);
  record.original=S.check(baseline.api,row,originalCtx);assert.equal(record.original,row.expectedError,row.name+' independent original oracle');
  record.candidate=S.check(candidate.api,row,candidateCtx,true);assert.equal(record.candidate,row.expectedError,row.name+' candidate exact diagnostic');
  record.stateComparisons=states(candidate.api,row,candidateCtx);record.passed=true;save();
 }
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}))}
