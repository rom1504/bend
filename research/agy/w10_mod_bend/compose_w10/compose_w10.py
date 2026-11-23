#!/usr/bin/env python3
"""Compose Wave 10 Pure-Bend Modular Unified Compiler (selfhost/build/agy/wave10_unified/compiler.bend).

Combines all 5 verified Phase 1 / Wave 9 deliverables on top of
`selfhost/build/agy/wave8_unified/compiler.bend` (read-only):
  1. w9_str_hot (`research/agy/w9_str_hot/apply_w9_str_hot.py`):
     - agy_sh_try in -O0 (`x181_program_private_fast`) + protect agy_sh intrinsics from inlining
     - direct `p113d_` hash-trie (`index_find` / `index_bucket` / `index_remove` / `index_tip`)
  2. w9_elf_fast (`research/agy/w9_elf_fast/apply_w9_elf_fast.py`):
     - compact `x202k_template`, single-pass `x187_elf_symbol_add`, fused `w7c_relocs_fused`,
       direct reverse-push `x188_build_instruction` (128 MiB guard), fast `x181_program_public_fast`
     - preserves `p111_cid_hot` in `.data` & `128 MiB` ELF guard
  3. M1 (`research/agy/w10_mod_bend/m1_merge_obj/merge_obj.bend`):
     - `x86-merge-obj` pure-Bend link-time segment table merge object emitter (0 C)
  4. M2 (`research/agy/w10_mod_bend/m2_elf_vis/mod_elf_vis.bend`, reconciled with w9_elf_fast):
     - `STB_LOCAL` (`$p111.k.*`, `main`) + `STB_WEAK` (`P86Seed.book`) in `x86-module` (0 objcopy)
     - upgraded to use `w9_elf_fast`'s single-pass `w7c_elf_ascii_valid` / `w7c_elf_sym_nums_valid` / `w7c_elf_sym_push`
     - wired into both `w8_module_entry` (`x86-module`) and `--trace x86-module`
  5. M3 (`research/agy/w10_mod_bend/m3_iface_bend/iface_emit.bend`):
     - `x86-iface` pure-Bend `.p130` interface carrier emitter (0 JS)
"""
from __future__ import annotations

import importlib.util
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W8_SRC = ROOT / "selfhost/build/agy/wave8_unified/compiler.bend"
W10_DST = ROOT / "selfhost/build/agy/wave10_unified/compiler.bend"

M1_BEND = ROOT / "research/agy/w10_mod_bend/m1_merge_obj/merge_obj.bend"
M2_BEND = ROOT / "research/agy/w10_mod_bend/m2_elf_vis/mod_elf_vis.bend"
M3_BEND = ROOT / "research/agy/w10_mod_bend/m3_iface_bend/iface_emit.bend"


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    cnt = src.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return src.replace(old, new, 1)


