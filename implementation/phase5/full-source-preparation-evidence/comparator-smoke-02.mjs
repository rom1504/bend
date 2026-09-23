// Fresh full-source comparison. This consumes maintained checked provenance;
// it neither fabricates a bootstrap sidecar nor imports rows into a proof.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache} from '../../development/workflow.mjs';
import {deriveEquality,verifyEqualityDerivation} from '../../development/equality.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';

const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const write=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n',{flag:'wx'});
export const ORDER=['typescript','checked','derived','derived','checked','typescript'];
export function settings(value){
 for(const k of Object.keys(value))assert.ok(['attempt','cpu','timeoutMs','deadline','heapMb','smoke'].includes(k),'Unknown setting: '+k);
 if(value.smoke!==undefined)assert.equal(typeof value.smoke,'boolean');
 assert.equal(typeof value.attempt,'string');assert.ok(value.attempt.length);
 const cpu=value.cpu??1,timeoutMs=value.timeoutMs??900000,heapMb=value.heapMb??12288;
 assert.ok(Number.isSafeInteger(cpu)&&cpu>=0);
 assert.ok(Number.isSafeInteger(timeoutMs)&&timeoutMs>=1000&&timeoutMs<=900000);
 assert.ok(Number.isSafeInteger(heapMb)&&heapMb>=4096&&heapMb<=12288);
 assert.equal(typeof value.deadline,'string');assert.ok(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{3})?Z$/.test(value.deadline)&&Number.isFinite(Date.parse(value.deadline)),'An absolute finite UTC campaign deadline is required');
 return {...value,cpu,timeoutMs,heapMb};
}
export function summarize(rows){
 const complete=rows.length===ORDER.length&&rows.every((r,i)=>r.index===i&&r.variant===ORDER[i]&&r.passed===true&&[r.observation?.requestMs,r.execution?.wallMs,r.observation?.maxRssKiB].every(n=>Number.isFinite(n)&&n>0));
 if(!complete)return {validComparison:false,timingsWithheld:'All six checked observations, output and root gates must pass; individual completed observations remain in rows.'};
 const variants=Object.fromEntries(['typescript','checked','derived'].map(v=>{const s=rows.filter(r=>r.variant===v),mean=f=>s.reduce((a,r)=>a+f(r),0)/s.length;return [v,{samples:2,meanRequestMs:mean(r=>r.observation.requestMs),meanProcessWallMs:mean(r=>r.execution.wallMs),meanMaxRssKiB:mean(r=>r.observation.maxRssKiB),maxRssKiB:Math.max(...s.map(r=>r.observation.maxRssKiB))}];}));
 const pairs=[[1,2],[4,3]].map(([a,b])=>({checkedIndex:a,derivedIndex:b,requestReductionPercent:100*(1-rows[b].observation.requestMs/rows[a].observation.requestMs),processReductionPercent:100*(1-rows[b].execution.wallMs/rows[a].execution.wallMs)}));
 return {validComparison:true,variants,pairs,descriptiveRatiosToTypescript:Object.fromEntries(['checked','derived'].map(v=>[v,{request:variants[v].meanRequestMs/variants.typescript.meanRequestMs,process:variants[v].meanProcessWallMs/variants.typescript.meanProcessWallMs}])),limits:'Two opposite-order samples per variant, one host. TypeScript includes fresh Base checking while Bend uses separately validated on-disk Base caches; ratios do not isolate backend lowering or identical cache work.'};
}

