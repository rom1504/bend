# Current compiler index updates/reads; helper declarations are extracted unchanged.
# Keep earlier aliases to exercise persistent updates and the collision bucket.
@unsafe
def p193t_build(+i: U32) -> KDef:
  +a = p111v_put(missing(),"compiler_hot_value","local",U32.add(i,1),U32.add(i,101))
  +b = p111v_put(a,"compiler_hot_values","local",U32.add(i,2),U32.add(i,102))
  +c = p111v_put(b,"costarring","local",U32.add(i,3),U32.add(i,103))
  +d = p111v_put(c,"liquid","alloca",U32.add(i,4),U32.add(i,104))
  +e = p111v_put(d,"解析.λ名字","local",U32.add(i,5),U32.add(i,105))
  p111v_put(e,"","local",U32.add(i,6),U32.add(i,106))

@unsafe
def p193t_values(+i: U32) -> List<&2,KDef>:
  +first = p193t_build(i)
  +second = p111v_put(first,"costarring","updated",U32.add(i,33),U32.add(i,133))
  +tree = p111v_put(second,"compiler_hot_value","updated",U32.add(i,11),U32.add(i,111))
  [p111v_get(first,"costarring"),
   p111v_get(first,"compiler_hot_value"),
   p111v_get(tree,"costarring"),
   p111v_get(tree,"liquid"),
   p111v_get(tree,"compiler_hot_value"),
   p111v_get(tree,"compiler_hot_values"),
   p111v_get(tree,"解析.λ名字"),
   p111v_get(tree,""),
   p111v_get(tree,"compiler_hot_valuf"),
   p111v_get(tree,"解析.λ名子")]

@unsafe
def p193t_continue(left: U32, i: U32, h: U32, words: List<&2,U32>) -> U32:
  match words:
    case Con{count,Con{first,Con{second,Nil{}}}}:
      p193t_go(left,i,p163r_mix(p163r_mix(p163r_mix(h,count),first),second))
    case _: 0

@unsafe
def p193t_go(left: U32, +i: U32, +h: U32) -> U32:
  match left:
    case 0: h
    case n: p193t_continue(U32.sub(n,1),U32.inc(i),h,p163r_digest(p193t_values(i)))

@unsafe
def p193t_run(n: U32) -> U32:
  p193t_go(n,0,2166136261)
