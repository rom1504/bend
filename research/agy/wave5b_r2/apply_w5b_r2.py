#!/usr/bin/env python3
"""Wave 5B Engine B Track W5B-R2: General F32/Bitwise Closer (GameOfLife, Nbody, Expression).

100% general, semantics-preserving compiler passes on top of wave5a_unified/compiler.bend:
  1. Direct IEEE-754 `sqrtss` emission (`x200r_sqrt_core`, `x195s_text`):
     On x86-64 SSE, `sqrtss` is bit-exact identical to libm `sqrtf` across all IEEE-754
     classes (+0, -0, +normal, +subnormal, +inf, -normal, -subnormal, -inf, qNaN, sNaN)
     and Bend has no C `errno`. Eliminates the 9-inst `pxor/ucomiss/ja/jmp/call` wrapper
     around every `F32.sqrt`, keeping F32-sqrt loops as true leaf functions.
  2. Large-body & loop-exit-condition joint GPR allocation (`x190_joint_frame`, `x190_j_counted`,
     `x191_loop_join`):
     - Raise `x190_joint_frame` statement cap 512 -> 1024 and `x190_j_counted` `nCands` cap
       256 -> 1024 (`x203_candidates` already bounds coloring to the top 32 variables).
     - Give loop-exit controlling branch conditions (where exactly one arm reaches `Again`)
       8x loop-read priority in `x191_loop_join` so loop counters in high-param loops stay
       in GPRs and unlock bottom-tested loop rotation (`w4b_rotate_loop`).
  3. Cycle-aware CFG register deadness (`w4b_reg_dead_step` with visited-label set):
     Revisiting a label already on the current DFS stack without reading `r` proves `r` is
     dead along that cycle (greatest fixpoint), unlocking dead-register peepholes (e.g. G4)
     across loop backedges.
  4. Extended general XMM & GPR peepholes:
     - X2-self: allow `fsrc == %xmmA` in `w5_x2_c` (`movaps A,B; mulss A,B; movaps B,A` -> `mulss A,A`).
     - X7: `movaps A,B; <fop> src,B; movq B,d(%rbp)` (A,B dead) -> `<fop> src,A; movq A,d(%rbp)`.
     - X8: `movaps A,B; movaps C,D; <fop> B,D` (B dead) -> `movaps C,D; <fop> A,D`.
     - X9: `movaps A,B; <fop1> s1,B; <fop2> s2,B; movq B,d(%rbp)` (A,B dead) -> in-place in A.
     - G7-ext: extend G7 (`movq A,B; <andq|shlq|shrq> $k,B; movq B,d(%rbp)`) to shifts too.
     - G10: `movq A,B; movq B,C` (B dead) -> `movq A,C`.
     - G12: `cmpq $0, %rC; sete %rC8; movzbl %rC8, %rC32; ... testl %rC32, %rC32; cmov(n)eq src, dst`
            (straight-line, %rC untouched & dead after testl) -> delete 3 setup insts and fold
            into `testq %rC, %rC; cmov(n)eq_inv src, dst`.
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave5a_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave5b_r2/compiler.bend"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return text.replace(old, new, 1)


# ---------------------------------------------------------------------------
# Pass 1: Direct IEEE-754 sqrtss emission (x195s_text and x200r_sqrt_core)
# ---------------------------------------------------------------------------
OLD_X195S_TEXT = """@unsafe
def x195s_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x188_label(x181_label(U32.inc(site),frame)),x186_float_result(name,frame)])"""

NEW_X195S_TEXT = """@unsafe
def x195s_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x186_float_result(name,frame)])"""

OLD_X200R_SQRT = """@unsafe
def x200r_sqrt_core(name: String, left: N111Value, ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +site: U32) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x188_label(x181_label(U32.inc(site),frame)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])"""

NEW_X200R_SQRT = """@unsafe
def x200r_sqrt_core(name: String, left: N111Value, ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +site: U32) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])"""

# ---------------------------------------------------------------------------
# Pass 2: Joint regalloc cap + loop-exit condition priority
# ---------------------------------------------------------------------------
OLD_J_COUNTED = """      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) ||
          (U32.is_gt(nCands,256) && U32.is_le(nt_count(String,params),8)),"""

NEW_J_COUNTED = """      nt_choose(X181Frame,(U32.is_gt(nCands,32) && Bool.not(x190_register_loop(body))) ||
          (U32.is_gt(nCands,1024) && U32.is_le(nt_count(String,params),8)),"""

OLD_JOINT_FRAME = """  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),"""

NEW_JOINT_FRAME = """  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),1024) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),"""

OLD_LOOP_JOIN = """@unsafe
def x191_loop_join(condition: N111Value, yes: X191LoopReads, no: X191LoopReads) -> X191LoopReads:
  match yes no:
    case X191LoopReads{+a,+hotA,fallA} X191LoopReads{+b,+hotB,fallB}:
      X191LoopReads{nt_choose(X181ReadCounts,hotA || hotB,
        u => x181_reads_value(condition,x191_reads_merge(a,b)),u => x191_reads_merge(a,b)),hotA || hotB,fallA || fallB}"""

NEW_LOOP_JOIN = """@unsafe
def w5b_reads_8(+condition: N111Value, +counts: X181ReadCounts) -> X181ReadCounts:
  x181_reads_value(condition,x181_reads_value(condition,x181_reads_value(condition,
    x181_reads_value(condition,x181_reads_value(condition,x181_reads_value(condition,
      x181_reads_value(condition,x181_reads_value(condition,counts))))))))

@unsafe
def w5b_reads_loop_cond(+condition: N111Value, +counts: X181ReadCounts) -> X181ReadCounts:
  w5b_reads_8(condition,w5b_reads_8(condition,w5b_reads_8(condition,w5b_reads_8(condition,counts))))

