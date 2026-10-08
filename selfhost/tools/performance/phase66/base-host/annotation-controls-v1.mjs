// Root-run Phase66 checked-B1 H2 qualification. Exact isolated host transforms;
// all compiler work uses the unchanged checked API. Writes only a fresh project.
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
const report={kind:'phase66-base-annotation-owned-controls',complete:false,pass:false,diagnosticOnly:true,execution:{node:process.version,execArgv:process.execArgv},cases:[]};
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
  process.env.BEND_TYPED_API=config.image.api.file;process.env.BEND_TYPED_RUNTIME=runtime;process.env.BEND_BASE=config.image.base.file;
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs'))),mod=await import(pathToFileURL(config.image.api.file)),api=await D.loadApi();
  assert(!mod.G,'Named-layout B1/B2 required');assert.equal(api,mod.default,'Owned API identity');assert.equal(D.project,project);for(const name of boot.exports)assert.equal(typeof api[name],'function',name);report.generation.actualExports=Object.keys(api).length;
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
  const bodySize=term=>{const stack=[term];let n=0;while(stack.length){const t=stack.pop();assert(++n<1000000);stack.push(...array(t.kids));}return n;};
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
