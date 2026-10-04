# Exact native scalar-key components needed by closed Map graphs. These proof
# rows do not create public argument admission or change residual native code.
@unsafe
def j_map_cmp_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Cmp")
  +kind = wnf(book, dt(owner))
  j_map_cmp_nominal(ty) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "LT"), "LT", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "EQ"), "EQ", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "GT"), "GT", ty)

# ADT quant0/1 is source-node metadata, not a Cmp quantity parameter. The
# canonical owner has no parameters; constructors must terminate at this exact
# nominal zeroarity type. No recursive type proof or metadata-erasing rewrite.
@unsafe
def j_map_cmp_nominal(+ty: KTerm) -> Bool:
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Cmp") && U32.is_eq(ix(ty), 0) &&
    (U32.is_eq(qt(ty), 0) || U32.is_eq(qt(ty), 1)) &&
    List.is_empty(&2,KTerm, ks(ty)) && List.is_empty(&2,String, rm(ty))

@unsafe
def j_map_cmp_ctor(+book: List<&2,KDef>, +c: KDef, +name: String, +ty: KTerm) -> Bool:
  j_pure_native_ctor(c, name, 0) && j_map_cmp_nominal(ty) && j_map_cmp_nominal(wnf(book, dt(c)))

@unsafe
def j_map_maybe_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Maybe")
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Maybe") && U32.is_eq(terms_len(ks(ty)), 2) && List.is_empty(&2,String, rm(ty)) &&
    String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) && List.is_empty(&2,KTerm, ks(kid(ty, 0))) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 2) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "None"), "None", 0) && j_pure_native_ctor(lookup(dc(owner), "Some"), "Some", 1)

@unsafe
def j_map_maybe_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Maybe"))
  j_map_maybe_some(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "None")), ks(ty)), ty, Nil{}, active, fuel))

@unsafe
def j_map_maybe_some(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Maybe")), "Some")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty, [kid(ty, 1)], active, fuel)

@unsafe
def j_map_closed_maybe(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_map_maybe_head(book, head) && j_pure_type(book, head)

@unsafe
def j_map_sigma_quantity(+ty: KTerm) -> U32:
  kc(U32, U32.is_eq(qt(kid(ty, 0)), 1) || U32.is_eq(qt(kid(ty, 1)), 1), u => 1, u => 2)

@unsafe
def j_map_sigma_kind(+ty: KTerm, +qa: U32, +qb: U32) -> Bool:
  +q = kid(ty, 0)
  String.eq(tg(ty), "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    kc(Bool, String.eq(tg(q), "Qua"), u => U32.is_eq(qt(q), kc(U32, U32.is_eq(qa, 1) || U32.is_eq(qb, 1), u => 1, u => 2)) && List.is_empty(&2,KTerm, ks(q)), u =>
      String.eq(tg(q), "Min") && U32.is_eq(terms_len(ks(q)), 2) && String.eq(tg(kid(q, 0)), "Qua") && U32.is_eq(qt(kid(q, 0)), qa) &&
      List.is_empty(&2,KTerm, ks(kid(q, 0))) && String.eq(tg(kid(q, 1)), "Qua") && U32.is_eq(qt(kid(q, 1)), qb) && List.is_empty(&2,KTerm, ks(kid(q, 1))))

@unsafe
def j_map_closed_field_quantity(+ty: KTerm, +left: U32) -> U32:
  # Canonical Tuple fields are affine binders; the type parameters affect kind.
  1

@unsafe
def j_map_native_binary(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) && Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) &&
    String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 1) && String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) &&
    kc(Bool, String.eq(dn(d), "U32.cmp"), u =>
      j_primitive_type(book, wnf(book, kid(ty, 0)), "U32") && j_primitive_type(book, wnf(book, kid(rest, 0)), "U32") && j_map_cmp_type(book, wnf(book, kid(rest, 1))), u =>
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") && j_primitive_type(book, wnf(book, kid(rest, 0)), "Nat") &&
      kc(Bool, String.eq(dn(d), "Nat.sub"), u => j_primitive_type(book, wnf(book, kid(rest, 1)), "Nat"), u =>
      kc(Bool, String.eq(dn(d), "Nat.is_lt"), u => j_primitive_type(book, wnf(book, kid(rest, 1)), "Bool"), u =>
      String.eq(dn(d), "Nat.divmod") && j_map_native_divmod_result(book, wnf(book, kid(rest, 1))))))

@unsafe
def j_map_native_divmod_result(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_pure_closed_sigma(book, ty) && j_primitive_type(book, wnf(book, kid(ty, 2)), "Nat") &&
    j_primitive_type(book, wnf(book, kid(kid(ty, 3), 0)), "Nat")

@unsafe
def j_instance_public_capture(+d: KDef) -> Bool:
  j_instance_source_definition(d) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) &&
    (String.eq(tg(j_strip(dv(d))), "Lam") || String.eq(tg(j_strip(dv(d))), "Mat"))

@unsafe
def j_instance_pure_capacity(+d: KDef, +ds: List<&2,KDef>) -> U32:
  kc(U32, String.eq(dk(index_first(dc(d))), "JErasedInstance") || j_instance_pure_rows(ds), u => 128, u => 32)

@unsafe
def j_instance_pure_rows(+ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{d, rest}: String.eq(dk(index_first(dc(d))), "JErasedInstance") || j_instance_pure_rows(rest)

# A source child reconstructed from inert projected fields remains private.
# Full graph/type proof independently validates constructor identity and fields.
@unsafe
def j_instance_child_fields(+env: List<&2,KTerm>, +ts: List<&2,KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{t, rest}: String.eq(tg(j_strip(t)), "Var") && String.eq(j_component_origin(env, ix(j_strip(t))), "@child") && j_instance_child_fields(env, rest)