@unsafe
def x191_loop_join(+condition: N111Value, yes: X191LoopReads, no: X191LoopReads) -> X191LoopReads:
  match yes no:
    case X191LoopReads{+a,+hotA,fallA} X191LoopReads{+b,+hotB,fallB}:
      +merged = x191_reads_merge(a,b)
      +isExit = (hotA && Bool.not(hotB)) || (hotB && Bool.not(hotA))
      X191LoopReads{nt_choose(X181ReadCounts,isExit,
        u => w5b_reads_loop_cond(condition,merged),
        u => nt_choose(X181ReadCounts,hotA || hotB,
          v => x181_reads_value(condition,merged),v => merged)),hotA || hotB,fallA || fallB}"""

# ---------------------------------------------------------------------------
# Pass 3: Cycle-aware w4b_reg_dead (tracks visited labels on DFS stack)
# ---------------------------------------------------------------------------
OLD_REG_DEAD_LAW = """law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  Bool"""

NEW_REG_DEAD_LAW = """law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  for +seen: List<&2,String>
  Bool"""

OLD_REG_DEAD = """@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops)
    case None{}: False{}

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      nt_choose(Bool,w4b_op_reads_reg(r,src),w => False{},w =>
        nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),x => True{},
          x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)))
    case _:
      nt_choose(Bool,w4b_args_read_reg(r,args),w => False{},
        w => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops))

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}:
      nt_choose(Bool,U32.is_eq(hops,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(op,"jmp"),
          v => w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1)),
          v => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1)) &&
               w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,U32.sub(budget,1),U32.sub(hops,1))))
    case _: False{}

@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      nt_choose(Bool,U32.is_eq(dr,r) && U32.is_ge(dw,32),u => True{},
        u => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops))
    case _: False{}

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{_},rest}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(Bool,agy_str_eq(op,"ret"),u => Bool.not(U32.is_eq(r,0)),u =>
        nt_choose(Bool,agy_str_eq(op,"popq"),p => w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops),p =>
        nt_choose(Bool,w4b_is_write_only_op(op),v => w4b_reg_dead_write(r,args,rest,fnItems,budget,hops),
          v => nt_choose(Bool,w4b_is_simple_alu(op),w =>
            nt_choose(Bool,w4b_args_read_reg(r,args),x => False{},
              x => w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops)),
            w => nt_choose(Bool,String.starts_with(op,"j"),
              x => w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops),
              x => False{})))))
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops):
  nt_choose(Bool,U32.is_eq(budget,0),u => False{},u => w4b_reg_dead_go(r,items,fnItems,budget,hops))

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,4)"""

NEW_REG_DEAD = """@unsafe
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
  w4b_reg_dead_step(r,items,fnItems,budget,8,[])"""

# ---------------------------------------------------------------------------
# Pass 4a: XMM peephole extensions (X2-self, X7, X8, X9)
# ---------------------------------------------------------------------------
OLD_W5_X2_C = """    case W5MAYes{s2,d2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s2,b) && U32.is_eq(d2,a) && Bool.not(w4c_op_is_xmm(a,fsrc)) &&
        w4c_xmm_dead(b,r3,fnItems,400,2),"""

NEW_W5_X2_C = """    case W5MAYes{s2,d2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s2,b) && U32.is_eq(d2,a) &&
        w4c_xmm_dead(b,r3,fnItems,400,2),"""

OLD_W5_XMM_MA_R2 = """@unsafe
def w5_xmm_fold_ma_r2(+a: U32, +b: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_x2_b(a,b,w4c_as_fop_any(i1),i2,r3,fnItems,acc),
        v => w4c_or_peep_opt(w5_x3_b(a,b,w5_as_movd_slot(i1),i2,r3,fnItems,acc),
          w => w5_x5(a,b,w4c_as_fop_any(i1),Con{i2,r3},fnItems,acc)))
    case Nil{}: w5_x5(a,b,w4c_as_fop_any(i1),[],fnItems,acc)"""

NEW_W5_XMM_MA_R2 = """# X7: movaps A,B; <fop> src,B; movq B,disp(%rbp) (A,B dead) -> <fop> src,A; movq A,disp(%rbp)
@unsafe
def w5b_x7_c(+a: U32, +b: U32, +fop: String, +fsrc: X187Operand, st2: W4CMovqXmmMem,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W4CMXMYes{sx,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sx,b) && Bool.not(w4c_op_is_xmm(a,fsrc)) &&
        w4c_xmm_dead(a,r3,fnItems,400,2) && w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_xmm(a),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{fop,[fsrc,x188_xmm(a)]}},acc}})},
        u => None{})
    case W4CMXMNo{}: None{}

# X9: movaps A,B; <fop1> s1,B; <fop2> s2,B; movq B,disp(%rbp) (A,B dead) -> in-place in A
@unsafe
def w5b_x9_d(+a: U32, +b: U32, +op1: String, +s1: X187Operand, +op2: String, +s2: X187Operand,
    st3: W4CMovqXmmMem, +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st3:
    case W4CMXMYes{sx,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sx,b) && Bool.not(w4c_op_is_xmm(a,s1)) && Bool.not(w4c_op_is_xmm(a,s2)) &&
        w4c_xmm_dead(a,r4,fnItems,400,2) && w4c_xmm_dead(b,r4,fnItems,400,2),
        u => Some{w5_xmm_fold(r4,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_xmm(a),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{op2,[s2,x188_xmm(a)]}},
          Con{PInst{X187Instruction{op1,[s1,x188_xmm(a)]}},acc}}})},
        u => None{})
    case W4CMXMNo{}: None{}

