// Independent finite IR/error controls. No generated invalid IR is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const [receiptArg,outArg]=process.argv.slice(2);
assert(receiptArg&&outArg,'Usage: controls-v01.mjs CHECKED_API_REPORT FRESH_PHASE144_OUT');
const ROOT=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(ROOT+'/selfhost/build/phase144/')&&!fs.existsSync(out));
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')}};
const rec=JSON.parse(fs.readFileSync(receiptArg));assert(rec.complete&&rec.checked);
const verify=p=>assert.deepEqual(pin(p.file),p);
const inputs=[pin(import.meta.filename),pin(receiptArg),rec.api,...rec.inputs];inputs.forEach(verify);
const required=['p111_verify_program','p144v_verify_program','p111v_schema','p144v_schema','p111v_body','p144v_body','p111v_put','p144v_put','missing'];
for(const name of required)assert(rec.exports.includes(name),name);
fs.mkdirSync(out);fs.copyFileSync(import.meta.filename,out+'/method.mjs');
const report={kind:'phase144-private-typed-verifier-controls',complete:false,inputs,rows:[],scope:'Independent finite expected errors, complete canonical schemas and complete flow/live-map comparisons. Host builds and compares data only. Not a theorem, arbitrary malformed private-trie equivalence, ownership proof or native execution.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const arr=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail}assert.equal(xs.$,'Nil');return a};
const u32={$:'N111U32'},u64={$:'N111U64'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi}),local=name=>({$:'N111Local',name});
const set=(name,value=word(7),typ=u64)=>({$:'N111Set',name,typ,value});
const ret=(value=word(0))=>({$:'N111Return',value});
const branch=(yes,no,condition=word(1))=>({$:'N111If',condition,yes:list(yes),no:list(no)});
const alloc=(name='buf',bytes=16,align=8)=>({$:'N111Alloca',name,bytes,align});
const offset=(name='p',bytes=word(8),base=local('buf'))=>({$:'N111Offset',name,base,bytes});
const load=(name='x',base=local('buf'),offset=0,typ=u64)=>({$:'N111Load',name,typ,base,offset});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const call=(symbol,args,name='r',typ=u64)=>({$:'N111Call',name,typ,symbol,args:list(args)});
const segment=(body,name='main',more={})=>({$:'N111Segment',name,arity:0,result:1,incoming:0,flags:0,body:list(body),...more});
const program=(segments,constructors=[])=>({$:'P111Program',segments:list(segments),constructors:list(constructors),show:list([0]),show_names:list([]),effects:list([]),pure:true});
const cases=[];
const add=(name,body,error='',more={})=>cases.push({name,program:program([segment(body,'main',more)]),error:error?'main: '+error:''});
add('return',[ret()]);
add('u64-assignment',[set('x'),ret(local('x'))]);
add('repeat-same-width',[set('x'),set('x',word(9)),ret(local('x'))]);
add('real-hash-collision',[set('Unit'),set('p143CollisionlrXlHP',word(11)),ret(local('Unit'))]);
add('both-arm-definition',[branch([set('x')],[set('x',word(8))]),ret(local('x'))]);
add('one-arm-terminal',[branch([ret()],[set('x')]),ret(local('x'))]);
add('both-arm-terminal',[branch([ret()],[ret(word(7))])]);
add('nested-join',[branch([branch([set('x')],[set('x')])],[set('x')]),ret(local('x'))]);
add('allocation-load',[alloc(),load(),ret(local('x'))]);
add('pointer-offset',[alloc(),offset(),load('x',local('p')),ret(local('x'))]);
add('equal-capacity-join',[alloc(),branch([offset()],[offset()]),load('x',local('p')),ret(local('x'))]);
add('different-capacity-join',[alloc(),branch([offset()],[offset('p',word(0))]),load('x',local('p')),ret(local('x'))], 'unbounded, unaligned or ill-typed load');
add('terminal-arm-preserves-capacity',[alloc(),branch([ret()],[offset()]),load('x',local('p')),ret(local('x'))]);
add('runtime-state-call',[call('p111_rt_keep',[arg(ptr,local('state')),arg(u64,word(3))]),ret(local('r'))]);
add('missing-local',[ret(local('missing'))],'segment return must be U64');
add('return-u32-local',[set('x',word(1),u32),ret(local('x'))],'segment return must be U64');
add('nonterminal',[set('x')],'segment has a nonterminal path');
add('after-terminal',[ret(),set('x')],'statement follows terminal path');
add('reserved-state',[set('state')],'invalid/reserved local name: state');
add('empty-local',[set('')],'invalid/reserved local name: ');
add('leading-number',[set('1x')],'invalid/reserved local name: 1x');
add('unicode-local',[set('λ')],'invalid/reserved local name: λ');
add('long-local',[set('a'.repeat(129))],'invalid/reserved local name: '+'a'.repeat(129));
add('width-change',[set('x'),set('x',word(1),u32)],'local width/allocation changes: x');
add('repeated-alloca',[alloc(),alloc()],'local width/allocation changes: buf');
add('alloca-after-local',[set('buf',word(0),ptr),alloc()],'local width/allocation changes: buf');
add('schema-before-flow-error',[ret(local('missing')),set('state')],'invalid/reserved local name: state');
add('branch-schema-yes-first',[branch([set('state')],[set('1bad')])],'invalid/reserved local name: state');
add('undefined-condition',[branch([ret()],[ret()],local('notLive'))],'condition must be a definitely assigned U32');
add('one-arm-only-definition',[branch([set('x')],[]),ret(local('x'))],'segment return must be U64');
add('branch-error-yes-first',[branch([ret(local('x'))],[load()])],'segment return must be U64');
add('unaligned-load',[alloc(),load('x',local('buf'),1),ret(local('x'))],'unbounded, unaligned or ill-typed load');
add('overflow-load',[alloc(),load('x',local('buf'),4294967295),ret(local('x'))],'unbounded, unaligned or ill-typed load');
add('zero-allocation',[alloc('buf',0),ret()],'unsupported stack allocation size/alignment');
add('large-allocation',[alloc('buf',2049),ret()],'unsupported stack allocation size/alignment');
add('bad-alignment',[alloc('buf',16,2),ret()],'unsupported stack allocation size/alignment');
add('offset-past-capacity',[alloc(),offset('p',word(17)),ret()],'unbounded or ill-typed pointer offset');
add('unknown-runtime-call',[call('not_an_import',[arg(ptr,local('state'))]),ret()],'runtime import signature/count/capacity mismatch: not_an_import');
add('wrong-state-argument',[alloc(),call('p111_rt_keep',[arg(ptr,local('buf')),arg(u64,word(1))]),ret()],'runtime import signature/count/capacity mismatch: p111_rt_keep');
add('wrong-runtime-arity',[call('p111_rt_keep',[arg(ptr,local('state'))]),ret()],'runtime import signature/count/capacity mismatch: p111_rt_keep');
cases.push({name:'missing-main',program:program([segment([ret()],'other')]),error:'program requires a direct, zero-argument main segment'});
cases.push({name:'duplicate-function',program:program([segment([ret()]),segment([ret()])]),error:'invalid/duplicate segment name: main'});
cases.push({name:'function-arity-bound',program:program([segment([ret()],'main',{arity:256})]),error:'segment metadata exceeds ABI capacity: main'});
cases.push({name:'duplicate-constructor',program:program([segment([ret()])],[{$:'N_Constructor',name:'A',arity:0,hot:false},{$:'N_Constructor',name:'A',arity:1,hot:true}]),error:'invalid/duplicate constructor name: A'});
const absentTerm=()=>({$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:list([]),removed:list([]),originBegin:0,originEnd:0});
const oldEntry=e=>({$:'KDef',name:e.name,kind:e.kind,arity:e.width,templates:e.capacity,typ:absentTerm(),value:absentTerm(),ctors:list([]),native:false,unsafe:false});
function tree(t,missing){switch(t.$){case'P144VTEmpty':return missing;case'P144VTLeaf':return{$:'KIndexLeaf',hash:t.hash,bucket:list(arr(t.bucket).map(oldEntry))};case'P144VTNode':return{$:'KIndexNode',hash:t.hash,mask:t.mask,left:tree(t.left,missing),right:tree(t.right,missing)};default:throw Error('Unknown private tree '+t.$)}}
try{
 const api=(await import(pathToFileURL(rec.api.file))).default,missing=api.missing();
 const oldIds={$:'N111Ids',functions:missing,constructors:missing},newIds={$:'P144VIds',functions:{$:'P144VTEmpty'},constructors:{$:'P144VTEmpty'}};
 for(const c of cases){
  const original=api.p111_verify_program(c.program),candidate=api.p144v_verify_program(c.program);
  assert.equal(original,c.error,c.name+' independent original error');assert.equal(candidate,c.error,c.name+' independent candidate error');
  let stateChecks=0;
  for(const s of arr(c.program.segments)){
   const os=api.p111v_put(missing,'state','parameter',3,2088),ns=api.p144v_put({$:'P144VTEmpty'},'state','parameter',3,2088);
   const a=api.p111v_schema(s.body,{$:'P111VScan',index:os,error:'',count:1});
   const b=api.p144v_schema(s.body,{$:'P144VScan',index:ns,error:'',count:1});
   assert.deepEqual({index:tree(b.index,missing),error:b.error,count:b.count},{index:a.index,error:a.error,count:a.count},c.name+' complete schema');stateChecks++;
   if(!a.error){
    const x=api.p111v_body(s.body,a.index,{$:'P111VFlow',live:os,terminal:false,error:''},oldIds,s.arity,s.incoming,s.result);
    const y=api.p144v_body(s.body,b.index,{$:'P144VFlow',live:ns,terminal:false,error:''},newIds,s.arity,s.incoming,s.result);
    assert.deepEqual({live:tree(y.live,missing),terminal:y.terminal,error:y.error},{live:x.live,terminal:x.terminal,error:x.error},c.name+' complete flow');stateChecks++;
   }
  }
  report.rows.push({name:c.name,error:c.error,completeStateChecks:stateChecks,passed:true});save();
 }
 inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack||e);process.exitCode=1}
finally{save();console.log(JSON.stringify({complete:report.complete,controls:report.rows.length,error:report.error}))}
