# In a nonexact fact lo/hi are mandatory one bits, never an exact value.
@unsafe
def p113l_ones(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_ne(lo,0) || U32.is_ne(hi,0)

@unsafe
def p113k_limit(fact: P113KFact, +width: U32) -> P113KFact:
  match fact:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,exact,u => p113k_exact(lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)),
        u => P113KFact{U32.min(bits,width),False{},lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)})

@unsafe
def p113k_join_fact(left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re && U32.is_eq(ll,rl) && U32.is_eq(lh,rh),
        u => p113k_exact(ll,lh),u => P113KFact{U32.max(lb,rb),False{},U32.and(ll,rl),U32.and(lh,rh)})

@unsafe
def p113l_enrich(+answer: P113KFact, op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match answer left right:
    case P113KFact{+bits,+exact,lo,hi} P113KFact{lb,le,ll,lh} P113KFact{rb,re,rl,rh}:
      nt_choose(P113KFact,Bool.not(exact) && String.eq(op,"or"),
        u => P113KFact{bits,False{},U32.or(ll,rl),U32.or(lh,rh)},u => answer)

@unsafe
def p113k_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  p113l_enrich(p113l_base_binary(op,left,right,width),op,left,right)

@unsafe
def p113k_compare(+op: String, +left: P113KFact, +right: P113KFact) -> P113KFact:
  nt_choose(P113KFact,p113k_zero(left) && p113l_ones(right),u => p113k_unsigned(op,False{},True{}),u =>
    nt_choose(P113KFact,p113l_ones(left) && p113k_zero(right),u => p113k_unsigned(op,False{},False{}),u => p113l_base_compare(op,left,right)))
