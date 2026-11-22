#!/usr/bin/env python3
"""Apply Wave 8 per-module disjoint 16-bit FID base + module table export patch.

Usage:
  python3 research/agy/w8_fid_base/apply_w8_fid_base.py --src <in.bend> --dst <out.bend>

Adds CLI mode:
  x86-module ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP FID_BASE MOD_NAME

Behavior:
  - Validates 0 <= FID_BASE < 65532 and FID_BASE + segment_count <= 65532
    (preserving the 4 runtime-reserved FIDs at FID_IO_EMIT..FID_IO_EMIT+3).
  - Shifts all N111Ids.functions entries in every P134Context by +FID_BASE, so
    every emitted N111FuncId immediate / frame / closure / jump uses [FID_BASE, FID_BASE + N).
  - Exports per-module tables with prefix `p111_mod_<MOD_NAME>_`:
      * p111_mod_<MOD_NAME>_fid_base   (uint64_t)
      * p111_mod_<MOD_NAME>_program    (P111Program ABI11102 with shifted main_fid & table relocs)
      * p111_mod_<MOD_NAME>_segments   (void*[])
      * p111_mod_<MOD_NAME>_fid_arity  (uint8_t[])
      * p111_mod_<MOD_NAME>_fid_flags  (uint8_t[])
      * p111_mod_<MOD_NAME>_fid_results(uint8_t[])
  - Omits global `p111_program` and `main` so N separately-compiled `.o` modules
    link cleanly with the link-time merge stub (`p111_link_merge.c`).
  - Existing modes (`x86`, `x86-object`, `x86-object-fast`, `x86-shard`) are unchanged.
"""

import argparse
from pathlib import Path

ANCHOR_BEFORE_ENTRY = """@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):"""