def reconcile_m2_with_w9_elf_fast(m2_txt: str) -> str:
    """Upgrade M2's w10_elf_symbol_add & w10*_build_symbol_checked to use w9_elf_fast's single-pass helpers."""
    old_sym = """# Encode 24-byte Elf64_Sym with exact st_info = (bind << 4) | kind:
#   STB_LOCAL  = 0 -> 0
#   STB_GLOBAL = 1 -> 16
#   STB_WEAK   = 2 -> 32  (only for defined symbols in weak_set)
@unsafe
def w10_elf_symbol_bytes(symbol: X187Symbol, nameOffset: U32, +weak_set: KDef) -> List<&2,U32>:
  match symbol:
    case X187Symbol{+name,+section,value,size,+global,kind}:
      +bind : U32 = nt_choose(U32,global,
        u => nt_choose(U32,Bool.not(U32.is_eq(section,0)) && w10_is_weak_sym(weak_set,name),
          v => 32,
          v => 16),
        u => 0)
      x187_elf_cat(x187_elf_u32(nameOffset),
        Con{U32.add(kind,bind),Con{0,
          x187_elf_cat(x187_elf_u16(section),
            x187_elf_cat(x187_elf_u64(value,0),x187_elf_u64(size,0)))}})

@unsafe
def w10_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, +weak_set: KDef, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,section,value,size,global,kind}
      X187ElfSymbols{+index,+count,+firstGlobal,+table,+strings,+stringSize,+error}:
      +encoded = x187_elf_ascii(name,[])
      +length = U32.inc(nt_count(U32,encoded))
      nt_choose(X187ElfSymbols,String.is_empty(error) && x187_elf_symbol_valid(symbol,sizes) &&
          agy_str_eq(dk(p111v_get(index,name)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p111v_put(index,name,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          nt_reverse(U32,w10_elf_symbol_bytes(symbol,stringSize,weak_set),table),
          Con{0,x187_elf_cat(encoded,strings)},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})"""

    new_sym = """# Single-pass Elf64_Sym emitter reconciling w9_elf_fast (`w7c_elf_ascii_valid` +
# `w7c_elf_sym_nums_valid` + `w7c_elf_sym_push`) with M2 `STB_LOCAL`/`STB_GLOBAL`/`STB_WEAK`:
#   STB_LOCAL  = 0 -> 0
#   STB_GLOBAL = 1 -> 16
#   STB_WEAK   = 2 -> 32  (only for defined symbols in weak_set)
@unsafe
def w10_elf_sym_add_ascii(+name: String, +section: U32, +value: U32, +size: U32, +global: Bool, +kind: U32,
    +sizes: X187ElfSizes, +weak_set: KDef, +index: KDef, +count: U32, +firstGlobal: U32, +table: List<&2,U32>,
    +strings: List<&2,U32>, +stringSize: U32, +error: String, asc: W7cAscii) -> X187ElfSymbols:
  match asc:
    case W7cAscii{ok,+strBytes,+nlen}:
      +length = U32.inc(nlen)
      +bind : U32 = nt_choose(U32,global,
        u => nt_choose(U32,Bool.not(U32.is_eq(section,0)) && w10_is_weak_sym(weak_set,name),
          v => 32,
          v => 16),
        u => 0)
      nt_choose(X187ElfSymbols,ok && String.is_empty(error) &&
          w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes) &&
          agy_str_eq(dk(p111v_get(index,name)),"Absent") && U32.is_lt(count,1048576) &&
          U32.is_le(length,U32.sub(67108864,stringSize)),
        u => X187ElfSymbols{p111v_put(index,name,"X187Symbol",count,0),U32.inc(count),firstGlobal,
          w7c_elf_sym_push(stringSize,U32.add(kind,bind),section,value,size,table),
          Con{0,strBytes},U32.add(stringSize,length),""},
        u => X187ElfSymbols{index,count,firstGlobal,table,strings,stringSize,
          p111_first(error,"invalid or duplicate ELF symbol")})

@unsafe
def w10_elf_symbol_add(+symbol: X187Symbol, +sizes: X187ElfSizes, +weak_set: KDef, state: X187ElfSymbols) -> X187ElfSymbols:
  match symbol state:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}
      X187ElfSymbols{+index,+count,+firstGlobal,table,+strings,+stringSize,+error}:
      w10_elf_sym_add_ascii(name,section,value,size,global,kind,sizes,weak_set,index,count,firstGlobal,table,strings,stringSize,error,
        w7c_elf_ascii_valid(name,strings,0))"""

    m2_txt = replace_exact(m2_txt, old_sym, new_sym, "m2_w10_elf_symbol_add")

    old_chk1 = """@unsafe
def w10_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object, +weak_set: KDef) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>"""

    new_chk1 = """@unsafe
def w10_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object, +weak_set: KDef) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}:
      nt_choose(X187ObjectResult,w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes),u =>"""

    m2_txt = replace_exact(m2_txt, old_chk1, new_chk1, "m2_w10_build_symbol_checked")

    old_chk2 = """@unsafe
def w10_x202p_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object, +weak_set: KDef) -> IO(U32):
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(IO(U32),x187_elf_symbol_valid(symbol,sizes),u =>"""

    new_chk2 = """@unsafe
def w10_x202p_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object, +weak_set: KDef) -> IO(U32):
  match symbol:
    case X187Symbol{+name,+section,+value,+size,+global,+kind}:
      nt_choose(IO(U32),w7c_elf_sym_nums_valid(section,value,size,global,kind,sizes),u =>"""

    m2_txt = replace_exact(m2_txt, old_chk2, new_chk2, "m2_w10_x202p_build_symbol_checked")
    return m2_txt


