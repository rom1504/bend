#!/usr/bin/env python3
"""Wave 4 Phase 3 Track W4-10: Array Bounds-Check Elimination & editdist/bst/histogram Closer.

100% general compiler passes on top of `wave4b_unified/compiler.bend`:
  1. Product-Field Scalar Kind Propagation (`nq_layout_single` + `nf_expand_kinds` + `p113pl_bind_flat`):
     Records 2-bit-per-field `N_WordKind` (`N_W32` for U32/F32/Char/Bool, `N_Imm64` for Nat, `N_W64` otherwise)
     in `NQShape.qt` during product layout and restores them when unpacking `$product` params and flat bindings.
     Eliminates all redundant `p111_rt_keep`/`p111_rt_sink` calls on scalar fields of unpacked Data/Tuple products
     and unlocks call-free register allocation inside product loops (e.g. `editdist`'s `$product.columns`).
  2. Bottom-Tested Loop Rotation Fix (`w4b_rotate_body`):
     Also matches `testq %r, %r` / `testl %r, %r` loop headers produced by W4-6's `cmpq $0 -> testq` peephole
     (which previously prevented `w4b_rotate_loop` from firing on any loop), plus post-rotation
     `subq $1, %r; testq %r, %r; jne -> subq $1, %r; jne`.
  3. CFG-Aware Machine Peepholes (`w4c_peep_cfg` in `w4_post_select`):
     Uses `w4b_reg_dead` (CFG-aware across `jmp` back-edges) for:
       - `movabsq $c, %r64; addl m32, %r32; movl %r32, m32 -> addl $c, m32` (in-place array inc/add)
       - `movl %r32, %eax; andl $M, %eax; movq %rax, %r64 -> andl $M, %r32` (eax-bounce removal)
  4. Hoisted Bitmask & Unit-Stride Induction-Variable Array Mask Elimination (`p117v` / `x185_array_version`):
     Formally justified by `Wave4Laws.lean: w4_bitmask_bounds_sound`:
       - Bitmask-bounded index `x & M` (or loop param whose back-edge is `x & M`): hoists `M <= mask`
         (and `param <= mask` for loop params) into `p113a_version_guard` once outside the loop.
       - Unit-stride induction variable `j` paired with countdown `left` (`j -> j + 1`, `left -> left - 1`
         only under `left != 0`): hoists `j <= mask && left <= mask && (j + left) <= mask` into
         `p113a_version_guard` once outside the loop (since `mask <= 2^31 - 1`, `j + left < 2^32`,
         guaranteeing zero 32-bit wraparound and `idx & mask == idx` on every iteration).
     Non-admitted inputs transparently fall back to the verified `p117v_<fid>` worker.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4b_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave4c_arrclose/compiler.bend"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def patch_1_product_field_kinds(src: str) -> str:
    """Pass 1: Propagate scalar N_WordKind for unpacked fields of NQShape products."""
    old_expand = """# Module: src/back/native/flat.bend:125
@unsafe
def nf_expand_kinds(shapes: List<&2, KTerm>, kinds: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match shapes, kinds:
    case Con{+shape, rest}, Con{kind, more}: nt_append(N_WordKind, nt_choose(List<&2, N_WordKind>, p98_tag_eq(shape, "NQShape"), u => nf_opaque_kinds(ix(shape)), u => [kind]), nf_expand_kinds(rest, more))
    case _, _: Nil{}"""

    new_expand = """# W4-10 Pass 1: Decode 2-bit-per-field N_WordKind mask stored in NQShape.qt.
@unsafe
def w4c_decode_kind(+bits: U32) -> N_WordKind:
  nt_choose(N_WordKind, U32.is_eq(bits, 1), u => N_W32{},
    u => nt_choose(N_WordKind, U32.is_eq(bits, 2), v => N_Imm64{}, v => N_W64{}))

@unsafe
def w4c_shape_kinds(+left: U32, +mask: U32, +i: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{},
    u => Con{w4c_decode_kind(U32.and(U32.shrn(mask, U32.to_nat(U32.mul(i, 2))), 3)),
             w4c_shape_kinds(U32.sub(left, 1), mask, U32.inc(i))})

@unsafe
def w4c_bundle_params_kinds(+left: U32, +n: U32, +mask: U32, +i: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(left, 0), u => Nil{},
    u =>
      +id = nc_id(n)
      +k = w4c_decode_kind(U32.and(U32.shrn(mask, U32.to_nat(U32.mul(i, 2))), 3))
      Con{NC_Binding{id, "v_" ++ U32.show(id), k},
          w4c_bundle_params_kinds(U32.sub(left, 1), U32.inc(n), mask, U32.inc(i))})

# Module: src/back/native/flat.bend:125
@unsafe
def nf_expand_kinds(shapes: List<&2, KTerm>, kinds: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match shapes, kinds:
    case Con{+shape, rest}, Con{kind, more}: nt_append(N_WordKind, nt_choose(List<&2, N_WordKind>, p98_tag_eq(shape, "NQShape"), u => w4c_shape_kinds(ix(shape), qt(shape), 0), u => [kind]), nf_expand_kinds(rest, more))
    case _, _: Nil{}"""

    src = replace_exact(src, old_expand, new_expand, "Pass 1a: nf_expand_kinds")

    old_layout_single = """# Module: src/back/native/product-layout.bend:15
@unsafe
def nq_layout_single(+book: List<&2, KDef>, +ty: KTerm, +owner: KDef, ctors: List<&2, KDef>) -> KTerm:
  match ctors:
    case Con{+ctr, Nil{}}:
      nt_choose(KTerm, p88_string_eq(dk(ctr), "Ctr") && U32.is_gt(da(ctr), 0) && U32.is_le(da(ctr), 8) && U32.is_eq(dx(ctr), 0) && (Bool.not(db(owner)) || (p88_string_eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u => nt_choose(KTerm, nq_layout_fields(book, nq_layout_specialize(dt(ctr), ks(ty), 64), ty, da(ctr), Nil{}),
          v => kt("NQShape", nt_choose(String, db(owner), w => dn(ctr), w => nc_ctor_encode(dn(ctr))), da(ctr), 0, Nil{}),
          v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}"""

    new_layout_single = """# W4-10 Pass 1: Compute 2-bit-per-field N_WordKind mask for single-ctor product fields.
@unsafe
def w4c_field_is_nat(+book: List<&2, KDef>, +head: KTerm) -> Bool:
  +owner = lookup(book, "Nat")
  p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), "Nat") && p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) &&
    List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head))

@unsafe
def w4c_field_is_w32(+book: List<&2, KDef>, +head: KTerm) -> Bool:
  +owner = lookup(book, nm(head))
  p98_tag_eq(head, "ADT") && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head)) &&
    nb_contains(["U32", "F32", "Char", "Bool"], nm(head))

