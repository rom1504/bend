# A private product shell has one fixed constructor and live one-word fields.
# Query original syntax before erasure. Never unfold a global definition,
# normalize an opaque field, or invoke conversion. Unknown layouts stay boxed.
@unsafe
def nq_layout(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  nq_layout_head(book, nq_layout_type(book, ty))

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
        u => nt_choose(KTerm, nq_layout_fields(book, nq_layout_specialize(dt(ctr), ks(ty), 64), ty, da(ctr), Nil{}),
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
  nq_layout_field_head(book, nq_layout_type(book, tel), owner, left, seen)

@unsafe
def nq_layout_field_head(+book: List<&2, KDef>, +head: KTerm, +owner: KTerm, +left: U32, +seen: List<&2, U32>) -> Bool:
  nt_choose(Bool, U32.is_eq(left, 0),
    u => String.eq(tg(head), "ADT") && String.eq(nm(head), nm(owner)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && norm_exact(head, owner),
    u => String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && nq_layout_leaf(nq_layout_type(book, kid(head, 0)), owner, seen) && nq_layout_fields(book, kid(head, 1), owner, U32.sub(left, 1), Con{ix(head), seen}))

# A directly recursive outer shell remains boxed. Nested records/arrays stay
# opaque fields; this is not a recursive graph-layout analysis.
@unsafe
def nq_layout_leaf(+field: KTerm, +owner: KTerm, +seen: List<&2, U32>) -> Bool:
  Bool.not(String.eq(tg(field), "Absent") || String.eq(tg(field), "Ref")) && Bool.not(nq_layout_dep(field, seen)) && Bool.not(String.eq(tg(field), "ADT") && String.eq(nm(field), nm(owner)))

# A small syntax-only head query. Constant-lambda beta covers nondependent
# Sigma families; dependent or unknown applications decline without evaluation.
@unsafe
def nq_layout_reduce(+t: KTerm, +fuel: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(fuel, 0), u => atom("Absent"), u =>
    nt_choose(KTerm, String.eq(tg(t), "Ann"), v => nq_layout_reduce(kid(t, 0), U32.sub(fuel, 1)), v =>
      nt_choose(KTerm, String.eq(tg(t), "App"), w => nq_layout_reduce_app(nq_layout_reduce(kid(t, 0), U32.sub(fuel, 1)), U32.sub(fuel, 1)), w => t)))

@unsafe
def nq_layout_reduce_app(+head: KTerm, +fuel: U32) -> KTerm:
  nt_choose(KTerm, String.eq(tg(head), "Lam") && Bool.not(nc_occurs(kid(head, 0), ix(head))),
    u => nq_layout_reduce(kid(head, 0), fuel), u => atom("Absent"))

# A direct reference to a nullary ADT is a declaration lookup, not an unfolding
# of its value. All other references remain opaque, including unsafe aliases.
@unsafe
def nq_layout_type(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  nq_layout_type_head(book, nq_layout_reduce(ty, 64))

@unsafe
def nq_layout_type_head(+book: List<&2, KDef>, +head: KTerm) -> KTerm:
  +owner = lookup(book, nm(head))
  nt_choose(KTerm, String.eq(tg(head), "Ref") && String.eq(dk(owner), "ADT") && U32.is_eq(da(owner), 0),
    u => kt("ADT", nm(head), 0, 0, Nil{}), u => head)

# Ordinary subst invokes core_rebuild, which can beta-reduce applications.
# This substitution only rebuilds syntax and never evaluates a substituted term.
@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "Var"),
    u => nt_choose(KTerm, U32.is_eq(ix(t), id), v => value, v => t),
    u => k_rebuild(t, nm(t), ix(t), qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t)))

@unsafe
def nq_layout_subst_list(ts: List<&2, KTerm>, +id: U32, +value: KTerm) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nq_layout_subst(h, id, value), nq_layout_subst_list(rest, id, value)}

@unsafe
def nq_layout_specialize(+tel: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match args:
    case Nil{}: tel
    case Con{+arg, +rest}:
      nt_choose(KTerm, U32.is_eq(fuel, 0), u => atom("Absent"), u => nq_layout_specialize_head(nq_layout_reduce(tel, 64), arg, rest, U32.sub(fuel, 1)))

@unsafe
def nq_layout_specialize_head(+head: KTerm, +arg: KTerm, +rest: List<&2, KTerm>, +fuel: U32) -> KTerm:
  nt_choose(KTerm, String.eq(tg(head), "All"),
    u => nq_layout_specialize(nq_layout_subst(kid(head, 1), ix(head), arg), rest, fuel), u => atom("Absent"))