def main() -> None:
    w9_str_hot = load_module("apply_w9_str_hot", ROOT / "research/agy/w9_str_hot/apply_w9_str_hot.py")
    w9_elf_fast = load_module("apply_w9_elf_fast", ROOT / "research/agy/w9_elf_fast/apply_w9_elf_fast.py")

    src = W8_SRC.read_text(encoding="utf-8")
    n0 = len(src)

    # 1. Apply w9_str_hot
    src, str_stats = w9_str_hot.apply_patch(src)
    n1 = len(src)
    print(f"[1/5] w9_str_hot applied: {n0:,} -> {n1:,} B ({str_stats})")

    # 2. Apply w9_elf_fast
    src = w9_elf_fast.apply_patch(src)
    n2 = len(src)
    print(f"[2/5] w9_elf_fast applied: {n1:,} -> {n2:,} B")

    # 3-5. Load M1, M2 (reconciled with w9_elf_fast), M3
    m1_txt = M1_BEND.read_text(encoding="utf-8").strip()
    m2_txt = reconcile_m2_with_w9_elf_fast(M2_BEND.read_text(encoding="utf-8").strip())
    m3_txt = M3_BEND.read_text(encoding="utf-8").strip()

    # Splice M1 + M2 + M3 right before w8_module_entry and hook w8_module_entry -> w10_module_request
    old_mod_entry = """@unsafe
def w8_module_entry(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, fid_base_m: Maybe<&2,U32>, +mod_name: String) -> IO(U32):
  match fid_base_m:
    case Some{+fid_base}:
      nt_choose(IO(U32),U32.is_lt(fid_base,65532) && Bool.not(String.is_empty(mod_name)),
        u => w8_module_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),fid_base,mod_name),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")"""

    new_mod_entry = (
        "\n# === WAVE 10 M1: Pure-Bend x86-merge-obj ===\n"
        + m1_txt
        + "\n\n# === WAVE 10 M2: Pure-Bend ELF64 Symbol Visibility (reconciled with w9_elf_fast) ===\n"
        + m2_txt
        + "\n\n# === WAVE 10 M3: Pure-Bend x86-iface ===\n"
        + m3_txt
        + "\n\n@unsafe\n"
        + """def w8_module_entry(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, fid_base_m: Maybe<&2,U32>, +mod_name: String) -> IO(U32):
  match fid_base_m:
    case Some{+fid_base}:
      nt_choose(IO(U32),U32.is_lt(fid_base,65532) && Bool.not(String.is_empty(mod_name)),
        u => w10_module_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),fid_base,mod_name),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")"""
    )

    src = replace_exact(src, old_mod_entry, new_mod_entry, "splice_m1_m2_m3_and_hook_w8_module_entry")
    print(f"[3-5/5] Spliced M1 + M2(reconciled) + M3: {n2:,} -> {len(src):,} B")

    # Hook --trace x86-module to also emit M2 ELF visibility (weak_set from P86Seed)
    old_tr_compile = """@unsafe
def w8_tr_compile_done(+trace: Bool, +t2: Nat, +t3: Nat, prepared: P169Prepared) -> IO(P169Prepared):
  match prepared:
    case P169Prepared{fw,+cur,+err}:
      do IO<P169Prepared>:
        +segs : U32 = w8_cursor_seg_count(cur)
        _ : Unit <- w8_tr_log(trace,"stage=x198pw_plan ms=" ++ w8_tr_ms(t2,t3) ++ " segs=" ++ U32.show(segs))
        IO.pure(P169Prepared,P169Prepared{fw,cur,err})

@unsafe
def w8_tr_compile_prep(+trace: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(P169Prepared):
  match prep:
    case P86PreparationError{error}:
      do IO<P169Prepared>:
        _ : Unit <- w8_tr_log(trace,"stage=prep_error msg=" ++ error)
        IO.pure(P169Prepared,p169s_fail(error))
    case P86PreparationReady{seed}:
      do IO<P169Prepared>:
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=p86_plan ms=" ++ w8_tr_ms(t1,t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared,x198pw_plan(plan))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(trace,t2,t3,prepared)

@unsafe
def w8_tr_compile(+trace: Bool, +path: String, +source: String, +base_path: String,
    +base: String, +carrier: String, +stamp: String, +cached: Bool) -> IO(P169Prepared):
  do IO<P169Prepared>:
    +t0 : Nat <- IO.now()
    +prep : P86Preparation <- IO.pure(P86Preparation,
      nt_choose(P86Preparation,cached,
        u => p88_cache_prepare(base_path,base,carrier,stamp),
        u => p86_prepare(base_path,base)))
    +t1 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=prep ms=" ++ w8_tr_ms(t0,t1))
    w8_tr_compile_prep(trace,path,source,t1,prep)

@unsafe
def w8_tr_emit_cursor(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w8_tr_emit_good(trace,fast,is_mod,t_start,cursor,avail,build,priv_n,pub_n,total_segs),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w8_tr_emit_priv(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +head: P113DFunction, rest: List<&2,P113DFunction>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)
    +n2 : U32 = U32.inc(priv_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,500),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_priv done=" ++ U32.show(n2) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Private{rest,ctx,next},avail,b2,n2,pub_n,total_segs)

@unsafe
def w8_tr_emit_pub(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +head: N111Segment, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => x181_program_public(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)
    +n2 : U32 = U32.inc(pub_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,2000),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_pub done=" ++ U32.show(n2) ++ "/" ++ U32.show(total_segs) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Public{rest,ctx,next},avail,b2,priv_n,n2,total_segs)

@unsafe
def w8_tr_emit_good(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_priv_done count=" ++ U32.show(priv_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Private{Con{head,rest},ctx,next}:
      w8_tr_emit_priv(trace,fast,is_mod,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Legacy{es,ctx,next}:
      w8_tr_emit_cursor(trace,fast,is_mod,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_pub_done count=" ++ U32.show(pub_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Con{head,rest},ctx,next}:
      w8_tr_emit_pub(trace,fast,is_mod,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Nil{}}:
      w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Main{},avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Con{head,rest}}:
      w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Tables{rest},avail,x187_output(x181_program_data(head,avail),build),priv_n,pub_n,total_segs)
    case P134Main{}:
      do IO<U32>:
        +t_elf0 : Nat <- IO.now()
        +b_fin : X187Build = nt_choose(X187Build,is_mod,u => build,u => x187_build_seq(x181_program_main(),build))
        +rc : U32 <- x202p_x201f_finish(b_fin)
        +t_elf1 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_elf ms=" ++ w8_tr_ms(t_elf0,t_elf1) ++ " total_ms=" ++ w8_tr_ms(t_start,t_elf1))
        IO.pure(U32,rc)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w8_tr_run_prepared(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +t0: Nat, prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{fw,+cursor,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => do IO<U32>:
          +avail : KDef = x181_cursor_index(cursor,missing())
          +segs : U32 = w8_cursor_seg_count(cursor)
          nt_choose(IO(U32),is_mod && U32.is_gt(U32.add(fid_base,segs),65532),
            v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"),
            v => do IO<U32>:
              +enr : P134Cursor = agy_enrich_cursor(cursor,avail)
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)
              w8_tr_emit_cursor(trace,fast,is_mod,t0,cur2,avail,x187_build_empty(),0,0,segs)),
        u => IO.die(U32,1,error))

@unsafe
def w8_tr_run_obj(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +path: String, +base_path: String, +carrier_path: String, +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"start src=" ++ path ++ nt_choose(String,is_mod,u => " mode=x86-module mod=" ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast",v => " mode=x86-object")))
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +t_rd : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=read ms=" ++ w8_tr_ms(t0,t_rd))
    +prepared : P169Prepared <- w8_tr_compile(trace,path,source,base_path,base,carrier,stamp,cached)
    w8_tr_run_prepared(trace,fast,is_mod,fid_base,mod_name,t0,prepared)"""

    new_tr_compile = """type W10TrCompiled is Data:
  W10TrCompiled{+prepared: P169Prepared, +weak_set: KDef}

@unsafe
def w8_tr_compile_done(+trace: Bool, +t2: Nat, +t3: Nat, prepared: P169Prepared, +weak_set: KDef) -> IO(W10TrCompiled):
  match prepared:
    case P169Prepared{fw,+cur,+err}:
      do IO<W10TrCompiled>:
        +segs : U32 = w8_cursor_seg_count(cur)
        _ : Unit <- w8_tr_log(trace,"stage=x198pw_plan ms=" ++ w8_tr_ms(t2,t3) ++ " segs=" ++ U32.show(segs))
        IO.pure(W10TrCompiled,W10TrCompiled{P169Prepared{fw,cur,err},weak_set})

@unsafe
def w8_tr_compile_prep(+trace: Bool, +is_mod: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(W10TrCompiled):
  match prep:
    case P86PreparationError{error}:
      do IO<W10TrCompiled>:
        _ : Unit <- w8_tr_log(trace,"stage=prep_error msg=" ++ error)
        IO.pure(W10TrCompiled,W10TrCompiled{p169s_fail(error),missing()})
    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_seed(seed),u => missing())
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=p86_plan ms=" ++ w8_tr_ms(t1,t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared,x198pw_plan(plan))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(trace,t2,t3,prepared,weak_set)

@unsafe
def w8_tr_compile(+trace: Bool, +is_mod: Bool, +path: String, +source: String, +base_path: String,
    +base: String, +carrier: String, +stamp: String, +cached: Bool) -> IO(W10TrCompiled):
  do IO<W10TrCompiled>:
    +t0 : Nat <- IO.now()
    +prep : P86Preparation <- IO.pure(P86Preparation,
      nt_choose(P86Preparation,cached,
        u => p88_cache_prepare(base_path,base,carrier,stamp),
        u => p86_prepare(base_path,base)))
    +t1 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=prep ms=" ++ w8_tr_ms(t0,t1))
    w8_tr_compile_prep(trace,is_mod,path,source,t1,prep)

@unsafe
def w8_tr_emit_cursor(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w8_tr_emit_good(trace,fast,is_mod,weak_set,t_start,cursor,avail,build,priv_n,pub_n,total_segs),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w8_tr_emit_priv(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: P113DFunction, rest: List<&2,P113DFunction>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)
    +n2 : U32 = U32.inc(priv_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,500),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_priv done=" ++ U32.show(n2) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Private{rest,ctx,next},avail,b2,n2,pub_n,total_segs)

@unsafe
def w8_tr_emit_pub(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: N111Segment, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => x181_program_public(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)
    +n2 : U32 = U32.inc(pub_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,2000),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_pub done=" ++ U32.show(n2) ++ "/" ++ U32.show(total_segs) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Public{rest,ctx,next},avail,b2,priv_n,n2,total_segs)

@unsafe
def w8_tr_emit_good(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_priv_done count=" ++ U32.show(priv_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Private{Con{head,rest},ctx,next}:
      w8_tr_emit_priv(trace,fast,is_mod,weak_set,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Legacy{es,ctx,next}:
      w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_pub_done count=" ++ U32.show(pub_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Con{head,rest},ctx,next}:
      w8_tr_emit_pub(trace,fast,is_mod,weak_set,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Nil{}}:
      w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Main{},avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Con{head,rest}}:
      w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t_start,P134Tables{rest},avail,x187_output(x181_program_data(head,avail),build),priv_n,pub_n,total_segs)
    case P134Main{}:
      do IO<U32>:
        +t_elf0 : Nat <- IO.now()
        +rc : U32 <- nt_choose(IO(U32),is_mod,
          u => w10_x202p_x201f_finish(build,weak_set),
          u => x202p_x201f_finish(x187_build_seq(x181_program_main(),build)))
        +t_elf1 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_elf ms=" ++ w8_tr_ms(t_elf0,t_elf1) ++ " total_ms=" ++ w8_tr_ms(t_start,t_elf1))
        IO.pure(U32,rc)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w8_tr_run_prepared(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +t0: Nat, compiled: W10TrCompiled) -> IO(U32):
  match compiled:
    case W10TrCompiled{P169Prepared{fw,+cursor,+error},+weak_set}:
      nt_choose(IO(U32),String.is_empty(error),
        u => do IO<U32>:
          +avail : KDef = x181_cursor_index(cursor,missing())
          +segs : U32 = w8_cursor_seg_count(cursor)
          nt_choose(IO(U32),is_mod && U32.is_gt(U32.add(fid_base,segs),65532),
            v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"),
            v => do IO<U32>:
              +enr : P134Cursor = agy_enrich_cursor(cursor,avail)
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)
              w8_tr_emit_cursor(trace,fast,is_mod,weak_set,t0,cur2,avail,x187_build_empty(),0,0,segs)),
        u => IO.die(U32,1,error))

@unsafe
def w8_tr_run_obj(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +path: String, +base_path: String, +carrier_path: String, +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"start src=" ++ path ++ nt_choose(String,is_mod,u => " mode=x86-module mod=" ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast",v => " mode=x86-object")))
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +t_rd : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=read ms=" ++ w8_tr_ms(t0,t_rd))
    +compiled : W10TrCompiled <- w8_tr_compile(trace,is_mod,path,source,base_path,base,carrier,stamp,cached)
    w8_tr_run_prepared(trace,fast,is_mod,fid_base,mod_name,t0,compiled)"""

    src = replace_exact(src, old_tr_compile, new_tr_compile, "hook_trace_x86_module_m2")

    # Wire x86-iface into x181_entry_args and x86-merge-obj into w8_dispatch_args
    old_entry = """@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86") || agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-object-fast"),
          v => x181_request_fast(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
          v => x181_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),agy_str_eq(program,"x86-object"))),
        u => IO.die(U32,2,"expected x86|x86-object|x86-object-fast, absolute input/Base paths and live|cache mode"))"""

    new_entry = """@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86") || agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast") || agy_str_eq(program,"x86-iface")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-iface"),
          v => w10_iface_request(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
          v => nt_choose(IO(U32),agy_str_eq(program,"x86-object-fast"),
            w => x181_request_fast(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
            w => x181_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),agy_str_eq(program,"x86-object")))),
        u => IO.die(U32,2,"expected x86|x86-object|x86-object-fast|x86-iface, absolute input/Base paths and live|cache mode"))"""

    src = replace_exact(src, old_entry, new_entry, "hook_x86_iface_dispatch")

    old_dispatch = """@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace"),
        u => w8_tr_entry(rest),
        u => x181_entry_args(Con{head,rest}))
    case Nil{}: x181_entry_args(Nil{})"""

    new_dispatch = """@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace"),
        u => w8_tr_entry(rest),
        u => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
          v => w10_merge_entry(rest),
          v => x181_entry_args(Con{head,rest})))
    case Nil{}: x181_entry_args(Nil{})"""

    src = replace_exact(src, old_dispatch, new_dispatch, "hook_x86_merge_obj_dispatch")

    # Assert all invariants
    for label, needle in [
        ("p111_cid_hot_data_guard", 'Bool.not(agy_str_eq(name,"p111_cid_hot"))'),
        ("elf_128mib_guard", "134217728"),
        ("w9_str_hot_sh_intrinsic", "def w9_is_sh_intrinsic("),
        ("w9_str_hot_private_fast", "def w9_private_fast_sh("),
        ("w9_elf_fast_sym_push", "def w7c_elf_sym_push("),
        ("w9_elf_fast_relocs_fused", "def w7c_relocs_fused("),
        ("m1_merge_entry", "def w10_merge_entry("),
        ("m2_elf_sym_add_ascii", "def w10_elf_sym_add_ascii("),
        ("m2_module_request", "def w10_module_request("),
        ("m3_iface_request", "def w10_iface_request("),
        ("w8_trace_emit_cursor", "def w8_tr_emit_cursor("),
    ]:
        assert needle in src, f"Invariant missing: {label} ({needle!r})"

    W10_DST.parent.mkdir(parents=True, exist_ok=True)
    W10_DST.write_text(src, encoding="utf-8")
    print(f"[DONE] Wrote {W10_DST} ({len(src):,} B)")


if __name__ == "__main__":
    main()
