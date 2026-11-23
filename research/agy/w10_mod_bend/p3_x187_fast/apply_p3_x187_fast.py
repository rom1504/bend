#!/usr/bin/env python3
"""Apply Phase 3 (P3-A) pure-Bend optimizations to wave10_unified/compiler.bend:
  1. Zero-Copy Tail-Fused ELF emission (`w10f_x201f_finish_any`):
     Eliminates 2x redundant `nt_reverse` (`x187_elf_cat` = `nt_append`) over `.text`,
     `.rodata`, and `.data` by keeping section byte lists in reverse order and fusing
     branch patching (`x201f_apply`) + reversal directly onto the ELF tail.
     Also wires `w7c_relocs_fused` into the streaming `x202p_x187_elf_checked` path.
  2. Zero-Copy Per-Function Local `.L*` Label Resolution (`w10f_output_fn` + `W10fFnBuild`):
     Keeps `.text` and non-`.L*` symbols in-place in `X187Build` (zero byte copying,
     zero double-hashing), while routing function-local `.L*` labels and all 15 `j*`
     branch opcodes into a tiny ~10-entry per-function `lsyms` trie + `lrelocs` list.
     Resolves local branches at function end into kind-131 pre-resolved patches and
     drops `lsyms` immediately (keeping `build.symbols`/`build.names` 12.8x smaller
     and eliminating 211k+ global trie lookups in `x188_fixup_scan`).
  3. Pure-Bend `x86-module-fast` & `--trace x86-module-fast` CLI + JS API
     (`w10_module_prepared_fast`), preserving M2 `STB_LOCAL`/`STB_WEAK` visibility,
     `p111_cid_hot` in `.data`, and 16-bit FID capacity guard.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave10_unified/compiler.bend"
DEFAULT_DST = Path("/tmp/agy_p3_x187/compiler.bend")


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return text.replace(old, new, 1)


# ---------------------------------------------------------------------------
# 1. Kind-131 pre-resolved local branch fast-path in `x188_fixup_item`
# ---------------------------------------------------------------------------
OLD_FIXUP_ITEM = """\
@unsafe
def x188_fixup_item(+reloc: X187Relocation, +index: KDef, +size: U32, +state: X188Fixups) -> X188Fixups:
  match reloc:
    case X187Relocation{section,offset,+kind,name,lo,hi}:
      nt_choose(X188Fixups,U32.is_eq(kind,130),
        u => x188_fixup_symbol(reloc,size,state,p111v_get(index,name)),
        u => x188_fixup_keep(reloc,state))"""

NEW_FIXUP_ITEM = """\
@unsafe
def x188_fixup_item(+reloc: X187Relocation, +index: KDef, +size: U32, +state: X188Fixups) -> X188Fixups:
  match reloc:
    case X187Relocation{section,offset,+kind,name,lo,hi}:
      nt_choose(X188Fixups,U32.is_eq(kind,131),
        u => x188_fixup_add(X187Relocation{1,offset,2,"",lo,0},state),
        u => nt_choose(X188Fixups,U32.is_eq(kind,130),
          v => x188_fixup_symbol(reloc,size,state,p111v_get(index,name)),
          v => x188_fixup_keep(reloc,state)))"""


# ---------------------------------------------------------------------------
# 2. Pure-Bend P3-A Core: Zero-Copy W10fFnBuild + Tail-Fused ELF Emission
# ---------------------------------------------------------------------------
P3_CORE_BEND = """\
# === WAVE 10 PHASE 3 (P3-A): Zero-Copy Per-Function .L* Resolution + Tail-Fused ELF ===

type W10fFnBuild is Data:
  W10fFnBuild{+build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>}

# Returns 233 for `jmp`, 130..143 for 2-byte `0F 8x` Jcc, or 0 if not a branch.
@unsafe
def w10f_jcc_code(+tail: String) -> U32:
  nt_choose(U32,agy_str_eq(tail,"ne"),u => 133,u =>
  nt_choose(U32,agy_str_eq(tail,"mp"),u => 233,u =>
  nt_choose(U32,agy_str_eq(tail,"e"),u => 132,u =>
  nt_choose(U32,agy_str_eq(tail,"z"),u => 132,u =>
  nt_choose(U32,agy_str_eq(tail,"a"),u => 135,u =>
  nt_choose(U32,agy_str_eq(tail,"b"),u => 130,u =>
  nt_choose(U32,agy_str_eq(tail,"ae"),u => 131,u =>
  nt_choose(U32,agy_str_eq(tail,"be"),u => 134,u =>
  nt_choose(U32,agy_str_eq(tail,"g"),u => 143,u =>
  nt_choose(U32,agy_str_eq(tail,"ge"),u => 141,u =>
  nt_choose(U32,agy_str_eq(tail,"l"),u => 140,u =>
  nt_choose(U32,agy_str_eq(tail,"le"),u => 142,u =>
  nt_choose(U32,agy_str_eq(tail,"np"),u => 139,u =>
  nt_choose(U32,agy_str_eq(tail,"nz"),u => 133,u =>
  nt_choose(U32,agy_str_eq(tail,"p"),u => 138,u => 0)))))))))))))))

