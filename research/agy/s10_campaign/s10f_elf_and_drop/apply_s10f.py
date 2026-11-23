#!/usr/bin/env python3
"""S10-F: Fast x187_pub + Fast x187_elf + -O2 Fast Sink Patch.

Idempotent patch against `selfhost/build/agy/wave15_unified/compiler.bend`
(and standalone `selfhost/build/agy/k10_wave15/m09.bend` for fast single-module iteration).
"""
from __future__ import annotations

import argparse
from pathlib import Path

MARKER = "# === S10-F: Fast x187_pub + x187_elf + -O2 Fast Sink ==="

SINK_TPL = [
    72,133,246,15,141,59,0,0,0,76,139,15,73,137,240,73,193,224,24,73,193,232,24,79,141,20,193,77,139,26,
    68,137,216,129,224,255,255,255,0,129,248,1,0,0,0,15,134,92,0,0,0,73,129,235,1,0,0,0,77,137,26,49,192,
    233,82,0,0,0,72,137,240,72,193,232,56,72,129,248,2,0,0,0,15,130,48,0,0,0,73,137,240,73,193,224,24,73,
    193,232,24,76,139,13,0,0,0,0,73,129,193,127,0,0,0,73,129,225,128,255,255,255,73,129,193,0,130,16,3,77,
    57,200,15,131,7,0,0,0,49,192,233,7,0,0,0,49,192,232,0,0,0,0,
]

KEEP_TPL = [
    72,133,246,15,141,60,0,0,0,76,139,15,73,137,240,73,193,224,24,73,193,232,24,79,141,20,193,77,139,26,
    68,137,216,129,224,255,255,255,0,129,248,254,255,255,0,15,131,94,0,0,0,73,129,195,1,0,0,0,77,137,26,
    72,137,240,233,83,0,0,0,72,137,240,72,193,232,56,72,129,248,2,0,0,0,15,130,48,0,0,0,73,137,240,73,193,
    224,24,73,193,232,24,76,139,13,0,0,0,0,73,129,193,127,0,0,0,73,129,225,128,255,255,255,73,129,193,0,
    130,16,3,77,57,200,15,131,8,0,0,0,72,137,240,233,7,0,0,0,49,192,232,0,0,0,0,
]


def _gen_chunked_push(prefix: str, data: list[int], chunk: int = 30) -> str:
    lines = []
    n_chunks = (len(data) + chunk - 1) // chunk
    for ci in range(n_chunks):
        sub = data[ci * chunk : (ci + 1) * chunk]
        expr = "t"
        for b in sub:
            expr = f"Con{{{b},{expr}}}"
        lines.append(f"@unsafe\ndef {prefix}_{ci}(t: List<&2,U32>) -> List<&2,U32>:\n  {expr}\n")
    chain = "t"
    for ci in range(n_chunks):
        chain = f"{prefix}_{ci}({chain})"
    lines.append(f"@unsafe\ndef {prefix}(t: List<&2,U32>) -> List<&2,U32>:\n  {chain}\n")
    return "\n".join(lines)


