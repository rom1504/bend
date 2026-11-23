#!/usr/bin/env python3
"""Wave 9 String-Hotspot + Hash-Trie Direct-Lowering Patch (w9_str_hot).

Fixes:
  1. #1 hotspot (14.9% native CPU in String.order.go):
     a) Protect agy_sh native x86-64 string/tag fast-path targets from being
        inlined away by p113i_eligible (which previously inlined String.eq /
        agy_str_eq / p88_string_eq / p98_tag_eq into 61+ callers as direct
        String.order.go calls, completely bypassing agy_sh_emit_streq).
     b) Enable agy_sh_try in x181_program_private_fast (-O0 / x86-object-fast),
        which previously skipped agy_sh_try entirely so wave8-native-self/n1
        had zero native x86-64 string/hash/tag fast paths.
     Note: Both String.eq and agy_str_eq are direct agy_sh_try targets (both
     emit the exact same agy_sh_emit_streq x86-64 fast path), so keeping
     String.eq callers direct avoids adding a JS wrapper hop while getting the
     full native x86-64 fast path.
  2. #14 hotspot (1.0% native CPU in p111_FID_$direct.w5c_idx_find_lr):
     Eliminate mutual-recursion helper cycles in index_find, index_bucket,
     index_remove, index_tip, and index_insert. On the hot trie descent paths
     (KIndexNode in index_find and index_tip), use non-recursive leaf selectors
     (w9_pick_kdef / w9_pick_kdef_b) so:
       - JS mode allocates ZERO closures per trie step, AND
       - Native x86-64 admits index_find, index_bucket, index_tip, index_remove,
         and index_insert to P113Direct (p113d_FID_*) and inlines w9_pick_kdef
         straight into a tight P113DAgain tail-call loop.
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave8_unified/compiler.bend"

# --- Patch 1: Eliminate mutual recursion in index_find / index_bucket / index_remove / index_tip ---

OLD_INDEX_BLOCK = """@unsafe
def w5_idx_bucket_if(ok: Bool, bucket: List<&2, KDef>, +name: String) -> KDef:
  match ok:
    case True{}: index_bucket(bucket, name)
    case False{}: missing()

@unsafe
def w5c_idx_find_lr(bit: U32, left: KDef, right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match bit:
    case 0: index_find(left, name, hash, bits)
    case _: index_find(right, name, hash, bits)

@unsafe
def w5_idx_find_kdef_t(isLeaf: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isLeaf:
    case True{}: w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name)
    case False{}: index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)

@unsafe
def w5_idx_find_kdef(isAbs: Bool, +arity: U32, +templates: U32, +ctors: List<&2, KDef>, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isAbs:
    case True{}: missing()
    case False{}: w5_idx_find_kdef_t(U32.is_eq(templates, 0), arity, templates, ctors, name, hash, bits)

@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5_idx_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash, bits)
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}:
      w5c_idx_find_lr(U32.and(hash, mask), left, right, name, hash, bits)

@unsafe
def w5_idx_bkt_hit(hit: Bool, h: KDef, rest: List<&2, KDef>, +name: String) -> KDef:
  match hit:
    case True{}: h
    case False{}: index_bucket(rest, name)

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{+h, rest}:
      w5_idx_bkt_hit(String.eq(dn(h), name), h, rest, name)

