// Supplemental helper controls: Bend performs every schema/flow/map operation.
import path from 'node:path';
import assert from 'node:assert/strict';
import * as S from './support.mjs';

const a=S.options();for(const key of ['baseline','candidate','out'])assert(a[key],'Missing --'+key);
const inputs=[S.pin(import.meta.filename),S.pin(path.join(import.meta.dirname,'support.mjs'))];
const out=S.output(a.out);
const report={kind:'phase147-numeric-verifier-helper-controls',version:1,complete:false,passed:false,
  inputs,rows:[],countBoundaries:[],scope:'Supplemental complete flow projections over coherent explicit-ID schemas. Numeric IDs are deliberately non-dense U32 helper inputs, including values beyond production local-count bounds. Count tests isolate the schema helper guard with a synthetic initial count; neither these nor projected host values establish complete-entry exhaustion or native ownership safety.'};
const save=()=>S.save(out+'/report.json',report);save();
const nil=()=>({$:'P147VNone'}),empty=()=>({$:'P147VEmpty'});
const tag=(name,fields={})=>({$:name,...fields});
const word=(lo=1)=>tag('N111Const',{lo,hi:0});
const local=name=>tag('N111Local',{name});
const set=name=>tag('N111Set',{name,typ:tag('N111U64'),value:word()});
const offset=(name,base,bytes)=>tag('N111Offset',{name,base:local(base),bytes:word(bytes)});
const ret=()=>tag('N111Return',{value:word()});
const ids=[0,1,2,3,65535,2147483648,4294967295];
const name=id=>'id_'+id;
const sorted=rows=>[...rows].sort((x,y)=>x[0]<y[0]?-1:x[0]>y[0]?1:0);
const flowProjection=flow=>({rows:S.semanticRows(flow.live),terminal:flow.terminal,error:flow.error});
const scanProjection=scan=>({rows:S.semanticRows(scan.index),error:scan.error,count:scan.count});
const scalarRows=values=>sorted(values.map(id=>[name(id),'local',2,0]));
// Expected intersections are literal independent fixtures, not a host map algorithm.
const fixtures=[
  {name:'equal-mask-same-prefix',yes:[0,1],no:[1,0],expected:[0,1]},
  {name:'equal-mask-different-prefix',yes:[0,2],no:[1,3],expected:[]},
  {name:'left-broader',yes:[0,1,2,3],no:[0,2],expected:[0,2]},
  {name:'right-broader',yes:[0,2],no:[0,1,2,3],expected:[0,2]},
  {name:'left-broader-prefix-mismatch',yes:[0,2],no:[3,65535],expected:[]},
  {name:'right-broader-prefix-mismatch',yes:[3,65535],no:[0,2],expected:[]},
  {name:'singleton-left',yes:[0],no:[0,1],expected:[0]},
  {name:'singleton-right',yes:[0,1],no:[1],expected:[1]},
  {name:'singleton-absent',yes:[0],no:[1,2],expected:[]},
  {name:'empty-left',yes:[],no:[0,1],expected:[]},
  {name:'empty-right',yes:[0,1],no:[],expected:[]},
  {name:'collapse-one-child',yes:[0,1],no:[0,2],expected:[0]},
  {name:'high-bit-equal-mask',yes:[0,2147483648],no:[2147483648,0],expected:[0,2147483648]},
  {name:'high-bit-unsigned-branch',yes:[0,2147483648],no:[2147483648,4294967295],expected:[2147483648]},
  {name:'all-seven-identities',yes:[0,1,2,3,65535,2147483648,4294967295],no:[4294967295,2147483648,65535,3,2,1,0],expected:[0,1,2,3,65535,2147483648,4294967295]},
  {name:'retained-seed',seed:[65535],yes:[0,1],no:[1,2],expected:[1,65535]},
];