S10F_CODE = f"""
{MARKER}

# ============================================================================
# Part 1: 8x-Unrolled Byte Reversal & Text Fixup + Fast Streaming ELF Finisher
# ============================================================================

type S10fSymPart is Data:
  S10fSymPart{{+locals: List<&2,X187Symbol>, +globals: List<&2,X187Symbol>, +error: String}}

type S10fHotIdx is Data:
  S10fHotIdx{{+i0: U32, +i1: U32, +i2: U32, +i3: U32, +i4: U32, +i5: U32, +i6: U32, +i7: U32}}

@unsafe
def s10f_u32_rev(+v: U32, tail: List<&2,U32>) -> List<&2,U32>:
  Con{{U32.shrn(v,24n),Con{{U32.and(U32.shrn(v,16n),255),
    Con{{U32.and(U32.shrn(v,8n),255),Con{{U32.and(v,255),tail}}}}}}}}

@unsafe
def s10f_reloc_enc(+offset: U32, +kind: U32, +symIdx: U32, +lo: U32, +hi: U32, acc: List<&2,U32>) -> List<&2,U32>:
  s10f_u32_rev(hi,s10f_u32_rev(lo,s10f_u32_rev(symIdx,
    s10f_u32_rev(kind,Con{{0,Con{{0,Con{{0,Con{{0,s10f_u32_rev(offset,acc)}}}}}}}}))))

@unsafe
def s10f_elf_sym_push(+nameOffset: U32, +info: U32, +section: U32, +value: U32, +size: U32, table: List<&2,U32>) -> List<&2,U32>:
  Con{{0,Con{{0,Con{{0,Con{{0,s10f_u32_rev(size,
    Con{{0,Con{{0,Con{{0,Con{{0,s10f_u32_rev(value,
      Con{{U32.and(U32.shrn(section,8n),255),Con{{U32.and(section,255),
        Con{{0,Con{{info,s10f_u32_rev(nameOffset,table)}}}}}}}})}}}}}}}})}}}}}}}}

@unsafe
def s10f_ascii_valid(text: String, +acc: List<&2,U32>, +len: U32) -> W7cAscii:
  match text:
    case SNil{{}}: W7cAscii{{U32.is_gt(len,0),acc,len}}
    case SCon{{+head,rest}}:
      +ch = Char.to_u32(head)
      nt_choose(W7cAscii,U32.is_lt(len,4096) && U32.is_gt(ch,0) && U32.is_lt(ch,128),
        u => s10f_ascii_valid(rest,Con{{ch,acc}},U32.inc(len)),
        u => W7cAscii{{False{{}},acc,len}})

@unsafe
def s10f_rev8(xs: List<&2,U32>, acc: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Con{{a,Con{{b,Con{{c,Con{{d,Con{{e,Con{{f,Con{{g,Con{{h,rest}}}}}}}}}}}}}}}}:
      s10f_rev8(rest,Con{{h,Con{{g,Con{{f,Con{{e,Con{{d,Con{{c,Con{{b,Con{{a,acc}}}}}}}}}}}}}}}})
    case Con{{a,Con{{b,Con{{c,Con{{d,rest}}}}}}}}:
      s10f_rev8(rest,Con{{d,Con{{c,Con{{b,Con{{a,acc}}}}}}}})
    case Con{{a,rest}}: s10f_rev8(rest,Con{{a,acc}})
    case Nil{{}}: acc

law s10f_apply:
  for +raw: List<&2,U32>
  for +patches: List<&2,X187Relocation>
  for end: U32
  for +acc: List<&2,U32>
  X187Encoded

law s10f_span8:
  for +count: U32
  for +raw: List<&2,U32>
  for +patches: List<&2,X187Relocation>
  for +offset: U32
  for +word: U32
  for +acc: List<&2,U32>
  X187Encoded

@unsafe
def s10f_span8_take8(+count: U32, raw: List<&2,U32>, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match raw:
    case Con{{a,Con{{b,Con{{c,Con{{d,Con{{e,Con{{f,Con{{g,Con{{h,rest}}}}}}}}}}}}}}}}:
      s10f_span8(U32.sub(count,8),rest,patches,offset,word,
        Con{{h,Con{{g,Con{{f,Con{{e,Con{{d,Con{{c,Con{{b,Con{{a,acc}}}}}}}}}}}}}}}})
    case _: X187Encoded{{[],[],"local branch fixup outside text"}}

@unsafe
def s10f_span8_take4(+count: U32, raw: List<&2,U32>, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match raw:
    case Con{{a,Con{{b,Con{{c,Con{{d,rest}}}}}}}}:
      s10f_span8(U32.sub(count,4),rest,patches,offset,word,
        Con{{d,Con{{c,Con{{b,Con{{a,acc}}}}}}}})
    case _: X187Encoded{{[],[],"local branch fixup outside text"}}

@unsafe
def s10f_span8_small(+count: U32, raw: List<&2,U32>, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match count raw:
    case 0 Con{{0,Con{{0,Con{{0,Con{{0,rest}}}}}}}}:
      s10f_apply(rest,patches,offset,
        Con{{U32.and(word,255),Con{{U32.and(U32.shrn(word,8n),255),
          Con{{U32.and(U32.shrn(word,16n),255),Con{{U32.shrn(word,24n),acc}}}}}}}})
    case 0 _: X187Encoded{{[],[],"invalid local branch placeholder"}}
    case _ Nil{{}}: X187Encoded{{[],[],"local branch fixup outside text"}}
    case _ Con{{head,rest}}: s10f_span8(U32.sub(count,1),rest,patches,offset,word,Con{{head,acc}})

@unsafe
def s10f_span8(count, raw, patches, offset, word, acc):
  nt_choose(X187Encoded,U32.is_ge(count,8),
    u => s10f_span8_take8(count,raw,patches,offset,word,acc),
    u => nt_choose(X187Encoded,U32.is_ge(count,4),
      v => s10f_span8_take4(count,raw,patches,offset,word,acc),
      v => s10f_span8_small(count,raw,patches,offset,word,acc)))

@unsafe
def s10f_apply(raw, patches, end, acc):
  match patches:
    case Nil{{}}: X187Encoded{{s10f_rev8(raw,acc),[],""}}
    case Con{{X187Relocation{{s,+offset,k,n,word,hi}},rest}}:
      s10f_span8(U32.sub(U32.sub(end,offset),4),raw,rest,offset,word,acc)

@unsafe
def s10f_selected(+raw: List<&2,U32>, patches: List<&2,X187Relocation>, +size: U32,
    +plan: List<&2,X187Relocation>) -> X187Encoded:
  match patches plan:
    case Nil{{}} Nil{{}}: X187Encoded{{s10f_rev8(raw,[]),[],""}}
    case Con{{_,_}} Nil{{}}: x188_fixup_bytes(s10f_rev8(raw,[]),patches,0,[])
    case _ Con{{_,_}}: s10f_apply(raw,plan,size,[])

@unsafe
def s10f_starts_dot(s: String) -> Bool:
  match s:
    case SCon{{c,_}}: U32.is_eq(Char.to_u32(c),46)
    case SNil{{}}: False{{}}

@unsafe
def s10f_fixup_keep(+reloc: X187Relocation, state: X188Fixups) -> X188Fixups:
  match reloc state:
    case X187Relocation{{s,o,k,+name,lo,hi}} X188Fixups{{patches,relocations,+escaped,error}}:
      X188Fixups{{patches,Con{{reloc,relocations}},
        nt_choose(KDef,s10f_starts_dot(name) && String.starts_with(name,".L"),
          u => p111v_put(escaped,name,"X188Escaped",0,0),u => escaped),error}}

@unsafe
def s10f_fixup_item(+reloc: X187Relocation, +index: KDef, +size: U32, +state: X188Fixups) -> X188Fixups:
  match reloc:
    case X187Relocation{{section,offset,+kind,name,lo,hi}}:
      nt_choose(X188Fixups,U32.is_eq(kind,131),
        u => x188_fixup_add(X187Relocation{{1,offset,2,"",lo,0}},state),
        u => nt_choose(X188Fixups,U32.is_eq(kind,130),
          v => x188_fixup_symbol(reloc,size,state,p111v_get(index,name)),
          v => s10f_fixup_keep(reloc,state)))

@unsafe
def s10f_fixup_scan(items: List<&2,X187Relocation>, +index: KDef, +size: U32,
    +count: U32, +state: X188Fixups) -> X188Fixups:
  match items:
    case Nil{{}}: state
    case Con{{head,rest}}:
      nt_choose(X188Fixups,U32.is_lt(count,1048576),
        u => s10f_fixup_scan(rest,index,size,U32.inc(count),s10f_fixup_item(head,index,size,state)),
        u => x188_fixup_error("invalid ELF relocation",state))

law s10f_build_syms_part:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +is_mod: Bool
  for +locs: List<&2,X187Symbol>
  for +glbs: List<&2,X187Symbol>
  S10fSymPart

@unsafe
def s10f_build_sym_checked(+symbol: X187Symbol, +rest: List<&2,String>, +index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +is_mod: Bool, +locs: List<&2,X187Symbol>, +glbs: List<&2,X187Symbol>) -> S10fSymPart:
  match symbol:
    case X187Symbol{{+name,+section,+value,+size,+global,+kind}}:
      nt_choose(S10fSymPart,w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes),
        u => nt_choose(S10fSymPart,global,
          v => s10f_build_syms_part(rest,index,escaped,sizes,is_mod,locs,Con{{symbol,glbs}}),
          v => nt_choose(S10fSymPart,s10f_starts_dot(name) && String.starts_with(name,".L") &&
                agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),
            w => s10f_build_syms_part(rest,index,escaped,sizes,is_mod,locs,glbs),
            w => s10f_build_syms_part(rest,index,escaped,sizes,is_mod,Con{{symbol,locs}},glbs))),
        u => S10fSymPart{{[],[],"invalid or duplicate ELF symbol"}})

@unsafe
def s10f_build_sym_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +is_mod: Bool, +locs: List<&2,X187Symbol>, +glbs: List<&2,X187Symbol>,
    +symbol: KDef) -> S10fSymPart:
  match symbol:
    case KDef{{n,k,section,value,KTerm{{tk,tn,size,kind,kids,removed,begin,end}},v,c,+global,+defined}}:
      nt_choose(S10fSymPart,Bool.not(defined) && s10f_starts_dot(name) && String.starts_with(name,".L"),
        u => S10fSymPart{{[],[],"undefined local label: " ++ name}},
        u =>
          +sym_global : Bool = nt_choose(Bool,is_mod && defined && w10_is_mod_local_sym(name),
            v => False{{}},
            v => global || Bool.not(defined))
          s10f_build_sym_checked(X187Symbol{{name,section,value,size,sym_global,kind}},
            rest,index,escaped,sizes,is_mod,locs,glbs))
    case _: S10fSymPart{{[],[],"invalid final object symbol"}}

@unsafe
def s10f_build_syms_part(names, index, escaped, sizes, is_mod, locs, glbs):
  match names:
    case Nil{{}}: S10fSymPart{{locs,glbs,""}}
    case Con{{+name,rest}}:
      s10f_build_sym_final(name,rest,index,escaped,sizes,is_mod,locs,glbs,p111v_get(index,name))

@unsafe
def s10f_elf_sym_add_ascii(+name: String, +section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32,
    +is_mod: Bool, +weak_set: KDef, +index: KDef, +count: U32, +firstGlobal: U32, +table: List<&2,U32>,
    +strings: List<&2,U32>, +stringSize: U32, +error: String, asc: W7cAscii) -> X187ElfSymbols:
  match asc:
    case W7cAscii{{ok,+strBytes,+nlen}}:
      +length = U32.inc(nlen)
      +h = index_hash(name,2166136261)
      +bind : U32 = nt_choose(U32,global,
        u => nt_choose(U32,is_mod && Bool.not(U32.is_eq(section,0)) && agy_str_eq(dk(w5c3_find(weak_set,name,h)),"W10Weak"),
          v => 32,
          v => 16),
        u => 0)
      nt_choose(X187ElfSymbols,ok && String.is_empty(error) &&
          agy_str_eq(dk(w5c3_find(index,name,h)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{{p111v_put_h(index,name,h,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          s10f_elf_sym_push(stringSize,U32.add(kind,bind),section,value,size,table),
          Con{{0,strBytes}},U32.add(stringSize,length),""}},
        u => X187ElfSymbols{{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")}})

@unsafe
def s10f_elf_syms_list(items: List<&2,X187Symbol>, +is_mod: Bool, +weak_set: KDef,
    +state: X187ElfSymbols) -> X187ElfSymbols:
  match items state:
    case Nil{{}} _: state
    case Con{{X187Symbol{{+name,+section,+value,+size,+global,+kind}},rest}}
         X187ElfSymbols{{+index,+count,+firstGlobal,table,+strings,+stringSize,+error}}:
      s10f_elf_syms_list(rest,is_mod,weak_set,
        s10f_elf_sym_add_ascii(name,section,value,size,global,kind,is_mod,weak_set,
          index,count,firstGlobal,table,strings,stringSize,error,s10f_ascii_valid(name,strings,0)))

@unsafe
def s10f_elf_syms_glbs(s1: X187ElfSymbols, glbs: List<&2,X187Symbol>,
    +is_mod: Bool, +weak_set: KDef) -> X187ElfSymbols:
  match s1:
    case X187ElfSymbols{{index,+count,fg,table,strings,stringSize,error}}:
      s10f_elf_syms_list(glbs,is_mod,weak_set,X187ElfSymbols{{index,count,count,table,strings,stringSize,error}})

@unsafe
def s10f_elf_syms_both(locs: List<&2,X187Symbol>, glbs: List<&2,X187Symbol>,
    +is_mod: Bool, +weak_set: KDef) -> X187ElfSymbols:
  s10f_elf_syms_glbs(
    s10f_elf_syms_list(locs,is_mod,weak_set,X187ElfSymbols{{missing(),1,1,x187_elf_zero(24,[]),[0],1,""}}),
    glbs,is_mod,weak_set)

@unsafe
def s10f_sym_idx_or0(+index: KDef, +name: String) -> U32:
  +found = p111v_get(index,name)
  nt_choose(U32,agy_str_eq(dk(found),"X187Symbol"),u => da(found),u => 0)

@unsafe
def s10f_make_hot_idx(+index: KDef) -> S10fHotIdx:
  S10fHotIdx{{
    s10f_sym_idx_or0(index,"p111_program"),
    s10f_sym_idx_or0(index,"p125_rt_ctor2"),
    s10f_sym_idx_or0(index,"p111_rt_sink"),
    s10f_sym_idx_or0(index,"p111_rt_jump"),
    s10f_sym_idx_or0(index,"p111_rt_keep"),
    s10f_sym_idx_or0(index,"p111_rt_return"),
    s10f_sym_idx_or0(index,"p111_rt_fail"),
    s10f_sym_idx_or0(index,"p111_rt_closure")}}

@unsafe
def s10f_hot_lookup(+sym: String, hot: S10fHotIdx) -> U32:
  match hot:
    case S10fHotIdx{{i0,i1,i2,i3,i4,i5,i6,i7}}:
      nt_choose(U32,agy_str_eq(sym,"p111_program"),u => i0,u =>
      nt_choose(U32,agy_str_eq(sym,"p125_rt_ctor2"),v => i1,v =>
      nt_choose(U32,agy_str_eq(sym,"p111_rt_sink"),w => i2,w =>
      nt_choose(U32,agy_str_eq(sym,"p111_rt_jump"),x => i3,x =>
      nt_choose(U32,agy_str_eq(sym,"p111_rt_keep"),y => i4,y =>
      nt_choose(U32,agy_str_eq(sym,"p111_rt_return"),z => i5,z =>
      nt_choose(U32,agy_str_eq(sym,"p111_rt_fail"),a => i6,a =>
      nt_choose(U32,agy_str_eq(sym,"p111_rt_closure"),b => i7,b => 0))))))))

law s10f_relocs_fused:
  for items: List<&2,X187Relocation>
  for +sizes: X187ElfSizes
  for +index: KDef
  for +hot: S10fHotIdx
  for +count: U32
  for +r1: List<&2,U32>
  for +n1: U32
  for +r2: List<&2,U32>
  for +n2: U32
  for +r3: List<&2,U32>
  for +n3: U32
  W7cRelocResult

@unsafe
def s10f_reloc_push(sec: U32, +offset: U32, +kind: U32, +symIdx: U32, +lo: U32, +hi: U32,
    rest: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +hot: S10fHotIdx, +count: U32,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7cRelocResult:
  match sec:
    case 1: s10f_relocs_fused(rest,sizes,index,hot,U32.inc(count),s10f_reloc_enc(offset,kind,symIdx,lo,hi,r1),U32.add(n1,24),r2,n2,r3,n3)
    case 2: s10f_relocs_fused(rest,sizes,index,hot,U32.inc(count),r1,n1,s10f_reloc_enc(offset,kind,symIdx,lo,hi,r2),U32.add(n2,24),r3,n3)
    case _: s10f_relocs_fused(rest,sizes,index,hot,U32.inc(count),r1,n1,r2,n2,s10f_reloc_enc(offset,kind,symIdx,lo,hi,r3),U32.add(n3,24))

@unsafe
def s10f_reloc_add(+sec: U32, +offset: U32, +kind: U32, +symIdx: U32, +lo: U32, +hi: U32,
    rest: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +hot: S10fHotIdx, +count: U32,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7cRelocResult:
  +limit = x187_elf_section_size(sec,sizes)
  +width = nt_choose(U32,U32.is_eq(kind,1),u => 8,u => 4)
  nt_choose(W7cRelocResult,U32.is_gt(symIdx,0) && U32.is_lt(count,1048576) && U32.is_ge(sec,1) && U32.is_le(sec,3) &&
      (U32.is_eq(kind,1) || U32.is_eq(kind,2) || U32.is_eq(kind,4)) &&
      U32.is_le(offset,limit) && U32.is_le(width,U32.sub(limit,offset)),
    u => s10f_reloc_push(sec,offset,kind,symIdx,lo,hi,rest,sizes,index,hot,count,r1,n1,r2,n2,r3,n3),
    u => W7cRelocBad{{}})

@unsafe
def s10f_relocs_fused(items, sizes, index, hot, count, r1, n1, r2, n2, r3, n3):
  match items:
    case Nil{{}}: W7cRelocOk{{W7RelocParts{{r1,n1,r2,n2,r3,n3}}}}
    case Con{{X187Relocation{{sec,offset,kind,+symbol,lo,hi}},rest}}:
      +hi0 = s10f_hot_lookup(symbol,hot)
      +sidx : U32 = nt_choose(U32,U32.is_gt(hi0,0),u => hi0,u => s10f_sym_idx_or0(index,symbol))
      s10f_reloc_add(sec,offset,kind,sidx,lo,hi,rest,sizes,index,hot,count,r1,n1,r2,n2,r3,n3)

@unsafe
def s10f_elf_emit_io(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rr: W7cRelocResult) -> IO(U32):
  match rr:
    case W7cRelocBad{{}}: IO.die(U32,1,"invalid ELF relocation")
    case W7cRelocOk{{W7RelocParts{{r1,+n1,r2,+n2,r3,+n3}}}}:
      +sectionNames = s10f_rev8(x187_elf_ascii(
          "\\0.text\\0.rodata\\0.data\\0.rela.text\\0.rela.rodata\\0.rela.data\\0.symtab\\0.strtab\\0.shstrtab\\0.note.GNU-stack\\0",[]),[])
      x202t_plan([
        X187ElfSection{{1,1,6,16,0,0,0,text}},
        X187ElfSection{{7,1,2,8,0,0,0,rodata}},
        X187ElfSection{{15,1,3,8,0,0,0,data}},
        X187ElfSection{{21,4,0,8,24,7,1,s10f_rev8(r1,[])}},
        X187ElfSection{{32,4,0,8,24,7,2,s10f_rev8(r2,[])}},
        X187ElfSection{{45,4,0,8,24,7,3,s10f_rev8(r3,[])}},
        X187ElfSection{{56,2,0,8,24,8,firstGlobal,s10f_rev8(table,[])}},
        X187ElfSection{{64,3,0,1,0,0,0,s10f_rev8(strings,[])}},
        X187ElfSection{{72,3,0,1,0,0,0,sectionNames}},
        X187ElfSection{{82,1,0,1,0,0,0,[]}}],
        x202t_sizes(X187ElfSizes{{ts,rs,ds}},X187ElfSizes{{n1,n2,n3}},count,stringSize,98),64,[],x187_elf_zero(64,[]))

@unsafe
def s10f_elf_checked_io(+text: List<&2,U32>, +rodata: List<&2,U32>, +data: List<&2,U32>,
    +relocations: List<&2,X187Relocation>, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> IO(U32):
  match sizes symbols:
    case X187ElfSizes{{+ts,+rs,+ds}}
         X187ElfSymbols{{+index,+count,+firstGlobal,table,strings,+stringSize,+error}}:
      nt_choose(IO(U32),String.is_empty(error),
        u => s10f_elf_emit_io(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          s10f_relocs_fused(relocations,sizes,index,s10f_make_hot_idx(index),0,[],0,[],0,[],0)),
        u => IO.die(U32,1,error))

@unsafe
def s10f_elf_after_syms(text: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    relocations: List<&2,X187Relocation>, +sizes: X187ElfSizes, +is_mod: Bool, +weak_set: KDef,
    sp: S10fSymPart) -> IO(U32):
  match sp:
    case S10fSymPart{{locs,glbs,+err}}:
      nt_choose(IO(U32),String.is_empty(err),
        u => s10f_elf_checked_io(text,rodata,data,relocations,sizes,s10f_elf_syms_both(locs,glbs,is_mod,weak_set)),
        u => IO.die(U32,1,err))

@unsafe
def s10f_elf_after_patch(names: List<&2,String>, index: KDef, escaped: KDef, +sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>,
    patched: X187Encoded, +is_mod: Bool, +weak_set: KDef) -> IO(U32):
  match patched:
    case X187Encoded{{bytes,_,+error}}:
      nt_choose(IO(U32),String.is_empty(error),
        u => s10f_elf_after_syms(bytes,rodata,data,relocations,sizes,is_mod,weak_set,
          s10f_build_syms_part(names,index,escaped,sizes,is_mod,[],[])),
        u => IO.die(U32,1,error))

@unsafe
def s10f_elf_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>,
    state: X188Fixups, +is_mod: Bool, +weak_set: KDef) -> IO(U32):
  match sizes state:
    case X187ElfSizes{{+ts,rs,ds}} X188Fixups{{+patches,relocations,escaped,+error}}:
      nt_choose(IO(U32),String.is_empty(error),
        u => s10f_elf_after_patch(names,index,escaped,sizes,rodata,data,relocations,
          s10f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[])),is_mod,weak_set),
        u => IO.die(U32,1,error))

@unsafe
def s10f_elf_finish_io(+build: X187Build, +is_mod: Bool, +weak_set: KDef) -> IO(U32):
  match build:
    case X187Build{{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}}:
      nt_choose(IO(U32),String.is_empty(error),
        u => s10f_elf_fixups(names,symbols,X187ElfSizes{{ts,rs,ds}},t,s10f_rev8(r,[]),s10f_rev8(d,[]),
          s10f_fixup_scan(relocs,symbols,ts,0,X188Fixups{{[],[],missing(),""}}),is_mod,weak_set),
        u => IO.die(U32,1,error))

# ============================================================================
# Part 2: Ultra-Fast Unboxed Direct-to-Bytes Public Segment Emitter (x187_pub)
# ============================================================================

type S10fT is Data:
  S10fT{{+t: List<&2,U32>, +ts: U32}}

type S10fPubCtx is Data:
  S10fPubCtx{{+f_st: X181Frame, +f_no: X181Frame, +seen: U32}}

type S10fPubRes is Data:
  S10fPubRes{{+build: X187Build, +seen: U32}}

type S10fRelOut is Data:
  S10fRelOut{{+relocs: List<&2,X187Relocation>, +symbols: KDef, +names: List<&2,String>, +seen: U32}}

type S10fFnSt is Data:
  S10fFnSt{{+t: List<&2,U32>, +ts: U32, +relocs: List<&2,X187Relocation>,
    +symbols: KDef, +names: List<&2,String>, +seen: U32,
    +lsyms: KDef, +lrelocs: List<&2,X187Relocation>, +next: U32, +term: Bool, +err: String}}

type S10fOpenRes is Data:
  S10fOpenRes{{+symbols: KDef, +names: List<&2,String>, +hash: U32, +err: String}}


@unsafe
def s10f_make_base_frame(+uses_state: Bool) -> X181Frame:
  +stateKind = nt_choose(String,uses_state,u => "X181Register",u => "X181UnusedState")
  +savedMask = nt_choose(U32,uses_state,u => 1,u => 0)
  +s0 = p111v_put(p111v_put(missing(),"state",stateKind,0,8),"__x181_saved_mask","X186SavedMask",savedMask,0)
  +init : X181Frame = X181Frame{{s0,40,0,["state"],""}}
  +f1 = x181_frame_buffer("scratch",2048,16,init)
  +f2 = x181_frame_buffer("__x181_results",64,16,f1)
  x181_frame_buffer("__x181_tail",8,8,f2)

@unsafe
def s10f_init_pub_ctx() -> S10fPubCtx:
  S10fPubCtx{{s10f_make_base_frame(True{{}}),s10f_make_base_frame(False{{}}),0}}

@unsafe
def s10f_hot_bit(+sym: String) -> U32:
  nt_choose(U32,agy_str_eq(sym,"p111_program"),u => 1,u =>
  nt_choose(U32,agy_str_eq(sym,"p125_rt_ctor2"),v => 2,v =>
  nt_choose(U32,agy_str_eq(sym,"p111_rt_sink"),w => 4,w =>
  nt_choose(U32,agy_str_eq(sym,"p111_rt_jump"),x => 8,x =>
  nt_choose(U32,agy_str_eq(sym,"p111_rt_keep"),y => 16,y =>
  nt_choose(U32,agy_str_eq(sym,"p111_rt_return"),z => 32,z =>
  nt_choose(U32,agy_str_eq(sym,"p111_rt_fail"),a => 64,a =>
  nt_choose(U32,agy_str_eq(sym,"p111_rt_closure"),b => 128,b => 0))))))))

@unsafe
def s10f_reg_name_h(+name: String, +bit: U32, +symbols: KDef, +names: List<&2,String>, +seen: U32,
    +relocs: List<&2,X187Relocation>, +reloc: X187Relocation) -> S10fRelOut:
  nt_choose(S10fRelOut,U32.is_gt(U32.and(seen,bit),0),
    u => S10fRelOut{{Con{{reloc,relocs}},symbols,names,seen}},
    u =>
      +h = index_hash(name,2166136261)
      +seen2 = U32.or(seen,bit)
      nt_choose(S10fRelOut,agy_str_eq(dk(w5c3_find(symbols,name,h)),"Absent"),
        v => S10fRelOut{{Con{{reloc,relocs}},
          index_set(symbols,KDef{{name,"X187Sym",0,0,KTerm{{"","",0,0,[],[],0,0}},atom("Absent"),[],False{{}},False{{}}}},h,32),
          Con{{name,names}},seen2}},
        v => S10fRelOut{{Con{{reloc,relocs}},symbols,names,seen2}}))

@unsafe
def s10f_add_reloc(+reloc: X187Relocation, +relocs: List<&2,X187Relocation>,
    +symbols: KDef, +names: List<&2,String>, +seen: U32) -> S10fRelOut:
  match reloc:
    case X187Relocation{{s,o,k,+name,lo,hi}}:
      s10f_reg_name_h(name,s10f_hot_bit(name),symbols,names,seen,relocs,reloc)

@unsafe
def s10f_func_open_old(+sym: String, +start_ts: U32, +h: U32, +symbols: KDef, +names: List<&2,String>, old: KDef) -> S10fOpenRes:
  match old:
    case KDef{{_,_,_,_,_,_,_,_,+defined}}:
      nt_choose(S10fOpenRes,defined,
        v => S10fOpenRes{{symbols,names,h,"duplicate symbol or invalid size: " ++ sym}},
        v => S10fOpenRes{{
          index_set(symbols,KDef{{sym,"X187Sym",1,start_ts,KTerm{{"","",0,2,[],[],0,0}},atom("Absent"),[],True{{}},True{{}}}},h,32),
          names,h,""}})
    case _: S10fOpenRes{{symbols,names,h,"invalid object symbol record"}}

@unsafe
def s10f_func_open(+sym: String, +start_ts: U32, +symbols: KDef, +names: List<&2,String>) -> S10fOpenRes:
  +h = index_hash(sym,2166136261)
  +old = index_find(symbols,sym,h,32)
  nt_choose(S10fOpenRes,agy_str_eq(dk(old),"Absent"),
    u => S10fOpenRes{{
      index_set(symbols,KDef{{sym,"X187Sym",1,start_ts,KTerm{{"","",0,2,[],[],0,0}},atom("Absent"),[],True{{}},True{{}}}},h,32),
      Con{{sym,names}},h,""}},
    u => s10f_func_open_old(sym,start_ts,h,symbols,names,old))

@unsafe
def s10f_func_close(+sym: String, +h: U32, +start_ts: U32, +end_ts: U32, +symbols: KDef) -> KDef:
  index_set(symbols,
    KDef{{sym,"X187Sym",1,start_ts,KTerm{{"","",U32.sub(end_ts,start_ts),2,[],[],0,0}},atom("Absent"),[],True{{}},True{{}}}},
    h,32)

# --- Pure-byte S10fT instruction emitters (zero 11-field X187Build allocation!) ---

@unsafe
def s10f_t_mem_mode(mode: U32, +disp: U32, t1: List<&2,U32>, +ts: U32, +n1: U32) -> S10fT:
  match mode:
    case 0: S10fT{{t1,U32.add(ts,n1)}}
    case 1: S10fT{{Con{{U32.and(disp,255),t1}},U32.add(ts,U32.inc(n1))}}
    case _: S10fT{{s10f_u32_rev(disp,t1),U32.add(ts,U32.add(n1,4))}}

@unsafe
def s10f_t_push_mem(+rex: U32, +opcode: U32, +reg: U32, +base: U32, +disp: U32,
    +t: List<&2,U32>, +ts: U32) -> S10fT:
  +low = U32.and(base,7)
  +rlow = U32.mul(U32.and(reg,7),8)
  +zero = U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5))
  +short = U32.is_le(disp,127) || U32.is_ge(disp,4294967168)
  +mode = nt_choose(U32,zero,u => 0,u => nt_choose(U32,short,v => 1,v => 2))
  +modrm = U32.add(U32.mul(mode,64),U32.add(rlow,low))
  +t0 : List<&2,U32> = Con{{modrm,Con{{opcode,Con{{rex,t}}}}}}
  +t1 = nt_choose(List<&2,U32>,U32.is_eq(low,4),u => Con{{36,t0}},u => t0)
  +n1 = nt_choose(U32,U32.is_eq(low,4),u => 4,u => 3)
  s10f_t_mem_mode(mode,disp,t1,ts,n1)

@unsafe
def s10f_t_push_mem32(+rex: U32, +opcode: U32, +reg: U32, +base: U32, +disp: U32,
    +t: List<&2,U32>, +ts: U32) -> S10fT:
  +low = U32.and(base,7)
  +rlow = U32.mul(U32.and(reg,7),8)
  +zero = U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5))
  +short = U32.is_le(disp,127) || U32.is_ge(disp,4294967168)
  +mode = nt_choose(U32,zero,u => 0,u => nt_choose(U32,short,v => 1,v => 2))
  +modrm = U32.add(U32.mul(mode,64),U32.add(rlow,low))
  +has_rex = U32.is_gt(rex,64)
  +t_pre : List<&2,U32> = nt_choose(List<&2,U32>,has_rex,u => Con{{rex,t}},u => t)
  +n_pre : U32 = nt_choose(U32,has_rex,u => 3,u => 2)
  +t0 : List<&2,U32> = Con{{modrm,Con{{opcode,t_pre}}}}
  +t1 = nt_choose(List<&2,U32>,U32.is_eq(low,4),u => Con{{36,t0}},u => t0)
  +n1 = nt_choose(U32,U32.is_eq(low,4),u => U32.inc(n_pre),u => n_pre)
  s10f_t_mem_mode(mode,disp,t1,ts,n1)

@unsafe
def s10f_t_movq_rr(+s: U32, +dd: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  S10fT{{Con{{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
    Con{{137,Con{{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}}}}},U32.add(ts,3)}}

@unsafe
def s10f_t_movl_rr(+s: U32, +dd: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +rex = U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n)))
  +modrm = U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7)))
  nt_choose(S10fT,U32.is_gt(rex,64),
    v => S10fT{{Con{{modrm,Con{{137,Con{{rex,t}}}}}},U32.add(ts,3)}},
    v => S10fT{{Con{{modrm,Con{{137,t}}}},U32.add(ts,2)}})

@unsafe
def s10f_t_movq_mr(+b: U32, +disp: U32, +dd: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  s10f_t_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,t,ts)

@unsafe
def s10f_t_movq_rm(+s: U32, +b: U32, +disp: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  s10f_t_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,t,ts)

@unsafe
def s10f_t_movl_mr(+b: U32, +disp: U32, +dd: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  s10f_t_push_mem32(U32.add(64,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,t,ts)

@unsafe
def s10f_t_movl_rm(+s: U32, +b: U32, +disp: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  s10f_t_push_mem32(U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,t,ts)

@unsafe
def s10f_t_leaq_mr(+b: U32, +disp: U32, +dd: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  s10f_t_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),141,dd,b,disp,t,ts)

@unsafe
def s10f_t_movabsq(+lo: U32, +hi: U32, +dd: U32, t: List<&2,U32>, +ts: U32) -> S10fT:
  S10fT{{s10f_u32_rev(hi,s10f_u32_rev(lo,Con{{U32.add(184,U32.and(dd,7)),Con{{U32.add(72,U32.shrn(dd,3n)),t}}}})),U32.add(ts,10)}}

@unsafe
def s10f_t_epilogue(+uses_state: Bool, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 : List<&2,U32> = nt_choose(List<&2,U32>,uses_state,v => Con{{240,Con{{101,Con{{139,Con{{76,t}}}}}}}},v => t)
  +n0 : U32 = nt_choose(U32,uses_state,v => 9,v => 5)
  S10fT{{Con{{195,Con{{93,Con{{236,Con{{137,Con{{72,t0}}}}}}}}}},U32.add(ts,n0)}}

@unsafe
def s10f_t_cmp_imm(+w64: Bool, +lo: U32, +cc: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 : List<&2,U32> = nt_choose(List<&2,U32>,w64,u => Con{{73,t}},u => Con{{65,t}})
  +t1 : List<&2,U32> = s10f_u32_rev(lo,Con{{250,Con{{129,t0}}}})
  S10fT{{Con{{210,Con{{182,Con{{15,Con{{69,Con{{194,Con{{cc,Con{{15,Con{{65,t1}}}}}}}}}}}}}}}},U32.add(ts,15)}}

@unsafe
def s10f_t_cmp_rr(+w64: Bool, +cc: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 : List<&2,U32> = nt_choose(List<&2,U32>,w64,u => Con{{77,t}},u => Con{{69,t}})
  S10fT{{Con{{210,Con{{182,Con{{15,Con{{69,Con{{194,Con{{cc,Con{{15,Con{{65,Con{{218,Con{{57,t0}}}}}}}}}}}}}}}}}}}},U32.add(ts,11)}}

@unsafe
def s10f_t_alu_imm(+w64: Bool, +ext: U32, +lo: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 : List<&2,U32> = nt_choose(List<&2,U32>,w64,u => Con{{73,t}},u => Con{{65,t}})
  S10fT{{s10f_u32_rev(lo,Con{{U32.add(194,U32.mul(ext,8)),Con{{129,t0}}}}),U32.add(ts,7)}}

@unsafe
def s10f_t_alu_rr(+w64: Bool, +ext: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 : List<&2,U32> = nt_choose(List<&2,U32>,w64,u => Con{{77,t}},u => Con{{69,t}})
  S10fT{{Con{{218,Con{{U32.inc(U32.mul(ext,8)),t0}}}},U32.add(ts,3)}}

@unsafe
def s10f_t_shift_imm(+w64: Bool, +ext: U32, +sh: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 : List<&2,U32> = nt_choose(List<&2,U32>,w64,u => Con{{73,t}},u => Con{{65,t}})
  S10fT{{Con{{sh,Con{{U32.add(194,U32.mul(ext,8)),Con{{193,t0}}}}}},U32.add(ts,4)}}

@unsafe
def s10f_t_shift_cl(+w64: Bool, +ext: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +rex = nt_choose(U32,w64,u => 73,u => 65)
  +modrm = U32.add(194,U32.mul(ext,8))
  S10fT{{Con{{modrm,Con{{211,Con{{rex,Con{{217,Con{{137,Con{{76,t}}}}}}}}}}}},U32.add(ts,6)}}

@unsafe
def s10f_set_t(res: S10fT, st: S10fFnSt) -> S10fFnSt:
  match res st:
    case S10fT{{t2,ts2}} S10fFnSt{{_,_,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      S10fFnSt{{t2,ts2,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}

@unsafe
def s10f_apply_t(res: S10fT, st: S10fFnSt, +msg: String) -> S10fFnSt:
  match res st:
    case S10fT{{+t2,+ts2}} S10fFnSt{{_,_,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+term,+err}}:
      nt_choose(S10fFnSt,U32.is_ge(ts2,4294967294),
        u => S10fFnSt{{t2,0,relocs,symbols,names,seen,lsyms,lrelocs,next,term,p111_first(err,msg)}},
        u => S10fFnSt{{t2,ts2,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_load_slot_t(+slot: KDef, +dd: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +k = dk(slot)
  nt_choose(S10fT,agy_str_eq(k,"X181Stack"),
    u => s10f_t_movq_mr(5,U32.sub(0,da(slot)),dd,t,ts),u =>
  nt_choose(S10fT,agy_str_eq(k,"X181Buffer"),
    u => s10f_t_leaq_mr(5,U32.sub(0,da(slot)),dd,t,ts),u =>
  nt_choose(S10fT,agy_str_eq(k,"X181Register"),
    u => s10f_t_movq_rr(w13c_reg_num(da(slot)),dd,t,ts),
    u => S10fT{{t,4294967295}})))

@unsafe
def s10f_store_slot_t(+slot: KDef, +s: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +k = dk(slot)
  nt_choose(S10fT,agy_str_eq(k,"X181Stack"),
    u => s10f_t_movq_rm(s,5,U32.sub(0,da(slot)),t,ts),u =>
  nt_choose(S10fT,agy_str_eq(k,"X181UnusedState"),
    u => S10fT{{t,ts}},u =>
  nt_choose(S10fT,agy_str_eq(k,"X181Register"),
    u => s10f_t_movq_rr(s,w13c_reg_num(da(slot)),t,ts),
    u => S10fT{{t,4294967295}})))

@unsafe
def s10f_load_id_t(tree: KDef, +name: String, +dd: U32, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +found = index_find(tree,name,index_hash(name,2166136261),32)
  nt_choose(S10fT,agy_str_eq(dk(found),"N111Id"),
    u => s10f_t_movabsq(da(found),0,dd,t,ts),
    u => S10fT{{t,4294967294}})

@unsafe
def s10f_load_sym_apply(ro: S10fRelOut, t: List<&2,U32>, +ts: U32, +dd: U32,
    lsyms: KDef, lrelocs: List<&2,X187Relocation>, +next: U32, +term: Bool, err: String) -> S10fFnSt:
  match ro:
    case S10fRelOut{{rel2,sym2,nam2,seen2}}:
      +t2 : List<&2,U32> = Con{{0,Con{{0,Con{{0,Con{{0,Con{{U32.add(5,U32.mul(U32.and(dd,7),8)),
        Con{{141,Con{{U32.add(72,U32.mul(U32.shrn(dd,3n),4)),t}}}}}}}}}}}}}}
      S10fFnSt{{t2,U32.add(ts,7),rel2,sym2,nam2,seen2,lsyms,lrelocs,next,term,err}}

@unsafe
def s10f_load_val(value: N111Value, ids: N111Ids, frame: X181Frame, +dd: U32, +st: S10fFnSt) -> S10fFnSt:
  match value ids frame st:
    case N111Local{{name}} _ X181Frame{{slots,_,_,_,_}} S10fFnSt{{+t,+ts,_,_,_,_,_,_,_,_,_}}:
      s10f_apply_t(s10f_load_slot_t(index_find(slots,name,index_hash(name,2166136261),32),dd,t,ts),st,"x181: missing local slot")
    case N111Const{{lo,hi}} _ _ S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_movabsq(lo,hi,dd,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})
    case N111Symbol{{+name}} _ _ S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+term,+err}}:
      nt_choose(S10fFnSt,Bool.not(String.is_empty(name)),
        u => s10f_load_sym_apply(
          s10f_add_reloc(X187Relocation{{1,U32.add(ts,3),2,name,4294967292,4294967295}},relocs,symbols,names,seen),
          t,ts,dd,lsyms,lrelocs,next,term,err),
        u => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,p111_first(err,"x86 invalid rip load")}})
    case N111FuncId{{name}} N111Ids{{functions,_}} _ S10fFnSt{{+t,+ts,_,_,_,_,_,_,_,_,_}}:
      s10f_apply_t(s10f_load_id_t(functions,name,dd,t,ts),st,"x181: missing native ID")
    case N111CtorId{{name}} N111Ids{{_,constructors}} _ S10fFnSt{{+t,+ts,_,_,_,_,_,_,_,_,_}}:
      s10f_apply_t(s10f_load_id_t(constructors,name,dd,t,ts),st,"x181: missing native ID")

@unsafe
def s10f_store_reg(+name: String, frame: X181Frame, +s: U32, +st: S10fFnSt) -> S10fFnSt:
  match frame st:
    case X181Frame{{slots,_,_,_,_}} S10fFnSt{{+t,+ts,_,_,_,_,_,_,_,_,_}}:
      s10f_apply_t(s10f_store_slot_t(index_find(slots,name,index_hash(name,2166136261),32),s,t,ts),st,"x181: invalid destination slot")

@unsafe
def s10f_st_movl_rr(+s: U32, +dd: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_movl_rr(s,dd,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_cmp_imm(+w64: Bool, +lo: U32, +cc: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_cmp_imm(w64,lo,cc,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_alu_imm(+w64: Bool, +ext: U32, +lo: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_alu_imm(w64,ext,lo,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_shift_imm(+w64: Bool, +ext: U32, +sh: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_shift_imm(w64,ext,sh,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_bin_rr(+w64: Bool, +cc: U32, +ak: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      +rt = nt_choose(S10fT,U32.is_gt(cc,0),
        x => s10f_t_cmp_rr(w64,cc,t,ts),
        x => nt_choose(S10fT,U32.is_ge(ak,20),
          y => s10f_t_shift_cl(w64,U32.sub(ak,20),t,ts),
          y => s10f_t_alu_rr(w64,U32.sub(ak,10),t,ts)))
      s10f_set_t(rt,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_emit_bin_rc(rc: N111Value, +w64: Bool, +cc: U32, +ak: U32, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +st: S10fFnSt) -> S10fFnSt:
  match rc:
    case N111Const{{+lo,+hi}}:
      nt_choose(S10fFnSt,U32.is_ge(ak,20),
        u => s10f_st_shift_imm(w64,U32.sub(ak,20),U32.mod(lo,nt_choose(U32,w64,v => 64,v => 32)),st),
      u => nt_choose(S10fFnSt,U32.is_eq(ak,14) && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        v => s10f_st_movl_rr(10,10,st),
      v => nt_choose(S10fFnSt,U32.is_eq(hi,0) && (Bool.not(w64) || U32.is_le(lo,2147483647)),
        w => nt_choose(S10fFnSt,U32.is_gt(cc,0),
          z => s10f_st_cmp_imm(w64,lo,cc,st),
          z => s10f_st_alu_imm(w64,U32.sub(ak,10),lo,st)),
        w => s10f_st_bin_rr(w64,cc,ak,s10f_load_val(right,ids,frame,11,st)))))
    case _: s10f_st_bin_rr(w64,cc,ak,s10f_load_val(right,ids,frame,11,st))

@unsafe
def s10f_emit_bin_op(+w64: Bool, +cc: U32, +ak: U32, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +st: S10fFnSt) -> S10fFnSt:
  s10f_emit_bin_rc(x185_id_to_const(right,ids),w64,cc,ak,right,ids,frame,st)

@unsafe
def s10f_st_movq_rm(+s: U32, +b: U32, +disp: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_movq_rm(s,b,disp,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_stack_arg(+is32: Bool, +off: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+term,+err}}:
      +st1 = nt_choose(S10fFnSt,is32,v => s10f_set_t(s10f_t_movl_rr(10,10,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}),v => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})
      s10f_st_movq_rm(10,4,off,st1)

@unsafe
def s10f_call_args(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32, +st: S10fFnSt) -> S10fFnSt:
  match args:
    case Nil{{}}: st
    case Con{{N111Arg{{+typ,+val}},+rest}}:
      +is32 = U32.is_eq(p111v_type(typ),1)
      nt_choose(S10fFnSt,U32.is_lt(index,6),
        u =>
          +rn = w13c_argreg_num(index)
          +st1 = s10f_load_val(val,ids,frame,rn,st)
          +st2 = nt_choose(S10fFnSt,is32,v => s10f_st_movl_rr(rn,rn,st1),v => st1)
          s10f_call_args(rest,ids,frame,U32.inc(index),st2),
        u =>
          +st1 = s10f_load_val(val,ids,frame,10,st)
          s10f_call_args(rest,ids,frame,U32.inc(index),s10f_st_stack_arg(is32,U32.mul(U32.sub(index,6),8),st1)))

@unsafe
def s10f_call_direct_apply(ro: S10fRelOut, +is32: Bool, +t: List<&2,U32>, +ts: U32,
    lsyms: KDef, lrelocs: List<&2,X187Relocation>, +next: U32, +term: Bool, err: String) -> S10fFnSt:
  match ro:
    case S10fRelOut{{rel2,sym2,nam2,seen2}}:
      +t1 : List<&2,U32> = Con{{0,Con{{0,Con{{0,Con{{0,Con{{232,Con{{192,Con{{49,t}}}}}}}}}}}}}}
      +ts1 = U32.add(ts,7)
      +rt = nt_choose(S10fT,is32,v => s10f_t_movl_rr(0,0,t1,ts1),v => S10fT{{t1,ts1}})
      s10f_set_t(rt,S10fFnSt{{t1,ts1,rel2,sym2,nam2,seen2,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_call_direct_emit(+typ: N111Type, +sym: String, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+term,+err}}:
      nt_choose(S10fFnSt,Bool.not(String.is_empty(sym)),
        u => s10f_call_direct_apply(
          s10f_add_reloc(X187Relocation{{1,U32.add(ts,3),4,sym,4294967292,4294967295}},relocs,symbols,names,seen),
          U32.is_eq(p111v_type(typ),1),t,ts,lsyms,lrelocs,next,term,err),
        u => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,p111_first(err,"x86 invalid call")}})

@unsafe
def s10f_emit_call_direct(+name: String, +typ: N111Type, +sym: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +st: S10fFnSt) -> S10fFnSt:
  s10f_store_reg(name,frame,0,s10f_call_direct_emit(typ,sym,s10f_call_args(args,ids,frame,0,st)))


@unsafe
def s10f_st_movabsq(+lo: U32, +hi: U32, +dd: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      s10f_set_t(s10f_t_movabsq(lo,hi,dd,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_emit_call_ctor0(+name: String, +typ: N111Type, +sym: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +st: S10fFnSt) -> S10fFnSt:
  match typ args:
    case N111U64{{}} Con{{N111Arg{{N111Ptr{{}},N111Local{{+state}}}},Con{{N111Arg{{N111U32{{}},N111CtorId{{+ctor}}}},Con{{N111Arg{{N111Ptr{{}},buf}},Con{{N111Arg{{N111U32{{}},N111Const{{0,0}}}},Nil{{}}}}}}}}}}:
      nt_choose(S10fFnSt,agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => s10f_store_reg(name,frame,0,s10f_st_movabsq(0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256)),0,st)),
        u => s10f_emit_call_direct(name,typ,sym,args,ids,frame,st))
    case _ _: s10f_emit_call_direct(name,typ,sym,args,ids,frame,st)

@unsafe
def s10f_apply_code_fb(fb: W10fFnBuild, +seen: U32, +next: U32, +term: Bool) -> S10fFnSt:
  match fb:
    case W10fFnBuild{{X187Build{{_,t2,_,_,ts2,_,_,sym2,nam2,rel2,err2}},ls2,lr2}}:
      S10fFnSt{{t2,ts2,rel2,sym2,nam2,seen,ls2,lr2,next,term,err2}}

@unsafe
def s10f_apply_code(code: X181Code, +st: S10fFnSt) -> S10fFnSt:
  match code st:
    case X181Code{{chunks,+next,+term,+cerr}} S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,_,_,+err}}:
      nt_choose(S10fFnSt,String.is_empty(cerr),
        u => s10f_apply_code_fb(
          w10f_fn_chunks(nt_reverse(X188Seq,chunks,[]),W10fFnBuild{{X187Build{{1,t,[],[],ts,0,0,symbols,names,relocs,err}},lsyms,lrelocs}}),
          seen,next,term),
        u => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,p111_first(err,cerr)}})

@unsafe
def s10f_emit_test_jz(+lbl: String, +st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      +t1 : List<&2,U32> = Con{{0,Con{{0,Con{{0,Con{{0,Con{{132,Con{{15,Con{{210,Con{{133,Con{{69,t}}}}}}}}}}}}}}}}}}
      S10fFnSt{{t1,U32.add(ts,9),relocs,symbols,names,seen,lsyms,
        Con{{X187Relocation{{1,U32.add(ts,5),130,lbl,4294967292,4294967295}},lrelocs}},next,term,err}}

@unsafe
def s10f_emit_jmp_lbl(+lbl: String, +st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      S10fFnSt{{Con{{0,Con{{0,Con{{0,Con{{0,Con{{233,t}}}}}}}}}},U32.add(ts,5),relocs,symbols,names,seen,lsyms,
        Con{{X187Relocation{{1,U32.inc(ts),130,lbl,4294967292,4294967295}},lrelocs}},next,term,err}}

@unsafe
def s10f_def_lbl(+lbl: String, +st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{t,+ts,relocs,symbols,names,seen,+lsyms,lrelocs,next,term,err}}:
      +h = index_hash(lbl,2166136261)
      S10fFnSt{{t,ts,relocs,symbols,names,seen,p111v_put_h(lsyms,lbl,h,"W10fL",ts,0),lrelocs,next,term,err}}

law s10f_emit_stmts:
  for body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +frame: X181Frame
  for +uses_state: Bool
  for +st: S10fFnSt
  S10fFnSt

law s10f_emit_scalars:
  for body: List<&2,N111Stmt>
  for +ids: N111Ids
  for +frame: X181Frame
  for +uses_state: Bool
  for +st: S10fFnSt
  S10fFnSt

@unsafe
def s10f_emit_if_no(+lbl_end: String, +yt: Bool, st_no: S10fFnSt) -> S10fFnSt:
  match st_no:
    case S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+nt,+err}}:
      nt_choose(S10fFnSt,yt && nt,
        u => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,True{{}},err}},
        u => s10f_def_lbl(lbl_end,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,False{{}},err}}))

@unsafe
def s10f_emit_if_yes(+lbl_else: String, +lbl_end: String, +no: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, st_yes: S10fFnSt) -> S10fFnSt:
  match st_yes:
    case S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+yt,+err}}:
      +st_mid = s10f_def_lbl(lbl_else,nt_choose(S10fFnSt,yt,
        u => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,False{{}},err}},
        u => s10f_emit_jmp_lbl(lbl_end,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,False{{}},err}})))
      s10f_emit_if_no(lbl_end,yt,s10f_emit_stmts(no,ids,frame,uses_state,st_mid))

@unsafe
def s10f_emit_if(+cond: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,+next,_,err}}:
      +lbl_else = w13c_lbl(next)
      +lbl_end = w13c_lbl(U32.inc(next))
      +st1 = s10f_load_val(cond,ids,frame,10,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,U32.add(next,2),False{{}},err}})
      +st2 = s10f_emit_test_jz(lbl_else,st1)
      s10f_emit_if_yes(lbl_else,lbl_end,no,ids,frame,uses_state,s10f_emit_stmts(yes,ids,frame,uses_state,st2))

@unsafe
def s10f_emit_if_s_yes(+lbl_else: String, +lbl_end: String, +no: List<&2,N111Stmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, st_yes: S10fFnSt) -> S10fFnSt:
  match st_yes:
    case S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,+next,+yt,+err}}:
      +st_mid = s10f_def_lbl(lbl_else,nt_choose(S10fFnSt,yt,
        u => S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,False{{}},err}},
        u => s10f_emit_jmp_lbl(lbl_end,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,False{{}},err}})))
      s10f_emit_if_no(lbl_end,yt,s10f_emit_scalars(no,ids,frame,uses_state,st_mid))

@unsafe
def s10f_emit_if_s(+cond: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,+next,_,err}}:
      +lbl_else = w13c_lbl(next)
      +lbl_end = w13c_lbl(U32.inc(next))
      +st1 = s10f_load_val(cond,ids,frame,10,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,U32.add(next,2),False{{}},err}})
      +st2 = s10f_emit_test_jz(lbl_else,st1)
      s10f_emit_if_s_yes(lbl_else,lbl_end,no,ids,frame,uses_state,s10f_emit_scalars(yes,ids,frame,uses_state,st2))

@unsafe
def s10f_st_load_mem(+is32: Bool, +offset: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      +rt = nt_choose(S10fT,is32,w => s10f_t_movl_mr(10,offset,10,t,ts),w => s10f_t_movq_mr(10,offset,10,t,ts))
      s10f_set_t(rt,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_store_mem(+is32: Bool, +offset: U32, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      +rt = nt_choose(S10fT,is32,w => s10f_t_movl_rm(11,10,offset,t,ts),w => s10f_t_movq_rm(11,10,offset,t,ts))
      s10f_set_t(rt,S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}})

@unsafe
def s10f_st_ret_epilogue(+uses_state: Bool, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{+t,+ts,relocs,symbols,names,seen,lsyms,lrelocs,next,_,err}}:
      s10f_set_t(s10f_t_epilogue(uses_state,t,ts),S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,True{{}},err}})

@unsafe
def s10f_st_err(+msg: String, st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,err}}:
      S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,term,p111_first(err,msg)}}

@unsafe
def s10f_emit_scalar_go(+stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool,
    +next: U32, +term: Bool, +st: S10fFnSt) -> S10fFnSt:
  match stmt:
    case N111Alloca{{_,_,_}}: st
    case N111Set{{+name,+typ,+value}}:
      nt_choose(S10fFnSt,agy_str_eq(name,"state"),
        v => s10f_apply_code(x181_add(x186_set_text(name,typ,value,ids,frame),X181Code{{[],next,term,""}}),st),
        v =>
          +st1 = s10f_load_val(value,ids,frame,10,st)
          +st2 = nt_choose(S10fFnSt,U32.is_eq(p111v_type(typ),1),w => s10f_st_movl_rr(10,10,st1),w => st1)
          s10f_store_reg(name,frame,10,st2))
    case N111Load{{+name,+typ,+base,+offset}}:
      nt_choose(S10fFnSt,U32.is_le(offset,2147483647) && Bool.not(agy_str_eq(name,"state")),
        v => s10f_store_reg(name,frame,10,s10f_st_load_mem(U32.is_eq(p111v_type(typ),1),offset,s10f_load_val(base,ids,frame,10,st))),
        v => s10f_apply_code(x181_add(x186_load_text(name,typ,base,offset,ids,frame),X181Code{{[],next,term,""}}),st))
    case N111Store{{+typ,+base,+offset,+value}}:
      nt_choose(S10fFnSt,U32.is_le(offset,2147483647) && Bool.not(w13c_is_state_val(base) && w13c_is_state_val(value)),
        v => s10f_st_store_mem(U32.is_eq(p111v_type(typ),1),offset,s10f_load_val(value,ids,frame,11,s10f_load_val(base,ids,frame,10,st))),
        v => s10f_apply_code(x181_add(x190_store_memory(typ,base,offset,value,ids,frame),X181Code{{[],next,term,""}}),st))
    case N111Bin{{+name,+typ,+op,+left,+right}}:
      +cc = w13c_cmp_setcc(op)
      +ak = nt_choose(U32,U32.is_gt(cc,0),v => 0,v => w13c_alu_kind(op))
      nt_choose(S10fFnSt,(U32.is_gt(cc,0) || U32.is_gt(ak,0)) && Bool.not(agy_str_eq(name,"state")),
        v => s10f_store_reg(name,frame,10,s10f_emit_bin_op(Bool.not(U32.is_eq(p111v_type(typ),1)),cc,ak,right,ids,frame,s10f_load_val(left,ids,frame,10,st))),
        v => s10f_apply_code(x181_binary(name,typ,op,left,right,ids,frame,X181Code{{[],next,term,""}}),st))
    case N111Offset{{+name,+base,+bytes}}:
      nt_choose(S10fFnSt,Bool.not(agy_str_eq(name,"state")),
        v => s10f_store_reg(name,frame,10,s10f_emit_bin_op(True{{}},0,10,bytes,ids,frame,s10f_load_val(base,ids,frame,10,st))),
        v => s10f_apply_code(x181_binary(name,N111Ptr{{}},"add",base,bytes,ids,frame,X181Code{{[],next,term,""}}),st))
    case N111Return{{+value}}:
      s10f_st_ret_epilogue(uses_state,s10f_load_val(value,ids,frame,0,st))
    case N111If{{cond,yes,no}}:
      s10f_emit_if_s(cond,yes,no,ids,frame,uses_state,st)
    case N111Call{{+name,+typ,+sym,+args}}:
      nt_choose(S10fFnSt,agy_str_eq(sym,"p111_rt_ctor"),
        x => s10f_emit_call_ctor0(name,typ,sym,args,ids,frame,st),x =>
      nt_choose(S10fFnSt,w13c_call_is_special(sym),
        y => s10f_apply_code(agy_rt_inline_try(name,typ,sym,args,ids,frame,X181Code{{[],next,term,""}}),st),
        y => s10f_emit_call_direct(name,typ,sym,args,ids,frame,st)))

@unsafe
def s10f_emit_scalar(+stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: S10fFnSt) -> S10fFnSt:
  match st:
    case S10fFnSt{{_,+ts,_,_,_,_,_,_,+next,+term,_}}:
      nt_choose(S10fFnSt,U32.is_gt(ts,134217000),
        u => s10f_st_err("x86 object section exceeds 128 MiB bound",st),
        u => s10f_emit_scalar_go(stmt,ids,frame,uses_state,next,term,st))

@unsafe
def s10f_emit_one(head: P113DStmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +next: U32, +st: S10fFnSt) -> S10fFnSt:
  match head:
    case P113DScalar{{scalar}}: s10f_emit_scalar(scalar,ids,frame,uses_state,st)
    case P113DIf{{cond,yes,no}}: s10f_emit_if(cond,yes,no,ids,frame,uses_state,st)
    case other: s10f_apply_code(x181_stmt(other,ids,frame,X181Code{{[],next,False{{}},""}}),st)

@unsafe
def s10f_emit_stmts(body, ids, frame, uses_state, st):
  match body st:
    case Nil{{}} _: st
    case Con{{head,rest}} S10fFnSt{{_,_,_,_,_,_,_,_,+next,False{{}},SNil{{}}}}:
      s10f_emit_stmts(rest,ids,frame,uses_state,s10f_emit_one(head,ids,frame,uses_state,next,st))
    case Con{{_,_}} S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,True{{}},SNil{{}}}}:
      S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,True{{}},"x86 statement after terminal"}}
    case Con{{_,_}} _: st

@unsafe
def s10f_emit_scalars(body, ids, frame, uses_state, st):
  match body st:
    case Nil{{}} _: st
    case Con{{head,rest}} S10fFnSt{{_,_,_,_,_,_,_,_,_,False{{}},SNil{{}}}}:
      s10f_emit_scalars(rest,ids,frame,uses_state,s10f_emit_scalar(head,ids,frame,uses_state,st))
    case Con{{_,_}} S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,True{{}},SNil{{}}}}:
      S10fFnSt{{t,ts,relocs,symbols,names,seen,lsyms,lrelocs,next,True{{}},"x86 statement after terminal"}}
    case Con{{_,_}} _: st

@unsafe
def s10f_resolve_if_needed(lrelocs: List<&2,X187Relocation>, lsyms: KDef, b_chk: X187Build) -> X187Build:
  match lrelocs:
    case Nil{{}}: b_chk
    case Con{{_,_}}: w10f_fn_resolve(lrelocs,lsyms,[],b_chk)

@unsafe
def s10f_pub_emit_done(+sym: String, +sym_h: U32, +start_ts: U32,
    +r: List<&2,U32>, +d: List<&2,U32>, +rs: U32, +ds: U32, st_end: S10fFnSt) -> S10fPubRes:
  match st_end:
    case S10fFnSt{{+t,+ts,+relocs,+symbols,+names,+seen,+lsyms,+lrelocs,_,+term,+err}}:
      nt_choose(S10fPubRes,String.is_empty(err),
        u => nt_choose(S10fPubRes,Bool.not(term),
          v => S10fPubRes{{X187Build{{1,t,r,d,ts,rs,ds,symbols,names,relocs,"x86 unterminated function"}},seen}},
          v => S10fPubRes{{s10f_resolve_if_needed(lrelocs,lsyms,
            X187Build{{1,t,r,d,ts,rs,ds,s10f_func_close(sym,sym_h,start_ts,ts,symbols),names,relocs,""}}),seen}}),
        u => S10fPubRes{{X187Build{{1,t,r,d,ts,rs,ds,symbols,names,relocs,err}},seen}})

@unsafe
def s10f_pub_prologue_t(+frame_sz: U32, +uses_state: Bool, +t: List<&2,U32>, +ts: U32) -> S10fT:
  +t0 = s10f_u32_rev(frame_sz,Con{{236,Con{{129,Con{{72,Con{{229,Con{{137,Con{{72,Con{{85,t}}}}}}}}}}}}}})
  nt_choose(S10fT,uses_state,
    v => S10fT{{Con{{252,Con{{137,Con{{73,Con{{240,Con{{101,Con{{137,Con{{76,t0}}}}}}}}}}}}}},U32.add(ts,18)}},
    v => S10fT{{t0,U32.add(ts,11)}})

@unsafe
def s10f_x202k_finish(ro: S10fRelOut, +sym: String, +h: U32, +ts: U32, t1: List<&2,U32>,
    r: List<&2,U32>, d: List<&2,U32>, +rs: U32, +ds: U32, err: String) -> S10fPubRes:
  match ro:
    case S10fRelOut{{rel2,sym2,nam2,seen2}}:
      +ts2 = U32.add(ts,26)
      S10fPubRes{{X187Build{{1,t1,r,d,ts2,rs,ds,s10f_func_close(sym,h,ts,ts2,sym2),nam2,rel2,err}},seen2}}

@unsafe
def s10f_x202k_opened(op: S10fOpenRes, +sym: String, +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +relocs: List<&2,X187Relocation>, +err: String, +build: X187Build, +seen: U32) -> S10fPubRes:
  match op:
    case S10fOpenRes{{sym1,nam1,+h,+oerr}}:
      nt_choose(S10fPubRes,String.is_empty(oerr),
        v =>
          +t1 : List<&2,U32> =
            Con{{0,Con{{0,Con{{0,Con{{0,Con{{233,
            Con{{192,Con{{49,Con{{40,Con{{119,Con{{139,Con{{72,Con{{16,Con{{139,Con{{72,
            Con{{16,Con{{71,Con{{137,Con{{72,Con{{8,Con{{232,Con{{131,Con{{72,
            Con{{16,Con{{71,Con{{139,Con{{72,t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
          s10f_x202k_finish(
            s10f_add_reloc(X187Relocation{{1,U32.add(ts,22),2,"p111_rt_apply",4294967292,4294967295}},relocs,sym1,nam1,seen),
            sym,h,ts,t1,r,d,rs,ds,err),
        v => S10fPubRes{{x187_build_error(oerr,build),seen}})

@unsafe
def s10f_pub_emit_x202k_sw(+sym: String, +b1: X187Build, +seen: U32) -> S10fPubRes:
  match b1:
    case X187Build{{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+err}}:
      nt_choose(S10fPubRes,U32.is_le(ts,134217696),
        u => s10f_x202k_opened(s10f_func_open(sym,ts,symbols,names),sym,t,r,d,ts,rs,ds,relocs,err,b1,seen),
        u => S10fPubRes{{x187_build_error("x86 object section exceeds 128 MiB bound",b1),seen}})
    case _: S10fPubRes{{x187_build_error("instruction outside text",b1),seen}}

@unsafe
def s10f_pub_emit_x202k(+sym: String, +build: X187Build, +seen: U32) -> S10fPubRes:
  s10f_pub_emit_x202k_sw(sym,x187_build_switch(1,build),seen)

@unsafe
def s10f_framed_d_run(pt: S10fT, +sym: String, +h: U32, +ts: U32, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, r: List<&2,U32>, d: List<&2,U32>,
    +rs: U32, +ds: U32, relocs: List<&2,X187Relocation>, sym1: KDef, nam1: List<&2,String>,
    +seen: U32, err: String) -> S10fPubRes:
  match pt:
    case S10fT{{t1,ts1}}:
      s10f_pub_emit_done(sym,h,ts,r,d,rs,ds,
        s10f_emit_stmts(body,ids,frame,uses_state,S10fFnSt{{t1,ts1,relocs,sym1,nam1,seen,missing(),[],0,False{{}},err}}))

@unsafe
def s10f_framed_d_open(op: S10fOpenRes, +sym: String, +frame_sz: U32, +body: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +relocs: List<&2,X187Relocation>, +err: String, +b1: X187Build, +seen: U32) -> S10fPubRes:
  match op:
    case S10fOpenRes{{sym1,nam1,+h,+oerr}}:
      nt_choose(S10fPubRes,String.is_empty(oerr),
        u => s10f_framed_d_run(s10f_pub_prologue_t(frame_sz,uses_state,t,ts),sym,h,ts,body,ids,frame,uses_state,r,d,rs,ds,relocs,sym1,nam1,seen,err),
        u => S10fPubRes{{x187_build_error(oerr,b1),seen}})

@unsafe
def s10f_pub_emit_framed_d_sw(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +uses_state: Bool,
    +b1: X187Build, +seen: U32, +frame: X181Frame) -> S10fPubRes:
  match b1 frame:
    case X187Build{{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+err}} X181Frame{{_,+bytes,+calls,_,_}}:
      +frame_sz = U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48)
      s10f_framed_d_open(s10f_func_open(sym,ts,symbols,names),sym,frame_sz,body,ids,frame,uses_state,t,r,d,ts,rs,ds,relocs,err,b1,seen)
    case _ _: S10fPubRes{{x187_build_error("instruction outside text",b1),seen}}

@unsafe
def s10f_pub_emit_framed_d(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +uses_state: Bool,
    +build: X187Build, +seen: U32, +frame: X181Frame) -> S10fPubRes:
  s10f_pub_emit_framed_d_sw(sym,body,ids,uses_state,x187_build_switch(1,build),seen,frame)

@unsafe
def s10f_framed_s_run(pt: S10fT, +sym: String, +h: U32, +ts: U32, +body: List<&2,N111Stmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, r: List<&2,U32>, d: List<&2,U32>,
    +rs: U32, +ds: U32, relocs: List<&2,X187Relocation>, sym1: KDef, nam1: List<&2,String>,
    +seen: U32, err: String) -> S10fPubRes:
  match pt:
    case S10fT{{t1,ts1}}:
      s10f_pub_emit_done(sym,h,ts,r,d,rs,ds,
        s10f_emit_scalars(body,ids,frame,uses_state,S10fFnSt{{t1,ts1,relocs,sym1,nam1,seen,missing(),[],0,False{{}},err}}))

@unsafe
def s10f_framed_s_open(op: S10fOpenRes, +sym: String, +frame_sz: U32, +body: List<&2,N111Stmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>,
    +ts: U32, +rs: U32, +ds: U32, +relocs: List<&2,X187Relocation>, +err: String, +b1: X187Build, +seen: U32) -> S10fPubRes:
  match op:
    case S10fOpenRes{{sym1,nam1,+h,+oerr}}:
      nt_choose(S10fPubRes,String.is_empty(oerr),
        u => s10f_framed_s_run(s10f_pub_prologue_t(frame_sz,uses_state,t,ts),sym,h,ts,body,ids,frame,uses_state,r,d,rs,ds,relocs,sym1,nam1,seen,err),
        u => S10fPubRes{{x187_build_error(oerr,b1),seen}})

@unsafe
def s10f_pub_emit_framed_s_sw(+sym: String, +body: List<&2,N111Stmt>, +ids: N111Ids, +uses_state: Bool,
    +b1: X187Build, +seen: U32, +frame: X181Frame) -> S10fPubRes:
  match b1 frame:
    case X187Build{{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+err}} X181Frame{{_,+bytes,+calls,_,_}}:
      +frame_sz = U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48)
      s10f_framed_s_open(s10f_func_open(sym,ts,symbols,names),sym,frame_sz,body,ids,frame,uses_state,t,r,d,ts,rs,ds,relocs,err,b1,seen)
    case _ _: S10fPubRes{{x187_build_error("instruction outside text",b1),seen}}

@unsafe
def s10f_pub_emit_framed_s(+sym: String, +body: List<&2,N111Stmt>, +ids: N111Ids, +uses_state: Bool,
    +build: X187Build, +seen: U32, +frame: X181Frame) -> S10fPubRes:
  s10f_pub_emit_framed_s_sw(sym,body,ids,uses_state,x187_build_switch(1,build),seen,frame)

@unsafe
def s10f_pub_emit_late(+sym: String, +ids: N111Ids, +build: X187Build, +f_st: X181Frame, +f_no: X181Frame,
    +seen: U32, late: P113ABody) -> S10fPubRes:
  match late:
    case P113ABody{{+ready_d,_}}:
      +us = w4_body_uses_state(ready_d)
      +base_f = nt_choose(X181Frame,us,a => f_st,a => f_no)
      s10f_pub_emit_framed_d(sym,ready_d,ids,us,build,seen,x181_frame_stmts(ready_d,base_f))

@unsafe
def s10f_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef,
    +build: X187Build, +pctx: S10fPubCtx) -> S10fPubRes:
  match segment context pctx:
    case N111Segment{{+name,arity,result,incoming,flags,+body}} P134Context{{+ids,index,direct,ready,view,lookups,heap,mode}} S10fPubCtx{{+f_st,+f_no,+seen}}:
      +sym = p111q_symbol(name)
      nt_choose(S10fPubRes,x202k_shape(body),
        w => s10f_pub_emit_x202k(sym,build,seen),
        w => nt_choose(S10fPubRes,x185_late_enabled() && p114t_scalar_list_names(body),
          z => s10f_pub_emit_late(sym,ids,build,f_st,f_no,seen,x185_late_stmts(x181_scalar_rows(body),ids,0)),
          z =>
            +us = w4_scalars_state(body)
            +base_f = nt_choose(X181Frame,us,a => f_st,a => f_no)
            s10f_pub_emit_framed_s(sym,body,ids,us,build,seen,x181_frame_scalars(body,base_f))))

@unsafe
def s10f_pub_emit_fast(+segment: N111Segment, context: P134Context, +available: KDef,
    +build: X187Build, +pctx: S10fPubCtx) -> S10fPubRes:
  match pctx:
    case S10fPubCtx{{_,_,+seen}}:
      nt_choose(S10fPubRes,String.is_empty(x187_build_message(build)),
        u => s10f_pub_emit_seg(segment,context,available,build,pctx),
        u => S10fPubRes{{build,seen}})

law s10f_mod_pub_loop:
  for segs: List<&2,N111Segment>
  for +ctx: P134Context
  for next: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  for +pctx: S10fPubCtx
  IO(U32)

@unsafe
def s10f_mod_pub_step(res: S10fPubRes, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +available: KDef, +weak_set: KDef, +f_st: X181Frame, +f_no: X181Frame) -> IO(U32):
  match res:
    case S10fPubRes{{+b2,+seen2}}:
      nt_choose(IO(U32),String.is_empty(x187_build_message(b2)),
        u => s10f_mod_pub_loop(rest,ctx,next,available,b2,weak_set,S10fPubCtx{{f_st,f_no,seen2}}),
        u => IO.die(U32,1,x187_build_message(b2)))

@unsafe
def s10f_mod_pub_loop(segs, ctx, next, available, build, weak_set, pctx):
  match segs pctx:
    case Nil{{}} _: w10_module_cursor_fast_io(next,available,build,weak_set)
    case Con{{head,rest}} S10fPubCtx{{+f_st,+f_no,_}}:
      s10f_mod_pub_step(s10f_pub_emit_fast(head,ctx,available,build,pctx),rest,ctx,next,available,weak_set,f_st,f_no)
"""