@unsafe
def w10f_fn_label_local(+name: String, +ts: U32, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>) -> W10fFnBuild:
  +h = index_hash(name,2166136261)
  nt_choose(W10fFnBuild,agy_str_eq(dk(w5c3_find(lsyms,name,h)),"W10fL"),
    u => W10fFnBuild{x187_build_error("duplicate symbol or invalid size: " ++ name,build),lsyms,lrelocs},
    u => W10fFnBuild{build,p111v_put_h(lsyms,name,h,"W10fL",ts,0),lrelocs})

@unsafe
def w10f_fn_emit_jcc(+code: U32, +sym: String, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String,
    +lsyms: KDef, +lrelocs: List<&2,X187Relocation>) -> W10fFnBuild:
  nt_choose(W10fFnBuild,U32.is_eq(code,0),
    u => W10fFnBuild{x188_build_instruction(inst,build),lsyms,lrelocs},
    u => nt_choose(W10fFnBuild,U32.is_eq(code,233),
      v => W10fFnBuild{
        X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{233,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error},
        lsyms,Con{X187Relocation{1,U32.inc(ts),130,sym,4294967292,4294967295},lrelocs}},
      v => W10fFnBuild{
        X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{code,Con{15,t}}}}}},r,d,U32.add(ts,6),rs,ds,symbols,names,relocs,error},
        lsyms,Con{X187Relocation{1,U32.add(ts,2),130,sym,4294967292,4294967295},lrelocs}}))

@unsafe
def w10f_fn_inst(+inst: X187Instruction, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>) -> W10fFnBuild:
  match inst build:
    case X187Instruction{SCon{+ch,+tail},Con{X187Target{+sym},Nil{}}}
         X187Build{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+error}:
      nt_choose(W10fFnBuild,U32.is_eq(Char.to_u32(ch),106) && U32.is_le(ts,134217712) && String.starts_with(sym,".L"),
        u => w10f_fn_emit_jcc(w10f_jcc_code(tail),sym,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error,lsyms,lrelocs),
        u => W10fFnBuild{x188_build_instruction(inst,build),lsyms,lrelocs})
    case _ _: W10fFnBuild{x187_build_parsed(PInst{inst},build),lsyms,lrelocs}

@unsafe
def w10f_fn_parsed(+parsed: X187Parsed, +st: W10fFnBuild) -> W10fFnBuild:
  match parsed st:
    case PLabel{+name} W10fFnBuild{+build,+lsyms,+lrelocs}:
      nt_choose(W10fFnBuild,String.starts_with(name,".L") && U32.is_eq(x187_build_section(build),1),
        u => w10f_fn_label_local(name,x187_build_offset(build),build,lsyms,lrelocs),
        u => W10fFnBuild{x187_build_symbol(name,1,0,build),lsyms,lrelocs})
    case PInst{+inst} W10fFnBuild{+build,+lsyms,+lrelocs}:
      w10f_fn_inst(inst,build,lsyms,lrelocs)
    case other W10fFnBuild{+build,+lsyms,+lrelocs}:
      W10fFnBuild{x187_build_parsed(other,build),lsyms,lrelocs}

law w10f_fn_seq_go:
  for seq: X188Seq
  for rest: List<&2,X188Seq>
  for +st: W10fFnBuild
  for +count: U32
  W10fFnBuild

