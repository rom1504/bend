// Independent structural controls only. Synthetic IR is never executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('controls.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p113a_verify','p113a_chunks','p113a_stmt_id','p113a_template','p113a_scan',
  'p113a_heap_min','p113a_enabled','p113a_body_names','p113d_verify'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x)))throw Error('Checked exports missing');
const apiPin=pin(apiFile);
if(receipt.api.sha256!==apiPin.sha256||receipt.api.bytes!==apiPin.bytes)throw Error('Checked API pin mismatch');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-array-fast-structural-controls',complete:false,
  inputs:[pin(import.meta.filename),apiPin,pin(receiptFile)],controls:[],
  scope:'Independent structural admission/template assertions; synthetic IR is never executed. Source/native/runtime evidence is separate.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
const api=(await import(pathToFileURL(apiFile))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];for(;xs?.$==='Con';xs=xs.tail)out.push(xs.head);assert.equal(xs?.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi}),local=name=>({$:'N111Local',name});
const arg=(typ,value)=>({$:'N111Arg',typ,value}),scalar=stmt=>({$:'P113DScalar',stmt});
const arrCall=(id,{symbol=id===73?'p111_rt_op':'p113_rt_array_pair',
  input='scratch',output='p113p_out_0',count=id===72?2:(id===73||id===74?3:1),outputs=2,state='state'}={})=>
  ({$:'N111Call',name:'status',typ:l,symbol,args:list([
    arg(ptr,local(state)),arg(w,word(id)),arg(ptr,local(input)),arg(w,word(count)),
    ...(id===73?[]:[arg(ptr,local(output)),arg(w,word(outputs))])])});
