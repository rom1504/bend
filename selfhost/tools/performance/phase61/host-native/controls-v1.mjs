// Diagnostic host-wrapper retention. Root owns one outer bounded supervisor.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';import {verifyAttempt} from '../../../development/workflow.mjs';
const [beforeArg,afterArg,outArg]=process.argv.slice(2);assert(beforeArg&&afterArg&&outArg);const out=path.resolve(outArg);const root=path.resolve(import.meta.dirname,'../../../../..');assert(out.startsWith(path.join(root,'selfhost/build/phase61')+path.sep));assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))}),inputs=new Map();function pin(file,want){const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(x,inputs.get(x.file));inputs.set(x.file,x);return x;}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'}),nil=()=>list([]),term=(tag,name='',children=[],quant=0,id=0)=>({$:'KTerm',tag,name,id,quant,kids:list(children),removed:nil(),originBegin:0,originEnd:0}),atom=()=>term('Absent'),adt=(name,args=[])=>term('ADT',name,args),all=(a,b,q=1,name='x',id=0)=>term('All',name,[a,b],q,id),def=(name,typ,arity=0,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity,templates:0,typ,value:atom(),ctors:list(ctors),native:false,unsafe:false});
const report={kind:'phase61-native-host-type-facts-controls',complete:false,pass:false,roles:{},rows:[],proofCases:[],inputs:[],scope:'Actual checked old/new private helpers and checked Base. Exact supported host wrapper bytes/events plus classifier proof refusals. Internal optimized graph visits may admit former budget refusals; the public old classifier stays exact. No clean speed or source-conformance claim from synthetic type graphs.'};const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
const digest=x=>hash(Buffer.from(JSON.stringify(x)));try{
 pin(import.meta.filename);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);pin(process.execPath);const parent=pin(new URL('../../phase55/semantic-host-controls-v1.mjs',import.meta.url).pathname);assert.equal(parent.sha256,'fbdfead8e33b2e7a81f1512a5f470647513ff48771706dfd39a005f81ebca36a');report.parent=parent;const roles={};
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 for(const [role,arg] of [['baseline',beforeArg],['candidate',afterArg]]){
  const attempt=pin(path.join(arg,'attempt.json')),m=await verifyAttempt(path.resolve(arg));assert(m.checked);for(const k of ['api','runtime','base','node','bootstrapReport'])pin(m[k].file,m[k]);assert.equal(identity(process.execPath).sha256,m.node.sha256);const vp=pin(path.join(arg,'validation-001/report.json')),v=JSON.parse(fs.readFileSync(vp.file));assert(v.complete&&v.pass&&v.selected.selectedComplete);assert.equal(v.selected.exactDifferences,0);assert.equal(v.selected.discrepancies,0);assert.equal(v.attempt.sha256,attempt.sha256);assert.equal(v.api.sha256,m.api.sha256);pin(path.join(m.snapshot.root,'src/back/js/direct/host.bend'));if(role==='candidate')pin(path.join(m.snapshot.root,'src/back/js/direct/host-native.bend'));
  const original=fs.readFileSync(m.api.file,'utf8'),ast=parse(original);for(const name of ['run_loop','nat_host','$jd_host$','$jd_host_nat_status$','$jd_marshal$','$jd_name$'])assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);assert(!original.includes('phase55HostProbe'));
  if(role==='candidate')for(const name of ['$jd_host_native_context$','$jd_host_nat_known$','$jd_host_native_leaf$','$lookup$','$da$'])assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
  const suffix='\nexport const phase55HostProbe={host:(book,d)=>run_loop($jd_host$(book,d)),status:(book,ty)=>run_loop($jd_host_nat_status$(book,{$:"Con",head:ty,tail:{$:"Nil"}},{$:"Nil"},1024)),marshal:(book,ty,out)=>run_loop($jd_marshal$(book,ty,out)),name:n=>run_loop($jd_name$(n)),run:run_loop,nat:nat_host'+(role==='candidate'?',prepare:b=>run_loop($jd_host_native_context$(b)),known:(b,t)=>run_loop($jd_host_nat_known$(b,t)),flags:b=>run_loop($da$(run_loop($lookup$(b,"$JD.Host.NativeWord")))),leaf:(t,f)=>run_loop($jd_host_native_leaf$(t,f))':',prepare:b=>b')+'};\n';assert.equal((original+suffix).slice(0,-suffix.length),original);parse(original+suffix);const file=path.join(out,role+'-diagnostic-api.mjs');fs.writeFileSync(file,original+suffix,{flag:'wx'});pin(file);const mod=await import(pathToFileURL(file));assert(!mod.G,'Named-field B1 transport required');const api=mod.default;
  const text=fs.readFileSync(m.base.file,'utf8'),source=api.f_source_located({$:'FSource',name:'Base',path:m.base.file,text},1,text.length+2),loaded=api.f_load_graph('Base',list([source]));assert.equal(loaded.error,'');assert.equal(api.compiler_check_result_abi(),2);const checked=api.check_program_diagnostic(loaded.book,nil(),nil());assert.equal(checked.error,'');
  roles[role]={api,probe:mod.phase55HostProbe,base:checked.book};report.roles[role]={attempt,api:m.api,base:m.base,runtime:m.runtime,derivative:identity(file),suffixSha256:hash(suffix),parserSourceSha256:hash(parserSource),checkedBase:digest(checked.book),productionAbiChanged:false};save();
 }
 assert.equal(report.roles.baseline.checkedBase,report.roles.candidate.checkedBase);
 const U=adt('U32'),N=adt('Nat'),AN=adt('Array',[N]);
 const recursive=def('P55Tree',term('Typ','',[term('Qua','',[],0)]),0,'ADT',[def('P55Nil',adt('P55Tree'),0,'Ctr'),def('P55Next',all(adt('P55Tree'),all(U,adt('P55Tree'))),2,'Ctr')]);
 const wide=name=>{let tel=adt(name);for(let i=259;i>=0;i--)tel=all(U,tel,1,'f'+i,i+1);return def(name,term('Typ','',[term('Qua','',[],0)]),0,'ADT',[def(name+'Ctor',tel,260,'Ctr')]);};
 const cases=[
  {id:'plain-u32',ty:all(U,U),arity:1,status:0,args:()=>[4],impl:(events,x)=>{events.push('body');return x+2;},expected:6,events:['body']},
  {id:'nat-only-result',ty:all(U,N),arity:1,status:1,args:()=>[4],impl:(events)=>{events.push('body');return 9;},expected:9n,events:['body']},
  {id:'nat-only-callback',ty:all(all(U,N),U),arity:1,status:1,args:events=>[x=>{events.push('callback:'+x);return 9n;}],impl:(events,f)=>{events.push('body');return Number(f(4));},expected:9,events:['body','callback:4']},
  {id:'array-nat-input',ty:all(AN,U),arity:1,status:1,args:events=>{const a=[2n,3n];Object.defineProperty(a,'forEach',{get(){events.push('forEach');return Array.prototype.forEach;}});return[a];},impl:(events,a)=>{events.push('body');return Number(a[0]+a[1]);},expected:5,events:['forEach','body','forEach']},
  {id:'nat-only-constructor-field',ty:all(adt('P55Box'),U),arity:1,status:1,extra:[def('P55Box',term('Typ','',[term('Qua','',[],0)]),0,'ADT',[def('P55BoxCtor',all(N,adt('P55Box'),1,'payload'),1,'Ctr')])],args:()=>[{$:'P55BoxCtor',payload:9n}],impl:(events,b)=>{events.push('body');return Number(b.payload);},expected:9,events:['body']},
  {id:'erased-nat-formal',ty:all(N,all(U,U),0,'erased'),arity:2,status:0,args:()=>[4],impl:(events,x)=>{events.push('body');return x+2;},expected:6,events:['body']},
  {id:'recursive-no-nat',ty:all(adt('P55Tree'),U),arity:1,status:0,extra:[recursive],args:events=>[{get next(){events.push('forbidden');throw Error('Unexpected recursive input inspection');}}],impl:(events)=>{events.push('body');return 7;},expected:7,events:['body']},
  {id:'combined-budget-fallback',ty:all(adt('P55WideA'),all(adt('P55WideB'),U)),arity:2,status:2,extra:[wide('P55WideA'),wide('P55WideB')],components:[adt('P55WideA'),adt('P55WideB'),U],args:()=>[{},{}],impl:(events)=>{events.push('body');return 11;},expected:11,events:['body']},
 ];
 for(const [i,spec] of cases.entries()){
  const row={id:spec.id,expectedStatus:spec.status,roles:{},pass:false};report.rows.push(row);
  for(const [role,R] of Object.entries(roles)){
   const extra=spec.extra??[],book=R.api.book_context(list([...extra,...(()=>{const a=[];let xs=R.base;while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;})()])),d=def('p55_probe_'+i,spec.ty,spec.arity),before=digest({book,d});
   const status=R.probe.status(book,spec.ty);assert.equal(status,spec.status);const componentStatus=(spec.components??[]).map(ty=>R.probe.status(book,ty));if(spec.components)assert.deepEqual(componentStatus,[0,0,0]);const prepared=R.probe.prepare(book);const fastStatus=role==='candidate'?R.probe.known(prepared,spec.ty):status;assert.equal(fastStatus,spec.status);if(role==='candidate')assert.equal(R.probe.flags(prepared),3);const wrapper=R.probe.host(prepared,d);assert(!wrapper.includes('JD_UNSUPPORTED'),'No diagnostic case may become host rejection');
   const wrapperFile=path.join(out,role+'-'+spec.id+'.js');fs.writeFileSync(wrapperFile,wrapper,{flag:'wx'});pin(wrapperFile);const events=[],args=spec.args(events),call=new Function('run_loop','nat_host',R.probe.name(d.name),'return ('+wrapper+');')(R.probe.run,R.probe.nat,(...xs)=>spec.impl(events,...xs));const value=call(...args);assert.deepEqual(value,spec.expected);assert.deepEqual(events,spec.events);assert.equal(digest({book,d}),before,'Diagnostic type graph mutated');
   row.roles[role]={status,fastStatus,componentStatus,wrapper:identity(wrapperFile),wrapperBytes:Buffer.byteLength(wrapper),value:typeof value==='bigint'?{bigint:value.toString()}:value,events,typeGraphUnchanged:true};row.roles[role].wrapperSource=wrapper;save();
  }
  const b=row.roles.baseline,c=row.roles.candidate;assert.equal(c.wrapperSource,b.wrapperSource,'Exact host wrapper changed');assert.equal(c.wrapper.sha256,b.wrapper.sha256);assert.deepEqual({value:c.value,events:c.events},{value:b.value,events:b.events});row.pass=true;save();
 }

 const C=roles.candidate,B=roles.baseline;
 function rawBase(R){const xs=[];let x=R.base;while(x.$==='Con'){if(x.head.kind!=='BookCache')xs.push(x.head);x=x.tail;}assert.equal(x.$,'Nil');return xs;}
 const makeBook=(R,extra,remove=[])=>R.api.book_context(list([...extra,...rawBase(R).filter(d=>!remove.includes(d.name))]));
 const native=(d)=>({...d,native:true});
 const fake=(name,field,kind='ADT',isNative=true,arity=0)=>({...def(name,term('Typ','',[term('Qua','',[],0)]),arity,kind,[native(def(name+'Ctor',all(field,adt(name)),1,'Ctr'))]),native:isNative});
 const proofCases=[
  {id:'native-with-Nat-refuses',extra:[fake('U32',N)],remove:['U32'],ty:U,status:1,flags:2},
  {id:'nonnative-U32-refuses',extra:[fake('U32',N,'ADT',false)],remove:['U32'],ty:U,status:1,flags:2},
  {id:'wrong-owner-kind-refuses',extra:[fake('U32',N,'Def')],remove:['U32'],ty:U,status:1,flags:2},
  {id:'parameterized-owner-refuses',extra:[fake('U32',N,'ADT',true,1)],remove:['U32'],ty:U,status:1,flags:2},
  {id:'missing-owner-refuses',extra:[],remove:['U32'],ty:U,status:0,flags:2},
  {id:'failed-preparation-overwrites-forged-fact',extra:[fake('U32',N),fake('F32',N),def('$JD.Host.NativeWord',atom(),3,'JDHostNativeWord')],remove:['U32','F32'],ty:U,status:1,flags:0},
 ];
 // A wide list of repeated constructor return types exhausts the old proof
 // without expensive dependent telescopes or any hidden Nat occurrence.
 const unknown=native(def('U32',term('Typ','',[term('Qua','',[],0)]),0,'ADT',Array.from({length:1030},(_,i)=>native(def('Budget'+i,U,0,'Ctr')))));
 proofCases.push({id:'budget-unknown-native-proof-refuses',extra:[unknown],remove:['U32'],ty:U,status:2,flags:2});
 for(const spec of proofCases){
  const observed={};for(const [role,R]of Object.entries(roles)){
   const book=makeBook(R,spec.extra,spec.remove),before=digest(book),old=R.probe.status(book,spec.ty),prepared=R.probe.prepare(book);
   assert.equal(old,spec.status,spec.id);const actual=role==='candidate'?R.probe.known(prepared,spec.ty):old;
   assert.equal(actual,old,spec.id);if(role==='candidate')assert.equal(R.probe.flags(prepared),spec.flags,spec.id);
   assert.equal(digest(book),before,spec.id+' mutated input');observed[role]={old,actual,flags:role==='candidate'?R.probe.flags(prepared):null};
  }report.proofCases.push({id:spec.id,observed,pass:true});save();
 }
 const prepared=C.probe.prepare(C.base);assert.equal(C.probe.flags(prepared),3);assert.equal(C.probe.leaf(adt('U32',[N]),3),false);assert.equal(C.probe.leaf(adt('F32',[N]),3),false);
 report.proofCases.push({id:'nonempty-actual-type-arguments-refuse-leaf',pass:true});
 const long=wide('P61BudgetBoundary');let tel=adt(long.name);for(let i=499;i>=0;i--)tel=all(U,tel,1,'f'+i,i+1);long.ctors=list([def(long.name+'Ctor',tel,500,'Ctr')]);
 const bbook=makeBook(B,[long]),cbook=makeBook(C,[long]),ty=adt(long.name),old=B.probe.status(bbook,ty),publicNew=C.probe.status(cbook,ty),fast=C.probe.known(C.probe.prepare(cbook),ty);
 assert.equal(old,2);assert.equal(publicNew,old);assert.equal(fast,0);report.proofCases.push({id:'internal-budget-admission-expands-public-scanner-exact',old,publicNew,fast,pass:true});
 // The optimized traversal itself is still finite: native leaves still cost visits.
 let over=U;for(let i=0;i<513;i++)over=all(U,over,1,'f'+i,i+1);
 assert.equal(C.probe.known(prepared,over),2);report.proofCases.push({id:'optimized-budget-still-refuses-over1024-visits',pass:true});save();

 report.counts={proofCases:report.proofCases.length,cases:report.rows.length,exactWrapperMatches:report.rows.filter(r=>r.pass).length,combinedBudgetFallback:1,natPositive:4};for(const a of [beforeArg,afterArg])await verifyAttempt(path.resolve(a));for(const r of inputs.values())assert.deepEqual(identity(r.file),r);report.complete=true;report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,counts:report.counts,error:report.error}));
