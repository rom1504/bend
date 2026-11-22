#!/usr/bin/env python3
"""Composable Wave 3B Track B3 patcher: Parallel Sharded x86 Codegen & ELF Emission.

Adds:
  1. Hosted JS/API sharded codegen:
       - agy_parcg_prepare_cursor(prepared) -> AgyParCgReady
       - agy_parcg_emit_shard(ready, shard, shards) -> X187ObjectResult
       - x187_prepared_shard(prepared, shard, shards) -> X187ObjectResult
  2. Native CLI sharded codegen:
       - x202p_x187_prepared_shard(prepared, shard, shards) -> IO(U32)
       - 8-arg CLI form in x181_entry_args:
           x86-object ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP SHARD SHARDS
  3. Zero behavioral change when shards <= 1 (calls original x187_prepared / x202p_x187_prepared).
  4. When shards > 1:
       - Round-robin shards P134Private and P134Public functions across 0..shards-1
       - Emits P134Tables and P134Main only on shard 0
       - Promotes all defined non-'.L' symbols to STB_GLOBAL so ld resolves cross-shard
         calls and data/table references natively, while '.L' local labels stay STB_LOCAL
         and are patched intra-shard by x188_fixup_scan.

Usage:
  python3 -B research/agy/wave3b_parcg/apply_parcg.py <src_compiler.bend> <dst_compiler.bend>
"""
import sys
from pathlib import Path

MARKER = "# === AGY-W3B-PARCG ==="

