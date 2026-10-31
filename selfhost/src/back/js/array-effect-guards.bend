
# Module: src/back/js/array-effect-guards.bend:4
@unsafe
def j_array_effect_has_native(+helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}: (db(d) && j_array_effect_known(dn(d))) || j_array_effect_has_native(rest)

# Module: src/back/js/array-effect-guards.bend:10
@unsafe
def j_array_effect_guard(+book: List<&2,KDef>, +d: KDef, +helpers: List<&2,KDef>, +original: String) -> String:
  kc(String, j_array_effect_has_native(helpers), u => "arrayViewHostGuard()&&", u => original)
