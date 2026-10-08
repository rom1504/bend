// Root-only paired runtime replay. No compiler invocation, installation or
// reinterpretation of the closed Node observations. Use the outer serial guard.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {spawn} from 'node:child_process';

const [typescriptArg,bendArg,acquisitionArg,bunArg,outArg,...extra]=process.argv.slice(2);
assert(typescriptArg&&bendArg&&acquisitionArg&&bunArg&&outArg&&!extra.length,
  'Usage: bun-replay-v1.mjs TS_REPORT BEND_REPORT ACQUISITION EXPLICIT_BUN_BINARY FRESH_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase66')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),inputs=new Map();
function pin(file,expected){file=fs.realpathSync(file);const data=fs.readFileSync(file),row={file,sha256:hash(data),bytes:data.length};if(expected?.sha256)assert.equal(row.sha256,expected.sha256,file);if(expected?.bytes!==undefined)assert.equal(row.bytes,expected.bytes,file);if(inputs.has(file))assert.deepEqual(row,inputs.get(file));inputs.set(file,row);return row;}
const read=file=>JSON.parse(fs.readFileSync(pin(file).file,'utf8'));
const report={kind:'phase66-paired-bun-runtime-replay',complete:false,pass:false,compilersExecuted:false,nodeResultsRewritten:false,cases:[],inputs:[]};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};save();
const missingFfi=/(?:Cannot find (?:module|package)|No such built-in module)[^\n]*['"]?bun:ffi/;
const platformExtras=new Map([
  ['base/read_bounds.bend','Bun libc error text differs from Node errno fallback'],
  ['io/file_open_mode.bend','Bun libc error text differs from Node errno fallback'],
  ['io/stderr_failure.bend','Bun libc error text differs from Node errno fallback'],
  ['io/process_run.bend','The provider uses Bun.spawnSync'],
  ['io/process_run_parallel.bend','The provider uses Bun.spawnSync'],
]);
const textOf=row=>String(row.result?.output??row.result?.diagnostic??((row.result?.stdout??'')+(row.result?.stderr??'')));
function walk(directory){return fs.readdirSync(directory,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>{assert(!e.isSymbolicLink());const p=path.join(directory,e.name);return e.isDirectory()?walk(p):(assert(e.isFile()),[p]);});}
function snapshot(directory){return walk(directory).map(file=>({relative:path.relative(directory,file),...pin(file)}));}
function copyTree(directory,target){const rows=snapshot(directory);fs.mkdirSync(target,{recursive:true});for(const row of rows){const to=path.join(target,row.relative);fs.mkdirSync(path.dirname(to),{recursive:true});fs.copyFileSync(row.file,to);pin(to,row);}return rows;}
async function execute(bun,module,directory,output){
  const limit=1024*1024,timeoutMs=10000,chunks=[];let bytes=0,timedOut=false,overflow=false,spawnError=null;
  const env={...process.env};for(const k of Object.keys(env))if(k.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH','BUN_OPTIONS'].includes(k))delete env[k];
  // One shared pipe preserves stdout/stderr write order, as the maintained
  // compiled-program adapter does. Positional shell arguments avoid interpolation.
  const child=spawn('/bin/sh',['-c','exec "$@" 2>&1','bun-replay',bun,module],{cwd:directory,env,detached:true,stdio:['ignore','pipe','pipe']});
  const kill=()=>{if(child.pid)try{process.kill(-child.pid,'SIGKILL');}catch(error){if(error.code!=='ESRCH')throw error;}};
  const collect=chunk=>{const available=limit-bytes;if(available>0)chunks.push(chunk.subarray(0,available));bytes+=chunk.length;if(bytes>limit&&!overflow){overflow=true;kill();}};
  child.stdout.on('data',collect);child.stderr.on('data',collect);
  const timer=setTimeout(()=>{timedOut=true;kill();},timeoutMs);
  const done=await new Promise(resolve=>{child.on('error',error=>{spawnError=String(error);});child.on('close',(code,signal)=>resolve({code,signal}));});
  clearTimeout(timer);kill();const text=Buffer.concat(chunks).toString('utf8');fs.writeFileSync(output,text,{flag:'wx'});
  const observation=timedOut?{status:'timeout',phase:'runtime',checked:true,reason:'Bun replay exceeded 10000ms',output:text,exitCode:done.code}:
    overflow||spawnError||done.signal?{status:'crash',phase:'runtime',checked:true,reason:overflow?'Bun replay output exceeded 1MiB':spawnError??('Signal '+done.signal),output:text,exitCode:done.code}:
    {status:done.code===0?'ok':'error',phase:'runtime',checked:true,typeAccepted:true,proofTrust:'not-assessed',kernelChecked:false,output:text,exitCode:done.code};
  return {command:[bun,module],shellForwarder:'/bin/sh -c exec "$@" 2>&1',cwd:directory,timeoutMs,outputLimitBytes:limit,observedBytes:bytes,timedOut,overflow,spawnError,exitCode:done.code,signal:done.signal,observation,output:pin(output)};
}
try{
  pin(import.meta.filename);pin(process.execPath);pin('/bin/sh');
  assert.equal(fs.readFileSync('/proc/self/status','utf8').match(/^Cpus_allowed_list:\s*(.+)$/m)?.[1],'3','Root must supply CPU3 affinity');
  const acquisition=read(acquisitionArg),bun=pin(bunArg);
  assert.equal(acquisition.kind,'phase66-official-bun-runtime-acquisition');assert.equal(acquisition.release,'bun-v1.4.2');
  assert.equal(bun.file,fs.realpathSync(acquisition.binary));assert.equal(bun.sha256,acquisition.binarySha256);assert.equal(bun.bytes,acquisition.binaryBytes);
  assert.equal(bun.sha256,'a83d263767d839e4d2649ca8e35d07159c7afc99afdc96d731ced29e056dda0c');
  const acquisitionDirectory=path.dirname(path.resolve(acquisitionArg));
  pin(path.join(acquisitionDirectory,'release.json'),{sha256:acquisition.releaseMetadataSha256});
  pin(path.join(acquisitionDirectory,'bun-linux-x64.zip'),{sha256:acquisition.zipSha256});assert.equal(acquisition.publishedDigest,'sha256:'+acquisition.zipSha256);
  report.runtime={acquisition:pin(acquisitionArg),binary:bun,release:acquisition.release,versionExecuted:false};
  const roles={};
  for(const [role,file] of [['typescript',typescriptArg],['bend',bendArg]]){
    const identity=pin(file),data=read(file);
    assert(data.finished&&data.results.length===1170&&data.selection.requested.length===1170,'Require closed full Node1170 report');
    assert.equal(data.inventory.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');
    assert.deepEqual(data.changedInputs,[]);assert.deepEqual(data.identity.changedArtifacts,[]);assert.equal(data.identity.adapterChangedDuringRun,false);
    const rows=new Map(data.results.map(row=>{assert.equal(row.lane,'js');return[row.id,row];}));assert.equal(rows.size,1170);
    assert.deepEqual([...rows.keys()].sort(),data.selection.requested.map(row=>{assert.equal(row.lane,'js');return row.id;}).sort());
    for(const [source,sha256] of Object.entries(data.inputHashes))pin(source,{sha256});
    for(const value of Object.values(data.identity.artifacts))pin(value.file,value);
    pin(data.options.adapter,{sha256:data.identity.adapterSha256});
    const project=path.resolve(path.dirname(data.options.adapter),'../../..');
    roles[role]={identity,data,rows,project};
  }
  assert.deepEqual([...roles.typescript.rows.keys()].sort(),[...roles.bend.rows.keys()].sort());
  const judgeFile=path.join(roles.bend.project,'tools/conformance/judge.mjs'),inventoryFile=path.join(roles.bend.project,'tools/conformance/inventory.mjs');
  report.judge={judge:pin(judgeFile),inventory:pin(inventoryFile),manifest:pin(path.join(roles.bend.project,'src/compiler.json'))};
  assert.equal(pin(path.join(roles.typescript.project,'tools/conformance/judge.mjs')).sha256,report.judge.judge.sha256);
  assert.equal(pin(path.join(roles.typescript.project,'tools/conformance/inventory.mjs')).sha256,report.judge.inventory.sha256);
  const {judge,rendered}=await import(pathToFileURL(judgeFile)),{describeFixture}=await import(pathToFileURL(inventoryFile));
  const selected=new Map();
  for(const [role,R] of Object.entries(roles))for(const row of R.rows.values())if(row.result?.phase==='runtime'&&row.result.checked===true&&missingFfi.test(textOf(row))){const reasons=selected.get(row.id)??[];reasons.push({role,reason:'Node runtime cannot load bun:ffi'});selected.set(row.id,reasons);}
  for(const [id,reason] of platformExtras){const row=roles.typescript.rows.get(id);assert(row&&row.status==='fail'&&row.result?.phase==='runtime'&&row.result.checked===true,'Authorized extra must remain an actual Node runtime mismatch');const reasons=selected.get(id)??[];reasons.push({role:'typescript',reason,explicitlyAuthorizedExtra:true});selected.set(id,reasons);}
  assert(selected.size>0);report.nodeReports=Object.fromEntries(Object.entries(roles).map(([role,R])=>[role,{identity:R.identity,summary:R.data.summary,complete:R.data.complete,selectedComplete:R.data.selectedComplete}]));
  report.selection={ids:[...selected.keys()].sort(),policy:'Union of exact Node missing-bun:ffi runtime outputs, plus five explicitly authorized platform mismatches. No NaN or other compiler failures admitted by this selector.',missingFfiRegex:missingFfi.source,extras:[...platformExtras]};save();
  const retainedInventories=[];
  for(const id of report.selection.ids){
    const row={id,reasons:selected.get(id),status:'pending',roles:{}};report.cases.push(row);save();
    const details={};
    for(const [role,R] of Object.entries(roles)){
      const previous=R.rows.get(id),artifacts=previous.artifacts;
      assert(artifacts&&fs.statSync(artifacts).isDirectory(),'Retained artifact directory missing for '+role+' '+id);
      const request=read(path.join(artifacts,'request.json'));assert.equal(request.test.id,id);assert.equal(request.lane,'js');assert.equal(fs.realpathSync(request.project),fs.realpathSync(R.project));
      const source=pin(request.test.file,request.test),test=describeFixture(source.file,id);
      assert.equal(test.sha256,request.test.sha256);assert.equal(test.expected,request.test.expected);assert.equal(test.negative,request.test.negative);
      const inventoryTest=R.data.inventory.tests.find(t=>t.id===id);assert(inventoryTest);assert.equal(inventoryTest.sha256,test.sha256);assert.equal(inventoryTest.expected,test.expected);
      const response=read(path.join(artifacts,'response.json'));assert.deepEqual(response,previous.result);
      const module=path.join(artifacts,path.basename(id,'.bend')+(role==='typescript'?'.cjs':'.mjs'));
      const recorded=snapshot(artifacts);retainedInventories.push({directory:artifacts,files:recorded});
      details[role]={test,module:fs.existsSync(module)?module:null,artifacts,checkedRuntime:previous.result?.checked===true&&previous.result?.phase==='runtime'};
      row.roles[role]={nodeStatus:previous.status,nodeObservation:previous.result,source,expected:test.expected,artifactFiles:recorded,module:fs.existsSync(module)?pin(module):null};
    }
    assert.equal(details.typescript.test.sha256,details.bend.test.sha256);assert.equal(details.typescript.test.expected,details.bend.test.expected);
    const source=fs.readFileSync(details.bend.test.file,'utf8');
    if(id.startsWith('gfx/')||/\b(?:Window|Audio)\./.test(source)){
      row.status='deferred-environment';row.reason='Selected graphics/window/audio rows are deferred without execution, even if a particular path might avoid opening a device; not counted as passed.';save();continue;
    }
    if(Object.values(details).some(d=>d.module===null||!d.checkedRuntime)){
      row.status='no-paired-replay';row.reason='At least one role lacks a retained emitted module with checked runtime provenance; neither program is recompiled or silently substituted.';save();continue;
    }
    const index=String(report.cases.length-1).padStart(3,'0');
    for(const role of report.cases.length%2?['typescript','bend']:['bend','typescript']){
      const d=details[role],directory=path.join(out,index+'-'+id.replaceAll('/','_'),role),work=path.join(directory,'artifacts');
      copyTree(d.artifacts,work);row.roles[role].clone=work;save();
      const module=path.join(work,path.basename(d.module));
      const execution=await execute(bun.file,module,work,path.join(directory,'combined-output.txt'));
      const verdict=judge(d.test,'js',execution.observation,roles[role].data.identity.capabilities);
      row.roles[role].execution=execution;row.roles[role].judgment=verdict;row.roles[role].rendered=rendered(execution.observation);save();
    }
    row.status=Object.values(row.roles).every(r=>r.judgment.status==='pass')?'pass':'fail';save();
  }
  for(const prior of retainedInventories)assert.deepEqual(snapshot(prior.directory),prior.files,'Retained Node artifacts changed');
  for(const value of inputs.values())pin(value.file,value);
  report.inputsUnchanged=true;report.complete=true;
  report.summary={selected:report.cases.length,paired:report.cases.filter(r=>Object.values(r.roles).every(x=>x.execution)).length,actions:report.cases.reduce((n,r)=>n+Object.values(r.roles).filter(x=>x.execution).length,0),statuses:Object.fromEntries(['pass','fail','deferred-environment','no-paired-replay'].map(status=>[status,report.cases.filter(r=>r.status===status).length]))};
  report.pass=report.cases.every(row=>row.status==='pass');
  report.scope='Finite paired Bun execution of already checked and emitted Node-campaign modules, using original frozen fixture judge. Separate runtime evidence; original Node failures/unsupported outcomes remain unchanged. Deferred and unpaired cases are not passes.';
}catch(error){report.error={name:error?.name,message:String(error?.message??error),stack:error?.stack};}
save();if(!report.complete||!report.pass)process.exitCode=1;console.log(JSON.stringify({complete:report.complete,pass:report.pass,summary:report.summary,error:report.error}));
