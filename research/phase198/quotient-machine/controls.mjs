import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const args=process.argv.slice(2),o=Object.fromEntries(Array.from({length:args.length/2},(_,i)=>args.slice(2*i,2*i+2)));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('CPU3');
const out=path.resolve(o['--out']);fs.mkdirSync(out);
const receipt=JSON.parse(fs.readFileSync(o['--api']));
if(!receipt.complete||!receipt.checked)throw Error('unchecked');
verify(receipt.api);verify(receipt.source);
const api=(await import(pathToFileURL(receipt.api.file))).default;
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const reg=(index,width=64)=>({$:'X187Reg',index,width,vector:false});
const imm=(lo,hi=0)=>({$:'X187Imm',lo:lo>>>0,hi});
const mem=(base,disp)=>({$:'X187Mem',base,disp:disp>>>0});
const target=symbol=>({$:'X187Target',symbol});
const one=item=>({$:'X188One',item});
const ins=(op,...ops)=>one({$:'PInst',inst:{$:'X187Instruction',op,operands:list(ops)}});
const sequence=xs=>api.x188_many(list(xs));
const shape=(d,id)=>[ins('leaq',mem(5,-16),reg(10)),ins('movabsq',imm(d),reg(11)),
  ins('movq',reg(11),mem(10,8)),ins('movq',reg(7),reg(7)),ins('movabsq',imm(id),reg(6)),
  ins('movl',reg(6,32),reg(6,32)),ins('leaq',mem(5,-16),reg(2)),ins('movabsq',imm(2),reg(1)),
  ins('movl',reg(1,32),reg(1,32)),ins('xorl',reg(0,32),reg(0,32)),ins('call',target('p111_rt_op'))];
const probe=rows=>api.x188_render(api.x191_frame_forward(sequence(rows)));
const mutations=[
 ['distinct frame cell',6,ins('leaq',mem(5,-32),reg(2))],['unaligned store frame',0,ins('leaq',mem(5,-15),reg(10))],
 ['different store offset',2,ins('movq',reg(11),mem(10,0))],['partial store',2,ins('movl',reg(11,32),mem(10,8))],
 ['unknown divisor',1,ins('movq',reg(12),reg(11))],
 ['high divisor bits',1,ins('movabsq',imm(26,1),reg(11))],['arity',7,ins('movabsq',imm(1),reg(1))],
 ['different runtime operation',4,ins('movabsq',imm(20),reg(6))],['foreign symbol',10,ins('call',target('other_runtime'))],
 ['control-flow barrier',3,one({$:'PLabel',name:'barrier'})],['intervening write',3,ins('movq',reg(6),mem(10,8))],
 ['zero divisor',1,ins('movabsq',imm(0),reg(11))],['outside proof',1,ins('movabsq',imm(65537),reg(11))]
];
for(const [name,index,replacement] of mutations){
  const rows=shape(26,19);rows[index]=replacement;
  if(!probe(rows).includes('  call '))throw Error(name);
}
const functions=[],parts=[one({$:'PSection',section:1})],status=[];
for(const d of [1,2,4,10,16,26,256,1000,65535,2147483648,0,7,65537])for(const op of [18,19]){
  const name='quot_'+d+'_'+op,rows=shape(d,op),converted=!probe(rows).includes('  call ');
  if(converted!==(api.p198q_plan(d).$!=='P198NoQuot'))throw Error('shape '+d+'/'+op);
  functions.push({name,d,op});status.push({d,op,converted});
  parts.push(one({$:'PGlobal',name}),one({$:'PLabel',name}),ins('pushq',reg(5)),ins('movq',reg(4),reg(5)),ins('subq',imm(32),reg(4)),
    ins('movq',reg(6),mem(5,-24)),ins('movq',reg(7),mem(5,-16)),api.x191_frame_forward(sequence(rows)),ins('movq',mem(5,-24),reg(2)),
    ins('movq',mem(5,-16),reg(10)),ins('movq',reg(10),mem(2,0)),ins('movq',mem(5,-8),reg(10)),ins('movq',reg(10),mem(2,8)),
    ins('movq',reg(5),reg(4)),ins('popq',reg(5)),ins('ret'));
}
const code=sequence(parts),obj=api.x188_assemble(code);if(obj.error)throw Error(obj.error);
const bytes=[];for(let xs=obj.bytes;xs.$==='Con';xs=xs.tail)bytes.push(xs.head);
const object=out+'/controls.o';fs.writeFileSync(object,Buffer.from(bytes));fs.writeFileSync(out+'/controls.s',api.x188_render(code));
const c=out+'/controls.c';
fs.writeFileSync(c,`#include <stdint.h>
#include <stdio.h>
typedef uint64_t u64;typedef uint32_t u32;
u64 p111_rt_op(void *unused, u32 id, u64 *arg, u32 count){(void)unused;if(count!=2)__builtin_trap();u32 d=arg[1],x=arg[0];return d?(id==18?x/d:x%d):(id==18?0:arg[0]);}
${functions.map(f=>'extern u64 '+f.name+'(u64,u64*);').join('\n')}
struct fun{u64(*f)(u64,u64*);u32 d,op;}fns[]={${functions.map(f=>'{'+f.name+','+f.d+'U,'+f.op+'}').join(',')}};
int main(void){unsigned n=0;for(unsigned i=0;i<sizeof(fns)/sizeof(fns[0]);++i){u32 d=fns[i].d;u64 x=123;
for(unsigned j=0;j<200;j++){switch(j){case 0:x=0;break;case 1:x=0xffffffffffffffffULL;break;case 2:x=(u64)d-1;break;case 3:x=d;break;case 4:x=(u64)d+1;break;default:x=x*6364136223846793005ULL+1442695040888963407ULL;}
u64 post[2]={7,11},y=fns[i].f(x,post);u64 w=d?(fns[i].op==18?(u32)x/d:(u32)x%d):(fns[i].op==18?0:x);
if(y!=w||post[0]!=x||post[1]!=d)return 1;++n;}}printf("%u checks\\n",n);return 0;}`);
const cc=JSON.parse(fs.readFileSync('selfhost/build/phase194/assets.json')).assets.linker;verify(cc);
const run=(cmd,args)=>{const r=spawnSync(cmd,args,{encoding:'utf8',timeout:15000});if(r.status!==0)throw Error(cmd+': '+r.status+' '+r.stderr);return r.stdout;};
const binary=out+'/controls';run(cc.file,['-std=c11','-O2','-no-pie',c,object,'-o',binary]);
const checked=run(binary,[]);
fs.writeFileSync(out+'/report.json',JSON.stringify({complete:true,method:pin(fileURLToPath(import.meta.url)),compiler:receipt.api,source:receipt.source,
  negative:mutations.map(x=>x[0]),cases:status,object:pin(object),binary:pin(binary),oracle:checked},null,2)+'\n');
console.log(checked);