S10F_TR_CODE = """
law s10f_tr_pub_loop:
  for +trace: Bool
  for +is_mod: Bool
  for +weak_set: KDef
  for +t_start: Nat
  for segs: List<&2,N111Segment>
  for +ctx: P134Context
  for next: P134Cursor
  for +avail: KDef
  for +build: X187Build
  for +priv_n: U32
  for +pub_n: U32
  for +total_segs: U32
  for +pctx: S10fPubCtx
  IO(U32)

@unsafe
def s10f_tr_pub_step(res: S10fPubRes, +trace: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +priv_n: U32, +pub_n: U32, +total_segs: U32,
    +f_st: X181Frame, +f_no: X181Frame) -> IO(U32):
  match res:
    case S10fPubRes{+b2,+seen2}:
      do IO<U32>:
        +n2 : U32 = U32.inc(pub_n)
        _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,2000),0),
          u => do IO<Unit>:
            +tn : Nat <- IO.now()
            w8_tr_log(True{},"stage=x187_pub done=" ++ U32.show(n2) ++ "/" ++ U32.show(total_segs) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
          u => IO.pure(Unit,Unit{}))
        nt_choose(IO(U32),String.is_empty(x187_build_message(b2)),
          u => s10f_tr_pub_loop(trace,is_mod,weak_set,t_start,rest,ctx,next,avail,b2,priv_n,n2,total_segs,S10fPubCtx{f_st,f_no,seen2}),
          u => IO.die(U32,1,x187_build_message(b2)))

@unsafe
def s10f_tr_pub_loop(trace, is_mod, weak_set, t_start, segs, ctx, next, avail, build, priv_n, pub_n, total_segs, pctx):
  match segs pctx:
    case Nil{} _:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_pub_done count=" ++ U32.show(pub_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,True{},is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case Con{head,rest} S10fPubCtx{+f_st,+f_no,_}:
      s10f_tr_pub_step(s10f_pub_emit_fast(head,ctx,avail,build,pctx),trace,is_mod,weak_set,t_start,rest,ctx,next,avail,priv_n,pub_n,total_segs,f_st,f_no)
"""

