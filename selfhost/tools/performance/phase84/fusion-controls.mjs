// Diagnostic only: exact paired-producer products on the actual owned API.
// Usage: node fusion-controls.mjs FROZEN_PLAN CASE FRESH_OUTPUT_DIRECTORY
// This deliberately repeats annotation/preparation; its clocks are not samples.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [planFile,caseName,outArg]=process.argv.slice(2);
assert(planFile&&caseName&&outArg,'Expected PLAN CASE FRESH_OUTPUT_DIRECTORY');
const out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>{
  file=fs.realpathSync(file);const bytes=fs.readFileSync(file);
  return {file,sha256:hash(bytes),bytes:bytes.length};
};
const verify=p=>{
  assert(p?.file&&p.sha256,'Missing frozen pin');
  const actual=pin(p.file);assert.equal(actual.sha256,p.sha256,p.file);
  if(p.bytes!==undefined)assert.equal(actual.bytes,p.bytes,p.file);
  return actual;
};
const list=xs=>{
  const result=[];
  while(xs?.$==='Con'){result.push(xs.head);xs=xs.tail;}
  assert.equal(xs?.$,'Nil','Malformed Bend list');return result;
};
const cacheFiles=project=>{
  const dir=path.join(project,'build/typed/cache');
  return fs.existsSync(dir)?fs.readdirSync(dir).sort().map(n=>pin(path.join(dir,n))):[];
};

// Compare all data fields, including annotations and private indexes. Pure
// value equality permits different sharing; iterative traversal avoids stack
// overflow and pair memoization avoids repeatedly expanding a shared DAG.
function sameValue(actual,expected,label){
  const pending=[[actual,expected,label]],seen=new WeakMap();
  let pairs=0,identical=0,leaves=0;
  while(pending.length){
    const [a,b,where]=pending.pop();
    if(Object.is(a,b)){identical++;continue;}
    assert.equal(typeof a,typeof b,where+': value types differ');
    if(a===null||b===null||typeof a!=='object'){
      leaves++;assert.equal(a,b,where+': values differ');continue;
    }
    assert.equal(Object.getPrototypeOf(a),Object.getPrototypeOf(b),where+': prototypes differ');
    let partners=seen.get(a);
    if(partners?.has(b))continue;
    if(!partners){partners=new WeakSet();seen.set(a,partners);}
    partners.add(b);pairs++;
    const ak=Reflect.ownKeys(a).sort(),bk=Reflect.ownKeys(b).sort();
    assert.deepEqual(ak,bk,where+': object fields differ');
    for(let i=ak.length-1;i>=0;i--){
      const key=ak[i],next=where.length<300?where+'.'+String(key):where.slice(0,160)+'….'+String(key);
      pending.push([a[key],b[key],next]);
    }
  }
  return {equal:true,objectPairs:pairs,identicalValues:identical,nonidenticalLeaves:leaves};
}

