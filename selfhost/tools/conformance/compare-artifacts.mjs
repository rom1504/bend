#!/usr/bin/env node
// Compare observed behavior, not compiler speed or diagnostic-rule soundness.
import fs from 'node:fs';
import crypto from 'node:crypto';
import {semanticSummary} from './semantic-summary.mjs';
const [beforeFile,afterFile,outputFile]=process.argv.slice(2);
if(!outputFile)throw Error('Usage: compare-artifacts.mjs BEFORE.json AFTER.json OUTPUT.json');
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const before=read(beforeFile),after=read(afterFile);
if(before.inventory.revision!==after.inventory.revision)throw Error('Different upstream pins');
const inventory=r=>new Map(r.inventory.tests.map(t=>[t.id,t.sha256]));
const a=inventory(before),b=inventory(after);
if(a.size!==b.size||[...a].some(([id,hash])=>b.get(id)!==hash))throw Error('Different fixture inventory');
const key=r=>r.id+'\0'+r.lane,prior=new Map(before.results.map(r=>[key(r),r]));
const normalize=(value,report)=>typeof value==='string'?value.split(report.options.upstream).join('$UPSTREAM'):value??null;
const observed=(r,report)=>({verdict:r.status,evidence:r.evidence??null,
  status:r.result?.status??null,phase:r.result?.phase??null,checked:r.result?.checked??null,
  exitCode:r.result?.exitCode??null,diagnostic:normalize(r.result?.diagnostic,report),
  output:normalize(r.result?.output??r.result?.stdout,report)});
const changes=[],missing=[],negative=[];
for(const r of after.results){
 const p=prior.get(key(r));if(!p){missing.push({side:'before',id:r.id,lane:r.lane});continue;}
 prior.delete(key(r));const x=observed(p,before),y=observed(r,after),same=JSON.stringify(x)===JSON.stringify(y);
 if(!same)changes.push({id:r.id,lane:r.lane,negative:r.negative,before:x,after:y});
 if(r.negative&&r.lane==='check')negative.push({id:r.id,sameObservedBehavior:same,before:x,after:y});
}
for(const r of prior.values())missing.push({side:'after',id:r.id,lane:r.lane});
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const report={before:{file:beforeFile,sha256:sha(beforeFile),identity:before.identity},after:{file:afterFile,sha256:sha(afterFile),identity:after.identity},
 method:'Compare verdict, rejection phase, checked flag, exit code, diagnostic and output. Only the exact upstream checkout prefix is normalized. Timing, compiler/toolchain identity and declaration-report presentation are excluded; source reports retain them.',
 sameObservedBehavior:changes.length===0&&missing.length===0,changes,missing,
 beforeSummary:semanticSummary(before.results),afterSummary:semanticSummary(after.results),negativeChecks:negative,
 limitation:'Unchanged observations preserve existing diagnostic differences and unproven intended-rule coverage. This does not prove checker equivalence or validate GPU hardware gates.'};
fs.writeFileSync(outputFile,JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({changed:changes.length,missing:missing.length,negativeChecks:negative.length}));