const walk=nodes=>unlist(nodes).flatMap(x=>[x,...(x.$==='N111If'?[...walk(x.yes),...walk(x.no)]:[])]);
const template=(id,n=0)=>unlist(api.p113a_template(arrCall(id),n,51413632));
const test=(name,fn)=>{try{fn();report.controls.push({name,pass:true});}catch(e){report.controls.push({name,pass:false,error:String(e)});save();throw e;}};
for(const id of [72,73,74,75])test(`recognize-${id}`,()=>assert.equal(api.p113a_stmt_id(arrCall(id)),id));
for(const [name,stmt] of [
  ['clone',arrCall(76)],['unknown-op',arrCall(77)],['wrong-count',arrCall(72,{count:3})],
  ['wrong-output-count',arrCall(72,{outputs:1})],['state-buffer',arrCall(72,{input:'state'})],
  ['wrong-import',arrCall(72,{symbol:'other'})],['wrong-state',arrCall(73,{state:'scratch'})]
])test(`refuse-${name}`,()=>{assert.equal(api.p113a_stmt_id(stmt),0);assert.deepEqual(unlist(api.p113a_template(stmt,0,51413632)),[stmt]);});
test('certificate-conjunction',()=>{
  for(const scalar of [false,true])for(const unshared of [false,true])
    assert.equal(api.p113a_enabled({$:'P113ACertificate',scalar,unshared}),scalar&&unshared);
});
test('descriptor-heap-boundary',()=>{
  assert.equal(api.p113a_heap_min(list([])),51413504);
  const node=n=>({$:'P112SNode',offset:0,name:'X',fields:list(Array.from({length:n},()=>({$:'P112SRaw',value:0})))});
  assert.equal(api.p113a_heap_min(list([node(1)])),51413632);
  assert.equal(api.p113a_heap_min(list([node(128)])),51413632);
  assert.equal(api.p113a_heap_min(list([node(129)])),51413760);
});
test('all-inputs-before-branch',()=>{
  for(const [id,count] of [[72,2],[73,3],[74,3],[75,1]]){
    const body=template(id);
    assert.deepEqual(body.slice(0,count).map(x=>[x.$,x.base.name,x.offset]),
      Array.from({length:count},(_,i)=>['N111Load','scratch',i*8]));
    assert(!body.some(x=>x.$==='N111Store'));
    const branch=body.at(-1);assert.equal(branch.$,'N111If');
    assert.deepEqual(unlist(branch.no),[arrCall(id)]);
  }
});
test('raw-rfc-static-guards',()=>{
  const body=template(72),bins=body.filter(x=>x.$==='N111Bin');
  assert(bins.some(x=>x.op==='shr'&&x.right.lo===56));
  assert(bins.some(x=>x.op==='eq'&&x.right.lo===6));
  assert(bins.some(x=>x.op==='uge'&&x.right.lo===51413632));
  assert.equal(bins.at(-1).op,'and');assert.equal(bins.at(-1).typ.$,'N111U32');
});
test('index-width-mask-and-uniform-address',()=>{
  const nodes=walk(list(template(72)));
  for(const [role,op,lo,hi] of [['class','and',31,0],['index','and',4294967295,0],
    ['location','and',4294967295,255],['bytes','shl',3,0]])
    assert(nodes.some(x=>x.$==='N111Bin'&&x.name===`p113a_0_${role}`&&x.op===op&&x.right.lo===lo&&x.right.hi===hi));
  assert(nodes.some(x=>x.$==='N111Offset'&&x.bytes.name==='p113a_0_bytes'));
});
test('size-never-reads-heap',()=>assert(!walk(list(template(75))).some(x=>x.$==='N111Load'&&x.typ.$==='N111Ptr')));
test('scalar-guards-before-mutation',()=>{
  for(const id of [72,73,74]){
    const raw=unlist(template(id).at(-1).yes),guard=raw.at(-1);
    assert.equal(guard.$,'N111If');assert.deepEqual(unlist(guard.no),[arrCall(id)]);
    assert(!raw.slice(0,-1).some(x=>x.$==='N111Store'));
    const roles=raw.filter(x=>x.$==='N111Bin'&&x.op==='ule').map(x=>x.name);
    assert.deepEqual(roles,id===72?['p113a_0_old_scalar']:id===74?['p113a_0_new_scalar']:['p113a_0_old_scalar','p113a_0_new_scalar']);
  }
});
test('set-return-array-pair-return-status',()=>{
  for(const id of [72,73,74,75]){
    const stores=walk(list(template(id))).filter(x=>x.$==='N111Set'&&x.name==='status');
    assert.equal(stores.length,1);
    assert.deepEqual(stores[0].value,id===73?local('p113a_0_array'):word(0));
  }
});
test('namespace-refuses-nested-destination',()=>{
  const bad=scalar({$:'N111Set',name:'p113a_7_old',typ:l,value:word(0)});
  assert.equal(api.p113a_body_names(list([bad])),false);
  assert.equal(api.p113a_body_names(list([{$:'P113DIf',condition:word(1),yes:list([]),no:list([bad])}])),false);
  assert.equal(api.p113a_body_names(list([{$:'P113DCall',destinations:list(['p113a_1_cell']),target:'x',args:list([])}])),false);
});
test('branch-freshness-monotonic',()=>{
  const scan=api.p113a_scan(list([
    {$:'P113DIf',condition:word(1),yes:list([scalar(arrCall(72))]),no:list([scalar(arrCall(75))])},
    scalar(arrCall(73))]),4,51413632);
  assert.equal(scan.next,7);
  const body=unlist(scan.body),yes=unlist(body[0].yes),no=unlist(body[0].no);
  assert.equal(yes[0].stmt.name,'p113a_4_array');assert.equal(no[0].stmt.name,'p113a_5_array');
  assert.equal(body[1].stmt.name,'p113a_6_array');
});
// The original verifier remains responsible for capacities/types/control flow.
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],
 ['Unit',0],['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const old={$:'P112StaticProgram',nodes:list([]),program:{$:'P111Program',segments:list([
 {$:'N111Segment',name:'main',arity:0,result:1,incoming:0,flags:0,body:list([{$:'N111Return',value:word(0)}])}]),
 constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),
 show:list([0]),show_names:list([]),effects:list([]),pure:true}};
const bundle=body=>({$:'P113DProgram',original:old,functions:list([{$:'P113DFunction',name:'$product.array_test',
 params:list([]),result:1,public:false,body:list(body)}])});
const wrapped=original=>({$:'P113AProgram',original,certificate:{$:'P113ACertificate',scalar:true,unshared:true}});
test('original-verifier-still-rejects-raw-heap',()=>{
 const bad=bundle([scalar({$:'N111Load',name:'raw',typ:ptr,base:local('state'),offset:0}),{$:'P113DResult',values:list([word(0)])}]);
 assert.notEqual(api.p113d_verify(bad),'');assert.notEqual(api.p113a_verify(wrapped(bad)),'');
 assert(unlist(api.p113a_chunks(wrapped(bad))).join('').startsWith('INVALID_P113_ARRAY_PROGRAM:'));
});
test('original-verifier-still-rejects-capacity',()=>{
 const bad=bundle([scalar({$:'N111Alloca',name:'p113p_out_0',bytes:8,align:8}),scalar(arrCall(72)),
   {$:'P113DResult',values:list([word(0)])}]);
 assert.notEqual(api.p113a_verify(wrapped(bad)),'');
});
report.complete=true;report.count=report.controls.length;save();
process.stdout.write(JSON.stringify({complete:true,controls:report.count,report:path.join(out,'report.json')})+'\n');
