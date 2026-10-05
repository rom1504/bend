# Closed private data shapes. This is not public argument admission: callers
# must prove scalar roots and a closed first-order graph before using these.
# A shared residual budget bounds all record-field visits, including siblings.

@unsafe
def j_region_local_ok(+result: Maybe<&2,U32>) -> Bool:
  match result:
    case Some{fuel}: True{}
    case None{}: False{}

@unsafe
def j_region_local_array(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_array_effect_array(book, ty)

@unsafe
def j_region_local_sigma(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Sigma") &&
    U32.is_eq(terms_len(ks(ty)), 4) && List.is_empty(&2, String, rm(ty)), u =>
    j_u32_native_ctor(book, "Sigma", "Tuple") && U32.is_eq(da(lookup(book, "Sigma")), 4), u => False{})

# After local-type admission, only flat scalar public results need record shells.
# Normalize aliases here so construction and elimination agree on the layout.
@unsafe
def j_region_local_vector(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, j_region_local_sigma(book, head), u => True{}, u =>
    String.eq(dk(j_region_local_ctor_head(book, head)), "Ctr") && Bool.not(j_region_record(book, head)))

# Return only an eligible constructor header. Field types are checked by
# j_region_local_type, before a caller may lower construction or elimination.
@unsafe
def j_region_local_ctor(+book: List<&2,KDef>, +ty: KTerm) -> KDef:
  j_region_local_ctor_head(book, wnf(book, ty))

@unsafe
def j_region_local_ctor_head(+book: List<&2,KDef>, +ty: KTerm) -> KDef:
  +owner = lookup(book, nm(ty))
  +kind = wnf(book, dt(owner))
  kc(KDef, j_region_local_sigma(book, ty),
    u => j_region_local_one(dc(owner), True{}), u =>
    kc(KDef, String.eq(tg(ty), "ADT") && U32.is_eq(terms_len(ks(ty)), 0) &&
      List.is_empty(&2, String, rm(ty)) && String.eq(dk(owner), "ADT") &&
      Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
      String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
      String.eq(tg(kid(kind, 0)), "Qua") &&
      (U32.is_eq(qt(kid(kind, 0)), 1) || U32.is_eq(qt(kid(kind, 0)), 2)),
      u => j_region_local_one(dc(owner), False{}), u => missing()))

@unsafe
def j_region_local_one(+ctors: List<&2,KDef>, +native: Bool) -> KDef:
  match ctors:
    case Con{c, Nil{}}:
      kc(KDef, String.eq(dk(c), "Ctr") && U32.is_eq(dx(c), 0) && U32.is_le(da(c), 32) &&
        kc(Bool, native, u => db(c) && String.eq(dn(c), "Tuple") && U32.is_eq(da(c), 2),
          u => Bool.not(db(c))), u => c, u => missing())
    case other: missing()

@unsafe
def j_region_local_fields(+book: List<&2,KDef>, +ty: KTerm) -> KTerm:
  +head = wnf(book, ty)
  +c = j_region_local_ctor_head(book, head)
  kc(KTerm, String.eq(dk(c), "Ctr"),
    u => j_specialize(book, dt(c), ks(head)), u => atom("Absent"))

@unsafe
def j_region_local_field_count(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  da(j_region_local_ctor(book, ty))

@unsafe
def j_region_local_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_region_local_ok(j_region_local_check(book, ty, Nil{}, 256))

@unsafe
def j_region_local_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_region_local_check_head(book, wnf(book, ty), active, U32.sub(fuel, 1)), u => None{})

@unsafe
def j_region_local_check_head(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, j_region_scalar(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, j_region_local_array(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, j_fold_type(book, ty) || j_list_ground_type(book, ty) || j_pure_closed_map(book, ty) || j_map_closed_maybe(book, ty) || j_map_cmp_type(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, Bool.not(has_name(active, nm(ty))), u =>
      j_region_local_record_check(book, ty, j_region_local_ctor_head(book, ty),
        kc(List<&2,String>, j_region_local_sigma(book, ty), u => active, u => Con{nm(ty), active}), fuel), u => None{}))))

@unsafe
def j_region_local_record_check(+book: List<&2,KDef>, +ty: KTerm, +c: KDef, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, String.eq(dk(c), "Ctr"), u =>
    j_region_local_fields_check(book, j_specialize(book, dt(c), ks(ty)), nm(ty), da(c), active, fuel), u => None{})

@unsafe
def j_region_local_fields_check(+book: List<&2,KDef>, +tel: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_region_local_fields_head(book, wnf(book, tel), owner, left, active, U32.sub(fuel, 1)), u => None{})

@unsafe
def j_region_local_fields_head(+book: List<&2,KDef>, +tel: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, String.eq(tg(tel), "ADT") && String.eq(nm(tel), owner) &&
      List.is_empty(&2, String, rm(tel)), u => Some{fuel}, u => None{}), u =>
    kc(Maybe<&2,U32>, String.eq(tg(tel), "All") && Bool.not(U32.is_eq(qt(tel), 0)), u =>
      j_region_local_fields_next(book, kid(tel, 1), owner, U32.sub(left, 1), active,
        j_region_local_check(book, kid(tel, 0), active, fuel)), u => None{}))

@unsafe
def j_region_local_fields_next(+book: List<&2,KDef>, +tel: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case Some{fuel}: j_region_local_fields_check(book, tel, owner, left, active, fuel)
    case None{}: None{}

# Erased parameters are not admitted for ordinary private helpers. Only the
# explicitly validated native Array operations have an erased element slot.
@unsafe
def j_region_local_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  kc(Bool, U32.is_le(left, 32), u => j_region_local_signature_head(book, wnf(book, ty), left), u => False{})

@unsafe
def j_region_local_signature_head(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  kc(Bool, U32.is_eq(left, 0), u => j_region_local_type(book, ty), u =>
    kc(Bool, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) && j_region_local_type(book, kid(ty, 0)),
      u => j_region_local_signature(book, kid(ty, 1), U32.sub(left, 1)), u => False{}))

@unsafe
def j_region_local_native(+book: List<&2,KDef>, +spine: KTerm) -> Bool:
  j_array_effect_native(book, spine)

@unsafe
def j_region_local_pair(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_array_effect_pair(book, ty)