@unsafe
def w10f_fn_seq_pop(rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match rest:
    case Nil{}: st
    case Con{head,tail}: w10f_fn_seq_go(head,tail,st,count)

@unsafe
def w10f_fn_st_ok(st: W10fFnBuild) -> Bool:
  match st:
    case W10fFnBuild{build,_,_}: String.is_empty(x187_build_message(build))

@unsafe
def w10f_fn_after_one(ok: Bool, rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match ok:
    case True{}: w10f_fn_seq_pop(rest,st,count)
    case False{}: st

@unsafe
def w10f_fn_seq_step(seq: X188Seq, rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match seq:
    case X188Empty{}: w10f_fn_seq_pop(rest,st,count)
    case X188One{item}:
      +st2 = w10f_fn_parsed(item,st)
      w10f_fn_after_one(w10f_fn_st_ok(st2),rest,st2,count)
    case X188Join{left,right}: w10f_fn_seq_go(left,Con{right,rest},st,count)

@unsafe
def w10f_fn_seq_chk(ok: Bool, seq: X188Seq, rest: List<&2,X188Seq>, +st: W10fFnBuild, +count: U32) -> W10fFnBuild:
  match ok:
    case True{}: w10f_fn_seq_step(seq,rest,st,U32.inc(count))
    case False{}:
      match st:
        case W10fFnBuild{build,lsyms,lrelocs}:
          W10fFnBuild{x187_build_error("x86 object fragment count exceeds bound",build),lsyms,lrelocs}

@unsafe
def w10f_fn_seq_go(seq, rest, st, count):
  w10f_fn_seq_chk(U32.is_lt(count,67108864),seq,rest,st,count)

@unsafe
def w10f_fn_chunks(chunks: List<&2,X188Seq>, +st: W10fFnBuild) -> W10fFnBuild:
  match chunks:
    case Nil{}: st
    case Con{+head,+rest}:
      nt_choose(W10fFnBuild,w10f_fn_st_ok(st),
        u => w10f_fn_chunks(rest,w10f_fn_seq_go(head,[],st,0)),
        u => st)

@unsafe
def w10f_fn_push_relocs(rev_relocs: List<&2,X187Relocation>, build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      X187Build{s,t,r,d,ts,rs,ds,symbols,names,nt_reverse(X187Relocation,rev_relocs,relocs),error}

law w10f_fn_resolve:
  for lrelocs: List<&2,X187Relocation>
  for +lsyms: KDef
  for +acc: List<&2,X187Relocation>
  for +build: X187Build
  X187Build

@unsafe
def w10f_fn_resolve_one(+reloc: X187Relocation, +rest: List<&2,X187Relocation>, +lsyms: KDef,
    +acc: List<&2,X187Relocation>, +build: X187Build, +entry: KDef) -> X187Build:
  match reloc:
    case X187Relocation{sec,+off,knd,+sym,lo,hi}:
      nt_choose(X187Build,agy_str_eq(dk(entry),"W10fL"),
        u => w10f_fn_resolve(rest,lsyms,
          Con{X187Relocation{1,off,131,"",U32.sub(da(entry),U32.add(off,4)),0},acc},build),
        u => w10f_fn_resolve(rest,lsyms,acc,x187_build_relocation(reloc,build)))

@unsafe
def w10f_fn_resolve_item(+reloc: X187Relocation, rest: List<&2,X187Relocation>, +lsyms: KDef,
    acc: List<&2,X187Relocation>, build: X187Build) -> X187Build:
  match reloc:
    case X187Relocation{sec,off,knd,+sym,lo,hi}:
      w10f_fn_resolve_one(reloc,rest,lsyms,acc,build,p111v_get(lsyms,sym))

@unsafe
def w10f_fn_resolve(lrelocs, lsyms, acc, build):
  match lrelocs:
    case Nil{}: w10f_fn_push_relocs(acc,build)
    case Con{reloc,rest}:
      w10f_fn_resolve_item(reloc,rest,lsyms,acc,build)

@unsafe
def w10f_fn_finish(st: W10fFnBuild) -> X187Build:
  match st:
    case W10fFnBuild{+build,+lsyms,+lrelocs}:
      nt_choose(X187Build,String.is_empty(x187_build_message(build)),
        u => w10f_fn_resolve(lrelocs,lsyms,[],build),
        u => build)

@unsafe
def w10f_output_fn(output, build):
  match output:
    case X181Output{+chunks,+error}:
      nt_choose(X187Build,String.is_empty(error) && String.is_empty(x187_build_message(build)),
        u => w10f_fn_finish(w10f_fn_chunks(chunks,W10fFnBuild{build,missing(),[]})),
        u => x187_build_error(p111_first(x187_build_message(build),error),build))

# --- Part B: Zero-Copy Tail-Fused ELF Emission (`w10f_elf_sections_emit_rev`) ---

@unsafe
def w10f_elf_wrap_text(+shOff: U32, +o1: U32, patched: X187Encoded) -> X187ObjectResult:
  match patched:
    case X187Encoded{t1,_,+err}:
      nt_choose(X187ObjectResult,String.is_empty(err),
        u => X187ObjectResult{x187_elf_cat(x187_elf_header(shOff),x187_elf_zero(U32.sub(o1,64),t1)),""},
        u => X187ObjectResult{[],err})

@unsafe
def w10f_elf_finish_rev(+plan: List<&2,X187Relocation>, text_rev: List<&2,U32>, +ts: U32,
    +shOff: U32, +o1: U32, pad1: List<&2,U32>) -> X187ObjectResult:
  match plan:
    case Nil{}:
      +t1 = nt_reverse(U32,text_rev,pad1)
      X187ObjectResult{x187_elf_cat(x187_elf_header(shOff),x187_elf_zero(U32.sub(o1,64),t1)),""}
    case Con{_,_}:
      w10f_elf_wrap_text(shOff,o1,x201f_apply(text_rev,plan,ts,pad1))

@unsafe
def w10f_elf_sections_emit_rev(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    +plan: List<&2,X187Relocation>, +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rp: W7RelocParts) -> X187ObjectResult:
  match rp:
    case W7RelocParts{r1,+n1,r2,+n2,r3,+n3}:
      +shstr = nt_reverse(U32,x187_elf_ascii(
        "\\0.text\\0.rodata\\0.data\\0.rela.text\\0.rela.rodata\\0.rela.data\\0.symtab\\0.strtab\\0.shstrtab\\0.note.GNU-stack\\0",[]),[])
      +shstrSize : U32 = 98
      +symSize = U32.mul(count,24)
      +o1 = x187_elf_align(64,16)
      +e1 = U32.add(o1,ts)
      +o2 = x187_elf_align(e1,8)
      +e2 = U32.add(o2,rs)
      +o3 = x187_elf_align(e2,8)
      +e3 = U32.add(o3,ds)
      +o4 = x187_elf_align(e3,8)
      +e4 = U32.add(o4,n1)
      +o5 = x187_elf_align(e4,8)
      +e5 = U32.add(o5,n2)
      +o6 = x187_elf_align(e5,8)
      +e6 = U32.add(o6,n3)
      +o7 = x187_elf_align(e6,8)
      +e7 = U32.add(o7,symSize)
      +o8 = e7
      +e8 = U32.add(o8,stringSize)
      +o9 = e8
      +e9 = U32.add(o9,shstrSize)
      +o10 = e9
      +shOff = x187_elf_align(o10,8)
      +shdrs = x187_elf_zero(64,
        w7_shdr(1,1,6,o1,ts,0,0,16,0,
        w7_shdr(7,1,2,o2,rs,0,0,8,0,
        w7_shdr(15,1,3,o3,ds,0,0,8,0,
        w7_shdr(21,4,0,o4,n1,7,1,8,24,
        w7_shdr(32,4,0,o5,n2,7,2,8,24,
        w7_shdr(45,4,0,o6,n3,7,3,8,24,
        w7_shdr(56,2,0,o7,symSize,8,firstGlobal,8,24,
        w7_shdr(64,3,0,o8,stringSize,0,0,1,0,
        w7_shdr(72,3,0,o9,shstrSize,0,0,1,0,
        w7_shdr(82,1,0,o10,0,0,0,1,0,[])))))))))))
      +t10 = x187_elf_zero(U32.sub(shOff,o10),shdrs)
      +t9 = x187_elf_cat(shstr,t10)
      +t8 = nt_reverse(U32,strings,t9)
      +t7 = nt_reverse(U32,table,t8)
      +t6 = nt_reverse(U32,r3,x187_elf_zero(U32.sub(o7,e6),t7))
      +t5 = nt_reverse(U32,r2,x187_elf_zero(U32.sub(o6,e5),t6))
      +t4 = nt_reverse(U32,r1,x187_elf_zero(U32.sub(o5,e4),t5))
      +t3 = nt_reverse(U32,data_rev,x187_elf_zero(U32.sub(o4,e3),t4))
      +t2 = nt_reverse(U32,rodata_rev,x187_elf_zero(U32.sub(o3,e2),t3))
      w10f_elf_finish_rev(plan,text_rev,ts,shOff,o1,x187_elf_zero(U32.sub(o2,e1),t2))

@unsafe
def w10f_elf_checked_go(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rr: W7cRelocResult) -> X187ObjectResult:
  match rr:
    case W7cRelocOk{rp}: w10f_elf_sections_emit_rev(text_rev,rodata_rev,data_rev,plan,ts,rs,ds,count,firstGlobal,table,strings,stringSize,rp)
    case W7cRelocBad{}: X187ObjectResult{[],"invalid ELF relocation"}

@unsafe
def w10f_elf_checked_rev(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, relocations: List<&2,X187Relocation>,
    +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match sizes symbols:
    case X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w10f_elf_checked_go(text_rev,rodata_rev,data_rev,plan,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => X187ObjectResult{[],error})

law w10f_build_symbols_rev:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for text_rev: List<&2,U32>
  for rodata_rev: List<&2,U32>
  for data_rev: List<&2,U32>
  for plan: List<&2,X187Relocation>
  for relocations: List<&2,X187Relocation>
  for +is_mod: Bool
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def w10f_build_sym_checked_rev(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>,
    text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, relocations: List<&2,X187Relocation>,
    +is_mod: Bool, +weak_set: KDef) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}:
      nt_choose(X187ObjectResult,w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes),u =>
        w10f_build_symbols_rev(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),
          text_rev,rodata_rev,data_rev,plan,relocations,is_mod,weak_set),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})

@unsafe
def w10f_build_sym_final_rev(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>,
    text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, relocations: List<&2,X187Relocation>,
    +is_mod: Bool, +weak_set: KDef, +symbol: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        +sym_global : Bool = nt_choose(Bool,is_mod && defined && w10_is_mod_local_sym(name),
          v => False{},
          v => global || Bool.not(defined))
        w10f_build_sym_checked_rev(X187Symbol{name,section,value,size,sym_global,kind},
          rest,index,escaped,sizes,acc,text_rev,rodata_rev,data_rev,plan,relocations,is_mod,weak_set))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def w10f_build_symbols_rev(names, index, escaped, sizes, acc, text_rev, rodata_rev, data_rev, plan, relocations, is_mod, weak_set):
  match names:
    case Nil{}:
      +syms : X187ElfSymbols = nt_choose(X187ElfSymbols,is_mod,
        u => w10_elf_globals(acc,sizes,weak_set,
          w10_elf_symbols(acc,False{},sizes,weak_set,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})),
        u => x187_elf_globals(acc,sizes,
          x187_elf_symbols(acc,False{},sizes,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})))
      w10f_elf_checked_rev(text_rev,rodata_rev,data_rev,plan,relocations,sizes,syms)
    case Con{+name,rest}:
      w10f_build_sym_final_rev(name,rest,index,escaped,sizes,acc,text_rev,rodata_rev,data_rev,plan,relocations,is_mod,weak_set,p111v_get(index,name))