WIRE_REPLACES = [
    (
        """    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w13c_pub_emit_fast(head,context,available,build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_fast_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x202p_x201f_finish(build,weak_set)""",
        """    case P134Public{Con{head,rest},+context,next}:
      s10f_mod_pub_loop(Con{head,rest},context,next,available,build,weak_set,s10f_init_pub_ctx())
    case P134Tables{Nil{}}: w10_module_cursor_fast_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: s10f_elf_finish_io(build,True{},weak_set)""",
    ),
    (
        """    case P134Public{Con{head,rest},ctx,next}:
      w8_tr_emit_pub(trace,fast,is_mod,weak_set,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)""",
        """    case P134Public{Con{head,rest},ctx,next}:
      nt_choose(IO(U32),fast,
        u => s10f_tr_pub_loop(trace,is_mod,weak_set,t_start,Con{head,rest},ctx,next,avail,build,priv_n,pub_n,total_segs,s10f_init_pub_ctx()),
        u => w8_tr_emit_pub(trace,fast,is_mod,weak_set,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs))""",
    ),
    (
        """        +rc : U32 <- nt_choose(IO(U32),is_mod,
          u => w10_x202p_x201f_finish(build,weak_set),
          u => x202p_x201f_finish(x187_build_seq(x181_program_main(),build)))""",
        """        +rc : U32 <- nt_choose(IO(U32),is_mod,
          u => s10f_elf_finish_io(build,True{},weak_set),
          u => s10f_elf_finish_io(x187_build_seq(x181_program_main(),build),False{},missing()))""",
    ),
]

