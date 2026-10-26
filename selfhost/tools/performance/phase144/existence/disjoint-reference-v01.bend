# Exact original final03 traversal, with only its definition and recursive
# references renamed. Retained as an independent control oracle after override.
@unsafe
def p144ce_original_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, Bool.not(constructor_exists(context, dn(d))) && p144ce_original_disjoint(dc(d), context), u => p144ce_original_disjoint(rest, context), u => False{})