@unsafe
def w10f_fixups_dispatch(+names: List<&2,String>, +index: KDef, +sizes: X187ElfSizes,
    +t_rev: List<&2,U32>, +r_rev: List<&2,U32>, +d_rev: List<&2,U32>,
    +patches: List<&2,X187Relocation>, +plan: List<&2,X187Relocation>,
    +relocations: List<&2,X187Relocation>, +escaped: KDef,
    +is_mod: Bool, +weak_set: KDef) -> X187ObjectResult:
  match patches plan:
    case Con{_,_} Nil{}:
      nt_choose(X187ObjectResult,is_mod,
        u => w10_build_patched(names,index,escaped,sizes,nt_reverse(U32,r_rev,[]),nt_reverse(U32,d_rev,[]),
          relocations,x188_fixup_bytes(nt_reverse(U32,t_rev,[]),patches,0,[]),weak_set),
        u => x188_build_patched(names,index,escaped,sizes,nt_reverse(U32,r_rev,[]),nt_reverse(U32,d_rev,[]),
          relocations,x188_fixup_bytes(nt_reverse(U32,t_rev,[]),patches,0,[])))
    case _ _:
      w10f_build_symbols_rev(names,index,escaped,sizes,[],t_rev,r_rev,d_rev,plan,relocations,is_mod,weak_set)