O2_SINK_REPLACES = [
    (
        """    # Sink a (%rbx) and return acc (%r15)
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),""",
        """    # S10-F: Fast RFC/imm/static sink on a (%rbx), return acc (%r15)
    w14e_sh_fast_sink(".Ls10f_pw_" ++ symbol,12,3),""",
    ),
    (
        """    # %rax = v_out; save to 16(%rsp), sink d (%r14) if boxed, then move v_out to %r14
    x188_i2("movq",x188_reg(0,64),X187Mem{4,16}),
    x188_i2("movq",x188_reg(14,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_sdok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_sdok),
    x188_i2("movq",X187Mem{4,16},x188_reg(14,64)),
    # Fall into miss/return path: %r14 = result value, %rbx = orig_m, %r15 = key
    x188_label(l_miss),
    x188_i2("movq",x188_reg(15,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_skok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_skok),""",
        """    # S10-F: Fast RFC/imm/static sink on d (%r14) and key (%r15)
    x188_i2("movq",x188_reg(0,64),X187Mem{4,16}),
    w14e_sh_fast_sink(l_sdok,12,14),
    x188_i2("movq",X187Mem{4,16},x188_reg(14,64)),
    x188_label(l_miss),
    w14e_sh_fast_sink(l_skok,12,15),""",
    ),
    (
        """    # Sink old_v (%r8) if boxed
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_svok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_svok),
    # Sink key (%r14) if boxed
    x188_i2("movq",x188_reg(14,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_skok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_skok),""",
        """    # S10-F: Fast RFC/imm/static sink on old_v (%r8 -> %rsi) and key (%r14)
    x188_i2("movq",x188_reg(8,64),x188_reg(6,64)),
    w14e_sh_fast_sink(l_svok,12,6),
    w14e_sh_fast_sink(l_skok,12,14),""",
    ),
    (
        """@unsafe
def agy_map_sink_rsi(+skip_lbl: String) -> X188Seq:
  x188_many([
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{skip_lbl}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(skip_lbl)])""",
        """@unsafe
def agy_map_sink_rsi(+skip_lbl: String) -> X188Seq:
  w14e_sh_fast_sink(skip_lbl,12,6)""",
    ),
]