# Module: src/core/index.bend:134
@unsafe
def index_remove(
  +ds: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      index_remove_step(h, rest, name, agy_str_eq(dn(h), name))

# Module: src/core/index.bend:145
@unsafe
def index_remove_step(
  +h: KDef, +rest: List<&2, KDef>, +name: String, +same: Bool,
) -> List<&2, KDef>:
  match same:
    case True{}: index_remove(rest, name)
    case False{}: Con{h, index_remove(rest, name)}

# Module: src/core/index.bend:153
law index_tip:
  for +tree: KDef
  for +hash: U32
  KDef

@unsafe
def w5_idx_tip_br(goLeft: Bool, left: KDef, right: KDef, +hash: U32) -> KDef:
  match goLeft:
    case True{}: index_tip(left, hash)
    case False{}: index_tip(right, hash)

@unsafe
def w5_idx_tip_node(isLeaf: Bool, +tree: KDef, +mask: U32, left: KDef, right: KDef, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: w5_idx_tip_br(U32.is_eq(U32.and(hash, mask), 0), left, right, hash)

@unsafe
def w5_idx_tip_kdef(isLeaf: Bool, +tree: KDef, +templates: U32, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash)

@unsafe
def index_tip(tree, hash):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      w5_idx_tip_kdef(U32.is_eq(templates, 0), tree, templates, hash)
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      w5_idx_tip_node(U32.is_eq(mask, 0), tree, mask, left, right, hash)"""

NEW_INDEX_BLOCK = """# Wave 9 (w9_str_hot): Non-recursive leaf selectors + pure self-recursive
# index_bucket / index_find / index_remove / index_tip: zero JS closures on
# hot KIndexNode descent AND full P113Direct admission in native x86-64.

@unsafe
def w9_pick_kdef(bit: U32, left: KDef, right: KDef) -> KDef:
  match bit:
    case 0: left
    case _: right

@unsafe
def w9_pick_kdef_b(goLeft: Bool, left: KDef, right: KDef) -> KDef:
  match goLeft:
    case True{}: left
    case False{}: right

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{+h, rest}:
      nt_choose(KDef, String.eq(dn(h), name),
        u => h,
        u => index_bucket(rest, name))

@unsafe
def w5_idx_bucket_if(ok: Bool, bucket: List<&2, KDef>, +name: String) -> KDef:
  match ok:
    case True{}: index_bucket(bucket, name)
    case False{}: missing()

@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      nt_choose(KDef, String.eq(kind, "Absent"),
        u => missing(),
        u => nt_choose(KDef, U32.is_eq(templates, 0),
          v => w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name),
          v => index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}:
      index_find(w9_pick_kdef(U32.and(hash, mask), left, right), name, hash, bits)

# Module: src/core/index.bend:134
@unsafe
def index_remove(
  +ds: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      nt_choose(List<&2, KDef>, agy_str_eq(dn(h), name),
        u => index_remove(rest, name),
        u => Con{h, index_remove(rest, name)})

# Module: src/core/index.bend:153
law index_tip:
  for +tree: KDef
  for +hash: U32
  KDef

@unsafe
def index_tip(tree, hash):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      nt_choose(KDef, U32.is_eq(templates, 0),
        u => tree,
        u => index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash))
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      nt_choose(KDef, U32.is_eq(mask, 0),
        u => tree,
        u => index_tip(w9_pick_kdef_b(U32.is_eq(U32.and(hash, mask), 0), left, right), hash))"""

# --- Patch 2: Protect agy_sh native fast-path functions from p113i_eligible inlining ---

OLD_P113I_ELIGIBLE = """@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +sz = p113i_size(body)
      +arity = nt_count(NC_Binding,params)
      Bool.not(p126s_is_table(function)) && Bool.not(w6_body_calls_self(name,body)) &&
        U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,64) &&
        U32.is_le(p113i_stack(body),8192) && p113i_params(params) &&
        ((U32.is_le(sz,1024) && p137qi_returns(body,result)) ||
         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))"""

NEW_P113I_ELIGIBLE = """@unsafe
def w9_is_sh_intrinsic(+name: String) -> Bool:
  agy_str_eq(name,"$direct.String.eq") ||
  agy_str_eq(name,"$p118borrow.read.String.eq") ||
  agy_str_eq(name,"$p128borrow.owned.String.eq") ||
  agy_str_eq(name,"$direct.agy_str_eq") ||
  agy_str_eq(name,"$p118borrow.read.agy_str_eq") ||
  agy_str_eq(name,"$p128borrow.owned.agy_str_eq") ||
  agy_str_eq(name,"$direct.p88_string_eq") ||
  agy_str_eq(name,"$p118borrow.read.p88_string_eq") ||
  agy_str_eq(name,"$p128borrow.owned.p88_string_eq") ||
  agy_str_eq(name,"$direct.p98_tag_eq") ||
  agy_str_eq(name,"$p118borrow.read.p98_tag_eq") ||
  agy_str_eq(name,"$p128borrow.owned.p98_tag_eq") ||
  agy_str_eq(name,"$direct.p98_tag_eq_read") ||
  agy_str_eq(name,"$p118borrow.read.p98_tag_eq_read") ||
  agy_str_eq(name,"$p128borrow.owned.p98_tag_eq_read")