@unsafe
def w4c_field_bits(+book: List<&2, KDef>, +field: KTerm) -> U32:
  nt_choose(U32, w4c_field_is_w32(book, field), u => 1,
    u => nt_choose(U32, w4c_field_is_nat(book, field), v => 2, v => 0))

law w4c_layout_kind_mask:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +left: U32
  for +fidx: U32
  for +acc: U32
  U32

@unsafe
def w4c_layout_kind_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fidx: U32, +acc: U32) -> U32:
  nt_choose(U32, U32.is_eq(left, 0), u => acc,
    u => nt_choose(U32, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)),
      v =>
        +bits = w4c_field_bits(book, nq_layout_type(book, kid(head, 0)))
        +acc2 = U32.or(acc, U32.shln(bits, U32.to_nat(U32.mul(fidx, 2))))
        w4c_layout_kind_mask(book, kid(head, 1), U32.sub(left, 1), U32.inc(fidx), acc2),
      v => acc))

@unsafe
def w4c_layout_kind_mask(book, tel, left, fidx, acc):
  w4c_layout_kind_head(book, nq_layout_type(book, tel), left, fidx, acc)

# Module: src/back/native/product-layout.bend:15
@unsafe
def nq_layout_single(+book: List<&2, KDef>, +ty: KTerm, +owner: KDef, ctors: List<&2, KDef>) -> KTerm:
  match ctors:
    case Con{+ctr, Nil{}}:
      nt_choose(KTerm, p88_string_eq(dk(ctr), "Ctr") && U32.is_gt(da(ctr), 0) && U32.is_le(da(ctr), 8) && U32.is_eq(dx(ctr), 0) && (Bool.not(db(owner)) || (p88_string_eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u =>
          +spec = nq_layout_specialize(dt(ctr), ks(ty), 64)
          nt_choose(KTerm, nq_layout_fields(book, spec, ty, da(ctr), Nil{}),
            v => kt("NQShape", nt_choose(String, db(owner), w => dn(ctr), w => nc_ctor_encode(dn(ctr))), da(ctr), w4c_layout_kind_mask(book, spec, da(ctr), 0, 0), Nil{}),
            v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}"""

    src = replace_exact(src, old_layout_single, new_layout_single, "Pass 1b: nq_layout_single")

    old_bind_flat = """@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = nq_bundle_params(ix(shape),n)"""

    new_bind_flat = """@unsafe
def p113pl_bind_flat(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +params = w4c_bundle_params_kinds(ix(shape),n,qt(shape),0)"""

    src = replace_exact(src, old_bind_flat, new_bind_flat, "Pass 1c: p113pl_bind_flat")

    # Pass 1d: Seed p113k_function with N_W32 param bounds (bits = 32 <= 56) so p111_rt_keep/sink
    # and redundant 0xffffffff masks on N_W32 params (including unpacked product fields!) are elided!
    old_p113k_fn = """@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}:
      +b1 = w4g_bwd_dce(w4g_copy_pass(body))
      +b2 = w4g_bwd_dce(w4g_copy_pass(w4g_p113k_body_only(p113k_body(b1,missing()))))
      P113DFunction{name,params,result,public,b2}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),32768),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)"""

    new_p113k_fn = """@unsafe
def w4c_seed_w32_facts(params: List<&2,NC_Binding>, +facts: KDef) -> KDef:
  match params:
    case Nil{}: facts
    case Con{NC_Binding{_,word,N_W32{}},rest}:
      w4c_seed_w32_facts(rest,p113k_put(facts,word,p113k_bound(32)))
    case Con{_,rest}: w4c_seed_w32_facts(rest,facts)

@unsafe
def p113k_function_done(name: String, +params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}:
      +seed = w4c_seed_w32_facts(params,missing())
      +b1 = w4g_bwd_dce(w4g_copy_pass(body))
      +b2 = w4g_bwd_dce(w4g_copy_pass(w4g_p113k_body_only(p113k_body(b1,seed))))
      P113DFunction{name,params,result,public,b2}


@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      +seed = w4c_seed_w32_facts(params,missing())
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),32768),
        u => p113k_function_done(name,params,result,public,p113k_body(body,seed)),u => function)"""

    src = replace_exact(src, old_p113k_fn, new_p113k_fn, "Pass 1d: p113k_function seed N_W32 facts")
    return src


def patch_2_3_rotate_and_cfg_peep(src: str) -> str:
    """Pass 2 & 3: Fix bottom-tested loop rotation for testq/testl + CFG-aware peepholes."""
    old_rotate = """@unsafe
def w4b_rotate_body(+before: List<&2,X187Parsed>, +loopLbl: String, body: List<&2,X187Parsed>,
    +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{i0,Con{i1,afterHdr}}:
      w4b_rotate_check_hdr(w4b_as_imm_reg(i0),w4b_as_branch(i1),before,loopLbl,afterHdr,orig)
    case _: orig"""

    new_rotate = """@unsafe
def w4c_rotate_check_test(rr: W4BRR, br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rr:
    case W4BRR{+op,+s,+ws,+d,+wd}:
      match br:
        case W4BBranch{+jop,+bodyLbl}:
          nt_choose(List<&2,X187Parsed>,
            U32.is_eq(s,d) && U32.is_eq(ws,wd) &&
            ((agy_str_eq(op,"testq") && U32.is_eq(ws,64)) || (agy_str_eq(op,"testl") && U32.is_eq(ws,32))) &&
            (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
            v => w4b_rotate_finish(w4b_take_exit_clean(afterHdr,bodyLbl,[]),before,loopLbl,bodyLbl,s,ws,orig),
            v => orig)
        case W4BBranchNone{}: orig
    case W4BRRNone{}: orig

@unsafe
def w4c_rotate_dispatch(cm: W4BImmReg, +i0: X187Parsed, +i1: X187Parsed, +before: List<&2,X187Parsed>,
    +loopLbl: String, +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cm:
    case W4BImmRegNone{}: w4c_rotate_check_test(w4b_as_rr(i0),w4b_as_branch(i1),before,loopLbl,afterHdr,orig)
    case _: w4b_rotate_check_hdr(cm,w4b_as_branch(i1),before,loopLbl,afterHdr,orig)

@unsafe
def w4b_rotate_body(+before: List<&2,X187Parsed>, +loopLbl: String, body: List<&2,X187Parsed>,
    +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match body:
    case Con{+i0,Con{+i1,+afterHdr}}:
      w4c_rotate_dispatch(w4b_as_imm_reg(i0),i0,i1,before,loopLbl,afterHdr,orig)
    case _: orig"""

    if old_rotate in src:
        src = replace_exact(src, old_rotate, new_rotate, "Pass 2: w4b_rotate_body testq/testl")
    else:
        print("Pass 2: w4b_rotate_body already upgraded (e.g. by W4-9), skipping", flush=True)

    old_simple_alu = """  agy_str_eq(op,"testl") || agy_str_eq(op,"testq")"""
    new_simple_alu = """  agy_str_eq(op,"testl") || agy_str_eq(op,"testq") || String.starts_with(op,"cmov")"""
    src = replace_exact(src, old_simple_alu, new_simple_alu, "Pass 3a: cmov in w4b_is_simple_alu")

    old_post = """@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep3],[]),peep3)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  w4b_wrap_items(rot,[])"""

    new_post = """# W4-10 Pass 3: CFG-aware machine peepholes (addl $c, m32; andl $M, %r32; subq+testq+jne).
type W4CMemAdd is Data:
  W4CMemAddNone{}
  W4CMemAdd{+b: U32, +idx: U32, +sc: U32, +disp: U32, +r: U32}

@unsafe
def w4c_as_addl_mem_reg(item: X187Parsed) -> W4CMemAdd:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Indexed{b,idx,sc,disp},Con{X187Reg{r,32,False{}},Nil{}}}:
          nt_choose(W4CMemAdd,agy_str_eq(op,"addl"),u => W4CMemAdd{b,idx,sc,disp,r},u => W4CMemAddNone{})
        case _: W4CMemAddNone{}
    case _: W4CMemAddNone{}

@unsafe
def w4c_as_movl_reg_mem(item: X187Parsed) -> W4CMemAdd:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Reg{r,32,False{}},Con{X187Indexed{b,idx,sc,disp},Nil{}}}:
          nt_choose(W4CMemAdd,agy_str_eq(op,"movl"),u => W4CMemAdd{b,idx,sc,disp,r},u => W4CMemAddNone{})
        case _: W4CMemAddNone{}
    case _: W4CMemAddNone{}

