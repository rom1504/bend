// Independent full-value comparisons and bounded observations. Compiler work
// executes in the checked Bend APIs; this file does no parsing or lowering.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const args={};
for(let i=2;i<process.argv.length;i+=2){need(process.argv[i]?.startsWith('--')&&process.argv[i+1],'--key value');const k=process.argv[i].slice(2);need(!Object.hasOwn(args,k),'duplicate argument');args[k]=process.argv[i+1];}
need(['baseline','candidate','binding','out'].every(k=>args[k]),'baseline/candidate/binding/out required');
need(Object.keys(args).every(k=>['baseline','candidate','binding','out','kind','modes','case-prefix'].includes(k)),'unknown argument');
const kind=args.kind??'parser';
need(['parser','semantic','stages','publication','report'].includes(kind),'kind must be parser, semantic, stages, publication or report');
const allModes=['parse','check','context','annotation','request'];
const modes=args.modes===undefined?allModes:args.modes.split(',');
need(modes.length>0&&new Set(modes).size===modes.length&&modes.every(mode=>allModes.includes(mode)),'modes must be a nonempty comma-separated list of distinct parse,check,context,annotation,request');
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const out=path.resolve(args.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const receipts={baseline:read(args.baseline),candidate:read(args.candidate)},binding=read(args.binding);
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.baseline),pin(args.candidate),pin(args.binding),binding.base,binding.carrier];
for(const r of Object.values(receipts)){need(r.complete&&r.checked&&r.kind==='bend-checked-hosted-api','checked API');inputs.push(r.api,r.source,...r.inputs);}
const report={kind:'phase175-complete-frontend-comparison',complete:false,inputs,rows:[],comparisonKind:kind,requestedModes:modes,checkedModes:[],ordinaryReference:{requested:modes.includes('request'),exported:null,checkedCases:0,status:'pending'},scope:'Complete finite frontend values and diagnostics, independently checked unchanged Bend oracle; no native timing or compiler correctness theorem.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();save();
function exact(a,b){
  const pending=[[a,b]],seen=new WeakMap();let pairs=0;
  while(pending.length){need(++pairs<=20000000,'value comparison bound');const [x,y]=pending.pop();if(Object.is(x,y))continue;
    need(typeof x===typeof y&&x!==null&&y!==null&&typeof x==='object','different scalar value: '+String(x)+' / '+String(y));
    let ys=seen.get(x);if(ys?.has(y))continue;if(!ys){ys=new WeakSet();seen.set(x,ys);}ys.add(y);
    const k=Object.keys(x).sort(),l=Object.keys(y).sort();need(k.length===l.length&&k.every((v,i)=>v===l[i]),'different constructor fields');
    for(const key of k)pending.push([x[key],y[key]]);
  }return pairs;
}
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
function listRows(xs){const out=[];while(xs?.$==='Con'){need(out.length<100000,'list bound');out.push(xs.head);xs=xs.tail;}need(xs?.$==='Nil','list shape');return out;}
function publicationPair(row,label){
  need(row?.$==='P175PDObservation',label+': publication observation required');
  const pairs=exact(row.baseline,row.candidate)+exact(row.baselineFamilies,row.candidateFamilies)+exact(row.baselineConstructors,row.candidateConstructors);
  return {name:label,pairs,exact:true};
}
function expectedStage(value,mode,success,name,failureStage='check'){
  if(success)need(mode==='request'?value?.$==='P175FRequest':value?.$==='P175FBook'&&value.stage==='check',name+': expected successful '+mode);
  else need(value?.$==='P175FError'&&typeof value.error==='string'&&value.error.startsWith(failureStage+': '),name+': expected a '+failureStage+' failure');
}
try{
  inputs.forEach(verify);const api={};for(const [k,r]of Object.entries(receipts))api[k]=(await import(pathToFileURL(r.api.file))).default;
  for(const k of ['baseline','candidate'])for(const name of ['p88_cache_prepare','p175fp_plan'])need(typeof api[k][name]==='function',k+' must export '+name);
  need(typeof api.baseline.p175fd_value==='function','baseline must export p175fd_value');
  const hasReference=typeof api.baseline.p175fp_reference==='function';
  report.ordinaryReference.exported=hasReference;
  report.ordinaryReference.status=!modes.includes('request')?'not-requested':hasReference?'pending':'not-exported';
  report.ordinaryReference.scope=hasReference?'Unchanged baseline p86_plan wiring checked only for requested request mode.':'No baseline reference export: comparisons are against the authenticated baseline staged API only.';
  if(kind==='parser'){
    const values={};
    for(const name of ['p175p_prec_observe','p175p_parser_observe','p175p_growth_boundaries']){
      const left=api.baseline[name](),right=api.candidate[name]();report.rows.push({name,pairs:exact(left,right),count:listRows(left).length,exact:true});values[name]=left;
    }
    const file=path.join(out,'parser-values.json');fs.writeFileSync(file,JSON.stringify(values)+'\n');report.parserValues=pin(file);
    const alphabet=[...'=->&|<+.^*/%op'],words=[''];let previous=[''];
    for(let n=1;n<=4;n++){const next=[];for(const s of previous)for(const c of alphabet)next.push(s+c);words.push(...next);previous=next;}
    words.push('λ','🙂','a','word','long-name','>>opx','\0','<\0','\n');
    const hash=crypto.createHash('sha256');let pairs=0;
    for(let i=0;i<words.length;i+=256){const chunk=words.slice(i,i+256),left=api.baseline.p175p_prec_values(list(chunk)),right=api.candidate.p175p_prec_values(list(chunk));pairs+=exact(left,right);hash.update(JSON.stringify([chunk,listRows(left)]));}
    report.rows.push({name:'operator-alphabet-up-to-four-codepoints',count:words.length,pairs,exact:true,observationsSha256:hash.digest('hex')});
  }else if(kind==='semantic'){
    const values=api.candidate.p175sf_controls();const rows=listRows(values);need(rows.length===18&&rows.every(x=>typeof x==='string'&&x.endsWith(':pass')),'semantic finite control');
    const file=path.join(out,'semantic-values.json');fs.writeFileSync(file,JSON.stringify(api.candidate.p175sf_values())+'\n');report.semanticValues=pin(file);report.rows.push({name:'semantic-controls',count:rows.length,values:rows,exact:true});
  }else if(kind==='publication'){
    need(modes.some(mode=>mode==='check'||mode==='request'),'publication requires check or request mode to validate large-source outcomes');
    const controls={};
    for(const side of ['baseline','candidate']){
      for(const name of ['p175pd_controls','p175pd_check_observe','p175pd_large_check_observe','p175pd_stale_adt','p175pa_plan'])need(typeof api[side][name]==='function',side+' must export '+name);
      controls[side]=api[side].p175pd_controls();
      const groups=listRows(controls[side]);need(groups.length===6,'six publication control groups required');
      const observations=[];
      for(let i=0;i<groups.length;i++)for(const [j,row]of listRows(groups[i]).entries())observations.push(publicationPair(row,side+':group'+i+':step'+j));
      need(observations.length===45,'45 complete publication observations required');
      report.rows.push({name:side+'-publication-pairs',count:observations.length,observations,exact:true});
      const stale=api[side].p175pd_stale_adt();publicationPair(stale,side+':stale-ADT');
      for(const field of ['baselineConstructors','candidateConstructors'])exact(stale[field],list([false,true]));
      for(const field of ['baselineFamilies','candidateFamilies'])exact(stale[field],list(['','A']));
      report.rows.push({name:side+'-stale-ADT-literal',constructors:[false,true],families:['','A'],exact:true});
    }
    report.rows.push({name:'publication-controls-between-APIs',pairs:exact(controls.baseline,controls.candidate),exact:true});
    for(const [name,count]of [['p175pd_check_observe',7],['p175pd_large_check_observe',8]]){
      const left=api.baseline[name](),right=api.candidate[name]();need(listRows(left).length===count&&listRows(right).length===count,'complete checker control count');
      report.rows.push({name,count,pairs:exact(left,right),exact:true,scope:'Complete DChecking, including ordered world, index, diagnostics and error results.'});
    }
  }else if(kind==='report'){
    const casesBySide={};
    for(const side of ['baseline','candidate']){
      for(const name of ['p175rn_cases','p175rn_controls'])need(typeof api[side][name]==='function',side+' must export '+name);
      casesBySide[side]=api[side].p175rn_cases();const cases=listRows(casesBySide[side]);need(cases.length===15,'15 report-name cases required');
      need(new Set(cases.map(row=>row.name)).size===15,'unique report-name cases required');
      const rows=cases.map(row=>{need(row?.$==='P175RNCase'&&typeof row.name==='string','report-name case shape');return {name:row.name,pairs:exact(row.expected,row.original)+exact(row.expected,row.candidate),expected:listRows(row.expected),exact:true};});
      const labels=listRows(api[side].p175rn_controls());exact(labels,cases.map(row=>row.name+':pass'));
      report.rows.push({name:side+'-report-name-literal-cases',count:rows.length,cases:rows,controls:labels,exact:true});
    }
    report.rows.push({name:'report-name-cases-between-APIs',pairs:exact(casesBySide.baseline,casesBySide.candidate),exact:true});
  }else {
    report.finiteControlScope='stages mode: parser-specific and semantic-specific control campaigns skipped; full finite stage values and diagnostics still compared';
  }
  const seeds={};for(const k of ['baseline','candidate']){const p=api[k].p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);need(p.$==='P86PreparationReady',p.error??'Base refused');seeds[k]=p.seed;}
  const fixtures=['coverage-map-churn-128','tree-bitonic','test-rle-roundtrip','lexer','editdist','symreg','coverage-closures-64','coverage-record-aggregation-64'];
  const cases=fixtures.map(name=>{const file=path.join(workspace,'selfhost/tools/bench/catalogs/native45/fixtures',name+'.bend');inputs.push(pin(file));return{name,path:file,text:fs.readFileSync(file,'utf8')};});
  if(kind==='semantic')for(const name of ['semantic-field-dependent','semantic-field-rewrite']){
    const file=path.join(workspace,'selfhost/tests/phase175',name+'.bend');inputs.push(pin(file));
    cases.push({name,path:file,text:fs.readFileSync(file,'utf8'),mustReady:true});
  }
  cases.push(...[
    ['empty',''],['missing-base','def main() -> U32:\n  42\n'],['bad-type','import Base\ndef main() -> U32:\n  "bad"\n'],
    ['bad-syntax','import Base\ndef main( -> U32:\n  1\n'],['duplicate','import Base\ndef x() -> U32:\n  1\ndef x() -> U32:\n  2\ndef main() -> U32:\n  x()\n'],
    ['erased-param','import Base\ndef identity(0 T: Type, x: T) -> T:\n  x\ndef main() -> U32:\n  identity(U32,42)\n']
  ].map(([name,text])=>({name,path:path.join(workspace,'selfhost/build/phase175/controls',name+'.bend'),text})));
  if(kind==='publication'){
    const manifestFile=path.join(workspace,'experiments/phase175/parser-publication-cases.json'),manifestPin=pin(manifestFile),manifest=read(manifestFile);inputs.push(manifestPin);
    need(manifest.kind==='phase175-publication-large-source-controls'&&manifest.rows.length===6,'six pinned large publication fixtures required');
    report.largeFixtureManifest=manifestPin;
    for(const fixture of manifest.rows){
      need(typeof fixture.expectedCheckSuccess==='boolean'&&Number.isInteger(fixture.minimumOrdinaryDefinitions)&&fixture.minimumOrdinaryDefinitions>=256,'large fixture outcome/admission contract');
      const file=path.resolve(workspace,fixture.file);need(file.startsWith(workspace+'/selfhost/tests/phase175/'),'publication fixture outside expected directory');
      const identity={file,bytes:fixture.bytes,sha256:fixture.sha256};verify(identity);inputs.push(identity);
      cases.push({name:'publication-'+fixture.name,path:file,text:fs.readFileSync(file,'utf8'),expectedCheckSuccess:fixture.expectedCheckSuccess,minimumOrdinaryDefinitions:fixture.minimumOrdinaryDefinitions,expectedFailureStage:fixture.expectedFailureStage??'check'});
    }
  }
  const selectedCases=args['case-prefix']?cases.filter(c=>c.name.startsWith(args['case-prefix'])):cases;
  need(selectedCases.length>0,'case-prefix selected no cases');
  report.casePrefix=args['case-prefix']??null;report.availableStageCases=cases.length;
  for(const c of selectedCases){
    const row={name:c.name,path:c.path,textSha256:crypto.createHash('sha256').update(c.text).digest('hex'),stages:[]};
    if(Object.hasOwn(c,'expectedCheckSuccess')){
      const admission={};for(const side of ['baseline','candidate']){
        const value=api[side].p175pa_plan('parse',seeds[side],c.path,c.text);
        if(c.expectedFailureStage==='parse')need(value?.$==='P175PAError'&&value.error.startsWith('parse: '),side+' '+c.name+': expected parser rejection');
        else need(value?.$==='P175PAReady'&&Number.isInteger(value.suffixCount)&&Number.isInteger(value.ordinaryCount)&&value.suffixCount>=value.ordinaryCount&&value.ordinaryCount>=c.minimumOrdinaryDefinitions&&value.compact===true,side+' '+c.name+': actual Bend compact-checker suffix admission required');admission[side]=value;
      }
      row.admission={...admission,pairs:exact(admission.baseline,admission.candidate),exact:true,scope:c.expectedFailureStage==='parse'?'Parser-negative fixture; does not exercise compact checking.':'Actual FPrefixLoad suffix plus original p143cg_enough(suffix,256), no host source counting.'};
      row.expectedCheckSuccess=c.expectedCheckSuccess;
    }
    for(const mode of modes){
      let t=performance.now();const left=api.baseline.p175fp_plan(mode,seeds.baseline,c.path,c.text);const baselineSeconds=(performance.now()-t)/1000;
      t=performance.now();const right=api.candidate.p175fp_plan(mode,seeds.candidate,c.path,c.text);const candidateSeconds=(performance.now()-t)/1000;
      if(c.mustReady&&mode==='request')need(left.$==='P175FRequest'&&right.$==='P175FRequest',c.name+' must produce a successful request: '+(left.error??right.error));
      if(Object.hasOwn(c,'expectedCheckSuccess')&&(mode==='check'||mode==='request')){
        expectedStage(left,mode,c.expectedCheckSuccess,'baseline '+c.name,c.expectedFailureStage);expectedStage(right,mode,c.expectedCheckSuccess,'candidate '+c.name,c.expectedFailureStage);
      }
      row.stages.push({mode,pairs:exact(left,right),result:left.$,error:left.error??null,exact:true,baselineSeconds,candidateSeconds,digest:api.baseline.p175fd_value(left)});
      if(mode==='request'&&hasReference){const ordinary=api.baseline.p175fp_reference(seeds.baseline,c.path,c.text);row.ordinaryPairs=exact(left,ordinary);row.ordinaryExact=true;report.ordinaryReference.checkedCases++;}
    }report.rows.push(row);save();
  }
  inputs.forEach(verify);report.checkedModes=[...modes];
  if(modes.includes('request')&&hasReference){need(report.ordinaryReference.checkedCases===selectedCases.length,'ordinary reference campaign incomplete');report.ordinaryReference.status='checked';}
  report.stageCases=selectedCases.length;report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.seconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,checkedModes:report.checkedModes,ordinaryReference:report.ordinaryReference.status,seconds:report.seconds,error:report.error}));}