@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +sz = p113i_size(body)
      +arity = nt_count(NC_Binding,params)
      Bool.not(w9_is_sh_intrinsic(name)) &&
        Bool.not(p126s_is_table(function)) && Bool.not(w6_body_calls_self(name,body)) &&
        U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,64) &&
        U32.is_le(p113i_stack(body),8192) && p113i_params(params) &&
        ((U32.is_le(sz,1024) && p137qi_returns(body,result)) ||
         (U32.is_le(sz,120) && w4i_returns_or_again(body,result,arity)))"""

# --- Patch 3: Enable agy_sh_try in x181_program_private_fast (-O0 / x86-object-fast) ---

OLD_PRIVATE_FAST = """@unsafe
def x181_program_private_fast(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{+name,+params,+result,public,+body} P134Context{+ids,index,direct,+ready,view,lookups,heap,mode}:
      +pnames = x181_param_names(params)
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => pnames,u => Con{"__x181_result_out",pnames})}
      +error = p111_first(x181_program_stmts(body,available),p111_first(x181_hygiene_names(pnames),x181_hygiene_stmts(body)))
      nt_choose(X181Output,String.is_empty(error),
        u => x181_program_join(x181_function_fast(p113e_symbol(name),names,body,ids),x181_forward(function,ready)),
        u => X181Output{[],error})"""

NEW_PRIVATE_FAST = """@unsafe
def w9_private_fast_sh(sh: Maybe<&2,X181Output>, +function: P113DFunction, +symbol: String,
    +names: List<&2,String>, +body: List<&2,P113DStmt>, +ids: N111Ids, +ready: KDef) -> X181Output:
  match sh:
    case Some{out}: x181_program_join(out,x181_forward(function,ready))
    case None{}: x181_program_join(x181_function_fast(symbol,names,body,ids),x181_forward(function,ready))

@unsafe
def x181_program_private_fast(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{+name,+params,+result,public,+body} P134Context{+ids,index,direct,+ready,view,lookups,heap,mode}:
      +pnames = x181_param_names(params)
      +names : List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => pnames,u => Con{"__x181_result_out",pnames})}
      +error = p111_first(x181_program_stmts(body,available),p111_first(x181_hygiene_names(pnames),x181_hygiene_stmts(body)))
      nt_choose(X181Output,String.is_empty(error),
        u => w9_private_fast_sh(agy_sh_try(function,ids),function,p113e_symbol(name),names,body,ids,ready),
        u => X181Output{[],error})"""


def apply_patch(txt: str) -> tuple[str, dict[str, int]]:
    stats: dict[str, int] = {}
    for name, old, new in [
        ("index_find_bucket_tip_remove", OLD_INDEX_BLOCK, NEW_INDEX_BLOCK),
        ("p113i_eligible_guard", OLD_P113I_ELIGIBLE, NEW_P113I_ELIGIBLE),
        ("private_fast_agy_sh", OLD_PRIVATE_FAST, NEW_PRIVATE_FAST),
    ]:
        count = txt.count(old)
        if count != 1:
            raise RuntimeError(f"Patch {name!r} expected 1 match, found {count}")
        txt = txt.replace(old, new, 1)
        stats[name] = 1
    return txt, stats


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()

    src_txt = args.src.read_text()
    patched, stats = apply_patch(src_txt)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(patched)
    print(f"[w9_str_hot] Wrote {args.dst} ({len(patched):,} B): {stats}")


if __name__ == "__main__":
    main()