PARCG_BLOCK = r'''
# === AGY-W3B-PARCG ===
type AgyParCgReady is Data:
  AgyParCgReady{+cursor: P134Cursor, +available: KDef, +error: String}

law agy_parcg_build_symbols:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for +object: X187Object
  X187ObjectResult

@unsafe
def agy_parcg_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>
        agy_parcg_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              String.eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})

@unsafe
def agy_parcg_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        agy_parcg_build_symbol_checked(
          X187Symbol{name,section,value,size,global || Bool.not(defined) || Bool.not(String.starts_with(name,".L")),kind},
          rest,index,escaped,sizes,acc,object))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def agy_parcg_build_symbols(names, index, escaped, sizes, acc, object):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: agy_parcg_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def agy_parcg_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> X187ObjectResult:
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => agy_parcg_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => X187ObjectResult{[],error})

@unsafe
def agy_parcg_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> X187ObjectResult:
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        agy_parcg_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => X187ObjectResult{[],error})

@unsafe
def agy_parcg_finish(+build: X187Build) -> X187ObjectResult:
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,x188_symbol_count(names,0,1),v =>
          agy_parcg_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => X187ObjectResult{[],"invalid or duplicate ELF symbol"}),
        u => X187ObjectResult{[],error})

def agy_parcg_next_rem(+rem: U32, +shards: U32) -> U32:
  +nxt = U32.inc(rem)
  nt_choose(U32,U32.is_eq(nxt,shards),u => 0,u => nxt)

law agy_parcg_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +shard: U32
  for +shards: U32
  for +rem: U32
  X187ObjectResult

@unsafe
def agy_parcg_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build,
    +shard: U32, +shards: U32, +rem: U32) -> X187ObjectResult:
  match cursor:
    case P134Private{Nil{},context,next}: agy_parcg_cursor(next,available,build,shard,shards,0)
    case P134Private{Con{head,rest},+context,next}:
      agy_parcg_cursor(P134Private{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_private(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Legacy{entries,context,next}: agy_parcg_cursor(next,available,build,shard,shards,0)
    case P134Public{Nil{},context,next}: agy_parcg_cursor(next,available,build,shard,shards,0)
    case P134Public{Con{head,rest},+context,next}:
      agy_parcg_cursor(P134Public{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_public(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Tables{Nil{}}: agy_parcg_cursor(P134Main{},available,build,shard,shards,0)
    case P134Tables{Con{head,rest}}:
      nt_choose(X187ObjectResult,U32.is_eq(shard,0),
        u => agy_parcg_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),shard,shards,0),
        u => agy_parcg_cursor(P134Main{},available,build,shard,shards,0))
    case P134Main{}:
      nt_choose(X187ObjectResult,U32.is_eq(shard,0),
        u => agy_parcg_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_finish(build))
    case _: X187ObjectResult{[],"incomplete object cursor"}

@unsafe
def agy_parcg_cursor(cursor, available, build, shard, shards, rem):
  nt_choose(X187ObjectResult,String.is_empty(x187_build_message(build)),
    u => agy_parcg_cursor_good(cursor,available,build,shard,shards,rem),
    u => X187ObjectResult{[],x187_build_message(build)})

@unsafe
def agy_parcg_prepare_cursor(+prepared: P169Prepared) -> AgyParCgReady:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(AgyParCgReady,String.is_empty(error),u =>
        AgyParCgReady{agy_enrich_cursor(cursor,x181_cursor_index(cursor,missing())),x181_cursor_index(cursor,missing()),""},
        u => AgyParCgReady{cursor,missing(),error})

@unsafe
def agy_parcg_emit_shard(+ready: AgyParCgReady, +shard: U32, +shards: U32) -> X187ObjectResult:
  match ready:
    case AgyParCgReady{+cursor,+available,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u =>
        nt_choose(X187ObjectResult,U32.is_le(shards,1),
          v => x187_cursor(cursor,available,x187_build_empty()),
          v => agy_parcg_cursor(cursor,available,x187_build_empty(),shard,shards,0)),
        u => X187ObjectResult{[],error})

@unsafe
def x187_prepared_shard(+prepared: P169Prepared, +shard: U32, +shards: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(shards,1),
    u => x187_prepared(prepared),
    u => agy_parcg_emit_shard(agy_parcg_prepare_cursor(prepared),shard,shards))

law agy_parcg_native_build_symbols:
  for +names: List<&2,String>
  for +index: KDef
  for +escaped: KDef
  for +sizes: X187ElfSizes
  for +acc: List<&2,X187Symbol>
  for +object: X187Object
  IO(U32)

@unsafe
def agy_parcg_native_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> IO(U32):
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(IO(U32),x187_elf_symbol_valid(symbol,sizes),u =>
        agy_parcg_native_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              String.eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => IO.die(U32,1,"invalid or duplicate ELF symbol"))

@unsafe
def agy_parcg_native_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> IO(U32):
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(IO(U32),Bool.not(defined) && String.starts_with(name,".L"),
        u => IO.die(U32,1,"undefined local label: " ++ name),u =>
        agy_parcg_native_build_symbol_checked(
          X187Symbol{name,section,value,size,global || Bool.not(defined) || Bool.not(String.starts_with(name,".L")),kind},
          rest,index,escaped,sizes,acc,object))
    case _: IO.die(U32,1,"invalid final object symbol")

@unsafe
def agy_parcg_native_build_symbols(names, index, escaped, sizes, acc, object):
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x202p_x187_elf(X187Object{text,rodata,data,acc,relocations})
    case Con{+name,rest}: agy_parcg_native_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def agy_parcg_native_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> IO(U32):
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => agy_parcg_native_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => IO.die(U32,1,error))

@unsafe
def agy_parcg_native_fixups(names: List<&2,String>, index: KDef, +sizes: X187ElfSizes,
    +raw: List<&2,U32>, rodata: List<&2,U32>, data: List<&2,U32>, state: X188Fixups) -> IO(U32):
  match sizes state:
    case X187ElfSizes{+ts,rs,ds} X188Fixups{+patches,relocations,escaped,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        agy_parcg_native_build_patched(names,index,escaped,sizes,rodata,data,relocations,
          x201f_selected(raw,patches,ts,x201f_plan(patches,ts,0,[]))),u => IO.die(U32,1,error))

@unsafe
def agy_parcg_native_finish(+build: X187Build) -> IO(U32):
  match build:
    case X187Build{s,t,r,d,+ts,rs,ds,+symbols,+names,relocs,+error}:
      nt_choose(IO(U32),String.is_empty(error),u =>
        nt_choose(IO(U32),x188_symbol_count(names,0,1),v =>
          agy_parcg_native_fixups(names,symbols,X187ElfSizes{ts,rs,ds},t,nt_reverse(U32,r,[]),nt_reverse(U32,d,[]),
            x188_fixup_scan(relocs,symbols,ts,0,X188Fixups{[],[],missing(),""})),
          v => IO.die(U32,1,"invalid or duplicate ELF symbol")),
        u => IO.die(U32,1,error))

law agy_parcg_native_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +shard: U32
  for +shards: U32
  for +rem: U32
  IO(U32)

@unsafe
def agy_parcg_native_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build,
    +shard: U32, +shards: U32, +rem: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: agy_parcg_native_cursor(next,available,build,shard,shards,0)
    case P134Private{Con{head,rest},+context,next}:
      agy_parcg_native_cursor(P134Private{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_private(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Legacy{entries,context,next}: agy_parcg_native_cursor(next,available,build,shard,shards,0)
    case P134Public{Nil{},context,next}: agy_parcg_native_cursor(next,available,build,shard,shards,0)
    case P134Public{Con{head,rest},+context,next}:
      agy_parcg_native_cursor(P134Public{rest,context,next},available,
        nt_choose(X187Build,U32.is_eq(rem,shard),u => x187_output(x181_program_public(head,context,available),build),u => build),
        shard,shards,agy_parcg_next_rem(rem,shards))
    case P134Tables{Nil{}}: agy_parcg_native_cursor(P134Main{},available,build,shard,shards,0)
    case P134Tables{Con{head,rest}}:
      nt_choose(IO(U32),U32.is_eq(shard,0),
        u => agy_parcg_native_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build),shard,shards,0),
        u => agy_parcg_native_cursor(P134Main{},available,build,shard,shards,0))
    case P134Main{}:
      nt_choose(IO(U32),U32.is_eq(shard,0),
        u => agy_parcg_native_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_native_finish(build))
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def agy_parcg_native_cursor(cursor, available, build, shard, shards, rem):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => agy_parcg_native_cursor_good(cursor,available,build,shard,shards,rem),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def agy_parcg_native_prepared(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(IO(U32),String.is_empty(error),
        v => agy_parcg_native_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty(),shard,shards,0),
        v => IO.die(U32,1,error))

@unsafe
def x202p_x187_prepared_shard(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(shards,1),
    u => x202p_x187_prepared(prepared),
    u => agy_parcg_native_prepared(prepared,shard,shards))

@unsafe
def agy_parcg_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +shard: U32, +shards: U32) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x202p_x187_prepared_shard(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),shard,shards),
      u => x202p_x187_prepared_shard(x198pw_compile(path,source,base_path,base,"",stamp,False{}),shard,shards))

@unsafe
def agy_parcg_entry_shard(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, shard_m: Maybe<&2,U32>, shards_m: Maybe<&2,U32>) -> IO(U32):
  match shard_m shards_m:
    case Some{+shard} Some{+shards}:
      nt_choose(IO(U32),U32.is_ge(shards,1) && U32.is_lt(shard,shards),
        u => agy_parcg_request(path,base,carrier,stamp,String.eq(mode,"cache"),shard,shards),
        u => IO.die(U32,2,"expected 0 <= shard < shards and shards >= 1"))
    case _ _: IO.die(U32,2,"expected U32 shard and shards arguments")
'''

