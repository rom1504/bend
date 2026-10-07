// Diagnostic only: ordinary compilation first, then compare two emission contexts.
// Run only inside the root-owned resource supervisor. No production cache is added.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [preparationArg,outArg,...wanted]=process.argv.slice(2);
assert(preparationArg&&outArg&&wanted.length);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase61')+path.sep));
assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file)),bytes:fs.statSync(file).size});
const inputs=new Map(),copies=[];
function pin(file,want){const x=identity(file);if(want){assert.equal(x.sha256,want.sha256);if(want.bytes!==undefined)assert.equal(x.bytes,want.bytes)}if(inputs.has(x.file))assert.deepEqual(x,inputs.get(x.file));inputs.set(x.file,x);return x}
const read=(file,want)=>{pin(file,want);return JSON.parse(fs.readFileSync(file,'utf8'))};
const array=xs=>{const r=[];while(xs?.$==='Con'){r.push(xs.head);xs=xs.tail;assert(r.length<=65536)}assert.equal(xs?.$,'Nil');return r};
const jsonHash=x=>hash(JSON.stringify(x)??'undefined');
const report={kind:'phase61-diagnostic-emission-context-comparison',complete:false,pass:false,diagnosticOnly:true,productionQualified:false,cases:[],inputs:[],copies,
  scope:'Fresh copied driver captures ordinary reach arguments/results without changing compiler calls. Complete raw output must match the inherited qualified oracle. Separate append-only diagnostic API then compares retained definition text, retained call facts and pruned lookup values. Equality is finite evidence, not a general context-invariance proof; no timing or cache benefit claim.'};
