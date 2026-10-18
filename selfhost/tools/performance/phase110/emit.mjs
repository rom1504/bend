// Transport authenticated checked facts into Bend-owned lowering and emitters.
// Source contracts select entries only; all optimization and code generation is Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,captureArg,outArg,variant='reverse',policy='fused']=process.argv.slice(2);
const apiFile=path.resolve(apiArg),capture=path.resolve(captureArg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=file=>({file:path.resolve(file),bytes:fs.statSync(file).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify=p=>{if(JSON.stringify(pin(p.file))!==JSON.stringify(p))throw Error('changed '+p.file);};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const array=x=>{const xs=[];while(x.$==='Con'){xs.push(x.head);x=x.tail;}if(x.$!=='Nil')throw Error('bad list');return xs;};
const record=JSON.parse(fs.readFileSync(path.join(capture,'report.json')));
if(!record.complete)throw Error('capture incomplete');
for(const p of record.products)verify(p);
const api=(await import(pathToFileURL(apiFile))).default;
const report={kind:'phase110-owned-library-emission',complete:false,variant,policy,inputs:[pin(apiFile),pin(import.meta.filename),pin(path.join(capture,'report.json')),...record.products],controls:{},rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 for(const [name,fn] of [['nx','nxlib_control_report'],['ownership','nxo_ownership_report'],['policy','nxo_policy_report'],['policy110','nxo110_policy_report'],['pair','nx110_control_report'],['take','nx110_take_control_report'],['alias','nx110_alias_control_report'],['calls','nxc_control_report'],['runtime-ir','nx110rt_control_report'],['runtime-width','nx110rt_width_report'],['runtime-calls','nx110rt_call_control_report'],['runtime-predicates','nx110rt_predicate_report'],['runtime-general','nx110rtg_control_report'],['runtime-stored','nx110rts_control_report'],['runtime-namespace','nx110rtn_control_report'],['runtime-spare','nx110rtw_control_report'],['runtime-combined','nx110rtc_control_report']]){
  if(!api[fn])continue;
  const text=api[fn]();fs.writeFileSync(path.join(out,name+'-controls.txt'),text);
  if(text.includes('FAIL'))throw Error(name+' controls failed');
  report.controls[name]={cases:text.trim().split('\n').length,passed:true};
 }
 const facts=array(JSON.parse(fs.readFileSync(path.join(capture,'native-facts.json'))));
 const ctors=list([['Nil',0,0],['Con',1,2],['SNil',2,0],['SCon',3,2]].map(([name,cid,arity])=>({$:'NxoCtor',name,cid,arity})));
 const entries=variant==='reverse'?[['nt_reverse','list_reverse'],['String.reverse.go','string_reverse']]:
  ['discard','duplicate'].includes(variant)?[['p109_list_'+variant,'list_reverse'],['p109_string_'+variant,'string_reverse']]:
  variant==='tail'?[['List.tail','list_tail']]:variant==='last'?[['List.last.go','list_last']]:
  variant==='append'?[['nt_reverse','list_reverse'],['nt_append','list_append']]:null;
 if(!entries)throw Error('unknown source contract '+variant);
 const symbols=entries.map(e=>e[1]),exports=list(variant==='append'?['list_append']:symbols);
 const selected=entries.map(([name,symbol])=>{const fact=facts.find(d=>d.name===name);if(!fact)throw Error('missing checked source '+name);return {name,symbol,fact};});
 const start=performance.now(),privateIR=policy.startsWith('runtime-ir-'),pair=['pair','pair-take'].includes(policy),basePolicy=pair?'specialized':policy;
 let library,functions=[],workers=[];
 if(privateIR&&api.nx110rt_lower_library){
  const result=api.nx110rt_lower_library(list(selected.map(({fact,symbol})=>({$:'NxcSource',fact,symbol}))),ctors,exports,policy.slice('runtime-ir-'.length));
  if(result.error)throw Error(result.error);library=result.library;
  for(const worker of array(library.workers)){
   fs.writeFileSync(path.join(out,worker.function.name+'.owned.json'),JSON.stringify(worker.ownership,null,2)+'\n');
   fs.writeFileSync(path.join(out,worker.function.name+'.nx.json'),api.nx_json_function(worker.function)+'\n');
  }
  report.rows=selected.map(({name,symbol})=>({name,symbol}));
 }else if(variant==='append'){
  if(privateIR)throw Error('ordinary-call runtime-IR closure not admitted');
  const result=api.nxc_lower_library(list(selected.map(({fact,symbol})=>({$:'NxcSource',fact,symbol}))),ctors,exports,basePolicy);
  if(result.error)throw Error(result.error);library=result.library;
  for(const row of array(result.ownership)){
   fs.writeFileSync(path.join(out,row.symbol+'.owned.json'),JSON.stringify(row.body??row.ops??row.ownership,null,2)+'\n');
  }
  report.rows=selected.map(({name,symbol})=>({name,symbol}));
 }else{
  for(const {name,symbol,fact} of selected){
   const t=performance.now();let result;
   if(privateIR){result=api.nxo_lower110rt(fact,ctors,symbol,policy.slice('runtime-ir-'.length));if(result.error)throw Error(name+': '+result.error);workers.push(result.worker);result={function:result.worker.function,ownership:result.worker.ownership};}
   else {result=['raw','trusted','fused'].includes(basePolicy)?api.nxo_lower_policy(fact,ctors,symbol,basePolicy):api.nxo_lower110_policy(fact,ctors,symbol,basePolicy);if(result.error)throw Error(name+': '+result.error);functions.push(result.function);}
   report.rows.push({name,symbol,lowerSeconds:(performance.now()-t)/1000});
   fs.writeFileSync(path.join(out,symbol+'.owned.json'),JSON.stringify(result.ownership,null,2)+'\n');
   fs.writeFileSync(path.join(out,symbol+'.nx.json'),api.nx_json_function(result.function)+'\n');
  }
  library=privateIR?{$:'Nx110RtLibrary',workers:list(workers),exports}:{$:'NxLibrary',imports:['raw','trusted','fused'].includes(basePolicy)?api.nxlib_runtime_imports_policy(basePolicy):api.nxlib_runtime110_imports_policy(basePolicy),functions:list(functions),exports};
 }
 let prefix='nxlib_';
 if(privateIR)prefix='nx110rt_';
 else{
  if(!api.nxlib_verify(library))throw Error('scalar library refused');
  if(pair){library=policy==='pair-take'?api.nx110_take_pair_library(library):api.nx110_pair_library(library);prefix='nx110_';}
 }
 if(!api[prefix+'verify'](library))throw Error(prefix+' library refused');
 fs.writeFileSync(path.join(out,'library.json'),JSON.stringify(library,null,2)+'\n');
 for(const [format,fn] of [['ssa','qbe'],['c','c']])fs.writeFileSync(path.join(out,'program.'+format),api[prefix+fn](library));
 report.seconds=(performance.now()-start)/1000;report.complete=true;
 report.outputs=['library.json','program.ssa','program.c',...symbols.map(s=>s+'.owned.json')].map(n=>pin(path.join(out,n)));
 for(const p of report.inputs)verify(p);save();console.log(JSON.stringify({complete:true,seconds:report.seconds,functions:report.rows}));
}catch(e){report.error=String(e);save();throw e;}
