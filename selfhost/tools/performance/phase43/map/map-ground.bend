# Exact native Map<&2,scalar> specialization. Constructor rows are validated;
# owner names alone never grant shape/ownership or public argument permission.
@unsafe
def j_pure_map_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Map")
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Map") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && j_region_scalar(book, kid(ty, 1)) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "MTip"), "MTip", 0) &&
    j_pure_native_ctor(lookup(dc(owner), "MLeaf"), "MLeaf", 2) &&
    j_pure_native_ctor(lookup(dc(owner), "MNode"), "MNode", 3)

@unsafe
def j_pure_closed_map(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  j_pure_map_head(book, head) && j_pure_type(book, head)

@unsafe
def j_pure_map_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_map_fields_head(book, wnf(book, tel), expected, fields, active, U32.sub(fuel, 1)), u => None{})

@unsafe
def j_pure_map_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match fields:
    case Nil{}:
      kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{})
    case Con{h, rest}:
      kc(Maybe<&2,U32>, String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) &&
        j_pure_same_closed(book, kid(tel, 0), h, 64), u =>
        kc(Maybe<&2,U32>, j_pure_same_closed(book, h, expected, 64), u =>
          j_pure_map_fields(book, kid(tel, 1), expected, rest, active, fuel), u =>
          j_pure_map_fields_next(book, kid(tel, 1), expected, rest, active,
            j_pure_type_check(book, h, active, fuel))), u => None{})

@unsafe
def j_pure_map_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}: j_pure_map_fields(book, tel, expected, fields, active, fuel)

@unsafe
def j_pure_map_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Map"))
  j_pure_map_leaf(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "MTip")), ks(ty)), ty, Nil{}, active, fuel))

@unsafe
def j_pure_map_leaf(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MLeaf")
      j_pure_map_node(book, ty, active,
        j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
          [kt("ADT", "String", 0, 0, Nil{}), kid(ty, 1)], active, fuel))

@unsafe
def j_pure_map_node(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MNode")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
        [kt("ADT", "Nat", 0, 0, Nil{}), ty, ty], active, fuel)
