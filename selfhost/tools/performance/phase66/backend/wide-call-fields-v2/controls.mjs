// Root-supervised diagnostic; these clocks are not performance evidence.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [attemptDir,outDir]=process.argv.slice(2);assert(attemptDir&&outDir);
const out=path.resolve(outDir);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map();
const pin=(file,expected)=>{file=fs.realpathSync(file);const b=fs.readFileSync(file),sha256=createHash('sha256').update(b).digest('hex');if(expected)assert.equal(sha256,expected);const x={file,sha256,bytes:b.length};if(inputs.has(file))assert.deepEqual(inputs.get(file),x);inputs.set(file,x);return x;};
const attemptFile=path.join(attemptDir,'attempt.json'),attempt=JSON.parse(fs.readFileSync(attemptFile)),candidateFile=path.join(import.meta.dirname,'candidate.json'),candidate=JSON.parse(fs.readFileSync(candidateFile));
pin(attemptFile);pin(candidateFile);pin(import.meta.filename);pin(process.execPath);
assert(attempt.checked);pin(path.join(attempt.snapshot.root,'src/back/js/direct/calls.bend'),candidate.after.sha256);pin(attempt.api.file,attempt.api.sha256);
const original=fs.readFileSync(attempt.api.file,'utf8');
for(const name of ['run_loop','$jd_calls_match_fields$','$jd_calls_match_arm$','$jd_calls_fields$','$jd_calls_body$','$jd_calls_bad$','$kt$','$all$','$atom$'])assert.equal(original.split('function '+name+'(').length,2,name);
const suffix=`
export const phase66WideFields=()=>{
 const call=(fn,...xs)=>run_loop(fn(...xs)),nil={$:'Nil'};
 const cons=(head,tail=nil)=>({$:'Con',head,tail});
 const term=(tag,name='',id=0,quant=0,kids=nil)=>call($kt$,tag,name,id,quant,kids);
 const absent=call($atom$,'Absent');
 const state=fuel=>({$:'JDCallScan',edges:nil,unknown:false,fuel,valid:true});
 const serialize=x=>JSON.stringify(x,(_,v)=>typeof v==='bigint'?{$bigint:String(v)}:v);
 const equal=(a,b,label)=>{if(serialize(a)!==serialize(b))throw Error(label+' full JDCallScan differs');};
 const make=quantities=>{let tel=absent,body=term('Var','result',9001);for(let i=quantities.length-1;i>=0;i--){tel=call($all$,quantities[i],'x'+i,i,absent,tel);body=term('Lam','x'+i,i,quantities[i],cons(body));}return {tel,body};};
 const result=[];
 const run=(label,qs,fuel,oldCompare,expectValid)=>{
  const {tel,body}=make(qs),s=state(fuel);
  const actual=call($jd_calls_match_fields$,nil,nil,body,tel,0,tel,s);
  const count=call($jd_calls_fields$,tel,fuel);
  const expected=count<65536?call($jd_calls_body$,nil,nil,body,tel,count,s):call($jd_calls_bad$,s);
  equal(actual,expected,label+' projected');
  if(oldCompare){const oldCount=call($jd_calls_fields$,tel,64),old=oldCount<65?call($jd_calls_body$,nil,nil,body,tel,oldCount,s):call($jd_calls_bad$,s);equal(actual,old,label+' old');}
  if(actual.valid!==expectValid)throw Error(label+' valid='+actual.valid);
  result.push({name:label,fields:qs.length,liveFields:qs.filter(q=>q!==0).length,fuel,lookahead:count,remaining:actual.fuel,valid:actual.valid,fullOldScanCompared:oldCompare,pass:true});
 };
 for(const fields of [0,1,2,8,64]){run('small-at-limit-'+fields,Array(fields).fill(1),fields,true,false);run('small-just-enough-'+fields,Array(fields).fill(1),fields+1,true,true);}
 for(const fields of [65,255,256,300])run('wide-'+fields,Array(fields).fill(1),fields+1,false,true);
 run('erased-lookahead-exhausted',[0,0,0],2,false,false);
 run('erased-just-enough',[0,0,0],4,true,true);
 run('mixed-erasure',[0,1,0,2,1],6,true,true);
 const s=state(9),bad=call($jd_calls_match_arm$,nil,nil,term('Var','r',7),absent,0,65536,s);equal(bad,call($jd_calls_bad$,s),'sentinel refusal');result.push({name:'sentinel-refusal',pass:true});
 return result;
};
`;
const derived=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derived,original+suffix,{flag:'wx'});
const module=await import(pathToFileURL(derived));const cases=module.phase66WideFields();
for(const row of inputs.values())pin(row.file,row.sha256);
const report={kind:'phase66-bounded-wide-fields-controls',complete:true,pass:cases.every(x=>x.pass),attempt:pin(attemptFile),api:pin(attempt.api.file,attempt.api.sha256),candidate:pin(candidateFile),derivative:{file:pin(derived),appendOnly:true,suffixSha256:createHash('sha256').update(suffix).digest('hex')},cases,inputs:[...inputs.values()],scope:'Actual checked-image private functions; complete JDCallScan equality at small-width fuel boundaries, explicit wider admission and erased/lookahead exhaustion. Separate real-source execution is required.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({pass:report.pass,cases:cases.length}));