def patch_source(text: str) -> str:
    if MARKER in text:
        return text

    anchor = "# === WAVE 10 PHASE 3 (P3-A): Pure-Bend `x86-module-fast` (-O0 modular emit + M2 ELF vis) ==="
    if anchor not in text:
        raise RuntimeError(f"Anchor not found: {anchor}")

    fwd_laws = """
law w10_module_cursor_fast_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)
"""
    dup_law = """law w10_module_cursor_fast_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)
"""
    if dup_law in text:
        text = text.replace(dup_law, "", 1)

    text = text.replace(anchor, fwd_laws + "\n" + S10F_CODE + "\n" + anchor, 1)

    tr_anchor = "@unsafe\ndef w8_tr_emit_good("
    if tr_anchor not in text:
        raise RuntimeError(f"Trace anchor not found: {tr_anchor}")
    text = text.replace(tr_anchor, S10F_TR_CODE + "\n" + tr_anchor, 1)

    for old, new in WIRE_REPLACES:
        if old not in text:
            raise RuntimeError(f"Wire target not found:\n{old[:120]}")
        text = text.replace(old, new, 1)

    for old, new in O2_SINK_REPLACES:
        if old in text:
            text = text.replace(old, new, 1)

    return text


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply S10-F patch to compiler.bend or m09.bend")
    ap.add_argument("src", type=Path, help="Input .bend file")
    ap.add_argument("dst", type=Path, help="Output patched .bend file")
    args = ap.parse_args()
    text = args.src.read_text(encoding="utf-8")
    patched = patch_source(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(patched, encoding="utf-8")
    assert patch_source(patched) == patched, "Patch is not idempotent!"
    print(f"Patched {args.src} -> {args.dst} ({len(text)} -> {len(patched)} bytes, idempotent OK)")


if __name__ == "__main__":
    main()
