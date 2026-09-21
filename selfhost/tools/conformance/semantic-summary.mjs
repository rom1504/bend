#!/usr/bin/env node
// Exact compatibility and semantic triage are separate: a generic rejection
// does not match the fixture diagnostic, and an Error expectation can be runtime.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
export function semanticSummary(rows) {
  const checked=rows.filter(r=>r.lane==='check'),positive=checked.filter(r=>!r.negative),negative=checked.filter(r=>r.negative);
  const accepted=r=>r.result?.status==='ok'&&r.result?.checked===true;
  const rejected=r=>r.result?.status==='error';
  const acceptedErrors=negative.filter(accepted).map(r=>{
    const later=rows.filter(other=>other.id===r.id&&other.status==='pass'&&['compile-rejection','runtime-rejection'].includes(other.evidence));
    return {id:r.id,lanes:[...new Set(later.map(other=>other.lane))],phases:[...new Set(later.map(other=>other.result.phase))]};
  });
  const failureGroups={};
  for(const r of positive.filter(r=>!accepted(r))) {
    const result=r.result||{},key=(result.phase||r.status||'unknown')+': '+(result.diagnostic||result.reason||r.reason||'unknown');
    (failureGroups[key]??=[]).push(r.id);
  }
  const executionGroups={};
  for(const r of rows.filter(r=>!r.negative&&!['parse','check'].includes(r.lane)&&['fail','timeout','crash','unsupported'].includes(r.status))) {
    const reason=r.result?.diagnostic||r.result?.reason||r.reason||'unknown';
    const key=r.lane+': '+reason;
    (executionGroups[key]??={lane:r.lane,reason,ids:[]}).ids.push(r.id);
  }
  return {
    completedRows:rows.length,
    positiveChecks:{total:positive.length,accepted:positive.filter(accepted).length,other:positive.filter(r=>!accepted(r)).map(r=>({id:r.id,result:r.result,status:r.status}))},
    errorExpectations:{total:negative.length,acceptedForPhaseTriage:negative.filter(accepted).map(r=>r.id),
      acceptedWithExpectedLaterRejection:acceptedErrors.filter(r=>r.lanes.length),
      acceptedWithoutExpectedLaterRejection:acceptedErrors.filter(r=>!r.lanes.length).map(r=>r.id),
      rejectedByPhase:negative.filter(rejected).reduce((out,r)=>(out[r.result.phase]=(out[r.result.phase]||0)+1,out),{}),
      timeoutsOrCrashes:negative.filter(r=>!accepted(r)&&!rejected(r)).map(r=>r.id)},
    positiveCheckingFailureGroups:Object.entries(failureGroups).map(([reason,ids])=>({reason,count:ids.length,ids})).sort((a,b)=>b.count-a.count),
    positiveExecutionFailureGroups:Object.values(executionGroups).map(g=>({...g,count:g.ids.length})).sort((a,b)=>b.count-a.count),
    exactLanes:Object.fromEntries([...new Set(rows.map(r=>r.lane))].map(lane=>[lane,rows.filter(r=>r.lane===lane).reduce((out,r)=>(out[r.status||r.result?.status||'unknown']=(out[r.status||r.result?.status||'unknown']||0)+1,out),{})])),
    note:'Accepted Error expectations require phase-specific triage. Rejections with different diagnostics are not exact conformance passes.'
  };
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  const file=process.argv[2];
  if(!file)throw Error('Usage: semantic-summary.mjs REPORT.json|PROGRESS.jsonl');
  const text=fs.readFileSync(file,'utf8'),rows=file.endsWith('.jsonl')?text.trim().split('\n').filter(Boolean).map(line=>JSON.parse(line)):JSON.parse(text).results;
  console.log(JSON.stringify(semanticSummary(rows),null,2));
}
