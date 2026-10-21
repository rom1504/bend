# Version02 preserves both original input width and comparison result width.
# Existing full-value bound<=1 proves x==1 iff x!=0. No narrowing copy/XOR.
@unsafe
def p120wb_candidate(+op: String, left: P113KFact, +right: P113KFact) -> Bool:
  U32.is_le(p113k_bits_of(left),1) && (String.eq(op,"eq") || String.eq(op,"ne")) &&
    p113l_exact_one(right)

@unsafe
def p120wb_original_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add") || String.eq(op,"sub")) && p113k_zero(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right})))

@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, +answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,exact,lo,hi}:
      nt_choose(N111Stmt,Bool.not(exact) && p120wb_candidate(op,lf,rf),
        u => N111Bin{name,typ,nt_choose(String,String.eq(op,"eq"),v => "ne",v => "eq"),left,N111Const{0,0}},
        u => p120wb_original_bin_stmt(name,typ,op,left,right,lf,rf,answer))
