# Early ownership facts. N_W32 means a nonowning canonical scalar here;
# it does not authorize truncating its physical U64 Term representation.
# The checked book and generated NOp provenance are caller premises.
@unsafe
def p113_scalar_result_name(+name: String) -> Bool:
  nb_contains([
    "u32_add", "u32_sub", "u32_and", "u32_or", "u32_xor", "u32_mul",
    "u32_is_eq", "u32_is_ne", "u32_is_lt", "u32_is_le", "u32_is_gt", "u32_is_ge",
    "u32_inc", "u32_shl", "u32_shr", "u32_shln", "u32_shrn", "u32_div", "u32_mod", "u32_not", "u32_is_zero",
    "u32_to_f32", "u32_from_nat",
    "f32_add", "f32_sub", "f32_mul", "f32_div",
    "f32_is_eq", "f32_is_ne", "f32_is_lt", "f32_is_le", "f32_is_gt", "f32_is_ge",
    "f32_sqrt", "f32_exp", "f32_log", "f32_log2", "f32_log10", "f32_sin", "f32_cos", "f32_tan",
    "f32_asin", "f32_acos", "f32_atan", "f32_sinh", "f32_cosh", "f32_tanh",
    "f32_floor", "f32_ceil", "f32_trunc", "f32_abs", "f32_pow", "f32_atan2", "f32_mod", "f32_neg",
    "f32_to_u32", "f32_bits", "nat_is_lt", "bool_or", "bool_xor"], name)

@unsafe
def p113_primitive_kind(+name: String, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, p113_scalar_result_name(name),
    u => nt_choose(N_WordKind, U32.is_eq(arity, nc_primitive_arity(name)), v => N_W32{}, v => N_W64{}),
    u => N_W64{})

# Consume the original checked telescope without substituting arguments.
# Any dependence on a crossed binder refuses the entire result fact.
@unsafe
def p113_result_tele(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, U32.is_eq(fuel,0), u => N_W64{},
    u => p113_result_head(book,nq_layout_type(book,ty),left,U32.sub(fuel,1)))

@unsafe
def p113_result_head(+book: List<&2,KDef>, +head: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"All"),
    u => nt_choose(N_WordKind, U32.is_eq(terms_len(ks(head)),2) && Bool.not(nc_occurs(kid(head,1),ix(head))),
      v => nt_choose(N_WordKind, U32.is_eq(qt(head),0),
        w => p113_result_tele(book,kid(head,1),left,fuel),
        w => nt_choose(N_WordKind, U32.is_gt(left,0),
          z => p113_result_tele(book,kid(head,1),U32.sub(left,1),fuel), z => N_W64{})),
      v => N_W64{}),
    u => nt_choose(N_WordKind, U32.is_eq(left,0), v => nf_scalar_kind(book,head), v => N_W64{}))

@unsafe
def p113_callee_def(+book: List<&2,KDef>, +d: KDef, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, String.eq(dk(d),"Def") && Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d)),
    u => nt_choose(N_WordKind, U32.is_eq(arity,nd_arity(book,dn(d))),
      v => p113_result_tele(book,dt(d),arity,256), v => N_W64{}),
    u => N_W64{})

@unsafe
def p113_callee_kind(+book: List<&2,KDef>, +head: KTerm, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"Ref") && Bool.not(U32.is_eq(qt(head),3)),
    u => p113_callee_def(book,lookup(book,nm(head)),arity), u => N_W64{})

@unsafe
def p113_application_kind(+book: List<&2,KDef>, +value: KTerm, +native: String) -> N_WordKind:
  nt_choose(N_WordKind, String.is_empty(native),
    u => p113_callee_kind(book,nd_head(value),terms_len(nd_args(value,[]))),
    u => p113_primitive_kind(native,terms_len(nd_args(value,[]))))

@unsafe
def p113_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(value,"Var") || p98_tag_eq(value,"NWord"),
    u => nk_value(value,env),
    u => nt_choose(N_WordKind, p98_tag_eq(value,"NOp"),
      v => p113_primitive_kind(nm(value),terms_len(ks(value))),
      v => nt_choose(N_WordKind, p98_tag_eq(value,"App"),
        w => p113_application_kind(book,value,nd_native_call(book,value)),
        w => nt_choose(N_WordKind, p98_tag_eq(value,"Ref"),
          z => p113_callee_kind(book,value,0), z => N_W64{}))))

@unsafe
def p113_binding(+book: List<&2,KDef>, +id: U32, +value: KTerm, +env: List<&2,NC_Binding>) -> NC_Binding:
  NC_Binding{id,"v_" ++ U32.show(id),p113_value_kind(book,value,env)}