@unsafe
def w10f_fixups_rev(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    t_rev: List<&2,U32>, r_rev: List<&2,U32>, d_rev: List<&2,U32>,
    state: X188Fixups, +is_mod: Bool, +weak_set: KDef) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w10f_fixups_dispatch(names,index,sizes,t_rev,r_rev,d_rev,patches,x201f_plan(patches,ts,0,[]),relocations,escaped,is_mod,weak_set),
        u => X187ObjectResult{[],error})

@unsafe
def w10f_x201f_finish_any(build, is_mod, weak_set):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          w10f_fixups_rev(names,symbols,X187ElfSizes{ts,rs,ds},t,r,d,
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""}),is_mod,weak_set),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

# --- Part C: Streaming IO `x202p` fused relocation pass ---

@unsafe
def w10f_x202p_elf_emit(text, rodata, data, ts, rs, ds, count, firstGlobal, table, strings, stringSize, rr):
  match rr:
    case W7cRelocBad{}: IO.die(U32,1,"invalid ELF relocation")
    case W7cRelocOk{W7RelocParts{r1,+n1,r2,+n2,r3,+n3}}:
      +sectionNames = nt_reverse(U32,x187_elf_ascii(
          "\\0.text\\0.rodata\\0.data\\0.rela.text\\0.rela.rodata\\0.rela.data\\0.symtab\\0.strtab\\0.shstrtab\\0.note.GNU-stack\\0",[]),[])
      x202t_plan([
        X187ElfSection{1,1,6,16,0,0,0,text},
        X187ElfSection{7,1,2,8,0,0,0,rodata},
        X187ElfSection{15,1,3,8,0,0,0,data},
        X187ElfSection{21,4,0,8,24,7,1,nt_reverse(U32,r1,[])},
        X187ElfSection{32,4,0,8,24,7,2,nt_reverse(U32,r2,[])},
        X187ElfSection{45,4,0,8,24,7,3,nt_reverse(U32,r3,[])},
        X187ElfSection{56,2,0,8,24,8,firstGlobal,nt_reverse(U32,table,[])},
        X187ElfSection{64,3,0,1,0,0,0,nt_reverse(U32,strings,[])},
        X187ElfSection{72,3,0,1,0,0,0,sectionNames},
        X187ElfSection{82,1,0,1,0,0,0,[]}],
        x202t_sizes(X187ElfSizes{ts,rs,ds},X187ElfSizes{n1,n2,n3},count,stringSize,98),64,[],x187_elf_zero(64,[]))
