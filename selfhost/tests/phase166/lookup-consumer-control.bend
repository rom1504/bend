# Counterfactual: independently specified complete records with the same digest/fold.
# Source producer changes; timing differences are not an exact component subtraction.

@unsafe
def p166c_continue(left: U32, i: U32, h: U32, words: List<&2,U32>) -> U32:
  match words:
    case Con{count,Con{first,Con{second,Nil{}}}}:
      p166c_go(left,i,p163r_mix(p163r_mix(p163r_mix(h,count),first),second))
    case _: 0

@unsafe
def p166c_go(left: U32, +i: U32, +h: U32) -> U32:
  match left:
    case 0: h
    case n:
      p166c_continue(U32.sub(n,1),U32.inc(i),h,p163r_digest(p166l_expected_values(i)))

@unsafe
def p166c_run(n: U32) -> U32:
  p166c_go(n,0,2166136261)
