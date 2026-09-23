// P5-020 accepted-path cost gate. Run under an external deadline and CPU mask.
// Preparation/seed equality are untimed; each timed request uses a fresh graph.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {verifyAttempt,identity,verifyIdentity,validatedCache} from '../../development/workflow.mjs';
const [configArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('Usage: freshness-cost.mjs CONFIG NEW_OUTPUT (external 120s deadline required)');
const configFile=fs.realpathSync(configArg),config=JSON.parse(fs.readFileSync(configFile)),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
assert.deepEqual(Object.keys(config).sort(),['baseline','candidate','cases']);
const resolve=f=>fs.realpathSync(path.resolve(path.dirname(configFile),f)),inputs=[],capture=file=>{const item=identity(file);if(!inputs.some(p=>p.file===item.file))inputs.push(item);return item;};
const report={kind:'phase5-imported-freshness-cost',complete:false,started:new Date().toISOString(),rows:[],seedChecks:[],inputs,
 scope:'Warmed persistent API/host requests, fresh source graphs and unchanged validated Base bytes; parse/check only. External deadline required. No full compiler timing claim.',
 node:{...capture(process.execPath),version:process.version,args:process.execArgv},affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(s=>s.startsWith('Cpus_allowed_list:'))};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 capture(configFile);capture(import.meta.filename);capture(new URL('../../development/workflow.mjs',import.meta.url).pathname);
 const attempts={};for(const variant of ['baseline','candidate']){const directory=resolve(config[variant]);attempts[variant]={directory,manifest:await verifyAttempt(directory)};capture(path.join(directory,'attempt.json'));}
 const before=attempts.baseline.manifest,after=attempts.candidate.manifest;
 assert.equal(before.artifactKind,'checked-b1');assert.equal(after.artifactKind,'checked-b1');
 assert.equal(before.base.sha256,after.base.sha256);assert.equal(before.runtime.sha256,after.runtime.sha256);
 const bs=JSON.parse(fs.readFileSync(before.bootstrapReport.file)),as=JSON.parse(fs.readFileSync(after.bootstrapReport.file));
 const bm=new Map(bs.modules.map(m=>[m.file,m.sha256])),am=new Map(as.modules.map(m=>[m.file,m.sha256]));
 assert.deepEqual([...bm.keys()],[...am.keys()]);assert.deepEqual([...bm.keys()].filter(k=>bm.get(k)!==am.get(k)),['src/load/graph.bend']);
 report.sourceDelta=['src/load/graph.bend'];report.apis={baseline:capture(before.api.file),candidate:capture(after.api.file)};
 for(const m of [before,after]){capture(m.bootstrapReport.file);for(const item of m.artifacts)capture(item.file);for(const item of m.snapshot.sources)capture(item.frozen.file);}
 const host=path.join(out,'host'),tools=path.join(host,'tools');fs.mkdirSync(tools,{recursive:true});
 for(const name of ['typed-driver','compiler-abi','node-resource-args','native-build','assemble']){const original=path.join(before.snapshot.root,'tools',name+'.mjs'),copy=path.join(tools,name+'.mjs');capture(original);fs.copyFileSync(original,copy);capture(copy);}
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_')||k==='NODE_OPTIONS')delete process.env[k];
 Object.assign(process.env,{BEND_BASE:before.base.file,BEND_TYPED_RUNTIME:before.runtime.file,BEND_UPSTREAM:before.config.upstream});
 const cases=config.cases.map(c=>({...c,file:resolve(c.file)}));assert.ok(cases.length>=1&&cases.length<=8);
 for(const c of cases){assert.ok(['parse','check'].includes(c.mode));capture(c.file);}
 const drivers={};
 for(const variant of ['baseline','candidate']){
  const m=attempts[variant].manifest;process.env.BEND_TYPED_API=m.api.file;
  const driver=await import(pathToFileURL(path.join(tools,'typed-driver.mjs')).href+'?variant='+variant),api=await driver.loadApi(),seed=await driver.prepareBase(api);
  drivers[variant]={driver,api};capture(validatedCache(path.join(host,'build/typed/cache'),m.api.file,m.base.file).file);
  for(const c of cases){
   const seeded=driver.discoverSources(api,c.file,{seed}),plain=driver.discoverSources(api,c.file);
   for(const file of plain.files)capture(file);
   const x=api.f_load_graph_seed(seeded.main,seeded.sources,seed.sourcePath,seed.sourceText,seed.book),y=api.f_load_graph(plain.main,plain.sources);
   assert.deepEqual(JSON.parse(JSON.stringify(x)),JSON.parse(JSON.stringify(y)),variant+' seed mismatch '+c.id);
   report.seedChecks.push({variant,id:c.id,error:x.error,exact:true});
  }
  // Warm JIT and the exact host path twice; these observations are not timed.
  for(let i=0;i<2;i++)for(const c of cases){const result=await driver.inspect(c.file,{mode:c.mode,api});assert.equal(result.status,'ok',c.id);assert.equal(result.phase,c.mode);}
 }
 report.prepared=new Date().toISOString();save();const expected=new Map();
 for(let round=0;round<3;round++)for(const variant of round%2?['candidate','baseline']:['baseline','candidate']){
  const {driver,api}=drivers[variant];
  for(const c of cases){const start=performance.now(),result=await driver.inspect(c.file,{mode:c.mode,api}),milliseconds=performance.now()-start,key=c.id+'::'+c.mode;
   assert.equal(result.status,'ok');if(expected.has(key))assert.deepEqual(result,expected.get(key));else expected.set(key,result);
   report.rows.push({round,variant,id:c.id,mode:c.mode,milliseconds,result});save();
  }
 }
 inputs.forEach(verifyIdentity);for(const x of Object.values(attempts))await verifyAttempt(x.directory);
 report.inputsVerified=true;report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,error:report.error,rows:report.rows.length}));
