// Phase30 timing boundaries, with honest B1/B2 staging instead of a fake B2 attempt.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {setup} from '../bootstrap/setup-v2.mjs';
import {identity,verify as verifyIdentity} from '../../phase54/bootstrap/adapter.mjs';

const entered=performance.now(),[requestFile,resultFile]=process.argv.slice(2);
assert.ok(requestFile&&resultFile&&!fs.existsSync(resultFile));
const request=JSON.parse(fs.readFileSync(requestFile,'utf8'));
const config=JSON.parse(fs.readFileSync(request.config.file,'utf8'));
const report={kind:'phase56-checked-library-latency-worker',complete:false,pass:false,
  stage:request.stage,role:request.role,request:identity(requestFile),config:request.config,
  node:process.version,execArgv:process.execArgv,
  affinity:fs.readFileSync('/proc/self/status','utf8').split('\n').find(x=>x.startsWith('Cpus_allowed_list:'))};
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
    D=await import(pathToFileURL(image.driver.file));
    assert.equal(D.apiPath,image.api.file);assert.equal(D.directRuntimePath,image.directRuntime.file);
  }
}
async function compile(row) {
  if(request.role==='typescript') {
    const book=B.book_nil();await B.book_load(book,row.source.file,'',new Map());B.book_valid(book);
    assert.equal(book.hols,0);return {code:C.js_lib(book,true),observation:{checked:true,holes:book.hols,backend:'upstream'}};
  }
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
  assert.equal(config.kind,'phase56-three-role-library-latency-plan');
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
    assert.equal(prep.complete,true);assert.equal(prep.pass,true);assert.deepEqual(prep.config,request.config);
    report.preparation=request.preparation;report.image=prep.image;report.sample=request.sample;
    const bindings=[...(prep.inputs??[]),...(prep.copies??[]).map(x=>x.after),...(prep.verification?.cacheFiles??[])];
    check(bindings);
    const row=config.cases.find(x=>x.id===request.case);assert.ok(row);
    const expected=prep.outputs.find(x=>x.id===row.id);assert.ok(expected?.oracle.pass);
    verify(expected.output);report.source=row.source;report.expected=expected.output;
    report.preflightMs=performance.now()-preflight;
    const imported=performance.now();await load(prep.image);report.hostImportMs=performance.now()-imported;
    const begin=performance.now();let result;
    try {result=await compile(row)} finally {report.requestMs=performance.now()-begin}
    report.importAndRequestMs=report.hostImportMs+report.requestMs;
    report.observation=result.observation;report.output=saveCode(request.output,result.code);
    assert.equal(report.output.sha256,expected.output.sha256,'Prepared checked output changed');
    if(request.role!=='typescript') {
      const files=result.observation.files.map(f=>fs.realpathSync(f)).sort();
      assert.deepEqual(files,[row.source.file,prep.image.base.file,prep.image.directRuntime.file].sort());
      const directory=path.join(prep.project,'build/typed/cache');
      assert.deepEqual(fs.readdirSync(directory).sort(),prep.verification.cacheFiles.map(x=>path.basename(x.file)).sort());
    }
    check(bindings);verify(request.preparation);verify(expected.output);
  }
  check(config.inputs);verify(request.config);report.complete=report.pass=true;
} catch(error) {report.error=String(error?.stack??error);process.exitCode=1;}
finally {
  report.workerElapsedMs=performance.now()-entered;report.maxRssKiB=process.resourceUsage().maxRSS;
  fs.writeFileSync(resultFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({complete:report.complete,pass:report.pass,role:report.role,stage:report.stage,error:report.error}));
}
