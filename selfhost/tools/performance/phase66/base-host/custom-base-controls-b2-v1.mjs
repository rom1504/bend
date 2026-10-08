// Root-run Phase66 genuine-B2 custom Base permission control. Full image lineage,
// exact unchanged snapshot host, standard-vs-custom full module oracle.
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
  // The same genuine B2 joins used by the maintained final-plan reuse gate.
  assert(config.imagePins,'Genuine B2 requires completed emission lineage');pin(config.imagePins.file,config.imagePins);
  const read=file=>JSON.parse(fs.readFileSync(file,'utf8')),identity=p=>({file:fs.realpathSync(p.file),sha256:p.sha256});
  const same=(a,b)=>{pin(a.file,a);pin(b.file,b);assert.deepEqual(identity(a),identity(b));};
  const origin=read(config.imagePins.file);assert.equal(origin.kind,'phase56-direct-image-pins');
  for(const key of ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference','admission'])pin(origin[key].file,origin[key]);
  same(origin.producer,{file:path.join(root,'selfhost/tools/performance/phase66/bootstrap/prepare-bootstrap.py'),sha256:'ac3a0be6991ed85e5603bf8b5de96cc480b539f1a2f76d38577ea27a82ad7a3d'});
  const attempt=read(origin.attempt.file);assert(attempt.checked&&attempt.kind==='bend-development-attempt');pin(attempt.bootstrapReport.file,attempt.bootstrapReport);
  const boot=read(attempt.bootstrapReport.file);same(origin.b1,attempt.api);same(origin.b2,config.image.api);same(origin.source,{file:boot.source,sha256:boot.sourceSha256});
  assert.equal(boot.stage,'upstream-bootstrap');assert.equal(boot.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');assert.equal(boot.baseSha256,'99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf');assert.equal(boot.provenance.verifiedAfterBuild,true);assert.equal(boot.provenance.upstream.trackedSourcesClean,true);
  same({file:boot.apiPath,sha256:boot.apiSha256},attempt.checkedApi);
  for(const item of boot.provenance.inputs)pin(item.file,item);
  if(attempt.artifactKind==='derived-b1'){
    pin(attempt.derivationReport.file,attempt.derivationReport);const derivation=read(attempt.derivationReport.file);assert.equal(derivation.transform.version,7);assert(derivation.transform.choices.sites>0);assert.equal(derivation.transform.tailChoices,undefined);
    same(derivation.original.api,attempt.checkedApi);same(derivation.original.bootstrapReport,attempt.bootstrapReport);same(derivation.output,origin.b1);pin(derivation.toolSnapshot.file,derivation.toolSnapshot);
    const verifier=await import(pathToFileURL(derivation.toolSnapshot.file));const replay=verifier.verifyEqualityDerivation(attempt.derivationReport.file);same(replay.metadata.output,origin.b1);
  }else{assert.equal(attempt.artifactKind,'checked-b1');same(attempt.api,attempt.checkedApi);}
  same(origin.runtime,pin(path.join(attempt.snapshot.root,'src/runtime/js/direct.mjs')));same(config.image.runtime,attempt.runtime);same(config.image.base,attempt.base);same(config.image.node,attempt.node);
  same(config.image.driver,pin(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')));
  const helper=path.join(attempt.snapshot.root,'tools/base-cache-graph.mjs'),helperRecord=attempt.artifacts.find(item=>item.file===helper);assert(helperRecord);pin(helper,helperRecord);
  const plan=read(origin.plan.file),emission=read(origin.emission.file),comparison=read(origin.comparison.file),reference=read(origin.rootsReference.file),admission=read(origin.admission.file);
  assert.equal(plan.kind,'phase56-candidate-image-plan');same(plan.attempt,origin.attempt);same(plan.admission,origin.admission);
  assert(emission.complete&&emission.pass&&comparison.complete&&comparison.pass&&comparison.observations===8);
  assert.equal(emission.kind,'phase55-split-compiler-emission');assert.equal(comparison.kind,'phase55-direct-compiler-driver-comparison');
  same(emission.subject.attempt,origin.attempt);same(emission.generator.attempt,origin.attempt);same(emission.subject.source,origin.source);same(emission.generator.api,origin.b1);
  same(emission.config,plan.configs[1]);same(emission.module,origin.b2);same(emission.directRuntime,origin.runtime);
  assert.equal(origin.roots.length,99);assert.equal(new Set(origin.roots).size,origin.roots.length);assert.deepEqual(origin.roots,boot.exports);assert.deepEqual(emission.roots,origin.roots);
  assert.equal(reference.kind,'phase61-checked-bootstrap-export-reference');same(reference.attempt,origin.attempt);same(reference.admission,origin.admission);same(reference.bootstrap,attempt.bootstrapReport);assert.deepEqual(reference.roots,origin.roots);
  assert.equal(admission.kind,'phase61-bootstrap-export-admission');assert.equal(admission.version,1);pin(admission.driver.file,admission.driver);assert.equal(admission.driver.sha256,config.image.driver.sha256);
  same(read(emission.config.file).driver,config.image.driver);
  pin(emission.qualification.file,emission.qualification);const tiny=read(emission.qualification.file);assert(tiny.complete&&tiny.pass&&tiny.splitEqualsUnsplit&&tiny.planEqualsCompatibility);assert.deepEqual(tiny.subject,emission.subject);
  for(const row of [...plan.inputs,...plan.configs,...plan.derivations.map(x=>x.output)])pin(row.file,row);
  for(const role of ['source','direct']){pin(comparison[role].file,comparison[role]);const row=read(comparison[role].file);assert(row.complete&&row.pass&&row.observations.length===8);same(row.emission,origin.emission);assert.deepEqual(row.subject,emission.subject);assert.deepEqual(row.generator,emission.generator);}
  const driverText=fs.readFileSync(config.image.driver.file,'utf8');assert(driverText.includes("const BASE_ANNOTATION_BASE_SHA256='"+config.image.base.sha256+"';"));
  report.generation={kind:'genuine-B2',imagePins:config.imagePins,attempt:origin.attempt,source:origin.source,b1:origin.b1,b2:origin.b2,roots:origin.roots,helper:helperRecord};
  const project=path.join(out,'project'),originalProject=path.resolve(path.dirname(config.image.driver.file),'..');
  function copy(relative){const from=path.join(originalProject,relative),to=path.join(project,relative);pin(from);fs.mkdirSync(path.dirname(to),{recursive:true});fs.copyFileSync(from,to);pin(to,inputs.get(fs.realpathSync(from)));return to;}
  function copyTree(relative){for(const item of fs.readdirSync(path.join(originalProject,relative),{withFileTypes:true})){const next=path.join(relative,item.name);if(item.isDirectory())copyTree(next);else{assert(item.isFile());copy(next);}}}
  for(const file of ['typed-driver.mjs','assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs'])copy('tools/'+file);
  copy('src/compiler.json');copyTree('src/runtime/js');
  const clonedDriver=path.join(project,'tools/typed-driver.mjs');
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
  assert(!mod.G,'Named-layout B1/B2 required');assert.equal(api,mod.default,'Owned API identity');assert.equal(D.project,project);for(const name of origin.roots)assert.equal(typeof api[name],'function','Missing admitted B2 root '+name);report.generation.actualExportCount=Object.keys(api).length;
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
