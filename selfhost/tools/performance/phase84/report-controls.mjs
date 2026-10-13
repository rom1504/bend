// Correctness diagnostics only. Root runs with ExecutionGuard; no benchmark claim.
// Usage: node report-controls.mjs FROZEN_PLAN OUT [ROLE=candidate]
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [planArg,outArg,roleName='candidate']=process.argv.slice(2);
assert(planArg&&outArg,'Expected FROZEN_PLAN OUT [ROLE]');
const out=path.resolve(outArg),root=path.resolve(import.meta.dirname,'../../../..');
fs.mkdirSync(out,{recursive:false});
const hash=value=>createHash('sha256').update(value).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,sha256:hash(b),bytes:b.length};};
const verify=p=>{const a=pin(p.file);assert.equal(a.sha256,p.sha256,p.file);if(p.bytes!==undefined)assert.equal(a.bytes,p.bytes,p.file);return a;};
const planPin=pin(planArg),plan=JSON.parse(fs.readFileSync(planPin.file,'utf8')),role=plan.roles[roleName];
assert(role&&role.api&&role.driver,'Role must be an actual prepared Bend compiler');
const report={kind:'phase84-report-controls',complete:false,pass:false,plan:planPin,method:pin(import.meta.filename),role:roleName,
  scope:'Untimed differential correctness controls of actual owned report dispatch, with fresh API identity and frozen source/cache inputs. Every prefix report is compared with the complete legacy DR_Report product.',
  counts:{ownedPrefixCalls:0,readyHits:0,unreadyHits:0,ordinaryDataFallbacks:0,directReadinessFallbacks:0,rawApiRequests:0},cases:[],products:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
const listArray=xs=>{const result=[];while(xs?.$==='Con'){result.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return result;};
const displayName=n=>n.replace(':','.');
const cacheFiles=()=>{const d=path.join(role.project,'build/typed/cache');return fs.existsSync(d)?fs.readdirSync(d).sort().map(n=>pin(path.join(d,n))):[];};
const pins=new Map();
function inventory(file){
  const p=pin(file);if(pins.has(p.file)){assert.deepEqual(pins.get(p.file),p);return;}
  pins.set(p.file,p);
  if(!p.file.endsWith('.bend'))return;
  for(const match of fs.readFileSync(p.file,'utf8').matchAll(/^\s*import\s+("[^"]+"|'[^']+'|[^\s#]+)/gm)){
    const name=match[1].replace(/^["']|["']$/g,'');
    if(name==='Base'){inventory(role.base.file);continue;}
    assert(name.startsWith('.'),'Unsupported fixture import inventory: '+name+' in '+p.file);
    inventory(path.resolve(path.dirname(p.file),name));
  }
}
let current=null,api,originalPrefix,originalData;
try{
  for(const p of plan.inputs)verify(p);
  for(const key of ['api','driver','runtime','base','node'])verify(role[key]);
  assert.equal(fs.realpathSync(process.execPath),role.node.file);
  report.identity={api:role.api,driver:role.driver,runtime:role.runtime,base:role.base,node:role.node};
  const preparationPin=pin(role.preparation),prepared=JSON.parse(fs.readFileSync(preparationPin.file,'utf8'));
  assert(prepared.complete&&prepared.pass);assert.equal(prepared.job.role,roleName);assert.equal(prepared.job.action,'prepare');
  assert.deepEqual(prepared.plan,role.preparationPlan?verify(role.preparationPlan):planPin);
  prepared.cache.forEach(verify);prepared.products.forEach(verify);assert.deepEqual(cacheFiles(),prepared.cache);
  report.preparation=preparationPin;report.cache=prepared.cache;report.preparedProducts=prepared.products;

  const fixtureDir=path.join(out,'fixtures');fs.mkdirSync(fixtureDir);
  const generated=(name,text)=>{const file=path.join(fixtureDir,name+'.bend');fs.writeFileSync(file,text,{flag:'wx'});return file;};
  const cycle=generated('unsafe-cycle',`import Base\n\n@unsafe\ndef loop_a(n: Nat) -> Nat:\n  loop_b(n)\n\n@unsafe\ndef loop_b(n: Nat) -> Nat:\n  loop_a(n)\n\ndef via(n: Nat) -> Nat:\n  loop_a(n)\n\ndef independent(n: Nat) -> Nat:\n  n\n`);
  const fields=generated('unsafe-type-and-field',`import Base\n\n@unsafe\ndef field_type() -> Type:\n  Nat\n\ntype Holder is Data:\n  Held{value: field_type()}\n\ndef typed_only(value: field_type()) -> Nat:\n  value\n`);
  const noBase=generated('no-base','def identity(x: Type) -> Type:\n  x\n');
  const cases=[];
  const add=(name,file,status,phase,bad=null,diagnostic=null)=>cases.push({name,file:path.resolve(root,file),expected:{status,phase,bad,diagnostic}});
  for(const [name,source] of Object.entries(plan.cases))add('bench-'+name,source.input.file,'ok','check',[]);
  add('unsafe-used','tests/import/unsafe_used.bend','error','verdict',['unsafe_lib.boom','innocent']);
  add('unsafe-unused','tests/import/unsafe_unused.bend','error','verdict',['unsafe_lib.boom']);
  add('law-derived','tests/import/unsafe_law_derived.bend','error','verdict',['unsafe-law/laws.false_law','unsafe-law/succ.succ_is_id','unsafe-law/derived.boom']);
  add('law-fill','tests/import/unsafe_law_fill.bend','error','verdict',['unsafe-law/laws.false_law']);
  add('law-unused','tests/import/unsafe_law_unused.bend','error','verdict',['unsafe-law/safe.spin']);
  add('inequality-freshening','tests/halt/sugar_self_call.bend','ok','check',[]);
  add('foreign-constructor-refs','tests/io/foreign_shared.bend','ok','check',['shared.make','main']);
  add('unsafe-mutual-cycle',cycle,'error','verdict',['loop_a','loop_b','via']);
  add('unsafe-type-field',fields,'error','verdict',['field_type','Holder','typed_only']);
  add('no-base-public-fallback',noBase,'ok','check',[]);
  add('duplicate-constructor','tests/parse/duplicate_ctor_name.bend','error','parse',null,'duplicate declaration: Kk');
  add('alias-refusal','tests/import/alias_twice.bend','error','parse',null,'a fresh alias');
  add('checker-refusal','tests/halt/non_structural_field.bend','error','check',null,'a decreasing self-call');
  cases.forEach(c=>inventory(c.file));report.fixtureInputs=[...pins.values()];report.expectedCases=cases;save();

  process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
  const D=await import(pathToFileURL(role.driver.file));api=await D.loadApi();assert.equal(await D.loadApi(),api,'Must instrument actual owned API object');
  assert.equal(typeof api.driver_report_prefix_data,'function');assert.equal(typeof api.driver_report_data,'function');
  originalPrefix=api.driver_report_prefix_data;originalData=api.driver_report_data;
  const identities=new WeakMap();let nextIdentity=0;
  const identity=x=>{assert(x&&typeof x==='object');if(!identities.has(x))identities.set(x,++nextIdentity);return identities.get(x);};
  api.driver_report_data=(...args)=>{report.counts.ordinaryDataFallbacks++;return originalData(...args);};
  api.driver_report_prefix_data=(book,load,state)=>{
    assert(current,'Report called outside a declared control');assert.equal(book,load.trace.result.book,'Report input must be the actual loaded book');
    const actual=originalPrefix(book,load,state),expected=originalData(book);
    assert.deepEqual(actual,expected,'Complete report mismatch for '+current.name);
    const ready=load.ready===true&&state.ready===true;
    report.counts.ownedPrefixCalls++;report.counts[ready?'readyHits':'unreadyHits']++;
    report.products.push({case:current.name,ready,bookIdentity:identity(book),loadIdentity:identity(load),stateIdentity:identity(state),
      verdict:actual.verdict,names:listArray(actual.names),sha256:hash(JSON.stringify(actual)),deepEqualLegacy:true});
    if(ready&&!report.counts.directReadinessFallbacks){
      for(const [label,l,s] of [['load-unready',{...load,ready:false},state],['state-unready',load,{...state,ready:false}],['both-unready',{...load,ready:false},{...state,ready:false}]]){
        const fallback=originalPrefix(book,l,s);assert.deepEqual(fallback,expected,label);
        report.counts.directReadinessFallbacks++;(report.fallbackControls??=[]).push({label,case:current.name,deepEqualLegacy:true});
      }
    }
    return actual;
  };
  for(const c of cases){
    current=c;const before={...report.counts},row={name:c.name,input:pin(c.file),expected:c.expected};report.cases.push(row);save();
    row.observation=await D.inspect(c.file,{mode:'check',withReport:true});
    const r=row.observation,e=c.expected;
    assert.equal(r.status,e.status,c.name);assert.equal(r.phase,e.phase,c.name);assert.equal(r.exitCode,e.status==='ok'?0:1,c.name);
    if(e.bad!==null){
      assert.equal(r.checked,true,c.name);assert.equal(r.typeAccepted,true,c.name);assert.equal(r.kernelChecked,false,c.name);
      assert.equal(r.proofTrust,e.bad.length?'failed':'passed',c.name);assert.deepEqual(r.unsafeDefinitions.map(displayName),e.bad,c.name);
      if(e.status==='error')assert(r.diagnostic.startsWith('SOME PROOFS FAIL\n'),c.name);
      if(c.name==='no-base-public-fallback')assert(report.counts.ordinaryDataFallbacks>before.ordinaryDataFallbacks,c.name);
      else assert(report.counts.ownedPrefixCalls>before.ownedPrefixCalls,'No optimized report path for '+c.name);
    }else{
      assert.equal(r.checked,e.phase==='check',c.name);assert(r.diagnostic.includes(e.diagnostic),c.name);
      assert.equal(report.counts.ownedPrefixCalls,before.ownedPrefixCalls,'Refused source reached new report path');
      assert.equal(report.counts.ordinaryDataFallbacks,before.ordinaryDataFallbacks,'Refused source reached report fallback');
    }
    for(const file of r.files??[]){const p=pin(file);assert.deepEqual(pins.get(p.file),p,'Unfrozen control input '+file);}
    if(['unsafe-used','inequality-freshening'].includes(c.name)){
      const hits=report.counts.ownedPrefixCalls;
      row.rawApiObservation=await D.inspect(c.file,{mode:'check',withReport:true,api});
      assert.deepEqual(row.rawApiObservation,r,'Explicit API request changed public result');
      assert.equal(report.counts.ownedPrefixCalls,hits,'Explicit API acquired owned-only report dispatch');report.counts.rawApiRequests++;
    }
    row.counts=Object.fromEntries(Object.keys(before).map(k=>[k,report.counts[k]-before[k]]));row.pass=true;save();
  }
  assert(report.counts.readyHits>0);assert.equal(report.counts.directReadinessFallbacks,3);assert.equal(report.counts.rawApiRequests,2);
  for(const p of plan.inputs)verify(p);for(const p of pins.values())verify(p);verify(preparationPin);prepared.cache.forEach(verify);prepared.products.forEach(verify);
  assert.deepEqual(cacheFiles(),prepared.cache);report.inputsUnchanged=true;report.complete=true;report.pass=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;}
finally{if(api&&originalPrefix)api.driver_report_prefix_data=originalPrefix;if(api&&originalData)api.driver_report_data=originalData;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,counts:report.counts,error:report.error}));
