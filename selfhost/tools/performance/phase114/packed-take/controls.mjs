// Inspect emission for ordinary Take1 call shapes; execute no generated IR.
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
for(const name of ['p114pk_shape','p114pk_buffer','p114pk_stmt','p111q_ids'])assert(receipt.exports?.includes(name));
assert(receipt.complete&&receipt.checked&&receipt.status===0);assert.deepEqual(receipt.api,pin(apiFile));
const api=(await import(pathToFileURL(apiFile))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const out=[];for(;xs?.$==='Con';xs=xs.tail)out.push(xs.head);assert.equal(xs?.$,'Nil');return out;};
const ptr={$:'N111Ptr'},word={$:'N111U64'},u32={$:'N111U32'};
const local=name=>({$:'N111Local',name}),arg=(typ,value)=>({$:'N111Arg',typ,value});
const call=(destination,input,output='scratch')=>({$:'N111Call',name:destination,typ:word,symbol:'p111_rt_take',args:list([
  arg(ptr,local('state')),arg(word,local(input)),arg(ptr,local(output)),arg(u32,{$:'N111Const',lo:1,hi:0})])});
const ids=api.p111q_ids({$:'P111Program',segments:list([]),constructors:list([]),show:list([]),show_names:list([]),effects:list([]),pure:true});
const initial=()=>({$:'P111QCode',chunks:list([]),next:0,terminal:false,error:''});
const render=(stmt,code=initial())=>api.p114pk_stmt(stmt,ids,code);
const text=code=>unlist(code.chunks).reverse().join('');
const report={kind:'phase114-packed-take-emission-controls',complete:false,inputs:[pin(import.meta.filename),pin(apiFile),pin(receiptFile)],controls:[],scope:'Source emission inspection only; ordinary packing fixtures supply independent native value/ownership checks.'};
fs.mkdirSync(out,{recursive:true});
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const test=(name,fn)=>{try{fn();report.controls.push({name,pass:true});}catch(e){report.controls.push({name,pass:false,error:String(e)});save();throw e;}};
save();
test('selected-factory-buffers',()=>{
  for(const output of ['scratch','p112f_7_local_scratch','p113i_3_local_scratch','p114h_case_0_local_scratch','p114h_case_7_local_scratch']){
    assert.equal(api.p114pk_buffer(output),true);assert.equal(api.p114pk_shape(call('status','owner',output)).$,'Some');
  }
});
const first=render(call('status','owner')),source=text(first);
test('byte-width-and-metadata',()=>{
  assert(source.includes(' =l add $p111_program, 24\n'));
  assert(source.includes(' =l add $p111_cid_arity, '));assert(source.includes(' =w loadub '));
  assert(source.indexOf(' =w cultl ')<source.indexOf(' =w loadub '));assert(source.includes(' =w ceqw %p114pk_0_arity, 1\n'));
});
test('full-payload-and-status-order',()=>{
  assert(source.includes(' =l and %p114pk_0_tag, 127\n'));
  assert(source.includes(' =l and %p114pk_0_term, 1099511627775\n'));
  assert(source.indexOf('storel %p114pk_0_payload, %v_scratch\n')<source.indexOf('%v_status =l copy 1\n'));
});
test('exact-original-helper-fallback',()=>{
  assert(source.includes('%v_status =l call $p111_rt_take(l %state, l %v_owner, l %v_scratch, w 1)\n'));
  assert.equal(first.error,'');assert.equal(first.terminal,false);
});
test('destination-input-alias',()=>{
  const alias=text(render(call('owner','owner')));
  assert(alias.startsWith('%p114pk_0_term =l copy %v_owner\n'));
  assert(alias.indexOf('storel %p114pk_0_payload, %v_scratch\n')<alias.indexOf('%v_owner =l copy 1\n'));
  assert(alias.includes('%v_owner =l call $p111_rt_take(l %state, l %v_owner, l %v_scratch, w 1)\n'));
});
test('fresh-sequential-sites',()=>{
  const second=render(call('status2','owner2'),first),both=text(second);
  assert(second.next>first.next&&first.next>0);
  assert(both.includes('@p114pk_0_join\n'));
  assert(both.includes(`@p114pk_${first.next}_join\n`));
});
report.complete=true;save();console.log(JSON.stringify({complete:true,controls:report.controls.length}));
