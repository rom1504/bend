// P5-021 host-only full frontend gate/comparison. No compiler or oracle changes.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache,observationHealth} from '../../development/workflow.mjs';
import {supervise,requireExecution} from '../../development/process.mjs';
const read=f=>JSON.parse(fs.readFileSync(f)),hash=b=>createHash('sha256').update(b).digest('hex');
const write=(f,v)=>fs.writeFileSync(f,JSON.stringify(v,null,2)+'\n',{flag:'wx'});
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):[path.join(d,e.name)]);
const key=r=>r.id+'::'+r.lane;
export function semanticRow(row,expectedHost){
 assert.ok(row.result&&Object.hasOwn(row.result,'hostProvenance'),'Missing explicit host provenance');
 assert.deepEqual(row.result.hostProvenance,expectedHost,'Unexpected host provenance');
 assert.deepEqual(Object.keys(expectedHost).sort(),['adapterSha256','driverSha256']);
 const {hostProvenance,...result}=row.result;
 return {id:row.id,namespace:row.namespace,lane:row.lane,negative:row.negative,status:row.status,reason:row.reason,evidence:row.evidence,result};
}
export function compareHostRows(previous,current,oldHost,newHost){
 assert.equal(new Set(previous.map(key)).size,previous.length);
 assert.equal(new Set(current.map(key)).size,current.length);assert.equal(previous.length,current.length);
 const prior=new Map(previous.map(row=>[key(row),semanticRow(row,oldHost)])),differences=[];
 for(const row of current){const actual=semanticRow(row,newHost),expected=prior.get(key(row));assert.ok(expected,'Missing prior row '+key(row));
  try{assert.deepEqual(actual,expected);}catch(error){differences.push({key:key(row),expected,actual,error:String(error)});}}
 return differences;
}
function healthy(raw){
 assert.ok(observationHealth(raw),'Incomplete or failed infrastructure observations');
 assert.equal(raw.inventory.total,1378);assert.equal(raw.results.length,2756);assert.equal(raw.workers.length,4);
 assert.ok(raw.workers.every(w=>w.stats.failures===0&&w.stats.timeouts===0));
 const positive=raw.results.filter(r=>!r.negative);assert.equal(positive.length,1838);assert.ok(positive.every(r=>r.status==='pass'),'Positive fixture regression');
}
async function histories(file,raw,project){
 const byWorker=new Map(raw.results.map(r=>[r.worker.session+'::'+r.worker.index,r]));assert.equal(byWorker.size,2756);
 const replay=await import(pathToFileURL(path.join(project,'tools/conformance/persistent-probe.mjs')));let total=0;
 const items=walk(file+'.artifacts').filter(f=>/\/worker-\d+\/session-\d+\.json$/.test(f)).map(f=>{
  const s=read(f);assert.equal(s.closed,true);assert.ok(s.requests.length>=1&&s.requests.length<=64);
  for(let i=0;i<s.requests.length;i++){const entry=s.requests[i],row=byWorker.get(f+'::'+i);assert.ok(row);assert.equal(entry.request.test.id,row.id);assert.equal(entry.request.lane,row.lane);assert.equal(entry.resultDigest,hash(JSON.stringify(row.result)));total++;}
  const index=s.requests.length-1,request={...s.requests[index].request,workerSession:{file:f,index,prefixDigest:s.requests[index].prefixDigest}};
  assert.equal(replay.validatePersistentReplay(request,s,raw.host.workerNodeArgs),index);
  return {identity:identity(f),requests:s.requests.length,closed:true};
 });assert.equal(total,2756);return items;
}
async function discovery(project,upstream,api,base,runtime){
 const env={...process.env};try{
  for(const k of Object.keys(process.env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete process.env[k];
  Object.assign(process.env,{BEND_UPSTREAM:upstream,BEND_TYPED_API:api,BEND_BASE:base,BEND_TYPED_RUNTIME:runtime,BEND_TYPED_TRACE:''});
  const inventory=await import(pathToFileURL(path.join(project,'tools/conformance/inventory.mjs'))),adapter=await import(pathToFileURL(path.join(project,'tools/conformance/adapters/typed.mjs')));
  const manifest=inventory.inventory(upstream);assert.equal(manifest.total,1378);
  const files=new Set([...manifest.tests.map(t=>t.file),...inventory.walk(path.join(upstream,'tests')),...inventory.walk(path.join(upstream,'bend2/effs')),...manifest.sources.map(s=>path.join(upstream,s.file))]);
  for(const f of typeof adapter.inputFiles==='function'?await adapter.inputFiles({tests:manifest.tests}):adapter.inputFiles||[])files.add(path.resolve(f));
  return {fixtureHashes:manifest.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0])),inputHashes:Object.fromEntries([...files].map(f=>[f,fs.existsSync(f)?inventory.sha256(fs.readFileSync(f)):null])),inputPaths:Object.fromEntries([...files].map(f=>[f,fs.existsSync(f)?fs.realpathSync(f):null]))};
 }finally{for(const k of Object.keys(process.env))if(!Object.hasOwn(env,k))delete process.env[k];Object.assign(process.env,env);}
}
async function prepare(configArg,outArg){
 const configFile=fs.realpathSync(configArg),config=read(configFile),resolve=f=>fs.realpathSync(path.resolve(path.dirname(configFile),f)),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
 assert.deepEqual(Object.keys(config).sort(),['attempt','candidate','gates']);
 const attempt=resolve(config.attempt),candidate=resolve(config.candidate),gatesFile=resolve(config.gates),gates=read(gatesFile),m=await verifyAttempt(attempt);
 assert.equal(m.artifactKind,'checked-b1');assert.equal(gates.complete,true);assert.equal(gates.rows.length,84);assert.ok(gates.contract.length>=15&&gates.contract.every(c=>c.pass));
 const preparationFile=path.join(candidate,'preparation.json'),preparation=read(preparationFile);
 assert.equal(fs.realpathSync(preparation.source),fs.realpathSync(m.snapshot.root));
 assert.equal(fs.realpathSync(preparation.output),candidate);
 for(const item of [...preparation.inputs,...preparation.outputs,preparation.tool,...gates.inputs])assert.equal(identity(item.file).sha256,item.sha256,'Changed reviewed input '+item.file);
 const reviewedGates=new Map(gates.inputs.map(i=>[fs.realpathSync(i.file),i.sha256]));
 assert.equal(reviewedGates.get(fs.realpathSync(preparationFile)),identity(preparationFile).sha256,'Gates used another preparation');
 const testedDriver=preparation.outputs.find(item=>item.file.endsWith('/tools/typed-driver.mjs'));assert.ok(testedDriver);
 assert.equal(reviewedGates.get(fs.realpathSync(testedDriver.file)),testedDriver.sha256,'Gates used another driver');
 assert.equal(reviewedGates.get(fs.realpathSync(m.api.file)),m.api.sha256,'Gates used another compiler');
 const inputs=[],capture=file=>{const item=identity(file);if(!inputs.some(x=>x.file===item.file))inputs.push(item);return item;};
 for(const f of [configFile,gatesFile,preparationFile,import.meta.filename,process.execPath,path.join(attempt,'attempt.json'),m.api.file,m.base.file,m.runtime.file,m.bootstrapReport.file])capture(f);
 for(const f of ['workflow','process'])capture(new URL('../../development/'+f+'.mjs',import.meta.url).pathname);
 capture(new URL('../../conformance/inventory.mjs',import.meta.url).pathname);
 for(const item of [...preparation.inputs,...preparation.outputs,preparation.tool,...gates.inputs])capture(item.file);
 for(const item of m.snapshot.sources)capture(item.frozen.file);
 const originalTools=walk(path.join(m.snapshot.root,'tools')).map(f=>path.relative(path.join(m.snapshot.root,'tools'),f)).sort(),candidateTools=walk(path.join(candidate,'tools')).map(f=>path.relative(path.join(candidate,'tools'),f)).sort();
 assert.deepEqual(candidateTools,originalTools);
 const changes=originalTools.filter(f=>identity(path.join(m.snapshot.root,'tools',f)).sha256!==identity(path.join(candidate,'tools',f)).sha256);
 assert.deepEqual(changes,['conformance/adapters/typed.mjs','typed-driver.mjs']);
 const runtimeFiles=walk(path.join(m.snapshot.root,'src/runtime')).map(f=>path.relative(path.join(m.snapshot.root,'src/runtime'),f)).sort();
 assert.deepEqual(walk(path.join(candidate,'src/runtime')).map(f=>path.relative(path.join(candidate,'src/runtime'),f)).sort(),runtimeFiles);
 for(const relative of ['src/runtime.mjs',...runtimeFiles.map(f=>'src/runtime/'+f)])assert.equal(identity(path.join(candidate,relative)).sha256,identity(path.join(m.snapshot.root,relative)).sha256,'Changed runtime input '+relative);
 const projects={},hostProvenance={},caches=[];
 for(const variant of ['control','memo']){
  const source=variant==='control'?m.snapshot.root:candidate,project=path.join(out,variant);projects[variant]=project;fs.mkdirSync(project);
  for(const relative of ['tools','src/runtime']){
   fs.mkdirSync(path.dirname(path.join(project,relative)),{recursive:true});fs.cpSync(path.join(source,relative),path.join(project,relative),{recursive:true});
   for(const f of walk(path.join(source,relative))){const old=capture(f),copy=capture(path.join(project,path.relative(source,f)));assert.equal(old.sha256,copy.sha256);}
  }
  fs.copyFileSync(m.runtime.file,path.join(project,'src/runtime.mjs'));capture(path.join(project,'src/runtime.mjs'));
  const cache=validatedCache(path.join(m.snapshot.root,'build/typed/cache'),m.api.file,m.base.file);capture(cache.file);
  const cacheDir=path.join(project,'build/typed/cache');fs.mkdirSync(cacheDir,{recursive:true});fs.copyFileSync(cache.file,path.join(cacheDir,path.basename(cache.file)));
  caches.push(capture(validatedCache(cacheDir,m.api.file,m.base.file).file));
  hostProvenance[variant]={driverSha256:identity(path.join(project,'tools/typed-driver.mjs')).sha256,adapterSha256:identity(path.join(project,'tools/conformance/adapters/typed.mjs')).sha256};
 }
 const expected=await discovery(projects.control,m.config.upstream,m.api.file,m.base.file,m.runtime.file),memoDiscovery=await discovery(projects.memo,m.config.upstream,m.api.file,m.base.file,m.runtime.file);assert.deepEqual(memoDiscovery,expected);
 for(const [file,digest] of Object.entries(expected.inputHashes))if(digest!==null){assert.equal(capture(file).sha256,digest);}
 const sourceCopy=path.join(out,'base-memo-frontend.mjs.source');fs.copyFileSync(import.meta.filename,sourceCopy);capture(sourceCopy);
 const report={kind:'phase5-base-memo-frontend-snapshot',complete:true,newBootstrap:false,created:new Date().toISOString(),attempt,projects,upstream:m.config.upstream,api:m.api,base:m.base,runtime:m.runtime,originalBootstrap:m.bootstrapReport,changes,hostProvenance,caches,expected,inputs,node:{...identity(process.execPath),version:process.version},cachePolicy:'Identical separately copied prevalidated API-specific Base bytes. Fresh worker processes in each run; private decoded memo lasts at most64requests. First misses/freezing are inside measured harness wall.'};
 inputs.forEach(verifyIdentity);await verifyAttempt(attempt);write(path.join(out,'snapshot.json'),report);return report;
}
async function run(snapshotArg,outArg){
 const file=fs.realpathSync(path.join(snapshotArg,'snapshot.json')),s=read(file),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});assert.equal(s.kind,'phase5-base-memo-frontend-snapshot');assert.equal(s.complete,true);
 assert.equal(process.execPath,s.node.file);assert.equal(process.version,s.node.version);
 const inputs=[...s.inputs,identity(file),identity(import.meta.filename),...['workflow','process'].map(n=>identity(new URL('../../development/'+n+'.mjs',import.meta.url).pathname)),identity(new URL('../../conformance/inventory.mjs',import.meta.url).pathname)];
 const verify=async()=>{inputs.forEach(verifyIdentity);await verifyAttempt(s.attempt);};await verify();
 const topology=[0,1,2,3].map(cpu=>({cpu,core:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/core_id`,'utf8').trim(),package:fs.readFileSync(`/sys/devices/system/cpu/cpu${cpu}/topology/physical_package_id`,'utf8').trim()}));assert.equal(new Set(topology.map(t=>t.package+':'+t.core)).size,4);
 const startedMono=performance.now(),totalBudgetMs=1200000;
 const report={kind:'phase5-base-memo-full-frontend-comparison',complete:false,newBootstrap:false,started:new Date().toISOString(),totalBudgetMs,inputs,topology,order:['control','memo','memo','control'],hostProvenance:s.hostProvenance,rows:[],scope:'Same genuine compiler, host-only private Base decoding memo. All semantic result fields and known verdicts remain exact; the two-field host provenance tuple is separately verified, not silently normalized.',resourceScope:'Finite four-worker shared-mask harness wall; request-reported per-worker RSS high water, not aggregate or OS process-tree peak. Preparation/post-audit excluded from reported harness wall but included in the 20-minute overall run budget.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();let expected=null;
 try{
  for(let index=0;index<report.order.length;index++){
   await verify();const variant=report.order[index],project=s.projects[variant],directory=path.join(out,index+'-'+variant);fs.mkdirSync(directory);const observedFile=path.join(directory,'observations.json');
   const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete env[k];Object.assign(env,{BEND_UPSTREAM:s.upstream,BEND_BASE:s.base.file,BEND_TYPED_RUNTIME:s.runtime.file,BEND_TYPED_API:s.api.file,BEND_TYPED_TRACE:''});
   const args=['-c','0,1,2,3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',path.join(project,'tools/conformance/run.mjs'),'--upstream',s.upstream,'--jobs','4','--timeout','300000','--worker-mode','persistent','--recycle-after','64','--rss-limit-mb','4096','--stack-kb','4096','--heap-mb','4096','--lanes','parse,check','--retain','failed','--adapter',path.join(project,'tools/conformance/adapters/typed.mjs'),'--output',observedFile];
   const remainingMs=Math.floor(totalBudgetMs-(performance.now()-startedMono));assert.ok(remainingMs>0,'Whole comparison exceeded20-minute budget');
   const row={index,variant,started:new Date().toISOString(),complete:false};report.rows.push(row);save();row.execution=await supervise('taskset',args,{directory:path.join(directory,'process'),env,timeoutMs:Math.min(900000,remainingMs)});save();requireExecution(row.execution,[0,1]);
   const raw=read(observedFile);row.observations=identity(observedFile);healthy(raw);
   assert.equal(raw.identity.artifacts.compiler.sha256,s.api.sha256);assert.equal(raw.identity.artifacts.base.sha256,s.base.sha256);assert.equal(raw.identity.artifacts.runtime.sha256,s.runtime.sha256);
   assert.deepEqual(raw.inputHashes,s.expected.inputHashes);assert.deepEqual(raw.inputPaths,s.expected.inputPaths);assert.deepEqual(raw.inventory.tests.map(t=>[t.id,t.sha256]).sort((a,b)=>a[0].localeCompare(b[0])),s.expected.fixtureHashes);
   for(const r of raw.results)semanticRow(r,s.hostProvenance[variant]);
   if(expected)row.differences=compareHostRows(expected.results,raw.results,s.hostProvenance.control,s.hostProvenance[variant]);else{assert.equal(variant,'control');expected=raw;row.differences=[];}
   row.hostProvenanceVerified=s.hostProvenance[variant];row.summary=raw.summary;row.fullConformance=raw.complete;row.workerStats=raw.workers;row.maxWorkerRssBytes=Math.max(...raw.workers.map(w=>w.stats.maxRssBytes));save();assert.equal(row.differences.length,0,'Changed semantic observations');
   row.histories=await histories(observedFile,raw,project);row.workerHistoriesVerified=true;row.histories.forEach(h=>verifyIdentity(h.identity));await verify();row.complete=true;row.finished=new Date().toISOString();save();
  }
  for(const row of report.rows){verifyIdentity(row.observations);row.histories.forEach(h=>verifyIdentity(h.identity));}await verify();
  const walls=v=>report.rows.filter(r=>r.variant===v).map(r=>r.execution.wallMs),control=walls('control'),memo=walls('memo');
  report.measurement={controlWallMs:control,memoWallMs:memo,controlMeanWallMs:(control[0]+control[1])/2,memoMeanWallMs:(memo[0]+memo[1])/2,pairReductionPercent:[100*(1-memo[0]/control[0]),100*(1-memo[1]/control[1])],wallReductionPercent:100*(1-(memo[0]+memo[1])/(control[0]+control[1]))};
  assert.ok(performance.now()-startedMono<=totalBudgetMs,'Whole comparison exceeded20-minute budget');
  report.inputsVerified=true;report.complete=true;report.finished=new Date().toISOString();save();return report;
 }catch(error){report.error=String(error.stack??error);report.finished=new Date().toISOString();save();throw error;}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const[mode,input,out,...extra]=process.argv.slice(2);if(!out||extra.length||!['prepare','run'].includes(mode))throw Error('Usage: base-memo-frontend.mjs prepare CONFIG NEW_SNAPSHOT | run SNAPSHOT NEW_RUN');const report=await(mode==='prepare'?prepare(input,out):run(input,out));console.log(JSON.stringify({complete:report.complete,measurement:report.measurement}));}
