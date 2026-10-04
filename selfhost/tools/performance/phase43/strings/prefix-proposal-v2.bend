# Complete-JPure continuation prefix: a total arithmetic helper is evaluated at
# its original Let site. No allocation/effect/container helper is admitted here.
@unsafe
def j_string_u32_telescope(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, head, "U32"), u =>
    kc(Bool, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_primitive_type(book, wnf(book, kid(head, 0)), "U32"),
      u => j_string_u32_telescope(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

@unsafe
def j_string_total_u32(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{term, rest}:
      +t = j_strip(term)
      +spine = j_call_spine(t, Nil{})
      kc(Bool, U32.is_gt(fuel, 0), u =>
        kc(Bool, String.eq(tg(t), "Var") || (String.eq(tg(t), "Lit") && (String.eq(nm(t), "U32") || String.eq(nm(t), "Nat"))),
          u => j_string_total_u32(book, rest, U32.sub(fuel, 1)), u =>
        kc(Bool, String.eq(tg(t), "App") && j_primitive_call(book, spine) && String.starts_with(nm(spine), "U32.") && Bool.not(String.eq(j_primitive_result(nm(spine)), "F32")),
          u => j_string_total_u32(book, List.append(&2, KTerm, ks(spine), rest), U32.sub(fuel, 1)), u =>
        kc(Bool, String.eq(tg(t), "Lam") || String.eq(tg(t), "Let") || String.eq(tg(t), "Bind"),
          u => j_string_total_u32(book, List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{}))), u => False{})

@unsafe
def j_string_u32_call_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm) -> Bool:
  +spine = j_call_spine(j_strip(t), Nil{})
  +d = lookup(book, nm(spine))
  kc(Bool, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) &&
    U32.is_eq(terms_len(ks(spine)), da(d)) && j_string_u32_telescope(book, dt(d), da(d)), u =>
      kc(Bool, j_string_total_u32(book, [dv(d)], 512) && j_pure_valid(j_direct_cached(book, dn(d))),
        u => j_string_u32_call_args(book, env, ks(spine)), u => False{}), u => False{})

@unsafe
def j_string_u32_call_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{a, rest}: kc(Bool, j_linear_u32_prefix(book, env, a, 128), u => j_string_u32_call_args(book, env, rest), u => False{})
