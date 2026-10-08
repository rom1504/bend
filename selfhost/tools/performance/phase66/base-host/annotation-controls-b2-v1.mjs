// Root-run Phase66 genuine-B2 H2 qualification. Exact emission and parent lineage;
// all semantic/demand controls retained from the passed selected03 controller.
// Writes only a fresh cloned project; no source or host transforms.
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
const report={kind:'phase66-base-annotation-genuine-b2-owned-controls',complete:false,pass:false,diagnosticOnly:true,execution:{node:process.version,execArgv:process.execArgv},cases:[]};
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
  process.env.BEND_TYPED_API=config.image.api.file;process.env.BEND_TYPED_RUNTIME=runtime;process.env.BEND_BASE=config.image.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs'))),mod=await import(pathToFileURL(config.image.api.file)),api=await D.loadApi();
  assert(!mod.G,'Named-layout B1/B2 required');assert.equal(api,mod.default,'Owned API identity');assert.equal(D.project,project);for(const name of origin.roots)assert.equal(typeof api[name],'function','Missing admitted B2 root '+name);report.generation.actualExportCount=Object.keys(api).length;
  const names=['base_annotation_prepare','base_annotation_wanted','base_annotation_allowed','annotate_selected_base','annotate_selected','check_program_diagnostic_world','book_context_world'];
  const original=Object.fromEntries(names.map(name=>{assert.equal(typeof api[name],'function',name);return[name,api[name]];}));
  let produced=null,producerWorld=null,counts=null,disabled=false,allowedArgs=null,consumerArgs=null;
  api.base_annotation_prepare=(world,work)=>{assert.equal(work,64);assert(!produced,'One producer call');producerWorld=world;produced=original.base_annotation_prepare(world,work);return produced;};
  api.base_annotation_wanted=(...args)=>{if(counts)counts.wanted++;const result=original.base_annotation_wanted(...args);if(counts)counts.actualWanted=result;return disabled?false:result;};
  api.base_annotation_allowed=(...args)=>{if(counts)counts.allowed++;const result=original.base_annotation_allowed(...args);if(counts)counts.actualAllowed=result;if(result)allowedArgs=args;return result;};
  api.check_program_diagnostic_world=(...args)=>{if(counts)counts.world++;return original.check_program_diagnostic_world(...args);};
  api.book_context_world=(...args)=>{if(counts)counts.context++;return original.book_context_world(...args);};
  api.annotate_selected_base=(book,selected,stops,products)=>{assert(counts);counts.consumer++;consumerArgs=[book,selected,stops,products];const actual=original.annotate_selected_base(book,selected,stops,products),expected=original.annotate_selected(book,selected,stops);counts.annotationComparedPairs+=equalGraph(actual,expected);const byName=new Map(array(products).filter(d=>d.kind!=='BookCache').map(d=>[d.name,d])),stopSet=new Set(array(stops));for(const d of array(actual))if(byName.has(d.name)&&!stopSet.has(d.name)){assert.equal(d,byName.get(d.name),'Cached definition must be returned directly');counts.annotationReused++;}assert.equal(counts.annotationReused,array(selected).filter(d=>byName.has(d.name)&&!stopSet.has(d.name)).length);counts.annotationExact=true;return actual;};
  await D.prepareBase(api);
  assert.equal(produced?.$,'KBaseAnnotationState');assert.equal(producerWorld?.state?.ready,true);
  const keys=array(produced.keys),list=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
  for(const name of ['book_context','jd_stops'])assert.equal(typeof api[name],'function',name);
  const checked=array(producerWorld.checked).reverse(),context=api.book_context(list(checked)),stops=api.jd_stops(context),stopNames=new Set(array(stops));
  // Independent full occurrence count; no borrowed Phase65 product/name oracle.
  const bodySize=term=>{const stack=[term];let n=0;while(stack.length){const t=stack.pop();assert(++n<1000000);if(t.$==='KLiteral')continue;assert(t.$==='KTerm'||t.$==='KLambda','Unknown term in independent census');stack.push(...array(t.kids));}return n;};
  const eligible=checked.filter(d=>d.kind==='Def'&&d.templates===0&&!stopNames.has(d.name)&&!['Absent','Foreign'].includes(d.value.tag)&&bodySize(d.value)>=64);
  assert.deepEqual(keys,eligible.map(d=>d.name));assert(keys.length>0);
  const products=array(produced.book).filter(d=>d.kind!=='BookCache'),expectedProducts=original.annotate_selected(context,list(eligible),stops);
  assert.deepEqual(products.map(d=>d.name),keys);const preparationPairs=equalGraph(list(products),expectedProducts);
  const sidecars=fs.readdirSync(D.baseAnnotationDirectory).filter(name=>name.endsWith('-annotations64-v1.bin'));assert.equal(sidecars.length,1);
  const sidecar=path.join(D.baseAnnotationDirectory,sidecars[0]),bytes=fs.readFileSync(sidecar),productOffset=4+bytes.readUInt32LE(0);
  report.preparation={keys,checkedDefinitions:checked.length,allProductsExact:true,preparationPairs,sidecar:{file:sidecar,sha256:hash(bytes),bytes:bytes.length},producerReady:true};
  // Observe real host IO without changing its result; miss rows must never read the body.
  const realOpen=fs.openSync,realRead=fs.readSync,realClose=fs.closeSync,tracked=new Set();
  fs.openSync=function(file,...args){const fd=realOpen.call(this,file,...args);if(path.resolve(String(file))===sidecar){tracked.add(fd);if(counts)counts.sidecarOpens++;}return fd;};
  fs.readSync=function(fd,...args){if(counts&&tracked.has(fd)&&args[3]>=productOffset)counts.productReads++;return realRead.call(this,fd,...args);};
  fs.closeSync=function(fd){tracked.delete(fd);return realClose.call(this,fd);};
  const reset=()=>counts={world:0,context:0,wanted:0,allowed:0,consumer:0,sidecarOpens:0,productReads:0,annotationComparedPairs:0,annotationReused:0};
  try{
    for(const spec of config.sources){
      const source=pin(spec.file,spec),row={id:spec.id,source,pass:false};report.cases.push(row);save();
      disabled=true;reset();const plain=await D.inspect(source.file,{mode:'library',backend:'direct'});row.ordinary={...counts};row.ordinaryObservation={status:plain.status,phase:plain.phase,diagnostic:plain.diagnostic,checked:plain.checked};assert.equal(plain.status,'ok',plain.diagnostic);assert.equal(counts.consumer,0);assert.equal(counts.productReads,0);
      disabled=false;reset();const cached=await D.inspect(source.file,{mode:'library',backend:'direct'});row.cached={...counts};assert.deepEqual(cached,plain,'Whole owned driver result differs');assert.equal(counts.world,1);assert.equal(counts.context,1);
      if(spec.id==='test-map-set-ops'){assert.equal(counts.consumer,1);assert.equal(counts.allowed,1);assert.equal(counts.actualAllowed,true);assert.equal(counts.annotationExact,true);assert(counts.annotationReused>0);assert(counts.productReads>0);}
      if(['numeric-recurrence','lexer'].includes(spec.id)){assert.equal(counts.actualWanted,false);assert.equal(counts.consumer,0);assert.equal(counts.allowed,0);assert.equal(counts.productReads,0);}
      if(spec.id==='test-map-set-ops'){
        const [context,selected,stops,products]=consumerArgs,[load,world]=allowedArgs;
        const list=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
        const productNames=new Set(array(products).map(d=>d.name)),stopped=array(selected).find(d=>productNames.has(d.name));assert(stopped);
        const newStops=list([stopped.name,...array(stops)]),stopActual=original.annotate_selected_base(context,selected,newStops,products),stopExpected=original.annotate_selected(context,selected,newStops);
        equalGraph(stopActual,stopExpected);assert.equal(array(stopActual).find(d=>d.name===stopped.name),stopped);
        assert.equal(original.base_annotation_wanted(list([stopped]),newStops,produced.keys),false);
        assert.equal(original.base_annotation_allowed(load,world),true);
        assert.equal(original.base_annotation_allowed({...load,ready:false},world),false);
        assert.equal(original.base_annotation_allowed({...load,trace:{...load.trace,result:{...load.trace.result,error:'control: loader refused'}}},world),false);
        const witnessFile=path.join(root,'selfhost/tools/performance/phase63/controls/base-collision-v1.json');pin(witnessFile);const witness=JSON.parse(fs.readFileSync(witnessFile,'utf8'));
        const fnv=name=>{let h=2166136261;for(const c of name)h=Math.imul((h^c.codePointAt(0))>>>0,16777619)>>>0;return h;};assert.equal(fnv(witness.first),witness.hash);assert.equal(fnv(witness.second),witness.hash);
        const sample=array(load.suffix).find(d=>d.kind==='Def');assert(sample);
        // Negative guard probe only: no forged carrier is compiled or granted host ownership.
        const collision={...sample,name:witness.second,ctors:{$:'Nil'}};
        assert.equal(original.base_annotation_allowed({...load,suffix:{$:'Con',head:collision,tail:load.suffix}},world),false);
        row.privateGuards={stopFirstExact:true,stoppedObjectPreserved:true,stoppedWantedFalse:true,actualAllowed:true,unreadyDeclined:true,loaderErrorDeclined:true,fullHashCollisionDeclined:true};
      }
      reset();const publicResult=await D.inspect(source.file,{mode:'library',backend:'direct',api});row.publicInjected={...counts};assert.deepEqual(publicResult,plain,'Public injected API result differs');assert.equal(counts.world,0);assert.equal(counts.consumer,0);assert.equal(counts.productReads,0);
      if(spec.expectedOutput){pin(spec.expectedOutput.file,spec.expectedOutput);assert.equal(cached.code,fs.readFileSync(spec.expectedOutput.file,'utf8'),'Qualified complete module differs');}
      for(const file of cached.files)if(!file.startsWith(project+path.sep))pin(file);
      row.output={sha256:hash(cached.code),bytes:Buffer.byteLength(cached.code)};row.pass=true;counts=null;save();console.log(JSON.stringify({id:row.id,pass:true,cached:row.cached}));
    }
  }finally{counts=null;fs.openSync=realOpen;fs.readSync=realRead;fs.closeSync=realClose;for(const name of names)api[name]=original[name];}
  assert(report.cases.some(row=>row.cached.consumer>0),'No actual owned product consumption');
  assert.equal(hash(fs.readFileSync(sidecar)),report.preparation.sidecar.sha256,'Artifact mutated by use');
  for(const value of inputs.values())pin(value.file,value);
  report.inputsUnchanged=true;report.complete=report.pass=true;
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};process.exitCode=1;}
save();
