// Ordinary final JS B2 C requests. Preparation/oracle work is a separate job.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [planFile,action,name,outArg]=process.argv.slice(2),out=path.resolve(outArg);
assert(['prepare','request'].includes(action));fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:hash(b),bytes:b.length};};
const verify=p=>{const actual=pin(p.file);assert.equal(actual.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(actual.bytes,p.bytes,p.file);return actual;};
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const plan=read(planFile),role=plan.b2;
const report={kind:'phase90-final-js-b2-screen-job',complete:false,pass:false,action,
  plan:pin(planFile),method:pin(import.meta.filename),node:process.version,v8:process.versions.v8,
  execArgv:process.execArgv,calls:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
const cacheFiles=()=>[path.join(role.project,'build/typed/cache'),path.join(role.project,'build/typed/base-products')]
  .flatMap(dir=>fs.existsSync(dir)?fs.readdirSync(dir).sort().filter(n=>n.includes(role.api.sha256)&&n.includes(role.base.sha256)).map(n=>pin(path.join(dir,n))):[]);
try{
  const validationStarted=performance.now();
  assert.equal(plan.kind,'phase90-final-compiler-six-case-plan');
  // These are the selected execution inputs, not the full historical provenance.
  role.selectedInputs.forEach(verify);
  const pins=read(verify(role.imagePins).file);assert.equal(pins.kind,'phase56-direct-image-pins');
  assert.equal(pins.b2.sha256,role.api.sha256);assert.equal(pins.attempt.sha256,role.attempt.sha256);
  assert.equal(pins.b1.sha256,role.generator.sha256);assert.equal(fs.realpathSync(process.execPath),plan.node.file);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH'].includes(key))delete process.env[key];
  process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
  if(action==='request'){
    assert(plan.preparation&&role.cache?.length);
    verify(plan.preparation);role.cache.forEach(verify);assert.deepEqual(cacheFiles(),role.cache);
  }
  report.inputValidationMs=performance.now()-validationStarted;
  const imported=performance.now();const D=await import(pathToFileURL(role.driver.file));const api=await D.loadApi();
  report.importsMs=performance.now()-imported;
  assert.equal(D.apiPath,role.api.file);assert.equal(D.driverPath,role.driver.file);
  assert.equal(D.basePath,role.base.file);assert.equal(D.runtimePath,role.runtime.file);
  assert.equal(D.project,role.project);
  if(action==='prepare'){
    report.cacheBefore=cacheFiles();const start=performance.now();await D.prepareBase(api);
    report.basePreparationMs=performance.now()-start;report.cache=cacheFiles();assert(report.cache.length>0);
  }
  const cases=action==='prepare'?Object.keys(plan.cases):[name];
  for(const caseName of cases){
    const source=plan.cases[caseName];assert(source);verify(source.input);
    const start=performance.now();const result=await D.inspect(source.input.file,{mode:'native',withReport:true});
    const requestMs=performance.now()-start;const validationStarted=performance.now();const {code,...observation}=result;
    assert.equal(observation.status,'ok');assert.equal(observation.checked,true);assert.equal(typeof code,'string');
    const file=path.join(out,caseName+'.c');fs.writeFileSync(file,code,{flag:'wx'});const output=pin(file);
    assert(output.bytes>0&&output.bytes<=64*1024**2);
    const row={case:caseName,requestMs,observation,output,basePreparationMs:null,
      timingScope:action==='prepare'?'Untimed setup oracle; ordinary request in shared preparation process.':
        'One ordinary request in a fresh Node process; API-specific prepared Base decoding is inside requestMs.'};
    row.requestInputs=(observation.files??[]).map(pin);
    for(const p of row.requestInputs)assert(plan.requestInputs.some(i=>i.file===p.file&&i.sha256===p.sha256),'Unfrozen request input '+p.file);
    if(action==='request'){
      verify(source.b2Oracle);assert.equal(output.sha256,source.b2Oracle.sha256);assert.equal(output.bytes,source.b2Oracle.bytes);
      assert(fs.readFileSync(file).equals(fs.readFileSync(source.b2Oracle.file)));row.exactC=true;
    }
    row.outputValidationMs=performance.now()-validationStarted;report.calls.push(row);save();
  }
  const verificationStarted=performance.now();
  role.selectedInputs.forEach(verify);
  if(action==='request'){role.cache.forEach(verify);assert.deepEqual(cacheFiles(),role.cache);}
  else {assert.deepEqual(cacheFiles(),report.cache);report.cache.forEach(verify);}
  report.finalVerificationMs=performance.now()-verificationStarted;
  report.inputsUnchanged=true;report.maxRssKiB=process.resourceUsage().maxRSS;report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,action,importsMs:report.importsMs,
  basePreparationMs:report.basePreparationMs,requestMs:report.calls.map(r=>r.requestMs),error:report.error}));