OLD_ENTRY = '''@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(String.eq(program,"x86") || String.eq(program,"x86-object")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => x181_request(path,base,carrier,stamp,String.eq(mode,"cache"),String.eq(program,"x86-object")),
        u => IO.die(U32,2,"expected x86|x86-object, absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: x86|x86-object ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP")'''

NEW_ENTRY = PARCG_BLOCK + '''
@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(String.eq(program,"x86") || String.eq(program,"x86-object")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => x181_request(path,base,carrier,stamp,String.eq(mode,"cache"),String.eq(program,"x86-object")),
        u => IO.die(U32,2,"expected x86|x86-object, absolute input/Base paths and live|cache mode"))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"x86-object") && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
        u => IO.die(U32,2,"expected x86-object, absolute input/Base paths, live|cache mode, and shard/shards"))
    case _: IO.die(U32,2,"usage: x86|x86-object ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS]")'''


def main():
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <src_compiler.bend> <dst_compiler.bend>", file=sys.stderr)
        sys.exit(2)
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    text = src.read_text()
    if MARKER in text:
        print(f"[apply_parcg] already patched: {src}")
        dst.write_text(text)
        return
    if OLD_ENTRY not in text:
        raise RuntimeError("Could not find x181_entry_args anchor in compiler.bend")
    patched = text.replace(OLD_ENTRY, NEW_ENTRY, 1)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(patched)
    print(f"[apply_parcg] wrote {dst} ({len(patched)} bytes, +{len(patched)-len(text)} bytes)")


if __name__ == "__main__":
    main()
