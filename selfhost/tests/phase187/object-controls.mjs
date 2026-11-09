#!/usr/bin/env bun
// Host orchestration and independent observation only. x187_assemble in checked
// Bend owns parsing, instruction selection/encoding, relocation and ELF writing.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';

const own=fileURLToPath(import.meta.url), fixture=name=>path.join(workspace,'selfhost/tests/phase187',name);
const args={}, extra=[];
for(let i=2;i<process.argv.length;i+=2){
  const key=process.argv[i],value=process.argv[i+1];
  need(['--api','--assets','--out','--assembly','--observer','--expect','--extra','--mode'].includes(key)&&value,'Unknown or incomplete option');
  if(key==='--extra')extra.push(path.resolve(value));else {need(!Object.hasOwn(args,key),'Duplicate option');args[key]=value;}
}
for(const key of ['--api','--assets','--out'])need(args[key],'Required '+key);
const mode=args['--mode']??'assemble';need(['assemble','elf'].includes(mode),'Unknown mode');
need(mode!=='elf'||!args['--assembly'],'ELF fixture mode owns its assembly');
let assembly=mode==='elf'?null:path.resolve(args['--assembly']??fixture('object-controls.s'));
const observer=path.resolve(args['--observer']??fixture(mode==='elf'?'object-elf-oracle.c':'object-controls.c'));
const expectation=path.resolve(args['--expect']??fixture(mode==='elf'?'object-elf.stdout':'object-controls.stdout'));
const builtin=mode==='assemble'&&!args['--assembly']&&!args['--observer']&&!args['--expect'];
const out=path.resolve(args['--out']);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'Fresh guarded build output required');
fs.mkdirSync(out,{recursive:true});
const snapshot=path.join(out,'driver.mjs');fs.copyFileSync(own,snapshot,fs.constants.COPYFILE_EXCL);
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
const report={kind:'phase187-direct-object-controls',version:1,mode,complete:false,started:new Date().toISOString(),
  inputs:[pin(own),pin(snapshot),pin(process.execPath),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs')),...(assembly?[pin(assembly)]:[]),pin(observer),pin(expectation),...extra.map(pin)],
  jobs:[],artifacts:[],refusals:[],objects:{},machines:[],
  scope:'Checked Bend object emitter; host only serializes bytes and independently reads ELF metadata. Finite independent machine observations plus GNU-as differential outputs, no backend proof, source-language qualification, bootstrap, install or performance claim. Fixed rel32 and branch-padding policies can change layout.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const record=file=>{const item=pin(file);report.artifacts.push(item);return item;};
const write=(name,data)=>{const file=path.join(out,name);fs.writeFileSync(file,data,{flag:'wx'});record(file);return file;};
const exact=(a,b,label)=>need(JSON.stringify(a)===JSON.stringify(b),label+' differs');
const elapsed=performance.now();save();
function run(label,command,expected){
  report.inputs.forEach(verify);const started=new Date().toISOString(),start=performance.now(),env={...process.env};
  for(const key of ['LD_PRELOAD','LD_AUDIT','BENDRTS','NODE_OPTIONS','NODE_PATH'])delete env[key];
  env.LC_ALL='C';
  const result=spawnSync(command[0],command.slice(1),{cwd:workspace,env,encoding:'utf8',timeout:20000,maxBuffer:16*1024*1024});
  const stdout=write(label+'.stdout',result.stdout??''),stderr=write(label+'.stderr',result.stderr??'');
  report.jobs.push({label,command,cwd:workspace,started,seconds:(performance.now()-start)/1000,status:result.status,
    signal:result.signal,error:result.error?.message??null,stdout:pin(stdout),stderr:pin(stderr)});save();
  need(result.status===0&&!result.signal&&!result.error,label+' failed');
  if(expected!==undefined)need(result.stdout===expected&&result.stderr==='',label+' exact output differs');
  return result.stdout;
}
function bytes(result,label){
  need(result?.$==='X187ObjectResult'&&typeof result.error==='string',label+' malformed result');
  const values=[];let xs=result.bytes;
  while(xs?.$==='Con'){
    need(values.length<64*1024*1024&&Number.isInteger(xs.head)&&xs.head>=0&&xs.head<=255,label+' non-byte or oversized output');
    values.push(xs.head);xs=xs.tail;
  }
  need(xs?.$==='Nil',label+' malformed byte list');
  return Buffer.from(values);
}
// Reading ELF is independent validation; none of these routines emits bytes.
function elf(file){
  const b=fs.readFileSync(file);need(b.length>=64&&b.subarray(0,7).equals(Buffer.from([127,69,76,70,2,1,1])),'ELF64 little endian magic');
  const u16=i=>b.readUInt16LE(i),u32=i=>b.readUInt32LE(i),u64=i=>b.readBigUInt64LE(i);
  const bounded=(v,label)=>{need(v>=0n&&v<=BigInt(b.length),label+' outside object');return Number(v);};
  need(u16(16)===1&&u16(18)===62&&u32(20)===1&&u16(52)===64&&u16(56)===0,'AMD64 relocatable header');
  const shoff=bounded(u64(40),'section headers'),count=u16(60),namesIndex=u16(62);
  need(u16(58)===64&&count>0&&count<4096&&namesIndex<count&&shoff+count*64<=b.length,'bounded section table');
  const sections=Array.from({length:count},(_,index)=>{
    const p=shoff+index*64,offset=bounded(u64(p+24),'section offset'),size=bounded(u64(p+32),'section size'),type=u32(p+4);
    need(type===8||offset+size<=b.length,'section range');
    const alignment=u64(p+48);need(alignment<=1048576n&&(alignment===0n||(alignment&(alignment-1n))===0n),'section alignment');
    need(alignment<=1n||BigInt(offset)%alignment===0n,'misaligned section');
    return {index,nameOffset:u32(p),type,flags:Number(u64(p+8)),offset,size,link:u32(p+40),info:u32(p+44),alignment:Number(alignment),entry:Number(u64(p+56))};
  });
  const stringAt=(section,offset)=>{need(section?.type===3&&offset<section.size,'string-table index');const end=b.indexOf(0,section.offset+offset);need(end>=section.offset+offset&&end<section.offset+section.size,'unterminated ELF string');return b.toString('utf8',section.offset+offset,end);};
  for(const s of sections){s.name=stringAt(sections[namesIndex],s.nameOffset);need((s.flags&5)!==5,'writable executable section');}
  need(sections[0].type===0&&sections[0].size===0,'null section');
  const byName=Object.fromEntries(sections.map(s=>[s.name,s]));
  need(byName['.text']?.type===1&&(byName['.text'].flags&6)===6,'executable text section');
  need(byName['.note.GNU-stack']&&byName['.note.GNU-stack'].size===0&&byName['.note.GNU-stack'].flags===0,'nonexecuting-stack marker');
  const symtab=byName['.symtab'];need(symtab?.type===2&&symtab.entry===24&&symtab.size%24===0&&symtab.link<count,'symbol table');
  const symbols=[];
  for(let p=symtab.offset;p<symtab.offset+symtab.size;p+=24){
    const index=symbols.length,name=stringAt(sections[symtab.link],u32(p)),binding=b[p+4]>>4,kind=b[p+4]&15,section=u16(p+6),value=u64(p+8),size=u64(p+16);
    need(section===0||section===0xfff1||section<count,'symbol section index');
    need(index<symtab.info?binding===0:binding!==0,'local/global symbol order');
    if(section>0&&section<count)need(value+size<=BigInt(sections[section].size),'symbol outside section');
    symbols.push({index,name,binding,kind,section,value:value.toString(),size:size.toString()});
  }
  need(symbols.length&&symbols[0].name===''&&symbols[0].section===0&&symbols[0].value==='0','null symbol');
  const relocations=[];
  for(const s of sections)if(s.type===4){
    need(s.entry===24&&s.size%24===0&&s.link===symtab.index&&s.info>0&&s.info<count,'RELA table');
    for(let p=s.offset;p<s.offset+s.size;p+=24){
      const offset=u64(p),info=u64(p+8),index=Number(info>>32n),kind=Number(info&0xffffffffn),width=kind===1?8:4;
      need([1,2,4].includes(kind)&&index<symbols.length&&offset+BigInt(width)<=BigInt(sections[s.info].size),'supported in-range relocation');
      relocations.push({section:sections[s.info].name,offset:offset.toString(),kind,symbol:symbols[index].name,addend:b.readBigInt64LE(p+16).toString()});
    }
  }
  return {file:pin(file),sections,symbols,relocations,textBytes:byName['.text'].size};
}
try{
  const authority=read(args['--api']),assets=read(args['--assets']),binding=authority.imageBinding;
  need(authority.kind==='bend-checked-hosted-api'&&authority.complete&&authority.checked&&!authority.error,'Complete checked API required');
  need(assets.kind==='bend-build-assets'&&assets.complete&&authority.upstream?.revision===assets.upstream,'API/assets upstream mismatch');
  need(binding?.kind==='bend-build-image-binding'&&binding.complete&&binding.checked&&binding.host==='js'&&binding.stage==='B1'&&same(binding.image,authority.api)&&same(binding.sourceIdentity,authority.source),'Exact checked-B1 binding required');
  const exports=mode==='elf'?['p187el_controls','p187el_object','p187el_assembly']:['x187_assemble'];
  need(exports.every(name=>authority.exports.includes(name)),'Checked emitter exports required');
  report.authority={receipt:pin(args['--api']),api:authority.api,source:authority.source,binding};
  report.inputs.push(report.authority.receipt,pin(args['--assets']),authority.api,authority.source,...authority.inputs);
  const tool=key=>{const expected=assets.assets?.[key];need(expected,'Missing asset '+key);const actual=pin(path.resolve(workspace,expected.file));need(same(actual,expected),'Changed tool '+key);report.inputs.push(actual);return actual.file;};
  const assembler=tool('assembler'),linker=tool('linker');need(same(pin(process.execPath),assets.assets?.bun),'Pinned Bun engine');
  for(const key of ['upstream-bend','upstream-comp','base']){const expected=pin(tool(key));need(authority.inputs.some(row=>row.file===expected.file&&same(row,expected)),'API upstream authority '+key);}
  const readelf=fs.realpathSync('/usr/bin/readelf'),objdump=fs.realpathSync('/usr/bin/objdump');report.inputs.push(pin(readelf),pin(objdump));
  const policy=assets.toolchains?.x86;need(policy?.target==='amd64_sysv'&&['assemblerFlags','linkerFlags','libraries'].every(key=>Array.isArray(policy[key])),'AMD64 toolchain policy');report.toolchain=policy;
  const seen=new Set();function includes(file){if(seen.has(file))return;need(seen.size<32,'bounded observer includes');seen.add(file);
    for(const m of fs.readFileSync(file,'utf8').matchAll(/^\s*#include\s+"([^"]+)"/gm)){const child=path.resolve(path.dirname(file),m[1]);need(child.startsWith(workspace+'/'),'local observer include required');report.inputs.push(pin(child));includes(child);}}
  includes(observer);
  if(mode==='elf'){
    const input=pin(fixture('object-elf-controls.bend')),manifestFile=path.join(path.dirname(authority.source.file),'manifest.json'),manifest=read(manifestFile);
    need(manifest.complete&&same(manifest.source,authority.source)&&manifest.inputs.some(row=>row.file===input.file&&same(row,input)),'ELF fixture absent from exact checked source');
    report.inputs.push(input,pin(manifestFile));
  }
  if(builtin){
    const catalog=path.join(workspace,'selfhost/tools/performance/phase112/float/cases.json'),cp=pin(catalog);
    need(cp.sha256==='bde39b2e416263ae82219c601ea409afc0e14be42ddb877a4d8aa4c545ce9753','Frozen FP labels');report.inputs.push(cp);
    const labels=read(catalog).cases,source=fs.readFileSync(observer,'utf8'),word=value=>((BigInt(value.hi)<<32n)|BigInt(value.lo)).toString(16).padStart(16,'0');
    const binary=labels.filter(row=>row.op>=26&&row.op<=35),unary=labels.filter(row=>row.op===23);
    need(binary.length===93&&unary.length===7,'Frozen FP inventory');
    exact(source.split('\n').filter(line=>/^  \{\d+, UINT64_C\(0x/.test(line)),binary.map(row=>
      `  {${row.op}, UINT64_C(0x${word(row.args[0])}), UINT64_C(0x${word(row.args[1])}), UINT64_C(0x${row.expectedHex}), ${row.comparison==='nan-class'?1:0}, ${JSON.stringify(row.name)}},`),'independent binary FP labels');
    exact(source.split('\n').filter(line=>/^  \{UINT64_C\(0x/.test(line)),unary.map(row=>
      `  {UINT64_C(0x${word(row.args[0])}), UINT64_C(0x${row.expectedHex})},`),'independent conversion labels');
  }
  report.inputs.forEach(verify);
  const api=(await import(pathToFileURL(authority.api.file))).default;need(exports.every(name=>typeof api[name]==='function'),'Callable checked emitter');
  const optionalControls=[
    {symbol: 'x187_parse_controls', fixture: 'object-parse-controls.bend', names: 'u64-max u64-carry s64-min negative-one u64-overflow s64-underflow decimal-suffix decimal-empty quad-max long-carry byte-negative byte-overflow long-overflow reloc-positive reloc-negative rip-negative register-r15 register-spl register-xmm15 memory-negative memory-empty memory-overflow high-byte-refusal indexed-refusal trailing-comma unknown-op error-directive section-text section-data type-function type-object alignment alignment-refusal label size size-refusal gnu-stack zero-bound'},
    {symbol: 'x187ec_controls', fixture: 'object-encode-controls.bend', names: 'ret push-rbp push-r15 pop-r12 movq-low movq-high movl-high movb-sil-dil-rex movb-r8b-spl movb-bpl-r9b movb-imm-spl-rex movabs-full64 movq-imm64 movl-full32 addq-reg subq-reg andq-reg xorq-reg xorl-high cmpq-high testl-high andb-low-rex orb-high-low imulq-high imull-high-destination addq-imm32 addq-signed32-min addq-signed32-max cmpq-negative-imm32 andl-unsigned-imm32 imulq-imm32 shlq-imm8 shrq-cl sarl-cl setne-dil setb-r12b movzbl-dil-r9d movzbl-spl-eax rbp-zero-disp8 rsp-zero-sib r12-zero-sib-rex r13-zero-disp8-rex store-r10-r12-disp8 store-r9d-rsp-negative8 rbp-positive127 rbp-positive128 r13-negative128 r13-negative129 rax-disp32-r11 lea-r12-disp32-r13 addq-memory-source cmpb-memory-destination movl-imm-r12-disp32 movb-imm-rbp-negative1 movq-imm-negative-r13 addss-prefix-before-rex subss-operand-order mulss-high-destination divss-high-source ucomiss-high movaps-high pxor-low pxor-high movd-gpr-to-xmm movd-xmm-to-gpr movd-high-gpr-to-xmm movd-high-xmm-to-gpr movd-rsp-to-xmm8 movd-xmm8-to-r13 cvtsi2ssq-r10-xmm3 cvtsi2ssq-rax-xmm8 call-plt32-offset jmp-pc32-offset jz-pc32-offset rip-lea-zero-addend rip-load-positive-addend rip-addend-borrow rip-addend-negative rip-trailing-imm32 rip-trailing-imm8 rip-sse-prefix-offset rip-movq-trailing-imm32 reject-unknown-op reject-extra-ret-operand reject-movq-width32 reject-register16 reject-vector-integer reject-movabs-register-register reject-memory-memory reject-memory-base16 reject-positive64-imm32 reject-movq-memory-positive64-imm32 reject-negative64-imm32 reject-movl-highword reject-shift-not-cl reject-shift-imm256 reject-set-width32 reject-movzbl-source32 reject-sse-gpr reject-sse-register16 reject-sse-width32 reject-movd-gpr64 reject-cvtsi-width32 reject-call-register reject-empty-call-target reject-offset-overflow'},
  ];
  report.admission=[];report.admissionSkipped=[];
  for(const control of optionalControls){
    if(!authority.exports.includes(control.symbol)){report.admissionSkipped.push(control.symbol);continue;}
    need(typeof api[control.symbol]==='function','Callable optional control '+control.symbol);
    const input=pin(fixture(control.fixture)),manifestFile=path.join(path.dirname(authority.source.file),'manifest.json'),manifest=read(manifestFile);
    need(manifest.complete&&same(manifest.source,authority.source)&&manifest.inputs.some(row=>row.file===input.file&&same(row,input)),'Optional controls absent from checked source: '+control.fixture);
    report.inputs.push(input,pin(manifestFile));
    const observed=[];let xs=api[control.symbol]();
    while(xs?.$==='Con'){need(observed.length<256,'bounded control inventory');observed.push(xs.head);xs=xs.tail;}
    need(xs?.$==='Nil','proper control list');exact(observed,control.names.split(' ').map(name=>name+'=1'),control.symbol+' exact controls');
    report.admission.push({symbol:control.symbol,count:observed.length,rows:observed});save();
  }
  if(mode==='elf'){
    const expected='valid-object elf-magic elf64-little-endian relocatable-amd64 fixed-section-table empty-object bad-byte bad-rodata-byte bad-data-byte empty-symbol nul-symbol non-ascii-symbol bad-symbol-section bad-symbol-kind symbol-outside symbol-size-outside symbol-size-overflow undefined-local undefined-nonzero duplicate-cross-binding unknown-relocation-symbol unknown-relocation-kind unknown-relocation-section relocation-overrun relocation-offset-overflow absolute-last-byte pc32-last-byte'.split(' ').map(name=>name+'=1');
    const rows=[];let xs=api.p187el_controls();while(xs?.$==='Con'){need(rows.length<100,'bounded ELF controls');rows.push(xs.head);xs=xs.tail;}
    need(xs?.$==='Nil','proper ELF controls');exact(rows,expected,'ELF admission controls');report.rows=rows;
    const source=api.p187el_assembly();need(typeof source==='string'&&source.length>0&&source.length<65536,'bounded ELF reference text');assembly=write('elf-reference.s',source);
  }
  const text=fs.readFileSync(assembly,'utf8');need(text.length>0&&text.length<32*1024*1024,'Bounded nonempty input assembly');
  const start=performance.now(),result=mode==='elf'?api.p187el_object():api.x187_assemble(text),objectBytes=bytes(result,'positive');report.encodingSeconds=(performance.now()-start)/1000;
  need(result.error===''&&objectBytes.length>0,'Object emission refused: '+result.error);
  const repeat=mode==='elf'?api.p187el_object():api.x187_assemble(text);need(repeat.error===''&&bytes(repeat,'repeat').equals(objectBytes),'Nondeterministic object bytes');
  const direct=write('direct.o',objectBytes),reference=path.join(out,'reference.o');
  const negatives=[['opcode','.text\nnot_an_instruction %rax\n'],['register','.text\nmovq %r16, %rax\n'],
    ['arity','.text\nmovq %rax\n'],['destination','.text\nmovq $1, $2\n'],['register-class','.text\npushq %xmm0\n'],
    ['duplicate-label','.text\np187_dup:\nret\np187_dup:\nret\n'],['directive','.unsupported 1\n'],['overflow','.data\n.quad 18446744073709551616\n']];
  for(const [name,input]of mode==='elf'?[]:negatives){const rejected=api.x187_assemble(input),data=bytes(rejected,name);report.refusals.push({name,input,error:rejected.error,bytes:data.length});save();need(rejected.error!==''&&data.length===0,'Malformed assembly admitted: '+name);}
  run('reference-assemble',[assembler,...policy.assemblerFlags,'-o',reference,assembly]);record(reference);
  for(const [role,file]of [['direct',direct],['reference',reference]]){
    run(role+'-readelf',[readelf,'-W','-h','-S','-s','-r',file]);run(role+'-objdump',[objdump,'-drw',file]);
    report.objects[role]=elf(file);save();
  }
  const inventory=o=>o.symbols.filter(s=>s.binding!==0).map(s=>({name:s.name,binding:s.binding,kind:s.kind,section:s.section===0?'UND':o.sections[s.section]?.name})).sort((a,b)=>a.name.localeCompare(b.name));
  exact(inventory(report.objects.direct),inventory(report.objects.reference),'global and undefined symbol inventory');
  report.textSizeRatio=report.objects.direct.textBytes/report.objects.reference.textBytes;
  if(mode==='elf'){
    exact(report.objects.direct.relocations.map(r=>[r.section,r.offset,r.kind,r.symbol,r.addend]),[
      ['.text','2',1,'p187elf_data','0'],['.text','14',2,'p187elf_data','-4'],['.text','20',4,'p187elf_external','-4'],['.text','25',2,'p187elf_local','-4'],
      ['.rodata','8',1,'p187elf_data','8'],['.data','16',1,'p187elf_data','8'],['.data','24',1,'p187elf_call','0']], 'independent ELF relocation inventory');
  }
  const observerObject=path.join(out,'observer.o');run('observer-compile',[linker,'-std=c11','-O2','-fno-pie','-c',observer,'-o',observerObject]);record(observerObject);
  const extras=[];for(let i=0;i<extra.length;i++){const object=path.join(out,'extra-'+i+'.o');run('extra-'+i,[assembler,...policy.assemblerFlags,'-o',object,extra[i]]);record(object);extras.push(object);}
  const expected=fs.readFileSync(expectation,'utf8');
  for(const [role,file]of [['direct',direct],['reference',reference]]){
    const binary=path.join(out,role);run(role+'-link',[linker,...policy.linkerFlags,observerObject,...extras,file,...policy.libraries,'-o',binary]);record(binary);
    run(role+'-execute',[binary],expected);report.machines.push({role,complete:true,binary:pin(binary),expected});save();
  }
  report.inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
report.seconds=(performance.now()-elapsed)/1000;report.finished=new Date().toISOString();save();
console.log(JSON.stringify({complete:report.complete,refusals:report.refusals.length,textSizeRatio:report.textSizeRatio,machines:report.machines,error:report.error}));