W8_HELPERS = """# Wave 8: Per-module disjoint 16-bit FID base + link-time table merge exports.
@unsafe
def w8_shift_fids_bucket(bucket: List<&2,KDef>, +fid_base: U32) -> List<&2,KDef>:
  match bucket:
    case Nil{}: []
    case Con{head,rest}: Con{w8_shift_fids_tree(head,fid_base),w8_shift_fids_bucket(rest,fid_base)}

@unsafe
def w8_shift_fids_tree(+tree: KDef, +fid_base: U32) -> KDef:
  match tree:
    case KIndexLeaf{hash,bucket}: KIndexLeaf{hash,w8_shift_fids_bucket(bucket,fid_base)}
    case KIndexNode{hash,mask,left,right}:
      KIndexNode{hash,mask,w8_shift_fids_tree(left,fid_base),w8_shift_fids_tree(right,fid_base)}
    case KDef{name,+kind,cid,arity,typ,value,children,native,unsafe}:
      nt_choose(KDef,agy_str_eq(kind,"N111Id"),
        u => KDef{name,kind,U32.add(cid,fid_base),arity,typ,value,children,native,unsafe},
        u => KDef{name,kind,cid,arity,typ,value,w8_shift_fids_bucket(children,fid_base),native,unsafe})

@unsafe
def w8_relocate_context(ctx: P134Context, +fid_base: U32) -> P134Context:
  match ctx:
    case P134Context{N111Ids{fns,ctors},index,direct,ready,view,lookups,heap,mode}:
      P134Context{N111Ids{w8_shift_fids_tree(fns,fid_base),ctors},index,direct,ready,view,lookups,heap,mode}

@unsafe
def w8_patch_prog_item(+item: P111QDatum, +idx: U32, +fid_base: U32, +mod_name: String) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}:
      nt_choose(P111QDatum,U32.is_eq(idx,4),
        u => P111QLong{U32.add(lo,fid_base),hi},
        u => P111QLong{lo,hi})
    case P111QReloc{+sym,off}:
      nt_choose(P111QDatum,agy_str_eq(sym,"p111_segments") || agy_str_eq(sym,"p111_fid_arity") ||
          agy_str_eq(sym,"p111_fid_flags") || agy_str_eq(sym,"p111_fid_results"),
        u => P111QReloc{"p111_mod_" ++ mod_name ++ "_" ++ sym,off},
        u => P111QReloc{sym,off})
    case other: other

@unsafe
def w8_patch_prog_items(items: List<&2,P111QDatum>, +idx: U32, +fid_base: U32, +mod_name: String) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{head,rest}:
      Con{w8_patch_prog_item(head,idx,fid_base,mod_name),w8_patch_prog_items(rest,U32.inc(idx),fid_base,mod_name)}

@unsafe
def w8_relocate_table(data: P111QData, +fid_base: U32, +mod_name: String) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      nt_choose(P111QData,agy_str_eq(name,"p111_segments") || agy_str_eq(name,"p111_fid_arity") ||
          agy_str_eq(name,"p111_fid_flags") || agy_str_eq(name,"p111_fid_results"),
        u => P111QData{"p111_mod_" ++ mod_name ++ "_" ++ name,alignment,True{},items},
        u => nt_choose(P111QData,agy_str_eq(name,"p111_program"),
          v => P111QData{"p111_mod_" ++ mod_name ++ "_program",alignment,True{},
            w8_patch_prog_items(items,0,fid_base,mod_name)},
          v => P111QData{name,alignment,exported,items}))

@unsafe
def w8_relocate_tables(tables: List<&2,P111QData>, +fid_base: U32, +mod_name: String) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{head,rest}:
      Con{w8_relocate_table(head,fid_base,mod_name),w8_relocate_tables(rest,fid_base,mod_name)}

@unsafe
def w8_cursor_seg_count(cursor: P134Cursor) -> U32:
  match cursor:
    case P134Private{fns,ctx,next}: w8_cursor_seg_count(next)
    case P134Legacy{es,ctx,next}: w8_cursor_seg_count(next)
    case P134Public{segs,ctx,next}: nt_count(N111Segment,segs)
    case _: 0

@unsafe
def w8_relocate_cursor(cursor: P134Cursor, +fid_base: U32, +mod_name: String) -> P134Cursor:
  match cursor:
    case P134Private{fns,ctx,next}:
      P134Private{fns,w8_relocate_context(ctx,fid_base),w8_relocate_cursor(next,fid_base,mod_name)}
    case P134Legacy{es,ctx,next}:
      P134Legacy{es,w8_relocate_context(ctx,fid_base),w8_relocate_cursor(next,fid_base,mod_name)}
    case P134Public{segs,ctx,next}:
      P134Public{segs,w8_relocate_context(ctx,fid_base),w8_relocate_cursor(next,fid_base,mod_name)}
    case P134Tables{tables}:
      P134Tables{Con{P111QData{"p111_mod_" ++ mod_name ++ "_fid_base",8,True{},[P111QLong{fid_base,0}]},
        w8_relocate_tables(tables,fid_base,mod_name)}}
    case other: other

@unsafe
def w8_module_cursor(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w8_module_cursor_good(cursor,available,build),u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w8_module_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: w8_module_cursor(next,available,build)
    case P134Private{Con{head,rest},+context,next}:
      w8_module_cursor(P134Private{rest,context,next},available,x187_output(x181_program_private(head,context,available),build))
    case P134Legacy{entries,context,next}: w8_module_cursor(next,available,build)
    case P134Public{Nil{},context,next}: w8_module_cursor(next,available,build)
    case P134Public{Con{head,rest},+context,next}:
      w8_module_cursor(P134Public{rest,context,next},available,x187_output(x181_program_public(head,context,available),build))
    case P134Tables{Nil{}}: w8_module_cursor(P134Main{},available,build)
    case P134Tables{Con{head,rest}}:
      w8_module_cursor(P134Tables{rest},available,x187_output(x181_program_data(head,available),build))
    case P134Main{}: x202p_x201f_finish(build)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w8_module_prepared(+prepared: P169Prepared, +fid_base: U32, +mod_name: String) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      +seg_count = w8_cursor_seg_count(cursor)
      nt_choose(IO(U32),String.is_empty(error),
        u => nt_choose(IO(U32),U32.is_le(U32.add(fid_base,seg_count),65532),
          v => w8_module_cursor(w8_relocate_cursor(agy_enrich_cursor(cursor,avail),fid_base,mod_name),avail,x187_build_empty()),
          v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)")),
        u => IO.die(U32,1,error))

@unsafe
def w8_module_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +fid_base: U32, +mod_name: String) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        w8_module_prepared(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),fid_base,mod_name),
      u => w8_module_prepared(x198pw_compile(path,source,base_path,base,"",stamp,False{}),fid_base,mod_name))

@unsafe
def w8_module_entry(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, fid_base_m: Maybe<&2,U32>, +mod_name: String) -> IO(U32):
  match fid_base_m:
    case Some{+fid_base}:
      nt_choose(IO(U32),U32.is_lt(fid_base,65532) && Bool.not(String.is_empty(mod_name)),
        u => w8_module_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),fid_base,mod_name),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")

@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):"""

OLD_8ARG_ARM = """    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-shard")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-shard"),
          v => agy_lpt_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
          v => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s))),
        u => IO.die(U32,2,"expected x86-object|x86-shard, absolute input/Base paths, live|cache mode, and shard/shards"))
    case _: IO.die(U32,2,"usage: x86|x86-object|x86-shard ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS]")"""

NEW_8ARG_ARM = """    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
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


def apply_patch(src: Path, dst: Path) -> None:
    text = src.read_text(encoding="utf-8")
    if ANCHOR_BEFORE_ENTRY not in text:
        raise SystemExit(f"anchor not found: x181_entry_args in {src}")
    if text.count(ANCHOR_BEFORE_ENTRY) != 1:
        raise SystemExit(f"expected exactly 1 occurrence of x181_entry_args in {src}")
    if OLD_8ARG_ARM not in text:
        raise SystemExit(f"anchor not found: 8-arg arm in {src}")
    if text.count(OLD_8ARG_ARM) != 1:
        raise SystemExit(f"expected exactly 1 occurrence of 8-arg arm in {src}")

    patched = text.replace(ANCHOR_BEFORE_ENTRY, W8_HELPERS, 1)
    patched = patched.replace(OLD_8ARG_ARM, NEW_8ARG_ARM, 1)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(patched, encoding="utf-8")
    print(f"w8_fid_base: patched {src} -> {dst} (+{len(patched.splitlines()) - len(text.splitlines())} lines)")


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply W8 per-module FID base patch")
    ap.add_argument("--src", required=True, type=Path)
    ap.add_argument("--dst", required=True, type=Path)
    args = ap.parse_args()
    apply_patch(args.src, args.dst)


if __name__ == "__main__":
    main()
