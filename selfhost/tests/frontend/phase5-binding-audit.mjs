// Verify the specific intended rules, not just matching rejection phases.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [beforeFile,focusedFile,executionFile,scopesFile,output]=process.argv.slice(2);
if(!output||fs.existsSync(output))throw Error('Usage: phase5-binding-audit.mjs BEFORE_PAIRED FOCUSED_PAIRED EXECUTION_PAIRED SCOPE_PAIRED NEW_REPORT');
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const paths=[beforeFile,focusedFile,executionFile,scopesFile,import.meta.filename].map(file=>({file:path.resolve(file),sha256:hash(file)}));
const report={kind:'phase5-frontend-focused-audit',complete:false,inputs:paths,newBootstrap:false,checks:[],scope:'Selected acceptance/phase, specific binder/decorator-rule diagnostics and exact interpreter/JS results; not full conformance.'};
try{
 const [before,focused,execution,scopes]=paths.slice(0,4).map(row=>JSON.parse(fs.readFileSync(row.file)));
 assert.equal(before.rows.length,22);assert.equal(focused.rows.length,70);assert.equal(execution.rows.length,12);assert.equal(scopes.rows.length,27);
 for(const selected of [focused,execution,scopes]){assert.equal(selected.selectedComplete,true);assert.equal(selected.missing.length,0);for(const row of selected.rows){assert.equal(row.referenceVerdict,'pass');assert.equal(row.candidateVerdict,'pass');assert.equal(row.semanticAgreement,true);}}
 for(const selected of [execution,scopes])for(const row of selected.rows)if(row.lane!=='check'){assert.equal(row.reference.status,'ok');assert.equal(row.candidate.status,'ok');assert.equal(row.reference.checked,true);assert.equal(row.candidate.checked,true);assert.equal(row.exactAgreement,true);report.checks.push({id:row.id,lane:row.lane,output:row.candidate.output});}
 const named=new Map(focused.rows.map(row=>[row.id,row]));
 const constructor=['parallel-bare-constructor','parallel-first-bad-body','parallel-first-unbound-value','parallel-base-constructor'];
 const parallel=['parallel-braced-constructor','parallel-field-constructor'];
 const decorator=['unsafe-law','unsafe-type','unsafe-import','unsafe-eof','unsafe-repeated','unsafe-unknown-decorator'];
 for(const [names,ref,own]of [[constructor,'a braced constructor pattern','a constructor pattern requires braces'],[parallel,'a parallel let binds names','a parallel let binds names'],[decorator,"'def' (@unsafe marks the def below it)",'expected def after @unsafe']])for(const name of names){const row=named.get('phase5/'+name);assert.ok(row);assert.ok(row.reference.diagnostic.includes(ref));assert.ok(row.candidate.diagnostic.includes(own));report.checks.push({id:row.id,intendedRule:true,reference:row.reference.diagnostic,candidate:row.candidate.diagnostic});}
 const good=named.get('phase5/parallel-bare-constructor').candidate.diagnostic;
 for(const name of ['parallel-first-bad-body','parallel-first-unbound-value'])assert.equal(named.get('phase5/'+name).candidate.diagnostic,good);
 report.firstErrorControls=true;
 report.baselineSemanticMismatches=before.rows.filter(row=>!row.semanticAgreement).map(row=>row.id);
 assert.equal(report.baselineSemanticMismatches.length,8);
 for(const id of report.baselineSemanticMismatches)assert.equal(named.get(id).semanticAgreement,true);
 report.knownDifferentRule={id:'phase5/parallel-first-bad-value',reference:named.get('phase5/parallel-first-bad-value').reference.diagnostic,candidate:named.get('phase5/parallel-first-bad-value').candidate.diagnostic,reason:'Existing raw-expression brace parsing discrepancy; same parse rejection is not evidence of intended-rule parity.'};
 report.observations={focusedCheck:70,scopeCheck:9,interpreter:15,js:15,total:109};
 report.exactDiagnosticDifferences=focused.rows.filter(row=>!row.exactAgreement).map(row=>row.id);
 for(const item of paths)assert.equal(hash(item.file),item.sha256);
 report.inputsUnchanged=true;report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,observations:report.observations,error:report.error}));