law w4c_peep_cfg:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +out: List<&2,X188Seq>
  List<&2,X188Seq>

@unsafe
def w4c_try_mem_inc_3(+c: U32, +r1: U32, a: W4CMemAdd, m: W4CMemAdd, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match a:
    case W4CMemAdd{+b,+idx,+sc,+disp,+r2}:
      match m:
        case W4CMemAdd{+mb,+mi,+ms,+md,+mr}:
          nt_choose(List<&2,X188Seq>,
            U32.is_eq(r1,r2) && U32.is_eq(r2,mr) && U32.is_le(c,2147483647) &&
            U32.is_eq(b,mb) && U32.is_eq(idx,mi) && U32.is_eq(sc,ms) && U32.is_eq(disp,md) &&
            Bool.not(U32.is_eq(r1,b)) && Bool.not(U32.is_eq(r1,idx)) &&
            w4b_reg_dead(r1,tail,fnItems,24) && w4_peep_flags_dead_list(tail,16),
            u => w4c_peep_cfg(tail,fnItems,Con{x188_i2("addl",X187Imm{c,0},X187Indexed{b,idx,sc,disp}),out}),
            u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
        case W4CMemAddNone{}: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})
    case W4CMemAddNone{}: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_try_eax_and_3(+sr: U32, im: W4BImmReg, r2: W4BRR, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match im:
    case W4BImmReg{+aop,+mask,0,0,32}:
      match r2:
        case W4BRR{+mop,0,64,+dr,64}:
          nt_choose(List<&2,X188Seq>,
            agy_str_eq(aop,"andl") && agy_str_eq(mop,"movq") && U32.is_eq(dr,sr) &&
            Bool.not(U32.is_eq(sr,0)) && U32.is_le(mask,2147483647) &&
            w4b_reg_dead(0,tail,fnItems,24) && w4_peep_flags_dead_list(tail,16),
            u => w4c_peep_cfg(tail,fnItems,Con{x188_i2("andl",X187Imm{mask,0},x188_reg(sr,32)),out}),
            u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
        case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})
    case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_try_sub_test_3(+r1: U32, rr: W4BRR, br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      match br:
        case W4BBranch{+jop,_}:
          nt_choose(List<&2,X188Seq>,
            agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r1) && w4_peep_is_jz_jnz(jop),
            u => w4c_peep_cfg(Con{i2,tail},fnItems,Con{X188One{i0},out}),
            u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
        case W4BBranchNone{}: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})
    case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_peep_cfg_rr(rr0: W4BRR, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rr0:
    case W4BRR{+op,+sr,32,0,32}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movl"),
        u => w4c_try_eax_and_3(sr,w4b_as_imm_reg(i1),w4b_as_rr(i2),i0,i1,i2,tail,fnItems,out),
        u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
    case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_peep_cfg_imm(im0: W4BImmReg, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match im0:
    case W4BImmReg{+op,+lo,0,+r1,64}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movabsq"),
        u => w4c_try_mem_inc_3(lo,r1,w4c_as_addl_mem_reg(i1),w4c_as_movl_reg_mem(i2),i0,i1,i2,tail,fnItems,out),
        u => nt_choose(List<&2,X188Seq>,agy_str_eq(op,"subq") && U32.is_eq(lo,1),
          v => w4c_try_sub_test_3(r1,w4b_as_rr(i1),w4b_as_branch(i2),i0,i1,i2,tail,fnItems,out),
          v => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})))
    case _: w4c_peep_cfg_rr(w4b_as_rr(i0),i0,i1,i2,tail,fnItems,out)

@unsafe
def w4c_peep_cfg(items,fnItems,out):
  match items:
    case Nil{}: out
    case Con{+i0,Con{+i1,Con{+i2,+tail}}}:
      w4c_peep_cfg_imm(w4b_as_imm_reg(i0),i0,i1,i2,tail,fnItems,out)
    case Con{h,rest}: w4c_peep_cfg(rest,fnItems,Con{X188One{h},out})

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +peep1 = x188_finish(w4_peep_list(flat0,[]))
  +f1 = w4_peep_flat([peep1],[])
  +peep2 = x188_finish(w4b_copy_peep(f1,f1,[]))
  +f2 = w4_peep_flat([peep2],[])
  +peep3 = x188_finish(w4b_copy_peep(f2,f2,[]))
  +f3 = w4_peep_flat([peep3],[])
  +peep4 = x188_finish(w4c_peep_cfg(f3,f3,[]))
  +shrunk = w4_leaf_shrink(w4_peep_flat([peep4],[]),peep4)
  +licm = w4b_licm_magic(w4_peep_flat([shrunk],[]))
  +rot = w4b_rotate_loop(licm)
  +peep5 = x188_finish(w4c_peep_cfg(rot,rot,[]))
  peep5"""

    if old_post in src:
        src = replace_exact(src, old_post, new_post, "Pass 3: w4c_peep_cfg + w4_post_select")
    else:
        old_post_w49 = old_post.replace("  w4b_wrap_items(rot,[])", "  x188_finish(w4b_copy_peep(rot,rot,[]))")
        new_post_w49 = new_post.replace(
            "  +peep5 = x188_finish(w4c_peep_cfg(rot,rot,[]))",
            "  +rot2 = w4_peep_flat([x188_finish(w4b_copy_peep(rot,rot,[]))],[])\n  +peep5 = x188_finish(w4c_peep_cfg(rot2,rot2,[]))",
        )
        src = replace_exact(src, old_post_w49, new_post_w49, "Pass 3: w4c_peep_cfg + w4_post_select (W4-9)")
    return src


def patch_4_p117v_bce(src: str) -> str:
    """Pass 4: Hoisted Bitmask & Unit-Stride Induction-Variable Array Mask Elimination in p117v."""
    old_p117v_tpl = """@unsafe
