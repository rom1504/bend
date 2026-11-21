import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const argv=process.argv.slice(2),o=Object.fromEntries(Array.from({length:argv.length/2},(_,i)=>argv.slice(2*i,2*i+2)));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('requires guarded CPU');
const out=path.resolve(o['--out']);fs.mkdirSync(out);
const auth=JSON.parse(fs.readFileSync(o['--api']));if(!auth.checked||!auth.complete||auth.error)throw Error('unchecked');verify(auth.api);verify(auth.source);
const api=(await import(pathToFileURL(auth.api.file))).default;
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const node=(s,o={})=>({$:s,...o}),one=item=>node('X188One',{item}),reg=(index,width=64)=>node('X187Reg',{index,width,vector:false});
const mem=(base,disp)=>node('X187Mem',{base,disp:disp>>>0}),imm=lo=>node('X187Imm',{lo,hi:0}),target=symbol=>node('X187Target',{symbol});
const ins=(op,...args)=>one(node('PInst',{inst:node('X187Instruction',{op,operands:list(args)})})),seq=items=>api.x188_many(list(items));
const slot=(arity,kind='X181Stack',templates=8)=>node('KDef',{name:'s'+arity,kind,arity,templates,typ:undefined,value:undefined,ctors:list([]),native:false,unsafe:false});
const leaf=(...entries)=>node('KIndexLeaf',{hash:17,bucket:list(entries)});
const label='.L199loop',name='p199_snapshot',lab=name=>one(node('PLabel',{name}));
const store=ins('movq',reg(11),mem(5,-80)),load=ins('movq',mem(5,-80),reg(10)),back=ins('jmp',target(label));
const middle=ins('addq',imm(1),reg(8));
function run(items,slots=leaf(slot(80))){
 const body=seq(items),candidate=api.x199s_apply(body,slots,label);return [api.x188_render(body),api.x188_render(candidate),candidate];
}
const head=[one(node('PSection',{section:1})),one(node('PGlobal',{name})),one(node('PType',{name,kind:2})),lab(name),
 ins('pushq',reg(5)),ins('movq',reg(4),reg(5)),ins('subq',imm(96),reg(4)),ins('movq',reg(6),reg(0)),ins('xorq',reg(8),reg(8)),lab(label),
 ins('cmpq',reg(7),reg(8)),ins('je',target('.L199done')),ins('movq',reg(0),reg(11))];
const tail=[lab('.L199done'),ins('movq',reg(5),reg(4)),ins('popq',reg(5)),ins('ret'),one(node('PSize',{name}))];
const [before,after,candidate]=run([...head,store,middle,load,ins('addq',reg(10),reg(0)),ins('addq',reg(8),reg(0)),back,...tail]);
if(before===after||!after.includes('movq %r11, %r10')||after.includes('-80(%rbp)'))throw Error('positive transfer');
const tests={
 clobber:[store,ins('movl',imm(2),reg(11,32)),load,back],call:[store,ins('call',target('elsewhere')),load,back],
 partial:[store,middle,ins('movl',mem(5,-80),reg(10,32)),back],secondRead:[store,middle,load,load,back],
 secondStore:[store,store,middle,load,back],escape:[ins('leaq',mem(5,-80),reg(6)),store,middle,load,back],
 frameEscape:[ins('movq',reg(5),reg(9)),store,middle,load,back],partialOverlap:[ins('movl',mem(5,-76),reg(9,32)),store,middle,load,back],indexed:[ins('leaq',node('X187Indexed',{base:5,index:7,scale:4,disp:0}),reg(2)),store,middle,load,back],
 label:[store,lab('.L199split'),middle,load,back],branch:[store,ins('je',target('.L199split')),middle,load,back],
 wrongBack:[store,middle,load,ins('jmp',target('.Lelse'))],long:[store,...Array(26).fill(middle),load,back],implicit:[store,ins('mulq',reg(2)),load,back],
 variableRead:[store,ins('leaq',node('X187Indexed',{base:11,index:7,scale:4,disp:0}),reg(2)),load,back]
};
for(const [k,v] of Object.entries(tests)){const [a,b]=run(v);if(a!==b)throw Error('refusal '+k);}
for(const x of [leaf(),leaf(slot(80,'X181Buffer')),leaf(slot(80,'X181Stack',4))]){
 const [a,b]=run([store,middle,load,back],x);if(a!==b)throw Error('noncanonical slot');
}
const [,same]=run([store,middle,ins('movq',mem(5,-80),reg(11)),back]);
if(same.includes('-80(%rbp)')||same.includes('movq %r11, %r11'))throw Error('identity');
const raw=api.x188_assemble(candidate);if(raw.error)throw Error(raw.error);
const bytes=[];let xs=raw.bytes;while(xs.$==='Con'){bytes.push(xs.head);xs=xs.tail;}if(xs.$!=='Nil')throw Error('bytes');
const asm=path.join(out,'fixture.s'),obj=path.join(out,'fixture.o');fs.writeFileSync(asm,after);fs.writeFileSync(obj,Buffer.from(bytes));
const assets=JSON.parse(fs.readFileSync('selfhost/build/phase194/assets.json'));verify(assets.assets.linker);
const cc=assets.assets.linker.file,observer=path.join(path.dirname(fileURLToPath(import.meta.url)),'observer.c');
const result={};for(const [key,file] of Object.entries({direct:obj,rendered:asm})){
 const exe=path.join(out,key);let p=spawnSync(cc,['-O2','-no-pie',observer,file,'-o',exe],{encoding:'utf8'});if(p.status!==0)throw Error(p.stderr);
 p=spawnSync(exe,[],{encoding:'utf8'});if(p.status!==0||p.stdout!=='256 wrapped complete loop results\n')throw Error(key+' machine oracle');
 result[key]={object:pin(file),binary:pin(exe),stdout:p.stdout};
}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,source:auth.source,api:auth.api,driver:pin(fileURLToPath(import.meta.url)),observer:pin(observer),positiveShapes:2,refused:Object.keys(tests),invalidHomes:3,result},null,2)+'\n');