try{
  const baseline=await S.checked(a.baseline),candidate=await S.checked(a.candidate);
  inputs.push(...baseline.inputs,...candidate.inputs);S.originalIdentity(baseline,candidate);
  report.baseline=baseline.receipt.api;report.candidate=candidate.receipt.api;
  report.canonicalSourceIdentity=candidate.preparation.canonicalSourceIdentity;
  // Baseline02 does not export schema/flow helpers. The candidate exports their
  // unchanged canonical bodies; authenticate those exact declarations explicitly.
  const api=candidate.api;
  const needed=['missing','p111v_put','p111v_schema','p111v_body','p147v_put','p147v_schema','p147v_body','p147n_seed','p147test_scan','p147test_flow'];
  for(const key of needed)assert(candidate.receipt.exports.includes(key)&&typeof api[key]==='function','Missing checked helper: '+key);
  for(const key of ['p111v_put','p111v_schema','p111v_body']){
    const get=x=>x.preparation.declarations.find(r=>r.kind==='def'&&r.name===key&&r.source==='canonical');
    const left=get(baseline),right=get(candidate);assert(left&&right&&S.same(left,right),'Original helper differs: '+key);
  }
  report.originalHelperSource='Byte-identical canonical original helpers exported by candidate, independently bound to baseline02 declaration identities.';
  const globalIds=tag('N111Ids',{functions:api.missing(),constructors:api.missing()});
  function maps(rows){
    let original=api.missing(),compact=empty();
    for(const row of rows){
      assert(Number.isInteger(row.id)&&row.id>=0&&row.id<=4294967295);
      original=api.p111v_put(original,row.name,row.kind,row.width,row.capacity);
      compact=api.p147v_put(compact,row.name,row.id,{local:0,alloca:1,parameter:2}[row.kind],row.width,row.capacity);
    }
    return{original,compact};
  }
  function trial(fixture,schemaRows,seedRows,yes,no,expectedRows){
    assert.equal(new Set(schemaRows.map(r=>r.id)).size,schemaRows.length);
    assert.equal(new Set(schemaRows.map(r=>r.name)).size,schemaRows.length);
    for(const seed of seedRows)assert(schemaRows.some(r=>JSON.stringify(r)===JSON.stringify(seed)),'Seed not a coherent schema subset');
    const schema=maps(schemaRows),seed=maps(seedRows);
    const before={rows:sorted(seedRows.map(r=>[r.name,r.kind,r.width,r.capacity])),terminal:false,error:''};
    const originalFlow=tag('P111VFlow',{live:seed.original,terminal:false,error:''});
    const compactFlow=tag('P147VFlow',{live:tag('P147VEnv',{schema:schema.compact,assigned:api.p147n_seed(seed.compact,nil())}),terminal:false,error:''});
    assert.deepEqual(flowProjection(originalFlow),before);
    assert.deepEqual(flowProjection(api.p147test_flow(compactFlow)),before);
    const schemaBefore=scanProjection(api.p147test_scan(tag('P147VScan',{index:schema.compact,error:'',count:schemaRows.length})));
    const retained=JSON.stringify(compactFlow);
    const body=S.list([tag('N111If',{condition:word(),yes:S.list(yes),no:S.list(no)})]);
    const expected={rows:sorted(expectedRows),terminal:false,error:''};
    const original=flowProjection(api.p111v_body(body,schema.original,originalFlow,globalIds,0,0,1));
    const actual=flowProjection(api.p147test_flow(api.p147v_body(body,schema.compact,compactFlow,globalIds,0,0,1)));
    assert.deepEqual(original,expected,fixture+' independent original expectation');
    assert.deepEqual(actual,expected,fixture+' complete numeric-map flow');
    assert.deepEqual(flowProjection(originalFlow),before,fixture+' original seed unchanged');
    assert.deepEqual(flowProjection(api.p147test_flow(compactFlow)),before,fixture+' numeric seed unchanged');
    assert.equal(JSON.stringify(compactFlow),retained,fixture+' retained immutable data unchanged');
    assert.deepEqual(scanProjection(api.p147test_scan(tag('P147VScan',{index:schema.compact,error:'',count:schemaRows.length}))),schemaBefore,fixture+' full schema unchanged');
    report.rows.push({name:fixture,ids:schemaRows.map(r=>r.id),expected,actual,original,seedBefore:before,seedUnchanged:true,schemaUnchanged:true,passed:true});save();
  }
  const schemaRows=ids.map(id=>({name:name(id),id,kind:'local',width:2,capacity:0}));
  for(const f of fixtures)trial(f.name,schemaRows,schemaRows.filter(r=>(f.seed??[]).includes(r.id)),
    f.yes.map(id=>set(name(id))),f.no.map(id=>set(name(id))),scalarRows(f.expected));
  const capacitySchema=schemaRows.map(row=>row.id===4294967295?{...row,kind:'alloca',width:3,capacity:32}:row.id===2147483648?{...row,width:3}:row);
  const capacitySeed=capacitySchema.filter(r=>r.id===4294967295),pointer=name(2147483648),buffer=name(4294967295);
  for(const f of [{name:'equal-capacities',yes:8,no:8,capacity:24},{name:'different-capacities-preserve-presence',yes:0,no:8,capacity:0}]){
    trial(f.name,capacitySchema,capacitySeed,[offset(pointer,buffer,f.yes)],[offset(pointer,buffer,f.no)],
      [[buffer,'alloca',3,32],[pointer,'local',3,f.capacity]]);
  }
  trial('capacity-join-with-asymmetric-scalar-tree',capacitySchema,capacitySeed,
    [set(name(0)),set(name(1)),offset(pointer,buffer,8)],[set(name(1)),offset(pointer,buffer,0)],
    [[buffer,'alloca',3,32],[pointer,'local',3,0],[name(1),'local',2,0]]);
  for(const f of [
    {name:'last-declaration-at-count-65535',body:[set('edge')],error:''},
    {name:'same-declaration-with-trailing-statement',body:[set('edge'),ret()],error:'too many segment locals'},
  ]){
    const body=S.list(f.body),expected={rows:[['edge','local',2,0]],error:f.error,count:65536};
    const original=scanProjection(api.p111v_schema(body,tag('P111VScan',{index:api.missing(),error:'',count:65535})));
    const actual=scanProjection(api.p147test_scan(api.p147v_schema(body,tag('P147VScan',{index:empty(),error:'',count:65535}))));
    assert.deepEqual(original,expected,f.name+' original helper boundary');assert.deepEqual(actual,expected,f.name+' candidate helper boundary');
    report.countBoundaries.push({name:f.name,syntheticInitialCount:65535,completeEntryExhaustion:false,expected,original,actual,passed:true});save();
  }
  inputs.forEach(S.verify);report.complete=report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,flowCases:report.rows.length,countCases:report.countBoundaries.length,error:report.error}))}
