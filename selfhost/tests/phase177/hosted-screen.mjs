// Measure checked Bend frontend APIs. No compiler work is implemented here.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const args={};for(let i=2;i<process.argv.length;i+=2)args[process.argv[i].slice(2)]=process.argv[i+1];
const out=path.resolve(args.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const binding=JSON.parse(fs.readFileSync(args.binding));
const report={kind:'phase177-hosted-frontend-screen',complete:false,inputs:[pin(import.meta.filename),pin(process.execPath),pin(args.binding),binding.base,binding.carrier,pin(args.source)],runs:[],scope:'In-process checked Bun APIs, prepared immutable Base, fresh compilation requests in balanced order. No process startup or source-to-executable timing; digest observation excluded. Finite complete-value gates are separate.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 const api={},seeds={};
 for(const role of ['baseline','candidate']){
  const r=JSON.parse(fs.readFileSync(args[role]));need(r.complete&&r.checked,'checked API');report.inputs.push(pin(args[role]),r.source,r.api,...r.inputs);report.inputs.forEach(verify);
  api[role]=(await import(pathToFileURL(r.api.file))).default;
  const prepared=api[role].p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);need(prepared.$==='P86PreparationReady','prepared Base');seeds[role]=prepared.seed;
 }
 const source=path.resolve(args.source),text=fs.readFileSync(source,'utf8');let expected;
 for(let cycle=0;cycle<2;cycle++)for(const role of cycle%2?['candidate','baseline']:['baseline','candidate']){
  const start=performance.now(),value=api[role].p175fp_plan('request',seeds[role],source,text),seconds=(performance.now()-start)/1000;
  need(value.$==='P175FRequest','successful request: '+value.error);const digest=api[role].p175fd_value(value);if(expected===undefined)expected=digest;need(digest===expected,'digest differs');
  report.runs.push({role,cycle,seconds,digest});save();
 }
 const med=role=>report.runs.filter(r=>r.role===role).reduce((n,r)=>n+r.seconds,0)/2;
 report.medians={baseline:med('baseline'),candidate:med('candidate')};report.ratio=report.medians.candidate/report.medians.baseline;
 report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,medians:report.medians,ratio:report.ratio,error:report.error}));