"""


# ---------------------------------------------------------------------------
# 3. Wire `x187_cursor_fast_good`, `x202p_x187_elf_checked`, `x86-module-fast`
# ---------------------------------------------------------------------------
OLD_X187_CURSOR_FAST = """\
@unsafe
def x187_cursor_fast_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Private{rest,context,next},available,x187_output(x181_program_private_fast(head,context,available),build))
    case P134Legacy{entries,context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Public{rest,context,next},available,x187_output(x181_program_public_fast(head,context,available),build))
    case P134Tables{Nil{}}: x187_cursor_fast(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x187_cursor_fast(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x201f_finish(x187_build_seq(x181_program_main(),build))
    case _: X187ObjectResult{[],"incomplete object cursor"}"""

NEW_X187_CURSOR_FAST = """\
@unsafe
def x187_cursor_fast_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build))
    case P134Legacy{entries,context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Nil{},context,next}: x187_cursor_fast(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      x187_cursor_fast(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build))
    case P134Tables{Nil{}}: x187_cursor_fast(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      x187_cursor_fast(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: w10f_x201f_finish_any(x187_build_seq(x181_program_main(),build),False{},missing())
    case _: X187ObjectResult{[],"incomplete object cursor"}"""


OLD_X202P_ELF_CHECKED = """\
@unsafe
def x202p_x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> IO(U32):
  match object symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,+error}:
      nt_choose(IO(U32),String.is_empty(error) && x187_elf_relocs_valid(relocations,sizes,index,0),
        u => x202p_x187_elf_sections(object,symbols,sizes),
        u => IO.die(U32,1,p111_first(error,"invalid ELF relocation")))"""

NEW_X202P_ELF_CHECKED = """\
@unsafe
def x202p_x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> IO(U32):
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSizes{+ts,+rs,+ds}
      X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => w10f_x202p_elf_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => IO.die(U32,1,error))"""


W10_MODULE_FAST_BEND = """\
# === WAVE 10 PHASE 3 (P3-A): Pure-Bend `x86-module-fast` (-O0 modular emit + M2 ELF vis) ===

law w10_module_cursor_fast:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  X187ObjectResult

