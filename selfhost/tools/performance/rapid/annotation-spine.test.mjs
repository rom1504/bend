// Differential correctness gate for the Bend application-spine annotation pass.
// Existing compiler workers are unchanged; only testing exports are appended.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('usage: annotation-spine.test.mjs BASELINE_API CANDIDATE_API NEW_OUTPUT_DIRECTORY');
const baseline=fs.realpathSync(baselineArg),candidate=fs.realpathSync(candidateArg),output=path.resolve(outArg);fs.mkdirSync(output,{recursive:false});
const hash=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex'),digest=x=>createHash('sha256').update(JSON.stringify(x)).digest('hex');
const runtime=path.resolve(path.dirname(baseline),'../src/runtime.mjs'),reviewedSource=new URL('../../../src/check/annotate.bend',import.meta.url),reviewedCore=new URL('../../../src/core/term.bend',import.meta.url);
const files=[import.meta.filename,process.execPath,baseline,candidate,runtime,reviewedSource.pathname,reviewedCore.pathname],identities=Object.fromEntries(files.map(p=>[p,hash(p)]));
const helpers={annotate:4,ka_type:3,core_beta:1,core_force:1,wnf:2,check:5};
async function expose(file,label,counted=false){let source=fs.readFileSync(file,'utf8');const counters=['ka_type','core_beta','wnf','subst','ka_spine','ka_spine_eligible'];if(counted){for(const name of counters){const re=new RegExp('function \\$'+name+'\\$\\([^)]*\\) \\{');source=source.replace(re,m=>m+'annotationCounters['+JSON.stringify(name)+']++;');}source='const annotationCounters='+JSON.stringify(Object.fromEntries(counters.map(n=>[n,0])))+';\n'+source;}for(const name of Object.keys(helpers))assert.equal(source.split('function $'+name+'$(').length,2,'Missing/duplicate '+name);const exports=Object.entries(helpers).map(([name,n])=>JSON.stringify(name)+':run_lib($'+name+'$,'+n+')');if(label.startsWith('candidate')){assert.ok(source.includes('function $ka_spine_eligible$('));exports.push('eligible:run_lib($ka_spine_eligible$,1)');}const copy=path.join(output,label+'.mjs');fs.writeFileSync(copy,source+'\nexport const annotationProbe={'+exports.join(',')+'};\n'+(counted?'export {annotationCounters};\n':'' ));return {...await import(pathToFileURL(copy)),copy,sha256:hash(copy)};}
const old=await expose(baseline,'baseline'),next=await expose(candidate,'candidate');
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),array=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;};
const t=(tag,name='',id=0,quant=0,kids=[],removed=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed)}),qua=q=>t('Qua','',0,q),typ=q=>t('Typ','',0,0,[qua(q)]),v=id=>t('Var','x',id),all=(id,q,a,b)=>t('All','x',id,q,[a,b]),lam=(id,b,q=1)=>t('Lam','x',id,q,[b]),ref=n=>t('Ref',n),app=(f,x)=>t('App','',0,0,[f,x]),ctr=(n,...xs)=>t('Ctr',n,0,0,xs),adt=n=>t('ADT',n),ann=(x,ty)=>t('Ann','',0,0,[x,ty]);
const d=(name,type,value=t('Absent'),arity=0,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity,templates:0,typ:type,value,ctors:list(ctors),native:false,unsafe:false});
const bool=d('B',typ(2),t('Absent'),0,'ADT',[d('Yes',adt('B'),t('Absent'),0,'Ctr'),d('No',adt('B'),t('Absent'),0,'Ctr')]);
const id=d('id',all(1,1,adt('B'),adt('B')),lam(2,v(2)),1),poly=d('poly',all(10,0,typ(1),all(11,1,v(10),v(10))),lam(12,lam(13,v(13))),2),functionAlias=d('Fn',typ(1),all(20,1,adt('B'),adt('B'))),valueAlias=d('alias',id.typ,ref('id'),1);
const env=book=>({$:'KEnv',book:list(book),name:'probe',lhs:ref('probe'),pending:0,quantities:nil,unsafe:false}),ctx=(id,type,q=1)=>t('Bind','f',id,q,[type]);
const report={kind:'phase3-annotation-spine-differential',started:new Date().toISOString(),node:process.version,nodeArgs:process.execArgv,identities,exposure:{baseline:{file:old.copy,sha256:old.sha256},candidate:{file:next.copy,sha256:next.sha256}},scope:'Exact annotated-core and emitted-JS equality against frozen B1. Both kernels check every manual term; source fixtures pass load/check/owned/TODO/specialization before annotation. Testing exports only; compiler worker bodies unchanged. Correctness timings are not benchmarks.',manual:[],sources:[],complete:false};
const save=()=>fs.writeFileSync(path.join(output,'report.json'),JSON.stringify(report,null,2)+'\n');save();
function manual(name,term,type,{book=[bool,id,poly,functionAlias,valueAlias],bindings=[],eligible=null}={}){const e=env(book),context=list(bindings);assert.equal(old.default.check_book(list(book)),'',name+' old book');assert.equal(next.default.check_book(list(book)),'',name+' new book');for(const a of [old,next])assert.equal(a.annotationProbe.check(e,context,term,1,type).error,'',name+' check');const before=old.annotationProbe.annotate(e,context,term,type),after=next.annotationProbe.annotate(e,context,term,type);assert.deepEqual(after,before,name+' exact annotation');const normalized=next.annotationProbe.core_beta(term),chosen=next.annotationProbe.eligible(normalized);if(eligible!==null)assert.equal(chosen,eligible,name+' branch');report.manual.push({name,checked:true,eligible:chosen,inputSha256:digest({book,bindings,term,type}),annotationSha256:digest(before),exact:true});save();}
manual('reference identity',app(ref('id'),ctr('Yes')),adt('B'),{eligible:true});
manual('reference value alias remains opaque to core_beta',app(ref('alias'),ctr('Yes')),adt('B'),{eligible:true});
manual('dependent erased type argument',app(app(ref('poly'),adt('B')),ctr('Yes')),adt('B'),{eligible:true});
manual('dependent partial application',app(ref('poly'),adt('B')),all(11,1,adt('B'),adt('B')),{eligible:true});
manual('variable function head',app(v(30),ctr('Yes')),adt('B'),{bindings:[ctx(30,id.typ)],eligible:true});
manual('variable dependent function head',app(app(v(31),adt('B')),ctr('No')),adt('B'),{bindings:[ctx(31,poly.typ)],eligible:true});
manual('variable function alias type',app(v(32),ctr('Yes')),adt('B'),{bindings:[ctx(32,ref('Fn'))],eligible:true});
manual('annotation on function head fallback',app(ann(ref('id'),ref('Fn')),ctr('Yes')),adt('B'),{eligible:false});
manual('annotation inside function prefix fallback',app(ann(app(ref('poly'),adt('B')),id.typ),ctr('Yes')),adt('B'),{eligible:false});
manual('explicit lambda beta fallback',app(lam(40,v(40)),ctr('Yes')),adt('B'),{eligible:false});
manual('beta reduction exposes reference spine',app(app(lam(41,ref('id')),ctr('No')),ctr('Yes')),adt('B'),{eligible:true});
manual('lambda argument is annotated under domain',app(app(ref('poly'),id.typ),lam(43,v(43))),id.typ,{eligible:true});
manual('outer annotation retained as requested type',ann(app(ref('id'),ctr('Yes')),adt('B')),adt('B'),{eligible:false});
// A value cell can carry a lambda; core_force follows it, core_beta does not.
manual('variable payload is not unfolded by core_beta',app(t('Var','f',45,0,[lam(46,v(46))]),ctr('Yes')),adt('B'),{bindings:[ctx(45,id.typ)],eligible:true});
// Deterministic varying arity/quantities: all supplied arguments must remain
// annotated, including erased ones; dependent type substitution happens once.
for(let n=1;n<=20;n++){let type=adt('B'),body=ctr('Yes');for(let k=n-1;k>=0;k--){type=all(100+k,k%3,adt('B'),type);body=lam(200+k,body,k%3);}const f=d('many',type,body,n),book=[bool,f];let call=ref('many');for(let k=0;k<n;k++)call=app(call,ctr(k%2?'No':'Yes'));manual('arity '+n+' erased/affine/unrestricted',call,adt('B'),{book,eligible:true});}
const reference=app(ref('alias'),ctr('Yes'));report.refUnfoldingWitness={coreBetaPreservesReference:digest(old.annotationProbe.core_beta(reference))===digest(reference),wnfUnfoldsReference:old.annotationProbe.wnf(list([bool,id,valueAlias]),reference).name==='Yes',explanation:'core_beta only reduces syntactic Lam heads. Unlike wnf it has no book argument; Ref heads remain Ref even if their definitions are lambdas.'};assert.equal(report.refUnfoldingWitness.coreBetaPreservesReference,true);assert.equal(report.refUnfoldingWitness.wnfUnfoldsReference,true);
const prefix='type B is Data:\n  Yes{}\n  No{}\n';
const fixtures=[
 ['ref',prefix+'def id(x: B) -> B:\n  x\ndef out() -> B:\n  id(Yes{})\n'],
 ['dependent',prefix+'law poly:\n  for -A: Type\n  for x: A\n  A\ndef poly(A, x):\n  x\ndef out() -> B:\n  poly(B, Yes{})\n'],
 ['higher-order',prefix+'def apply(f: B -> B, x: B) -> B:\n  f(x)\ndef id(x: B) -> B:\n  x\ndef out() -> B:\n  apply(id, Yes{})\n'],
 ['annotated-function',prefix+'def id(x: B) -> B:\n  x\ndef out() -> B:\n  ({id : B -> B})(Yes{})\n'],
 ['local-lambda',prefix+'def out() -> B:\n  f = {x => x : B -> B}\n  f(Yes{})\n'],
];
for(const [name,source] of fixtures){const sourceFile=path.join(output,name+'.bend');fs.writeFileSync(sourceFile,source);const sources=list([{$:'FSource',name:sourceFile,path:sourceFile,text:source}]),books=[old.default.f_load_graph(sourceFile,sources),next.default.f_load_graph(sourceFile,sources)];assert.equal(books[0].error,'',name+' old load');assert.equal(books[1].error,'',name+' new load');assert.deepEqual(books[0].book,books[1].book,name+' exact loaded book');const book=books[0].book;for(const a of [old,next]){assert.equal(a.default.check_book(book),'',name+' check');assert.equal(a.default.driver_owned(book),'',name+' owned');assert.equal(a.default.driver_todos(book),0,name+' TODO');}
 const specialized=old.default.specialize_book(book);assert.equal(old.default.specialized_error(specialized),'');const final=old.default.specialized_book(specialized);assert.equal(old.default.driver_emit_owned(final),'');const before=old.default.annotate_book(final),after=next.default.annotate_book(final);assert.deepEqual(after,before,name+' exact source annotation');const oldCode=old.default.j_library(before),newCode=next.default.j_library(after);assert.equal(newCode,oldCode,name+' exact emitted JS');const emitted=path.join(output,name+'-emitted.mjs');fs.writeFileSync(emitted,fs.readFileSync(runtime,'utf8')+'\n'+newCode);const execution=(await import(pathToFileURL(emitted))).default.out();assert.deepEqual(execution,{$:'Yes',a:[]},name+' generated execution');report.sources.push({name,sourceSha256:hash(sourceFile),definitions:array(final).length,checked:true,annotationSha256:digest(before),emittedSha256:createHash('sha256').update(oldCode).digest('hex'),execution,exact:true});save();}
