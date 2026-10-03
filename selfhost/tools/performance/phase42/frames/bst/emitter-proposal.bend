# Prospective additions, not installed or checked. Caller is the explicit owned
# graph emitter after exact native Sigma/nonerased two-field type and complete
# Tuple coverage proof. These are not public/general match dispatch functions.

@unsafe
def j_owned_tuple_fields(+arg: String, +at: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, 2), u => rest, u =>
    Con{"(" ++ arg ++ ")[" ++ U32.show(at) ++ "]", j_owned_tuple_fields(arg, U32.inc(at), rest)})

# Only the one proved native Tuple arm is emitted. Its original specialized
# telescope drives each binder; erased or dependent products are outside scope.
@unsafe
def j_owned_component_tuple(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>, +d: KDef, +phase: U32) -> String:
  "{" ++ j_component_emit(book, env, kid(t, 0), j_arm_type(book, ty, "Tuple"),
    j_owned_tuple_fields(arg, 0, rest), d, phase) ++ "}"

@unsafe
def j_owned_finite_tuple(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>) -> String:
  "{" ++ j_finite_emit(book, env, kid(t, 0), j_arm_type(book, ty, "Tuple"),
    j_owned_tuple_fields(arg, 0, rest)) ++ "}"

# Optional construction-only ablation after match/admission has passed. Shared
# typed argument lowering preserves field order and exact child references.
@unsafe
def j_owned_pair_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  "[" ++ j_ctor_args(book, env, ks(t),
    j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), "Tuple")), ks(wnf(book, ty)))) ++ "]"