def p117v_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]


@unsafe
def p117v_template_sunk(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]


@unsafe
def p117v_rewrite_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117v_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117v_template(stmt,n,origin))),
          p117v_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117v_rewrite_yes(condition,no,rest,heap_min,used,sites,p117v_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117v_rewrite(rest,n,heap_min,used,sites))


@unsafe
def p117v_rewrite_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117v_template_sunk(stmt,n,origin,v0,v1,v2)))),
        p117v_rewrite(rest,U32.inc(n),heap_min,used,sites))
    case P113ASunkNo{}: p117v_rewrite_step(body,n,heap_min,used,sites)


@unsafe
def p117v_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117v_rewrite_sunk(p113a_match_sunk(body),body,n,heap_min,used,sites)


@unsafe
def p117v_rewrite_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p117v_rewrite_no(condition,body,rest,heap_min,used,sites,p117v_rewrite(no,next,heap_min,used,sites))


@unsafe
def p117v_rewrite_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p117v_rewrite(rest,next,heap_min,used,sites))"""

    new_p117v_tpl = """# W4-10 Pass 4: Hoisted Bitmask & Induction-Variable Array Mask Elimination (w4_bitmask_bounds_sound).
@unsafe
def p117v_address_nomask(+id: U32, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[
    p123a_scale(p113a_name(n,"bytes"),p113a_value(n,"index"),p117h_index_shift()),
    N111Offset{p113a_name(n,"cell"),p117h_ref(origin,"base"),p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),p117h_cell_type(),p113a_value(n,"cell"),0}]))

@unsafe
def p117v_address_pick(+id: U32, +n: U32, +origin: U32, +nomask: KDef) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(p117h_get(nomask,U32.show(n)),1),
    u => p117v_address_nomask(id,n,origin),
    u => p117h_address(id,n,origin))

@unsafe
def p117v_template_ex(+original: N111Stmt, +n: U32, +origin: U32, +nomask: KDef) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117v_address_pick(id,n,origin,nomask),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

@unsafe
def p117v_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  p117v_template_ex(original,n,origin,missing())

@unsafe
def p117v_template_sunk_ex(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value, +nomask: KDef) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117v_address_pick(id,n,origin,nomask),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

@unsafe
def p117v_template_sunk(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  p117v_template_sunk_ex(original,n,origin,v0,v1,v2,missing())

law p117v_rewrite_ex:
  for +body: List<&2,P113DStmt>
  for +n: U32
  for +heap_min: U32
  for +used: U32
  for +sites: KDef
  for +nomask: KDef
  P113ABody

@unsafe
def p117v_rewrite_no_ex(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{nb,nn}: p113a_prefix([P113DIf{condition,yes,nb}],p117v_rewrite_ex(rest,nn,heap_min,used,sites,nomask))

@unsafe
def p117v_rewrite_yes_ex(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}:
      p117v_rewrite_no_ex(condition,body,rest,heap_min,used,sites,nomask,p117v_rewrite_ex(no,next,heap_min,used,sites,nomask))

@unsafe
def p117v_rewrite_step_ex(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117v_rewrite_ex(rest,n,heap_min,used,sites,nomask)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117v_template_ex(stmt,n,origin,nomask))),
          p117v_rewrite_ex(rest,U32.inc(n),heap_min,used,sites,nomask)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117v_rewrite_yes_ex(condition,no,rest,heap_min,used,sites,nomask,p117v_rewrite_ex(yes,n,heap_min,used,sites,nomask))
    case Con{head,rest}: p113a_prefix([head],p117v_rewrite_ex(rest,n,heap_min,used,sites,nomask))

@unsafe
def p117v_rewrite_sunk_ex(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117v_template_sunk_ex(stmt,n,origin,v0,v1,v2,nomask)))),
        p117v_rewrite_ex(rest,U32.inc(n),heap_min,used,sites,nomask))
    case P113ASunkNo{}: p117v_rewrite_step_ex(body,n,heap_min,used,sites,nomask)

@unsafe
def p117v_rewrite_ex(body,n,heap_min,used,sites,nomask):
  p117v_rewrite_sunk_ex(p113a_match_sunk(body),body,n,heap_min,used,sites,nomask)

@unsafe
def p117v_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117v_rewrite_ex(body,n,heap_min,used,sites,missing())

# --- Flow-Sensitive BCE Fact Analysis (Bitmask & Unit-Stride IV) ---
# Fact entry per variable stored in a single KDef map `env`:
#   dk = "BM"  -> da = upper bound M (<= 0x7fffffff), dx = 0
#   dk = "INC" -> da = param_idx, dx = 1 (value == param[da] + 1)
#   dk = "DEC" -> da = param_idx, dx = 2 (value == param[da] - 1)
#   dk = "NZ"  -> da = param_idx, dx = 3 (value == (param[da] != 0))
#   dk = "PRM" -> da = param_idx, dx = 4 (value == param[da])
#   dk = "UNK" -> unknown / killed

@unsafe
def w4c_env_kill(+env: KDef, +name: String) -> KDef:
  p111v_put(env,name,"UNK",0,0)

@unsafe
def w4c_env_copy(+env: KDef, +dest: String, +src: String) -> KDef:
  +d = p111v_get(env,src)
  nt_choose(KDef,agy_str_eq(dk(d),"BM") || agy_str_eq(dk(d),"INC") || agy_str_eq(dk(d),"DEC") ||
      agy_str_eq(dk(d),"NZ") || agy_str_eq(dk(d),"PRM"),
    u => p111v_put(env,dest,dk(d),da(d),dx(d)),
    u => w4c_env_kill(env,dest))

