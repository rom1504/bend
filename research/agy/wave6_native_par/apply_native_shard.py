#!/usr/bin/env python3
"""Apply Wave 6 Native LPT Sharding (`x86-shard`) patch to a copy of compiler.bend.

Adds deterministic Longest-Processing-Time (LPT) weight-balanced native sharding
as the `x86-shard` CLI subcommand alongside existing `x86-object ... [SHARD SHARDS]`:

  x86-shard ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP SHARD SHARDS

Every worker independently computes exact IR statement weights for `P134Private`
and `P134Public`, sorts descending (deterministic merge sort), greedily assigns
each item to the lightest shard bucket, emits ONLY the items assigned to `SHARD`,
and assigns `P134Tables` + `P134Main` to whichever shard has the minimum total
load after packing (preventing shard 0 stragglers).

NEVER modifies `selfhost/build/agy/wave5c_unified/` in place — always writes to `--out`.
"""
import argparse
from pathlib import Path

PATCH_MARKER = "# === AGY-W6-NATIVE-LPT-SHARD ==="

LPT_CODE = r"""
# === AGY-W6-NATIVE-LPT-SHARD ===
type AgyLptPriv is Data:
  AgyLptPriv{+weight: U32, +item: P113DFunction}

type AgyLptPub is Data:
  AgyLptPub{+weight: U32, +item: N111Segment}

type AgyLptPrivSplit is Data:
  AgyLptPrivSplit{+left: List<&2,AgyLptPriv>, +right: List<&2,AgyLptPriv>}

type AgyLptPubSplit is Data:
  AgyLptPubSplit{+left: List<&2,AgyLptPub>, +right: List<&2,AgyLptPub>}

type AgyLptPrivOut is Data:
  AgyLptPrivOut{+build: X187Build, +loads: List<&2,U32>}

law agy_lpt_n111_list:
  for +stmts: List<&2,N111Stmt>
  for +acc: U32
  U32

@unsafe
def agy_lpt_n111_stmt(+stmt: N111Stmt, +acc: U32) -> U32:
  match stmt:
    case N111If{c,yes,no}: agy_lpt_n111_list(no,agy_lpt_n111_list(yes,U32.add(acc,2)))
    case _: U32.add(acc,1)

@unsafe
def agy_lpt_n111_list(stmts, acc):
  match stmts:
    case Nil{}: acc
    case Con{head,rest}: agy_lpt_n111_list(rest,agy_lpt_n111_stmt(head,acc))

law agy_lpt_p113_list:
  for +stmts: List<&2,P113DStmt>
  for +acc: U32
  U32

@unsafe
def agy_lpt_p113_stmt(+stmt: P113DStmt, +acc: U32) -> U32:
  match stmt:
    case P113DScalar{s}: agy_lpt_n111_stmt(s,acc)
    case P113DIf{c,yes,no}: agy_lpt_p113_list(no,agy_lpt_p113_list(yes,U32.add(acc,2)))
    case _: U32.add(acc,1)

@unsafe
def agy_lpt_p113_list(stmts, acc):
  match stmts:
    case Nil{}: acc
    case Con{head,rest}: agy_lpt_p113_list(rest,agy_lpt_p113_stmt(head,acc))

@unsafe
def agy_lpt_priv_weight(+fn: P113DFunction) -> U32:
  match fn:
    case P113DFunction{n,p,r,pub,body}: U32.add(1,agy_lpt_p113_list(body,0))

@unsafe
def agy_lpt_pub_weight(+seg: N111Segment) -> U32:
  match seg:
    case N111Segment{n,a,r,inc,fl,body}: U32.add(1,agy_lpt_n111_list(body,0))

@unsafe
def agy_lpt_zero_loads(+n: U32, +acc: List<&2,U32>) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(n,0),u => acc,u => agy_lpt_zero_loads(U32.sub(n,1),Con{0,acc}))

@unsafe
def agy_lpt_min_idx_go(+loads: List<&2,U32>, +idx: U32, +best_idx: U32, +best_val: U32) -> U32:
  match loads:
    case Nil{}: best_idx
    case Con{+v,rest}:
      nt_choose(U32,U32.is_lt(v,best_val),
        u => agy_lpt_min_idx_go(rest,U32.add(idx,1),idx,v),
        u => agy_lpt_min_idx_go(rest,U32.add(idx,1),best_idx,best_val))

@unsafe
def agy_lpt_min_idx(+loads: List<&2,U32>) -> U32:
  match loads:
    case Nil{}: 0
    case Con{+v,rest}: agy_lpt_min_idx_go(rest,1,0,v)

@unsafe
def agy_lpt_add_load(+loads: List<&2,U32>, +target: U32, +delta: U32) -> List<&2,U32>:
  match loads:
    case Nil{}: []
    case Con{+v,rest}:
      nt_choose(List<&2,U32>,U32.is_eq(target,0),
        u => Con{U32.add(v,delta),rest},
        u => Con{v,agy_lpt_add_load(rest,U32.sub(target,1),delta)})

@unsafe
def agy_lpt_priv_wrap(+fns: List<&2,P113DFunction>, +acc: List<&2,AgyLptPriv>) -> List<&2,AgyLptPriv>:
  match fns:
    case Nil{}: acc
    case Con{+head,rest}: agy_lpt_priv_wrap(rest,Con{AgyLptPriv{agy_lpt_priv_weight(head),head},acc})

@unsafe
def agy_lpt_priv_split(+xs: List<&2,AgyLptPriv>, +a: List<&2,AgyLptPriv>, +b: List<&2,AgyLptPriv>) -> AgyLptPrivSplit:
  match xs:
    case Nil{}: AgyLptPrivSplit{a,b}
    case Con{x,Nil{}}: AgyLptPrivSplit{Con{x,a},b}
    case Con{x,Con{y,rest}}: agy_lpt_priv_split(rest,Con{x,a},Con{y,b})

@unsafe
def agy_lpt_priv_merge(+a: List<&2,AgyLptPriv>, +b: List<&2,AgyLptPriv>) -> List<&2,AgyLptPriv>:
  match a b:
    case Nil{} _: b
    case _ Nil{}: a
    case Con{AgyLptPriv{+wa,+ia},ra} Con{AgyLptPriv{+wb,+ib},rb}:
      nt_choose(List<&2,AgyLptPriv>,U32.is_ge(wa,wb),
        u => Con{AgyLptPriv{wa,ia},agy_lpt_priv_merge(ra,Con{AgyLptPriv{wb,ib},rb})},
        u => Con{AgyLptPriv{wb,ib},agy_lpt_priv_merge(Con{AgyLptPriv{wa,ia},ra},rb)})

law agy_lpt_priv_sort:
  for +xs: List<&2,AgyLptPriv>
  List<&2,AgyLptPriv>

@unsafe
def agy_lpt_priv_sort_split(sp: AgyLptPrivSplit) -> List<&2,AgyLptPriv>:
  match sp:
    case AgyLptPrivSplit{l,r}: agy_lpt_priv_merge(agy_lpt_priv_sort(l),agy_lpt_priv_sort(r))

@unsafe
def agy_lpt_priv_sort(xs):
  match xs:
    case Nil{}: []
    case Con{x,Nil{}}: Con{x,[]}
    case _: agy_lpt_priv_sort_split(agy_lpt_priv_split(xs,[],[]))

@unsafe
def agy_lpt_pub_wrap(+segs: List<&2,N111Segment>, +acc: List<&2,AgyLptPub>) -> List<&2,AgyLptPub>:
  match segs:
    case Nil{}: acc
    case Con{+head,rest}: agy_lpt_pub_wrap(rest,Con{AgyLptPub{agy_lpt_pub_weight(head),head},acc})

@unsafe
def agy_lpt_pub_split(+xs: List<&2,AgyLptPub>, +a: List<&2,AgyLptPub>, +b: List<&2,AgyLptPub>) -> AgyLptPubSplit:
  match xs:
    case Nil{}: AgyLptPubSplit{a,b}
    case Con{x,Nil{}}: AgyLptPubSplit{Con{x,a},b}
    case Con{x,Con{y,rest}}: agy_lpt_pub_split(rest,Con{x,a},Con{y,b})

@unsafe
def agy_lpt_pub_merge(+a: List<&2,AgyLptPub>, +b: List<&2,AgyLptPub>) -> List<&2,AgyLptPub>:
  match a b:
    case Nil{} _: b
    case _ Nil{}: a
    case Con{AgyLptPub{+wa,+ia},ra} Con{AgyLptPub{+wb,+ib},rb}:
      nt_choose(List<&2,AgyLptPub>,U32.is_ge(wa,wb),
        u => Con{AgyLptPub{wa,ia},agy_lpt_pub_merge(ra,Con{AgyLptPub{wb,ib},rb})},
        u => Con{AgyLptPub{wb,ib},agy_lpt_pub_merge(Con{AgyLptPub{wa,ia},ra},rb)})

law agy_lpt_pub_sort:
  for +xs: List<&2,AgyLptPub>
  List<&2,AgyLptPub>

@unsafe
def agy_lpt_pub_sort_split(sp: AgyLptPubSplit) -> List<&2,AgyLptPub>:
  match sp:
    case AgyLptPubSplit{l,r}: agy_lpt_pub_merge(agy_lpt_pub_sort(l),agy_lpt_pub_sort(r))

@unsafe
def agy_lpt_pub_sort(xs):
  match xs:
    case Nil{}: []
    case Con{x,Nil{}}: Con{x,[]}
    case _: agy_lpt_pub_sort_split(agy_lpt_pub_split(xs,[],[]))

@unsafe
def agy_lpt_emit_priv(+xs: List<&2,AgyLptPriv>, +context: P134Context, +available: KDef,
    +build: X187Build, +loads: List<&2,U32>, +shard: U32) -> AgyLptPrivOut:
  match xs:
    case Nil{}: AgyLptPrivOut{build,loads}
    case Con{AgyLptPriv{+w,item},rest}:
      nt_choose(AgyLptPrivOut,String.is_empty(x187_build_message(build)),u =>
        agy_lpt_emit_priv_step(w,item,rest,context,available,build,loads,shard,agy_lpt_min_idx(loads)),
        u => AgyLptPrivOut{build,loads})

@unsafe
def agy_lpt_emit_priv_step(+w: U32, item: P113DFunction, rest: List<&2,AgyLptPriv>, +context: P134Context,
    +available: KDef, +build: X187Build, +loads: List<&2,U32>, +shard: U32, +bucket: U32) -> AgyLptPrivOut:
  agy_lpt_emit_priv(rest,context,available,
    nt_choose(X187Build,U32.is_eq(bucket,shard),u => x187_output(x181_program_private(item,context,available),build),u => build),
    agy_lpt_add_load(loads,bucket,w),shard)

@unsafe
def agy_lpt_emit_pub(+xs: List<&2,AgyLptPub>, +context: P134Context, +available: KDef,
    +build: X187Build, +loads: List<&2,U32>, +shard: U32) -> AgyLptPrivOut:
  match xs:
    case Nil{}: AgyLptPrivOut{build,loads}
    case Con{AgyLptPub{+w,item},rest}:
      nt_choose(AgyLptPrivOut,String.is_empty(x187_build_message(build)),u =>
        agy_lpt_emit_pub_step(w,item,rest,context,available,build,loads,shard,agy_lpt_min_idx(loads)),
        u => AgyLptPrivOut{build,loads})

@unsafe
def agy_lpt_emit_pub_step(+w: U32, item: N111Segment, rest: List<&2,AgyLptPub>, +context: P134Context,
    +available: KDef, +build: X187Build, +loads: List<&2,U32>, +shard: U32, +bucket: U32) -> AgyLptPrivOut:
  agy_lpt_emit_pub(rest,context,available,
    nt_choose(X187Build,U32.is_eq(bucket,shard),u => x187_output(x181_program_public(item,context,available),build),u => build),
    agy_lpt_add_load(loads,bucket,w),shard)

law agy_lpt_native_cursor:
  for +cursor: P134Cursor
  for +available: KDef
  for +build: X187Build
  for +loads: List<&2,U32>
  for +shard: U32
  for +table_shard: U32
  IO(U32)

@unsafe
def agy_lpt_cursor_after(+next: P134Cursor, +available: KDef, +shard: U32, +table_shard: U32, out: AgyLptPrivOut) -> IO(U32):
  match out:
    case AgyLptPrivOut{build,loads}: agy_lpt_native_cursor(next,available,build,loads,shard,table_shard)

@unsafe
def agy_lpt_native_cursor_good(+cursor: P134Cursor, +available: KDef, +build: X187Build,
    +loads: List<&2,U32>, +shard: U32, +table_shard: U32) -> IO(U32):
  match cursor:
    case P134Private{fns,+context,next}:
      agy_lpt_cursor_after(next,available,shard,table_shard,
        agy_lpt_emit_priv(agy_lpt_priv_sort(agy_lpt_priv_wrap(fns,[])),context,available,build,loads,shard))
    case P134Legacy{entries,context,next}: agy_lpt_native_cursor(next,available,build,loads,shard,table_shard)
    case P134Public{segs,+context,next}:
      agy_lpt_cursor_after(next,available,shard,table_shard,
        agy_lpt_emit_pub(agy_lpt_pub_sort(agy_lpt_pub_wrap(segs,[])),context,available,build,loads,shard))
    case P134Tables{Nil{}}: agy_lpt_native_cursor(P134Main{},available,build,loads,shard,agy_lpt_min_idx(loads))
    case P134Tables{Con{head,rest}}:
      agy_lpt_tables_step(head,rest,available,build,loads,shard,agy_lpt_min_idx(loads))
    case P134Main{}:
      nt_choose(IO(U32),U32.is_eq(shard,table_shard),
        u => agy_parcg_native_finish(x187_build_seq(x181_program_main(),build)),
        u => agy_parcg_native_finish(build))
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def agy_lpt_tables_go(+tables: List<&2,P111QData>, +available: KDef, +build: X187Build,
    +loads: List<&2,U32>, +shard: U32, +owner: U32) -> IO(U32):
  match tables:
    case Nil{}: agy_lpt_native_cursor(P134Main{},available,build,loads,shard,owner)
    case Con{head,rest}:
      nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
        u => agy_lpt_tables_go(rest,available,x187_output(x181_program_data(head,available),build),loads,shard,owner),
        u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def agy_lpt_tables_step(head: P111QData, rest: List<&2,P111QData>, +available: KDef, +build: X187Build,
    +loads: List<&2,U32>, +shard: U32, +owner: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_eq(shard,owner),
    u => agy_lpt_tables_go(rest,available,x187_output(x181_program_data(head,available),build),loads,shard,owner),
    u => agy_lpt_native_cursor(P134Main{},available,build,loads,shard,owner))

@unsafe
def agy_lpt_native_cursor(cursor, available, build, loads, shard, table_shard):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => agy_lpt_native_cursor_good(cursor,available,build,loads,shard,table_shard),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def agy_lpt_native_prepared(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(IO(U32),String.is_empty(error),
        v => agy_lpt_native_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty(),agy_lpt_zero_loads(shards,[]),shard,0),
        v => IO.die(U32,1,error))

@unsafe
def agy_lpt_prepared_shard(+prepared: P169Prepared, +shard: U32, +shards: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(shards,1),
    u => x202p_x187_prepared(prepared),
    u => agy_lpt_native_prepared(prepared,shard,shards))

@unsafe
def agy_lpt_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +shard: U32, +shards: U32) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        agy_lpt_prepared_shard(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),shard,shards),
      u => agy_lpt_prepared_shard(x198pw_compile(path,source,base_path,base,"",stamp,False{}),shard,shards))

@unsafe
def agy_lpt_entry_shard(+path: String, +base: String, +mode: String, +carrier: String,
    +stamp: String, shard_m: Maybe<&2,U32>, shards_m: Maybe<&2,U32>) -> IO(U32):
  match shard_m shards_m:
    case Some{+shard} Some{+shards}:
      nt_choose(IO(U32),U32.is_ge(shards,1) && U32.is_lt(shard,shards),
        u => agy_lpt_request(path,base,carrier,stamp,agy_str_eq(mode,"cache"),shard,shards),
        u => IO.die(U32,2,"expected 0 <= shard < shards and shards >= 1"))
    case _ _: IO.die(U32,2,"expected U32 shard and shards arguments")
"""

