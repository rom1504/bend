// Current exact production closure against the independently frozen closed set.
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import * as S from '../../../experiments/phase147/tools/support.mjs';
const a=S.options();for(const k of ['preparation','out'])assert(a[k]);
const out=S.output(a.out),p=S.read(a.preparation),rfile=path.join(path.dirname(a.preparation),'api/report.json'),r=S.read(rfile);
const inputs=[S.pin(import.meta.filename),S.pin(a.preparation),S.pin(rfile),...p.inputs,p.apiSource,p.exports,p.cases,r.api,r.source];
const report={kind:'phase147-current-runtime-classifier-controls',complete:false,passed:false,inputs,
  canonicalSourceIdentity:p.canonicalSourceIdentity,rows:[],
  scope:'Finite independent closed-set expectations on the exact extracted production declaration; no universal proof, native ownership proof or whole-request speed claim.'};
const save=()=>S.save(out+'/report.json',report);save();
try{
 assert.equal(p.kind,'phase147-current-runtime-classifier');assert(p.complete);assert.equal(r.kind,'bend-checked-hosted-api');assert(r.complete&&r.checked);assert(S.same(p.apiSource,r.source));
 assert.deepEqual(r.exports,['p118z_runtime']);assert.deepEqual(S.read(p.exports.file).exports,r.exports);inputs.forEach(S.verify);
 const api=(await import(pathToFileURL(r.api.file))).default,fixture=S.read(p.cases.file);assert(fixture.complete&&fixture.kind==='phase147-runtime-classifier-cases');
 assert.equal(fixture.cases.length,677);assert.equal(new Set(fixture.cases.map(x=>x.symbol)).size,677);assert.equal(new Set(fixture.accepted).size,25);
 for(const x of fixture.cases){assert.equal(x.expected,fixture.accepted.includes(x.symbol));const actual=api.p118z_runtime(x.symbol);assert.equal(actual,x.expected,JSON.stringify(x.symbol));report.rows.push({symbol:x.symbol,expected:x.expected,actual,passed:true});}
 inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,cases:report.rows.length,error:report.error}));}