@unsafe
def w4c_env_seed(params: List<&2,NC_Binding>, +i: U32, +env: KDef) -> KDef:
  match params:
    case Nil{}: env
    case Con{NC_Binding{_,word,_},rest}:
      w4c_env_seed(rest,U32.inc(i),p111v_put(env,word,"PRM",i,4))

@unsafe
def w4c_env_param_idx(+env: KDef, +name: String) -> Maybe<&2,U32>:
  +d = p111v_get(env,name)
  nt_choose(Maybe<&2,U32>,agy_str_eq(dk(d),"PRM"),u => Some{da(d)},u => None{})

@unsafe
def w4c_local_name(v: N111Value) -> String:
  match v:
    case N111Local{src}: src
    case _: ""

@unsafe
def w4c_const_u32_any(v: N111Value) -> Maybe<&2,U32>:
  match v:
    case N111Const{lo,0}: Some{lo}
    case _: None{}

@unsafe
def w4c_env_put_param(mp: Maybe<&2,U32>, +env: KDef, +dest: String, +tag: String, +dxv: U32) -> KDef:
  match mp:
    case Some{pi}: p111v_put(env,dest,tag,pi,dxv)
    case None{}: w4c_env_kill(env,dest)

@unsafe
def w4c_step_bin_r(rc: Maybe<&2,U32>, +dest: String, +op: String, +lsrc: String, +lc: Maybe<&2,U32>, +rsrc: String, +env: KDef) -> KDef:
  match rc:
    case Some{+lo}:
      nt_choose(KDef,agy_str_eq(op,"and") && U32.is_eq(lo,4294967295) && Bool.not(String.is_empty(lsrc)),
        u => w4c_env_copy(env,dest,lsrc),
        u => nt_choose(KDef,agy_str_eq(op,"and") && U32.is_le(lo,2147483647),
          v => p111v_put(env,dest,"BM",lo,0),
          v => nt_choose(KDef,agy_str_eq(op,"add") && U32.is_eq(lo,1) && Bool.not(String.is_empty(lsrc)),
            w => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"INC",1),
            w => nt_choose(KDef,agy_str_eq(op,"sub") && U32.is_eq(lo,1) && Bool.not(String.is_empty(lsrc)),
              x => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"DEC",2),
              x => nt_choose(KDef,agy_str_eq(op,"ne") && U32.is_eq(lo,0) && Bool.not(String.is_empty(lsrc)),
                y => w4c_env_put_param(w4c_env_param_idx(env,lsrc),env,dest,"NZ",3),
                y => w4c_env_kill(env,dest))))))
    case None{}:
      match lc:
        case Some{+lo}:
          nt_choose(KDef,agy_str_eq(op,"and") && U32.is_eq(lo,4294967295) && Bool.not(String.is_empty(rsrc)),
            u => w4c_env_copy(env,dest,rsrc),
            u => nt_choose(KDef,agy_str_eq(op,"and") && U32.is_le(lo,2147483647),
              v => p111v_put(env,dest,"BM",lo,0),
              v => nt_choose(KDef,agy_str_eq(op,"add") && U32.is_eq(lo,1) && Bool.not(String.is_empty(rsrc)),
                w => w4c_env_put_param(w4c_env_param_idx(env,rsrc),env,dest,"INC",1),
                w => w4c_env_kill(env,dest))))
        case None{}: w4c_env_kill(env,dest)

@unsafe
def w4c_step_set(val: N111Value, +dest: String, +env: KDef) -> KDef:
  match val:
    case N111Local{src}: w4c_env_copy(env,dest,src)
    case N111Const{+lo,0}:
      nt_choose(KDef,U32.is_le(lo,2147483647),
        u => p111v_put(env,dest,"BM",lo,0),
        u => w4c_env_kill(env,dest))
    case _: w4c_env_kill(env,dest)

@unsafe
def w4c_step_scalar(stmt: N111Stmt, +env: KDef) -> KDef:
  match stmt:
    case N111Bin{dest,_,op,left,right}:
      w4c_step_bin_r(w4c_const_u32_any(right),dest,op,w4c_local_name(left),w4c_const_u32_any(left),w4c_local_name(right),env)
    case N111Set{dest,_,val}: w4c_step_set(val,dest,env)
    case N111Call{dest,_,_,_}: w4c_env_kill(env,dest)
    case N111Load{dest,_,_,_}: w4c_env_kill(env,dest)
    case N111Offset{dest,_,_}: w4c_env_kill(env,dest)
    case N111Alloca{dest,_,_}: w4c_env_kill(env,dest)
    case _: env

@unsafe
def w4c_kill_names(names: List<&2,String>, +env: KDef) -> KDef:
  match names:
    case Nil{}: env
    case Con{nm,rest}: w4c_kill_names(rest,w4c_env_kill(env,nm))

@unsafe
def w4c_nth_val(vals: List<&2,N111Value>, +i: U32) -> Maybe<&2,N111Value>:
  match vals:
    case Nil{}: None{}
    case Con{v,rest}: nt_choose(Maybe<&2,N111Value>,U32.is_eq(i,0),u => Some{v},u => w4c_nth_val(rest,U32.sub(i,1)))

