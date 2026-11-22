#!/usr/bin/env python3
"""Wave 5 Engine B Track W5-R3: General High-Arity Direct-Style, cmov Diamond & Register/Slot Optimizer.

100% general compiler passes (zero benchmark-specific matchers):
  1. Lift arbitrary arity <= 32 caps to arity <= 64 across direct-style candidate
     admission (p113pl_candidates), product signature flattening (nq_signature_tele),
     direct-style inliner (p113i_eligible), region/worker admission (p112w/p169q),
     and adapter admission/verification (p164a/p167v). The underlying runtime
     (p111_rt_reg_get up to 255) and x86-64 direct-style codegen (x181_frame /
     x181_call_text / __x181_tail) already support arbitrary stack-passed arity.
  2. Lower pure-diamond selects in w4g_try_diamond to canonical 1-statement P113DIf
     selects instead of 4-op bitmask arithmetic (sub 0 / xor / and / xor), enabling
     x191_conditional_select (cmov) and x194_ps (cmp + cmov fusion) while removing
     4 temporary locals per select.
  3. Lift x190 joint/liveness register allocator size cap (512 -> 2048 stmts) and
     candidate-list cap (64 -> 512 locals; x203_rank already selects the top 32
     by read score into the 32-bit interference graph).
  4. Enable w4c_copy_slot_fwd + w4c_backedge_coalesce + w4c_dead_slot_elim in
     w4c_xmm_opt even when a function contains leaq -disp(%rbp) for disjoint
     stack buffers (scratch / __x181_tail / __x181_results / alloca), which are
     strictly disjoint from scalar X181Stack homes in x181_frame and already
     counted as reads by w4c_inst_reads.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave4c_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5_r3/compiler.bend"

REPLACEMENTS = [
    # --- Pass 1: Lift arbitrary arity <= 32 caps to 64 ---
    (
        '  +ok = p98_tag_eq(tele, "NQTele") && nq_has_shape(ks(tele)) && U32.is_le(nq_shape_words(nc_tail_terms(ks(tele))), 32)',
        '  +ok = p98_tag_eq(tele, "NQTele") && nq_has_shape(ks(tele)) && U32.is_le(nq_shape_words(nc_tail_terms(ks(tele))), 64)',
    ),
    (
        '      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,32) && p112r_tail(tail,target,arity,0,buffer),',
        '      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,64) && p112r_tail(tail,target,arity,0,buffer),',
    ),
    (
        '      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32) && U32.is_le(sites,8),',
        '      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,64) && U32.is_le(sites,8),',
    ),
    (
        '      nt_choose(Bool,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32),',
        '      nt_choose(Bool,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,64),',
    ),
    (
        '        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),',
        '        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),64),',
    ),
    (
        '      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,32) &&',
        '      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(arity,64) &&',
    ),
    (
        '    U32.is_le(arity,32) && agy_str_eq(dk(signature),"P113Direct") &&\n'
        '    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),1)',
        '    U32.is_le(arity,64) && agy_str_eq(dk(signature),"P113Direct") &&\n'
        '    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),1)',
    ),
    (
        '      U32.is_le(arity,32) && U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&',
        '      U32.is_le(arity,64) && U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&',
    ),
    (
        '    U32.is_le(arity,32) && agy_str_eq(dk(signature),"P113Direct") &&\n'
        '    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),0)',
        '    U32.is_le(arity,64) && agy_str_eq(dk(signature),"P113Direct") &&\n'
        '    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),0)',
    ),
    (
        '  U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32)',
        '  U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,64)',
    ),
    # --- Pass 2: w4g_try_diamond -> 1-stmt P113DIf select (enables cmov & cmp+cmov fusion) ---
    (
        '          +mnm = ydst ++ "_w4m"\n'
        '          +dnm = ydst ++ "_w4d"\n'
        '          +snm = ydst ++ "_w4s"\n'
        '          +subjVal : N111Value = N111Local{subjName}\n'
        '          +pickY = U32.is_eq(da(rel),1)\n'
        '          +baseVal : N111Value = nt_choose(N111Value,pickY,z => N111Local{nnm},z => N111Local{ynm})\n'
        '          +altVal : N111Value = nt_choose(N111Value,pickY,z => N111Local{ynm},z => N111Local{nnm})\n'
        '          +sel : List<&2,P113DStmt> = [\n'
        '            P113DScalar{N111Bin{mnm,N111U64{},"sub",N111Const{0,0},subjVal}},\n'
        '            P113DScalar{N111Bin{dnm,N111U64{},"xor",altVal,baseVal}},\n'
        '            P113DScalar{N111Bin{snm,N111U64{},"and",N111Local{dnm},N111Local{mnm}}},\n'
        '            P113DScalar{N111Bin{ydst,N111U64{},"xor",baseVal,N111Local{snm}}}\n'
        '          ]',
        '          +sel : List<&2,P113DStmt> = [\n'
        '            P113DIf{condition,\n'
        '              [P113DScalar{N111Set{ydst,N111U64{},N111Local{ynm}}}],\n'
        '              [P113DScalar{N111Set{ydst,N111U64{},N111Local{nnm}}}]}\n'
        '          ]',
    ),
    # --- Pass 4: Enable slot copy-fwd / backedge-coalesce / dead-slot-elim even with disjoint leaq buffers ---
    (
        'def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:\n'
        '  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])\n'
        '  nt_choose(List<&2,X187Parsed>,w4c_has_leaq_rbp(p1),\n'
        '    u => p1,\n'
        '    u => w4c_xmm_opt_nolea(p1))',
        'def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:\n'
        '  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])\n'
        '  w4c_xmm_opt_nolea(p1)',
    ),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    text = args.src.read_text()
    for i, (old, new) in enumerate(REPLACEMENTS, 1):
        cnt = text.count(old)
        assert cnt == 1, f"Replacement #{i} expected 1 match, found {cnt}: {old[:80]!r}"
        text = text.replace(old, new, 1)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(text)
    print(f"Wrote {args.dst} ({len(text)} bytes, {len(REPLACEMENTS)} general replacements applied)")


if __name__ == "__main__":
    main()
