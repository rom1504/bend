// Synthetic checked-IR controls. Root alone executes this file and native pairs.
// The arithmetic/readback oracles are independent of the region planner.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiFile,outDir]=process.argv.slice(2);
if(!apiFile||!outDir)throw Error('Usage: region-multi-wide32-controls.mjs API FRESH_OUT');
const api=(await import(pathToFileURL(path.resolve(apiFile)).href)).default;
fs.mkdirSync(outDir);
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const local=name=>({$:'N111Local',name}),word=lo=>({$:'N111Const',lo,hi:0});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const state=()=>arg(ptr,local('state')),scratch=()=>arg(ptr,local('scratch'));
const call=(name,symbol,args)=>({$:'N111Call',name,typ:l,symbol,args:list(args)});
const ret=name=>({$:'N111Return',value:local(name)});
const store=(i,value)=>({$:'N111Store',typ:l,base:local('scratch'),offset:8*i,value});
const alloc={$:'N111Alloca',name:'scratch',bytes:2048,align:8};
const get=(name,i)=>call(name,'p111_rt_reg_get',[state(),arg(w,word(i))]);
const bin=(name,op,left,right)=>({$:'N111Bin',name,typ:l,op,left,right});
const sink=value=>call('ignored','p111_rt_sink',[state(),arg(l,value)]);
const keep=(name,value)=>call(name,'p111_rt_keep',[state(),arg(l,value)]);
const jump=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('reply','p111_rt_jump',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))]),ret('reply')];
const result=value=>[store(0,value),call('reply','p111_rt_return',[state(),scratch(),arg(w,word(1))]),ret('reply')];
const frame=(name,vs)=>[...vs.map((v,i)=>store(i,v)),call('ignored','p111_rt_frame',[state(),arg(w,{$:'N111FuncId',name}),scratch(),arg(w,word(vs.length))])];
const ctor=(name,cid,count)=>call(name,'p111_rt_ctor',[state(),arg(w,{$:'N111CtorId',name:cid}),scratch(),arg(w,word(count))]);
const segment=(name,arity,body,incoming=0)=>({$:'N111Segment',name,arity,result:1,incoming,flags:0,body:list(body)});
const entry=(name,params,body)=>segment(name,params.length,[alloc,...params.map(get),...body]);
const continuation=(name,captures,res,body)=>segment(name,captures.length+1,[alloc,
  ...(captures.length?[call('ignored','p111_rt_stack_pop',[state(),arg(w,word(captures.length))])]:[]),
  ...captures.map((name,i)=>call(name,'p111_rt_stack_get',[state(),arg(w,word(i))])),get(res,0),...body],1);
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const program=(segments,string=false)=>({$:'P111Program',segments:list(segments),constructors:list(core.map(([name,arity])=>
  ({$:'N_Constructor',name,arity,hot:arity>0}))),show:list([string?4:0]),show_names:list([]),effects:list([]),pure:true});