@unsafe
def w4c_nth_param_name(params: List<&2,NC_Binding>, +i: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{NC_Binding{_,word,_},rest}: nt_choose(String,U32.is_eq(i,0),u => word,u => w4c_nth_param_name(rest,U32.sub(i,1)))

@unsafe
def w4c_cond_nz_param(cond: N111Value, +env: KDef) -> Maybe<&2,U32>:
  match cond:
    case N111Local{cn}:
      +d = p111v_get(env,cn)
      nt_choose(Maybe<&2,U32>,agy_str_eq(dk(d),"NZ") || agy_str_eq(dk(d),"PRM"),u => Some{da(d)},u => None{})
    case _: None{}

@unsafe
def w4c_opt_eq(m: Maybe<&2,U32>, +x: U32) -> Bool:
  match m:
    case Some{v}: U32.is_eq(v,x)
    case None{}: False{}

@unsafe
def w4c_val_is_dec(mv: Maybe<&2,N111Value>, +pidx: U32, +env: KDef) -> Bool:
  match mv:
    case Some{N111Local{nm}}:
      +d = p111v_get(env,nm)
      agy_str_eq(dk(d),"DEC") && U32.is_eq(da(d),pidx)
    case _: False{}

@unsafe
def w4c_val_is_inc(mv: Maybe<&2,N111Value>, +pidx: U32, +env: KDef) -> Bool:
  match mv:
    case Some{N111Local{nm}}:
      +d = p111v_get(env,nm)
      agy_str_eq(dk(d),"INC") && U32.is_eq(da(d),pidx)
    case _: False{}

@unsafe
def w4c_val_bm_env(v: N111Value, +env: KDef) -> Maybe<&2,U32>:
  match v:
    case N111Const{+lo,0}:
      nt_choose(Maybe<&2,U32>,U32.is_le(lo,2147483647),u => Some{lo},u => None{})
    case N111Local{nm}:
      +d = p111v_get(env,nm)
      nt_choose(Maybe<&2,U32>,agy_str_eq(dk(d),"BM"),u => Some{da(d)},u => None{})
    case _: None{}

@unsafe
def w4c_val_bm_opt(mv: Maybe<&2,N111Value>, +env: KDef) -> Maybe<&2,U32>:
  match mv:
    case Some{v}: w4c_val_bm_env(v,env)
    case None{}: None{}

# Flow-sensitive check for countdown param `pidx`: every P113DAgain is under `pidx != 0` and passes `DEC(pidx)`.
@unsafe
def w4c_fs_check_dec(+pidx: U32, body: List<&2,P113DStmt>, +guarded: Bool, +env: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: w4c_fs_check_dec(pidx,rest,guarded,w4c_step_scalar(stmt,env))
    case Con{P113DCall{dests,_,_},rest}: w4c_fs_check_dec(pidx,rest,guarded,w4c_kill_names(dests,env))
    case Con{P113DAgain{vals},rest}:
      guarded && w4c_val_is_dec(w4c_nth_val(vals,pidx),pidx,env) && w4c_fs_check_dec(pidx,rest,guarded,env)
    case Con{P113DIf{cond,yes,no},rest}:
      +isNz = w4c_opt_eq(w4c_cond_nz_param(cond,env),pidx)
      w4c_fs_check_dec(pidx,yes,guarded || isNz,env) &&
      w4c_fs_check_dec(pidx,no,guarded,env) &&
      w4c_fs_check_dec(pidx,rest,guarded,env)
    case Con{_,rest}: w4c_fs_check_dec(pidx,rest,guarded,env)

@unsafe
def w4c_fs_find_countdown(params: List<&2,NC_Binding>, +i: U32, +body: List<&2,P113DStmt>, +seed: KDef) -> Maybe<&2,U32>:
  match params:
    case Nil{}: None{}
    case Con{_,rest}:
      nt_choose(Maybe<&2,U32>,w4c_fs_check_dec(i,body,False{},seed),
        u => Some{i},
        u => w4c_fs_find_countdown(rest,U32.inc(i),body,seed))

@unsafe
def w4c_fs_check_inc(+pidx: U32, body: List<&2,P113DStmt>, +env: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: w4c_fs_check_inc(pidx,rest,w4c_step_scalar(stmt,env))
    case Con{P113DCall{dests,_,_},rest}: w4c_fs_check_inc(pidx,rest,w4c_kill_names(dests,env))
    case Con{P113DAgain{vals},rest}:
      w4c_val_is_inc(w4c_nth_val(vals,pidx),pidx,env) && w4c_fs_check_inc(pidx,rest,env)
    case Con{P113DIf{_,yes,no},rest}:
      w4c_fs_check_inc(pidx,yes,env) && w4c_fs_check_inc(pidx,no,env) && w4c_fs_check_inc(pidx,rest,env)
    case Con{_,rest}: w4c_fs_check_inc(pidx,rest,env)

law w4c_fs_max_bm:
  for +pidx: U32
  for body: List<&2,P113DStmt>
  for +env: KDef
  for +acc: U32
  Maybe<&2,U32>

@unsafe
def w4c_fs_max_bm_b(mb: Maybe<&2,U32>, +pidx: U32, rest: List<&2,P113DStmt>, +env: KDef, +acc: U32) -> Maybe<&2,U32>:
  match mb:
    case Some{+b}:
      +m2 = nt_choose(U32,U32.is_gt(b,acc),u => b,u => acc)
      w4c_fs_max_bm(pidx,rest,env,m2)
    case None{}: None{}

@unsafe
def w4c_fs_max_bm_no(m2: Maybe<&2,U32>, +pidx: U32, rest: List<&2,P113DStmt>, +env: KDef) -> Maybe<&2,U32>:
  match m2:
    case Some{+a2}: w4c_fs_max_bm(pidx,rest,env,a2)
    case None{}: None{}

@unsafe
def w4c_fs_max_bm_yes(m1: Maybe<&2,U32>, +pidx: U32, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +env: KDef) -> Maybe<&2,U32>:
  match m1:
    case Some{+a1}: w4c_fs_max_bm_no(w4c_fs_max_bm(pidx,no,env,a1),pidx,rest,env)
    case None{}: None{}

@unsafe
def w4c_fs_max_bm(pidx,body,env,acc):
  match body:
    case Nil{}: Some{acc}
    case Con{P113DScalar{stmt},rest}: w4c_fs_max_bm(pidx,rest,w4c_step_scalar(stmt,env),acc)
    case Con{P113DCall{dests,_,_},rest}: w4c_fs_max_bm(pidx,rest,w4c_kill_names(dests,env),acc)
    case Con{P113DAgain{vals},rest}:
      w4c_fs_max_bm_b(w4c_val_bm_opt(w4c_nth_val(vals,pidx),env),pidx,rest,env,acc)
    case Con{P113DIf{_,yes,no},rest}:
      w4c_fs_max_bm_yes(w4c_fs_max_bm(pidx,yes,env,acc),pidx,no,rest,env)
    case Con{_,rest}: w4c_fs_max_bm(pidx,rest,env,acc)

@unsafe
def w4c_fs_iv_mask(params: List<&2,NC_Binding>, +i: U32, +body: List<&2,P113DStmt>, +seed: KDef, +acc: U32) -> U32:
  match params:
    case Nil{}: acc
    case Con{_,rest}:
      +acc2 = nt_choose(U32,U32.is_lt(i,31) && w4c_fs_check_inc(i,body,seed),
        u => U32.or(acc,U32.shln(1,U32.to_nat(i))),
        u => acc)
      w4c_fs_iv_mask(rest,U32.inc(i),body,seed,acc2)

@unsafe
def w4c_fs_pbm_put(mb: Maybe<&2,U32>, +i: U32, +acc: KDef) -> KDef:
  match mb:
    case Some{+b}: p111v_put(acc,U32.show(i),"W4BM",b,1)
    case None{}: acc

@unsafe
def w4c_fs_pbm_map(params: List<&2,NC_Binding>, +i: U32, +body: List<&2,P113DStmt>, +seed: KDef, +acc: KDef) -> KDef:
  match params:
    case Nil{}: acc
    case Con{_,rest}:
      w4c_fs_pbm_map(rest,U32.inc(i),body,seed,w4c_fs_pbm_put(w4c_fs_max_bm(i,body,seed,0),i,acc))

type W4CBCEPlan is Data:
  W4CBCEPlan{+nomask: KDef, +guards: List<&2,N111Stmt>, +next: U32}

@unsafe
def w4c_guard_ule(+gn: String, +lhs: N111Value, +rhs: N111Value) -> List<&2,N111Stmt>:
  [N111Bin{gn,N111U64{},"ule",lhs,rhs},
   N111Bin{"p113a_version_guard",N111U32{},"and",N111Local{"p113a_version_guard"},N111Local{gn}}]

@unsafe
def w4c_has_bit(+mask: U32, +i: U32) -> Bool:
  U32.is_lt(i,31) && U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(i))),0)

