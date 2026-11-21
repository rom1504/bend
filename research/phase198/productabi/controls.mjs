import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const [receipt,directory]=process.argv.slice(2);
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('CPU3');
const cert=JSON.parse(fs.readFileSync(receipt));
if(!cert.complete||!cert.checked)throw Error('Unchecked API');
verify(cert.api);verify(cert.source);
const api=(await import(pathToFileURL(cert.api.file))).default;
const nil={$:'Nil'}, list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const fls=false, t={$:'KTerm',tag:'Absent',name:'',id:0,quant:0,kids:nil,removed:nil,originBegin:0,originEnd:0};
const absent={$:'KDef',name:'',kind:'Absent',arity:0,templates:0,typ:t,value:t,ctors:nil,native:fls,unsafe:fls};
const ids={$:'N111Ids',functions:absent,constructors:absent},u64={$:'N111U64'},u32={$:'N111U32'},ptr={$:'N111Ptr'};
const names=[...'abcdefgh'], vs=names.map(name=>({$:'N111Local',name})), v=name=>({$:'N111Local',name}), c=lo=>({$:'N111Const',lo,hi:0});
const ret=(...ys)=>({$:'P113DResult',values:list(ys)});
const scalar=stmt=>({$:'P113DScalar',stmt});
const fn=(name,result,body)=>({$:'P113DFunction',name,result,params:list(names.map((word,id)=>({$:'NC_Binding',id,word,kind:{$:'N_W64'}}))),public:fls,body:list(body)});
const pair=fn('pair',2,[{$:'P113DIf',condition:v('a'),yes:list([ret(v('b'),v('h'))]),no:list([ret(v('h'),v('b'))])}]);
const call=(target,names,args=vs)=>({$:'P113DCall',target,destinations:list(names),args:list(args)});
const caller=fn('call',1,[call('pair',['l','r']),call('pair',['one','two'],[c(1),v('r'),...vs.slice(2,7),v('l')]),
  scalar({$:'N111Bin',name:'difference',typ:u64,op:'sub',left:v('one'),right:v('two')}),ret(v('difference'))]);
const index=fs=>api.x181_forward_index(list(fs),absent,absent);
const idx=index([caller,pair]);
const observed=[];
function check(label,index,expected){
  const selected=api.x198pr_selected(index,'pair');
  const result=selected===true||selected.$==='True';
  if(result!==expected)throw Error(label+' '+JSON.stringify(selected));
  observed.push({label,result});
}
check('definition after demand',idx,true);
check('demand after definition',index([pair,caller]),true);
check('unknown target',index([caller]),false);
check('one site',index([fn('once',1,[call('pair',['x','y']),ret(v('y'))]),pair]),false);
check('inconsistent return width',index([caller,fn('pair',2,[ret(v('a'))])]),false);
check('raw return',index([caller,fn('pair',2,[scalar({$:'N111Return',value:v('a')})])]),false);
const args=list([[ptr,v('state')],[u32,c(73)],[ptr,v('scratch')],[u32,c(3)]].map(([typ,value])=>({$:'N111Arg',typ,value})));
check('versionable array operation',index([caller,fn('pair',2,[scalar({$:'N111Call',name:'tmp',typ:u64,symbol:'p111_rt_op',args}),ret(v('a'),v('b'))])]),false);
const marked=api.x198pr_ids(ids,idx);
const chunks=[];
for(const row of [api.x181_direct(pair,marked),api.x198pr_worker(pair,idx,marked),api.x181_direct(caller,marked)]){
  if(row.error)throw Error(row.error);
  for(let xs=row.chunks;xs.$==='Con';xs=xs.tail)chunks.push(xs.head);
}
const sequence=api.x188_many(list(chunks)), assembly=api.x188_render(sequence),obj=api.x188_assemble(sequence);
if(obj.error)throw Error(obj.error);
const out=path.resolve(directory);
fs.mkdirSync(out);
const symbol='p198r_p113d_FID_112_97_105_114_';
if(assembly.includes('.globl '+symbol)||!assembly.includes('call '+symbol))throw Error('missing local worker');
const b=[];for(let xs=obj.bytes;xs.$==='Con';xs=xs.tail)b.push(xs.head);
const object=out+'/probe.o';fs.writeFileSync(object,Buffer.from(b));fs.writeFileSync(out+'/probe.s',assembly);
const gcc=JSON.parse(fs.readFileSync('selfhost/build/phase194/assets.json')).assets.linker;verify(gcc);
function run(cmd,args){const child=spawnSync(cmd,args,{encoding:'utf8',timeout:10000});if(child.status!==0)throw Error(JSON.stringify({cmd,args,status:child.status,err:child.stderr}));return child.stdout;}
run(gcc.file,['-no-pie',object,'research/phase198/productabi/abi.c','-o',out+'/probe']);
const result=run(out+'/probe',[]);
fs.writeFileSync(out+'/report.json',JSON.stringify({complete:true,api:cert.api,controls:observed,object:pin(object),result},null,2)+'\n');
console.log(result.trim());
