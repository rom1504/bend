// Compare completed observations, not the target runner's overall conformance verdict.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const identity=f=>({file:path.resolve(f),sha256:hash(f)});
const read=f=>JSON.parse(fs.readFileSync(f));
const [selectionFile,pairedFile,output]=process.argv.slice(2);
assert.ok(output,'usage: SELECTION_PROVENANCE PAIRED_REPORT FRESH_OUTPUT');
const selection=read(selectionFile),paired=read(pairedFile);
const inputs=[identity(import.meta.filename),identity(selectionFile),identity(pairedFile)];
for(const item of [selection.baseline,selection.reference]) {
  assert.equal(hash(item.file),item.sha256); inputs.push(identity(item.file));
}
assert.ok(paired.finished); assert.equal(paired.error,undefined);
const selected=new Set(Object.keys(selection.groups));
for(const name of ['candidate','reference']) {
  const item=paired.attempts[name]; assert.equal(hash(item.file),item.sha256);
  const report=read(item.file); assert.ok(report.finished);
  assert.equal(report.results.length,selected.size); assert.deepEqual(report.changedInputs,[]);
  assert.ok(report.results.every(x=>selected.has(x.id)&&x.lane==='parse'));
  inputs.push(identity(item.file));
}
const before=new Map(read(selection.baseline.file).results.filter(x=>x.lane==='parse').map(x=>[x.id,x.result]));
const keys=['status','phase','checked','exitCode','diagnostic'];
const observation=x=>Object.fromEntries(keys.map(k=>[k,x[k]??null]));
const semantic=x=>[x.status,x.phase,x.checked??null];
const rows=paired.rows.map(row=>{
  assert.ok(selected.has(row.id));
  const old=before.get(row.id); assert.ok(old);
  const unchanged=JSON.stringify(observation(old))===JSON.stringify(observation(row.candidate));
  const exact=JSON.stringify(observation(row.candidate))===JSON.stringify(observation(row.reference));
  const sameClassification=JSON.stringify(semantic(old))===JSON.stringify(semantic(row.candidate));
  const priorAcceptanceGap=selection.groups[row.id]!=='both-rejected';
  return {id:row.id,group:selection.groups[row.id],unchanged,exact,sameClassification,priorAcceptanceGap,
    pass:sameClassification&&(unchanged||exact)&&(!priorAcceptanceGap||unchanged)};
});
assert.equal(rows.length,selected.size); assert.equal(new Set(rows.map(x=>x.id)).size,rows.length);
const report={kind:'phase5-structured-parser-negative-comparison',complete:true,pass:rows.every(x=>x.pass),
  scope:'All167 baseline parse-error cases; every candidate must remain unchanged or become exactly the live reference. Two existing acceptance gaps are retained. This is not full conformance or a performance measurement.',
  inputs,counts:{selected:rows.length,repaired:rows.filter(x=>!x.unchanged&&x.exact).length,
    unchanged:rows.filter(x=>x.unchanged).length,priorAcceptanceGaps:rows.filter(x=>x.priorAcceptanceGap).length,
    changedMismatch:rows.filter(x=>!x.unchanged&&!x.exact).length,classificationChanges:rows.filter(x=>!x.sameClassification).length},rows};
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:report.pass,counts:report.counts}));
if(!report.pass)process.exitCode=1;
