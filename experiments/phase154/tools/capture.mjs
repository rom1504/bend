// Capture current checked frontend output before any QBE lowering.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import assert from 'node:assert/strict';import {pathToFileURL}from'node:url';
import {encodeGraph,writeGraph}from'./graph.mjs';
const root=path.resolve(import.meta.dirname,'../../..'),options={};
for(let i=2;i<process.argv.length;i+=2){assert(process.argv[i].startsWith('--')&&process.argv[i+1]);options[process.argv[i].slice(2)]=process.argv[i+1]}
for(const key of ['plan','out'])assert(options[key]);
const read=p=>JSON.parse(fs.readFileSync(p)),pin=file=>{file=fs.realpathSync(file);const data=fs.readFileSync(file);return{file,bytes:data.length,sha256:crypto.createHash('sha256').update(data).digest('hex')}};
const verify=p=>{const now=pin(p.file);assert(now.bytes===p.bytes&&now.sha256===p.sha256,'Changed input: '+p.file)};
function items(list){const result=[];while(list?.$==='Con'){assert(result.length<1_000_000);result.push(list.head);list=list.tail}assert.equal(list?.$,'Nil');return result}
const out=path.resolve(options.out);assert(out.startsWith(root+'/selfhost/build/phase154/')&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=[pin(import.meta.filename),pin(path.join(import.meta.dirname,'graph.mjs')),pin(options.plan),pin(process.execPath)];
const report={kind:'phase154-prelower-capture',version:1,complete:false,inputs,rows:[],scope:'Capture current checked request and source/erased owners before lowering, then run the original small backend once for independent full-program metadata. Source census and acquisition clocks are not performance claims.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
function census(term){let nodes=0,branches=0,calls=0,refs=0,lets=0;const todo=[term];while(todo.length){const t=todo.pop();assert(++nodes<=200_000,'Owner syntax bound exceeded');const tag=t.$==='KTerm'?t.tag:t.$==='KLambda'?'Lam':t.$==='KLiteral'?'Literal':null;assert(tag,'Unknown source term');
 if(['Mat','If','NIf','NMat'].includes(tag))branches++;if(['App','NCall','NApply','NOp'].includes(tag))calls++;if(tag==='Ref')refs++;if(tag==='Let')lets++;if(t.kids)todo.push(...items(t.kids));}return{nodes,branches,calls,refs,lets}}
function select(rows,count){assert(rows.length>=count,'Insufficient eligible owners: '+rows.length);const chosen=new Set();
 for(const key of ['branches','calls'])for(const r of [...rows].sort((a,b)=>b.census[key]-a.census[key]||b.census.nodes-a.census.nodes||a.reachIndex-b.reachIndex).slice(0,2))chosen.add(r.reachIndex);
 for(let i=0;i<count-4;i++)chosen.add(rows[Math.round(i*(rows.length-1)/Math.max(1,count-5))].reachIndex);
 for(const r of rows){if(chosen.size>=count)break;chosen.add(r.reachIndex)}return rows.filter(r=>chosen.has(r.reachIndex));}
try{
 const plan=read(options.plan);assert(plan.kind==='phase154-prelower-capture-plan'&&plan.complete);inputs.push(...plan.inputs,plan.qualification,plan.apiReceipt,plan.base,...plan.families.map(f=>f.source));inputs.forEach(verify);
 const acquisition=read(plan.apiReceipt.file);assert(acquisition.kind==='bend-checked-hosted-api'&&acquisition.complete&&acquisition.checked);assert(acquisition.source.bytes===plan.canonicalIdentity.bytes&&acquisition.source.sha256===plan.canonicalIdentity.sha256);
 for(const name of ['p86_prepare','p86_plan','ns_body','p134e_plan'])assert(acquisition.exports.includes(name));inputs.push(acquisition.api,acquisition.source);
 report.historicalAcquisitionInputs=[];
 for(const original of acquisition.inputs){const historical=(plan.historicalAcquisitionInputs??[]).find(row=>row.declared.file===original.file&&row.declared.bytes===original.bytes&&row.declared.sha256===original.sha256);
  if(historical){assert(['selfhost/tools/build/hosted.mjs','selfhost/src/compiler.json'].includes(path.relative(root,original.file)));assert(historical.retained.bytes===original.bytes&&historical.retained.sha256===original.sha256);inputs.push(historical.retained);report.historicalAcquisitionInputs.push(historical)}
  else inputs.push(original);
 }inputs.forEach(verify);
 report.api=acquisition.api;report.canonicalIdentity=plan.canonicalIdentity;report.base=plan.base;
 const api=(await import(pathToFileURL(acquisition.api.file))).default,started=performance.now();
 const preparation=api.p86_prepare(plan.base.file,fs.readFileSync(plan.base.file,'utf8'));assert.equal(preparation.$,'P86PreparationReady');report.basePreparationSeconds=(performance.now()-started)/1000;save();
 for(const family of plan.families){const row={name:family.name,source:family.source,complete:false};report.rows.push(row);save();const begin=performance.now();
  const planned=api.p86_plan(preparation.seed,family.source.file,fs.readFileSync(family.source.file,'utf8'));assert.equal(planned.$,'P86PlanReady',family.name+': '+planned.error);
  row.frontendSeconds=(performance.now()-begin)/1000;const request=planned.request;assert.equal(request.$,'NR_Request');
  const names=items(request.names),declared=new Map();for(const d of items(request.source))if(d.$==='KDef'&&d.kind==='Def'&&!declared.has(d.name))declared.set(d.name,d);
  const allowed=new Set(family.owners??family.ownerNames??[]),inventory=[],eligible=[];
  for(let reachIndex=0;reachIndex<names.length;reachIndex++){const name=names[reachIndex],definition=declared.get(name),record=api.ns_body(request.book,name),inside=allowed.has(name)||(family.ownerPrefixes??[]).some(p=>name.startsWith(p));
   const why=!inside?'outside declared family':!definition?'no source Def':record.$!=='KDef'||record.kind!=='NativeErasedBody'?'no original erased body':definition.arity>32?'arity exceeds bounded owner policy':'';
   const item={name,reachIndex,arity:definition?.arity??null,eligible:why==='',exclusion:why};if(!why){item.census=census(record.value);eligible.push({...item,definition,erased:record})}inventory.push(item);
  }
  const selected=select(eligible,plan.functions);row.selection={policy:'Two greatest branch counts, two greatest call counts, then declaration-order spread and earliest remaining owners. No filtering by candidate success.',scope:family.selectionScope,eligible:eligible.length,reached:names.length,owners:selected.map(({definition,erased,...meta})=>meta)};
  const backendStart=performance.now(),emitted=api.p134e_plan(planned);assert.equal(emitted.$,'P134Planned',family.name+': '+emitted.error);row.originalBackendSeconds=(performance.now()-backendStart)/1000;
  const emissionPlan=emitted.plan;
  // Persist exact target data before metadata-only shape inspection, so a host
  // extraction error can be repaired offline without rerunning the frontend.
  const graph=encodeGraph({planned,request,selectedOwners:selected.map(({name,reachIndex,definition,erased})=>({name,reachIndex,definition,erased})),originalEmissionPlan:emissionPlan});
  const graphFile=out+'/'+family.name+'.graph.json';row.graphBytes=writeGraph(graphFile,graph);row.graph=pin(graphFile);row.graphNodes=graph.nodes.length;save();
  let raw,direct=[];
  if(emissionPlan.$==='P134Admitted'){assert.equal(emissionPlan.program.$,'P113AProgram');const program=emissionPlan.program.original;assert.equal(program.$,'P113DProgram');direct=items(program.functions);raw=program.original.program;}
  else if(emissionPlan.$==='P134Direct'){assert.equal(emissionPlan.program.$,'P113DProgram');direct=items(emissionPlan.program.functions);raw=emissionPlan.program.original.program;}
  else if(emissionPlan.$==='P134Static')raw=emissionPlan.program.program;
  else{assert.equal(emissionPlan.$,'P134Raw');raw=emissionPlan.program;}
  assert.equal(raw.$,'P111Program');const headerFile=out+'/'+family.name+'-headers.json';
  const headers={kind:'phase154-original-program-headers',version:1,complete:true,family:family.name,emissionPlanTag:emissionPlan.$,
   segments:items(raw.segments).map(fn=>({...fn,body:{$:'Nil'}})),constructors:items(raw.constructors),directHeaders:direct.map(fn=>({...fn,body:{$:'Nil'}})),
   scope:'Exact original final-program order/ABI fields. Bodies stripped only in this companion packet; complete original plan remains in the graph.'};
  fs.writeFileSync(headerFile,JSON.stringify(headers)+'\n');row.headers=pin(headerFile);row.headerCounts={raw:headers.segments.length,direct:headers.directHeaders.length,constructors:headers.constructors.length};
  const inventoryFile=out+'/'+family.name+'-owners.json';fs.writeFileSync(inventoryFile,JSON.stringify({kind:'phase154-owner-inventory',complete:true,selection:row.selection,owners:inventory},null,2)+'\n');row.inventory=pin(inventoryFile);row.complete=true;save();
 }
 inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1}
finally{save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.map(r=>({name:r.name,complete:r.complete,nodes:r.graphNodes,bytes:r.graphBytes})),error:report.error}))}
