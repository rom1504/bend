// Independent structural transfer checks; no synthetic owning IR is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('identity-controls.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),file=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=f=>{f=path.resolve(f);const b=fs.readFileSync(f);return{file:f,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(file),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p113p_pair_code','p113p_primitive','p113ai_intrinsic'];
if(!receipt.complete||!receipt.checked||!required.every(n=>receipt.exports?.includes(n))||receipt.api.sha256!==pin(file).sha256)throw Error('Checked API/export pin mismatch');
fs.mkdirSync(out,{recursive:true});fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-array-identity-structural-controls',complete:false,inputs:[pin(file),pin(receiptFile),pin(import.meta.filename)],controls:[],scope:'Builder transfer/order assertions only; no synthetic IR/native execution.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const api=(await import(pathToFileURL(file))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=x=>{const a=[];for(;x?.$==='Con';x=x.tail)a.push(x.head);assert.equal(x?.$,'Nil');return a;};
const local=name=>({$:'N111Local',name}),word=(lo,hi=0)=>({$:'N111Const',lo,hi});
const test=(name,run)=>{try{run();report.controls.push({name,pass:true});}catch(e){report.controls.push({name,pass:false,error:String(e)});save();throw e;}};
for(const [id,count] of [[72,2],[74,3],[75,1],[76,1]])test('pair-identity-'+id,()=>{
 const values=[local('p113p_status_3'),word(4294967295),word(123,0x82000001)].slice(0,count);
 const code=api.p113p_pair_code(id,list(values),3),body=unlist(code.body);
 assert.equal(code.error,'');assert.deepEqual(unlist(code.values),[local('p113p_first_3'),local('p113p_second_3')]);
 assert.deepEqual(body[0],{$:'N111Set',name:'p113ai_array_3',typ:{$:'N111U64'},value:values[0]});
 const ci=body.findIndex(s=>s.$==='N111Call');assert(ci>count);
 const call=body[ci];assert.equal(call.symbol,'p113_rt_array_pair');assert.equal(call.name,'p113p_status_3');
 assert.deepEqual(unlist(call.args).map(a=>a.value),[local('state'),word(id),local('scratch'),word(count),local('p113p_out_3'),word(2)]);
 assert.deepEqual(body[ci+1],{$:'N111Set',name:'p113p_first_3',typ:{$:'N111U64'},value:local('p113ai_array_3')});
 assert.deepEqual(body[ci+2],{$:'N111Load',name:'p113p_second_3',typ:{$:'N111U64'},base:local('p113p_out_3'),offset:8});
 assert.equal(body.filter(s=>s.$==='N111Call').length,1);
 assert(!body.some(s=>s.$==='N111Load'&&s.offset===0));
});
test('full64-rfc-word-snapshot',()=>{
 const value=word(0x89abcdef,0x86000123),body=unlist(api.p113p_pair_code(75,list([value]),9).body);
 assert.deepEqual(body[0].value,value);assert.equal(body[0].typ.$,'N111U64');
});
test('set-keeps-original-call-and-order',()=>{
 const values=[local('value'),word(3),local('replacement')],code=api.p113ai_intrinsic('array_set',list(values),11),body=unlist(code.body);
 assert.equal(code.error,'');assert.deepEqual(code.value,local('p113ai_result_11'));
 assert.deepEqual(body[0],{$:'N111Set',name:'p113ai_array_11',typ:{$:'N111U64'},value:local('value')});
 const calls=body.filter(x=>x.$==='N111Call');assert.equal(calls.length,1);assert.equal(calls[0].symbol,'p111_rt_op');
 assert.deepEqual(unlist(calls[0].args).map(a=>a.value),[local('state'),word(73),local('scratch'),word(3)]);
 assert.deepEqual(body.at(-1),{$:'N111Set',name:'p113ai_result_11',typ:{$:'N111U64'},value:local('p113ai_array_11')});
 assert.equal(body.filter(x=>x.$==='N111Store').length,3);
});
test('nonset-unchanged-builder-shape',()=>{
 const code=api.p113ai_intrinsic('array_new',list([word(0),word(7)]),12),body=unlist(code.body);
 assert(!body.some(x=>x.name?.startsWith('p113ai_')));assert.equal(body.at(-1).symbol,'p111_rt_op');
 assert.equal(unlist(body.at(-1).args)[1].value.lo,71);
});
test('wrong-set-count-no-identity',()=>{
 const body=unlist(api.p113ai_intrinsic('array_set',list([word(0),word(1)]),0).body);
 assert(!body.some(x=>x.name?.startsWith('p113ai_')));
});
report.complete=true;report.count=report.controls.length;save();
process.stdout.write(JSON.stringify({complete:true,controls:report.count,report:path.join(out,'report.json')})+'\n');
