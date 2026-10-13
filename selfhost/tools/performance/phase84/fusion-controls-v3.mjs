// Focused full-product and whole-inspection differential controls.
// Usage: node fusion-controls-v3.mjs FROZEN_PLAN CASE_OR_all FRESH_OUTPUT_DIRECTORY
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

const controls=[
  {
    "name": "erased-field",
    "relative": "selfhost/tools/performance/phase73/scalar-controls/erased-field.bend",
    "sha256": "e4fe6fb34df79924e5d5c1fa3e0c39c365f404c572e2703a9bf8cca4bad05509",
    "bytes": 316,
    "expected": {
      "status": "ok",
      "phase": "compile",
      "checked": true,
      "exitCode": 0
    },
    "purpose": "Mixed erased/live fields and native scalar sharing",
    "sourceAudit": {
      "importsBase": true,
      "definesMain": true,
      "goldenLines": [
        "12884901886n"
      ]
    }
  },
  {
    "name": "open-array",
    "relative": "tests/reg/array_open_element.bend",
    "sha256": "8587c942801ad3e4f01f1505dbd302dbef047fea4dd4277249335601e610d453",
    "bytes": 657,
    "expected": {
      "status": "error",
      "phase": "compile",
      "checked": true,
      "exitCode": 1,
      "diagnostic": "Error: an open Array element type"
    },
    "purpose": "Open Array layout refusal",
    "sourceAudit": {
      "importsBase": true,
      "definesMain": true,
      "goldenLines": [
        "Error: an open Array element type",
        "exit 1"
      ]
    }
  },
  {
    "name": "dependent-array",
    "relative": "tests/reg/brw_audit3_dependent_array.bend",
    "sha256": "7f979264891f53114ad432c92ebc7c88c6ddf7ed1c607c647fc2a5ff97ffe8cc",
    "bytes": 903,
    "expected": {
      "status": "ok",
      "phase": "compile",
      "checked": true,
      "exitCode": 0
    },
    "purpose": "Value-dependent String/Array family",
    "sourceAudit": {
      "importsBase": true,
      "definesMain": true,
      "goldenLines": [
        "7"
      ]
    }
  },
  {
    "name": "rewrite-binders",
    "relative": "tests/reg/rwt_carb_binders.bend",
    "sha256": "abcdd7de281f14a8a792ab88f8e7b555dd5d8e31631377b9e5c77a5d586f2e1b",
    "bytes": 1367,
    "expected": {
      "status": "ok",
      "phase": "compile",
      "checked": true,
      "exitCode": 0
    },
    "purpose": "Rewrite/proof erasure, annotations and parallel lets",
    "sourceAudit": {
      "importsBase": true,
      "definesMain": true,
      "goldenLines": [
        "8879"
      ]
    }
  },
  {
    "name": "closure-partial",
    "relative": "tests/compile/closure_partial_app.bend",
    "sha256": "a5db1896b19521ea737bd80b3d76304ba9bcd75ac7ce67c5cf6da4011f529d94",
    "bytes": 510,
    "expected": {
      "status": "ok",
      "phase": "compile",
      "checked": true,
      "exitCode": 0
    },
    "purpose": "Capturing lambda and constructor match",
    "sourceAudit": {
      "importsBase": true,
      "definesMain": true,
      "goldenLines": [
        "17"
      ]
    }
  },
  {
    "name": "erased-field-call",
    "relative": "tests/reg/erased_field_call.bend",
    "sha256": "1ddf82d0eafefbfc03fb0582afe50ec7f86ee815495eb7181dbfdc982194c81c",
    "bytes": 1469,
    "expected": {
      "status": "ok",
      "phase": "compile",
      "checked": true,
      "exitCode": 0
    },
    "purpose": "Calls in erased constructor fields",
    "sourceAudit": {
      "importsBase": true,
      "definesMain": true,
      "goldenLines": [
        "0"
      ]
    }
  }
];
// V2 is preserved; its no-Base dependent-pair case stopped before fusion.
// This selection was statically checked for Base and main before execution.
const root=path.resolve(import.meta.dirname,'../../../..');
const selected=caseName==='all'?controls:controls.filter(c=>c.name===caseName);
assert(selected.length>0&&selected.length<=6,'Unknown control; use all or a manifest case name');
const report={kind:'phase84-fusion-controls-v3',complete:false,pass:false,
  plan:pin(planFile),method:pin(import.meta.filename),rows:[],
  scope:'Six existing Base-importing main-bearing source fixtures; full annotation/NR_Request identity and complete owned-inspect equality. Explicit-api path independently preserves public observations; differing C there is recorded, not automatically a fusion regression. No native execution or timing claim. Fixture expected statuses are hypotheses checked here, not prior native results.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  const plan=JSON.parse(fs.readFileSync(planFile,'utf8'));
  assert.equal(plan.kind,'phase68-native-compilation-plan');
  const role=plan.roles.candidate;assert(role,'Frozen candidate role required');
  for(const item of plan.inputs)verify(item);
  for(const key of ['api','node','base','driver','runtime'])verify(role[key]);
  assert.equal(fs.realpathSync(process.execPath),role.node.file,'Run with pinned Node');
  report.role=role;report.execution={node:process.version,execArgv:process.execArgv};
  report.fixtures=selected.map(c=>({...c,source:verify({file:path.join(root,c.relative),sha256:c.sha256,bytes:c.bytes})}));
  const prepared=JSON.parse(fs.readFileSync(role.preparation,'utf8'));
  assert(prepared.complete&&prepared.pass,'Preparation must have passed');
  assert.equal(prepared.job.role,'candidate');assert.equal(prepared.job.action,'prepare');
  assert.deepEqual(prepared.plan,role.preparationPlan?verify(role.preparationPlan):report.plan);
  prepared.cache.forEach(verify);prepared.products.forEach(verify);
  assert.deepEqual(cacheFiles(role.project),prepared.cache,'Unexpected prepared cache');
  report.preparationPin=pin(role.preparation);report.cacheBefore=prepared.cache;
  process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;
  process.env.BEND_BASE=role.base.file;
  const D=await import(pathToFileURL(role.driver.file)),api=await D.loadApi();
  assert.equal(await D.loadApi(),api,'Actual owned API object required');
  for(const name of ['nr_fuse_selected','annotate_selected','nr_prepare_fused','nr_prepare_annotated'])
    assert.equal(typeof api[name],'function','Missing export '+name);
  const fuse=api.nr_fuse_selected,annotate=api.annotate_selected;
  const prepareFused=api.nr_prepare_fused,prepareOrdinary=api.nr_prepare_annotated;
  const products=new WeakMap();let active;
  const fuseControl=(book,defs,stops)=>{
    assert(active,'Unexpected paired producer outside owned control');
    const baseline=annotate(book,defs,stops),actual=fuse(book,defs,stops);
    const row={selected:list(defs).length,fused:actual.fused,ordinary:actual.ordinary,
      bodies:list(actual.bodies).map(b=>b.name)};
    active.annotation.push(row);
    row.fullDefs=sameValue(actual.defs,baseline,active.name+' annotated definitions');
    assert.equal(row.fused+row.ordinary,row.selected);assert.equal(row.bodies.length,row.fused);
    products.set(actual,{book,baseline});return actual;
  };
  const prepareControl=(book,selected)=>{
    assert(active,'Unexpected paired preparation outside owned control');
    const original=products.get(selected);assert(original,'Unobserved paired product');
    assert.equal(book,original.book,'Source identity changed');
    const baseline=prepareOrdinary(book,original.baseline),actual=prepareFused(book,selected);
    const row={runtimeNames:list(actual.names)};active.preparation.push(row);
    row.fullRequest=sameValue(actual,baseline,active.name+' NR_Request');
    products.delete(selected);return actual;
  };
  function preserve(row,label,result){
    const {code,...observation}=result;row[label]={observation};
    if(code!==undefined){
      const file=path.join(out,row.name+'-'+label+'.c');fs.writeFileSync(file,code,{flag:'wx'});
      row[label].code=pin(file);
    }
    row[label].inputs=(observation.files??[]).map(pin);
    const allowed=[...plan.inputs,...report.fixtures.map(c=>c.source)];
    for(const item of row[label].inputs)
      assert(allowed.some(p=>p.file===item.file&&p.sha256===item.sha256),'Unfrozen input '+item.file);
    save();
  }
  for(const fixture of report.fixtures){
    const row={name:fixture.name,purpose:fixture.purpose,expected:fixture.expected,annotation:[],preparation:[]};
    report.rows.push(row);save();
    const raw=await D.inspect(fixture.source.file,{mode:'native',withReport:true,api});
    preserve(row,'rawLegacy',raw);
    // Isolate fusion while retaining all other owned-path permissions.
    api.nr_fuse_selected=undefined;api.nr_prepare_fused=undefined;
    let legacy;
    try{legacy=await D.inspect(fixture.source.file,{mode:'native',withReport:true});}
    finally{api.nr_fuse_selected=fuseControl;api.nr_prepare_fused=prepareControl;}
    preserve(row,'ownedLegacy',legacy);
    active=row;let actual;
    try{actual=await D.inspect(fixture.source.file,{mode:'native',withReport:true});}
    finally{active=null;}
    preserve(row,'fused',actual);
    row.sameOwnedLegacy=sameValue(actual,legacy,row.name+' complete owned legacy inspection');
    const {code:actualCode,...actualObservation}=actual;
    const {code:rawCode,...rawObservation}=raw;
    row.sameRawObservation=sameValue(actualObservation,rawObservation,row.name+' explicit-api observation');
    row.sameRawC=actualCode===rawCode;
    if(!row.sameRawC)row.rawCDifferenceScope='Explicit-api disables other owned permissions. Owned legacy equality above is the fusion attribution control; no emitted program equivalence is inferred from differing C.';
    for(const [key,wanted] of Object.entries(fixture.expected))
      assert.deepEqual(actual[key],wanted,row.name+' expected '+key);
    if(fixture.expected.phase==='check'){
      assert.equal(row.annotation.length,0,'Rejected checker input reached annotation');
      assert.equal(row.preparation.length,0,'Rejected checker input reached preparation');
    }else{
      assert.equal(row.annotation.length,1,'Owned path did not reach fusion once');
      assert.equal(row.preparation.length,fixture.expected.status==='ok'?1:0,'Unexpected preparation across rejection boundary');
    }
    assert.deepEqual(cacheFiles(role.project),prepared.cache,'Control changed prepared cache');
    row.pass=true;save();
  }
  for(const item of plan.inputs)verify(item);
  for(const fixture of report.fixtures)verify(fixture.source);
  for(const item of [...prepared.cache,...prepared.products])verify(item);
  verify(report.preparationPin);verify(report.plan);verify(report.method);
  report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
save();
console.log(JSON.stringify({complete:report.complete,pass:report.pass,rows:report.rows.length,
  passed:report.rows.filter(r=>r.pass).length,error:report.error}));
