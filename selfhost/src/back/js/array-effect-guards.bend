# Every closed native Array graph needs fresh allocation/host permission on
# its handle path too. Refusing raw layout must not admit a weaker private body.
@unsafe
def j_array_effect_has_native(+helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}: (db(d) && j_array_effect_known(dn(d))) || j_array_effect_has_native(rest)

@unsafe
def j_array_effect_guard(+book: List<&2,KDef>, +d: KDef, +helpers: List<&2,KDef>, +original: String) -> String:
  kc(String, j_array_effect_has_native(helpers), u => "arrayViewHostGuard()&&", u => original)