export async function compare(configArg,outArg){
 const configFile=fs.realpathSync(configArg),config=settings(read(configFile)),out=path.resolve(outArg);
 fs.mkdirSync(out,{recursive:false});
 const report={kind:'phase5-final-full-source-comparison',complete:false,newBootstrap:false,started:new Date().toISOString(),inputs:[],prime:[],rows:[],order:ORDER,
  scope:'Same final assembled source and canonical Base, fully checked/owned/closed library compilation. B1/derived emitted bytes and repeated TypeScript bytes must agree within their emitter families; no cross-emitter byte equivalence is asserted.',
  cachePolicy:'Separate API-specific validated Base caches, primed in fresh processes outside measured samples; their decoded graphs must be identical. TypeScript loads/checks Base in every fresh process. OS caches are not flushed.',
  timingBoundary:'Request excludes imports, provenance hashing, emitted-file writes and result serialization; includes ordinary source/cache reads and compiler pipeline. Process wall includes fresh Node startup, imports, provenance and output capture. Nested API phase timings overlap and must not be summed. Output syntax/root/execution oracles run separately outside the measured process.',
  proofPolicy:'This is a compilation comparison, not a fixed-point proof. Run the unchanged conformance/selfhost.mjs separately from the genuine checked B1; measurement rows are never synthesized into its resume report.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 const add=file=>{const item=identity(file);if(!report.inputs.some(i=>i.file===item.file))report.inputs.push(item);return item.file;};
 const verify=()=>report.inputs.forEach(verifyIdentity);
 const remaining=maximum=>{const ms=Math.min(maximum,Date.parse(config.deadline)-Date.now());assert.ok(ms>=1,'Campaign deadline exhausted');return Math.floor(ms);};
 try{
  remaining(config.timeoutMs);
  const attempt=fs.realpathSync(path.resolve(path.dirname(configFile),config.attempt)),m=await verifyAttempt(attempt);
  assert.equal(m.artifactKind,'checked-b1');const boot=read(m.bootstrapReport.file);
  report.original={attempt:identity(path.join(attempt,'attempt.json')),api:m.api,bootstrap:m.bootstrapReport};
  report.compilerSource=identity(boot.source);report.source=config.smoke?identity(new URL('./full-source-smoke.bend',import.meta.url).pathname):report.compilerSource;report.base=m.base;report.runtime=m.runtime;
  if(config.smoke){report.kind='phase5-full-source-tool-smoke';report.scope='Tiny accepted library exercises the comparison pipeline with a genuine compiler. This is NOT a full-source observation. Checked B1 classifies TypeScript root metadata; tiny emitted H has no j_library_roots export, so that full-compiler-only check is not performed.';report.smoke=true;}
  for(const file of [configFile,import.meta.filename,path.join(attempt,'attempt.json'),m.api.file,m.bootstrapReport.file,boot.source,report.source.file,m.base.file,m.runtime.file,process.execPath])add(file);
  for(const name of ['workflow','equality','process'])add(new URL('../../development/'+name+'.mjs',import.meta.url).pathname);
  add(new URL('../../conformance/inventory.mjs',import.meta.url).pathname);
  const derived=await deriveEquality({api:m.api.file,bootstrapReport:m.bootstrapReport.file,outputDirectory:path.join(out,'derived')});
  report.derivation=identity(derived.report);
  for(const file of [derived.api,derived.report,derived.metadata.toolSnapshot.file])add(file);
  for(const item of derived.metadata.original.inputs){verifyIdentity(item);add(item.file);}
  const upstream=m.config.upstream,base=m.base.file,runtime=m.runtime.file;
  assert.equal(fs.realpathSync(base),fs.realpathSync(path.join(upstream,'bend2/base.bend')));
  for(const name of ['bend.ts','comp.ts','base.bend','main.ts'])add(path.join(upstream,'bend2',name));
  const walk=directory=>fs.readdirSync(directory,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(directory,e.name)):[path.join(directory,e.name)]);
  for(const file of walk(path.join(upstream,'bend2/effs')))add(file);
  const env={...process.env};for(const key of Object.keys(env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete env[key];
  async function git(label,args){const r=await supervise('git',['-C',upstream,...args],{directory:path.join(out,label),env,timeoutMs:remaining(10000)});requireExecution(r);return r;}
  report.upstream={directory:upstream,pin:derived.metadata.original.revision,clean:await git('upstream-clean',['diff','--quiet','HEAD','--','bend2','tests'])};
  report.upstream.head=await git('upstream-head',['rev-parse','HEAD']);assert.equal(fs.readFileSync(report.upstream.head.stdout,'utf8').trim(),report.upstream.pin);
  const hostDir=path.join(out,'host/tools');fs.mkdirSync(hostDir,{recursive:true});report.hostCopies=[];
  for(const name of ['typed-driver','compiler-abi','native-build','node-resource-args','assemble']){const original=add(path.join(m.snapshot.root,'tools',name+'.mjs')),copy=path.join(hostDir,name+'.mjs');fs.copyFileSync(original,copy);add(copy);assert.equal(identity(original).sha256,identity(copy).sha256);report.hostCopies.push({original:identity(original),copy:identity(copy)});}
  const host=path.join(hostDir,'typed-driver.mjs'),worker=path.join(out,'worker.mjs');
  const workerSource=add(new URL('./full-source-worker.mjs',import.meta.url).pathname);fs.copyFileSync(workerSource,worker);add(worker);
  const classifier=path.join(out,'checked-root-classifier.mjs'),text=fs.readFileSync(m.api.file,'utf8');
  assert.equal((text.match(/function \$j_library_roots\$\(/g)??[]).length,1,'Missing exact checked root worker');
  const adapter='\nexport function finalLibraryRoots(defs){return run_loop($j_library_roots$(defs));}\n';
  fs.writeFileSync(classifier,text+adapter,{flag:'wx'});add(classifier);report.classifier={original:m.api,adapted:identity(classifier),adapter,scope:'Export-only adapter of the unchanged checked worker; this is not a new checked compiler.'};
  const classifierModule=await import(pathToFileURL(classifier));
  const classify=metadata=>{const nil={$:'Nil'},atom=tag=>({$:'KTerm',tag,name:'',id:0,quant:0,kids:nil,removed:nil});let book=nil;
   for(const d of [...metadata].reverse())book={$:'Con',head:{$:'KDef',name:d.name,kind:d.kind,arity:0,templates:d.templates,typ:atom('Type'),value:atom(d.valueTag),ctors:nil,native:d.base,unsafe:false},tail:book};
   const roots=[];let xs=classifierModule.finalLibraryRoots(book);while(xs.$==='Con'){roots.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return roots;};
  const variants={checked:{id:'checked',api:m.api.file},derived:{id:'derived',api:derived.api},typescript:{id:'typescript'}};
  const work={id:'compiler',input:report.source.file,mode:'library'};
  report.variants=variants;report.cpu=config.cpu;report.deadline=config.deadline;report.node={...identity(process.execPath),version:process.version,args:['--stack-size=4096',`--max-old-space-size=${config.heapMb}`]};
  report.stackLimit=fs.readFileSync('/proc/self/limits','utf8').split('\n').find(s=>s.startsWith('Max stack size'));
  const stackSoft=/^Max stack size\s+(\S+)/.exec(report.stackLimit??'')?.[1];assert.ok(stackSoft==='unlimited'||Number(stackSoft)>=8192*1024,'4MiB Node stack needs a verified OS stack limit of at least 8MiB');save();
  async function sample(variant,label,prime=false,index=null){
   verify();const request=path.join(out,label+'.request.json'),result=path.join(out,label+'.result.json'),output=path.join(out,label+'.mjs');
   write(request,{variant:variant.id,api:variant.api,upstream,base,runtime,host,input:work.input,mode:'library',output,prime,workloads:[work],inputs:report.inputs});
   const row={index,label,variant:variant.id,request:identity(request),started:new Date().toISOString(),passed:false};(prime?report.prime:report.rows).push(row);save();
   row.execution=await supervise('taskset',['-c',String(config.cpu),process.execPath,...report.node.args,worker,request,result],{directory:path.join(out,label+'-process'),env,timeoutMs:remaining(config.timeoutMs)});
   row.finished=new Date().toISOString();if(fs.existsSync(result)){row.result=identity(result);row.observation=read(result);}save();requireExecution(row.execution);
   assert.equal(row.observation.inputsVerified,true);assert.equal(row.observation.node.path,process.execPath);assert.deepEqual(row.observation.node.args,report.node.args);
   assert.equal(row.observation.affinity.split(':')[1].trim(),String(config.cpu));assert.ok([row.observation.requestMs,row.observation.maxRssKiB,row.execution.wallMs].every(n=>Number.isFinite(n)&&n>0));verify();return row;
  }
  for(const name of ['checked','derived']){
   const variant=variants[name],row=await sample(variant,'prime-'+name,true),cache=row.observation.cache;
   assert.equal(row.observation.result.status,'primed');assert.equal(cache.validatedBy,'check_book');assert.equal(cache.compilerSha256,identity(variant.api).sha256);assert.equal(cache.baseSha256,m.base.sha256);
   row.cache=validatedCache(path.join(out,'host/build/typed/cache'),variant.api,base);add(row.cache.file);
   for(const file of row.observation.dependencies)add(file);row.passed=true;save();
  }
  assert.deepEqual(read(report.prime[0].cache.file).book,read(report.prime[1].cache.file).book,'Decoded Base books differ');report.decodedBaseEqual=true;
  let roots,metadata;
  for(const [index,name] of ORDER.entries()){
   const row=await sample(variants[name],'sample-'+index+'-'+name,false,index),r=row.observation.result;
   assert.deepEqual({status:r.status,phase:r.phase,checked:r.checked,exitCode:r.exitCode,diagnostic:r.diagnostic??null},{status:'ok',phase:'compile',checked:true,exitCode:0,diagnostic:null});
   verifyIdentity(row.observation.emitted);
   if(name==='typescript'){
    const actual=classify(row.observation.rootMetadata);assert.deepEqual(actual,row.observation.roots);
    if(roots){assert.deepEqual(actual,roots);assert.deepEqual(row.observation.rootMetadata,metadata);}else {roots=actual;metadata=row.observation.rootMetadata;}
    row.checkedRootClassifierEqual=true;
   }
   assert.ok(roots&&metadata);
   if(name!=='typescript')assert.deepEqual(row.observation.roots,roots,'Actual Bend book roots differ from TypeScript root order');
   for(const peer of report.rows.filter(p=>p!==row&&p.passed&&((p.variant==='typescript')===(name==='typescript'))))assert.deepEqual(fs.readFileSync(row.observation.emitted.file),fs.readFileSync(peer.observation.emitted.file),'Repeated or B1/derived emitted bytes differ');
   const oracle=path.join(out,row.label+'-oracle.mjs');
   const actualHClassifier=name!=='typescript'&&!config.smoke;
   const code=`import assert from 'node:assert/strict';\nconst H=await import(${JSON.stringify(pathToFileURL(row.observation.emitted.file).href)});\nconst roots=${JSON.stringify(roots)},metadata=${JSON.stringify(metadata)};\n${name==='typescript'?'assert.deepEqual(Object.keys(H.default),roots);':'for(const root of roots)assert.ok(Object.hasOwn(H.default,root),root);'}\nassert.equal(H.default.f_ascii_ident_code(65),true);assert.equal(H.default.f_ascii_ident_code(128512),false);\n`+(!actualHClassifier?'':`const nil=H.list([]),atom=tag=>H.ctor('KTerm',[tag,'',0,0,nil,nil]);\nconst defs=metadata.map(d=>H.ctor('KDef',[d.name,d.kind,0,d.templates,atom('Type'),atom(d.valueTag),nil,d.base,false]));\nlet list=H.default.j_library_roots(H.list(defs));const actual=[];while(list.$==='Con'){actual.push(list.a[0]);list=list.a[1];}assert.equal(list.$,'Nil');assert.deepEqual(actual,roots);\n`)+`console.log(JSON.stringify({rootCount:roots.length,actualOutputExports:true,actualHClassifier:${actualHClassifier},asciiOracle:true}));\n`;
   fs.writeFileSync(oracle,code,{flag:'wx'});row.oracle=identity(oracle);
   row.outputExecution=await supervise('taskset',['-c',String(config.cpu),process.execPath,...report.node.args,oracle],{directory:path.join(out,row.label+'-oracle-process'),env,timeoutMs:remaining(30000),maxBytes:1048576});requireExecution(row.outputExecution);
   row.rootGate={roots:roots.length,checkedClassifier:true,actualOutputExports:true,actualHClassifier};row.passed=true;save();
  }
  await verifyAttempt(attempt);verifyEqualityDerivation(derived.report);verify();
  report.upstream.finalClean=await git('upstream-final-clean',['diff','--quiet','HEAD','--','bend2','tests']);
  report.upstream.finalHead=await git('upstream-final-head',['rev-parse','HEAD']);assert.equal(fs.readFileSync(report.upstream.finalHead.stdout,'utf8').trim(),report.upstream.pin);
  report.inputsUnchanged=true;report.summary=summarize(report.rows);assert.equal(report.summary.validComparison,true);report.complete=true;report.finished=new Date().toISOString();save();return report;
 }catch(error){report.error=String(error.stack??error);report.summary=summarize(report.rows);report.finished=new Date().toISOString();save();throw error;}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [config,out,...extra]=process.argv.slice(2);if(!out||extra.length)throw Error('Usage: full-source-compare.mjs CONFIG NEW_DIRECTORY');const report=await compare(config,out);console.log(JSON.stringify({complete:report.complete,summary:report.summary}));}
