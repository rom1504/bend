@unsafe
def p113l_base_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
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
def p113l_base_compare(+op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re,
        u => p113k_unsigned(op,U32.is_eq(ll,rl) && U32.is_eq(lh,rh),U32.is_lt(lh,rh) || (U32.is_eq(lh,rh) && U32.is_lt(ll,rl))),u =>
      nt_choose(P113KFact,re && U32.is_lt(lb,rb),u => p113k_unsigned(op,False{},True{}),u =>
      nt_choose(P113KFact,le && U32.is_lt(rb,lb),u => p113k_unsigned(op,False{},False{}),u => p113k_bound(1))))


@unsafe
def p113l_base_scalar(stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      P113KScalar{[N111Set{name,typ,p113k_replace(value,facts)}],p113k_put(facts,name,p113k_limit(p113k_value(value,facts),p113k_width(typ)))}
    case N111Bin{name,typ,op,+left,+right}: p113k_scalar_bin(name,typ,op,left,right,facts,p113k_value(left,facts),p113k_value(right,facts))
    case N111Call{+name,typ,symbol,args}: P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(64))}
    case N111If{+condition,yes,no}: p113k_scalar_if(condition,yes,no,facts,p113k_value(condition,facts))
    case N111Load{+name,typ,base,offset}: P113KScalar{[N111Load{name,typ,base,offset}],p113k_put(facts,name,p113k_bound(64))}
    case N111Store{typ,base,offset,value}: P113KScalar{[N111Store{typ,base,offset,p113k_replace(value,facts)}],facts}
    case N111Offset{+name,base,bytes}: P113KScalar{[N111Offset{name,base,bytes}],p113k_put(facts,name,p113k_bound(64))}
    case N111Alloca{+name,bytes,align}: P113KScalar{[N111Alloca{name,bytes,align}],p113k_put(facts,name,p113k_bound(64))}
    case N111Return{value}: P113KScalar{[N111Return{value}],facts}