@unsafe
def w4c_bce_site_local(idxVal: N111Value, +n: U32, +origin: U32, +guarded: Bool, +cntName: String,
    +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  match idxVal:
    case N111Local{+inm}:
      +d = p111v_get(env,inm)
      +maskRef = p117h_ref(origin,"mask")
      +pfx = "w4c_bce_" ++ U32.show(n) ++ "_"
      # Case 2: bitmask-wrapped param j (PRM with pbmMap entry)
      nt_choose(W4CBCEPlan,agy_str_eq(dk(d),"PRM") && U32.is_eq(dx(p111v_get(pbmMap,U32.show(da(d)))),1),
        u =>
          +bound = da(p111v_get(pbmMap,U32.show(da(d))))
          +pname = w4c_nth_param_name(params,da(d))
          W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
            nt_append(N111Stmt,guards,
              nt_append(N111Stmt,w4c_guard_ule(pfx ++ "pbm",N111Const{bound,0},maskRef),
                w4c_guard_ule(pfx ++ "pinit",N111Local{pname},maskRef))),U32.inc(n)},
        # Case 3: unit-stride IV param j (PRM in ivMask) OR j+1 (INC in ivMask under countdown guard)
        u =>
          +isIv = Bool.not(String.is_empty(cntName)) &&
            ((agy_str_eq(dk(d),"PRM") && w4c_has_bit(ivMask,da(d))) ||
             (guarded && agy_str_eq(dk(d),"INC") && w4c_has_bit(ivMask,da(d))))
          nt_choose(W4CBCEPlan,isIv,
            v =>
              +pname = w4c_nth_param_name(params,da(d))
              +sumName = pfx ++ "sum"
              +gStmts = nt_append(N111Stmt,w4c_guard_ule(pfx ++ "iv0",N111Local{pname},maskRef),
                nt_append(N111Stmt,w4c_guard_ule(pfx ++ "cnt0",N111Local{cntName},maskRef),
                  Con{N111Bin{sumName,N111U64{},"add",N111Local{pname},N111Local{cntName}},
                    w4c_guard_ule(pfx ++ "ivend",N111Local{sumName},maskRef)}))
              W4CBCEPlan{p117h_put(nomask,U32.show(n),1),nt_append(N111Stmt,guards,gStmts),U32.inc(n)},
            v => W4CBCEPlan{nomask,guards,U32.inc(n)}))
    case _: W4CBCEPlan{nomask,guards,U32.inc(n)}

