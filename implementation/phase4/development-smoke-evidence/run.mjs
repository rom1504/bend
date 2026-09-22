import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnFileCapture} from '../../phase3/native-final/host/tools/performance/rapid/native-file-capture.mjs';
const root=path.resolve(import.meta.dirname,'../../..'),out=import.meta.dirname,upstream=fs.realpathSync(path.join(root,'.bootstrap/upstream'));
const sha=file=>crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const walk=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);
const inputs=[import.meta.filename,...walk(path.join(root,'tools')).filter(p=>p.endsWith('.mjs')||p.endsWith('.bend')),...walk(path.join(root,'src')),...walk(path.join(root,'tests/frontend/phase2-rules')),...['tests/conformance/bootstrap-provenance.test.mjs','tests/conformance/targeted.test.mjs','tests/conformance/selection.test.mjs','tests/conformance/persistent-worker.test.mjs','tests/node-resource-args.test.mjs'].map(p=>path.join(root,p))];
const identity=Object.fromEntries(inputs.map(p=>[p,sha(p)])),api=path.join(out,'api.mjs'),runtime=path.join(root,'src/runtime.mjs');
const env={...process.env,BEND_UPSTREAM:upstream,BEND_BASE:path.join(upstream,'bend2/base.bend'),BEND_TYPED_API:api,BEND_TYPED_RUNTIME:runtime};delete env.NODE_OPTIONS;
const defaults=['dist/typed-api.mjs','dist/typed-bootstrap-report.json'].map(p=>path.join(root,p));
const defaultHashes=Object.fromEntries(defaults.filter(p=>fs.existsSync(p)).map(p=>[p,sha(p)]));
const report={kind:'phase4-normal-development-smoke',complete:false,started:new Date().toISOString(),cpu:3,node:process.version,nodeSha256:sha(process.execPath),upstream,identity,defaultHashes,commands:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
async function run(name,args,timeout){
  const row={name,command:[process.execPath,...args],started:new Date().toISOString()},start=performance.now();report.commands.push(row);save();
  const r=await spawnFileCapture(process.execPath,args,{env,cwd:root,timeout,maxBuffer:16*1024*1024});
  fs.writeFileSync(path.join(out,name+'.stdout'),r.stdout);fs.writeFileSync(path.join(out,name+'.stderr'),r.stderr);
  Object.assign(row,{wallMs:performance.now()-start,status:r.status,signal:r.signal,error:r.error?.message,stdoutSha256:sha(path.join(out,name+'.stdout')),stderrSha256:sha(path.join(out,name+'.stderr')),finished:new Date().toISOString()});save();return r;
}
try{
  const tests=await run('tests',['--test','--test-isolation=none','tests/conformance/bootstrap-provenance.test.mjs','tests/conformance/targeted.test.mjs','tests/conformance/selection.test.mjs','tests/conformance/persistent-worker.test.mjs','tests/node-resource-args.test.mjs'],120000);
  report.testsPassed=tests.status===0&&!tests.error;
  const boot=await run('bootstrap',['--stack-size=4096','--max-old-space-size=4096','tools/typed-driver.mjs','--bootstrap'],180000);
  if(boot.status!==0||boot.error)throw Error('Normal bootstrap failed: '+(boot.error?.message||boot.stderr));
  const bootstrap=JSON.parse(fs.readFileSync(api+'.bootstrap.json'));
  if(!bootstrap.provenance?.verifiedAfterBuild||bootstrap.apiSha256!==sha(api))throw Error('Normal bootstrap provenance missing or changed');
  report.bootstrap={report:api+'.bootstrap.json',sha256:sha(api+'.bootstrap.json'),apiSha256:sha(api),apiBytes:fs.statSync(api).size,exports:bootstrap.exports.length,source:bootstrap.source,sourceSha256:bootstrap.sourceSha256};
  const count=await run('exports',['--input-type=module','-e',`const m=await import(${JSON.stringify(api)});console.log(JSON.stringify({namedExports:Object.keys(m).length,defaultExports:Object.keys(m.default??{}).length,names:Object.keys(m.default??{})}));`],30000);report.actualExports=JSON.parse(count.stdout);
  const config={upstream,api,runtime,bootstrapReport:api+'.bootstrap.json',selection:path.join(root,'tests/frontend/phase2-rules/cases.json'),cpu:3,workerMode:'persistent',jobs:1,recycleAfter:64,timeoutMs:30000,rssLimitMb:4096,stackKb:4096,heapMb:4096,retain:'all'};
  const cf=path.join(out,'target-config.json');fs.writeFileSync(cf,JSON.stringify(config,null,2)+'\n');
  const targeted=await run('target',['--stack-size=4096','--max-old-space-size=4096','tools/conformance/target.mjs',cf,path.join(out,'target')],180000);
  if(targeted.status!==0||targeted.error)throw Error('Normal paired target failed: '+(targeted.error?.message||targeted.stderr));
  report.paired=JSON.parse(fs.readFileSync(path.join(out,'target/paired.json')));
  report.changedInputs=Object.entries(identity).filter(([p,h])=>sha(p)!==h).map(([p])=>p);report.changedDefaults=Object.entries(defaultHashes).filter(([p,h])=>sha(p)!==h).map(([p])=>p);
  report.complete=report.testsPassed&&report.paired.selectedComplete&&report.changedInputs.length===0&&report.changedDefaults.length===0;
}catch(e){report.error=e.stack;process.exitCode=1;}finally{report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,error:report.error,output:out}));}
