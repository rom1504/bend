// Root-run Phase66 custom Base permission control. Actual checked B1 lineage,
// shared reviewed isolated host transforms, standard-vs-custom full module oracle.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [configArg,outArg]=process.argv.slice(2), root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg??'.');
assert(configArg&&out.startsWith(path.join(root,'selfhost/build/phase66')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),inputs=new Map();
function pin(file,expected){file=fs.realpathSync(file);const bytes=fs.readFileSync(file),p={file,sha256:hash(bytes),bytes:bytes.length};if(expected?.sha256)assert.equal(p.sha256,expected.sha256,file);if(expected?.canonicalPath!==undefined)assert.equal(file,expected.canonicalPath);if(expected?.bytes!==undefined)assert.equal(p.bytes,expected.bytes);if(inputs.has(file))assert.deepEqual(p,inputs.get(file));inputs.set(file,p);return p;}
const report={kind:'phase66-base-annotation-custom-base-owned-controls',complete:false,pass:false,diagnosticOnly:true,execution:{node:process.version,execArgv:process.execArgv},cases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
function array(xs){const values=[];while(xs?.$==='Con'){assert(values.length<65536);values.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return values;}
// Iterative whole-value equality includes every field and handles shared immutable DAGs.
function equalGraph(a,b){const queue=[[a,b]],seen=new WeakMap();let pairs=0;while(queue.length){const [x,y]=queue.pop();if(Object.is(x,y))continue;assert.equal(typeof x,typeof y);if(x===null||y===null||typeof x!=='object'){assert.deepEqual(x,y);continue;}let ys=seen.get(x);if(ys?.has(y))continue;if(!ys)seen.set(x,ys=new WeakSet());ys.add(y);assert(++pairs<=2000000,'Graph comparison budget');assert.equal(Array.isArray(x),Array.isArray(y));const keys=Object.keys(x).sort();assert.deepEqual(keys,Object.keys(y).sort());for(const k of keys)queue.push([x[k],y[k]]);}return pairs;}
try{
  pin(import.meta.filename);report.config=pin(configArg);const config=JSON.parse(fs.readFileSync(configArg,'utf8'));
  assert(config.sources?.length&&config.sources.length<=12);
  for(const p of config.provenance??[])pin(p.file,p);
  for(const name of ['api','driver','runtime','base','node']){assert(config.image[name]?.sha256);pin(config.image[name].file,config.image[name]);}
  assert.equal(pin(process.execPath).sha256,config.image.node.sha256);
  assert(config.checkedAttempt,'Actual checked B1 receipt required');pin(config.checkedAttempt.file,config.checkedAttempt);
  const read=file=>JSON.parse(fs.readFileSync(file,'utf8')),same=(a,b)=>{const x=pin(a.file,a),y=pin(b.file,b);assert.equal(x.file,y.file);assert.equal(x.sha256,y.sha256);};
  const attempt=read(config.checkedAttempt.file);assert.equal(attempt.kind,'bend-development-attempt');assert.equal(attempt.version,1);assert.equal(attempt.checked,true);assert.equal(attempt.artifactKind,'checked-b1');
  same(attempt.api,config.image.api);same(attempt.checkedApi,config.image.api);same(attempt.base,config.image.base);same(attempt.runtime,config.image.runtime);same(attempt.node,config.image.node);
  pin(attempt.bootstrapReport.file,attempt.bootstrapReport);const boot=read(attempt.bootstrapReport.file);
  assert.equal(boot.stage,'upstream-bootstrap');assert.equal(boot.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');assert.equal(boot.provenance.upstream.revision,boot.revision);assert.equal(boot.provenance.upstream.trackedSourcesClean,true);assert.equal(boot.provenance.verifiedAfterBuild,true);
  same({file:boot.apiPath,sha256:boot.apiSha256},config.image.api);assert.equal(boot.baseSha256,config.image.base.sha256);pin(boot.source,{sha256:boot.sourceSha256});
  for(const row of boot.provenance.inputs)pin(row.file,row);
  assert(boot.provenance.inputs.some(row=>row.role==='assembled-source'&&row.sha256===boot.sourceSha256));
  const driverSource=boot.provenance.inputs.find(row=>row.role==='host-tool'&&path.basename(row.file)==='typed-driver.mjs');assert(driverSource);same(driverSource,config.image.driver);
  assert.equal(fs.realpathSync(path.dirname(config.image.driver.file)),fs.realpathSync(path.join(attempt.snapshot.root,'tools')));
  for(const row of attempt.snapshot.sources)pin(row.frozen.file,row.frozen);
  const compilerManifest=read(path.join(attempt.snapshot.root,'src/compiler.json'));assert.equal(compilerManifest.upstream,boot.revision);assert.deepEqual(compilerManifest.modules,boot.modules.map(row=>row.file));
  for(const row of boot.modules){const frozen=attempt.snapshot.sources.find(item=>path.relative(attempt.snapshot.root,item.frozen.file)===row.file);assert(frozen);assert.equal(frozen.frozen.sha256,row.sha256);}
  assert.equal(boot.exports.length,99);assert.equal(new Set(boot.exports).size,99);
  let transformed=fs.readFileSync(config.image.driver.file,'utf8');
  for(const item of config.hostTransforms){pin(item.file,item);const transform=read(item.file);assert.equal(hash(transformed),transform.beforeSha256);for(const op of transform.operations){assert.equal(transformed.split(op.before).length,2);transformed=transformed.replace(op.before,op.after);}assert.equal(hash(transformed),transform.afterSha256);pin(transform.candidate,{sha256:transform.afterSha256});}
  pin(config.driverCandidate.file,config.driverCandidate);assert.equal(transformed,fs.readFileSync(config.driverCandidate.file,'utf8'));
  assert(transformed.includes("const BASE_ANNOTATION_BASE_SHA256='"+config.image.base.sha256+"';"));
  report.generation={kind:'checked-B1',attempt:config.checkedAttempt,bootstrap:attempt.bootstrapReport,source:{file:boot.source,sha256:boot.sourceSha256},api:config.image.api,hostTransforms:config.hostTransforms,candidate:config.driverCandidate,requestedExports:boot.exports};
  const project=path.join(out,'project'),originalProject=path.resolve(path.dirname(config.image.driver.file),'..');
  function copy(relative){const from=path.join(originalProject,relative),to=path.join(project,relative);pin(from);fs.mkdirSync(path.dirname(to),{recursive:true});fs.copyFileSync(from,to);pin(to,inputs.get(fs.realpathSync(from)));return to;}
  function copyTree(relative){for(const item of fs.readdirSync(path.join(originalProject,relative),{withFileTypes:true})){const next=path.join(relative,item.name);if(item.isDirectory())copyTree(next);else{assert(item.isFile());copy(next);}}}
  for(const file of ['typed-driver.mjs','assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs'])copy('tools/'+file);
  copy('src/compiler.json');copyTree('src/runtime/js');
  const clonedDriver=path.join(project,'tools/typed-driver.mjs');inputs.delete(fs.realpathSync(clonedDriver));fs.writeFileSync(clonedDriver,transformed);pin(clonedDriver,config.driverCandidate);
  const runtime=path.join(project,'src/runtime.mjs');fs.copyFileSync(config.image.runtime.file,runtime);pin(runtime,config.image.runtime);
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_'))delete process.env[key];
  const spec=config.sources.find(row=>row.id==='test-map-set-ops');assert(spec);pin(spec.file,spec);
  process.env.BEND_TYPED_API=config.image.api.file;process.env.BEND_TYPED_RUNTIME=runtime;process.env.BEND_BASE=config.image.base.file;
  const standardURL=pathToFileURL(clonedDriver);standardURL.search='standard-base';
  const Standard=await import(standardURL),standardApi=await Standard.loadApi();
  assert.equal(Standard.project,project);assert.equal(Standard.basePath,config.image.base.file);
  const standardPrepared=await Standard.prepareBase(standardApi,{backendProducts:false});assert.equal(standardPrepared.preparedWorld?.state?.ready,true);
  assert(!fs.existsSync(Standard.baseAnnotationDirectory),'Mandatory-only standard prime must not create optional products');
  const standard=await Standard.inspect(spec.file,{mode:'library',backend:'direct'});
  report.standardObservation={status:standard.status,phase:standard.phase,diagnostic:standard.diagnostic,checked:standard.checked};save();
  assert.equal(standard.status,'ok',standard.diagnostic);assert.equal(standard.checked,true);
  for(const file of standard.files)pin(file);
  const standardModule=path.join(out,'standard-map.mjs');fs.writeFileSync(standardModule,standard.code,{flag:'wx'});
  report.standardModule=pin(standardModule);save();
  const customBase=path.join(project,'src/runtime/js/custom-base.bend'),originalBase=fs.readFileSync(config.image.base.file);
  fs.writeFileSync(customBase,Buffer.concat([originalBase,Buffer.from('\n# Phase66 custom Base content permission control.\n')]),{flag:'wx'});
  const customIdentity=pin(customBase);assert.notEqual(customIdentity.sha256,config.image.base.sha256);
  assert.equal(fs.readFileSync(customBase).subarray(0,originalBase.length).equals(originalBase),true);
  process.env.BEND_TYPED_API=config.image.api.file;process.env.BEND_TYPED_RUNTIME=runtime;process.env.BEND_BASE=customBase;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs'))),mod=await import(pathToFileURL(config.image.api.file)),api=await D.loadApi();
  assert(!mod.G,'Named-layout B1/B2 required');assert.equal(api,mod.default,'Owned API identity');assert.equal(D.project,project);for(const name of boot.exports)assert.equal(typeof api[name],'function',name);report.generation.actualExportCount=Object.keys(api).length;
  assert.equal(D.basePath,customBase);
  const names=['base_annotation_prepare','base_annotation_wanted','base_annotation_allowed','annotate_selected_base','check_program_diagnostic_world','book_context_world'];
  const counts=Object.fromEntries(names.map(name=>[name,0])),original={};
  for(const name of names){assert.equal(typeof api[name],'function',name);original[name]=api[name];api[name]=(...args)=>{counts[name]++;return original[name](...args);};}
  report.customCounts=counts;save();
  const noSidecar=()=>assert(!fs.existsSync(D.baseAnnotationDirectory)||fs.readdirSync(D.baseAnnotationDirectory).length===0,'Custom Base created optional backend products');
  try{
    const first=await D.prepareBase(api);assert.equal(first.preparedWorld?.state?.ready,true,'Custom Base must otherwise admit ready world');
    assert.equal(counts.base_annotation_prepare,0);noSidecar();
    const second=await D.prepareBase(api);assert.equal(second.preparedWorld?.state?.ready,true);assert.equal(counts.base_annotation_prepare,0);noSidecar();
    const actual=await D.inspect(spec.file,{mode:'library',backend:'direct'});
    report.observation={status:actual.status,phase:actual.phase,diagnostic:actual.diagnostic,checked:actual.checked};
    assert.equal(actual.status,'ok',actual.diagnostic);assert.equal(actual.checked,true);assert.equal(actual.code,standard.code,'Comment-only custom Base changed the same-image ordinary Map module');
    assert.equal(counts.check_program_diagnostic_world,1);assert.equal(counts.book_context_world,1);
    for(const name of ['base_annotation_prepare','base_annotation_wanted','base_annotation_allowed','annotate_selected_base'])assert.equal(counts[name],0,name+' must remain undemanded');
    noSidecar();for(const file of actual.files)pin(file);
    report.customBase={original:config.image.base,derived:customIdentity,change:'append one inert comment',otherwiseReadyWorld:true,preparedTwice:true};
    report.counts=counts;report.optionalArtifactAbsent=true;report.output={sha256:hash(actual.code),bytes:Buffer.byteLength(actual.code),sameImageOrdinaryModuleExact:true};
  }finally{for(const name of names)api[name]=original[name];}
  for(const value of inputs.values())pin(value.file,value);
  report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();