@unsafe
def w5b_x9_c(+a: U32, +b: U32, +op1: String, +s1: X187Operand, f2: W4CFopAny, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFAYes{op2,s2,fdst2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fdst2,b),
        u => w5b_x9_d(a,b,op1,s1,op2,s2,w4c_as_movq_xm(i3),r4,fnItems,acc),
        u => None{})
    case W4CFANo{}: None{}

@unsafe
def w5b_x9_r3(+a: U32, +b: U32, +op1: String, +s1: X187Operand, +i2: X187Parsed, r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r3:
    case Con{+i3,+r4}: w5b_x9_c(a,b,op1,s1,w4c_as_fop_any(i2),i3,r4,fnItems,acc)
    case Nil{}: None{}

@unsafe
def w5b_x79_b(+a: U32, +b: U32, f1: W4CFopAny, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{+op1,+s1,fdst1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fdst1,b),
        u => w4c_or_peep_opt(w5b_x7_c(a,b,op1,s1,w4c_as_movq_xm(i2),r3,fnItems,acc),
          v => w5b_x9_r3(a,b,op1,s1,i2,r3,fnItems,acc)),
        u => None{})
    case W4CFANo{}: None{}

# X8: movaps A,B; movaps C,D; <fop> B,D (B dead, A!=D, B!=C, B!=D) -> movaps C,D; <fop> A,D
@unsafe
def w5b_x8_c(+a: U32, +b: U32, +c: U32, +d: U32, f2: W4CFopAny,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFAYes{+fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(fdst,d) && w4c_op_is_xmm(b,fsrc) && w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,
          Con{PInst{X187Instruction{fop,[x188_xmm(a),x188_xmm(d)]}},
          Con{PInst{X187Instruction{"movaps",[x188_xmm(c),x188_xmm(d)]}},acc}})},
        u => None{})
    case W4CFANo{}: None{}

@unsafe
def w5b_x8_b(+a: U32, +b: U32, m1: W5Movaps, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m1:
    case W5MAYes{c,d}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(a,d)) && Bool.not(U32.is_eq(b,c)) && Bool.not(U32.is_eq(b,d)),
        u => w5b_x8_c(a,b,c,d,w4c_as_fop_any(i2),r3,fnItems,acc),
        u => None{})
    case W5MANo{}: None{}

@unsafe
def w5_xmm_fold_ma_r2(+a: U32, +b: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_x2_b(a,b,w4c_as_fop_any(i1),i2,r3,fnItems,acc),
        v => w4c_or_peep_opt(w5_x3_b(a,b,w5_as_movd_slot(i1),i2,r3,fnItems,acc),
          w => w4c_or_peep_opt(w5b_x79_b(a,b,w4c_as_fop_any(i1),i2,r3,fnItems,acc),
            x => w4c_or_peep_opt(w5b_x8_b(a,b,w5_as_movaps(i1),i2,r3,fnItems,acc),
              y => w5_x5(a,b,w4c_as_fop_any(i1),Con{i2,r3},fnItems,acc)))))
    case Nil{}: w5_x5(a,b,w4c_as_fop_any(i1),[],fnItems,acc)"""

# ---------------------------------------------------------------------------
# Pass 4b: GPR peephole extensions (G7-shift, G10 copy-chain, G12 zero-test cmov)
# ---------------------------------------------------------------------------
OLD_W5_G7 = """@unsafe
def w5_g7_c(+rA: U32, +rB: U32, +lo: U32, +hi: U32, st2: W5StoreRbp, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W5SRYes{sr,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sr,rB) && Bool.not(U32.is_eq(rA,5)) &&
        w4b_reg_dead(rA,r3,fnItems,96) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{"andq",[X187Imm{lo,hi},x188_reg(rA,64)]}},acc}})},
        u => None{})
    case W5SRNo{}: None{}

@unsafe
def w5_g67_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{+op1,+lo,+hi,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,rB) && U32.is_eq(hi,0),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"imull") && U32.is_eq(lo,3),
          v => w5_g6a_c(rA,rB,w4b_as_rr(i2),r3,fnItems,acc),
          v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"addl"),
            w => w5_g6b_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
            w => None{})),
        u => None{})
    case W4BImmReg{+op1,+lo,+hi,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,rB) && agy_str_eq(op1,"andq"),
        u => w5_g7_c(rA,rB,lo,hi,w5_as_store_rbp(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}"""

NEW_W5_G7 = """@unsafe
def w5_g7_c(+rA: U32, +rB: U32, +op1: String, +lo: U32, +hi: U32, st2: W5StoreRbp, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W5SRYes{sr,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sr,rB) && Bool.not(U32.is_eq(rA,5)) &&
        w4b_reg_dead(rA,r3,fnItems,96) && w4b_reg_dead(rB,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{op1,[X187Imm{lo,hi},x188_reg(rA,64)]}},acc}})},
        u => None{})
    case W5SRNo{}: None{}

@unsafe
def w5_g67_b(+rA: U32, +rB: U32, im1: W4BImmReg, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im1:
    case W4BImmReg{+op1,+lo,+hi,d1,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(d1,rB) && U32.is_eq(hi,0),
        u => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"imull") && U32.is_eq(lo,3),
          v => w5_g6a_c(rA,rB,w4b_as_rr(i2),r3,fnItems,acc),
          v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op1,"addl"),
            w => w5_g6b_c(rA,rB,lo,w4b_as_rr(i2),r3,fnItems,acc),
            w => None{})),
        u => None{})
    case W4BImmReg{+op1,+lo,+hi,d1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(d1,rB) && (agy_str_eq(op1,"andq") || agy_str_eq(op1,"shlq") || agy_str_eq(op1,"shrq")),
        u => w5_g7_c(rA,rB,op1,lo,hi,w5_as_store_rbp(i2),r3,fnItems,acc),
        u => None{})
    case _: None{}