function save(){report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n')}
save();
try{
  pin(import.meta.filename);report.node=pin(process.execPath);report.nodeVersion=process.version;
  const prep=read(preparationArg,{sha256:'9a91f0b4a62462cf9aa21dd7aab0584b2004c205ee1f6756e910772d729279a0'});assert(prep.complete&&prep.pass&&prep.stage==='prepare'&&prep.role==='candidate');
  const cfg=read(prep.config.file,prep.config);report.preparation=identity(preparationArg);report.image=prep.image;
  assert.equal(prep.image.api.sha256,'f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a');
  assert.equal(prep.image.driver.sha256,'569f17b1e0ccd87da33dd07c2b7a7837f4578cae7d592e646f10eb4c2d2a313b');
  for(const key of ['api','source','runtime','directRuntime','base','driver','emission','checkedGenerator'])pin(prep.image[key].file,prep.image[key]);
  const project=path.join(out,'project');
  function copy(src){const before=pin(src.file,src),rel=path.relative(prep.project,before.file);assert(rel&&!rel.startsWith('..')&&!path.isAbsolute(rel));const file=path.join(project,rel);fs.mkdirSync(path.dirname(file),{recursive:true});fs.copyFileSync(before.file,file,fs.constants.COPYFILE_EXCL);const after=identity(file);assert.equal(after.sha256,before.sha256);copies.push({before,after});return file}
  for(const item of prep.copies)copy(item.after);
  assert.equal(prep.verification.cacheFiles.length,1);for(const item of prep.verification.cacheFiles)copy(item);
  const driver=path.join(project,'tools/typed-driver.mjs'),driverBytes=fs.readFileSync(driver,'utf8');
  const changes=[
    ['      const reachable=api.jd_reach_selected(contextBook,book,roots);','      globalThis[Symbol.for("bend.phase61.reuse-probe")].before(contextBook,book,roots);\n      const reachable=api.jd_reach_selected(contextBook,book,roots);'],
    ['      book=api.jd_reach_defs(reachable);','      book=api.jd_reach_defs(reachable);\n      globalThis[Symbol.for("bend.phase61.reuse-probe")].after(book);']
  ];
  let changed=driverBytes;for(const [a,b]of changes){assert.equal(changed.split(a).length,2);changed=changed.replace(a,b)}
  let inverse=changed;for(const [a,b]of [...changes].reverse())inverse=inverse.replace(b,a);assert.equal(inverse,driverBytes);
  const diagnosticDriver=path.join(project,'tools/typed-driver-reuse-probe.mjs');fs.writeFileSync(diagnosticDriver,changed,{flag:'wx'});report.driverDerivative={parent:identity(driver),output:identity(diagnosticDriver),changes,exactInverse:true};
  const original=fs.readFileSync(prep.image.api.file,'utf8');
  const names=['jd_doc_definition','jd_text_render','jd_calls_rows','lookup','jd_calls_context','jd_selected_context','jd_calls_fact','jd_component','jd_component_id','jd_may_bounce','jd_calls_valid','jd_definition_budget'];
  const jsName=n=>'$jd$'+[...n].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
  const acornSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],acorn={exports:{}};new Function('module','exports',acornSource)(acorn,acorn.exports);
  const ast=acorn.exports.parse(original,{ecmaVersion:'latest',sourceType:'module'});
  for(const n of ['run_loop',...names.map(jsName)])assert.equal(ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===n).length,1,n);
  assert(!original.includes('phase61ReuseProbe'));
  const suffix='\nexport const phase61ReuseProbe={'+names.map(n=>JSON.stringify(n)+':(...xs)=>run_loop('+jsName(n)+'(...xs))').join(',')+'};\n';
  const apiFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(apiFile,original+suffix,{flag:'wx'});assert.equal(fs.readFileSync(apiFile,'utf8').slice(0,-suffix.length),original);acorn.exports.parse(original+suffix,{ecmaVersion:'latest',sourceType:'module'});
  report.apiDerivative={parent:prep.image.api,output:identity(apiFile),suffixSha256:hash(suffix),appendOnly:true,parserSourceSha256:hash(acornSource)};
  for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
  process.env.BEND_TYPED_API=path.join(project,'dist/api.mjs');process.env.BEND_TYPED_RUNTIME=path.join(project,'src/runtime.mjs');process.env.BEND_BASE=prep.image.base.file;
  const D=await import(pathToFileURL(diagnosticDriver));assert.equal(D.apiPath,process.env.BEND_TYPED_API);
  let captured=null;
  globalThis[Symbol.for('bend.phase61.reuse-probe')]={before(context,defs,roots){assert.equal(captured,null);captured={context,defs,roots}},after(defs){assert(captured&&!captured.retained);captured.retained=defs}};
  const selected=wanted[0]==='all'?cfg.cases.map(x=>x.id):wanted;assert.equal(new Set(selected).size,selected.length);
  let P;
  for(const id of selected){
    const spec=cfg.cases.find(x=>x.id===id),oracle=prep.outputs.find(x=>x.id===id);assert(spec&&oracle?.oracle.pass);assert.deepEqual(spec.source,oracle.source);assert.equal(oracle.oracle.freshlyExecuted,false);
    for(const x of [spec.source,...spec.files,...spec.emissionInputs,oracle.output])pin(x.file,x);
    captured=null;const result=await D.inspect(spec.source.file,{mode:'library',backend:'direct'});assert.equal(result.status,'ok');assert.equal(result.checked,true);assert.equal(result.backend,'direct');assert(captured?.retained);
    const bytes=Buffer.from(result.code);assert.equal(bytes.compare(fs.readFileSync(oracle.output.file)),0,'Ordinary raw output changed');
    assert.deepEqual(result.files.map(x=>fs.realpathSync(x)).sort(),[spec.source.file,prep.image.base.file,D.directRuntimePath].sort());
    if(!P)P=(await import(pathToFileURL(apiFile))).phase61ReuseProbe;
    const {context,defs,retained}=captured,initial=P.jd_calls_context(P.jd_selected_context(context,defs),defs),final=P.jd_calls_context(P.jd_selected_context(context,retained),retained);
    assert.equal(P.jd_calls_valid(initial),true);assert.equal(P.jd_calls_valid(final),true);
    const all=array(defs),keep=array(retained),keptNames=new Set(keep.map(x=>x.name)),row={id,source:spec.source,oracle:oracle.output,fullOutput:{sha256:hash(bytes),bytes:bytes.length},initialDefinitions:all.length,retainedDefinitions:keep.length,definitions:[],prunedLookupDifferences:[],tailEdgesOutsideRetained:[],retainedCallRowDifferences:[],pass:false};report.cases.push(row);save();
    for(const d of keep){
      const a=P.jd_text_render(P.jd_doc_definition(initial,d)),b=P.jd_text_render(P.jd_doc_definition(final,d));
      const fa=P.jd_calls_fact(initial,d.name),fb=P.jd_calls_fact(final,d.name),ca=array(P.jd_component(initial,d.name)),cb=array(P.jd_component(final,d.name));
      const f={name:d.name,kind:d.kind,bytes:Buffer.byteLength(a),initialSha256:hash(a),finalSha256:hash(b),textEqual:a===b,factEqual:jsonHash(fa)===jsonHash(fb),componentEqual:JSON.stringify(ca)===JSON.stringify(cb),initialComponent:ca,finalComponent:cb,initialBounce:P.jd_may_bounce(initial,d.name),finalBounce:P.jd_may_bounce(final,d.name)};
      if(a!==b){let i=0;while(i<Math.min(a.length,b.length)&&a[i]===b[i])i++;f.firstDifference={offset:i,initial:a.slice(Math.max(0,i-80),i+160),final:b.slice(Math.max(0,i-80),i+160)}}
      row.definitions.push(f);
    }
    for(const d of all)if(!keptNames.has(d.name)){
      const a=P.lookup(initial,d.name),b=P.lookup(final,d.name),changedFields=Object.keys(a).filter(k=>jsonHash(a[k])!==jsonHash(b[k]));
      if(changedFields.length)row.prunedLookupDifferences.push({name:d.name,changedFields,initialSha256:jsonHash(a),finalSha256:jsonHash(b)});
    }
    const ir=P.jd_calls_rows(initial,defs,P.jd_definition_budget()),fr=P.jd_calls_rows(final,retained,P.jd_definition_budget());assert.equal(ir.$,'Some');assert.equal(fr.$,'Some');
    const initialRows=array(ir.value),finalRows=new Map(array(fr.value).map(d=>[d.name,d]));
    for(const d of initialRows)if(keptNames.has(d.name)){
      if(jsonHash(d)!==jsonHash(finalRows.get(d.name)))row.retainedCallRowDifferences.push(d.name);
      for(const edge of array(d.value.kids))if(!keptNames.has(edge.name))row.tailEdgesOutsideRetained.push({from:d.name,to:edge.name});
    }
    row.counts={textMatches:row.definitions.filter(x=>x.textEqual).length,textDifferences:row.definitions.filter(x=>!x.textEqual).length,factDifferences:row.definitions.filter(x=>!x.factEqual||!x.componentEqual||x.initialBounce!==x.finalBounce).length,prunedLookupDifferences:row.prunedLookupDifferences.length,tailEdgesOutsideRetained:row.tailEdgesOutsideRetained.length,retainedCallRowDifferences:row.retainedCallRowDifferences.length};
    // Mismatches are successful diagnostic findings, not failed source semantics.
    row.pass=true;save();console.log(JSON.stringify({id,counts:row.counts}));captured=null;
  }
  delete globalThis[Symbol.for('bend.phase61.reuse-probe')];
  for(const x of inputs.values())assert.deepEqual(identity(x.file),x);for(const x of copies)assert.deepEqual(identity(x.after.file),x.after);
  for(const d of [report.apiDerivative,report.driverDerivative])assert.deepEqual(identity(d.output.file),d.output);
  report.complete=report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1}finally{save()}
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
