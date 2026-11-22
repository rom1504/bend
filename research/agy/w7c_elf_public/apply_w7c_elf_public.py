#!/usr/bin/env python3
"""Wave 7c patcher: P134Public + x187/x188 direct instruction encoder & single-pass ELF emission.

Disjoint ownership:
  - x202k_template (compact pre-encoded continuation thunk, 26 bytes vs 28 insts)
  - x181_program_public_fast (fused scalar check + omit unused .L*_loop label for non-loop segments)
  - x188_build_instruction (direct reverse-push encoder for hot movq/movabsq/leaq/call/xorl/pushq/popq/ret)
  - x187_elf_symbol_add / x188_build_symbol_checked (single-pass ASCII validation+encode, direct table reverse-push)
  - x187_elf_checked / w7_elf_sections_fast (fused single-pass relocation validation + partitioning)
"""
import argparse
import sys


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    cnt = src.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return src.replace(old, new, 1)


def apply_patch(src: str) -> str:
    # 1. Compact pre-encoded x202k_template (21 bytes PBytes + jmp p111_rt_apply = 26 bytes, zero .L*_loop label)
    old_x202k = """@unsafe
def x202k_template(+symbol: String) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{2320,0},x188_reg(4,64)),x188_i2("movq",x188_reg(12,64),X187Mem{5,4294967280}),
    x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),x188_i2("movq",x188_reg(0,64),x188_reg(12,64)),
    x188_label(".L" ++ symbol ++ "_loop"),
    x188_i2("movq",X187Mem{12,16},x188_reg(7,64)),x188_i2("movabsq",X187Imm{4294967288,4294967295},x188_reg(11,64)),
    x188_i2("addq",x188_reg(11,64),x188_reg(7,64)),x188_i2("movq",x188_reg(7,64),X187Mem{12,16}),
    x188_i2("movq",X187Mem{12,16},x188_reg(7,64)),x188_i2("movq",X187Mem{7,0},x188_reg(6,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(7,64)),x188_i2("movq",x188_reg(12,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,24}),x188_i2("movq",x188_reg(7,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,32}),x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,40}),x188_i2("movq",X187Mem{4,24},x188_reg(7,64)),
    x188_i2("movq",X187Mem{4,32},x188_reg(6,64)),x188_i2("movq",X187Mem{4,40},x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),x188_i1("call",X187Target{"p111_rt_apply"}),
    x188_i2("movq",x188_reg(0,64),x188_reg(7,64)),x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),
    x188_i2("movq",X187Mem{5,4294967280},x188_reg(12,64)),x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),
    x188_i1("popq",x188_reg(5,64)),x188_i0("ret"),X188One{PSize{symbol}}])],""}"""

    new_x202k = """@unsafe
def x202k_template(+symbol: String) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    X188One{PBytes{[72,139,71,16,72,131,232,8,72,137,71,16,72,139,16,72,139,119,40,49,192]}},
    x188_i1("jmp",X187Target{"p111_rt_apply"}),X188One{PSize{symbol}}])],""}"""

    src = replace_exact(src, old_x202k, new_x202k, "x202k_template")

    # 2. Single-pass ELF symbol add (fused ASCII validate+encode, direct 24B table push)
    old_sym_add = """@unsafe
def x187_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,section,value,size,global,kind}
      X187ElfSymbols{+index,+count,+firstGlobal,+table,+strings,+stringSize,+error}:
      +encoded = x187_elf_ascii(name,[])
      +length = U32.inc(nt_count(U32,encoded))
      nt_choose(X187ElfSymbols,String.is_empty(error) && x187_elf_symbol_valid(symbol,sizes) &&
          agy_str_eq(dk(p111v_get(index,name)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p111v_put(index,name,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          nt_reverse(U32,x187_elf_symbol_bytes(symbol,stringSize),table),
          Con{0,x187_elf_cat(encoded,strings)},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})"""

    new_sym_add = """type W7cAscii is Data:
  W7cAscii{+ok: Bool, +bytes: List<&2,U32>, +len: U32}

@unsafe
def w7c_elf_ascii_valid(text: String, +acc: List<&2,U32>, +len: U32) -> W7cAscii:
  match text:
    case SNil{}: W7cAscii{U32.is_gt(len,0),acc,len}
    case SCon{+head,rest}:
      +ch = Char.to_u32(head)
      nt_choose(W7cAscii,U32.is_lt(len,4096) && U32.is_gt(ch,0) && U32.is_lt(ch,128),
        u => w7c_elf_ascii_valid(rest,Con{ch,acc},U32.inc(len)),
        u => W7cAscii{False{},acc,len})

@unsafe
def w7c_elf_sym_nums_valid(+section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32, sizes: X187ElfSizes) -> Bool:
  +limit = x187_elf_section_size(section,sizes)
  U32.is_le(section,3) && U32.is_le(kind,2) &&
    U32.is_le(value,limit) && U32.is_le(size,U32.sub(limit,value)) &&
    (Bool.not(U32.is_eq(section,0)) || (global && U32.is_eq(value,0) && U32.is_eq(size,0)))

@unsafe
def w7c_u32_rev(+v: U32, tail: List<&2,U32>) -> List<&2,U32>:
  Con{U32.shrn(v,24n),Con{U32.and(U32.shrn(v,16n),255),
    Con{U32.and(U32.shrn(v,8n),255),Con{U32.and(v,255),tail}}}}

@unsafe
def w7c_elf_sym_push(+nameOffset: U32, +info: U32, +section: U32, +value: U32, +size: U32, table: List<&2,U32>) -> List<&2,U32>:
  Con{0,Con{0,Con{0,Con{0,w7c_u32_rev(size,
    Con{0,Con{0,Con{0,Con{0,w7c_u32_rev(value,
      Con{U32.and(U32.shrn(section,8n),255),Con{U32.and(section,255),
        Con{0,Con{info,w7c_u32_rev(nameOffset,table)}}}})}}}})}}}}

@unsafe
def w7c_elf_sym_add_ascii(+name: String, +section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32,
    +sizes: X187ElfSizes, +index: KDef, +count: U32, +firstGlobal: U32, +table: List<&2,U32>,
    +strings: List<&2,U32>, +stringSize: U32, +error: String, asc: W7cAscii) -> X187ElfSymbols:
  match asc:
    case W7cAscii{ok,+strBytes,+nlen}:
      +length = U32.inc(nlen)
      nt_choose(X187ElfSymbols,ok && String.is_empty(error) &&
          w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes) &&
          agy_str_eq(dk(p111v_get(index,name)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p111v_put(index,name,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          w7c_elf_sym_push(stringSize,U32.add(kind,nt_choose(U32,global,v => 16,v => 0)),section,value,size,table),
          Con{0,strBytes},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})

@unsafe
def x187_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}
      X187ElfSymbols{+index,+count,+firstGlobal,table,+strings,+stringSize,+error}:
      w7c_elf_sym_add_ascii(name,section,value,size,global,kind,sizes,index,count,firstGlobal,table,strings,stringSize,error,
        w7c_elf_ascii_valid(name,strings,0))"""

    src = replace_exact(src, old_sym_add, new_sym_add, "x187_elf_symbol_add")

    # 3. Single-pass fused relocation validation + partitioning (1 p111v_get per reloc instead of 2)
    old_elf_checked = """@unsafe
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error) && x187_elf_relocs_valid(relocations,sizes,index,0),
        u => w7_elf_sections_fast(object,sizes,symbols),
        u => X187ObjectResult{[],p111_first(error,"invalid ELF relocation")})"""

    new_elf_checked = """type W7cRelocResult is Data:
  W7cRelocOk{+parts: W7RelocParts}
  W7cRelocBad{}

law w7c_relocs_fused:
  for items: List<&2,X187Relocation>
  for +sizes: X187ElfSizes
  for +index: KDef
  for +count: U32
  for +r1: List<&2,U32>
  for +n1: U32
  for +r2: List<&2,U32>
  for +n2: U32
  for +r3: List<&2,U32>
  for +n3: U32
  W7cRelocResult

@unsafe
def w7c_reloc_fused_add(sec: U32, offset: U32, kind: U32, symIdx: U32, lo: U32, hi: U32,
    rest: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7cRelocResult:
  match sec:
    case 1: w7c_relocs_fused(rest,sizes,index,U32.inc(count),w7_reloc_enc(offset,kind,symIdx,lo,hi,r1),U32.add(n1,24),r2,n2,r3,n3)
    case 2: w7c_relocs_fused(rest,sizes,index,U32.inc(count),r1,n1,w7_reloc_enc(offset,kind,symIdx,lo,hi,r2),U32.add(n2,24),r3,n3)
    case _: w7c_relocs_fused(rest,sizes,index,U32.inc(count),r1,n1,r2,n2,w7_reloc_enc(offset,kind,symIdx,lo,hi,r3),U32.add(n3,24))

@unsafe
def w7c_reloc_fused_sym(+sec: U32, +offset: U32, +kind: U32, +lo: U32, +hi: U32,
    +sym: KDef, +rest: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7cRelocResult:
  +limit = x187_elf_section_size(sec,sizes)
  +width = nt_choose(U32,U32.is_eq(kind,1),u => 8,u => 4)
  nt_choose(W7cRelocResult,U32.is_lt(count,1048576) && U32.is_ge(sec,1) && U32.is_le(sec,3) &&
      (U32.is_eq(kind,1) || U32.is_eq(kind,2) || U32.is_eq(kind,4)) &&
      U32.is_le(offset,limit) && U32.is_le(width,U32.sub(limit,offset)) &&
      agy_str_eq(dk(sym),"X187Symbol"),
    u => w7c_reloc_fused_add(sec,offset,kind,da(sym),lo,hi,rest,sizes,index,count,r1,n1,r2,n2,r3,n3),
    u => W7cRelocBad{})

@unsafe
def w7c_relocs_fused(items,sizes,index,count,r1,n1,r2,n2,r3,n3):
  match items:
    case Nil{}: W7cRelocOk{W7RelocParts{r1,n1,r2,n2,r3,n3}}
    case Con{X187Relocation{sec,offset,kind,symbol,lo,hi},rest}:
      w7c_reloc_fused_sym(sec,offset,kind,lo,hi,p111v_get(index,symbol),rest,sizes,index,count,r1,n1,r2,n2,r3,n3)

@unsafe
def w7c_elf_checked_go(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rr: W7cRelocResult) -> X187ObjectResult:
  match rr:
    case W7cRelocOk{rp}: w7_elf_sections_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,rp)
    case W7cRelocBad{}: X187ObjectResult{[],"invalid ELF relocation"}

@unsafe
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
         X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w7c_elf_checked_go(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => X187ObjectResult{[],error})"""

    src = replace_exact(src, old_elf_checked, new_elf_checked, "x187_elf_checked")

    # 4. Eliminate redundant x187_elf_name char walk in x188_build_symbol_checked (already validated by x188_symbol_count)
    old_sym_chk = """@unsafe
def x188_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>
        x187_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})"""

    new_sym_chk = """@unsafe
def x188_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}:
      nt_choose(X187ObjectResult,w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes),u =>
        x187_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})"""

    src = replace_exact(src, old_sym_chk, new_sym_chk, "x188_build_symbol_checked")

    # 5. Direct reverse-push fast instruction encoder in x188_build_instruction
    old_build_inst = """@unsafe
def w7_build_inst_enc(enc: X187Encoded, +inst: X187Instruction, +build: X187Build) -> X187Build:
  match enc:
    case X187Encoded{bytes,Nil{},SNil{}}: x187_build_bytes(bytes,build)
    case other: x187_build_encoded(x188_branch_encoded(inst,other),build)

@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  w7_build_inst_enc(x187_encode(inst,x187_build_offset(build)),inst,build)"""

    new_build_inst = """@unsafe
def w7_build_inst_enc(enc: X187Encoded, +inst: X187Instruction, +build: X187Build) -> X187Build:
  match enc:
    case X187Encoded{bytes,Nil{},SNil{}}: x187_build_bytes(bytes,build)
    case other: x187_build_encoded(x188_branch_encoded(inst,other),build)

@unsafe
def w7c_push_mem_mode(mode: U32, +disp: U32, t1: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>,
    +ts: U32, +n1: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match mode:
    case 0: X187Build{1,t1,r,d,U32.add(ts,n1),rs,ds,symbols,names,relocs,error}
    case 1: X187Build{1,Con{U32.and(disp,255),t1},r,d,U32.add(ts,U32.inc(n1)),rs,ds,symbols,names,relocs,error}
    case _: X187Build{1,w7c_u32_rev(disp,t1),r,d,U32.add(ts,U32.add(n1,4)),rs,ds,symbols,names,relocs,error}

@unsafe
def w7c_push_mem(+rex: U32, +opcode: U32, +reg: U32, +base: U32, +disp: U32,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  +low = U32.and(base,7)
  +rlow = U32.mul(U32.and(reg,7),8)
  +zero = U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5))
  +short = U32.is_le(disp,127) || U32.is_ge(disp,4294967168)
  +mode = nt_choose(U32,zero,u => 0,u => nt_choose(U32,short,v => 1,v => 2))
  +modrm = U32.add(U32.mul(mode,64),U32.add(rlow,low))
  +t0 : List<&2,U32> = Con{modrm,Con{opcode,Con{rex,t}}}
  +t1 = nt_choose(List<&2,U32>,U32.is_eq(low,4),u => Con{36,t0},u => t0)
  +n1 = nt_choose(U32,U32.is_eq(low,4),u => 4,u => 3)
  w7c_push_mem_mode(mode,disp,t1,r,d,ts,n1,rs,ds,symbols,names,relocs,error)

@unsafe
def w7c_fast_movq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,64,False{}} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u => X187Build{1,
          Con{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
          Con{137,Con{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}},
          r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Reg{+s,64,False{}} X187Mem{+b,+disp}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(b,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Mem{+b,+disp} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(b,16) && U32.is_lt(dd,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def w7c_fast_leaq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Mem{+b,+disp} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(b,16) && U32.is_lt(dd,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),141,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Rip{+sym,+lo,+hi} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,Bool.not(String.is_empty(sym)) && U32.is_lt(dd,16),
        u => x187_build_relocation(
          X187Relocation{1,U32.add(ts,3),2,sym,U32.sub(lo,4),U32.sub(hi,nt_choose(U32,U32.is_lt(lo,4),v => 1,v => 0))},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{U32.add(5,U32.mul(U32.and(dd,7),8)),
            Con{141,Con{U32.add(72,U32.mul(U32.shrn(dd,3n),4)),t}}}}}}},
            r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def w7c_fast_movabsq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Imm{+lo,+hi} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16),
        w => X187Build{1,w7c_u32_rev(hi,w7c_u32_rev(lo,Con{U32.add(184,U32.and(dd,7)),Con{U32.add(72,U32.shrn(dd,3n)),t}})),
          r,d,U32.add(ts,10),rs,ds,symbols,names,relocs,error},
        w => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def w7c_fast_inst_c(c0: U32, +tail: String, operands: List<&2,X187Operand>, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match c0 operands:
    case 109 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"ovq"),
        u => w7c_fast_movq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"ovabsq"),
          v => w7c_fast_movabsq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 108 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"eaq"),
        u => w7c_fast_leaq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 99 Con{X187Target{+sym},Nil{}}:
      nt_choose(X187Build,agy_str_eq(tail,"all") && Bool.not(String.is_empty(sym)),
        u => x187_build_relocation(X187Relocation{1,U32.inc(ts),4,sym,4294967292,4294967295},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{232,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 120 Con{X187Reg{+s,32,False{}},Con{X187Reg{+dd,32,False{}},Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"orl") && U32.is_lt(s,8) && U32.is_lt(dd,8),
        u => X187Build{1,Con{U32.add(192,U32.add(U32.mul(s,8),dd)),Con{49,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 114 Nil{}:
      nt_choose(X187Build,agy_str_eq(tail,"et"),
        u => X187Build{1,Con{195,t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 112 Con{X187Reg{+dd,64,False{}},Nil{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"ushq"),
        u => nt_choose(X187Build,U32.is_lt(dd,8),
          v => X187Build{1,Con{U32.add(80,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
          v => X187Build{1,Con{U32.add(80,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"opq"),
          v => nt_choose(X187Build,U32.is_lt(dd,8),
            w => X187Build{1,Con{U32.add(88,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
            w => X187Build{1,Con{U32.add(88,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  match inst build:
    case X187Instruction{SCon{+ch,+tail},+operands} X187Build{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+error}:
      nt_choose(X187Build,U32.is_le(ts,33554416),
        u => w7c_fast_inst_c(Char.to_u32(ch),tail,operands,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,x187_build_offset(build)),inst,build)"""

    src = replace_exact(src, old_build_inst, new_build_inst, "x188_build_instruction")

    # 6. Fast P134Public in x181_program_public_fast: omit unused .L<sym>_loop label for public segments + fuse scalar check
    old_pub_fast = """@unsafe
def x181_program_public_fast(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = p111_first(x181_program_scalars(body,available),x181_hygiene_scalars(body))
      nt_choose(X181Output,String.is_empty(error),
        u => nt_choose(X181Output,x202k_shape(body),v => x202k_template(p111q_symbol(name)),
          v => x181_function_fast(p111q_symbol(name),["state"],x181_scalar_rows(body),ids)),
        u => X181Output{[],error})"""

    new_pub_fast = """@unsafe
def w7c_public_fast_emit(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +ids: N111Ids) -> X181Output:
  +frame = x186_saves_frame(x181_frame(symbol,params,body))
  x181_function_fast_done(symbol,x181_stmts(body,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))

@unsafe
def w7c_public_fast_late(symbol: String, params: List<&2,String>, ids: N111Ids, body: P113ABody) -> X181Output:
  match body:
    case P113ABody{ready,_}: w7c_public_fast_emit(symbol,params,ready,ids)

@unsafe
def w7c_public_fast(+symbol: String, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_body_names(body),
    u => w7c_public_fast_late(symbol,["state"],ids,x185_late_stmts(body,ids,0)),
    u => w7c_public_fast_emit(symbol,["state"],body,ids))

law w7c_pub_check_scalars:
  for body: List<&2,N111Stmt>
  for +available: KDef
  String

@unsafe
def w7c_pub_check_scalar(stmt: N111Stmt, +available: KDef) -> String:
  match stmt:
    case N111Set{name,typ,value}: p111_first(x181_program_value(value,available),x181_hygiene_name(name))
    case N111Bin{name,typ,op,left,right}:
      p111_first(x181_program_value(left,available),p111_first(x181_program_value(right,available),x181_hygiene_name(name)))
    case N111Call{name,typ,symbol,args}:
      p111_first(x181_program_symbol(symbol,available),p111_first(x181_program_args(args,available),x181_hygiene_name(name)))
    case N111If{condition,yes,no}:
      p111_first(x181_program_value(condition,available),
        p111_first(w7c_pub_check_scalars(yes,available),w7c_pub_check_scalars(no,available)))
    case N111Return{value}: x181_program_value(value,available)
    case N111Load{name,typ,base,offset}: p111_first(x181_program_value(base,available),x181_hygiene_name(name))
    case N111Store{typ,base,offset,value}:
      p111_first(x181_program_value(base,available),x181_program_value(value,available))
    case N111Offset{name,base,bytes}:
      p111_first(x181_program_value(base,available),p111_first(x181_program_value(bytes,available),x181_hygiene_name(name)))
    case N111Alloca{name,bytes,align}: x181_hygiene_name(name)

@unsafe
def w7c_pub_check_scalars(body,available):
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(w7c_pub_check_scalar(head,available),w7c_pub_check_scalars(rest,available))

@unsafe
def x181_program_public_fast(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = w7c_pub_check_scalars(body,available)
      nt_choose(X181Output,String.is_empty(error),
        u => nt_choose(X181Output,x202k_shape(body),v => x202k_template(p111q_symbol(name)),
          v => w7c_public_fast(p111q_symbol(name),x181_scalar_rows(body),ids)),
        u => X181Output{[],error})"""

    src = replace_exact(src, old_pub_fast, new_pub_fast, "x181_program_public_fast")
    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    args = ap.parse_args()
    with open(args.src, "r", encoding="utf-8") as f:
        text = f.read()
    out = apply_patch(text)
    with open(args.dst, "w", encoding="utf-8") as f:
        f.write(out)
    print(f"Patched {args.src} -> {args.dst} ({len(text)} -> {len(out)} bytes)")


if __name__ == "__main__":
    main()
