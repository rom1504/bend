// Small raw-core correctness controls: original compiler versus candidate.
// Run under the root resource guard; no timings are benchmark claims.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const [recipeArg,baselineArg,candidateArg,outArg]=process.argv.slice(2);
const recipe=JSON.parse(fs.readFileSync(recipeArg,'utf8')),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const pin=p=>({file:path.resolve(p),sha256:createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
const root=path.resolve(import.meta.dirname,'../../../../..');
const runtimePath=path.join(root,'selfhost/src/runtime/native/runtime.c'),runtime=fs.readFileSync(runtimePath,'utf8');
const inputs=[pin(recipeArg),pin(baselineArg),pin(candidateArg),pin(runtimePath),pin(import.meta.filename)];
const report={kind:'phase68-native-raw-controls-v4',complete:false,pass:false,inputs,rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const list=a=>a.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',kids=[],id=0,quant=1)=>({$: 'KTerm',tag,name,kids:list(kids),id,quant,removed:list([])});
const vr=i=>t('Var','',[],i),ctr=(k,...a)=>t('Ctr',k,a),ref=k=>t('Ref',k),app=(f,x)=>t('App','',[f,x]);
const lam=(id,b)=>t('Lam','',[b],id),all=(id,a,b)=>t('All','',[a,b],id);
const nty=t('ADT','Nat'),nat=n=>n===0?ctr('Zero'):ctr('Succ',nat(n-1));
const def=(name,value,typ=nty)=>({$: 'KDef',name,kind:'Def',arity:0,templates:0,typ,value,ctors:list([]),native:value.tag==='Absent',unsafe:true});
const bind=(id,value,body)=>t('Let','',[t('Bind','',[value],id),body]);
const add=(a,b)=>app(app(ref('Nat.add'),a),b);
const baseCtor=(name,arity,typ)=>({...def(name,t('Absent'),typ),kind:'Ctr',arity});
const baseADT=(name,ctors)=>({...def(name,t('Absent'),t('Typ')),kind:'ADT',ctors:list(ctors),native:true});
const lty=t('ADT','List',[t('ADT','U32')]);
const parents=[baseADT('List',[baseCtor('Nil',0,lty),baseCtor('Con',2,all(78,t('ADT','U32'),all(79,lty,lty)))]),baseADT('Nat',[baseCtor('Zero',0,nty),baseCtor('Succ',1,all(80,nty,nty))])];
try {
 const apis={baseline:(await import(pathToFileURL(baselineArg))).default,candidate:(await import(pathToFileURL(candidateArg))).default};
 for(const [name,book,expected] of [
  ['body-error-first',[def('main',bind(1,vr(90),vr(91)))],'native unbound variable 91'],
  ['value-error',[def('main',bind(1,vr(90),vr(1)))],'native unbound variable 90'],
 ]) {
  const row={name,kind:'compile-error',expected,results:{}};
  for(const [role,api] of Object.entries(apis))row.results[role]=api.nc_compile(list([...book,...parents]),runtime,'').error;
  row.pass=Object.values(row.results).every(x=>x===expected);report.rows.push(row);save();assert(row.pass,JSON.stringify(row));
 }
 const books=[
  ['atom-chain',[def('main',bind(1,nat(7),bind(2,vr(1),bind(3,vr(2),vr(3)))))],'7n'],
  ['primitive-override',[def('main',add(nat(2),nat(3))),def('Nat.add',lam(91,lam(92,nat(9))))],'9n'],
  ['primitive-partial',[def('main',bind(10,app(ref('Nat.add'),nat(2)),app(vr(10),nat(3)))),def('Nat.add',t('Absent'))],'5n'],
 ];
 for(const [name,book,expected] of books)for(const [role,api] of Object.entries(apis)) {
  const got=api.nc_compile(list([...book,...parents]),runtime,'');assert.equal(got.error,'',name+' '+role);
  const stem=path.join(out,name+'-'+role);fs.writeFileSync(stem+'.c',got.source,{flag:'wx'});
  const cc=spawnSync(recipe.clang,[...recipe.clangArgs.filter(x=>x!=='-O3'),'-O1',stem+'.c',...recipe.linkArgs,'-o',stem],{encoding:'utf8',timeout:45000,maxBuffer:2**20});
  const row={name,role,kind:'native-execution',expected,source:pin(stem+'.c'),compile:{status:cc.status,stderr:cc.stderr,error:cc.error?.message},runs:[]};
  report.rows.push(row);save();assert.equal(cc.status,0,cc.stderr||cc.error?.message);
  for(const threads of [1,4]) { const run=spawnSync(stem,['--threads',String(threads),'--gpu','off'],{encoding:'utf8',timeout:10000,maxBuffer:2**20});row.runs.push({threads,status:run.status,stdout:run.stdout,stderr:run.stderr,pass:run.status===0&&run.stdout.trimEnd()===expected}); }
  row.pass=row.runs.every(x=>x.pass);save();assert(row.pass,JSON.stringify(row));
  if(name==='atom-chain') {
   // Diagnostic derivative only: mock a shared error observation in emitted
   // CPU C. Host err_post is synchronous; this does not execute GPU/device code.
   const start=got.source.indexOf('WL_CASE(FID_109_97_105_110_)');assert(start>=0);
   const at=got.source.indexOf('WL_OPEN',start)+'WL_OPEN'.length;assert(at>start);
   const markers=['r0 = v_3;'];
   assert.equal(got.source.split(markers[0]).length,2);
   const worker='INLINE Term NF_FID_109_97_105_110_(Env e, bool seq, Term* nf_out) {';
   if(got.source.includes(worker)) {
    assert.equal(got.source.split(worker).length,2);
    const workerHead=worker+'\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }';
    assert.equal(got.source.split(workerHead).length,2);
    assert.equal(got.source.split('#define err_spun(H, n) ((++*(n) & 4095) == 0 && err_seen(H))').length,2);
    markers.push('*nf_out = v_3;');
    assert.equal(got.source.split(markers[1]).length,2);
    // The original marker is in DEVICE fallback; this is the selected host return.
    assert(got.source.indexOf(markers[1])>got.source.indexOf(worker));
    assert(got.source.indexOf(markers[1])<start);
   }
   const seen='#define err_seen(H)    (DEVICE && a32_load(a32_at(H, H_ERROR_CODE)) != 0)';
   assert.equal(got.source.split(seen).length,2);
   const mock='static bool p67_shared_error = false;\nstatic bool p67_err_seen(Corpus H) { if (p67_shared_error) { fputs("P67_CHECKPOINT\\n", stderr); fflush(stderr); _exit(1); } return false; }\n#define err_seen(H) p67_err_seen(H)';
   const inject='\nseq = getenv("P67_FORCE_NONSEQ") == NULL; p67_shared_error = true;\n';
   let diagnostic=got.source.slice(0,at)+inject+got.source.slice(at);
   for(const marker of markers) diagnostic=diagnostic.replace(marker,'fputs("P67_BODY_REACHED\\n", stderr);\n'+marker);
   diagnostic=diagnostic.replace(seen,mock);
   const dc=stem+'-cancel.c',db=stem+'-cancel';fs.writeFileSync(dc,diagnostic,{flag:'wx'});
   const build=spawnSync(recipe.clang,[...recipe.clangArgs.filter(x=>x!=='-O3'),'-O1',dc,...recipe.linkArgs,'-o',db],{encoding:'utf8',timeout:45000,maxBuffer:2**20});
   const control={name:'shared-error-checkpoint',role,kind:'emitted-C-mocked-shared-error-diagnostic',scope:'Mocks shared error observation on CPU; no GPU execution or device conformance claim.',parent:pin(stem+'.c'),source:pin(dc),edits:[{at,insert:inject},{markers,insert:'P67_BODY_REACHED before both exact scheduler and selected NF host return sites; one compiled path executes'},{old:seen,new:mock}],compile:{status:build.status,stderr:build.stderr},runs:[]};report.rows.push(control);save();assert.equal(build.status,0,build.stderr);
   for(const nonseq of [false,true]) {
    const env={...process.env};delete env.P67_FORCE_NONSEQ;if(nonseq)env.P67_FORCE_NONSEQ='1';
    const r=spawnSync(db,['--threads','1','--gpu','off'],{env,encoding:'utf8',timeout:10000,maxBuffer:2**20});
    const reached=r.stderr.includes('P67_BODY_REACHED');control.runs.push({nonseq,status:r.status,stdout:r.stdout,stderr:r.stderr,pass:r.status===1&&r.stderr.includes('P67_CHECKPOINT')&&reached===!nonseq});
   }
   control.pass=control.runs.every(x=>x.pass);save();assert(control.pass,JSON.stringify(control));
  }
 }
 inputs.forEach(x=>assert.deepEqual(pin(x.file),x));
 report.complete=true;report.pass=report.rows.every(x=>x.pass);
} catch(error) {report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,rows:report.rows.length,error:report.error}));
