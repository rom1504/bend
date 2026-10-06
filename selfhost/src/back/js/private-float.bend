# Only the typed private-region planner creates this leaf. The complete plan
# must still succeed before emission; its F32 name retains the full host guard.
# Ordinary literals and every nonfinite payload keep their original decoder.
@unsafe
def j_private_float_plan(+t: KTerm) -> KTerm:
  kc(KTerm, core_literal(t) && String.eq(nm(t), "F32") && j_private_float_finite(kl_number(t)),
    u => kt("JF32", "F32", kl_number(t), 0, Nil{}), u => t)

# Retain the original shared-view write, including its position and exceptions.
# Under the unchanged full host proof, the following native read is inert. All
# finite binary32 values are exact binary64 dyadics; no Math helper is needed.
@unsafe
def j_private_float_code(+bits: U32) -> String:
  kc(String, j_private_float_finite(bits), u =>
    "(/* private finite F32 */floatView.setUint32(0," ++ U32.show(bits) ++ ",true)," ++
    kc(String, U32.is_eq(U32.and(bits, 2147483648), 0),
      u => j_private_float_magnitude(bits), u => "-(" ++ j_private_float_magnitude(bits) ++ ")") ++ ")",
    u => "bitsFloat(" ++ U32.show(bits) ++ ")")
