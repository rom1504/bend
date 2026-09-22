// Intended-rule and exact-observation audit; no normalization of compiler text.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [configArg,output]=process.argv.slice(2);
if(!output||fs.existsSync(output))throw Error('Usage: phase5-constructor-audit.mjs CONFIG NEW_REPORT');
const configFile=fs.realpathSync(configArg),config=JSON.parse(fs.readFileSync(configFile));
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const inputs=[configFile,import.meta.filename].map(file=>({file,sha256:hash(file)}));
const read=name=>{const file=fs.realpathSync(path.resolve(path.dirname(configFile),config[name]));inputs.push({file,sha256:hash(file)});return JSON.parse(fs.readFileSync(file));};
const report={kind:'phase5-constructor-diagnostic-audit',complete:false,inputs,scope:'Selected intended rules, exact raw diagnostics and unchanged authoritative checker strings; no whole-language or timing claim.'};
try {
  const cases=read('cases').cases,before=read('before'),after=read('after'),bv=read('beforeVerdicts'),av=read('afterVerdicts');
  assert.equal(before.rows.length,cases.length);assert.equal(after.rows.length,cases.length);
  assert.equal(after.selectedComplete,true);assert.equal(bv.complete,true);assert.equal(av.complete,true);
  const index=rows=>new Map(rows.map(row=>[row.id,row])),b=index(before.rows),a=index(after.rows),v0=index(bv.rows),v1=index(av.rows);
  const changed=new Set(['unknown-inferred-ctor','datatype-as-constructor','unknown-family','filled-def-as-family','unfilled-law-as-family','unknown-family-before-argument']);
  const verdict=r=>({status:r.status,phase:r.phase,checked:r.checked,exitCode:r.exitCode});
  report.cases=cases.map(test=>{
    const old=b.get(test.id),next=a.get(test.id);assert.ok(old&&next);
    assert.equal(next.referenceVerdict,'pass');assert.equal(next.candidateVerdict,'pass');
    assert.deepEqual(next.reference,old.reference,'Live reference observation changed');
    assert.deepEqual(verdict(next.candidate),verdict(old.candidate),'Acceptance, phase or checked flag changed');
    assert.deepEqual(v0.get(test.id).authoritative,v1.get(test.id).authoritative,'Authoritative checker verdict changed');
    if(test.referenceReason){
      assert.ok(next.reference.diagnostic.includes(test.referenceReason),'Reference does not exercise intended reason: '+test.id);
      assert.ok(next.candidate.diagnostic.includes(test.referenceReason),'Candidate does not report intended reason: '+test.id);
    }
    if(!changed.has(test.id.split('/').at(-1)))assert.deepEqual(next.candidate,old.candidate,'Unrelated control diagnostic changed');
    return {id:test.id,intendedRule:true,authoritativeUnchanged:true,exactBefore:old.exactAgreement,exactAfter:next.exactAgreement,reference:next.reference,candidate:next.candidate};
  });
  const oldUp=read('upstreamBefore'),newUp=read('upstreamAfter'),u0=index(oldUp.rows);
  assert.equal(oldUp.rows.length,newUp.rows.length);
  report.upstream=newUp.rows.map(row=>{const old=u0.get(row.id);assert.ok(old);assert.deepEqual(row.reference,old.reference);assert.deepEqual(verdict(row.candidate),verdict(old.candidate));return {id:row.id,exactBefore:old.exactAgreement,exactAfter:row.exactAgreement,reference:row.reference,candidate:row.candidate};});
  report.resolvedExact=[...report.cases,...report.upstream].filter(row=>!row.exactBefore&&row.exactAfter).map(row=>row.id);
  report.remainingExact=[...report.cases,...report.upstream].filter(row=>!row.exactAfter).map(row=>row.id);
  report.newExact=[...report.cases,...report.upstream].filter(row=>row.exactBefore&&!row.exactAfter).map(row=>row.id);assert.equal(report.newExact.length,0);
  for(const item of inputs)assert.equal(hash(item.file),item.sha256,'Audit input drift');
  report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,resolvedExact:report.resolvedExact,remainingExact:report.remainingExact,error:report.error}));