# G10: movq %rA, %rB; movq %rB, %rC (%rB dead) -> movq %rA, %rC
@unsafe
def w5b_g10_b(+rA: U32, +rB: U32, rr1: W4BRR, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{op1,s1,64,+rC,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op1,"movq") && U32.is_eq(s1,rB) && Bool.not(U32.is_eq(rC,rB)) &&
        w4b_reg_dead(rB,r2,fnItems,96),
        u => Some{nt_choose(List<&2,X187Parsed>,U32.is_eq(rA,rC),
          v => w5_gpr_peep(r2,fnItems,acc),
          v => w5_gpr_peep(r2,fnItems,Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rC,64)]}},acc}))},
        u => None{})
    case _: None{}"""

OLD_GPR_RR64 = """@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
            x => w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc))))
    case Con{+i2,+r3}: w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc)
    case Nil{}: None{}"""

NEW_GPR_RR64 = """# G1-gen: movq src1, %rB; <comm64> %rA, %rB; movq src2, %rA; <comm64> %rB, %rA (%rB dead)
#         -> <comm64> src1, %rA; <comm64> src2, %rA (src1,src2 in {d(%rbp), %rC})
@unsafe
def w5b_g1_src_ok(+rA: U32, +rB: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,_}: U32.is_eq(b,5)
    case X187Reg{r,64,False{}}: Bool.not(U32.is_eq(r,rA)) && Bool.not(U32.is_eq(r,rB)) && Bool.not(U32.is_eq(r,5))
    case _: False{}

@unsafe
def w5b_g1_d(+src1: X187Operand, +src2: X187Operand, +op1: String, +rA: U32, +rB: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{op3,s3,64,d3,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op3,op1) && U32.is_eq(s3,rB) && U32.is_eq(d3,rA) &&
        w4b_reg_dead(rB,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{op1,[src2,x188_reg(rA,64)]}},
          Con{PInst{X187Instruction{op1,[src1,x188_reg(rA,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5b_g1_c(+src1: X187Operand, +op1: String, +rA: U32, +rB: U32, mv2: W5MovqToReg, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match mv2:
    case W5MTRYes{+src2,dr2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(dr2,rA) && w5b_g1_src_ok(rA,rB,src2),
        u => w5b_g1_d(src1,src2,op1,rA,rB,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case W5MTRNo{}: None{}

@unsafe
def w5b_g1_b(+src1: X187Operand, +rB: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{+op1,+rA,64,dr1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op1) && U32.is_eq(dr1,rB) && Bool.not(U32.is_eq(rA,rB)) &&
        Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)) && w5b_g1_src_ok(rA,rB,src1),
        u => w5b_g1_c(src1,op1,rA,rB,w5_as_movq_to_reg(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

@unsafe
def w5_gpr_rr64_r2(+rA: U32, +rB: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,Con{+i3,+r4}}:
      w4c_or_peep_opt(
        nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rB,0) && w5_not_scratch(rA),
          v => w5_gpr_rr64_g2(rA,i1,i2,i3,r4,fnItems,acc),
          v => None{}),
        v => w4c_or_peep_opt(w5b_g1_b(x188_reg(rA,64),rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
          v2 => w4c_or_peep_opt(w5_g34_b(rA,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
            w => w4c_or_peep_opt(w5_g5_b(rA,rB,w4b_as_imm_reg(i1),i2,i3,r4,fnItems,acc),
              x => w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,Con{i3,r4},fnItems,acc),
                y => w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,Con{i3,r4}},fnItems,acc))))))
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_g67_b(rA,rB,w4b_as_imm_reg(i1),i2,r3,fnItems,acc),
        u => w5b_g10_b(rA,rB,w4b_as_rr(i1),Con{i2,r3},fnItems,acc))
    case Nil{}: w5b_g10_b(rA,rB,w4b_as_rr(i1),[],fnItems,acc)"""

# G12: cmpq $0, %rC; sete %rC8; movzbl %rC8, %rC32; ... testl %rC32, %rC32; cmov(n)eq src, dst
# Straight-line scan (up to 16 insts, %rC untouched, no labels/branches/calls)
OLD_GPR_TRY_IMM = """@unsafe
def w5_gpr_try_imm(im0: W4BImmReg, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im0:
    case W4BImmReg{op0,1,0,r,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"xorl"),
        u => w5_g8_b(r,w4b_as_imm_reg(i1),r2,fnItems,acc),
        u => None{})
    case _: None{}"""

NEW_GPR_TRY_IMM = """# G12: cmpq $0, %rC; sete %rC8; movzbl %rC8, %rC32; ... testl %rC32, %rC32; cmov(n)eq src, dst
@unsafe
def w5b_g12_flip_cmov(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"cmovneq"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"cmoveq"),v => "cmovneq",v => ""))

@unsafe
def w5b_g12_match_cmov(+rC: U32, item: X187Parsed) -> Maybe<&2,X187Parsed>:
  match item:
    case PInst{X187Instruction{+op,Con{+src,Con{+dst,Nil{}}}}}:
      +flipped = w5b_g12_flip_cmov(op)
      nt_choose(Maybe<&2,X187Parsed>,
        Bool.not(String.is_empty(flipped)) &&
        Bool.not(w4b_op_reads_reg(rC,src)) && Bool.not(w4b_op_reads_reg(rC,dst)),
        u => Some{PInst{X187Instruction{flipped,[src,dst]}}},
        u => None{})
    case _: None{}

@unsafe
def w5b_g12_is_testl_self(+rC: U32, item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{s,32,False{}},Con{X187Reg{d,32,False{}},Nil{}}}}}:
      agy_str_eq(op,"testl") && U32.is_eq(s,rC) && U32.is_eq(d,rC)
    case _: False{}

@unsafe
def w5b_g12_safe_mid(+rC: U32, item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{+op,+args}}:
      (w4b_is_write_only_op(op) || w4b_is_simple_alu(op)) &&
      Bool.not(w4b_args_read_reg(rC,args))
    case _: False{}

law w5b_g12_scan:
  for +rC: U32
  for items: List<&2,X187Parsed>
  for +mid: List<&2,X187Parsed>
  for +budget: U32
  for +fnItems: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5b_g12_found_cmov(+rC: U32, cm: Maybe<&2,X187Parsed>, +mid: List<&2,X187Parsed>,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match cm:
    case Some{newCmov}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w4b_reg_dead(rC,rest,fnItems,96),
        w => Some{nt_append(X187Parsed,nt_reverse(X187Parsed,mid,[]),
          Con{PInst{X187Instruction{"testq",[x188_reg(rC,64),x188_reg(rC,64)]}},
          Con{newCmov,rest}})},
        w => None{})
    case None{}: None{}

@unsafe
def w5b_g12_scan_go(+rC: U32, items: List<&2,X187Parsed>, +mid: List<&2,X187Parsed>,
    +budget: U32, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Con{+h,Con{+h2,+rest}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_g12_is_testl_self(rC,h),
        v => w5b_g12_found_cmov(rC,w5b_g12_match_cmov(rC,h2),mid,rest,fnItems),
        v => nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5b_g12_safe_mid(rC,h),
          w => w5b_g12_scan(rC,Con{h2,rest},Con{h,mid},U32.sub(budget,1),fnItems),
          w => None{}))
    case _: None{}

@unsafe
def w5b_g12_scan(rC,items,mid,budget,fnItems):
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(budget,0),u => None{},
    u => w5b_g12_scan_go(rC,items,mid,budget,fnItems))

