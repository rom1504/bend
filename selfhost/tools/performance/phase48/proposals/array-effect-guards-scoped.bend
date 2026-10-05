# Newly admitted native effects need the complete no-callback allocation fence
# on their HANDLE path too. A failed raw guard must not enter a weaker private
# body whose allocation can mutate source dependencies through fill callbacks.
# Existing U32 new/get/set-only graphs retain their prior guard observations.
@unsafe
def j_array_effect_guard_required(+book: List<&2,KDef>, +d: KDef, +helpers: List<&2,KDef>) -> Bool:
  kc(Bool, j_array_effect_has_native(helpers), u =>
    j_array_effect_guard_helpers(book, helpers) || j_array_effect_float_calls(book, [dv(d)], 8192), u => False{})

@unsafe
def j_array_effect_has_native(+helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}: (db(d) && j_array_effect_known(dn(d))) || j_array_effect_has_native(rest)

@unsafe
def j_array_effect_guard_helpers(+book: List<&2,KDef>, +helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}:
      (db(d) && (String.eq(dn(d), "Array.swap") || String.eq(dn(d), "Array.size"))) ||
      (Bool.not(db(d)) && j_array_effect_float_calls(book, [dv(d)], 8192)) ||
      j_array_effect_guard_helpers(book, rest)

# Source aliases are normalized at the native element position. Ordinary term
# annotations alone are not relied on to establish a floating allocation.
# Exhaustion chooses the stronger guard; it never authorizes a weaker one.
@unsafe
def j_array_effect_float_calls(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        j_array_effect_float_call(book, t) ||
          j_array_effect_float_calls(book, List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)), u => True{})

@unsafe
def j_array_effect_float_call(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  kc(Bool, String.eq(tg(t), "JNative"),
    u => j_array_effect_known(nm(t)) && String.eq(j_array_effect_element(book, kid(t, 0)), "F32"), u =>
    kc(Bool, String.eq(tg(t), "App"),
      u => j_array_effect_float_spine(book, j_call_spine(t, Nil{})), u => False{}))

@unsafe
def j_array_effect_float_spine(+book: List<&2,KDef>, +spine: KTerm) -> Bool:
  String.eq(tg(spine), "Call") && j_array_effect_known(nm(spine)) &&
    U32.is_gt(terms_len(ks(spine)), 0) && String.eq(j_array_effect_element(book, kid(spine, 0)), "F32")

# Each caller supplies its old complete guard text as the refusal-preserving
# default. The new required guard precedes input checks and dependency reads.
@unsafe
def j_array_effect_guard(+book: List<&2,KDef>, +d: KDef, +helpers: List<&2,KDef>, +original: String) -> String:
  kc(String, j_array_effect_guard_required(book, d, helpers), u => "arrayViewHostGuard()&&", u => original)
