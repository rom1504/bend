#!/usr/bin/env node
// Small paired frontend experiment. This measures worker reuse, never compiler
// equivalence or full conformance. Every timed cell uses frozen host artifacts.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import os from 'node:os';
import {spawnSync} from 'node:child_process';
import {performance} from 'node:perf_hooks';
import {fileURLToPath,pathToFileURL} from 'node:url';
const sha=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const digest=file=>sha(fs.readFileSync(file));
const save=(file,value)=>fs.writeFileSync(file,JSON.stringify(value,null,2)+'\n');
const median=values=>[...values].sort((a,b)=>a-b)[Math.floor(values.length/2)];
const files=directory=>fs.readdirSync(directory,{withFileTypes:true}).flatMap(entry=>entry.isDirectory()?files(path.join(directory,entry.name)):[path.join(directory,entry.name)]).sort();
export function measure(configFile,output){
  const config=JSON.parse(fs.readFileSync(configFile,'utf8'));
  const relative=file=>path.resolve(path.dirname(configFile),file);
  const project=relative(config.project),upstream=relative(config.upstream),api=relative(config.api);
  const cpu=config.cpu??0,rounds=config.rounds??3;
  if(!Number.isSafeInteger(rounds)||rounds<2||!Number.isSafeInteger(cpu)||cpu<0)throw Error('Invalid measurement rounds or CPU');
  if(fs.existsSync(output))throw Error('Measurement output must be fresh');
  fs.mkdirSync(output,{recursive:true});
  const snapshot=path.join(output,'snapshot');fs.mkdirSync(path.join(snapshot,'src'),{recursive:true});fs.mkdirSync(path.join(snapshot,'dist'));
  fs.cpSync(path.join(project,'tools'),path.join(snapshot,'tools'),{recursive:true});
  fs.cpSync(path.join(project,'src/runtime/native'),path.join(snapshot,'src/runtime/native'),{recursive:true});
  fs.copyFileSync(relative(config.runtime??path.join(project,'src/runtime.mjs')),path.join(snapshot,'src/runtime.mjs'));
  fs.copyFileSync(api,path.join(snapshot,'dist/api.mjs'));
  fs.copyFileSync(path.join(upstream,'bend2/base.bend'),path.join(snapshot,'dist/base.bend'));
  const artifacts=Object.fromEntries(files(snapshot).map(file=>[path.relative(snapshot,file),digest(file)]));
  save(path.join(output,'frozen-artifacts.json'),artifacts);
  save(path.join(output,'config.json'),{...config,project,upstream,api});
  const environment={...process.env,BEND_UPSTREAM:upstream,BEND_TYPED_API:path.join(snapshot,'dist/api.mjs'),BEND_TYPED_RUNTIME:path.join(snapshot,'src/runtime.mjs'),BEND_BASE:path.join(snapshot,'dist/base.bend'),BEND_TYPED_TRACE:''};
  delete environment.NODE_OPTIONS;delete environment.NODE_COMPILE_CACHE;environment.NODE_DISABLE_COMPILE_CACHE='1';
  const preparationCommand=['taskset','-c',String(cpu),process.execPath,'--stack-size=4096','--max-old-space-size=4096','--input-type=module','-e',`const driver=await import(${JSON.stringify(pathToFileURL(path.join(snapshot,'tools/typed-driver.mjs')).href)});await driver.prepareBase();`];
  const preparationStart=performance.now();
  const preparation=spawnSync(preparationCommand[0],preparationCommand.slice(1),{cwd:project,env:environment,encoding:'utf8',timeout:120000,maxBuffer:2**22});
  if(preparation.error||preparation.status!==0)throw Error('Base cache preparation failed: '+(preparation.error||preparation.stderr));
  const cacheDirectory=path.join(snapshot,'build/typed/cache');
  const preparedCache={command:preparationCommand,wallMs:performance.now()-preparationStart,files:Object.fromEntries(files(cacheDirectory).map(file=>[file,digest(file)])),includedInTimedCells:false};
  if(!Object.keys(preparedCache.files).length)throw Error('Base cache preparation produced no artifact');
  save(path.join(output,'prepared-cache.json'),preparedCache);
  const cases=config.cases??['base/list_fold.bend','check/alpha_equivalence.bend','check/typed_let_mismatch.bend','parse/law_fill_arrow.bend'];
  const rows=[],observations=new Map();
  for(let round=0;round<rounds;round++){
    const entries=cases.flatMap(id=>['parse','check'].map(lane=>({id,lane})));
    if(round%2)entries.reverse();
    const selection=path.join(output,`selection-${round}.json`);save(selection,entries);
    for(const adapter of round%2?['upstream','typed']:['typed','upstream'])for(const mode of round%2?['persistent','isolated']:['isolated','persistent']){
      const name=`${adapter}-${mode}-${round}`,reportFile=path.join(output,name+'.json');
      const args=[path.join(snapshot,'tools/conformance/run.mjs'),'--upstream',upstream,'--adapter',path.join(snapshot,'tools/conformance/adapters',adapter+'.mjs'),'--selection',selection,'--output',reportFile,'--jobs','1','--timeout',String(config.timeoutMs??30000),'--retain','all','--worker-mode',mode,'--recycle-after','64','--rss-limit-mb','2048','--stack-kb','4096','--heap-mb','4096','--selected-exit','1'];
      const command=['taskset','-c',String(cpu),process.execPath,...args],started=performance.now();
      const child=spawnSync(command[0],command.slice(1),{cwd:project,env:environment,encoding:'utf8',timeout:180000,maxBuffer:2**22});
      const wallMs=performance.now()-started;fs.writeFileSync(path.join(output,name+'.stdout'),child.stdout||'');fs.writeFileSync(path.join(output,name+'.stderr'),child.stderr||'');
      if(child.error||!fs.existsSync(reportFile))throw Error(`Measurement failed ${name}: ${child.error||child.stderr}`);
      const report=JSON.parse(fs.readFileSync(reportFile,'utf8'));
      if(report.results.length!==entries.length||report.changedInputs.length||report.identity.adapterChangedDuringRun||report.identity.changedArtifacts.length||report.results.some(row=>['timeout','crash','unsupported'].includes(row.status))||report.workers?.some(worker=>worker.errors.length))throw Error('Invalid measurement cell: '+name);
      const exact=report.results.map(row=>({id:row.id,lane:row.lane,result:row.result,status:row.status,reason:row.reason,evidence:row.evidence}));
      const observationSha256=sha(JSON.stringify(exact));
      if(observations.has(adapter)&&observations.get(adapter).hash!==observationSha256)throw Error('Persistent/isolated/reordered observation mismatch: '+name);
      observations.set(adapter,{hash:observationSha256,rows:exact});
      const row={adapter,mode,round,order:entries,command,wallMs,probeMs:report.results.reduce((sum,row)=>sum+row.ms,0),report:reportFile,reportSha256:digest(reportFile),exitCode:child.status,selectedComplete:report.selectedComplete,fullComplete:report.complete,summary:report.summary.statuses,observationSha256,workers:report.workers};
      for(const [file,hash] of Object.entries(preparedCache.files))if(digest(file)!==hash)throw Error('Prepared Base cache changed: '+file);
      rows.push(row);save(path.join(output,'progress.json'),rows);console.log(JSON.stringify({cell:name,wallMs:Math.round(wallMs),probeMs:row.probeMs,observationsEqual:true}));
    }
  }
  for(const [file,hash] of Object.entries(artifacts))if(digest(path.join(snapshot,file))!==hash)throw Error('Frozen measurement artifact changed: '+file);
  const summary=Object.fromEntries(['typed','upstream'].map(adapter=>{
    const timings=Object.fromEntries(['isolated','persistent'].map(mode=>{const values=rows.filter(row=>row.adapter===adapter&&row.mode===mode);return [mode,{wallMedianMs:median(values.map(row=>row.wallMs)),probeMedianMs:median(values.map(row=>row.probeMs))}];}));
    return [adapter,{...timings,wallRatio:timings.isolated.wallMedianMs/timings.persistent.wallMedianMs,probeRatio:timings.isolated.probeMedianMs/timings.persistent.probeMedianMs,exactModeAndOrderEquality:true,observations:observations.get(adapter)}];
  }));
  const firstReport=JSON.parse(fs.readFileSync(rows[0].report,'utf8'));
  const upstreamIdentity={revision:firstReport.inventory.revision,files:Object.fromEntries(['bend.ts','comp.ts','main.ts','base.bend'].map(file=>[file,digest(path.join(upstream,'bend2',file))]))};
  const fixtures=firstReport.inventory.tests.filter(test=>cases.includes(test.id)).map(test=>({id:test.id,file:test.file,sha256:test.sha256,negative:test.negative}));
  const result={schemaVersion:1,complete:true,preparedCache,upstreamIdentity,fixtures,purpose:'Selected isolated/persistent frontend worker comparison; not full conformance or a cross-compiler speedup claim',host:{node:process.execPath,nodeVersion:process.version,platform:process.platform,arch:process.arch,cpu,model:os.cpus()[cpu]?.model},config:{...config,project,upstream,api},recipe:[process.execPath,fileURLToPath(import.meta.url),configFile,output],sourceConfigSha256:digest(configFile),toolSha256:digest(fileURLToPath(import.meta.url)),frozenArtifactManifest:{file:path.join(output,'frozen-artifacts.json'),sha256:digest(path.join(output,'frozen-artifacts.json'))},keyArtifacts:Object.fromEntries(['dist/api.mjs','dist/base.bend','src/runtime.mjs','tools/typed-driver.mjs','tools/conformance/run.mjs','tools/conformance/replay.mjs','tools/conformance/persistent-probe.mjs','tools/conformance/persistent-worker.mjs','tools/conformance/adapters/typed.mjs','tools/conformance/adapters/upstream.mjs'].map(file=>[file,artifacts[file]])),limitations:['Small selected workload, three sequential repetitions by default, shared host CPU and memory contention remain possible.','The validated Base disk cache is prepared once outside timed cells and its digest checked after every cell; module compile disk caches are disabled.',
'Process wall includes inventory, identity hashing and report IO; probe sums include worker startup, framing, source loading and checking.','Requests are all parse/check; no mutable graph is intentionally shared. Negative diagnostic mismatches against fixture oracles remain visible.','Equality is exact within each adapter across modes/order, not between the two compiler implementations.'],rows,summary};
  save(path.join(output,'report.json'),result);return result;
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  const [config,output]=process.argv.slice(2);if(!config||!output)throw Error('Usage: node persistent-measure.mjs CONFIG.json NEW_OUTPUT_DIRECTORY');
  measure(path.resolve(config),path.resolve(output));
}
