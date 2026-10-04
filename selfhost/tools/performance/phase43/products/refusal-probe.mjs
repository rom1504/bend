// Small compiler predicate regression discriminator; root executes under limits.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';import {verifyAttempt} from '../../../development/workflow.mjs';
const[attemptArg,outArg]=process.argv.slice(2);assert(attemptArg&&outArg,'usage: refusal-probe.mjs CHECKED_ATTEMPT NEW_OUT');const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);const attempt=await verifyAttempt(path.resolve(attemptArg)),source=fs.readFileSync(attempt.api.file,'utf8'),sha=s=>createHash('sha256').update(s).digest('hex');assert(source.includes('$j_linear_u32_prefix$'));
const addition=`
export function phase43PrefixRefusals(){
 const nil={$:'Nil'};const term=(tag,name='',kids=[],id=0,quant=0)=>({$:'KTerm',tag,name,id,quant,kids:kids.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),removed:nil,originBegin:0,originEnd:0});
 const absent=term('Absent'),var0=term('Var','',[],990001),ref=term('Ref','U32.add'),lit=term('Lit','U32',[],1),oneArg=term('App','',[ref,lit]);
 const rows=[];for(const[label,t]of[['Absent128',absent],['freeVar128',var0],['wrongArity128',oneArg]]){const begin=performance.now(),value=run_loop($j_linear_u32_prefix$(nil,nil,t,128));rows.push({label,value,milliseconds:performance.now()-begin});}
 for(const[label,t]of[['nonLetAbsent',absent],['nonLetVar',var0],['malformedLet',term('Let','',[term('Bind','',[absent],990002,1),absent])]]){const begin=performance.now(),value=run_loop($j_linear_prefix_alias$(nil,nil,t,'not.a.ref'));rows.push({label,value,milliseconds:performance.now()-begin});}
 return rows;
}
`;
const diagnostic=path.join(out,'api-refusals.mjs');fs.writeFileSync(diagnostic,source+addition,{flag:'wx'});fs.copyFileSync(import.meta.filename,path.join(out,'consumed-refusal.mjs'));const api=await import(pathToFileURL(diagnostic)),rows=api.phase43PrefixRefusals();for(const r of rows){assert.equal(r.value,false,r.label);assert(r.milliseconds<1000,'fast refusal: '+r.label);}const report={kind:'phase43-computed-prefix-refusals',passed:true,scope:'tiny compiler predicate regression; empty-book malformed inputs cannot acquire native proof',api:{path:fs.realpathSync(attempt.api.file),sha256:sha(source)},diagnostic:{path:diagnostic,sha256:sha(source+addition)},rows};fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));
