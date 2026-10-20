@unsafe
def p113k_shift(+left: P113KFact, +amount: U32, +right: Bool) -> P113KFact:
  match left:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,U32.is_eq(amount,0),u => left,u =>
      nt_choose(P113KFact,Bool.not(exact),
        u => p113k_bound(nt_choose(U32,right,v => nt_choose(U32,U32.is_ge(amount,bits),w => 0,w => U32.sub(bits,amount)),v => U32.min(64,U32.add(bits,amount)))),u =>
      nt_choose(P113KFact,U32.is_lt(amount,32),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.or(U32.shrn(lo,U32.to_nat(amount)),U32.shln(hi,U32.to_nat(U32.sub(32,amount)))),U32.shrn(hi,U32.to_nat(amount))),
          v => p113k_exact(U32.shln(lo,U32.to_nat(amount)),U32.or(U32.shln(hi,U32.to_nat(amount)),U32.shrn(lo,U32.to_nat(U32.sub(32,amount)))))),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.shrn(hi,U32.to_nat(U32.sub(amount,32))),0),
          v => p113k_exact(0,U32.shln(lo,U32.to_nat(U32.sub(amount,32))))))))

@unsafe
def p113k_unsigned(+op: String, +equal: Bool, +less: Bool) -> P113KFact:
  nt_choose(P113KFact,String.eq(op,"eq"),u => p113k_exact(Bool.to_u32(equal),0),u =>
  nt_choose(P113KFact,String.eq(op,"ne"),u => p113k_exact(Bool.to_u32(Bool.not(equal)),0),u =>
  nt_choose(P113KFact,String.eq(op,"ult"),u => p113k_exact(Bool.to_u32(less),0),u =>
  nt_choose(P113KFact,String.eq(op,"ule"),u => p113k_exact(Bool.to_u32(less || equal),0),u =>
  nt_choose(P113KFact,String.eq(op,"ugt"),u => p113k_exact(Bool.to_u32(Bool.not(less || equal)),0),u =>
  nt_choose(P113KFact,String.eq(op,"uge"),u => p113k_exact(Bool.to_u32(Bool.not(less)),0),u => p113k_bound(1)))))))

@unsafe
def p113k_compare(+op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re,
        u => p113k_unsigned(op,U32.is_eq(ll,rl) && U32.is_eq(lh,rh),U32.is_lt(lh,rh) || (U32.is_eq(lh,rh) && U32.is_lt(ll,rl))),u =>
      nt_choose(P113KFact,re && U32.is_lt(lb,rb),u => p113k_unsigned(op,False{},True{}),u =>
      nt_choose(P113KFact,le && U32.is_lt(rb,lb),u => p113k_unsigned(op,False{},False{}),u => p113k_bound(1))))

@unsafe
def p113k_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,p111v_comparison(op),u => p113k_compare(op,left,right),u =>
      nt_choose(P113KFact,String.eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),v => p113k_bound(U32.min(lb,rb))),u =>
      nt_choose(P113KFact,String.eq(op,"or"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.or(ll,rl),U32.or(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,String.eq(op,"xor"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.xor(ll,rl),U32.xor(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,(String.eq(op,"shr") || String.eq(op,"shl")) && re && U32.is_eq(rh,0) && U32.is_lt(rl,width),
        u => p113k_shift(left,rl,String.eq(op,"shr")),u =>
      nt_choose(P113KFact,String.eq(op,"add"),u => p113k_bound(U32.min(width,U32.inc(U32.max(lb,rb)))),u =>
      nt_choose(P113KFact,String.eq(op,"mul"),u => p113k_bound(U32.min(width,U32.add(lb,rb))),
        u => p113k_bound(width))))))))

@unsafe
def p113k_bin_fact(+typ: N111Type, +op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  +width = p113k_width(typ)
  p113k_limit(p113k_binary(op,p113k_limit(left,width),p113k_limit(right,width),width),width)

@unsafe
def p113k_ones(+bits: U32) -> U32:
  nt_choose(U32,U32.is_eq(bits,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(bits)),1))

@unsafe
def p113k_mask_covers(+bits: U32, mask: P113KFact) -> Bool:
  match mask:
    case P113KFact{mb,+exact,+lo,+hi}:
      exact && nt_choose(Bool,U32.is_le(bits,32),
        u => U32.is_eq(U32.and(lo,p113k_ones(bits)),p113k_ones(bits)),
        u => U32.is_eq(lo,4294967295) && U32.is_eq(U32.and(hi,p113k_ones(U32.sub(bits,32))),p113k_ones(U32.sub(bits,32))))

@unsafe
def p113k_bits_of(fact: P113KFact) -> U32:
  match fact:
    case P113KFact{bits,exact,lo,hi}: bits

@unsafe
def p113k_zero(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_eq(bits,0)

@unsafe
def p113k_result_type(+typ: N111Type, +op: String) -> N111Type:
  nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => typ)

@unsafe
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(N111Stmt,exact,u => N111Set{name,p113k_result_type(typ,op),N111Const{lo,hi}},u =>
      nt_choose(N111Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add") || String.eq(op,"sub")) && p113k_zero(rf)),
        u => N111Set{name,typ,left},u =>
      nt_choose(N111Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(lf)),
        u => N111Set{name,typ,right},u => N111Bin{name,typ,op,left,right})))
