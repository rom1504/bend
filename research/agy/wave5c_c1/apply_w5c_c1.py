#!/usr/bin/env python3
"""Wave 5C C1: Compile-Speed 10x Closer.

Composable, 100% bit-exact backend compile-time optimizations on top of
selfhost/build/agy/wave5b_unified/compiler.bend, merging the 4 high-value
W5B-C1 optimizations that were skipped during Wave 5B composition due to
W5B-R2/R3 upgrades:

  1. w4b_reg_dead_fast_and_lbltrie:
     - O(1) first-char dispatch for w4b_is_write_only_op / w4b_is_simple_alu / w4b_is_alu32_rr
     - O(log L) Patricia trie W5BLblTrie for label lookup in w5b_reg_dead_t
     - Zero-closure w5b_reg_dead_t AND w4b_reg_dead_step, fused with W5B-R2's
       `seen` cycle-set, `setcc; movzbl` overwrite check, and `hops = 8`.
  2. w4b_copy_peep_fast:
     - Direct-match zero-closure w5b_copy_peep_t using W5BLblTrie + changed flag.
  3. w5_gpr_step direct-match + w4_post_select idempotent skip-if-unchanged:
     - Direct 1-scrutinee dispatch for w5_gpr_step preserving W5B-R2's G15, G12, G11.
     - Skip redundant 2nd/3rd passes of w4b_copy_peep, w5_gpr_peep, and w5b_peep
       when the previous pass made 0 changes (plus zero-closure w5b_peep_inst).
  4. x187_e_single_pair_match_family:
     - O(1) `match family:` dispatch in x187_e_single and x187_e_pair, preserving
       W5B-R3's `prefix` arg in x187_e_shift (family 3) and `movzwl` (family 18).

Usage:
  python3 -B research/agy/wave5c_c1/apply_w5c_c1.py \
    --src selfhost/build/agy/wave5b_unified/compiler.bend \
    --dst selfhost/build/agy/wave5c_c1/compiler.bend
"""

import argparse
from pathlib import Path


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise ValueError(f"[{label}] expected 1 match, found {cnt}")
    return text.replace(old, new, 1)


def apply_patches(src: str) -> str:
    # ------------------------------------------------------------------
    # 1. w4b_reg_dead_fast_and_lbltrie (fused with W5B-R2 seen + setcc;movzbl + hops=8)
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def w4b_is_write_only_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
  agy_str_eq(op,"leaq") || agy_str_eq(op,"movzbl") || agy_str_eq(op,"movd")

@unsafe
def w4b_is_simple_alu(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"addq") || agy_str_eq(op,"subl") || agy_str_eq(op,"subq") ||
  agy_str_eq(op,"imull") || agy_str_eq(op,"imulq") || agy_str_eq(op,"andl") || agy_str_eq(op,"andq") ||
  agy_str_eq(op,"orl") || agy_str_eq(op,"orq") || agy_str_eq(op,"xorl") || agy_str_eq(op,"xorq") ||
  agy_str_eq(op,"shll") || agy_str_eq(op,"shlq") || agy_str_eq(op,"shrl") || agy_str_eq(op,"shrq") ||
  agy_str_eq(op,"sarl") || agy_str_eq(op,"sarq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"cmpq") ||
  agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || String.starts_with(op,"cmov") ||
  String.starts_with(op,"set")

@unsafe
def w4b_is_alu32_rr(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"subl") || agy_str_eq(op,"imull") ||
  agy_str_eq(op,"andl") || agy_str_eq(op,"orl") || agy_str_eq(op,"xorl")

law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  for +seen: List<&2,String>
  Bool

@unsafe
def w4b_find_label(+lbl: String, items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Nil{}: None{}
    case Con{PLabel{l},+rest}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(l,lbl),u => Some{rest},u => w4b_find_label(lbl,rest))
    case Con{_,rest}: w4b_find_label(lbl,rest)

@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops,seen)
    case None{}: False{}

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      nt_choose(Bool,w4b_op_reads_reg(r,src),w => False{},w =>
        nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),x => True{},
          x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen)))
    case _:
      nt_choose(Bool,w4b_args_read_reg(r,args),w => False{},
        w => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen))

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}:
      nt_choose(Bool,nb_contains(seen,tgt),
        s => nt_choose(Bool,agy_str_eq(op,"jmp"),
          u => True{},
          u => nt_choose(Bool,U32.is_eq(hops,0),v => False{},
            v => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1),seen))),
        s => nt_choose(Bool,U32.is_eq(hops,0),u => False{},u =>
          nt_choose(Bool,agy_str_eq(op,"jmp"),
            v => w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1),Con{tgt,seen}),
            v => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1),seen) &&
                 w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1),Con{tgt,seen}))))
    case _: False{}

@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),u => True{},
        u => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen))
    case _: False{}

@unsafe
def w5b_dead_movzbl(+r: U32, rest: List<&2,X187Parsed>) -> Bool:
  match rest:
    case Con{PInst{X187Instruction{mop,Con{X187Reg{ms,8,False{}},Con{X187Reg{md,32,False{}},Nil{}}}}},_}:
      agy_str_eq(mop,"movzbl") && U32.is_eq(ms,r) && U32.is_eq(md,r)
    case _: False{}

@unsafe
def w5b_dead_after_setcc(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>) -> Bool:
  match args:
    case Con{X187Reg{dr,8,False{}},Nil{}}:
      U32.is_eq(dr,r) && w5b_dead_movzbl(r,rest)
    case _: False{}

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{+lbl},rest}:
      nt_choose(Bool,nb_contains(seen,lbl),u => True{},
        u => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,Con{lbl,seen}))
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"ret"),u => Bool.not(U32.is_eq(r,0)),u =>
        nt_choose(Bool,agy_str_eq(op,"popq"),p => w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops,seen),p =>
        nt_choose(Bool,String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),q => True{},q =>
        nt_choose(Bool,w4b_is_write_only_op(op),v => w4b_reg_dead_write(r,args,rest,fnItems,budget,hops,seen),
          v => nt_choose(Bool,w4b_is_simple_alu(op),w =>
            nt_choose(Bool,w4b_args_read_reg(r,args),x => False{},
              x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen)),
            w => nt_choose(Bool,String.starts_with(op,"j"),
              x => w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops,seen),
              x => False{}))))))
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops,seen):
  nt_choose(Bool,U32.is_eq(budget,0),u => False{},u => w4b_reg_dead_go(r,items,fnItems,budget,hops,seen))

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,8,[])""",
        """# W5C-C1: O(1) first-char opcode classifiers + O(log L) W5BLblTrie + zero-closure w4b_reg_dead
# (fused with W5B-R2 seen cycle-set, setcc;movzbl overwrite check, and hops=8)
@unsafe
def w5c_is_wo_c(u: U32, +op: String) -> Bool:
  match u:
    case 109: String.eq(op,"movq") || String.eq(op,"movl") || String.eq(op,"movabsq") || String.eq(op,"movzbl") || String.eq(op,"movd")
    case 108: String.eq(op,"leaq")
    case _: False{}

