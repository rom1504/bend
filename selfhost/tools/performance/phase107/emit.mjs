// Every transformation and emitter invoked here is implemented in checked Bend.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';import crypto from 'node:crypto';
const [apiArg,graphsArg,outArg,method='nx_inline',pipeline='inline']=process.argv.slice(2),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const api=(await import(pathToFileURL(path.resolve(apiArg)))).default;
const pin=file=>({file:path.resolve(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const report={complete:false,method,pipeline,api:pin(apiArg),inputs:[pin(import.meta.filename)],rows:[],rejections:[]};
const selected=[];
for(const name of fs.readdirSync(graphsArg).filter(n=>!n.endsWith('.json')).sort()){
 const file=path.join(graphsArg,name,'selected.json');report.inputs.push(pin(file));
 const start=performance.now(),r=api.nxk_lower(JSON.parse(fs.readFileSync(file)),'bench');
 const seconds=(performance.now()-start)/1000;
 if(name.startsWith('refuse_')){if(!r.error)throw Error('unsupported source accepted '+name);report.rejections.push({name,error:r.error,seconds});}
 else {if(r.error)throw Error(name+': '+r.error);selected.push({name:'source-'+name,program:r.program,lowerSeconds:seconds});}
}
for(const name of ['text','list','tree','closure','tail','many','shared','shared_borrow'])selected.push({name:'ir-'+name,program:api.nx_workload(name).value,lowerSeconds:null});
for(const {name,program:raw,lowerSeconds} of selected){
 for(const budget of [0,4096]){
  const start=performance.now(),program=api.nx_optimize(api[method](pipeline==='tail-fused'&&budget>0?api.nx_tail_optimize(raw):raw,budget));
  const optimizeSeconds=(performance.now()-start)/1000;
  if(api.nx_verify(program)!==true)throw Error('verification '+name+'/'+budget);
  const stem=path.join(out,name+'-'+budget),times={};
  for(const [ext,fn] of [['json','nx_json_program'],['c','nx_c_program'],['ssa','nxq_program']]){
   const begin=performance.now();fs.writeFileSync(stem+'.'+ext,api[ext==='ssa'&&pipeline==='tail-fused'&&budget>0?'nxq_program_fused':fn](program));times[ext]=(performance.now()-begin)/1000;
  }
  report.rows.push({name,budget,stem,lowerSeconds,optimizeSeconds,emitSeconds:times,nodes:api.nx_inline_nodes(program)});
 }
}
report.complete=true;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({rows:report.rows.length,rejections:report.rejections}));
