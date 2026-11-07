# Source-level ownership experiment; replace only canonical f_pattern_sub.
# The complete record is destructured before recursion. No old parent is held
# while an owned child-list result is traversed. Matching-variable replacement
# still delegates to the unchanged f_pattern_value and list recursion remains
# the unchanged f_pattern_subs. Every field/variant is preserved exactly.
@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KTerm{tag,name,nodeId,quant,kids,removed,begin,end}:
      f_choose(KTerm,f_eq(tag,"Var") && U32.is_eq(nodeId,id),
        u => f_pattern_value(value,begin,end),
        u => KTerm{tag,name,nodeId,quant,f_pattern_subs(kids,id,value),removed,begin,end})
    case KLambda{name,nodeId,quant,kids,removed,begin,end,present}:
      KLambda{name,nodeId,quant,f_pattern_subs(kids,id,value),removed,begin,end,present}
    case KLiteral{kind,number,text,begin,end}: t
