// Transport and assertions only. The checked Bend API performs all IR work.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [receiptArg,outArg]=process.argv.slice(2);
if(!receiptArg||!outArg)throw Error('CHECKED_API_REPORT FRESH_OUTPUT_DIRECTORY required');
const root=path.resolve(import.meta.dirname,'../../../..');
const receipt=path.resolve(receiptArg),out=path.resolve(outArg);
if(fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase118/'))
  throw Error('Fresh Phase118 output directory required');
const pin=file=>{file=path.resolve(file);const bytes=fs.readFileSync(file);return {
  file,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')};};
const verify=entry=>{const actual=pin(entry.file);assert.equal(actual.bytes,entry.bytes,entry.file);
  assert.equal(actual.sha256,entry.sha256,entry.file);};
const list=value=>{const result=[];while(value?.$==='Con'){result.push(value.head);value=value.tail;}
  assert.equal(value?.$,'Nil','Bend list terminator');return result;};
const live=value=>{const names=list(value);assert(names.every(x=>typeof x==='string'));
  assert.equal(new Set(names).size,names.length,'Duplicate live name');return names.sort();};
const r=JSON.parse(fs.readFileSync(receipt,'utf8'));
assert(r.complete&&r.checked,'Checked API required');
const exports=['p118d_controls','p118d_policy_controls'];
for(const name of exports)assert(r.exports.includes(name),'Missing checked export '+name);
const inputs=[pin(import.meta.filename),pin(receipt),r.api,...r.inputs,pin(process.execPath)];
for(const input of inputs)verify(input);
fs.mkdirSync(out);
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase118-dead-scalars-finite-controls',complete:false,inputs,exports,
  arguments:[{$:'Unit'}],rows:[],scope:'Finite Bend analysis; host compares literal expected bodies and live sets. No host IR rewriting or generated target execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const start=performance.now();
try{
  const api=(await import(pathToFileURL(r.api.file))).default;
  for(const name of exports)assert.equal(typeof api[name],'function',name);
  const controls=api.p118d_controls({$:'Unit'});
  const policy=api.p118d_policy_controls({$:'Unit'});
  const raw=path.join(out,'controls.json');
  fs.writeFileSync(raw,JSON.stringify({controls,policy},null,2)+'\n');report.output=pin(raw);
  const cases=list(controls);
  const names=['dead-chain','overwritten','self-update','partial-branch-definition',
    'both-branches-define','terminal-arm','mutable-condition','parallel-again',
    'parallel-call-overlap','scalar-if','ownership-call','unused-float-call',
    'memory-is-retained','high-word-payload','exposes-bool-diamond'];
  assert.equal(cases.length,15);assert.deepEqual(cases.map(x=>x.name),names);
  for(const c of cases){
    assert.equal(c.$,'P118DControl');
    const row={name:c.name,bodyPassed:false,livePassed:false};report.rows.push(row);
    assert.deepEqual(c.actual,c.expected,c.name+' body');row.bodyPassed=true;
    assert.deepEqual(live(c.live),live(c.expected_live),c.name+' live-in');row.livePassed=true;
  }
  const policyValues=list(policy);assert.equal(policyValues.length,9);
  report.policy=policyValues.map((x,index)=>({index,passed:x?.$==='True'}));
  assert(report.policy.every(x=>x.passed),'Conservative removal whitelist');
  for(const input of inputs)verify(input);
  report.complete=true;
}catch(error){report.error=String(error);report.stack=error?.stack;process.exitCode=1;}
finally{
  report.seconds=(performance.now()-start)/1000;
  report.peakRss=process.resourceUsage().maxRSS*1024;save();
  console.log(JSON.stringify({complete:report.complete,bodyChecks:report.rows.length,
    policyChecks:report.policy?.length,error:report.error,out}));
}
