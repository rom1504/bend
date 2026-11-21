// Only the marshalling and independent oracles live here. Instruction selection,
// typed object assembly and text rendering all come from the checked Bend API.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const argv=process.argv.slice(2),o=Object.fromEntries(Array.from({length:argv.length/2},(_,i)=>argv.slice(2*i,2*i+2)));
const out=path.resolve(o['--out']);fs.mkdirSync(out);
const read=p=>JSON.parse(fs.readFileSync(p));
const a=read(o['--api']);if(!a.complete||!a.checked||a.error)throw Error('unchecked');
verify(a.api);verify(a.source);const api=(await import(pathToFileURL(a.api.file))).default;
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const node=(s,o={})=>({$:s,...o}),reg=(index,width=64)=>node('X187Reg',{index,width,vector:false});
const op=(opcode,...operands)=>node('X188One',{item:node('PInst',{inst:node('X187Instruction',{op:opcode,operands:list(operands)})})});
const directive=(s,o)=>node('X188One',{item:node(s,o)});
const arg=(typ,value)=>node('N111Arg',{typ:node('N111'+typ),value});
const local=name=>node('N111Local',{name});
const word=(lo,hi=0)=>node('N111Const',{lo,hi});
const call=(id,count,extra={})=>node('N111Call',{name:'answer',typ:node('N111U64'),symbol:'p111_rt_op',
  args:list([arg('Ptr',local('state')),arg('U32',word(id)),arg('Ptr',local('buf')),arg('U32',word(count))]),...extra});
const ids=[24,25,63,67],checks=[];
for(let id=0;id<88;id++)for(let n=0;n<4;n++){
  const expected=(id===24||id===25)?n===1:(id===63||id===67)&&n===2;
  if((api.x198w_op(call(id,n)).$==='X198WOp')!==expected)throw Error('admission '+id+'/'+n);
  checks.push([id,n]);
}
for(const change of [x=>x.typ=node('N111U32'),x=>x.symbol='foreign',x=>x.args.head.value=local('other'),
 x=>x.args.tail.head.value.hi=1,x=>x.args.tail.tail.head.value=local('state'),x=>x.args.tail.tail.tail.head.value.hi=1]){
 const row=call(25,1);change(row);if(api.x198w_op(row).$!=='X198WNone')throw Error('bad shape');
}
const known=(id,facts)=>api.x198w_known(api.x198w_op(call(id,id<30?1:2)),list(facts));
const fact=(offset,v)=>node('X185ScratchCell',{buffer:'buf',offset,typ:node('N111U64'),value:local(v)});
for(const id of ids){
 if(known(id,[]).$!=='None')throw Error('missing fact');
 const r=known(id,[fact(0,'x'),fact(8,'y')]);if((r.$==='Some')!==(id!==63))throw Error('known '+id);
 if(id===25&&(r.value.op!=='and'||r.value.right.lo!==0xffffffff||r.value.right.hi!==0))throw Error('mask');
}
const functions=[];
for(const id of ids){
 const name='word'+id;
 functions.push(directive('PGlobal',{name}),directive('PType',{name,kind:2}),directive('PLabel',{name}),
   op('movq',reg(7),reg(10)),api.x198w_calc(id),op('movq',reg(11),reg(0)),op('ret'),directive('PSize',{name}));
}
const seq=api.x188_many(list([directive('PSection',{section:1}),...functions]));
const assembled=api.x188_assemble(seq);if(assembled.error)throw Error(assembled.error);
const bytes=[];let xs=assembled.bytes;while(xs.$==='Con'){bytes.push(xs.head);xs=xs.tail;}
if(xs.$!=='Nil')throw Error('incomplete');
const obj=path.join(out,'program.o'),asm=path.join(out,'program.s');fs.writeFileSync(obj,Buffer.from(bytes));fs.writeFileSync(asm,api.x188_render(seq));
const assets=read('selfhost/build/phase194/assets.json');verify(assets.assets.linker);const cc=assets.assets.linker.file;
const observer=path.join(path.dirname(fileURLToPath(import.meta.url)),'observer.c');
const observations={};for(const [suffix,program] of Object.entries({object:obj,assembly:asm})){
 const exe=path.join(out,suffix),b=spawnSync(cc,['-O2',observer,program,'-o',exe],{encoding:'utf8'});if(b.status)throw Error(b.stderr);
 const run=spawnSync(exe,[],{encoding:'utf8'});if(run.status||run.stdout!=='checked 16420\n')throw Error(JSON.stringify(run.output));
 observations[suffix]={exe:pin(exe),stdout:run.stdout};
}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,api:a.api,source:a.source,method:pin(fileURLToPath(import.meta.url)),
   sourceOracle:pin(observer),ordinaryAdmissions:checks.length,malformedRefusals:6,object:pin(obj),assembly:pin(asm),observations},null,2)+'\n');
