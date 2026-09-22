import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'../../..'),out=import.meta.dirname,launchFile=path.join(root,'build/phase4/combined-launch.json');
const read=p=>JSON.parse(fs.readFileSync(p)),sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const launch=read(launchFile),checked=read(launch.checked);
if(!checked.complete||!checked.inputsUnchanged||sha(launch.source.file)!==launch.source.sha256||sha(launch.api.file)!==launch.api.sha256)throw Error('Combined checked compiler identity differs');
const sourceRoot=path.join(out,'source-root'),host=path.join(out,'host');fs.mkdirSync(sourceRoot);fs.mkdirSync(host);
const report={kind:'phase4-final-native-integration',complete:false,started:new Date().toISOString(),cpu:3,node:{file:process.execPath,version:process.version,sha256:sha(process.execPath)},launch:{file:launchFile,sha256:sha(launchFile)},checked:{file:launch.checked,sha256:sha(launch.checked)},source:launch.source,api:launch.api,runtime:{file:launch.runtime,sha256:sha(launch.runtime)},base:{file:launch.base,sha256:sha(launch.base)},modules:[],tools:[],adaptations:[],commands:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function copy(source,relative,base=host){const target=path.join(base,relative);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(source,target);return {source,target,sha256:sha(source)};}
for(const m of checked.modules){if(sha(m.destination)!==m.sha256||sha(path.join(root,m.relative))!==m.sha256)throw Error('Combined module differs: '+m.relative);report.modules.push(copy(m.destination,m.relative,sourceRoot));}
const manifest=path.join(root,'src/compiler.json'),manifestInput=checked.inputs.find(x=>x.file.endsWith('/src/compiler.json'));
if(!manifestInput||sha(manifest)!==manifestInput.sha256)throw Error('Module manifest differs');
report.modules.push(copy(manifest,'src/compiler.json',sourceRoot),copy(launch.runtime,'src/runtime.mjs',sourceRoot));
for(const item of launch.hostFiles){if(sha(item.path)!==item.sha256)throw Error('Combined host changed');const rel=path.relative(path.dirname(path.dirname(launch.driver)),item.path);report.tools.push(copy(item.path,rel));}
for(const name of ['native-bundle-prepare.mjs','native-bundle.bend','native-graph.bend','native-component.mjs','native-compiler-cache.mjs','native-graph-api.mjs','native-graph-fixtures.mjs'])report.tools.push(copy(path.join(root,'tools/performance/rapid',name),'tools/performance/rapid/'+name));
const prior=path.join(root,'build/phase3/native-final/host/tools/performance/rapid');
for(const name of ['native-file-capture.mjs','native-graph-run.mjs','native-graph-validate.mjs'])report.tools.push(copy(path.join(prior,name),'tools/performance/rapid/'+name));
// Keep the already tested native launcher/validator file capture adaptation.
// The checker itself uses the unchanged pinned compiler and all original gates.
const component=path.join(host,'tools/performance/rapid/native-component.mjs');let text=fs.readFileSync(component,'utf8');
const originalSha=sha(component);fs.writeFileSync(path.join(out,'native-component.original.mjs'),text);
text=text.replace("import {spawnSync} from 'node:child_process';","import {spawnFileCapture as spawnSync} from './native-file-capture.mjs';").replaceAll('= spawnSync(', '= await spawnSync(');
text=text.replace('if (revision.status !== 0 ||','if (revision.error || revision.signal || revision.status !== 0 ||').replace('if (status.status !== 0 ||','if (status.error || status.signal || status.status !== 0 ||');
fs.writeFileSync(component,text);report.adaptations.push({file:component,originalSha256:originalSha,consumedSha256:sha(component),scope:'Attempt-local asynchronous file capture for git/affinity queries, retaining strict errors/signals/status/pin/clean checks.'});
const capture=path.join(host,'tools/performance/rapid/native-file-capture.mjs');const {spawnFileCapture}=await import(pathToFileURL(capture));
const sequence=read(path.join(root,'build/phase3/native-final/build-sequence.json'));const env={...process.env,...sequence.environment};delete env.NODE_OPTIONS;
report.environment=sequence.environment;report.consumedToolHashes=Object.fromEntries(report.tools.map(t=>[t.target,sha(t.target)]));report.toolSha256=sha(import.meta.filename);save();
async function run(name,script,args,timeoutMs){
 const command=['taskset','-c','3',process.execPath,'--stack-size=4096','--max-old-space-size=4096',script,...args],start=performance.now(),row={name,command,timeoutMs,started:new Date().toISOString()};report.commands.push(row);save();console.log('START '+name);
 const result=await spawnFileCapture(command[0],command.slice(1),{env,cwd:root,timeout:timeoutMs,maxBuffer:32*1024*1024});
 const stdout=path.join(out,name+'.stdout'),stderr=path.join(out,name+'.stderr');fs.writeFileSync(stdout,result.stdout);fs.writeFileSync(stderr,result.stderr);
 Object.assign(row,{wallMs:performance.now()-start,status:result.status,signal:result.signal,error:result.error?.message,stdout,stderr,stdoutSha256:sha(stdout),stderrSha256:sha(stderr),finished:new Date().toISOString()});save();
 if(result.error||result.signal||result.status!==0)throw Error(name+' failed: '+(result.error?.message||result.stderr));console.log('DONE '+name);return result;
}
try{
 const rapid=path.join(host,'tools/performance/rapid');
 await run('prepare',path.join(rapid,'native-bundle-prepare.mjs'),[sourceRoot,path.join(out,'snapshot')],30000);
 await run('checked-emission',component,[path.join(out,'snapshot/compiler.bend'),path.join(out,'checked'),'--js'],180000);
 await run('cache-miss',path.join(rapid,'native-compiler-cache.mjs'),[path.join(out,'checked/program.c'),path.join(out,'compiler-o2'),path.join(out,'cache'),'--opt=O2','--timeout-ms=300000'],310000);
 await run('cache-hit',path.join(rapid,'native-compiler-cache.mjs'),[path.join(out,'checked/program.c'),path.join(out,'compiler-o2-hit'),path.join(out,'cache'),'--opt=O2','--timeout-ms=30000'],40000);
 if(sha(path.join(out,'compiler-o2'))!==sha(path.join(out,'compiler-o2-hit')))throw Error('Native cache hit bytes differ');
 await run('expose',path.join(rapid,'native-graph-api.mjs'),[path.join(out,'checked'),path.join(out,'api')],30000);
 const validation={...read(path.join(root,'build/phase3/native-final/validation-config.json')),binary:path.join(out,'compiler-o2'),api:path.join(out,'api/api.mjs'),base:launch.base,runtime:launch.runtime,cpu:3};
 fs.writeFileSync(path.join(out,'validation-config.json'),JSON.stringify(validation,null,2)+'\n');
 await run('semantic',path.join(rapid,'native-graph-validate.mjs'),[path.join(out,'validation-config.json'),path.join(out,'validation')],240000);
 const manifest={main:launch.source.file,base:launch.base,modules:[],assets:[]};fs.writeFileSync(path.join(out,'compiler-manifest.json'),JSON.stringify(manifest,null,2)+'\n');
 const full=await run('fullsource',path.join(rapid,'native-graph-run.mjs'),[path.join(out,'compiler-o2'),path.join(out,'compiler-manifest.json'),launch.runtime,path.join(out,'compiler-library.mjs'),'library','--cpu=3','--timeout-ms=600000'],620000);
 report.fullsource=JSON.parse(full.stdout);if(!report.fullsource.published)throw Error('Full compiler source was not emitted');
 await run('syntax','--check',[path.join(out,'compiler-library.mjs')],30000);
 report.changedTools=Object.entries(report.consumedToolHashes).filter(([p,h])=>sha(p)!==h).map(([p])=>p);
 report.changedModules=report.modules.filter(m=>sha(m.target)!==m.sha256).map(m=>m.target);
 if(report.changedTools.length||report.changedModules.length)throw Error('Consumed native snapshot changed');
 report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}finally{report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,error:report.error,report:path.join(out,'report.json')}));}
