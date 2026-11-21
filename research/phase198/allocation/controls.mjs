// Transport one typed test program through the checked Bend selector and both emitters.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [authorityFile,out]=process.argv.slice(2);
const authority=JSON.parse(fs.readFileSync(authorityFile));
if (!authority.complete || !authority.checked || authority.error || authority.changedInputs?.length) throw Error('unchecked authority');
function pin(file){return createHash('sha256').update(fs.readFileSync(file)).digest('hex');}
if(pin(authority.api.file)!==authority.api.sha256||pin(authority.source.file)!==authority.source.sha256)throw Error('authority changed');
const api=(await import(pathToFileURL(authority.api.file))).default;
fs.mkdirSync(out,{recursive:true});
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const reg=(index,width=64)=>({$:'X187Reg',index,width,vector:false});
const mem=(base,disp)=>({$:'X187Mem',base,disp:disp>>>0});
const imm=n=>({$:'X187Imm',lo:n>>>0,hi:n<0?0xffffffff:0});
const tgt=symbol=>({$:'X187Target',symbol});
const one=item=>({$:'X188One',item});
const ins=(op,...operands)=>one({$:'PInst',inst:{$:'X187Instruction',op,operands:list(operands)}});
const seq=items=>api.x188_many(list(items));
const slot={$:'X198FRSlot',bytes:128,disp:(-48)>>>0};
function rewrite(code){return api.x198fr_work(list([code]),slot,code,false,false,list([]));}
const name='p198_frame_test';
const pro=[one({$:'PSection',section:1}),one({$:'PGlobal',name}),one({$:'PType',name,kind:2}),one({$:'PLabel',name}),
    ins('pushq',reg(5)),ins('movq',reg(4),reg(5)),ins('subq',imm(128),reg(4))];
const call=ins('call',tgt('p198_frame_external'));
const write=ins('movq',reg(7),mem(5,-48));
const read=ins('movq',mem(5,-48),reg(10));
const epilogue=[ins('movq',reg(5),reg(4)),ins('popq',reg(5)),ins('ret'),one({$:'PSize',name})];
const code=seq([...pro,write,ins('movq',reg(6),mem(5,-56)),ins('movq',mem(5,16),reg(0)),ins('movq',reg(0),mem(4,0)),call,read,
    ins('addq',reg(10),reg(0)),ins('addq',mem(5,-56),reg(0)),...epilogue]);
const transformed=rewrite(code);
const asm=api.x188_render(transformed);
for(const wanted of ['movq %rdi, %rbp','movq %rbp, %r10','movq 144(%rsp), %rax','movq %rsi, 72(%rsp)','leaq 128(%rsp), %rsp','call p198_frame_external']){
  if(!asm.includes(wanted))throw Error('missing selected instruction '+wanted);
}
const refused={address:[write,ins('leaq',mem(5,-48),reg(0)),read],partial:[ins('movl',reg(7,32),mem(5,-48)),read],
    rebaseOverflow:[write,ins('movq',mem(5,0x7fffffff),reg(0)),read],manualFramePointer:[write,ins('addq',imm(1),reg(5)),read],
    dynamicRsp:[write,ins('subq',imm(8),reg(4)),read],writeOnly:[write],readOnly:[read],
    indexUsingRbp:[write,ins('leaq',{$:'X187Indexed',base:0,index:5,scale:1,disp:0},reg(10)),read]};
for(const [key,items] of Object.entries(refused)){
  const original=seq([...pro,...items,...epilogue]);
  if(api.x188_render(rewrite(original))!==api.x188_render(original))throw Error('refusal '+key);
}
const obj=api.x188_assemble(transformed);
if(obj.error)throw Error(obj.error);
const bytes=[];
let next=obj.bytes;
while(next.$==='Con'){if(bytes.length>65536||!Number.isInteger(next.head)||next.head<0||next.head>255)throw Error('invalid object');bytes.push(next.head);next=next.tail;}
if(next.$!=='Nil'||bytes.length===0)throw Error('invalid byte list');
fs.writeFileSync(path.join(out,'program.s'),asm);
fs.writeFileSync(path.join(out,'program.o'),Buffer.from(bytes));
fs.writeFileSync(path.join(out,'selection.json'),JSON.stringify({accepted:6,refusals:Object.keys(refused),source:authority.source,api:authority.api},null,2)+'\n');
