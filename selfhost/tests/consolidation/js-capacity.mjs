#!/usr/bin/env node
// Boundary controls call the public compiled Bend API. This file constructs
// independent copies of one checked closed literal; it implements no compiler.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';

const requireThat=(test,message)=>{if(!test)throw Error(message);};
const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file);return {file,bytes:bytes.length,sha256:hash(bytes)};};
const verify=row=>{const actual=pin(row.file);requireThat(actual.bytes===row.bytes&&actual.sha256===row.sha256,'Changed input: '+row.file);return actual;};
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const out=[];while(xs?.$==='Con'){requireThat(out.length<100000,'List capacity exceeded');out.push(xs.head);xs=xs.tail;}requireThat(xs?.$==='Nil','Malformed list');return out;}
const args={};
for(let i=2;i<process.argv.length;i+=2){const key=process.argv[i].slice(2);requireThat(process.argv[i].startsWith('--')&&process.argv[i+1]&&['baseline','candidate','out'].includes(key)&&!args[key],'Expected unique --baseline/--candidate/--out value');args[key]=process.argv[i+1];}
for(const key of ['baseline','candidate','out'])requireThat(args[key],'Missing --'+key);
const out=path.resolve(args.out);requireThat(!fs.existsSync(out),'Fresh output directory required');fs.mkdirSync(out,{recursive:true});
const report={kind:'bend-js-definition-capacity-controls',version:2,complete:false,inputs:[pin(fileURLToPath(import.meta.url)),pin(process.execPath)],runs:[],controls:[],
  scope:'Finite public-API controls for a resource bound. One tiny literal template is parsed and checked once per producer; every synthetic KDef changes only its independent closed declaration name. Cases8/4096 include layout and complete library rendering for byte comparison;4100/4352/4353 measure planner admission/refusal only. No full compiler source is checked here, no generated products execute, and this is not a correctness theorem.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const started=performance.now();save();
async function producer(label,authorityFile,budget){
  const authorityPin=pin(authorityFile),authority=JSON.parse(fs.readFileSync(authorityPin.file,'utf8'));
  requireThat(authority.kind==='bend-checked-hosted-api'&&authority.complete&&authority.checked,'Require independently checked B1 authority');
  const image=verify(authority.api),source=verify(authority.source);
  const bases=(authority.inputs??[]).filter(p=>p.file.endsWith('/bend2/base.bend'));
  requireThat(bases.length===1,'Unique pinned Base required');const base=verify(bases[0]);
  report.inputs.push(authorityPin,image,source,base);
  const module=await import(pathToFileURL(image.file));requireThat(!module.G,'These controls require the named-field checked B1 ABI');const api=module.default;
  for(const name of ['f_load_graph','check_book_diagnostic','book_context','jd_stops','annotate_selected','jd_plan_selected','jd_plan_error','jd_plan_defs','jd_plan_library','j_layout_error','driver_emit_owned'])requireThat(typeof api[name]==='function','Missing public API: '+name);
  const start=performance.now(),templateName='capacity_template';
  const loaded=api.f_load_graph('__capacity__',list([
    {$:'FSource',name:'__capacity__',path:'__capacity__',text:'import Base\n\ndef capacity_template() -> U32:\n  0\n'},
    {$:'FSource',name:'Base',path:base.file,text:fs.readFileSync(base.file,'utf8')}
  ]));
  requireThat(loaded?.$==='FResult'&&loaded.error==='','Template parse failed: '+loaded?.error);
  const checked=api.check_book_diagnostic(loaded.book,list([]));
  requireThat(checked?.$==='DResult'&&checked.error==='','Template check failed: '+checked?.error);
  requireThat(api.driver_emit_owned(loaded.book)==='','Template ownership refused');
  const rows=array(loaded.book),templates=rows.filter(d=>d.name===templateName);
  requireThat(templates.length===1,'Unique template declaration required');const template=templates[0];
  requireThat(template.$==='KDef'&&template.kind==='Def'&&template.arity===0&&template.templates===0&&template.native===false&&template.unsafe===false,'Unexpected template declaration');
  requireThat(template.value?.$==='KLiteral'&&template.value.kind==='U32'&&template.value.number===0&&template.value.text==='','Template must be a closed literal, not a function/reference');
  requireThat(template.typ?.$==='KTerm'&&template.typ.tag==='Ref'&&template.typ.name==='U32'&&template.typ.kids?.$==='Nil'&&template.ctors?.$==='Nil','Unexpected template type/constructors');
  const baseRows=rows.filter(d=>d!==template),run={label,budget,image,source,base,template:{checked:true,owned:true,body:'U32 literal 0',renamedField:'name',seconds:(performance.now()-start)/1000},cases:[]};
  report.runs.push(run);save();
  const products=new Map();
  for(const count of [8,4096,4100,4352,4353]){
    const begin=performance.now();
    const row={count,expectedAccepted:count<=budget,scope:[8,4096].includes(count)?'plan-layout-library':'plan-admission',stage:'construct'};run.cases.push(row);save();
    const defs=Array.from({length:count},(_,i)=>({...template,name:'capacity_'+i}));
    requireThat(defs.every(d=>d.typ===template.typ&&d.value===template.value),'Changed literal declaration payload');
    const context=api.book_context(list([...baseRows,...defs])),roots=list(defs.map(d=>d.name)),stops=api.jd_stops(context);
    const selected=api.annotate_selected(context,list(defs),stops);
    requireThat(array(selected).length===count,'Annotation changed synthetic declaration count');
    row.stage='plan';save();
    const plan=api.jd_plan_selected(context,selected,roots),error=api.jd_plan_error(plan),accepted=error==='';
    Object.assign(row,{accepted,error});save();
    requireThat(accepted===row.expectedAccepted,label+' unexpected admission at '+count+': '+error);
    if(accepted){
      const planned=api.jd_plan_defs(plan);row.selectedDefinitions=array(planned).length;
      requireThat(row.selectedDefinitions===count,'Unexpected emitted dependency count');
      if(row.scope==='plan-layout-library'){
        row.stage='layout';save();
        requireThat(api.j_layout_error(context,planned,roots,stops)==='','Synthetic layout refused');
        row.stage='library';save();
        const code=api.jd_plan_library(plan);requireThat(typeof code==='string'&&!code.includes('\n/*JD_UNSUPPORTED:'),'Synthetic emission refused');
        const file=path.join(out,label+'-'+count+'.mjs');fs.writeFileSync(file,code,{flag:'wx'});row.product=pin(file);products.set(count,{bytes:Buffer.from(code),pin:row.product});
      }
    }else requireThat(error==='direct reachability tail-call analysis refused','Unexpected bound refusal: '+error);
    row.stage='complete';row.seconds=(performance.now()-begin)/1000;save();
  }
  const context=api.book_context(loaded.book),stops=api.jd_stops(context),selected=api.annotate_selected(context,list([template]),stops);
  const missing=api.jd_plan_error(api.jd_plan_selected(context,selected,list(['capacity_missing'])));
  requireThat(missing==='direct reachability missing emitted definition','Unexpected invalid-root result: '+missing);
  run.invalidMissingRoot=missing;save();return {products,base,missing};
}
try{
  const baseline=await producer('baseline',args.baseline,4096),candidate=await producer('candidate',args.candidate,4352);
  requireThat(baseline.base.sha256===candidate.base.sha256,'Different Base inputs');
  for(const count of [8,4096]){const left=baseline.products.get(count),right=candidate.products.get(count);requireThat(left.bytes.equals(right.bytes),'Admitted product changed at '+count);report.controls.push({name:'byte-identical-under-old-limit',count,baseline:left.pin,candidate:right.pin,passed:true});}
  requireThat(baseline.missing===candidate.missing,'Invalid-root refusal changed');
  report.controls.push({name:'same-invalid-root-refusal',diagnostic:candidate.missing,passed:true});
  report.controls.push({name:'4096-4100-4352-4353-resource-boundaries',passed:true});
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.seconds=(performance.now()-started)/1000;save();console.log(JSON.stringify({complete:report.complete,seconds:report.seconds,error:report.error,report:path.join(out,'report.json')}));
