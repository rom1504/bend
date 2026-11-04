// Correct one preserved fixture expectation. Transport/fixture construction and
// exact observation only; parser and both checkers execute the checked Bend API.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const root=path.resolve(import.meta.dirname,'../../..'),args={};
for(let i=2;i<process.argv.length;i+=2){assert(process.argv[i].startsWith('--')&&process.argv[i+1]);args[process.argv[i].slice(2)]=process.argv[i+1]}
assert(args.out,'--out requires a fresh Phase156 result directory');
const manifest=args.manifest??root+'/selfhost/build/phase156/controls-prepare02/manifest.json';
const priorFile=args.prior??root+'/selfhost/build/phase156/controls02/report.json';
const fixturesFile=root+'/experiments/phase156/publication/fixtures.json';
const read=file=>JSON.parse(fs.readFileSync(file));
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return{file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')}};
const verify=expected=>assert.deepEqual(pin(expected.file),expected);
const list=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function items(value){const result=[];while(value.$==='Con'){result.push(value.head);value=value.tail}assert.equal(value.$,'Nil');return result}
const plan=read(manifest),receipt=read(plan.apiReport),prior=read(priorFile);
assert(plan.complete&&receipt.complete&&receipt.checked);
assert.deepEqual(plan.source,receipt.source);assert.deepEqual(prior.source,plan.source);
assert(prior.complete);
assert.deepEqual(prior.rows.filter(row=>!row.passed).map(row=>row.name),['publication-duplicate-definition']);
const out=path.resolve(args.out);assert(out.startsWith(root+'/selfhost/build/phase156/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=[pin(import.meta.filename),pin(manifest),pin(plan.apiReport),pin(priorFile),pin(fixturesFile),receipt.source,receipt.api,...plan.inputs];
const report={kind:'phase156-duplicate-fixture-correction',version:1,complete:false,passed:false,inputs,source:plan.source,
 correctsOnly:{report:pin(priorFile),row:'publication-duplicate-definition'},rows:[],
 scope:'Preserved controls02 remains unchanged. Exact parser diagnostic replaces its mistaken parse-success expectation; a duplicated genuine parsed KDef separately reaches the checker duplicate guard. No other control or performance result is rerun or inferred.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const parserExpected="Error:\n- expected : a fresh name (duplicate declaration: same)\n- observed : 'same'\nLocation:\n4 |   Off{}\n5>| def same() -> Bit:\n  |     ^^^^\n6 |   Off{}";
const checkerExpected='same: duplicate declaration';
try{
 inputs.forEach(verify);
 const api=(await import(pathToFileURL(receipt.api.file))).default;
 for(const name of ['f_load_graph_trace','p156cp_reference_check','p143cp_check','dg_check_world'])assert(receipt.exports.includes(name));
 const fixture=read(fixturesFile).cases.find(row=>row.name==='duplicate-definition');assert(fixture);
 const sourcePath='/phase156/duplicate-definition.bend';
 const parse=text=>api.f_load_graph_trace(sourcePath,list([{$:'FSource',name:sourcePath,path:sourcePath,text}]));
 const duplicateParsed=parse(fixture.source);
 assert.equal(duplicateParsed.result.error,parserExpected,'Exact independent duplicate parser diagnostic');
 report.rows.push({name:'duplicate-source-parser-refusal',passed:true,expected:parserExpected,actual:duplicateParsed.result.error});save();

 const singleSource='type Bit is Data:\n  Off{}\ndef same() -> Bit:\n  Off{}\n';
 const single=parse(singleSource);assert.equal(single.result.error,'','Single-definition fixture parses');
 const sourceEvents=items(single.result.book);assert.equal(sourceEvents.length,2);
 const definition=sourceEvents.at(-1);assert.equal(definition.$,'KDef');assert.equal(definition.name,'same');assert.equal(definition.kind,'Def');
 assert.equal(api.p156cp_reference_check(single.result.book,true).result.error,'','Single-definition fixture independently checks');
 // Reuse the exact final event, including body, types, IDs, quantities and spans.
 // This is a finite malformed event-list input, not a new host compiler rule.
 const duplicateBook=list([...sourceEvents,definition]);
 for(const logging of [true,false]){
  const original=api.p156cp_reference_check(duplicateBook,logging),candidate=api.p143cp_check(duplicateBook,logging);
  assert.equal(original.result.error,checkerExpected,'Independent duplicate checker refusal');
  assert.deepEqual(candidate,original,'Complete DChecking equality');
  const file=out+'/checker-'+(logging?'logging':'ordinary')+'.json';
  fs.writeFileSync(file,JSON.stringify({singleSource,duplicateBook,original,candidate})+'\n',{flag:'wx'});
  report.rows.push({name:'duplicate-event-checker-refusal',logging,passed:true,error:original.result.error,completeResult:pin(file)});save();
 }
 assert.equal(api.dg_check_world(duplicateBook).result.error,checkerExpected,'Unchanged legacy duplicate guard');
 inputs.forEach(verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.length,error:report.error}))}
