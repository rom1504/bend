# A private product shell has one fixed constructor and live one-word fields.
# Query the checked, original typed book before erasure; never infer a shape
# from a constructor spelling or an erased matcher. Unknown layouts stay boxed.
@unsafe
def nq_layout(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  nq_layout_head(book, wnf(book, ty))

@unsafe
def nq_layout_head(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  +owner = lookup(book, nm(ty))
  nt_choose(KTerm, String.eq(tg(ty), "ADT") && String.eq(dk(owner), "ADT") && List.is_empty(&2, String, rm(ty)) && U32.is_eq(terms_len(ks(ty)), da(owner)) && U32.is_eq(dx(owner), 0) && (Bool.not(db(owner)) || String.eq(dn(owner), "Sigma")),
    u => nq_layout_single(book, ty, owner, dc(owner)), u => atom("Absent"))

@unsafe
def nq_layout_single(+book: List<&2, KDef>, +ty: KTerm, +owner: KDef, ctors: List<&2, KDef>) -> KTerm:
  match ctors:
    case Con{+ctr, Nil{}}:
      nt_choose(KTerm, String.eq(dk(ctr), "Ctr") && U32.is_gt(da(ctr), 0) && U32.is_le(da(ctr), 8) && U32.is_eq(dx(ctr), 0) && (Bool.not(db(owner)) || (String.eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u => nt_choose(KTerm, nq_layout_fields(book, j_specialize(book, dt(ctr), ks(ty)), ty, da(ctr), Nil{}),
          v => kt("NQShape", nt_choose(String, db(owner), w => dn(ctr), w => nc_ctor_encode(dn(ctr))), da(ctr), 0, Nil{}),
          v => atom("Absent")),
        u => atom("Absent"))
    case _: atom("Absent")

# Prior-field dependencies disqualify a shell; direct recursion is checked
# separately. A generic type, Array<T>, function or nested record is opaque;
# no recursive unboxing or field-representation theorem is assumed here.
@unsafe
def nq_layout_dep(+ty: KTerm, ids: List<&2, U32>) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{id, rest}: nc_occurs(ty, id) || nq_layout_dep(ty, rest)

@unsafe
def nq_layout_fields(+book: List<&2, KDef>, +tel: KTerm, +owner: KTerm, +left: U32, +seen: List<&2, U32>) -> Bool:
  nq_layout_field_head(book, wnf(book, tel), owner, left, seen)

@unsafe
def nq_layout_field_head(+book: List<&2, KDef>, +head: KTerm, +owner: KTerm, +left: U32, +seen: List<&2, U32>) -> Bool:
  nt_choose(Bool, U32.is_eq(left, 0),
    u => String.eq(tg(head), "ADT") && String.eq(nm(head), nm(owner)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && compare(book, head, owner, False{}),
    u => String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && nq_layout_leaf(wnf(book, kid(head, 0)), owner, seen) && nq_layout_fields(book, kid(head, 1), owner, U32.sub(left, 1), Con{ix(head), seen}))

# A directly recursive outer shell remains boxed. Nested records/arrays stay
# opaque fields; this is not a recursive graph-layout analysis.
@unsafe
def nq_layout_leaf(+field: KTerm, +owner: KTerm, +seen: List<&2, U32>) -> Bool:
  Bool.not(nq_layout_dep(field, seen)) && Bool.not(String.eq(tg(field), "ADT") && String.eq(nm(field), nm(owner)))