@unsafe
def w4c_bce_site_bm(mb: Maybe<&2,U32>, +n: U32, +origin: U32, +idxVal: N111Value, +guarded: Bool, +cntName: String,
    +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  match mb:
    case Some{+bound}:
      +maskRef = p117h_ref(origin,"mask")
      +pfx = "w4c_bce_" ++ U32.show(n) ++ "_"
      W4CBCEPlan{p117h_put(nomask,U32.show(n),1),
        nt_append(N111Stmt,guards,w4c_guard_ule(pfx ++ "bm",N111Const{bound,0},maskRef)),U32.inc(n)}
    case None{}: w4c_bce_site_local(idxVal,n,origin,guarded,cntName,params,ivMask,pbmMap,env,nomask,guards)

@unsafe
def w4c_bce_site(+n: U32, +origin: U32, +idxVal: N111Value, +guarded: Bool, +cntName: String,
    +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  w4c_bce_site_bm(w4c_val_bm_env(idxVal,env),n,origin,idxVal,guarded,cntName,params,ivMask,pbmMap,env,nomask,guards)

law w4c_bce_walk:
  for +body: List<&2,P113DStmt>
  for +n: U32
  for +used: U32
  for +sites: KDef
  for +guarded: Bool
  for +cntIdx: Maybe<&2,U32>
  for +cntName: String
  for +params: List<&2,NC_Binding>
  for +ivMask: U32
  for +pbmMap: KDef
  for +env: KDef
  for +nomask: KDef
  for +guards: List<&2,N111Stmt>
  W4CBCEPlan

@unsafe
def w4c_bce_walk_no(p2: W4CBCEPlan, rest: List<&2,P113DStmt>, +used: U32, +sites: KDef, +guarded: Bool,
    +cntIdx: Maybe<&2,U32>, +cntName: String, +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef) -> W4CBCEPlan:
  match p2:
    case W4CBCEPlan{nm2,g2,n2}:
      w4c_bce_walk(rest,n2,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nm2,g2)

@unsafe
def w4c_bce_walk_yes(p1: W4CBCEPlan, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +used: U32, +sites: KDef, +guarded: Bool,
    +cntIdx: Maybe<&2,U32>, +cntName: String, +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef) -> W4CBCEPlan:
  match p1:
    case W4CBCEPlan{nm1,g1,n1}:
      w4c_bce_walk_no(w4c_bce_walk(no,n1,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nm1,g1),
        rest,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env)

@unsafe
def w4c_opt_eq2(a: Maybe<&2,U32>, b: Maybe<&2,U32>) -> Bool:
  match a:
    case Some{x}: w4c_opt_eq(b,x)
    case None{}: False{}

@unsafe
def w4c_bce_walk_step(body: List<&2,P113DStmt>, +n: U32, +used: U32, +sites: KDef, +guarded: Bool,
    +cntIdx: Maybe<&2,U32>, +cntName: String, +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  match body:
    case Nil{}: W4CBCEPlan{nomask,guards,n}
    case Con{P113DScalar{+stmt},+rest}:
      +env2 = w4c_step_scalar(stmt,env)
      nt_choose(W4CBCEPlan,U32.is_eq(p113a_stmt_id(stmt),0),
        u => w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards),
        u => w4c_bce_walk(rest,U32.inc(n),used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards))
    case Con{P113DCall{dests,_,_},+rest}:
      w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,w4c_kill_names(dests,env),nomask,guards)
    case Con{P113DIf{cond,yes,no},+rest}:
      +isNz = w4c_opt_eq2(w4c_cond_nz_param(cond,env),cntIdx)
      w4c_bce_walk_yes(w4c_bce_walk(yes,n,used,sites,guarded || isNz,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards),
        no,rest,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env)
    case Con{_,rest}:
      w4c_bce_walk(rest,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards)

@unsafe
def w4c_bce_walk_after_site(p1: W4CBCEPlan, rest: List<&2,P113DStmt>, +used: U32, +sites: KDef, +guarded: Bool,
    +cntIdx: Maybe<&2,U32>, +cntName: String, +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef) -> W4CBCEPlan:
  match p1:
    case W4CBCEPlan{nm1,g1,n1}:
      w4c_bce_walk(rest,n1,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nm1,g1)

@unsafe
def w4c_bce_walk_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +used: U32, +sites: KDef, +guarded: Bool,
    +cntIdx: Maybe<&2,U32>, +cntName: String, +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      +env2 = w4c_step_scalar(stmt,env)
      nt_choose(W4CBCEPlan,U32.is_gt(U32.and(used,p117h_bit(origin)),0) && Bool.not(U32.is_eq(id,75)),
        u => w4c_bce_walk_after_site(w4c_bce_site(n,origin,v1,guarded,cntName,params,ivMask,pbmMap,env,nomask,guards),
          rest,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2),
        u => w4c_bce_walk(rest,U32.inc(n),used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env2,nomask,guards))
    case P113ASunkNo{}:
      w4c_bce_walk_step(body,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards)

@unsafe
def w4c_bce_walk(body,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards):
  w4c_bce_walk_sunk(p113a_match_sunk(body),body,n,used,sites,guarded,cntIdx,cntName,params,ivMask,pbmMap,env,nomask,guards)

@unsafe
def w4c_bce_analyze_cnt(cntIdx: Maybe<&2,U32>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +used: U32, +sites: KDef, +seed: KDef) -> W4CBCEPlan:
  match cntIdx:
    case Some{+ci}:
      +cntName = w4c_nth_param_name(params,ci)
      +ivMask = w4c_fs_iv_mask(params,0,body,seed,0)
      +pbmMap = w4c_fs_pbm_map(params,0,body,seed,missing())
      w4c_bce_walk(body,0,used,sites,False{},Some{ci},cntName,params,ivMask,pbmMap,seed,missing(),[])
    case None{}:
      +pbmMap = w4c_fs_pbm_map(params,0,body,seed,missing())
      w4c_bce_walk(body,0,used,sites,False{},None{},"",params,0,pbmMap,seed,missing(),[])

@unsafe
def w4c_bce_analyze(+params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +used: U32, +sites: KDef) -> W4CBCEPlan:
  +seed = w4c_env_seed(params,0,missing())
  w4c_bce_analyze_cnt(w4c_fs_find_countdown(params,0,body,seed),params,body,used,sites,seed)"""

    src = replace_exact(src, old_p117v_tpl, new_p117v_tpl, "Pass 4a: p117v_rewrite_ex + BCE analysis")

    # Wire W4CBCEPlan into x185_array_dispatch and x185_array_version!
    old_dispatch = """@unsafe
def x185_array_dispatch(+name: String, +params: List<&2,NC_Binding>, +result: U32, +used: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)},
    [N111If{N111Local{"p113a_version_guard"},[],[
      N111Call{"__x181_fallback",N111U64{},"p117v_" ++ nt_fid(name),
        Con{p111_state(),nt_choose(List<&2,N111Arg>,U32.is_eq(result,1),
          u => x185_array_arguments(params),
          u => Con{N111Arg{N111Ptr{},N111Local{"__x181_result_out"}},x185_array_arguments(params)})}},
      N111Return{N111Local{"__x181_fallback"}}]}])"""

    new_dispatch = """@unsafe
def x185_array_dispatch_ex(+name: String, +params: List<&2,NC_Binding>, +result: U32, +used: U32, +extra: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    nt_append(N111Stmt,Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)},extra),
    [N111If{N111Local{"p113a_version_guard"},[],[
      N111Call{"__x181_fallback",N111U64{},"p117v_" ++ nt_fid(name),
        Con{p111_state(),nt_choose(List<&2,N111Arg>,U32.is_eq(result,1),
          u => x185_array_arguments(params),
          u => Con{N111Arg{N111Ptr{},N111Local{"__x181_result_out"}},x185_array_arguments(params)})}},
      N111Return{N111Local{"__x181_fallback"}}]}])

@unsafe
def x185_array_dispatch(+name: String, +params: List<&2,NC_Binding>, +result: U32, +used: U32) -> List<&2,N111Stmt>:
  x185_array_dispatch_ex(name,params,result,used,[])"""

    src = replace_exact(src, old_dispatch, new_dispatch, "Pass 4b: x185_array_dispatch_ex")

    old_version = """@unsafe
def x185_array_version(+function: P113DFunction, +ids: N111Ids, +heap: U32, +used: U32, sites: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,body}:
      x181_program_join(x185_array_emit(p113a_function(function,heap),"p117v_" ++ nt_fid(name),[],ids),
        x199s_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,used,sites)),
          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),
            x185_array_dispatch(name,params,result,used)),ids,used,heap))"""

    new_version = """@unsafe
def x185_array_version_plan(plan: W4CBCEPlan, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +result: U32, +public: Bool, +body: List<&2,P113DStmt>, +ids: N111Ids, +heap: U32, +used: U32, +sites: KDef) -> X181Output:
  match plan:
    case W4CBCEPlan{nomask,guards,_}:
      x181_program_join(x185_array_emit(p113a_function(function,heap),"p117v_" ++ nt_fid(name),[],ids),
        x199s_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite_ex(body,0,heap,used,sites,nomask)),
          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),
            x185_array_dispatch_ex(name,params,result,used,guards)),ids,used,heap))

@unsafe
def x185_array_version(+function: P113DFunction, +ids: N111Ids, +heap: U32, +used: U32, +sites: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      x185_array_version_plan(w4c_bce_analyze(params,body,used,sites),function,name,params,result,public,body,ids,heap,used,sites)"""

    src = replace_exact(src, old_version, new_version, "Pass 4c: x185_array_version")
    return src


def apply_all(src: str) -> str:
    src = patch_1_product_field_kinds(src)
    src = patch_2_3_rotate_and_cfg_peep(src)
    src = patch_4_p117v_bce(src)
    return src


def main():
    ap = argparse.ArgumentParser(description="Wave 4C Track W4-10: Array BCE + editdist/bst/histogram Closer")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src_text = args.src.read_text()
    out_text = apply_all(src_text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out_text)
    print(f"Wrote {args.dst} ({len(out_text)} bytes, delta={len(out_text) - len(src_text):+d} bytes)")


if __name__ == "__main__":
    main()
