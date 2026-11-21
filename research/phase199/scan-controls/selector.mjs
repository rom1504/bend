import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';

const args=process.argv.slice(2);
const o=Object.fromEntries(Array.from({length:args.length/2},(_,i)=>args.slice(i*2,i*2+2)));
assert(/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')));
const read=f=>JSON.parse(fs.readFileSync(f));
const receipt=read(o['--api']), capture=read(o['--capture']);
assert(receipt.checked&&receipt.complete); verify(receipt.api);verify(receipt.source);verify(capture.sourceApi);
const api=(await import(pathToFileURL(receipt.api.file))).default;
const out=path.resolve(o['--out']);fs.mkdirSync(out);
const original=capture.cases[0].workers.find(w=>w.pretty.endsWith('$product.fold.loop'));
assert(original);assert.equal(original.params.length,6);
const nil={$:'Nil'},lst=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
function flat(x){const a=[];while(x.$==='Con'){a.push(x.head);x=x.tail;}assert.equal(x.$,'Nil');return a;}
const clone=x=>JSON.parse(JSON.stringify(x));
const local=name=>({$:'N111Local',name}),num=lo=>({$:'N111Const',lo,hi:0}),u32={$:'N111U32'},u64={$:'N111U64'};
const copy=(name,value)=>({$:'P113DScalar',stmt:{$:'N111Set',name,typ:u64,value}});
const positions={dec:0,indexNarrow:1,inc:2,mask:3,scale:4,readPtr:5,read:6,carryNarrow:7,add:8,next:9,indexForXor:10,xor:11,writeCopy:12,writePtr:13,store:14,again:15};
function context(w){
  const entry=flat(w.body),outer=entry[1],nested=flat(outer.no),inner=nested[1],work=flat(inner.yes);
  assert.equal(work.length,16);
  const r={w,entry,outer,nested,inner,work,finish(){inner.yes=lst(work);outer.no=lst(nested);w.body=lst(entry);}};
  for(const [key,i] of Object.entries(positions))r[key]=work[i].stmt??work[i];
  return r;
}
const items=[];
function trial(name,admit,mutate=()=>{}){
  const w=clone(original),r=context(w);mutate(r);r.finish();
  const input=clone(w.body),actual=api.x199s_select(lst(w.params),w.body);
  const outer=flat(actual)[1],inner=flat(outer.no)[1],steps=flat(inner.yes);
  const calls=steps.filter(s=>s.stmt?.symbol==='p199_rt_u32_scan4');
  assert.equal(calls.length,admit?1:0,name);
  if(admit){
    const [state,outPtr,fuel,index,array,carry]=w.params;
    assert.equal(steps.length,2,name);assert.equal(calls[0].stmt.name,carry,name);
    assert.deepEqual(flat(calls[0].stmt.args).map(a=>[a.typ.$,a.value.name]),[
      ['N111Ptr','p113a_3_hoist_base'],['N111U64','p113a_3_hoist_mask'],['N111U64',fuel],['N111U64',index],['N111U64',carry]],name);
    assert.deepEqual(flat(steps[1].values),[local(array),local(carry)],name);
    assert.deepEqual(outer.yes,r.outer.yes,name);assert.deepEqual(inner.no,r.inner.no,name);
    assert.deepEqual(flat(actual)[0],r.entry[0],name);assert.deepEqual(flat(outer.no)[0],r.nested[0],name);
  } else assert.deepEqual(actual,input,name);
  items.push({name,admitted:admit});
  fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:false,items},null,2)+'\n');
}
trial('actual normalized worker',true);
trial('renamed inputs and all local definitions',true,r=>{
  const names=new Set(r.w.params.slice(2));
  function gather(x){if(!x||typeof x!=='object')return;if(['N111Set','N111Bin','N111Offset','N111Load','N111Call'].includes(x.$))names.add(x.name);for(const v of Object.values(x))gather(v);}
  gather(r.w.body);
  const rename=new Map([...names].map((name,i)=>[name,'scan_test_operand_'+i]));
  function rewrite(x){if(!x||typeof x!=='object')return;if(typeof x.name==='string'&&rename.has(x.name))x.name=rename.get(x.name);for(const v of Object.values(x))rewrite(v);}
  rewrite(r.w.body);r.w.params=r.w.params.map(n=>rename.get(n)??n);
});
trial('commuted addition and xor binary operands',true,r=>{for(const s of [r.inc,r.mask,r.scale,r.add,r.xor])[s.left,s.right]=[s.right,s.left];});
trial('extra transparent carry snapshot',true,r=>{r.work.splice(-1,0,copy('scan_test_credit',r.again.values.tail.tail.tail.head));r.again.values.tail.tail.tail.head=local('scan_test_credit');});
trial('retains a distinct unreachable diagnostic',true,r=>{r.inner.no.head.stmt.args.tail.head.value=num(37);});
trial('zero exit reverses output fields',false,r=>{r.outer.yes.head.values=lst(flat(r.outer.yes.head.values).reverse());});
trial('loop returns input carry',false,r=>{r.again.values.tail.tail.tail.head=local(r.w.params[5]);});
trial('backedge returns post-XOR carry',false,r=>{r.again.values.tail.tail.tail.head=local(r.xor.name);});
trial('backedge changes owner',false,r=>{r.again.values.tail.tail.head=local(r.w.params[4]+'_wrong');});
trial('nonzero fuel branch tested at two',false,r=>{r.nested[0].stmt.right=num(2);});
trial('zero guard checks upper-word nonzero constant',false,r=>{r.entry[0].stmt.right.hi=1;});
trial('fuel decreases by two',false,r=>{r.dec.right=num(2);});
trial('fuel decrement truncates U64',false,r=>{r.dec.typ=u32;});
trial('index increment truncation removed',false,r=>{r.inc.typ=u64;});
trial('index never advances',false,r=>{r.again.values.tail.head=local(r.w.params[3]);});
trial('different ring mask',false,r=>{r.mask.right=num(127);});
trial('unmasked pointer offset',false,r=>{r.scale.left=local(r.w.params[3]);});
trial('eight-byte physical spacing',false,r=>{r.scale.right=num(8);});
trial('different array origin on store',false,r=>{r.writePtr.base=local('p113a_2_hoist_base');});
trial('store addresses next slot',false,r=>{r.store.offset=4;});
trial('wide load touches a neighbor',false,r=>{r.read.typ=u64;});
trial('wide store touches a neighbor',false,r=>{r.store.typ=u64;});
trial('cell update subtracts',false,r=>{r.add.op='sub';});
trial('xor uses masked index',false,r=>{r.xor.right=local(r.mask.name);});
trial('xor uses incremented index',false,r=>{r.xor.right=local(r.inc.name);});
trial('store retains pre-xor prefix sum',false,r=>{r.store.value=local(r.next.name);});
trial('backedge reads wrong local after overwrite',false,r=>{r.work.splice(-1,0,copy(r.next.name,local(r.xor.name)));});
trial('writes ring metadata',false,r=>{r.work.splice(-1,0,copy('p113a_3_hoist_base',local(r.w.params[4])));});
trial('body mutates its incoming array local',false,r=>{r.work.splice(-1,0,copy(r.w.params[4],local(r.w.params[5])));});
trial('second read',false,r=>{r.work.splice(7,0,clone(r.work[6]));});
trial('second write',false,r=>{r.work.splice(-1,0,clone(r.work[14]));});
trial('observable foreign call',false,r=>{r.work.splice(-1,0,clone(r.inner.no.head));});
trial('duplicate physical parameter',false,r=>{r.w.params[3]=r.w.params[2];});
const report={complete:true,api:receipt.api,source:receipt.source,capture:pin(o['--capture']),method:pin(fileURLToPath(import.meta.url)),
  positive:items.filter(i=>i.admitted).length,negative:items.filter(i=>!i.admitted).length,items};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(report.positive+' positive and '+report.negative+' conservative fallback cases');