const report={kind:'phase84-fusion-controls',complete:false,pass:false,case:caseName,
  plan:pin(planFile),method:pin(import.meta.filename),annotation:[],preparation:[],
  scope:'One frozen successful native request through the actual owned candidate API. Full annotation and NR_Request value comparisons plus exact C. Diagnostic repetition is not a performance sample; does not establish rejected-input or broader conformance.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  const plan=JSON.parse(fs.readFileSync(planFile,'utf8'));
  assert.equal(plan.kind,'phase68-native-compilation-plan');
  const role=plan.roles.candidate,source=plan.cases[caseName];
  assert(role&&source,'Frozen candidate role and case are required');
  for(const item of plan.inputs)verify(item);
  for(const key of ['api','node','base','driver','runtime'])verify(role[key]);
  assert.equal(fs.realpathSync(process.execPath),role.node.file,'Run with the pinned Node binary');
  report.role=role;report.source=verify(source.input);report.oracle=verify(source.expected.candidate);
  report.execution={node:process.version,execArgv:process.execArgv};
  const prepared=JSON.parse(fs.readFileSync(role.preparation,'utf8'));
  assert(prepared.complete&&prepared.pass,'Preparation must have passed');
  assert.equal(prepared.job.role,'candidate');assert.equal(prepared.job.action,'prepare');
  assert.deepEqual(prepared.plan,role.preparationPlan?verify(role.preparationPlan):report.plan);
  prepared.cache.forEach(verify);prepared.products.forEach(verify);
  assert.deepEqual(cacheFiles(role.project),prepared.cache,'Unexpected initial prepared cache');
  report.preparationPin=pin(role.preparation);report.cacheBefore=prepared.cache;

  process.env.BEND_TYPED_API=role.api.file;
  process.env.BEND_TYPED_RUNTIME=role.runtime.file;
  process.env.BEND_BASE=role.base.file;
  const D=await import(pathToFileURL(role.driver.file)),api=await D.loadApi();
  assert.equal(await D.loadApi(),api,'Control must retain the actual owned API object');
  for(const name of ['nr_fuse_selected','annotate_selected','nr_prepare_fused','nr_prepare_annotated'])
    assert.equal(typeof api[name],'function','Missing candidate export '+name);
  const fuse=api.nr_fuse_selected,annotate=api.annotate_selected;
  const prepareFused=api.nr_prepare_fused,prepareOrdinary=api.nr_prepare_annotated;
  const products=new WeakMap();
  api.nr_fuse_selected=(book,selected,stops)=>{
    const baseline=annotate(book,selected,stops),actual=fuse(book,selected,stops);
    const row={selected:list(selected).length,stops:list(stops).length,
      fused:actual.fused,ordinary:actual.ordinary,bodies:list(actual.bodies).map(b=>b.name)};
    report.annotation.push(row);
    row.fullDefs=sameValue(actual.defs,baseline,'annotated definitions');
    assert.equal(row.fused+row.ordinary,row.selected,'Definition coverage count');
    assert.equal(row.bodies.length,row.fused,'One private body per paired definition');
    assert.equal(new Set(row.bodies).size,row.bodies.length,'Duplicate produced body name');
    products.set(actual,{book,baseline});return actual;
  };
  api.nr_prepare_fused=(book,selected)=>{
    const control=products.get(selected);
    assert(control,'Preparation did not use the observed producer product');
    assert.equal(book,control.book,'Preparation source book identity changed');
    const baseline=prepareOrdinary(book,control.baseline),actual=prepareFused(book,selected);
    const row={runtimeNames:list(actual.names)};report.preparation.push(row);
    row.fullRequest=sameValue(actual,baseline,'NR_Request');
    products.delete(selected);return actual;
  };
  const result=await D.inspect(source.input.file,{mode:'native',withReport:true});
  const {code,...observation}=result;report.observation=observation;
  assert.equal(observation.status,'ok');assert.equal(observation.checked,true);
  assert(report.annotation.length>0,'Owned driver did not use paired annotation');
  assert.equal(report.preparation.length,report.annotation.length,'Missing paired request preparation');
  fs.writeFileSync(path.join(out,'actual.c'),code,{flag:'wx'});
  report.actual=pin(path.join(out,'actual.c'));
  assert.equal(report.actual.sha256,report.oracle.sha256,'Complete C differs; actual.c preserved');
  report.exactC=true;
  report.requestInputs=(observation.files??[]).map(pin);
  for(const item of report.requestInputs)
    assert(plan.inputs.some(p=>p.file===item.file&&p.sha256===item.sha256),'Unfrozen input '+item.file);
  assert.deepEqual(cacheFiles(role.project),prepared.cache,'Control changed prepared cache');
  for(const item of plan.inputs)verify(item);
  for(const item of [...prepared.cache,...prepared.products])verify(item);
  verify(report.preparationPin);verify(report.plan);verify(report.method);
  report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();
console.log(JSON.stringify({case:caseName,complete:report.complete,pass:report.pass,
  annotationCalls:report.annotation.length,preparationCalls:report.preparation.length,
  exactC:report.exactC,error:report.error}));