@unsafe
def w5b_g12_apply(res: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match res:
    case Some{rewritten}: Some{w5_gpr_peep(rewritten,fnItems,acc)}
    case None{}: None{}

@unsafe
def w5b_g12_c(+rC: U32, mz2: W5Movzbl, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match mz2:
    case W5MZYes{sr,dr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(sr,rC) && U32.is_eq(dr,rC),
        u => w5b_g12_apply(w5b_g12_scan(rC,r3,[],16,fnItems),fnItems,acc),
        u => None{})
    case W5MZNo{}: None{}

@unsafe
def w5b_g12_b_r2(+rC: U32, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}: w5b_g12_c(rC,w5_as_movzbl(i2),r3,fnItems,acc)
    case Nil{}: None{}

@unsafe
def w5b_g12_b(+rC: U32, sc1: W5Setcc, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match sc1:
    case W5SetYes{op,sr}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op,"sete") && U32.is_eq(sr,rC),
        u => w5b_g12_b_r2(rC,r2,fnItems,acc),
        u => None{})
    case W5SetNo{}: None{}

@unsafe
def w5_gpr_try_imm(im0: W4BImmReg, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im0:
    case W4BImmReg{op0,1,0,r,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"xorl"),
        u => w5_g8_b(r,w4b_as_imm_reg(i1),r2,fnItems,acc),
        u => None{})
    case W4BImmReg{op0,0,0,r,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"cmpq"),
        u => w5b_g12_b(r,w5_as_setcc(i1),r2,fnItems,acc),
        u => None{})
    case _: None{}"""


OLD_GPR_TRY_LD = """@unsafe
def w5_gpr_try_ld(ld0: W5LoadRbp, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld0:
    case W5LRYes{d1,rB}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}: w5_g1_b(d1,rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc)
        case _: None{}
    case W5LRNo{}: None{}"""

NEW_GPR_TRY_LD = """# G15: movq d1(%rbp), %rA; movq d2(%rbp), %rB; <comm64> %rA, %rB (%rA dead) -> movq d2(%rbp), %rB; <comm64> d1(%rbp), %rB
@unsafe
def w5b_g15_c(+d1: U32, +rA: U32, +d2: U32, +rB: U32, rr2: W4BRR, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr2:
    case W4BRR{+op2,s2,64,d_2,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op2) && U32.is_eq(s2,rA) && U32.is_eq(d_2,rB) &&
        Bool.not(U32.is_eq(rA,rB)) && Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)) &&
        w4b_reg_dead(rA,r3,fnItems,96),
        u => Some{w5_gpr_peep(r3,fnItems,
          Con{PInst{X187Instruction{op2,[X187Mem{5,d1},x188_reg(rB,64)]}},
          Con{PInst{X187Instruction{"movq",[X187Mem{5,d2},x188_reg(rB,64)]}},acc}})},
        u => None{})
    case _: None{}

@unsafe
def w5b_g15_b(+d1: U32, +rA: U32, ld1: W5LoadRbp, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5LRYes{d2,rB}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rA,rB)),
        u => w5b_g15_c(d1,rA,d2,rB,w4b_as_rr(i2),r3,fnItems,acc),
        u => None{})
    case W5LRNo{}: None{}

