// Root runs each invocation in a fresh guarded process. No clean timing claim.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import crypto from 'node:crypto';import {fileURLToPath,pathToFileURL} from 'node:url';
const ROOT=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../../../..');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=[],pins=new Map();
function pin(v){const i=identity(typeof v==='string'?v:v.file);if(typeof v==='object'){assert.equal(i.sha256,v.sha256);if(v.bytes!==undefined)assert.equal(fs.statSync(i.file).size,v.bytes);}if(!pins.has(i.file)){pins.set(i.file,i);inputs.push(i);}else assert.deepEqual(pins.get(i.file),i);return i;}
function read(v){return JSON.parse(fs.readFileSync(pin(v).file,'utf8'));}
function check(){for(const i of inputs)assert.deepEqual(identity(i.file),i);}
const [mode,inputFile,other,outArg]=process.argv.slice(2);
assert(['prepare','sample'].includes(mode)&&inputFile&&other&&outArg,'prepare ORIGINAL_PREP DERIVATION OUT | sample COUNTER_PREP CASE OUT');
assert.equal(process.version,'v24.18.0');
const out=path.resolve(outArg),boundary=path.join(ROOT,'selfhost/build/phase59')+path.sep;
assert(out.startsWith(boundary)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});assert.equal(fs.realpathSync(out),out);
const report={kind:'phase59-counter-request',complete:false,pass:false,mode,diagnosticOnly:true,checkedDerivative:false,cleanTiming:false,producer:pin(fileURLToPath(import.meta.url)),node:pin(process.execPath),requests:0,inputs};
let counters;
try{
 if(mode==='prepare'){
  const original=read(inputFile);assert.equal(original.kind,'phase59-candidate-image-library-worker');
  assert.equal(original.complete,true);assert.equal(original.pass,true);assert.equal(original.stage,'prepare');assert.equal(original.role,'direct');
  report.originalPreparation=pin(inputFile);const config=read(original.config),binding=read(config.imageBindings);
  for(const i of config.inputs)pin(i);
  assert.equal(original.image.api.sha256,'a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081');pin(original.image.api);
  const deriv=read(other);assert.equal(deriv.kind,'phase59-b2-counter-derivation');assert.equal(deriv.complete,true);assert.equal(deriv.pass,true);
  assert.equal(deriv.exactInverse,true);assert.equal(deriv.runtimePrefixUnchanged,true);assert.equal(deriv.targetExecuted,false);
  assert.equal(pin(deriv.parent).sha256,original.image.api.sha256);pin(deriv.producer);pin(deriv.output);for(const i of deriv.inputs)pin(i);
  report.derivation=pin(other);assert.equal(binding.roles.direct.kind,'direct');
  const modified={...binding,roles:{direct:binding.roles.direct,counters:{kind:'syntax',parentRole:'direct',derivation:report.derivation}},scope:'Diagnostic entry counters over genuine selected B2; no checked derivative or timing claim.'};
  const bindingsFile=path.join(out,'bindings.json');fs.writeFileSync(bindingsFile,JSON.stringify(modified,null,2)+'\n',{flag:'wx'});report.bindings=pin(bindingsFile);
  const setupFile=path.join(ROOT,'selfhost/build/phase59/latency-method01/setup.mjs');report.setup=pin(setupFile);
  const {setup}=await import(pathToFileURL(setupFile));const staged=await setup(bindingsFile,path.join(out,'stage'),{role:'counters'});
  assert.equal(staged.image.api.sha256,deriv.output.sha256);assert.equal(staged.image.source.sha256,original.image.source.sha256);
  for(const k of ['runtime','base','directRuntime','driver'])assert.equal(staged.image[k].sha256,original.image[k].sha256);
  await staged.D.prepareBase(staged.api);report.verification=await staged.verifyFinal();assert.equal(report.verification.cacheFiles.length,1);
  report.image={...staged.image,kind:'diagnostic-b2-counters'};report.subject=staged.subject;report.project=staged.project;report.copies=staged.copies;
  for(const i of staged.inputs)pin(i);for(const c of staged.copies)pin(c.after);for(const c of report.verification.cacheFiles)pin(c);
  report.outputs=original.outputs;for(const row of report.outputs){assert.equal(row.oracle.pass,true);assert.equal(row.observation.checked,true);assert.equal(row.observation.status,'ok');pin(row.source);pin(row.output);}
  report.scope='Fresh private cache primed by the diagnostic image, outside the subsequent first-request process. Original genuine output oracles retained; no measured user request here.';
 }else{
  const prep=read(inputFile);assert.equal(prep.kind,report.kind);assert.equal(prep.mode,'prepare');assert.equal(prep.complete,true);assert.equal(prep.pass,true);
  report.preparation=pin(inputFile);for(const i of prep.inputs)pin(i);for(const c of prep.copies)pin(c.after);for(const c of prep.verification.cacheFiles)pin(c);
  const deriv=read(prep.derivation);assert.equal(deriv.kind,'phase59-b2-counter-derivation');assert.equal(deriv.output.sha256,prep.image.api.sha256);
  const row=prep.outputs.find(x=>x.id===other);assert(row&&row.oracle.pass);pin(row.source);pin(row.output);const expected=fs.readFileSync(row.output.file);
  report.image=prep.image;report.source=row.source;report.expected=row.output;report.case=row.id;
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  process.env.BEND_TYPED_API=prep.image.api.file;process.env.BEND_TYPED_RUNTIME=prep.image.runtime.file;process.env.BEND_BASE=prep.image.base.file;
  const D=await import(pathToFileURL(prep.image.driver.file));assert.equal(D.apiPath,prep.image.api.file);assert.equal(D.directRuntimePath,prep.image.directRuntime.file);
  const api=await D.loadApi();counters=await import(pathToFileURL(prep.image.api.file));assert.equal(api,counters.default);
  const before=counters.phase59CounterSnapshot();assert.equal(before.active,false);
  for(const v of Object.values(before.stages))for(const n of Object.values(v))assert.equal(n,0);
  counters.phase59CounterReset();report.requests++;
  const result=await D.inspect(row.source.file,{mode:'library',backend:'direct'});
  assert.equal(result.status,'ok');assert.equal(result.checked,true);assert.equal(result.backend,'direct');assert.equal(result.interface,'upstream-callable');
  assert.equal(Buffer.compare(Buffer.from(result.code),expected),0,'Complete prepared output bytes');
  assert.deepEqual(result.files.map(f=>fs.realpathSync(f)).sort(),[row.source.file,prep.image.base.file,prep.image.directRuntime.file].sort());
  report.counters=counters.phase59CounterStop();const {code,...observation}=result;report.observation=observation;
  const output=path.join(out,'output.mjs');fs.writeFileSync(output,code,{flag:'wx'});report.output=pin(output);
  const cache=path.join(prep.project,'build/typed/cache');assert.deepEqual(fs.readdirSync(cache).sort(),prep.verification.cacheFiles.map(x=>path.basename(x.file)).sort());
  report.scope='Exactly one first ordinary D.inspect after API import, using a separately primed diagnostic-image private cache. Counts include that complete request; no profile or clean speed/physical-allocation claim.';
 }
 check();report.complete=report.pass=true;
}catch(e){report.error=String(e?.stack??e);if(counters)try{report.partialCounters=counters.phase59CounterStop();}catch(x){report.counterError=String(x);}process.exitCode=1;}
finally{report.maxRssKiB=process.resourceUsage().maxRSS;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});process.stdout.write(JSON.stringify({complete:report.complete,pass:report.pass,mode,case:report.case,error:report.error})+'\n');}