OLD_ENTRY = """    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),agy_str_eq(program,"x86-object") && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
        u => IO.die(U32,2,"expected x86-object, absolute input/Base paths, live|cache mode, and shard/shards"))
    case _: IO.die(U32,2,"usage: x86|x86-object ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS]")"""

NEW_ENTRY = """    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+shard_s,Con{+shards_s,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-shard")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-shard"),
          v => agy_lpt_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s)),
          v => agy_parcg_entry_shard(path,base,mode,carrier,stamp,U32.read(shard_s),U32.read(shards_s))),
        u => IO.die(U32,2,"expected x86-object|x86-shard, absolute input/Base paths, live|cache mode, and shard/shards"))
    case _: IO.die(U32,2,"usage: x86|x86-object|x86-shard ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [SHARD SHARDS]")"""


def apply_patch(src: Path, out: Path) -> None:
    text = src.read_text()
    if PATCH_MARKER in text:
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text)
        return
    str_eq = "agy_str_eq" if "def agy_str_eq(" in text else "String.eq"
    has_enrich = "def agy_enrich_cursor(" in text
    old_entry = OLD_ENTRY.replace("agy_str_eq", str_eq)
    new_entry = NEW_ENTRY.replace("agy_str_eq", str_eq)
    lpt_code = LPT_CODE.replace("agy_str_eq", str_eq)
    if not has_enrich:
        lpt_code = lpt_code.replace("agy_enrich_cursor(cursor,avail)", "cursor")
    if old_entry not in text:
        raise RuntimeError(f"Expected x181_entry_args shard clause not found in {src}")
    anchor = "@unsafe\ndef x181_entry_args("
    idx = text.find(anchor)
    if idx < 0:
        raise RuntimeError(f"Expected x181_entry_args anchor not found in {src}")
    patched = text[:idx] + lpt_code + "\n" + text[idx:]
    patched = patched.replace(old_entry, new_entry, 1)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(patched)


def main() -> None:
    ap = argparse.ArgumentParser(description="Patch compiler.bend with Wave 6 native LPT sharding (x86-shard)")
    ap.add_argument("--src", type=Path, required=True, help="Input compiler.bend (never modified)")
    ap.add_argument("--out", type=Path, required=True, help="Output patched compiler.bend")
    args = ap.parse_args()
    if args.src.resolve() == args.out.resolve():
        raise SystemExit("Refusing to overwrite input compiler.bend in place; pass a distinct --out path.")
    apply_patch(args.src, args.out)
    print(f"Patched {args.src} -> {args.out} ({args.out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
