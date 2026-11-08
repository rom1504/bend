// Complete values from unchanged and compact checked Bend frontend APIs.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
import {expand,exact} from './representation-oracle.mjs';
const a={};for(let i=2;i<process.argv.length;i+=2)a[process.argv[i].slice(2)]=process.argv[i+1];
const out=path.resolve(a.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');
fs.mkdirSync(out,{recursive:true});
const binding=JSON.parse(fs.readFileSync(a.binding));
const report={kind:'phase180-complete-frontend-values',complete:false,inputs:[pin(import.meta.filename),pin(new URL('./representation-oracle.mjs',import.meta.url)),pin(process.execPath),pin(a.binding),binding.base,binding.carrier],rows:[],scope:'Independent complete expanded values, including ordered books, spans, diagnostics, prepared request and retained input aliases. Finite tests, not a compiler correctness theorem.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
 const api={},seed={};
 for(const role of ['baseline','candidate']){
  const r=JSON.parse(fs.readFileSync(a[role]));need(r.complete&&r.checked,'checked API');
  report.inputs.push(pin(a[role]),r.api,r.source,...r.inputs);report.inputs.forEach(verify);
  api[role]=(await import(pathToFileURL(r.api.file))).default;
  const p=api[role].p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
  need(p.$==='P86PreparationReady',p.error??'Base preparation failed');seed[role]=p.seed;
 }
 exact(expand(seed.baseline),expand(seed.candidate));
 const savedSeeds={baseline:structuredClone(seed.baseline),candidate:structuredClone(seed.candidate)};
 const cases=['coverage-map-churn-128','tree-bitonic','test-rle-roundtrip','lexer','editdist','symreg','coverage-closures-64','coverage-record-aggregation-64'].map(name=>{
  const file=path.join(workspace,'selfhost/tools/bench/catalogs/native45/fixtures',name+'.bend');report.inputs.push(pin(file));
  return {name,file,text:fs.readFileSync(file,'utf8'),success:true};
 });
 for(const [name,text] of [['empty',''],['missing-base','def main() -> U32:\n  42\n'],['bad-type','import Base\ndef main() -> U32:\n  "bad"\n'],['bad-syntax','import Base\ndef main( -> U32:\n  1\n'],['duplicate','import Base\ndef x() -> U32:\n  1\ndef x() -> U32:\n  2\ndef main() -> U32:\n  x()\n'],['erased-param','import Base\ndef identity(0 T: Type, x: T) -> T:\n  x\ndef main() -> U32:\n  identity(U32,42)\n']])
  cases.push({name,file:path.join(out,name+'.bend'),text,success:false});
 for(const c of cases){
  for(const mode of ['parse','check','context','annotation','request']){
   const left=api.baseline.p175fp_plan(mode,seed.baseline,c.file,c.text);
   const right=api.candidate.p175fp_plan(mode,seed.candidate,c.file,c.text);
   if(c.success&&mode==='request')need(left.$==='P175FRequest'&&right.$==='P175FRequest','ordinary fixture refused: '+c.name);
   exact(expand(left),expand(right));
   if(mode==='request')exact(left,api.baseline.p175fp_reference(seed.baseline,c.file,c.text));
   need(api.baseline.p175fd_value(left)===api.candidate.p175fd_value(right),'representation-neutral digest mismatch');
   report.rows.push({name:c.name,mode,result:left.$,error:left.error??null,exact:true});save();
  }
 }
 for(const role of ['baseline','candidate'])exact(seed[role],savedSeeds[role]);
 report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