const observations=[],refusals=[];
const load=(name,i)=>({$:'N111Load',name,typ:l,base:local('scratch'),offset:8*i});
function productProgram(segments,n,stringFields=false,stringResult=false){
  const fields=2*n,scalarOffset=6+2*fields;
  const show=stringResult?[4]:[7,1,1,0,core.length+1,fields,...Array.from({length:fields},(_,i)=>[i,scalarOffset]).flat(),stringFields?4:0];
  return {$:'P111Program',segments:list(segments),constructors:list([...core,['ArgProduct',n],['WideResult',fields]].map(([name,arity])=>
    ({$:'N_Constructor',name,arity,hot:arity>0}))),show:list(show),show_names:list(stringResult?[]:['WideResult']),effects:list([]),pure:true};
}
function shape(n){
  const names=Array.from({length:n},(_,i)=>'p'+i),caps=names.map((_,i)=>'c'+i),taken=names.map((_,i)=>'a'+i);
  const permCaps=[...names.keys()].filter(i=>i%2).reverse().concat([...names.keys()].filter(i=>!(i%2)));
  const permArgs=[...names.keys()].map(i=>(i+Math.floor(n/2)+1)%n).reverse();
  const leafOrder=[...names.keys()].map(i=>(i+3)%n);
  const resultOrder=[...names.keys()].reverse();
  const leaf=entry('wide_leaf',names,[...leafOrder.map((i,slot)=>store(slot,local(names[i]))),ctor('args_product','ArgProduct',n),...result(local('args_product'))]);
  const returnedFields=resultOrder.flatMap(i=>[local(caps[i]),local(taken[(i+1)%n])]);
  const resume=continuation('wide_resume',caps,'args_product',[
    call('ignored','p111_rt_take',[state(),arg(l,local('args_product')),scratch(),arg(w,word(n))]),
    ...taken.map((name,i)=>load(name,i)),...returnedFields.map((value,i)=>store(i,value)),ctor('answer','WideResult',2*n),...result(local('answer'))]);
  return {names,caps,permCaps,permArgs,leafOrder,resultOrder,leaf,resume};
}
function emit(name,p,expected,n){
  assert.equal(api.p111_verify_program(p),'',name+': original verifier');
  const index=api.p112c_index(p.segments),segments=unlist(p.segments),ids=api.p111q_ids(p);
  const transformed=api.p112c_plan_index(segments[0],api.p112f_index(p.segments),index.ready);
  assert.equal(transformed.count,1,name+': wide site fused');
  assert.equal(transformed.next,1,name+': one fresh site');
  const candidate=unlist(api.p112c_segment_chunks(p.segments,ids,list([])));
  const text=candidate.join('');
  const privateLeafStart=text.indexOf('function l $'+api.p112w_symbol('wide_leaf')+'(');
  assert.ok(privateLeafStart>=0,name+': private wide leaf');
  const privateHeader=text.slice(privateLeafStart).split('\n')[0];
  assert.equal((privateHeader.match(/l %/g)||[]).length,n+1,name+': state plus every owned arg');
  assert.ok(text.includes('p112f_0_capture_'+(n-1)),name+': final capture snapshotted');
  assert.ok(text.includes('p112f_0_arg_'+(n-1)),name+': final argument snapshotted');
  const metadata=unlist(api.p111q_chunks(p)).slice(segments.length);
  fs.writeFileSync(path.join(outDir,name+'-baseline.ssa'),[...segments.map(s=>api.p111q_segment(s,ids)),...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'-candidate.ssa'),[...candidate,...metadata].join(''));
  fs.writeFileSync(path.join(outDir,name+'.stdout'),expected+'\n');
  observations.push({name,ownedArgs:n,captures:n,machineArgs:n+1,expected:expected+'\n',counts:api.p112c_program_counts(p),targetsExecuted:false});
}
for(const n of [9,16,32]){
  const s=shape(n),capValues=s.names.map((_,i)=>1009+37*i),argValues=s.names.map((_,i)=>3001+43*i);
  const main=entry('main',[],[...frame('wide_resume',s.permCaps.map(i=>word(capValues[i]))),...jump('wide_leaf',s.permArgs.map(i=>word(argValues[i])))]);
  const fields=s.resultOrder.flatMap(i=>[capValues[s.permCaps[i]],argValues[s.permArgs[s.leafOrder[(i+1)%n]]]]);
  emit('wide-permutation-'+n,productProgram([main,s.leaf,s.resume],n),'WideResult{'+fields.join(', ')+'}',n);
}
function string(prefix,text){
  const body=[ctor(prefix+'0','SNil',0)];let at=prefix+'0',i=0;
  for(const char of [...text].reverse()){
    const next=prefix+(++i);body.push(store(0,word(char.codePointAt(0))),store(1,local(at)),ctor(next,'SCon',2));at=next;
  }
  return {body,value:local(at)};
}
for(const productFirst of [true,false]){
  const n=9,s=shape(n),a=string('shared','α😀');
  // 2*n+1 owning credits: n captures, n arguments and one pending outer alias.
  const keeps=Array.from({length:2*n},(_,i)=>keep('owner',i===0?a.value:local('owner')));
  const main=entry('main',[],[...a.body,...keeps,...frame('outer',[local('owner')]),
    ...frame('wide_resume',Array(n).fill(local('owner'))),...jump('wide_leaf',Array(n).fill(local('owner')))]);
  const outer=continuation('outer',['alias'],'value',[sink(local(productFirst?'value':'alias')),...result(local(productFirst?'alias':'value'))]);
  const p=productProgram([main,s.leaf,s.resume,outer],n,true,productFirst);
  const expected=productFirst?'"α😀"':'WideResult{'+Array(2*n).fill('"α😀"').join(', ')+'}';
  emit(productFirst?'wide-alias-product-first':'wide-alias-alias-first',p,expected,n);
}
function refuse(name,p,expectedSites=0){
  assert.equal(api.p111_verify_program(p),'',name+': generic IR remains legal');
  const index=api.p112c_index(p.segments),first=unlist(p.segments)[0];
  assert.equal(api.p112c_plan_index(first,api.p112f_index(p.segments),index.ready).count,expectedSites,name+': no wide fusion');
  assert.equal(unlist(index.entries).some(e=>e.segment.name==='main'),false,name+': private main refused');
  refusals.push({name,originalValid:true,sites:expectedSites,targetsExecuted:false});
}
const tooWide=shape(33);
refuse('thirty-three-arguments',productProgram([
  entry('main',[],[...frame('resume',[]),...jump('wide_leaf',Array.from({length:33},(_,i)=>word(i)))]),tooWide.leaf,
  continuation('resume',[],'value',result(local('value')))],33));
const captureNames=Array.from({length:33},(_,i)=>'c'+i);
refuse('thirty-three-captures',program([
  entry('main',[],[...frame('resume',captureNames.map((_,i)=>word(i))),...jump('identity',[word(7)])]),
  entry('identity',['x'],result(local('x'))),continuation('resume',captureNames,'value',result(local('value')))]));
fs.writeFileSync(path.join(outDir,'report.json'),JSON.stringify({kind:'phase112-wide-continuation-fusion-controls',complete:true,
  sourceKind:'synthetic-verified-N111-ABI-witness',observations,refusals,targetsExecuted:false},null,2)+'\n');
console.log(JSON.stringify({complete:true,observations:observations.length,refusals:refusals.length}));
