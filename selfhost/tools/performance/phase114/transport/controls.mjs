// Structural source controls only. No generated IR is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('controls.mjs CHECKED_API FRESH_PHASE114_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase114/')||fs.existsSync(out))throw Error('Fresh Phase114 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p114t_expand','p114t_buffer','p114t_namespace','p114t_negative_bytes','p114t_stmt','p111q_ids'];
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x)))throw Error('Checked exports missing');
const apiPin=pin(apiFile);
assert.deepEqual(receipt.api,apiPin);
const api=(await import(pathToFileURL(apiFile))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];for(;xs?.$==='Con';xs=xs.tail)out.push(xs.head);assert.equal(xs?.$,'Nil');return out;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi}),local=name=>({$:'N111Local',name});
const arg=(typ,value)=>({$:'N111Arg',typ,value});
const program={$:'P111Program',segments:list([{$:'N111Segment',name:'transport_cont',arity:3,result:1,incoming:1,flags:0,body:list([])}]),constructors:list([]),show:list([]),show_names:list([]),effects:list([]),pure:true};
const ids=api.p111q_ids(program);
const frame=(count,buffer='scratch')=>({$:'N111Call',name:'frame_status',typ:l,symbol:'p111_rt_frame',args:list([
  arg(ptr,local('state')),arg(w,{$:'N111FuncId',name:'transport_cont'}),arg(ptr,local(buffer)),arg(w,word(count))])});
const stack=(symbol,count)=>({$:'N111Call',name:'stack_value',typ:l,symbol,args:list([arg(ptr,local('state')),arg(w,word(count))])});
const expand=stmt=>api.p114t_expand(stmt,ids,7);
fs.mkdirSync(out,{recursive:true});
const report={kind:'phase114-transport-structural-controls',complete:false,inputs:[pin(import.meta.filename),apiPin,pin(receiptFile)],controls:[],scope:'Template tree/text assertions only; no generated IR/native execution. Ordinary source compilation/output gates are separate.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const test=(name,fn)=>{try{fn();report.controls.push({name,pass:true});}catch(e){report.controls.push({name,pass:false,error:String(e)});save();throw e;}};
save();
for(const count of [0,2,26])test(`frame-ordered-${count}`,()=>{
  const expansion=expand(frame(count));assert.equal(expansion.changed,true);
  const body=unlist(expansion.body);assert.equal(body.length,2*count+5);
  assert.deepEqual(body[0],{$:'N111Load',name:'p114t_7_sp',typ:ptr,base:local('state'),offset:16});
  for(let i=0;i<count;i++){
    assert.deepEqual(body[1+2*i],{$:'N111Load',name:'p114t_7_capture',typ:l,base:local('scratch'),offset:8*i});
    assert.deepEqual(body[2+2*i],{$:'N111Store',typ:l,base:local('p114t_7_sp'),offset:8*i,value:local('p114t_7_capture')});
  }
  assert.deepEqual(body.at(-4),{$:'N111Store',typ:l,base:local('p114t_7_sp'),offset:8*count,value:{$:'N111FuncId',name:'transport_cont'}});
  assert.deepEqual(body.at(-3),{$:'N111Offset',name:'p114t_7_next_sp',base:local('p114t_7_sp'),bytes:word(8*(count+1))});
  assert.deepEqual(body.at(-2),{$:'N111Store',typ:ptr,base:local('state'),offset:16,value:local('p114t_7_next_sp')});
  assert.deepEqual(body.at(-1),{$:'N111Set',name:'frame_status',typ:l,value:word(0)});
});
for(const count of [0,3])test(`pop-${count}`,()=>{
  const body=unlist(expand(stack('p111_rt_stack_pop',count)).body);
  assert.equal(body.length,4);
  const expected=count===0?word(0):word((2**32-count*8)>>>0,0xffffffff);
  assert.deepEqual(body[1].bytes,expected);assert.deepEqual(api.p114t_negative_bytes(count),expected);
  assert.equal(body[2].offset,16);assert.deepEqual(body[3].value,word(0));
});
for(const index of [0,2])test(`get-${index}`,()=>{
  const body=unlist(expand(stack('p111_rt_stack_get',index)).body);
  assert.equal(body.length,2);assert.equal(body[0].offset,16);
  assert.deepEqual(body[1],{$:'N111Load',name:'stack_value',typ:l,base:local('p114t_7_sp'),offset:index*8});
});
test('factory-buffers',()=>{
  for(const name of ['scratch','p112f_0_local_scratch','p112f_7_local_scratch','p113i_0_local_scratch','p113i_15_local_p113i_1_local_scratch'])assert.equal(api.p114t_buffer(name),true,name);
  for(const name of ['state','other','p112f_8_local_scratch','p113i_16_local_scratch'])assert.equal(api.p114t_buffer(name),false,name);
});
test('unsupported-buffer-keeps-exact-helper',()=>{
  const stmt=frame(2,'other'),actual=expand(stmt);assert.equal(actual.changed,false);assert.deepEqual(unlist(actual.body),[stmt]);
});
test('jump-return-remain-exact',()=>{
  for(const symbol of ['p111_rt_jump','p111_rt_return']){const stmt={...frame(2),symbol};const actual=expand(stmt);assert.equal(actual.changed,false);assert.deepEqual(unlist(actual.body),[stmt]);}
});
test('distinct-site-counter',()=>{
  const code={$:'P111QCode',chunks:list([]),next:0,terminal:false,error:''};
  const first=api.p114t_stmt(stack('p111_rt_stack_get',0),ids,code);
  const second=api.p114t_stmt(stack('p111_rt_stack_get',0),ids,first);
  assert(first.next>0&&second.next>first.next);
  const text=unlist(second.chunks).reverse().join('');
  assert(text.includes('%v_p114t_0_sp'));assert(text.includes(`%v_p114t_${first.next}_sp`));
  assert(!text.includes('call $p111_rt_stack_get'));assert.equal(second.error,'');
});
test('namespace-generic-and-private',()=>{
  const wrap=(segments,functions)=>({$:'P113AProgram',original:{$:'P113DProgram',original:{$:'P112StaticProgram',program:{...program,segments:list(segments)},nodes:list([])},functions:list(functions)},certificate:{$:'P113ACertificate',scalar:false,unshared:false}});
  const bad={$:'N111Set',name:'p114t_0_sp',typ:l,value:word(0)};
  const segment={...unlist(program.segments)[0],body:list([bad])};
  assert.equal(api.p114t_namespace(wrap([],[])),true);
  assert.equal(api.p114t_namespace(wrap([segment],[])),false);
  assert.equal(api.p114t_namespace(wrap([], [{$:'P113DFunction',name:'direct_test',params:list([]),result:1,public:false,body:list([{$:'P113DScalar',stmt:bad}])}])),false);
});
report.complete=true;save();console.log(JSON.stringify({complete:true,controls:report.controls.length}));