@unsafe
def w5_gpr_try_ld(ld0: W5LoadRbp, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld0:
    case W5LRYes{d1,rB}:
      match r2:
        case Con{+i2,Con{+i3,+r4}}:
          w4c_or_peep_opt(w5b_g1_b(X187Mem{5,d1},rB,w4b_as_rr(i1),i2,i3,r4,fnItems,acc),
            u => w5b_g15_b(d1,rB,w5_as_load_rbp(i1),i2,Con{i3,r4},fnItems,acc))
        case Con{+i2,+r3}: w5b_g15_b(d1,rB,w5_as_load_rbp(i1),i2,r3,fnItems,acc)
        case Nil{}: None{}
    case W5LRNo{}: None{}"""

# ---------------------------------------------------------------------------
# Pass 5: Loop-rotation exit-block budget 256 -> 512 + Leaf Free-GPR Slot Promotion
# ---------------------------------------------------------------------------
OLD_TAILDUP_CHECK = """@unsafe
def w4b_taildup_check(revBody: List<&2,X187Parsed>, +body: List<&2,X187Parsed>, +exitLbl: String) -> List<&2,X187Parsed>:
  match revBody:
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}:
      +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4b_taildup_replace(body,m1,mv,tst,jne,exitLbl),u => body)
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4b_taildup_replace(b1,m2,mv,tst,jne,exitLbl),u => b1)
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+mergeLbl},_}}}}:
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(mergeLbl,body),
        u => w4b_taildup_replace(body,mergeLbl,mv,tst,jne,exitLbl),
        u => body)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}}:
      +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4c_taildup_replace2(body,m1,mv1,mv2,tst,jne,exitLbl),u => body)
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4c_taildup_replace2(b1,m2,mv1,mv2,tst,jne,exitLbl),u => b1)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+mergeLbl},_}}}}}:
      nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(mergeLbl,body),
        u => w4c_taildup_replace2(body,mergeLbl,mv1,mv2,tst,jne,exitLbl),
        u => body)
    case _: body"""

NEW_TAILDUP_CHECK = """@unsafe
def w5b_is_pinst(x: X187Parsed) -> Bool:
  match x:
    case PInst{_}: True{}
    case _: False{}