@unsafe
def w4b_is_write_only_op(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5c_is_wo_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w5c_is_alu_c(u: U32, +op: String) -> Bool:
  match u:
    case 97: String.eq(op,"addl") || String.eq(op,"addq") || String.eq(op,"andl") || String.eq(op,"andq")
    case 115: String.eq(op,"subl") || String.eq(op,"subq") || String.eq(op,"shll") || String.eq(op,"shlq") || String.eq(op,"shrl") || String.eq(op,"shrq") || String.eq(op,"sarl") || String.eq(op,"sarq") || String.starts_with(op,"set")
    case 105: String.eq(op,"imull") || String.eq(op,"imulq")
    case 111: String.eq(op,"orl") || String.eq(op,"orq")
    case 120: String.eq(op,"xorl") || String.eq(op,"xorq")
    case 99: String.eq(op,"cmpl") || String.eq(op,"cmpq") || String.starts_with(op,"cmov")
    case 116: String.eq(op,"testl") || String.eq(op,"testq")
    case _: False{}

@unsafe
def w4b_is_simple_alu(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5c_is_alu_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w5c_is_alu32_c(u: U32, +op: String) -> Bool:
  match u:
    case 97: String.eq(op,"addl") || String.eq(op,"andl")
    case 115: String.eq(op,"subl")
    case 105: String.eq(op,"imull")
    case 111: String.eq(op,"orl")
    case 120: String.eq(op,"xorl")
    case _: False{}

@unsafe
def w4b_is_alu32_rr(+op: String) -> Bool:
  match op:
    case SCon{c,_}: w5c_is_alu32_c(Char.to_u32(c),op)
    case SNil{}: False{}

@unsafe
def w5b_dead_movzbl(+r: U32, rest: List<&2,X187Parsed>) -> Bool:
  match rest:
    case Con{PInst{X187Instruction{mop,Con{X187Reg{ms,8,False{}},Con{X187Reg{md,32,False{}},Nil{}}}}},_}:
      String.eq(mop,"movzbl") && U32.is_eq(ms,r) && U32.is_eq(md,r)
    case _: False{}

@unsafe
def w5b_dead_after_setcc(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>) -> Bool:
  match args:
    case Con{X187Reg{dr,8,False{}},Nil{}}:
      U32.is_eq(dr,r) && w5b_dead_movzbl(r,rest)
    case _: False{}

type W5BLblEntry is Data:
  W5BLblEntry{+lbl: String, +tail: List<&2,X187Parsed>}

type W5BLblTrie is Data:
  W5BLNil{}
  W5BLLeaf{+h: U32, +items: List<&2,W5BLblEntry>}
  W5BLNode{+h: U32, +mask: U32, +l: W5BLblTrie, +r: W5BLblTrie}

law w5c_lbl_bkt_find:
  for items: List<&2,W5BLblEntry>
  for +lbl: String
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5c_lbl_bkt_if(eq: Bool, t: List<&2,X187Parsed>, rest: List<&2,W5BLblEntry>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: Some{t}
    case False{}: w5c_lbl_bkt_find(rest,lbl)

@unsafe
def w5c_lbl_bkt_find(items, lbl):
  match items:
    case Nil{}: None{}
    case Con{W5BLblEntry{k,t},rest}: w5c_lbl_bkt_if(String.eq(k,lbl),t,rest,lbl)

law w5c_lbl_find:
  for trie: W5BLblTrie
  for +lbl: String
  for +h: U32
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5c_lbl_find_leaf(eq: Bool, items: List<&2,W5BLblEntry>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: w5c_lbl_bkt_find(items,lbl)
    case False{}: None{}

@unsafe
def w5c_lbl_find_br(bit: U32, l: W5BLblTrie, r: W5BLblTrie, +lbl: String, +h: U32) -> Maybe<&2,List<&2,X187Parsed>>:
  match bit:
    case 0: w5c_lbl_find(l,lbl,h)
    case _: w5c_lbl_find(r,lbl,h)

@unsafe
def w5c_lbl_find(trie, lbl, h):
  match trie:
    case W5BLNil{}: None{}
    case W5BLLeaf{stored,items}: w5c_lbl_find_leaf(U32.is_eq(stored,h),items,lbl)
    case W5BLNode{stored,mask,l,r}: w5c_lbl_find_br(U32.and(h,mask),l,r,lbl,h)

@unsafe
def w5c_lbl_join_br(bit: U32, +trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, +mask: U32) -> W5BLblTrie:
  match bit:
    case 0: W5BLNode{stored,mask,W5BLLeaf{h,[entry]},trie}
    case _: W5BLNode{stored,mask,trie,W5BLLeaf{h,[entry]}}

@unsafe
def w5c_lbl_join(+trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, +mask: U32) -> W5BLblTrie:
  w5c_lbl_join_br(U32.and(h,mask),trie,entry,h,stored,mask)

law w5c_lbl_insert:
  for +trie: W5BLblTrie
  for +entry: W5BLblEntry
  for +h: U32
  W5BLblTrie

@unsafe
def w5c_lbl_ins_leaf(+mask: U32, +trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, items: List<&2,W5BLblEntry>) -> W5BLblTrie:
  match mask:
    case 0: W5BLLeaf{h,Con{entry,items}}
    case _: w5c_lbl_join(trie,entry,h,stored,mask)

@unsafe
def w5c_lbl_ins_side(bit: U32, +stored: U32, +split: U32, l: W5BLblTrie, r: W5BLblTrie, +entry: W5BLblEntry, +h: U32) -> W5BLblTrie:
  match bit:
    case 0: W5BLNode{stored,split,w5c_lbl_insert(l,entry,h),r}
    case _: W5BLNode{stored,split,l,w5c_lbl_insert(r,entry,h)}

@unsafe
def w5c_lbl_ins_node(below: U32, +trie: W5BLblTrie, +stored: U32, +split: U32, l: W5BLblTrie, r: W5BLblTrie,
    +entry: W5BLblEntry, +h: U32, +diff: U32) -> W5BLblTrie:
  match below:
    case 0: w5c_lbl_ins_side(U32.and(h,split),stored,split,l,r,entry,h)
    case _: w5c_lbl_join(trie,entry,h,stored,index_split_bit(diff))

@unsafe
def w5c_lbl_insert(trie, entry, h):
  match trie:
    case W5BLNil{}: W5BLLeaf{h,[entry]}
    case W5BLLeaf{stored,items}: w5c_lbl_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,entry,h,stored,items)
    case W5BLNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5c_lbl_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,entry,h,diff)

@unsafe
def w5c_lbl_build(items: List<&2,X187Parsed>) -> W5BLblTrie:
  match items:
    case Nil{}: W5BLNil{}
    case Con{PLabel{+l},+rest}:
      w5c_lbl_insert(w5c_lbl_build(rest),W5BLblEntry{l,rest},index_hash(l,2166136261))
    case Con{_,rest}: w5c_lbl_build(rest)

law w5c_reg_dead_step_t:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +lbls: W5BLblTrie
  for +budget: U32
  for +hops: U32
  for +seen: List<&2,String>
  Bool

@unsafe
def w5c_reg_dead_at_lbl_t(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +lbls: W5BLblTrie,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match found:
    case Some{atTgt}: w5c_reg_dead_step_t(r,atTgt,lbls,budget,hops,seen)
    case None{}: False{}

@unsafe
def w5c_rd_cont_t(stop: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match stop:
    case True{}: False{}
    case False{}: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_kill_or_cont_t(kill: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match kill:
    case True{}: True{}
    case False{}: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_wr_if_t(reads: Bool, +dr: U32, +dw: U32, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match reads:
    case True{}: False{}
    case False{}: w5c_rd_kill_or_cont_t(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,lbls,budget,hops,seen)

@unsafe
def w5c_reg_dead_write_t(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      w5c_rd_wr_if_t(w4b_op_reads_reg(r,src),dr,dw,r,rest,lbls,budget,hops,seen)
    case _: w5c_rd_cont_t(w4b_args_read_reg(r,args),r,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_br_seen_hops_t(+hops: U32, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_jmp_t(isJmp: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: True{}
    case False{}: w5c_rd_br_seen_hops_t(hops,r,rest,lbls,budget,seen)

@unsafe
def w5c_rd_br_both_t(ok: Bool, +r: U32, +tgt: String, +lbls: W5BLblTrie, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match ok:
    case False{}: False{}
    case True{}: w5c_reg_dead_at_lbl_t(r,w5c_lbl_find(lbls,tgt,index_hash(tgt,2166136261)),lbls,nb,nh,Con{tgt,seen})

@unsafe
def w5c_rd_br_jmp_t(isJmp: Bool, +r: U32, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: w5c_reg_dead_at_lbl_t(r,w5c_lbl_find(lbls,tgt,index_hash(tgt,2166136261)),lbls,nb,nh,Con{tgt,seen})
    case False{}: w5c_rd_br_both_t(w5c_reg_dead_step_t(r,rest,lbls,nb,nh,seen),r,tgt,lbls,nb,nh,seen)

@unsafe
def w5c_rd_br_hops_t(+hops: U32, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w5c_rd_br_jmp_t(String.eq(op,"jmp"),r,tgt,rest,lbls,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_t(isSeen: Bool, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: w5c_rd_br_seen_jmp_t(String.eq(op,"jmp"),r,rest,lbls,budget,hops,seen)
    case False{}: w5c_rd_br_hops_t(hops,r,op,tgt,rest,lbls,budget,seen)

@unsafe
def w5c_reg_dead_branch_t(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}: w5c_rd_br_seen_t(nb_contains(seen,tgt),r,op,tgt,rest,lbls,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_reg_dead_pop_t(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      w5c_rd_kill_or_cont_t(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,lbls,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_rd_alu_if_t(isAlu: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isAlu:
    case False{}: False{}
    case True{}: w5c_rd_cont_t(w4b_args_read_reg(r,args),r,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_setcc_if_t(killed: Bool, +r: U32, +op: String, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match killed:
    case True{}: True{}
    case False{}: w5c_rd_alu_if_t(w4b_is_simple_alu(op),r,args,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_wo_if_t(isWo: Bool, +r: U32, +op: String, +args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isWo:
    case True{}: w5c_reg_dead_write_t(r,args,rest,lbls,budget,hops,seen)
    case False{}: w5c_rd_alu_if_t(w4b_is_simple_alu(op),r,args,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_ret_if_t(isRet: Bool, +r: U32) -> Bool:
  match isRet:
    case True{}: Bool.not(U32.is_eq(r,0))
    case False{}: False{}

@unsafe
def w5c_rd_pop_if_t(isPop: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isPop:
    case True{}: w5c_reg_dead_pop_t(r,args,rest,lbls,budget,hops,seen)
    case False{}: False{}

@unsafe
def w5c_rd_inst_c_t(u: U32, +r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match u:
    case 114: w5c_rd_ret_if_t(String.eq(op,"ret"),r)
    case 112: w5c_rd_pop_if_t(String.eq(op,"popq"),r,args,rest,lbls,budget,hops,seen)
    case 106: w5c_reg_dead_branch_t(r,op,args,rest,lbls,budget,hops,seen)
    case 115: w5c_rd_setcc_if_t(String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),r,op,args,rest,lbls,budget,hops,seen)
    case _: w5c_rd_wo_if_t(w4b_is_write_only_op(op),r,op,args,rest,lbls,budget,hops,seen)

@unsafe
def w5c_reg_dead_inst_t(+r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match op:
    case SCon{c,_}: w5c_rd_inst_c_t(Char.to_u32(c),r,op,args,rest,lbls,budget,hops,seen)
    case SNil{}: False{}

@unsafe
def w5c_rd_lbl_seen_t(isSeen: Bool, +r: U32, +lbl: String, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: True{}
    case False{}: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops,Con{lbl,seen})

@unsafe
def w5c_reg_dead_go_t(+r: U32, items: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{+lbl},rest}: w5c_rd_lbl_seen_t(nb_contains(seen,lbl),r,lbl,rest,lbls,budget,hops,seen)
    case Con{PInst{X187Instruction{op,args}},rest}: w5c_reg_dead_inst_t(r,op,args,rest,lbls,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_reg_dead_step_t(r,items,lbls,budget,hops,seen):
  match budget:
    case 0: False{}
    case _: w5c_reg_dead_go_t(r,items,lbls,budget,hops,seen)

@unsafe
def w5c_reg_dead_t(+r: U32, items: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32) -> Bool:
  w5c_reg_dead_step_t(r,items,lbls,budget,8,[])

law w4b_find_label:
  for +lbl: String
  for items: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5c_find_lbl_if(eq: Bool, rest: List<&2,X187Parsed>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: Some{rest}
    case False{}: w4b_find_label(lbl,rest)

@unsafe
def w4b_find_label(lbl, items):
  match items:
    case Nil{}: None{}
    case Con{PLabel{l},+rest}: w5c_find_lbl_if(String.eq(l,lbl),rest,lbl)
    case Con{_,rest}: w4b_find_label(lbl,rest)

law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  for +seen: List<&2,String>
  Bool

@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops,seen)
    case None{}: False{}

@unsafe
def w5c_rd_cont_f(stop: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match stop:
    case True{}: False{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_kill_f(kill: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match kill:
    case True{}: True{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_wr_if_f(reads: Bool, +dr: U32, +dw: U32, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match reads:
    case True{}: False{}
    case False{}: w5c_rd_kill_f(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,fnItems,budget,hops,seen)

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      w5c_rd_wr_if_f(w4b_op_reads_reg(r,src),dr,dw,r,rest,fnItems,budget,hops,seen)
    case _: w5c_rd_cont_f(w4b_args_read_reg(r,args),r,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_br_seen_hops_f(+hops: U32, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_jmp_f(isJmp: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: True{}
    case False{}: w5c_rd_br_seen_hops_f(hops,r,rest,fnItems,budget,seen)

@unsafe
def w5c_rd_br_both_f(ok: Bool, +r: U32, +tgt: String, +fnItems: List<&2,X187Parsed>, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match ok:
    case False{}: False{}
    case True{}: w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,nb,nh,Con{tgt,seen})

@unsafe
def w5c_rd_br_jmp_f(isJmp: Bool, +r: U32, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,nb,nh,Con{tgt,seen})
    case False{}: w5c_rd_br_both_f(w4b_reg_dead_step(r,rest,fnItems,nb,nh,seen),r,tgt,fnItems,nb,nh,seen)

@unsafe
def w5c_rd_br_hops_f(+hops: U32, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w5c_rd_br_jmp_f(String.eq(op,"jmp"),r,tgt,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_f(isSeen: Bool, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: w5c_rd_br_seen_jmp_f(String.eq(op,"jmp"),r,rest,fnItems,budget,hops,seen)
    case False{}: w5c_rd_br_hops_f(hops,r,op,tgt,rest,fnItems,budget,seen)

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}: w5c_rd_br_seen_f(nb_contains(seen,tgt),r,op,tgt,rest,fnItems,budget,hops,seen)
    case _: False{}

@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      w5c_rd_kill_f(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,fnItems,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_rd_alu_if_f(isAlu: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isAlu:
    case False{}: False{}
    case True{}: w5c_rd_cont_f(w4b_args_read_reg(r,args),r,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_setcc_if_f(killed: Bool, +r: U32, +op: String, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match killed:
    case True{}: True{}
    case False{}: w5c_rd_alu_if_f(w4b_is_simple_alu(op),r,args,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_wo_if_f(isWo: Bool, +r: U32, +op: String, +args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isWo:
    case True{}: w4b_reg_dead_write(r,args,rest,fnItems,budget,hops,seen)
    case False{}: w5c_rd_alu_if_f(w4b_is_simple_alu(op),r,args,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_pop_if_f(isPop: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isPop:
    case True{}: w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops,seen)
    case False{}: False{}

@unsafe
def w5c_rd_inst_c_f(u: U32, +r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match u:
    case 114: w5c_rd_ret_if_t(String.eq(op,"ret"),r)
    case 112: w5c_rd_pop_if_f(String.eq(op,"popq"),r,args,rest,fnItems,budget,hops,seen)
    case 106: w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops,seen)
    case 115: w5c_rd_setcc_if_f(String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),r,op,args,rest,fnItems,budget,hops,seen)
    case _: w5c_rd_wo_if_f(w4b_is_write_only_op(op),r,op,args,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_inst_f(+r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match op:
    case SCon{c,_}: w5c_rd_inst_c_f(Char.to_u32(c),r,op,args,rest,fnItems,budget,hops,seen)
    case SNil{}: False{}

@unsafe
def w5c_rd_lbl_seen_f(isSeen: Bool, +r: U32, +lbl: String, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: True{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,Con{lbl,seen})

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{+lbl},rest}: w5c_rd_lbl_seen_f(nb_contains(seen,lbl),r,lbl,rest,fnItems,budget,hops,seen)
    case Con{PInst{X187Instruction{op,args}},rest}: w5c_rd_inst_f(r,op,args,rest,fnItems,budget,hops,seen)
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops,seen):
  match budget:
    case 0: False{}
    case _: w4b_reg_dead_go(r,items,fnItems,budget,hops,seen)

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,8,[])""",
        "w4b_reg_dead_fast_and_lbltrie",
    )

    # ------------------------------------------------------------------
    # 2. w4b_copy_peep_fast (direct-match zero-closure using W5BLblTrie + changed flag)
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def w4b_copy_peep(items,fnItems,out):
  match items:
    case Nil{}: out
    case Con{+i0,Con{+i1,+rest}}: w4b_copy_pair_rr(w4b_as_rr(i0),w4b_as_rr(i1),i0,i1,rest,fnItems,out)
    case Con{h,rest}: w4b_copy_peep(rest,fnItems,Con{X188One{h},out})""",
        """type W5BPeepOut is Data:
  W5BPeepOut{+changed: Bool, +seq: List<&2,X188Seq>}

law w5c_copy_peep_t:
  for items: List<&2,X187Parsed>
  for +lbls: W5BLblTrie
  for +out: List<&2,X188Seq>
  for +changed: Bool
  W5BPeepOut

@unsafe
def w5c_cp_jcc_if(ok: Bool, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{i3,tail},lbls,Con{X188One{i1},Con{X188One{i0},out}},True{})
    case False{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_check_jcc_t(br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match br:
    case W4BBranch{jop,_}: w5c_cp_jcc_if(w4_peep_is_jz_jnz(jop),i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BBranchNone{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sf4_if(ok: Bool, +a: U32, +b: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{"subl",[X187Reg{a,32,False{}},X187Reg{b,32,False{}}]}},tail},lbls,out,True{})
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold4_t(r4: W4BRR, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r4:
    case W4BRR{op4,s4,ws4,d4,wd4}:
      +ok = String.eq(op4,"movq") && U32.is_eq(s4,a) && U32.is_eq(ws4,64) && U32.is_eq(d4,b) && U32.is_eq(wd4,64) &&
            Bool.not(U32.is_eq(a,b) || U32.is_eq(t,a) || U32.is_eq(t,b) || U32.is_eq(t,11) || U32.is_eq(a,11) || U32.is_eq(b,11)) &&
            w5c_reg_dead_t(t,tail,lbls,36) && w5c_reg_dead_t(a,tail,lbls,36) && w5c_reg_dead_t(11,tail,lbls,36)
      w5c_sf4_if(ok,a,b,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sf3_if(ok: Bool, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_sub_fold4_t(w4b_as_rr(i4),b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold3_t(r3: W4BRR, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r3:
    case W4BRR{op3,s3,ws3,d3,wd3}:
      w5c_sf3_if(String.eq(op3,"subl") && U32.is_eq(s3,11) && U32.is_eq(ws3,32) && U32.is_eq(d3,a) && U32.is_eq(wd3,32),
        i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sf2_if(ok: Bool, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_sub_fold3_t(w4b_as_rr(i3),i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold2_t(r2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match r2:
    case W4BRR{op2,s2,ws2,d2,wd2}:
      w5c_sf2_if(String.eq(op2,"movq") && U32.is_eq(s2,t) && U32.is_eq(ws2,64) && U32.is_eq(d2,a) && U32.is_eq(wd2,64),
        i3,i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_sub_fold_t(+b: U32, +t: U32, +a: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match rest:
    case Con{i2,Con{i3,Con{i4,tail}}}:
      w5c_sub_fold2_t(w4b_as_rr(i2),i3,i4,b,t,a,i0,i1,rest,tail,lbls,out,chg)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_cp_chk_if(ok: Bool, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_check_jcc_t(w4b_as_branch(i3),i0,i1,i2,i3,tail,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_check_test_t(tr: W4BRR, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match tr:
    case W4BRR{top,s,ws,d,wd}:
      w5c_cp_chk_if(String.eq(top,"testq") && U32.is_eq(s,c) && U32.is_eq(d,c) && U32.is_eq(ws,64) && U32.is_eq(wd,64),
        i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BRRNone{}: w5c_copy_peep_t(Con{i1,Con{i2,Con{i3,tail}}},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_check_cmp_t(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      w5c_cp_chk_if(String.eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) && U32.is_eq(cr,c) && U32.is_eq(cw,64),
        i0,i1,i2,i3,tail,lbls,out,chg)
    case W4BImmRegNone{}: w5c_copy_check_test_t(w4b_as_rr(i2),c,i0,i1,i2,i3,tail,lbls,out,chg)

@unsafe
def w5c_copy_after_sub_t(+c: U32, +rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match rest:
    case Con{+i2,Con{+i3,+tail}}: w5c_copy_check_cmp_t(w4b_as_imm_reg(i2),c,i0,i1,i2,i3,tail,lbls,out,chg)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_cp_r6(ok: Bool, +s: U32, +t: U32, +t2: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_sub_fold_t(s,t,t2,i0,i1,rest,lbls,out,chg)
    case False{}: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_cp_r5(ok: Bool, +isMov32: Bool, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(rest,lbls,Con{X188One{i0},out},True{})
    case False{}:
      w5c_cp_r6(isMov32 && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) && U32.is_eq(d,11),
        s,t,t2,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r4(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_after_sub_t(d,rest,i0,i1,lbls,out,chg)
    case False{}:
      w5c_cp_r5(String.eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
          U32.is_eq(t,t2) && U32.is_eq(t,d) && (isMov32 || w4b_is_alu32_rr(op0)),
        isMov32,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r3(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{op0,[X187Reg{t,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      w5c_cp_r4(String.eq(op0,"subl") && String.eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
        isMov32,op0,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r2(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +ws: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      +ok3 = U32.is_eq(ws,32) && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
             U32.is_eq(t,t2) && U32.is_eq(s,d) && Bool.not(U32.is_eq(t,d)) &&
             (String.eq(op0,"addl") || String.eq(op0,"imull") || String.eq(op0,"andl") || String.eq(op0,"orl") || String.eq(op0,"xorl")) &&
             w5c_reg_dead_t(t,rest,lbls,36)
      w5c_cp_r3(ok3,isMov32,op0,op1,s,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_cp_r1(ok: Bool, +isMov32: Bool, +op0: String, +op1: String, +s: U32, +ws: U32, +t: U32, +t2: U32, +wt2: U32, +d: U32, +wd: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match ok:
    case True{}: w5c_copy_peep_t(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},lbls,out,True{})
    case False{}:
      +ok2 = isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
             U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w5c_reg_dead_t(t,rest,lbls,36)
      w5c_cp_r2(ok2,isMov32,op0,op1,s,ws,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)

@unsafe
def w5c_copy_pair_t(+op0: String, +s: U32, +ws: U32, +t: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +chg: Bool) -> W5BPeepOut:
  match i1:
    case PInst{X187Instruction{+op1,Con{X187Reg{+t2,+wt2,False{}},Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      +isMov32 = String.eq(op0,"movl") && U32.is_eq(ws,32)
      +ok1 = isMov32 && String.eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
             U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w5c_reg_dead_t(t,rest,lbls,36)
      w5c_cp_r1(ok1,isMov32,op0,op1,s,ws,t,t2,wt2,d,wd,i0,i1,rest,lbls,out,chg)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},chg)

@unsafe
def w5c_copy_i0(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +out: List<&2,X188Seq>, +changed: Bool) -> W5BPeepOut:
  match i0:
    case PInst{X187Instruction{+op0,Con{X187Reg{+s,+ws,False{}},Con{X187Reg{+t,32,False{}},Nil{}}}}}:
      w5c_copy_pair_t(op0,s,ws,t,i0,i1,rest,lbls,out,changed)
    case _: w5c_copy_peep_t(Con{i1,rest},lbls,Con{X188One{i0},out},changed)

@unsafe
def w5c_copy_peep_t(items,lbls,out,changed):
  match items:
    case Nil{}: W5BPeepOut{changed,out}
    case Con{+i0,Con{+i1,+rest}}: w5c_copy_i0(i0,i1,rest,lbls,out,changed)
    case Con{h,rest}: w5c_copy_peep_t(rest,lbls,Con{X188One{h},out},changed)

@unsafe
def w5c_peep_seq(res: W5BPeepOut) -> List<&2,X188Seq>:
  match res:
    case W5BPeepOut{_,seq}: seq

@unsafe
def w4b_copy_peep(items,fnItems,out):
  w5c_peep_seq(w5c_copy_peep_t(items,w5c_lbl_build(fnItems),out,False{}))""",
        "w4b_copy_peep_fast",
    )

    # ------------------------------------------------------------------
    # 3a. w5_gpr_step direct-match (preserving W5B-R2 G15, G12, G11)
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_gpr_try_ld(w5_as_load_rbp(i0),i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_gpr_try_rr(w4b_as_rr(i0),i0,i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_gpr_try_imm(w4b_as_imm_reg(i0),i1,r2,fnItems,acc),
        w => w4c_or_peep(w5_gpr_try_jcc(w4b_as_branch(i0),i1,r2,fnItems,acc),
          x => w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})))))""",
        """@unsafe
def w5c_gpr_or(res: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match res:
    case Some{out}: out
    case None{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_ld_if(neg: Bool, +disp: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match neg:
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case True{}: w5c_gpr_or(w5_gpr_try_ld(W5LRYes{disp,rB},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_rr64_if(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match same:
    case True{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or(w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_try_movq_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Mem{5,disp}: w5c_gpr_ld_if(w4c_is_neg_rbp(5,disp),disp,rB,i0,i1,r2,fnItems,acc)
    case X187Reg{+rA,64,False{}}: w5c_gpr_rr64_if(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_try_cmpq_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Imm{0,0}: w5c_gpr_or(w5b_g12_b(rB,w5_as_setcc(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_rr32_if(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match same:
    case True{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or(w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_try_movl_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Reg{+rA,32,False{}}: w5c_gpr_rr32_if(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_try_xorl_src(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match src:
    case X187Imm{1,0}: w5c_gpr_or(w5_g8_b(rB,w4b_as_imm_reg(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64_cmp(isCmpq: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isCmpq:
    case True{}: w5c_gpr_try_cmpq_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64(isMovq: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5c_gpr_try_movq_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op64_cmp(String.eq(op,"cmpq"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_op32_xor(isXor: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isXor:
    case True{}: w5c_gpr_try_xorl_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op32(isMovl: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovl:
    case True{}: w5c_gpr_try_movl_src(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op32_xor(String.eq(op,"xorl"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_wd(wd: U32, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match wd:
    case 64: w5c_gpr_op64(String.eq(op,"movq"),op,src,d,i0,i1,r2,fnItems,acc)
    case 32: w5c_gpr_op32(String.eq(op,"movl"),op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5_gpr_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{src,Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      w5c_gpr_wd(wd,op,src,d,i0,i1,r2,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      w5c_gpr_or(w5_gpr_try_jcc(W4BBranch{op,lbl},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5_gpr_peep(Con{i1,r2},fnItems,Con{i0,acc})""",
        "w5_gpr_step_direct",
    )

    # ------------------------------------------------------------------
    # 3b. w5b_peep zero-closure + w4_post_select idempotent skip-if-unchanged
    #     (for w4b_copy_peep, w5_gpr_peep, AND w5b_peep!)
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op1,"movl") && U32.is_eq(r1,rD) && U32.is_eq(r2,rD),
        u => w5b_peep(tail,fnItems,Con{i0,acc}),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_inst(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_movq(rA,rB,i0,rest,fnItems,acc),
        u => nt_choose(List<&2,X187Parsed>,w5b_is_cmp(op),
          v => w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc),
          v => w5b_peep(rest,fnItems,Con{i0,acc})))
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movzbl"),
        u => w5b_peep_movzbl(rD,i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movq"),
        u => w5b_peep_apply(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case PInst{X187Instruction{+op,Con{X187Target{+l1},Nil{}}}}:
      w5b_peep_apply(w5b_try_jcc_jmp(op,l1,rest),i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,_}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_cmp(op),
        u => w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc),
        u => w5b_peep(rest,fnItems,Con{i0,acc}))
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+rest}: w5b_peep_inst(i0,rest,fnItems,acc)

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f2 = w5_flat_rev_seq(w4b_copy_peep(f1,f1,[]),[])
  +f3 = w5_flat_rev_seq(w4b_copy_peep(f2,f2,[]),[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +f4 = w4_peep_flat([peep4],[])
  +shrunk = w4_leaf_shrink(f4,peep4)
  +f4s = w4_peep_flat([shrunk],[])
  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +prom = w5b_run_leaf_promote(Bool.not(hasCall) && hasNegRbp,licm)
  +f5 = w5_run_rot(hasLbl,prom)
  +g1 = w5_gpr_peep(f5,f5,[])
  +g2 = w5_gpr_peep(g1,g1,[])
  +g3 = w5_gpr_peep(g2,g2,[])
  +b1 = w5b_peep(g3,g3,[])
  +b1b = w5b_peep(b1,b1,[])
  +b2 = w5_flat_rev_seq(w4c_peep_cfg(b1b,b1b,[]),[])
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,b2)
  w4b_wrap_items(xmm,[])""",
        """@unsafe
def w5c_peep_mz_if(drop: Bool, +i0: X187Parsed, tail: List<&2,X187Parsed>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match drop:
    case True{}: w5b_peep(tail,fnItems,Con{i0,acc})
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_movzbl(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      w5c_peep_mz_if(U32.is_eq(r1,rD) && U32.is_eq(r2,rD) && String.eq(op1,"movl"),i0,tail,rest,fnItems,acc)
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_cmp_if(isCmp: Bool, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isCmp:
    case True{}: w5b_peep_apply(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc)
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_rr64_if(isMovq: Bool, +op: String, +rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5b_peep_movq(rA,rB,i0,rest,fnItems,acc)
    case False{}: w5c_bp_cmp_if(w5b_is_cmp(op),i0,rest,fnItems,acc)

@unsafe
def w5c_bp_mz_if(isMz: Bool, +rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMz:
    case True{}: w5b_peep_movzbl(rD,i0,rest,fnItems,acc)
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_ds_if(isMovq: Bool, +d1: U32, +rA: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match isMovq:
    case True{}: w5b_peep_apply(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc)
    case False{}: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep_inst(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      w5c_bp_rr64_if(String.eq(op,"movq"),op,rA,rB,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      w5c_bp_mz_if(String.eq(op,"movzbl"),rD,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      w5c_bp_ds_if(String.eq(op,"movq"),d1,rA,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+l1},Nil{}}}}:
      w5b_peep_apply(w5b_try_jcc_jmp(op,l1,rest),i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,_}}:
      w5c_bp_cmp_if(w5b_is_cmp(op),i0,rest,fnItems,acc)
    case _: w5b_peep(rest,fnItems,Con{i0,acc})

@unsafe
def w5b_peep(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,+rest}: w5b_peep_inst(i0,rest,fnItems,acc)

type W5BGprOut is Data:
  W5BGprUnchanged{}
  W5BGprChanged{+out: List<&2,X187Parsed>}

@unsafe
def w5c_lbl_build_if(hasLbl: Bool, items: List<&2,X187Parsed>) -> W5BLblTrie:
  match hasLbl:
    case True{}: w5c_lbl_build(items)
    case False{}: W5BLNil{}

@unsafe
def w5c_copy_peep2(r1: W5BPeepOut, +hasLbl: Bool, f1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BPeepOut{False{},_}: f1
    case W5BPeepOut{True{},seq2}:
      +f2 = w5_flat_rev_seq(seq2,[])
      w5_flat_rev_seq(w5c_peep_seq(w5c_copy_peep_t(f2,w5c_lbl_build_if(hasLbl,f2),[],False{})),[])

law w5c_gpr_peep_c:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  W5BGprOut

@unsafe
def w5c_gpr_or_c(res: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match res:
    case Some{out}: W5BGprChanged{out}
    case None{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_ld_c(neg: Bool, +disp: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match neg:
    case False{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case True{}: w5c_gpr_or_c(w5_gpr_try_ld(W5LRYes{disp,rB},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_rr64_c(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match same:
    case True{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or_c(w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_movq_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Mem{5,disp}: w5c_gpr_ld_c(w4c_is_neg_rbp(5,disp),disp,rB,i0,i1,r2,fnItems,acc)
    case X187Reg{+rA,64,False{}}: w5c_gpr_rr64_c(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_cmpq_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Imm{0,0}: w5c_gpr_or_c(w5b_g12_b(rB,w5_as_setcc(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_rr32_c(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match same:
    case True{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or_c(w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_movl_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Reg{+rA,32,False{}}: w5c_gpr_rr32_c(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_xorl_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Imm{1,0}: w5c_gpr_or_c(w5_g8_b(rB,w4b_as_imm_reg(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64_cmp_c(isCmpq: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isCmpq:
    case True{}: w5c_gpr_cmpq_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64_c(isMovq: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovq:
    case True{}: w5c_gpr_movq_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op64_cmp_c(String.eq(op,"cmpq"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_op32_xor_c(isXor: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isXor:
    case True{}: w5c_gpr_xorl_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op32_c(isMovl: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovl:
    case True{}: w5c_gpr_movl_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op32_xor_c(String.eq(op,"xorl"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_wd_c(wd: U32, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match wd:
    case 64: w5c_gpr_op64_c(String.eq(op,"movq"),op,src,d,i0,i1,r2,fnItems,acc)
    case 32: w5c_gpr_op32_c(String.eq(op,"movl"),op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_step_c(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match i0:
    case PInst{X187Instruction{+op,Con{src,Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      w5c_gpr_wd_c(wd,op,src,d,i0,i1,r2,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      w5c_gpr_or_c(w5_gpr_try_jcc(W4BBranch{op,lbl},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_peep_c(items,fnItems,acc):
  match items:
    case Nil{}: W5BGprUnchanged{}
    case Con{+i0,Con{+i1,+r2}}: w5c_gpr_step_c(i0,i1,r2,fnItems,acc)
    case Con{_,Nil{}}: W5BGprUnchanged{}

@unsafe
def w5c_gpr_pass3(r2: W5BGprOut, g1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r2:
    case W5BGprUnchanged{}: g1
    case W5BGprChanged{+g2}: w5_gpr_peep(g2,g2,[])

@unsafe
def w5c_gpr_pass2(r1: W5BGprOut, f5: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BGprUnchanged{}: f5
    case W5BGprChanged{+g1}: w5c_gpr_pass3(w5c_gpr_peep_c(g1,g1,[]),g1)

law w5c_bp_c:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  W5BGprOut

@unsafe
def w5c_bp_apply_c(hit: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match hit:
    case Some{rewritten}: W5BGprChanged{w5b_peep(rewritten,fnItems,acc)}
    case None{}: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_movq_c(+rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  +h = w4c_or_peep_opt(w5b_try_ror16(rA,rB,rest,fnItems),
    u => w4c_or_peep_opt(w5b_try_rol16(rA,rB,rest,fnItems),
      v => w4c_or_peep_opt(w5b_try_cmp_bounce(rA,rB,rest,fnItems),
        w => w4c_or_peep_opt(w5b_try_sel_bounce(rA,rB,rest,fnItems),
          z => w5b_try_spill_bounce(rA,rB,rest,fnItems)))))
  w5c_bp_apply_c(h,i0,rest,fnItems,acc)

@unsafe
def w5c_bp_mz_drop_c(drop: Bool, +i0: X187Parsed, tail: List<&2,X187Parsed>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match drop:
    case True{}: W5BGprChanged{w5b_peep(tail,fnItems,Con{i0,acc})}
    case False{}: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_movzbl_c(+rD: U32, +i0: X187Parsed, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match rest:
    case Con{PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}},+tail}:
      w5c_bp_mz_drop_c(U32.is_eq(r1,rD) && U32.is_eq(r2,rD) && String.eq(op1,"movl"),i0,tail,rest,fnItems,acc)
    case _: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_cmp_c(isCmp: Bool, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isCmp:
    case True{}: w5c_bp_apply_c(w5b_try_cmp_jcc(i0,rest,fnItems),i0,rest,fnItems,acc)
    case False{}: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_rr64_c(isMovq: Bool, +op: String, +rA: U32, +rB: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovq:
    case True{}: w5c_bp_movq_c(rA,rB,i0,rest,fnItems,acc)
    case False{}: w5c_bp_cmp_c(w5b_is_cmp(op),i0,rest,fnItems,acc)

@unsafe
def w5c_bp_mz_c(isMz: Bool, +rD: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMz:
    case True{}: w5c_bp_movzbl_c(rD,i0,rest,fnItems,acc)
    case False{}: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_ds_c(isMovq: Bool, +d1: U32, +rA: U32, +i0: X187Parsed, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovq:
    case True{}: w5c_bp_apply_c(w5b_try_dup_square(d1,rA,rest,fnItems),i0,rest,fnItems,acc)
    case False{}: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_inst_c(+i0: X187Parsed, +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match i0:
    case PInst{X187Instruction{+op,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}}:
      w5c_bp_rr64_c(String.eq(op,"movq"),op,rA,rB,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Reg{_,8,False{}},Con{X187Reg{+rD,32,False{}},Nil{}}}}}:
      w5c_bp_mz_c(String.eq(op,"movzbl"),rD,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Mem{5,+d1},Con{X187Reg{+rA,64,False{}},Nil{}}}}}:
      w5c_bp_ds_c(String.eq(op,"movq"),d1,rA,i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+l1},Nil{}}}}:
      w5c_bp_apply_c(w5b_try_jcc_jmp(op,l1,rest),i0,rest,fnItems,acc)
    case PInst{X187Instruction{+op,_}}:
      w5c_bp_cmp_c(w5b_is_cmp(op),i0,rest,fnItems,acc)
    case _: w5c_bp_c(rest,fnItems,Con{i0,acc})

@unsafe
def w5c_bp_c(items,fnItems,acc):
  match items:
    case Nil{}: W5BGprUnchanged{}
    case Con{+i0,+rest}: w5c_bp_inst_c(i0,rest,fnItems,acc)

@unsafe
def w5c_bp_pass2(r1: W5BGprOut, g3: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BGprUnchanged{}: g3
    case W5BGprChanged{+b1}: w5b_peep(b1,b1,[])

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f3 = w5c_copy_peep2(w5c_copy_peep_t(f1,w5c_lbl_build_if(hasLbl,f1),[],False{}),hasLbl,f1)
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +f4 = w4_peep_flat([peep4],[])
  +shrunk = w4_leaf_shrink(f4,peep4)
  +f4s = w4_peep_flat([shrunk],[])
  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +prom = w5b_run_leaf_promote(Bool.not(hasCall) && hasNegRbp,licm)
  +f5 = w5_run_rot(hasLbl,prom)
  +g3 = w5c_gpr_pass2(w5c_gpr_peep_c(f5,f5,[]),f5)
  +b1b = w5c_bp_pass2(w5c_bp_c(g3,g3,[]),g3)
  +b2 = w5_flat_rev_seq(w4c_peep_cfg(b1b,b1b,[]),[])
  +xmm = w5_run_xmm(hasXmm,hasNegRbp,b2)
  w4b_wrap_items(xmm,[])""",
        "w4_post_select_skip_unchanged",
    )

    # ------------------------------------------------------------------
    # 4. x187_e_single_pair_match_family (preserving W5B-R3 shift prefix + movzwl family 18)
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,U32.is_eq(family,9),u => x187_e_branch(operand,code,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,8),u => nt_choose(X187Encoded,x187_e_reg(operand,64,False{}),v =>
    x187_e_ok(nt_append(U32,x187_e_prefix(0,False{},0,operand,False{}),[U32.add(code,U32.mod(x187_e_index(operand),8))])),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,5) && x187_e_rm(operand,8,False{}),u =>
    x187_e_modrm(0,[15,code],False{},0,operand,x187_e_byte(operand),[],offset),u => x187_e_error())))

@unsafe
def x187_e_pair(+src: X187Operand, +dst: X187Operand, +family: U32, +width: U32,
    +code: U32, +extra: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,U32.is_eq(family,1),u => x187_e_alu(src,dst,width,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,2),u => x187_e_mov(src,dst,width,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,15),u => x187_e_movabs(src,dst),u =>
  nt_choose(X187Encoded,U32.is_eq(family,3),u => x187_e_shift(src,dst,width,extra,prefix,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,4),u => x187_e_imul(src,dst,width,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,6),u => nt_choose(X187Encoded,x187_e_reg(dst,32,False{}) && x187_e_rm(src,8,False{}),v =>
    x187_e_modrm(0,[15,182],False{},x187_e_index(dst),src,x187_e_byte(src),[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,7),u => x187_e_sse(src,dst,prefix,code,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,10),u => x187_e_movd(src,dst,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,11),u => nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),v =>
    x187_e_modrm(243,[15,42],True{},x187_e_index(dst),src,False{},[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,12),u => nt_choose(X187Encoded,x187_e_reg(dst,64,False{}) &&
    x187_e_rm(src,64,False{}) && Bool.not(x187_e_reg(src,64,False{})),v =>
      x187_e_modrm(0,[141],True{},x187_e_index(dst),src,False{},[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,13),u => x187_e_test(src,dst,width,offset),u =>
    nt_choose(X187Encoded,U32.is_eq(family,16),v => x191cm_pair(src,dst,width,code,offset),v =>
    nt_choose(X187Encoded,U32.is_eq(family,18) && x187_e_reg(dst,32,False{}) && x187_e_rm(src,32,False{}),w =>
      x187_e_modrm(0,[15,183],False{},x187_e_index(dst),src,False{},[],offset),w => x187_e_error())))))))))))))""",
        """@unsafe
def w5c_es_f8(ok: Bool, +operand: X187Operand, +code: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_ok(nt_append(U32,x187_e_prefix(0,False{},0,operand,False{}),[U32.add(code,U32.mod(x187_e_index(operand),8))]))
    case False{}: x187_e_error()

@unsafe
def w5c_es_f5(ok: Bool, +operand: X187Operand, +code: U32, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,code],False{},0,operand,x187_e_byte(operand),[],offset)
    case False{}: x187_e_error()

@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match family:
    case 9: x187_e_branch(operand,code,extra,offset)
    case 8: w5c_es_f8(x187_e_reg(operand,64,False{}),operand,code)
    case 5: w5c_es_f5(x187_e_rm(operand,8,False{}),operand,code,offset)
    case _: x187_e_error()

@unsafe
def w5c_ep_f6(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,182],False{},x187_e_index(dst),src,x187_e_byte(src),[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f11(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(243,[15,42],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f12(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[141],True{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def w5c_ep_f18(ok: Bool, +src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_modrm(0,[15,183],False{},x187_e_index(dst),src,False{},[],offset)
    case False{}: x187_e_error()

@unsafe
def x187_e_pair(+src: X187Operand, +dst: X187Operand, +family: U32, +width: U32,
    +code: U32, +extra: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  match family:
    case 1: x187_e_alu(src,dst,width,extra,offset)
    case 2: x187_e_mov(src,dst,width,offset)
    case 15: x187_e_movabs(src,dst)
    case 3: x187_e_shift(src,dst,width,extra,prefix,offset)
    case 4: x187_e_imul(src,dst,width,offset)
    case 6: w5c_ep_f6(x187_e_reg(dst,32,False{}) && x187_e_rm(src,8,False{}),src,dst,offset)
    case 7: x187_e_sse(src,dst,prefix,code,offset)
    case 10: x187_e_movd(src,dst,offset)
    case 11: w5c_ep_f11(x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),src,dst,offset)
    case 12: w5c_ep_f12(x187_e_reg(dst,64,False{}) && x187_e_rm(src,64,False{}) && Bool.not(x187_e_reg(src,64,False{})),src,dst,offset)
    case 13: x187_e_test(src,dst,width,offset)
    case 16: x191cm_pair(src,dst,width,code,offset)
    case 18: w5c_ep_f18(x187_e_reg(dst,32,False{}) && x187_e_rm(src,32,False{}),src,dst,offset)
    case _: x187_e_error()""",
        "x187_e_single_pair_match_family",
    )

    # ------------------------------------------------------------------
    # 5. Hot Patricia Trie Fast-Paths: p131i_insert, index_find, w5c3_find, p113k_join_node
    #    Eliminate redundant split==0 / mask==0 checks, Bool boxing, and index_node/index_leaf/index_join hops.
    # ------------------------------------------------------------------
    src = replace_exact(
        src,
        """@unsafe
def w5_idx_find_branch(goLeft: Bool, left: KDef, right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match goLeft:
    case True{}: index_find(left, name, hash, bits)
    case False{}: index_find(right, name, hash, bits)

@unsafe
def w5_idx_find_node(isLeaf: Bool, +stored: U32, +mask: U32, +left: KDef, +right: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match isLeaf:
    case True{}: w5_idx_bucket_if(U32.is_eq(stored, hash), [left, right], name)
    case False{}: w5_idx_find_branch(U32.is_eq(U32.and(hash, mask), 0), left, right, name, hash, bits)

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
    case KIndexNode{stored, +mask, +left, +right}:
      w5_idx_find_node(U32.is_eq(mask, 0), stored, mask, left, right, name, hash, bits)""",
        """@unsafe
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
      w5c_idx_find_lr(U32.and(hash, mask), left, right, name, hash, bits)""",
        "index_find_direct_u32",
    )

    src = replace_exact(
        src,
        """@unsafe
def w5c3_find_lr(go_left: Bool, +left: KDef, +right: KDef, +name: String, +hash: U32) -> KDef:
  match go_left:
    case True{}: w5c3_find(left, name, hash)
    case False{}: w5c3_find(right, name, hash)

@unsafe
def w5c3_find_node(zero_mask: Bool, +stored: U32, +mask: U32, +left: KDef, +right: KDef, +name: String, +hash: U32) -> KDef:
  match zero_mask:
    case True{}: w5c3_find_leaf(U32.is_eq(stored, hash), [left, right], name)
    case False{}: w5c3_find_lr(U32.is_eq(U32.and(hash, mask), 0), left, right, name, hash)

@unsafe
def w5c3_find_kdef_t0(t0: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match t0:
    case True{}: w5c3_find_leaf(U32.is_eq(arity, hash), ctors, name)
    case False{}: w5c3_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash)

@unsafe
def w5c3_find_kdef(is_abs: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match is_abs:
    case True{}: missing()
    case False{}: w5c3_find_kdef_t0(U32.is_eq(templates, 0), arity, templates, ctors, name, hash)

@unsafe
def w5c3_find(tree, name, hash):
  match tree:
    case KIndexLeaf{stored, bucket}: w5c3_find_leaf(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, +mask, +left, +right}: w5c3_find_node(U32.is_eq(mask, 0), stored, mask, left, right, name, hash)
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5c3_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash)""",
        """@unsafe
def w5c_find_lr(bit: U32, left: KDef, right: KDef, +name: String, +hash: U32) -> KDef:
  match bit:
    case 0: w5c3_find(left, name, hash)
    case _: w5c3_find(right, name, hash)

@unsafe
def w5c3_find_kdef_t0(t0: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match t0:
    case True{}: w5c3_find_leaf(U32.is_eq(arity, hash), ctors, name)
    case False{}: w5c3_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash)

@unsafe
def w5c3_find_kdef(is_abs: Bool, +arity: U32, +templates: U32, +ctors: List<&2,KDef>, +name: String, +hash: U32) -> KDef:
  match is_abs:
    case True{}: missing()
    case False{}: w5c3_find_kdef_t0(U32.is_eq(templates, 0), arity, templates, ctors, name, hash)

@unsafe
def w5c3_find(tree, name, hash):
  match tree:
    case KIndexLeaf{stored, bucket}: w5c3_find_leaf(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}: w5c_find_lr(U32.and(hash, mask), left, right, name, hash)
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      w5c3_find_kdef(String.eq(kind, "Absent"), arity, templates, ctors, name, hash)""",
        "w5c3_find_direct_u32",
    )

    src = replace_exact(
        src,
        """@unsafe
def w5_p131i_leaf(isZero: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32, bucket: List<&2, KDef>) -> KDef:
  match isZero:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

@unsafe
def w5_p131i_br(goLeft: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32) -> KDef:
  match goLeft:
    case True{}: index_node(stored, split, p131i_insert(left, d, hash), right)
    case False{}: index_node(stored, split, left, p131i_insert(right, d, hash))

@unsafe
def w5_p131i_in(inSub: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match inSub:
    case True{}: w5_p131i_br(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash)
    case False{}: index_join(tree, d, hash, index_split_bit(diff))

@unsafe
def w5_p131i_node(isZero: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match isZero:
    case True{}: p131i_original_set(tree, d, hash, 32)
    case False{}: w5_p131i_in(U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0), tree, stored, split, left, right, d, hash, diff)

@unsafe
def p131i_insert(tree, d, hash):
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      +mask = index_split_bit(U32.xor(hash, stored))
      w5_p131i_leaf(U32.is_eq(mask, 0), tree, d, hash, mask, bucket)
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      w5_p131i_node(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, diff)""",
        """@unsafe
def w5c_p131i_join(bit: U32, +stored: U32, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match bit:
    case 0: KIndexNode{stored, mask, KIndexLeaf{hash, [d]}, tree}
    case _: KIndexNode{stored, mask, tree, KIndexLeaf{hash, [d]}}

@unsafe
def w5c_p131i_leaf(+mask: U32, +tree: KDef, +d: KDef, +hash: U32, +stored: U32, bucket: List<&2, KDef>) -> KDef:
  match mask:
    case 0: KIndexLeaf{hash, Con{d, index_remove(bucket, dn(d))}}
    case _: w5c_p131i_join(U32.and(hash, mask), stored, tree, d, hash, mask)

@unsafe
def w5c_p131i_br(bit: U32, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32) -> KDef:
  match bit:
    case 0: KIndexNode{stored, split, p131i_insert(left, d, hash), right}
    case _: KIndexNode{stored, split, left, p131i_insert(right, d, hash)}

@unsafe
def w5c_p131i_in(outside: U32, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match outside:
    case 0: w5c_p131i_br(U32.and(hash, split), stored, split, left, right, d, hash)
    case _:
      +m = index_split_bit(diff)
      w5c_p131i_join(U32.and(hash, m), stored, tree, d, hash, m)

@unsafe
def p131i_insert(tree, d, hash):
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      w5c_p131i_leaf(index_split_bit(U32.xor(hash, stored)), tree, d, hash, stored, bucket)
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      w5c_p131i_in(U32.and(diff, U32.sub(split, 1)), tree, stored, split, left, right, d, hash, diff)""",
        "p131i_insert_direct_u32",
    )

    src = replace_exact(
        src,
        """@unsafe
def p113k_join_nn(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c2_jnn_z(U32.is_eq(lm, 0) || U32.is_eq(rm, 0), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jn_lm0(lm0: Bool, +lh: U32, +lm: U32, +la: KDef, +lb: KDef, +rh: U32, +right: KDef, +out: KDef) -> KDef:
  match lm0:
    case True{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))
    case False{}: w5c2_jnn_lt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right, out)

@unsafe
def w5c2_jn_abs(is_abs: Bool, +la: KDef, +lb: KDef, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: out
    case False{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))

@unsafe
def p113k_join_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh, _}:
      w5c2_jn_lm0(U32.is_eq(lm, 0), lh, lm, la, lb, rh, right, out)
    case KIndexNode{rh, rm, ra, rb}:
      p113k_join_nn(lh, lm, la, lb, left, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jn_abs(String.eq(kind, "Absent"), la, lb, right, out)""",
        """@unsafe
def p113k_join_nn(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c2_jnn_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)

@unsafe
def w5c2_jn_abs(is_abs: Bool, +la: KDef, +lb: KDef, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: out
    case False{}: p113k_join_go(lb, right, p113k_join_go(la, right, out))

@unsafe
def p113k_join_node(+lh: U32, +lm: U32, +la: KDef, +lb: KDef, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match right:
    case KIndexLeaf{rh, _}:
      w5c2_jnn_lt_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(lm, 1)), 0), rh, lm, la, lb, right, out)
    case KIndexNode{rh, rm, ra, rb}:
      w5c2_jnn_eq(U32.is_eq(lm, rm), lh, lm, la, lb, left, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jn_abs(String.eq(kind, "Absent"), la, lb, right, out)""",
        "p113k_join_node_direct",
    )

    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, type=Path)
    ap.add_argument("--dst", required=True, type=Path)
    args = ap.parse_args()

    src_text = args.src.read_text()
    out_text = apply_patches(src_text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out_text)
    print(f"Wrote {args.dst} ({len(out_text)} bytes)", flush=True)


if __name__ == "__main__":
    main()