@unsafe
def w10_module_cursor_fast_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor_fast(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor_fast(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor_fast(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor_fast(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_fast(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_fast(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10f_x201f_finish_any(build,True{},weak_set)
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def w10_module_cursor_fast(cursor, available, build, weak_set):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_fast_good(cursor,available,build,weak_set),u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def w10_module_prepared_fast(+prepared: P169Prepared, seed: P86Seed, +fid_base: U32, +mod_name: String) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      +weak_set = w10_weak_from_seed(seed)
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => nt_choose(X187ObjectResult,U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor_fast(w8_relocate_cursor(cursor,fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => X187ObjectResult{[],"x86-module-fast: fid_base + segment_count exceeds 16-bit FID capacity (65532)"}),
        u => X187ObjectResult{[],error})

law w10_module_cursor_fast_io:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +weak_set: KDef
  IO(U32)

@unsafe
def w10_module_cursor_fast_io_good(+cursor: P134Cursor, +available: KDef, +build: X187Build, +weak_set: KDef) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: w10_module_cursor_fast_io(next,available,build,weak_set)
    case P134Private{Con{head,rest},+context,next}:
      w10_module_cursor_fast_io(P134Private{rest,context,next},available,w10f_output_fn(x181_program_private_fast(head,context,available),build),weak_set)
    case P134Legacy{entries,context,next}: w10_module_cursor_fast_io(next,available,build,weak_set)
    case P134Public{Nil{},context,next}: w10_module_cursor_fast_io(next,available,build,weak_set)
    case P134Public{Con{head,rest},+context,next}:
      w10_module_cursor_fast_io(P134Public{rest,context,next},available,w10f_output_fn(x181_program_public_fast(head,context,available),build),weak_set)
    case P134Tables{Nil{}}: w10_module_cursor_fast_io(P134Main{},available,build,weak_set)
    case P134Tables{Con{head,rest}}:
      w10_module_cursor_fast_io(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),weak_set)
    case P134Main{}: w10_x202p_x201f_finish(build,weak_set)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w10_module_cursor_fast_io(cursor, available, build, weak_set):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w10_module_cursor_fast_io_good(cursor,available,build,weak_set),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w10_module_prepared_fast_io(+prepared: P169Prepared, +weak_set: KDef, +fid_base: U32, +mod_name: String) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w10_module_cursor_fast_io(w8_relocate_cursor(cursor,fid_base,mod_name),avail,x187_build_empty(),weak_set),
          v => IO.die(U32,1,"x86-module-fast: fid_base + segment_count exceeds 16-bit FID capacity (65532)")),
        u => IO.die(U32,1,error))

@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_fast_io(x198pw_plan(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)

@unsafe
def w10_module_request_fast(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +prep : P86Preparation = nt_choose(P86Preparation,cached,
      u => p88_cache_prepare(base_path,base,carrier,stamp),
      u => p86_prepare(base_path,base))
    w10_module_prep_run_fast(path,source,fid_base,mod_name,prep)

@unsafe
def w10_module_fast_entry(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, fid_base_m: Maybe<&2,U32>, +mod_name: String) -> IO(U32):
  match fid_base_m:
    case Some{+fid_base}:
      nt_choose(IO(U32),U32.is_lt(fid_base,65532) && Bool.not(String.is_empty(mod_name)),
        u => w10_module_request_fast(path,base,carrier,stamp,agy_str_eq(mode,"cache"),fid_base,mod_name),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")
"""


OLD_W10_MOD_ANCHOR = """\
@unsafe
def w10_module_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +prep : P86Preparation = nt_choose(P86Preparation,cached,
      u => p88_cache_prepare(base_path,base,carrier,stamp),
      u => p86_prepare(base_path,base))
    w10_module_prep_run(path,source,fid_base,mod_name,prep)"""

OLD_W8_TR_EMIT_PRIV_BUILD = """\
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)"""

NEW_W8_TR_EMIT_PRIV_BUILD = """\
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = w10f_output_fn(out,build)"""

OLD_W8_TR_EMIT_PUB_BUILD = """\
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => x181_program_public(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)"""

NEW_W8_TR_EMIT_PUB_BUILD = """\
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => x181_program_public(head,ctx,avail))
    +b2 : X187Build = w10f_output_fn(out,build)"""

OLD_W8_TR_ENRICH = """\
              +enr : P134Cursor = agy_enrich_cursor(cursor,avail)
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)"""

NEW_W8_TR_ENRICH = """\
              +enr : P134Cursor = nt_choose(P134Cursor,fast,w => cursor,w => agy_enrich_cursor(cursor,avail))
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)"""

OLD_W8_TR_START_LOG = """\
    _ : Unit <- w8_tr_log(trace,"start src=" ++ path ++ nt_choose(String,is_mod,u => " mode=x86-module mod=" ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast",v => " mode=x86-object")))"""

NEW_W8_TR_START_LOG = """\
    _ : Unit <- w8_tr_log(trace,"start src=" ++ path ++ nt_choose(String,is_mod,u => nt_choose(String,fast,v => " mode=x86-module-fast mod=",v => " mode=x86-module mod=") ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast",v => " mode=x86-object")))"""

OLD_W8_TR_MOD_ENTRY = """\
@unsafe
def w8_tr_mod_fid(fid_m: Maybe<&2,U32>, +mod_name: String, +path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}: w8_tr_run_obj(True{},False{},True{},fb,mod_name,path,base,carrier,stamp,cached)
    case _: IO.die(U32,2,"expected U32 fid_base argument")

@unsafe
def w8_tr_entry(+args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_run_obj(True{},agy_str_eq(program,"x86-object-fast"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}}:
      nt_choose(IO(U32),agy_str_eq(program,"x86-module") && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_mod_fid(U32.read(fid_s),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case _: x181_entry_args(args)"""

NEW_W8_TR_MOD_ENTRY = """\
@unsafe
def w8_tr_mod_fid(fid_m: Maybe<&2,U32>, +fast: Bool, +mod_name: String, +path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}: w8_tr_run_obj(True{},fast,True{},fb,mod_name,path,base,carrier,stamp,cached)
    case _: IO.die(U32,2,"expected U32 fid_base argument")

@unsafe
def w8_tr_entry(+args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_run_obj(True{},agy_str_eq(program,"x86-object-fast"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_mod_fid(U32.read(fid_s),agy_str_eq(program,"x86-module-fast"),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case _: x181_entry_args(args)"""

OLD_ENTRY_ARGS_MOD = """\
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-shard") || agy_str_eq(program,"x86-module")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-module"),
          v => w8_module_entry(path,base,mode,carrier,stamp,U32.read(shard_s),shards_s),
          v => nt_choose(IO(U32),agy_str_eq(program,"x86-shard"),
            w => agy_lpt_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
            w => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)))),
        u => IO.die(U32,2,"expected x86-object|x86-shard|x86-module, absolute input/Base paths, live|cache mode, and shard/shards or fid_base/mod_name"))
    case _: IO.die(U32,2,"usage: x86|x86-object|x86-shard|x86-module ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS | FID_BASE MOD_NAME]")"""

NEW_ENTRY_ARGS_MOD = """\
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-shard") || agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-module-fast"),
          v => w10_module_fast_entry(path,base,mode,carrier,stamp,U32.read(shard_s),shards_s),
          v => nt_choose(IO(U32),agy_str_eq(program,"x86-module"),
            w => w8_module_entry(path,base,mode,carrier,stamp,U32.read(shard_s),shards_s),
            w => nt_choose(IO(U32),agy_str_eq(program,"x86-shard"),
              z => agy_lpt_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
              z => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s))))),
        u => IO.die(U32,2,"expected x86-object|x86-shard|x86-module|x86-module-fast, absolute input/Base paths, live|cache mode, and shard/shards or fid_base/mod_name"))
    case _: IO.die(U32,2,"usage: x86|x86-object|x86-object-fast|x86-shard|x86-module|x86-module-fast ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS | FID_BASE MOD_NAME]")"""


def main() -> None:
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SRC
    dst = Path(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_DST

    text = src.read_text(encoding="utf-8")

    text = replace_exact(text, OLD_FIXUP_ITEM, NEW_FIXUP_ITEM, "x188_fixup_item kind 131")

    LAWS_FOR_P3 = """\
law w10f_output_fn:
  for +output: X181Output
  for +build: X187Build
  X187Build

law w10f_x201f_finish_any:
  for +build: X187Build
  for +is_mod: Bool
  for +weak_set: KDef
  X187ObjectResult

law w10f_x202p_elf_emit:
  for text: List<&2,U32>
  for rodata: List<&2,U32>
  for data: List<&2,U32>
  for +ts: U32
  for +rs: U32
  for +ds: U32
  for +count: U32
  for +firstGlobal: U32
  for table: List<&2,U32>
  for strings: List<&2,U32>
  for +stringSize: U32
  for rr: W7cRelocResult
  IO(U32)

"""
    text = replace_exact(
        text,
        OLD_X187_CURSOR_FAST,
        LAWS_FOR_P3 + NEW_X187_CURSOR_FAST,
        "x187_cursor_fast_good + laws",
    )
    text = replace_exact(text, OLD_X202P_ELF_CHECKED, NEW_X202P_ELF_CHECKED, "x202p_x187_elf_checked")
    text = replace_exact(
        text,
        OLD_W10_MOD_ANCHOR,
        OLD_W10_MOD_ANCHOR + "\n\n" + P3_CORE_BEND + "\n\n" + W10_MODULE_FAST_BEND,
        "insert P3 core + x86-module-fast",
    )
    text = replace_exact(text, OLD_W8_TR_EMIT_PRIV_BUILD, NEW_W8_TR_EMIT_PRIV_BUILD, "w8_tr_emit_priv")
    text = replace_exact(text, OLD_W8_TR_EMIT_PUB_BUILD, NEW_W8_TR_EMIT_PUB_BUILD, "w8_tr_emit_pub")
    text = replace_exact(text, OLD_W8_TR_ENRICH, NEW_W8_TR_ENRICH, "w8_tr_run_prepared enrich")
    text = replace_exact(text, OLD_W8_TR_START_LOG, NEW_W8_TR_START_LOG, "w8_tr_run_obj log")
    text = replace_exact(text, OLD_W8_TR_MOD_ENTRY, NEW_W8_TR_MOD_ENTRY, "w8_tr_entry")
    text = replace_exact(text, OLD_ENTRY_ARGS_MOD, NEW_ENTRY_ARGS_MOD, "x181_entry_args")

    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(text, encoding="utf-8")
    print(f"Wrote {dst} ({dst.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