@unsafe
def w4b_taildup_check(revBody: List<&2,X187Parsed>, +body: List<&2,X187Parsed>, +exitLbl: String) -> List<&2,X187Parsed>:
  match revBody:
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv),
        w =>
          +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4b_taildup_replace(body,m1,mv,tst,jne,exitLbl),u => body)
          nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4b_taildup_replace(b1,m2,mv,tst,jne,exitLbl),u => b1),
        w => body)
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+mergeLbl},_}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv) && w4b_has_jmp_to(mergeLbl,body),
        u => w4b_taildup_replace(body,mergeLbl,mv,tst,jne,exitLbl),
        u => body)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv2) && w5b_is_pinst(mv1),
        w =>
          +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4c_taildup_replace2(body,m1,mv1,mv2,tst,jne,exitLbl),u => body)
          nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4c_taildup_replace2(b1,m2,mv1,mv2,tst,jne,exitLbl),u => b1),
        w => body)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+mergeLbl},_}}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv2) && w5b_is_pinst(mv1) && w4b_has_jmp_to(mergeLbl,body),
        u => w4c_taildup_replace2(body,mergeLbl,mv1,mv2,tst,jne,exitLbl),
        u => body)
    case _: body"""

OLD_ROT_EXIT_1 = """        v => w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],256),before,loopLbl,bodyLbl,s,ws,orig),"""
NEW_ROT_EXIT_1 = """        v => w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],512),before,loopLbl,bodyLbl,s,ws,orig),"""

OLD_ROT_EXIT_2 = """        v => w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],256),before,loopLbl,bodyLbl,r,w,orig),"""
NEW_ROT_EXIT_2 = """        v => w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],512),before,loopLbl,bodyLbl,r,w,orig),"""

OLD_POST_SELECT_ROT = """  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +f5 = w5_run_rot(hasLbl,licm)"""

NEW_POST_SELECT_ROT = """  +licm = w5_run_licm(Bool.not(hasCall) && hasLbl && hasImulq,f4s)
  +prom = w5b_run_leaf_promote(Bool.not(hasCall) && hasNegRbp,licm)
  +f5 = w5_run_rot(hasLbl,prom)"""

OLD_W5_RUN_ROT_HDR = """@unsafe
def w5_run_rot(hasLbl: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:"""

NEW_W5_RUN_ROT_HDR = """# ---- W5B-R2: General Leaf-Function Free-GPR Stack-Slot Promotion ----

@unsafe
def w5b_reg_used(+r: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}:
      w4b_args_read_reg(r,args) || w5b_reg_used(r,rest)
    case Con{_,rest}: w5b_reg_used(r,rest)

@unsafe
def w5b_is_r12_save(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{12,64,False{}},Con{X187Mem{5,4294967280},Nil{}}}}}:
      agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w5b_is_r12_restore(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{5,4294967280},Con{X187Reg{12,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w5b_is_r12_ctx_init(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{7,64,False{}},Con{X187Reg{12,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w5b_item_uses_r12(h: X187Parsed) -> Bool:
  match h:
    case PInst{X187Instruction{_,args}}: w4b_args_read_reg(12,args)
    case _: False{}

@unsafe
def w5b_r12_check(items: List<&2,X187Parsed>, +hasSave: Bool, +hasInit: Bool) -> Bool:
  match items:
    case Nil{}: hasSave && hasInit
    case Con{+h,+rest}:
      nt_choose(Bool,w5b_is_r12_save(h),u => w5b_r12_check(rest,True{},hasInit),
        u => nt_choose(Bool,w5b_is_r12_restore(h),v => w5b_r12_check(rest,hasSave,hasInit),
          v => nt_choose(Bool,w5b_is_r12_ctx_init(h),w => w5b_r12_check(rest,hasSave,True{}),
            w => Bool.not(w5b_item_uses_r12(h)) && w5b_r12_check(rest,hasSave,hasInit))))

@unsafe
def w5b_is_gpr64_slot_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"addq") || agy_str_eq(op,"subq") ||
  agy_str_eq(op,"andq") || agy_str_eq(op,"orq") || agy_str_eq(op,"xorq") ||
  agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmoveq") || agy_str_eq(op,"cmovneq")

@unsafe
def w5b_is_gpr64_or_imm(op: X187Operand) -> Bool:
  match op:
    case X187Reg{_,64,False{}}: True{}
    case X187Imm{_,_}: True{}
    case _: False{}

@unsafe
def w5b_is_gpr64_reg(op: X187Operand) -> Bool:
  match op:
    case X187Reg{_,64,False{}}: True{}
    case _: False{}

type W5BSlotScan is Data:
  W5BSlotScan{+counts: W4CMap, +bad: W4CMap}

@unsafe
def w5b_mark_bad_op(op: X187Operand, +bad: W4CMap) -> W4CMap:
  match op:
    case X187Mem{b,+d}:
      nt_choose(W4CMap,w4c_is_neg_rbp(b,d),
        u => w4c_map_inc(bad,w4c_slot_key(d),w4c_slot_key(d),0),
        u => bad)
    case _: bad

@unsafe
def w5b_mark_bad_args(args: List<&2,X187Operand>, +bad: W4CMap) -> W4CMap:
  match args:
    case Nil{}: bad
    case Con{a,rest}: w5b_mark_bad_args(rest,w5b_mark_bad_op(a,bad))

@unsafe
def w5b_map_inc8(m: W4CMap, +k: U32) -> W4CMap:
  w4c_map_inc(w4c_map_inc(w4c_map_inc(w4c_map_inc(
    w4c_map_inc(w4c_map_inc(w4c_map_inc(w4c_map_inc(m,k,k,0),k,k,0),k,k,0),k,k,0),
    k,k,0),k,k,0),k,k,0),k,k,0)

@unsafe
def w5b_scan_slot_args(+op: String, args: List<&2,X187Operand>, +afterLbl: Bool, +counts: W4CMap, +bad: W4CMap) -> W5BSlotScan:
  match args:
    case Con{X187Mem{b,+d},Con{+dst,Nil{}}}:
      nt_choose(W5BSlotScan,w4c_is_neg_rbp(b,d),
        v => nt_choose(W5BSlotScan,
          U32.is_ge(w4c_slot_key(d),48) && w5b_is_gpr64_slot_op(op) && w5b_is_gpr64_reg(dst),
          w => W5BSlotScan{nt_choose(W4CMap,afterLbl,
            x => w5b_map_inc8(counts,w4c_slot_key(d)),
            x => w4c_map_inc(counts,w4c_slot_key(d),w4c_slot_key(d),0)),bad},
          w => W5BSlotScan{counts,w4c_map_inc(bad,w4c_slot_key(d),w4c_slot_key(d),0)}),
        v => W5BSlotScan{counts,w5b_mark_bad_op(dst,bad)})
    case Con{+src,Con{X187Mem{b,+d},Nil{}}}:
      nt_choose(W5BSlotScan,w4c_is_neg_rbp(b,d),
        v => nt_choose(W5BSlotScan,
          U32.is_ge(w4c_slot_key(d),48) && w5b_is_gpr64_slot_op(op) && w5b_is_gpr64_or_imm(src),
          w => W5BSlotScan{w4c_map_inc(counts,w4c_slot_key(d),w4c_slot_key(d),0),bad},
          w => W5BSlotScan{counts,w4c_map_inc(bad,w4c_slot_key(d),w4c_slot_key(d),0)}),
        v => W5BSlotScan{counts,w5b_mark_bad_op(src,bad)})
    case _: W5BSlotScan{counts,w5b_mark_bad_args(args,bad)}

@unsafe
def w5b_scan_slot_inst(+op: String, +args: List<&2,X187Operand>, beforeInit: Bool,
    +afterLbl: Bool, st: W5BSlotScan) -> W5BSlotScan:
  match st:
    case W5BSlotScan{+counts,+bad}:
      nt_choose(W5BSlotScan,beforeInit,
        u => W5BSlotScan{counts,w5b_mark_bad_args(args,bad)},
        u => w5b_scan_slot_args(op,args,afterLbl,counts,bad))

@unsafe
def w5b_scan_slot_item(h: X187Parsed, beforeInit: Bool, afterLbl: Bool, +st: W5BSlotScan) -> W5BSlotScan:
  match h:
    case PInst{X187Instruction{op,args}}: w5b_scan_slot_inst(op,args,beforeInit,afterLbl,st)
    case _: st

@unsafe
def w5b_is_plabel(h: X187Parsed) -> Bool:
  match h:
    case PLabel{_}: True{}
    case _: False{}

@unsafe
def w5b_scan_slots(items: List<&2,X187Parsed>, +waitInit: Bool, +afterLbl: Bool, +st: W5BSlotScan) -> W5BSlotScan:
  match items:
    case Nil{}: st
    case Con{+h,rest}:
      w5b_scan_slots(rest,waitInit && Bool.not(w5b_is_r12_ctx_init(h)),w5b_is_plabel(h),
        w5b_scan_slot_item(h,waitInit,afterLbl,st))

type W5BBestSlot is Data:
  W5BBestSlot{+key: U32, +cnt: U32}

@unsafe
def w5b_pick_best(m: W4CMap, +bad: W4CMap, +best: W5BBestSlot) -> W5BBestSlot:
  match m:
    case W4CMEmpty{}: best
    case W4CMLeaf{+k,+v}:
      match best:
        case W5BBestSlot{bk,bc}:
          nt_choose(W5BBestSlot,
            U32.is_eq(w4c_map_get(bad,k,k),0) && U32.is_gt(v,bc),
            u => W5BBestSlot{k,v},u => W5BBestSlot{bk,bc})
    case W4CMNode{z,o}: w5b_pick_best(o,bad,w5b_pick_best(z,bad,best))

@unsafe
def w5b_rew_op(+disp: U32, +rFree: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{b,+d}:
      nt_choose(X187Operand,U32.is_eq(b,5) && U32.is_eq(d,disp),
        u => x188_reg(rFree,64),u => X187Mem{b,d})
    case other: other

@unsafe
def w5b_rew_args(+disp: U32, +rFree: U32, args: List<&2,X187Operand>) -> List<&2,X187Operand>:
  match args:
    case Nil{}: []
    case Con{a,rest}: Con{w5b_rew_op(disp,rFree,a),w5b_rew_args(disp,rFree,rest)}

@unsafe
def w5b_rew_one(+disp: U32, +rFree: U32, h: X187Parsed) -> X187Parsed:
  match h:
    case PInst{X187Instruction{op,args}}: PInst{X187Instruction{op,w5b_rew_args(disp,rFree,args)}}
    case other: other

@unsafe
def w5b_rew_items(+disp: U32, +rFree: U32, +dropInit: Bool, items: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,dropInit && w5b_is_r12_ctx_init(h),
        u => w5b_rew_items(disp,rFree,False{},rest,acc),
        u => w5b_rew_items(disp,rFree,dropInit,rest,Con{w5b_rew_one(disp,rFree,h),acc}))

@unsafe
def w5b_promote_do(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>, best: W5BBestSlot) -> List<&2,X187Parsed>:
  match best:
    case W5BBestSlot{+k,cnt}:
      nt_choose(List<&2,X187Parsed>,U32.is_eq(k,0),u => items,
        u => w5b_rew_items(U32.sub(0,k),rFree,isR12,items,[]))

@unsafe
def w5b_promote_pick(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>, st: W5BSlotScan) -> List<&2,X187Parsed>:
  match st:
    case W5BSlotScan{counts,bad}: w5b_promote_do(rFree,isR12,items,w5b_pick_best(counts,bad,W5BBestSlot{0,2}))

@unsafe
def w5b_promote_one(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w5b_promote_pick(rFree,isR12,items,w5b_scan_slots(items,isR12,False{},W5BSlotScan{W4CMEmpty{},W4CMEmpty{}}))

@unsafe
def w5b_promote_cleanup(+orig: List<&2,X187Parsed>, +prom: List<&2,X187Parsed>, changed: Bool) -> List<&2,X187Parsed>:
  match changed:
    case False{}: orig
    case True{}:
      +p1 = w5_flat_rev_seq(w4b_copy_peep(prom,prom,[]),[])
      w5_flat_rev_seq(w4c_peep_cfg(p1,p1,[]),[])

@unsafe
def w5b_leaf_slot_promote_go(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +canRcx = Bool.not(w5b_reg_used(1,items))
  +canR12 = w5b_r12_check(items,False{},False{})
  +p1 = nt_choose(List<&2,X187Parsed>,canRcx,v => w5b_promote_one(1,False{},items),v => items)
  +p2 = nt_choose(List<&2,X187Parsed>,canR12,v => w5b_promote_one(12,True{},p1),v => p1)
  w5b_promote_cleanup(items,p2,canRcx || canR12)

@unsafe
def w5b_leaf_slot_promote(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  nt_choose(List<&2,X187Parsed>,w4c_has_leaq_rbp(items),u => items,u => w5b_leaf_slot_promote_go(items))

@unsafe
def w5b_run_leaf_promote(doProm: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match doProm:
    case True{}: w5b_leaf_slot_promote(items)
    case False{}: items

@unsafe
def w5_run_rot(hasLbl: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    text = args.src.read_text()
    text = replace_once(text, OLD_X195S_TEXT, NEW_X195S_TEXT, "x195s_text direct sqrtss")
    text = replace_once(text, OLD_X200R_SQRT, NEW_X200R_SQRT, "x200r_sqrt_core direct sqrtss")
    text = replace_once(text, OLD_LOOP_JOIN, NEW_LOOP_JOIN, "x191_loop_join exit-cond priority")
    text = replace_once(text, OLD_REG_DEAD_LAW, NEW_REG_DEAD_LAW, "w4b_reg_dead_step law")
    text = replace_once(text, OLD_REG_DEAD, NEW_REG_DEAD, "w4b_reg_dead cycle-aware + setcc")
    text = replace_once(text, OLD_TAILDUP_CHECK, NEW_TAILDUP_CHECK, "w4b_taildup_check PInst guard")
    text = replace_once(text, OLD_ROT_EXIT_1, NEW_ROT_EXIT_1, "w4c_rotate_check_test exit 512")
    text = replace_once(text, OLD_ROT_EXIT_2, NEW_ROT_EXIT_2, "w4c_rotate_check_cmp exit 512")
    text = replace_once(text, OLD_W5_X2_C, NEW_W5_X2_C, "w5_x2_c allow self-op")
    text = replace_once(text, OLD_W5_XMM_MA_R2, NEW_W5_XMM_MA_R2, "w5b X7/X8/X9 XMM folds")
    text = replace_once(text, OLD_W5_G7, NEW_W5_G7, "w5b G7-shift + G10 copy-chain")
    text = replace_once(text, OLD_GPR_RR64, NEW_GPR_RR64, "w5_gpr_rr64_r2 hook G10")
    text = replace_once(text, OLD_GPR_TRY_IMM, NEW_GPR_TRY_IMM, "w5_gpr_try_imm hook G12")
    text = replace_once(text, OLD_GPR_TRY_LD, NEW_GPR_TRY_LD, "w5_gpr_try_ld hook G15")
    text = replace_once(text, OLD_W5_RUN_ROT_HDR, NEW_W5_RUN_ROT_HDR, "w5b_leaf_slot_promote defs")
    text = replace_once(text, OLD_POST_SELECT_ROT, NEW_POST_SELECT_ROT, "w4_post_select hook leaf promote")

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(text)
    print(f"Wrote {args.dst} ({len(text)} bytes)")


if __name__ == "__main__":
    main()
