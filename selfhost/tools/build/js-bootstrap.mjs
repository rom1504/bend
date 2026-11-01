#!/usr/bin/env node
// Self-emission through public Bend APIs only. No source/JS rewriting, TypeScript
// compiler fallback, private helper exposure, hidden cache, or phase imports.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,requireThat,workspace,driverInputs} from './hosted.mjs';
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
function array(xs){const result=[];while(xs?.$==='Con'){requireThat(result.length<100000,'Book/list capacity exceeded');result.push(xs.head);xs=xs.tail;}requireThat(xs?.$==='Nil','Malformed compiler list');return result;}
const args={};for(let i=2;i<process.argv.length;i+=2){requireThat(process.argv[i].startsWith('--')&&process.argv[i+1],'Expected --option value');args[process.argv[i].slice(2)]=process.argv[i+1];}
for(const key of ['generator','generator-report','source','base','out'])requireThat(args[key],'Missing --'+key);
const source=pin(args.source),generator=pin(args.generator),base=pin(args.base),authorityPin=pin(args['generator-report']),authority=read(authorityPin.file);
const rootsFile=path.resolve(args.exports??path.join(workspace,'selfhost/tools/build/js-c-exports.json'));
const rootsDoc=read(rootsFile),roots=rootsDoc.exports;
requireThat(rootsDoc.kind==='bend-hosted-api-exports'&&Array.isArray(roots)&&roots.length>0&&roots.length<=256&&new Set(roots).size===roots.length,'Explicit bounded API roots required');
requireThat(rootsDoc.protocol==='hosted-api-v1'&&JSON.stringify(rootsDoc.targets)===JSON.stringify(['js','c'])&&JSON.stringify(rootsDoc.preparationModes)===JSON.stringify(['live']),'Self-emitted image requires the explicit JS/C live API profile');
const out=path.resolve(args.out);requireThat(!fs.existsSync(out)&&out.startsWith(workspace+'/selfhost/build/'),'Fresh build output required');
const same=(a,b)=>a?.sha256===b?.sha256&&a?.bytes===b?.bytes;
let stage,freshCheck;
if(authority.kind==='bend-js-self-emission'){
  requireThat(authority.complete&&authority.stage==='B2'&&same(generator,authority.image)&&same(source,authority.source),'B3 requires actual same-source B2 producer');
  requireThat(JSON.stringify(roots)===JSON.stringify(authority.roots),'B3 roots differ');
  stage='B3';freshCheck=true;
}else{
  requireThat(['bend-checked-hosted-api','consolidation-checked-api-probe'].includes(authority.kind)&&authority.complete&&authority.checked&&same(generator,authority.api)&&same(source,authority.source),'B2 requires actual same-source checked B1 producer');
  // The generator must expose the compilation pipeline, not every function it
  // will compile. Every requested root is checked against the loaded subject.
  stage='B2';freshCheck=false;
}
const authorityInputs=authority.inputs??authority.inputsObservedAfterExecution??[];
for(const row of authorityInputs)verify(row);
const checkedBases=authority.base?[authority.base]:authorityInputs.filter(row=>row.file.endsWith('/bend2/base.bend'));
requireThat(checkedBases.length===1&&same(base,checkedBases[0]),'Base differs from checked generator authority');
const directRuntime=pin(path.join(workspace,'selfhost/src/runtime/js/direct.mjs'));
const inputs=[pin(import.meta.filename),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs')),pin(process.execPath),source,generator,base,authorityPin,pin(rootsFile),directRuntime,...driverInputs(),...authorityInputs];
if(args.compare)inputs.push(pin(args.compare));
inputs.forEach(verify);fs.mkdirSync(out,{recursive:true});
const report={kind:'bend-js-self-emission',version:1,complete:false,stage,generator,authority:authorityPin,source,base,roots,directRuntime,inputs,steps:[],freshSelfCheck:false,mathematicalProof:false,installed:false,defaultChanged:false,
  scope:'Public selected-library pipeline in the generated Bend compiler. B2 inherits exact complete upstream source checking; B3 freshly type-checks that same source. Complete B2/B3 equality is a separate required flag, not inferred from successful emission.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const started=performance.now();const progress=path.join(out,'progress.jsonl');fs.writeFileSync(progress,'',{flag:'wx'});save();
function step(name,fn){
  const start=performance.now();fs.appendFileSync(progress,JSON.stringify({name,event:'start',elapsedSeconds:(start-started)/1000})+'\n');
  try{const value=fn();report.steps.push({name,seconds:(performance.now()-start)/1000});save();fs.appendFileSync(progress,JSON.stringify({name,event:'complete',elapsedSeconds:(performance.now()-started)/1000})+'\n');return value;}
  catch(error){fs.appendFileSync(progress,JSON.stringify({name,event:'error',error:String(error),elapsedSeconds:(performance.now()-started)/1000})+'\n');throw error;}
}
try{
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=generator.file;process.env.BEND_BASE=base.file;
  const driver=await import(pathToFileURL(path.join(workspace,'selfhost/tools/typed-driver.mjs')));
  const api=await driver.loadApi();
  for(const name of ['specialize_book','driver_emit_owned','book_context','jd_stops','reach_book','annotate_selected','jd_plan_selected','jd_plan_error','jd_plan_defs','jd_plan_library','j_layout_error','jd_foreign_error','jd_foreign_paths','jd_modules'])requireThat(typeof api[name]==='function','Missing public compiler API: '+name);
  let graph=step('load-complete-source',()=>driver.discoverSources(api,source.file));
  requireThat(graph.loadTrace.result.error==='','Frontend refused compiler source: '+graph.loadTrace.result.error);
  for(const file of graph.files){const discovered=pin(file);requireThat(same(discovered,source)||same(discovered,base),'Unrecorded import in checked compiler source: '+file);inputs.push(discovered);}
  let book=graph.loadTrace.result.book;graph=null;
  requireThat(step('remaining-todos',()=>api.driver_todos(book))===0,'Compiler source contains unfilled definitions');
  if(freshCheck){
    const checked=step('fresh-own-source-check',()=>api.check_book_diagnostic(book,list([])));
    requireThat(checked?.$==='DResult'&&checked.error==='','Fresh B2 self-check failed: '+checked?.error);
    report.freshSelfCheck=true;report.typeAccepted=true;
  }
  let specialized=step('specialize',()=>api.specialize_book(book));
  requireThat(api.specialized_error(specialized)==='','Compiler specialization refused');book=api.specialized_book(specialized);specialized=null;
  requireThat(step('ownership',()=>api.driver_emit_owned(book))==='','Compiler ownership refused');
  const definitions=new Set(array(book).filter(d=>d.kind==='Def').map(d=>d.name));
  for(const name of roots)requireThat(definitions.has(name),'Root absent from loaded source: '+name);
  const context=step('context',()=>api.book_context(book)),rootList=list(roots),stops=step('native-stops',()=>api.jd_stops(context));
  book=null;
  let selected=step('source-reachability',()=>api.reach_book(context,rootList,stops));
  let selectedRows=array(selected);
  report.sourceSelection={rows:selectedRows.length,definitions:selectedRows.filter(d=>d.kind==='Def'&&d.templates===0).length,nonAbsentDefinitions:selectedRows.filter(d=>d.kind==='Def'&&d.templates===0&&d.value.tag!=='Absent').length};selectedRows=null;save();
  if(typeof globalThis.Bun?.gc==='function')step('release-host-references',()=>globalThis.Bun.gc(true));
  selected=step('annotate-selected',()=>api.annotate_selected(context,selected,stops));
  const plan=step('emitted-reachability',()=>api.jd_plan_selected(context,selected,rootList));
  requireThat(api.jd_plan_error(plan)==='','Direct plan refused: '+api.jd_plan_error(plan));selected=api.jd_plan_defs(plan);
  report.selectedDefinitions=array(selected).length;
  requireThat(step('layout',()=>api.j_layout_error(context,selected,rootList,stops))==='','Library layout refused');
  requireThat(api.jd_foreign_error(selected)===''&&array(api.jd_foreign_paths(selected)).length===0,'Self-emitted API has foreign provider dependencies');
  const emitted=step('public-library-emission',()=>api.jd_plan_library(plan));
  requireThat(typeof emitted==='string'&&!emitted.includes('\n/*JD_UNSUPPORTED:'),'Direct library emission refused');
  const modules=step('foreign-modules',()=>api.jd_modules(selected,list([])));
  const code=fs.readFileSync(directRuntime.file,'utf8')+'\n'+modules+'\n'+emitted;
  requireThat(Buffer.byteLength(code)>0&&Buffer.byteLength(code)<=128*1024**2,'Self-emitted API exceeds bounded output');
  const imageFile=path.join(out,'api.mjs');fs.writeFileSync(imageFile,code,{flag:'wx'});report.image=pin(imageFile);
  if(args.compare){report.reference=pin(args.compare);report.byteEquality=fs.readFileSync(args.compare).equals(fs.readFileSync(imageFile));requireThat(report.byteEquality,'Self-emitted bytes differ from the reference');}
  inputs.forEach(verify);report.complete=true;
  report.imageBinding={kind:'bend-build-image-binding',version:1,complete:true,host:'js',stage,image:report.image,sourceIdentity:source,checked:true,protocol:rootsDoc.protocol,targets:rootsDoc.targets,preparationModes:rootsDoc.preparationModes,exports:roots,
    scope:'Actual Bend-produced JS image; checking belongs to the exact source. Driver/behavioral qualification and installation are separate.'};
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.seconds=(performance.now()-started)/1000;report.progress=pin(progress);save();console.log(JSON.stringify({complete:report.complete,stage,image:report.image,freshSelfCheck:report.freshSelfCheck,byteEquality:report.byteEquality,error:report.error,report:path.join(out,'report.json')}));
