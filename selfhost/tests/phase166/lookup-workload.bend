# Actual compiler lookup computation. Dependencies are the unchanged Phase163
# direct-workloads.bend and direct-runtime.bend plus maintained compiler helpers.
# Full values are exported for hosted controls; native runs digest every field
# and release each round before continuing. No generated answer is precomputed.

@unsafe
def p166l_names(+i: U32) -> List<&2,KDef>:
  [p163w_row("p111q_value",U32.add(i,17)),
   p163w_row("p111q_values",U32.add(i,18)),
   p163w_row("p113d_candidate",U32.add(i,19)),
   p163w_row("解析.λ名字",U32.add(i,20))]

@unsafe
def p166l_values(+i: U32) -> List<&2,KDef>:
  +book = p166l_names(i)
  p163w_lookup_round(i,
    [lookup(book,"p111q_value"),
     lookup(book,"p111q_valuf"),
     lookup(book,"q111q_value"),
     lookup(book,"p111q_values"),
     lookup(book,"p111q_valu"),
     lookup(book,"解析.λ名字"),
     lookup(book,"解析.λ名子"),
     lookup(book,"p113d_candidate")])

@unsafe
def p166l_expected_values(+i: U32) -> List<&2,KDef>:
  p163w_lookup_expected_round(i,
    [p163w_row("p111q_value",U32.add(i,17)),
     p163w_absent(),p163w_absent(),
     p163w_row("p111q_values",U32.add(i,18)),
     p163w_absent(),
     p163w_row("解析.λ名字",U32.add(i,20)),
     p163w_absent(),
     p163w_row("p113d_candidate",U32.add(i,19))])

@unsafe
def p166l_continue(left: U32, i: U32, h: U32, words: List<&2,U32>) -> U32:
  match words:
    case Con{count,Con{first,Con{second,Nil{}}}}:
      p166l_go(left,i,p163r_mix(p163r_mix(p163r_mix(h,count),first),second))
    case _: 0

@unsafe
def p166l_go(left: U32, +i: U32, +h: U32) -> U32:
  match left:
    case 0: h
    case n:
      p166l_continue(U32.sub(n,1),U32.inc(i),h,p163r_digest(p166l_values(i)))

@unsafe
def p166l_run(n: U32) -> U32:
  p166l_go(n,0,2166136261)
