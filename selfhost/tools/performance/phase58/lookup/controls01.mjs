// Root supplies the external process-tree resource guard. No production API edits.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg,'controls01.mjs BASELINE_ATTEMPT CANDIDATE_ATTEMPT NEW_OUT');
const rawRoot=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../build/phase58'));
const out=path.resolve(outArg);assert(out.startsWith(rawRoot+path.sep));assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});assert(fs.realpathSync(out).startsWith(rawRoot+path.sep));
const identity=f=>({file:fs.realpathSync(f),sha256:createHash('sha256').update(fs.readFileSync(f)).digest('hex')});
const inputs=new Map();function pin(f,want){const row=identity(f);if(want){assert.equal(row.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(fs.statSync(f).size,want.bytes);}if(inputs.has(row.file))assert.deepEqual(row,inputs.get(row.file));inputs.set(row.file,row);return row;}
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<100000);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
const digest=x=>createHash('sha256').update(JSON.stringify(x)).digest('hex');
const term=(tag,name='',id=0,quant=0,kids=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const absent=()=>term('Absent');
const def=(name,kind='Def',ctors=[],typ=absent(),value=absent())=>({$:'KDef',name,kind,arity:0,templates:0,typ,value,ctors:list(ctors),native:false,unsafe:false});
const report={kind:'phase58-checked-lookup-controls',complete:false,pass:false,roles:{},synthetic:[],arms:[],sources:[],copies:[],inputs:[],
 scope:'Private instrumented checked B1 query images, exact global first-match controls and actual accepted/annotated source arm types. Owner shortcut assumes checked constructor uniqueness. Synthetic duplicate-owner books test only global search; rejected duplicate source tests admission. Counts are diagnostic, not timings or object-identity ABI claims.'};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
function copy(f,t){const before=pin(f);fs.mkdirSync(path.dirname(t),{recursive:true});fs.copyFileSync(f,t,fs.constants.COPYFILE_EXCL);const after=pin(t);assert.equal(after.sha256,before.sha256);report.copies.push({before,after});}
function files(d){return fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{assert(!e.isSymbolicLink());const f=path.join(d,e.name);return e.isDirectory()?files(f):[f];});}
function env(R){for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];process.env.BEND_TYPED_API=R.m.api.file;process.env.BEND_TYPED_RUNTIME=path.join(R.project,'src/runtime.mjs');process.env.BEND_BASE=R.m.base.file;}
try{
 pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
 const catalogFile=pin(path.join(import.meta.dirname,'catalog01.json'));const catalog=JSON.parse(fs.readFileSync(catalogFile.file));assert.equal(catalog.kind,'phase58-lookup-source-catalog');
 const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],P={exports:{}};new Function('module','exports',parserText)(P,P.exports);
 const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});report.parser={version:P.exports.version,sha256:createHash('sha256').update(parserText).digest('hex')};
 const roles={};
 for(const [role,arg] of [['baseline',baselineArg],['candidate',candidateArg]]){
  const directory=fs.realpathSync(arg),attempt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);assert(m.checked&&m.config.strictExact);
  for(const k of ['api','runtime','base','node'])pin(m[k].file,m[k]);
  const query=pin(path.join(m.snapshot.root,'src/back/common/queries.bend'));
  const allowed=role==='baseline'?[catalog.sourceVariants.baseline.sha256]:catalog.sourceVariants.variants.map(x=>x.sha256);assert(allowed.includes(query.sha256),'Unexpected query source variant');
  const original=fs.readFileSync(m.api.file,'utf8'),ast=parse(original),names=['run_loop','$j_find_ctor$','$j_arm_type$','$book_cached$','$wnf$','$lookup$','$missing$','$kt$'];
  const declarations=Object.fromEntries(names.map(n=>{const hits=ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n);assert.equal(hits.length,1,n);return[n,hits[0]];}));
  assert(!original.includes('$p58QueryCounts'));
  const edits=['missing','kt'].map(n=>({at:declarations['$'+n+'$'].body.start+1,text:'$p58QueryCounts.'+n+'++;'})).sort((a,b)=>b.at-a.at);
  let text=original;for(const e of edits)text=text.slice(0,e.at)+e.text+text.slice(e.at);
  const suffix='\nconst $p58QueryCounts={missing:0,kt:0};\nexport const phase58Queries={find:(b,n)=>run_loop($j_find_ctor$(b,n)),arm:(b,t,n)=>run_loop($j_arm_type$(b,t,n)),cached:(b)=>run_loop($book_cached$(b,0)),wnf:(b,t)=>run_loop($wnf$(b,t)),lookup:(b,n)=>run_loop($lookup$(b,n)),reset:()=>{$p58QueryCounts.missing=0;$p58QueryCounts.kt=0;},counts:()=>({...$p58QueryCounts})};\n';
  text+=suffix;parse(text);const derived=path.join(out,role+'-query-probe.mjs');fs.writeFileSync(derived,text,{flag:'wx'});pin(derived);
  const mod=await import(pathToFileURL(derived));assert.equal(mod.G,undefined);const project=path.join(out,role+'-project');
  for(const n of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])copy(path.join(m.snapshot.root,'tools',n+'.mjs'),path.join(project,'tools',n+'.mjs'));
  copy(path.join(m.snapshot.root,'src/compiler.json'),path.join(project,'src/compiler.json'));copy(m.runtime.file,path.join(project,'src/runtime.mjs'));for(const f of files(path.join(m.snapshot.root,'src/runtime')))copy(f,path.join(project,path.relative(m.snapshot.root,f)));
  const R={m,project,probe:mod.phase58Queries};env(R);R.D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs')));R.api=await R.D.loadApi();assert.equal(R.D.apiPath,m.api.file);roles[role]=R;
  report.roles[role]={attempt,api:m.api,query,derivative:identity(derived),edits,suffixSha256:createHash('sha256').update(suffix).digest('hex'),project,productionAbiChanged:false};save();
 }
 const target=def('Quartz58','Ctr',[],term('ADT','Result58')),later=def('Quartz58','Ctr',[],term('ADT','Later58'));
 const empty=Array.from({length:512},(_,i)=>def('quiet'+i));
 const cases=[['empty-book',[], 'Quartz58',def('','Absent')],['empty-owners-hit',[...empty,def('Owner58','ADT',[target])],'Quartz58',target],['empty-owners-miss',empty,'Quartz58',def('','Absent')],
  ['nonempty-child-misses',[...empty.map((d,i)=>def(d.name,'ADT',[def('other'+i,'Ctr')])),def('Owner58','ADT',[target])],'Quartz58',target],
  ['first-owner-duplicate',[def('A','ADT',[target]),def('B','ADT',[later])],'Quartz58',target],['first-child-duplicate',[def('A','ADT',[target,later])],'Quartz58',target],
  ['matching-absent-skips-owner',[def('A','ADT',[def('Quartz58','Absent'),target]),def('B','ADT',[later])],'Quartz58',later],
  ['nonctor-first-match',[def('A','ADT',[def('Quartz58','Def')]),def('B','ADT',[target])],'Quartz58',def('Quartz58','Def')]];
 for(const [name,book,key,expected] of cases){const row={name,expected:digest(expected),roles:{}};const b=list(book),before=digest(b);
  for(const [role,R]of Object.entries(roles)){R.probe.reset();const value=R.probe.find(b,key);assert.deepEqual(value,expected);assert.equal(digest(b),before);row.roles[role]={result:digest(value),counts:R.probe.counts()};}
  assert.deepEqual(row.roles.baseline.result,row.roles.candidate.result);
  if(name==='empty-owners-hit'||name==='nonempty-child-misses'){assert.equal(row.roles.baseline.counts.missing,512);assert.equal(row.roles.candidate.counts.missing,0);}
  if(name==='empty-owners-miss'){assert.equal(row.roles.baseline.counts.missing,513);assert.equal(row.roles.candidate.counts.missing,1);}
  report.synthetic.push(row);save();}
 for(const [role,R]of Object.entries(roles)){
  const cache=R.probe.cached(list([target]));const children=list([...array(cache),def('Veil58','Ctr')]);
  for(const [name,key,expected]of [['cached-child-hit','Quartz58',target],['cached-child-miss-stops','Veil58',later]]){
   const b=list([def('CacheOwner','ADT',array(children)),def('Next','ADT',[{...later,name:'Veil58'}])]);
   R.probe.reset();const value=R.probe.find(b,key);assert.deepEqual(value,name==='cached-child-hit'?expected:{...expected,name:'Veil58'});
   report.synthetic.push({name,role,result:digest(value),counts:R.probe.counts()});}
 }
 const source=pin(catalog.accepted.file,catalog.accepted);let reference;
 for(const [role,R]of Object.entries(roles)){
  env(R);const graph=R.D.discoverSources(R.api,source.file);for(const f of graph.files)pin(f);const loaded=graph.loadTrace.result;assert.equal(loaded.error,'');
  const checked=R.api.check_program_diagnostic(loaded.book,list([]),list([]));assert.equal(checked.error,'');const book=R.api.book_context(checked.book);
  const names=[...fs.readFileSync(source.file,'utf8').matchAll(/^def\s+([^\s(:]+)/gm)].map(x=>x[1]);
  const selected=list(names.map(n=>R.probe.lookup(book,n)));const annotated=R.api.annotate_selected(book,selected,list([]));const before=digest({book,annotated});const rows=[];
  function walk(t){if(t.$==='KLiteral')return;const kids=array(t.kids);if(t.tag==='Ann'){
    let raw=kids[0];while(raw?.tag==='Ann')raw=array(raw.kids)[0];if(raw?.tag==='Mat'){
     const ty=R.probe.wnf(book,kids[1]);if(ty.tag==='All'){R.probe.reset();const arm=R.probe.arm(book,ty,raw.name);rows.push({name:raw.name,ty:digest(ty),arm:digest(arm),counts:R.probe.counts()});}
    }}for(const k of kids)walk(k);}
  for(const d of array(annotated))walk(d.value);assert(rows.length>0);assert.equal(digest({book,annotated}),before);
  const quincety=term('All','q',999991,1,[term('ADT','Quince58'),term('ADT','U32')]);
  for(const [name,ty,key]of [['unknown-owner',term('All','q',999991,1,[term('ADT','Unowned58'),term('ADT','U32')]),'Seed58'],
   ['owner-constructor-miss',quincety,'Carry58'],['unknown-telescope',term('Other','',0,0,[term('ADT','Quince58'),term('ADT','U32')]),'Seed58'],
   ['absent-telescope',absent(),'Seed58']]){
   R.probe.reset();const arm=R.probe.arm(book,ty,key);rows.push({name,ty:digest(ty),arm:digest(arm),counts:R.probe.counts(),fallback:true});
  }
  const values=rows.map(({counts,...r})=>r);if(reference)assert.deepEqual(values,reference);else reference=values;
  report.arms.push({role,rows,inputUnchanged:true});
  const emitted=await R.D.inspect(source.file,{mode:'library',backend:'direct'});assert.equal(emitted.status,'ok');assert.equal(emitted.typeAccepted,true);
  const moduleFile=path.join(out,role+'-renamed.mjs');fs.writeFileSync(moduleFile,emitted.code,{flag:'wx'});pin(moduleFile);const library=await import(pathToFileURL(moduleFile));assert.equal(library.default.main(),catalog.expected);
  const rejected=pin(catalog.rejected.file,catalog.rejected);const error=await R.D.inspect(rejected.file,{mode:'check'});assert.equal(error.status,'error');assert.equal(error.typeAccepted,false);assert(error.diagnostic.includes(catalog.diagnosticContains));
  report.sources.push({role,source,emitted:identity(moduleFile),value:catalog.expected,rejected,status:error.status,phase:error.phase,diagnostic:error.diagnostic});save();
 }
 assert.deepEqual(report.sources[0].diagnostic,report.sources[1].diagnostic);
 for(const row of inputs.values())assert.deepEqual(identity(row.file),row);await verifyAttempt(fs.realpathSync(baselineArg));await verifyAttempt(fs.realpathSync(candidateArg));
 report.complete=report.pass=true;
}catch(e){report.error={name:e.name,message:e.message,stack:e.stack};process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,synthetic:report.synthetic.length,armRows:report.arms.map(r=>r.rows.length),error:report.error?.message}));}