if(process.argv.includes('--measure')){
 const countedOld=await expose(baseline,'baseline-counted',true),countedNext=await expose(candidate,'candidate-counted',true);report.measurement={scope:'Annotation only, same process, two untimed warmups then three alternating repetitions. Instrumentation is separate from timed workers. Synthetic checked arity scaling is not a whole-compiler benchmark.',rows:[]};
 for(const arity of [8,16,32,64,128]){let type=adt('B'),body=ctr('Yes');for(let k=arity-1;k>=0;k--){type=all(1000+k,k%3,adt('B'),type);body=lam(2000+k,body,k%3);}const book=[bool,d('many',type,body,arity)],e=env(book);let term=ref('many');for(let k=0;k<arity;k++)term=app(term,ctr(k%2?'No':'Yes'));for(const a of [old,next]){assert.equal(a.default.check_book(list(book)),'');assert.equal(a.annotationProbe.check(e,nil,term,1,adt('B')).error,'');}
 const row={arity,counts:{},samples:[]},expected=old.annotationProbe.annotate(e,nil,term,adt('B'));
 for(const [name,a] of [['baseline',countedOld],['candidate',countedNext]]){for(const k of Object.keys(a.annotationCounters))a.annotationCounters[k]=0;assert.deepEqual(a.annotationProbe.annotate(e,nil,term,adt('B')),expected);row.counts[name]={...a.annotationCounters};}
 for(let warm=0;warm<2;warm++)for(const a of [old,next])assert.deepEqual(a.annotationProbe.annotate(e,nil,term,adt('B')),expected);
 for(let rep=0;rep<3;rep++)for(const [name,a] of (rep%2?[['candidate',next],['baseline',old]]:[['baseline',old],['candidate',next]])){const start=performance.now(),result=a.annotationProbe.annotate(e,nil,term,adt('B')),milliseconds=performance.now()-start;assert.deepEqual(result,expected);row.samples.push({variant:name,rep,milliseconds});}
 const median=xs=>xs.sort((a,b)=>a-b)[Math.floor(xs.length/2)];row.medians=Object.fromEntries(['baseline','candidate'].map(n=>[n,median(row.samples.filter(x=>x.variant===n).map(x=>x.milliseconds))]));report.measurement.rows.push(row);save();
 }
}
report.inputsUnchanged=Object.entries(identities).every(([p,h])=>hash(p)===h);assert.equal(report.inputsUnchanged,true);report.complete=true;report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:true,manual:report.manual.length,sources:report.sources.length,refUnfoldingWitness:report.refUnfoldingWitness,report:path.join(output,'report.json')}));
