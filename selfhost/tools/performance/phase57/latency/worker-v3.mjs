// Diagnostic successor: preserve trace markers and use bounded signed-delta profiler summary.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {setup} from '../setup.mjs';
import {profile} from '../profile-v2.mjs';
import {identity,verify as verifyIdentity,hash} from '../../phase54/bootstrap/adapter.mjs';

const entered=performance.now(),[requestFile,resultFile]=process.argv.slice(2);
assert.ok(requestFile&&resultFile&&!fs.existsSync(resultFile));
const request=JSON.parse(fs.readFileSync(requestFile,'utf8'));
const config=JSON.parse(fs.readFileSync(request.config.file,'utf8'));
const report={kind:'phase57-four-image-library-worker',complete:false,pass:false,
  stage:request.stage,role:request.role,mode:config.mode,request:identity(requestFile),config:request.config,
  node:process.version,execArgv:process.execArgv,
  affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
const traceMarker=(event,phase,index=null)=>{
  if(config.mode!=='trace'||request.stage!=='sample')return;
  const marker={event,phase,index,monotonicMs:performance.now(),wallTime:new Date().toISOString(),role:request.role,case:request.case};
  report.traceWindows??=[];
  if(event==='begin')report.traceWindows.push({phase,index,begin:marker});
  else {
    const window=report.traceWindows.at(-1);
    assert.ok(window&&window.phase===phase&&window.index===index&&!window.end,'Unpaired trace marker');
    window.end=marker;
  }
  fs.writeSync(1,'BEND_PHASE57_TRACE '+JSON.stringify(marker)+'\n');
};
const verify=item=>{verifyIdentity({file:item.file,sha256:item.sha256});
  if(item.bytes!==undefined)assert.equal(fs.statSync(item.file).size,item.bytes)};
const check=items=>{for(const item of items)verify(item)};
let staged,D,B,C;
async function load(image) {
  if(request.role==='typescript') {
    B=await import(pathToFileURL(path.join(config.upstream,'bend2/bend.ts')));
    C=await import(pathToFileURL(path.join(config.upstream,'bend2/comp.ts')));
  } else {
    for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
    process.env.BEND_TYPED_API=image.api.file;process.env.BEND_TYPED_RUNTIME=image.runtime.file;
    process.env.BEND_BASE=image.base.file;
    if(config.mode==='trace'&&request.stage==='sample')process.env.BEND_TYPED_TRACE='1';
    D=await import(pathToFileURL(image.driver.file));
    assert.equal(D.apiPath,image.api.file);assert.equal(D.directRuntimePath,image.directRuntime.file);
  }
}
async function compile(row) {
  if(request.role==='typescript') {
    const book=B.book_nil();await B.book_load(book,row.source.file,'',new Map());B.book_valid(book);
    assert.equal(book.hols,0);return {code:C.js_lib(book,true),observation:{checked:true,holes:book.hols,backend:'upstream'}};
  }
  // No API override or persistent inspector: each ordinary request creates its own book.
  const result=await D.inspect(row.source.file,{mode:'library',backend:'direct'});
  assert.equal(result.status,'ok');assert.equal(result.checked,true);
  assert.equal(result.backend,'direct');assert.equal(result.interface,'upstream-callable');
  const {code,...observation}=result;return {code,observation};
}
function saveCode(file,code) {
  assert.equal(typeof code,'string');assert.ok(code.length>0);
  if(request.role!=='typescript')assert.ok(code.startsWith(fs.readFileSync(D.directRuntimePath,'utf8')+'\n'));
  fs.writeFileSync(file,code,{flag:'wx'});return {...identity(file),bytes:Buffer.byteLength(code)};
}
try {
  verify(request.config);check(config.inputs);
  assert.equal(config.kind,'phase57-four-image-library-plan');
  assert.ok(config.roles.includes(request.role));assert.ok(['prepare','sample'].includes(request.stage));
  const preflight=performance.now();
  if(request.stage==='prepare') {
    if(request.role!=='typescript') {
      staged=await setup(config.imagePins.file,path.join(request.out,'stage'),{role:request.role});
      D=staged.D;report.image=staged.image;report.subject=staged.subject;
      const prime=performance.now();await D.prepareBase(staged.api);report.basePrimeMs=performance.now()-prime;
      report.project=staged.project;
    } else {await load();report.upstreamCommit=config.upstreamCommit;}
    report.preflightMs=performance.now()-preflight;report.outputs=[];
    for(const row of config.cases) {
      const result=await compile(row),output=saveCode(path.join(request.out,row.id+'.mjs'),result.code);
      const mod=await import(pathToFileURL(output.file)),fn=mod.default?.[row.point.exportName];
      assert.equal(typeof fn,'function');const value=fn(...row.point.args);
      assert.ok(Object.is(value,row.point.expected),'Full catalog oracle: '+row.id);
      report.outputs.push({id:row.id,source:row.source,output,observation:result.observation,
        oracle:{point:row.point,value,pass:true}});
    }
    if(staged) {
      report.verification=await staged.verifyFinal();assert.equal(report.verification.cacheFiles.length,1);
      report.inputs=staged.inputs;report.copies=staged.copies;
    }
  } else {
    verify(request.preparation);const prep=JSON.parse(fs.readFileSync(request.preparation.file,'utf8'));
    assert.equal(prep.kind,report.kind);assert.equal(prep.stage,'prepare');assert.equal(prep.role,request.role);
    assert.equal(prep.complete,true);assert.equal(prep.pass,true);verify(prep.config);
    const oldConfig=JSON.parse(fs.readFileSync(prep.config.file,'utf8'));check(oldConfig.inputs);
    for(const key of ['kind','imagePins','upstream','upstreamCommit','node'])assert.deepEqual(oldConfig[key],config[key]);
    report.preparation=request.preparation;report.image=prep.image;report.sample=request.sample;
    const bindings=[...(prep.inputs??[]),...(prep.copies??[]).map(x=>x.after),...(prep.verification?.cacheFiles??[])];
    check(bindings);
    const row=config.cases.find(x=>x.id===request.case);assert.ok(row);
    assert.deepEqual(oldConfig.cases.find(x=>x.id===row.id),row);
    const expected=prep.outputs.find(x=>x.id===row.id);assert.ok(expected?.oracle.pass);
    verify(expected.output);report.source=row.source;report.expected=expected.output;
    const expectedBytes=fs.readFileSync(expected.output.file);
    function validate(result) {
      const bytes=Buffer.from(result.code);assert.equal(bytes.compare(expectedBytes),0,'Prepared checked output changed');
      if(request.role!=='typescript') {
        const files=result.observation.files.map(f=>fs.realpathSync(f)).sort();
        assert.deepEqual(files,[row.source.file,prep.image.base.file,prep.image.directRuntime.file].sort());
      }
      return {sha256:hash(bytes),bytes:bytes.length};
    }
    report.preflightMs=performance.now()-preflight;
    traceMarker('begin','host-import');
    const imported=performance.now();await load(prep.image);report.hostImportMs=performance.now()-imported;
    traceMarker('end','host-import');
    traceMarker('begin','api-load');
    const apiStart=performance.now();
    if(request.role!=='typescript')await D.loadApi();
    report.apiLoadMs=request.role==='typescript'?0:performance.now()-apiStart;
    traceMarker('end','api-load');
    report.apiLoadScope=request.role==='typescript'?'Compiler imports included in hostImportMs':'Ordinary D.loadApi, including ABI checks/adaptation';
    traceMarker('begin','first-request');
    const begin=performance.now();let first;
    try {first=await compile(row)} finally {report.firstRequestMs=performance.now()-begin;traceMarker('end','first-request')}
    report.importApiAndFirstMs=report.hostImportMs+report.apiLoadMs+report.firstRequestMs;
    report.observation=first.observation;validate(first);report.output=saveCode(request.output,first.code);first=null;
    report.warmRequests=[];
    for(let i=0;i<config.warmRequests;i++) {
      traceMarker('begin','warm-request',i);
      const begin=performance.now(),result=await compile(row),requestMs=performance.now()-begin;
      traceMarker('end','warm-request',i);
      report.warmRequests.push({index:i,requestMs,output:validate(result)});
    }
    report.cleanTiming=config.mode==='clean';
    if(config.mode!=='clean') {
      const run=async()=>{const result=await compile(row);return validate(result)};
      if(config.mode==='trace') {
        report.traceRequests=[];const begin=performance.now();
        do {
          const index=report.traceRequests.length;traceMarker('begin','trace-request',index);
          const start=performance.now(),output=await run(),requestMs=performance.now()-start;
          traceMarker('end','trace-request',index);report.traceRequests.push({requestMs,output});
        }
        while(performance.now()-begin<config.profile.targetMs&&report.traceRequests.length<config.profile.maxRequests);
        report.traceMs=performance.now()-begin;
      } else report.profile=await profile({mode:config.mode,run,out:request.profileOut,...config.profile,
        moduleUrl:pathToFileURL(request.role==='typescript'?path.join(config.upstream,'bend2/comp.ts'):prep.image.api.file).href});
    }
    if(request.role!=='typescript') {
      const directory=path.join(prep.project,'build/typed/cache');
      assert.deepEqual(fs.readdirSync(directory).sort(),prep.verification.cacheFiles.map(x=>path.basename(x.file)).sort());
    }
    check(bindings);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);
  }
  check(config.inputs);verify(request.config);report.complete=report.pass=true;
} catch(error) {report.error=String(error?.stack??error);process.exitCode=1;}
finally {
  report.workerElapsedMs=performance.now()-entered;report.maxRssKiB=process.resourceUsage().maxRSS;
  fs.writeFileSync(resultFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({complete:report.complete,pass:report.pass,role:report.role,stage:report.stage,mode:report.mode,error:report.error}));
}
