# Checked, closed constructor identity. This is not a mutable cell-reuse rule.
# All rejection paths retain the original matched-constructor lowering.
@unsafe
def p126ci_has(ids: List<&2,U32>, +id: U32) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{head,rest}: U32.is_eq(head,id) || p126ci_has(rest,id)

@unsafe
def p126ci_plain(+term: KTerm) -> Bool:
  String.eq(tg(term),"Var") && List.is_empty(&2,KTerm,ks(term)) && List.is_empty(&2,String,rm(term)) && U32.is_eq(qt(term),0)

@unsafe
def p126ci_fields(fields: List<&2,KTerm>, ids: List<&2,U32>) -> Bool:
  match fields ids:
    case Nil{} Nil{}: True{}
    case Con{+field,rest} Con{+id,more}:
      p126ci_plain(field) && U32.is_eq(ix(field),id) && p126ci_fields(rest,more)
    case _ _: False{}

# No beta evaluation, effects or observations: exact live lambdas followed by
# the exact original constructor. Reject binder reuse and erased/bang binders.
@unsafe
def p126ci_lambdas(+body: KTerm, +name: String, +left: U32, +ids: List<&2,U32>) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),
    u => String.eq(tg(body),"Ctr") && String.eq(nm(body),name) &&
      List.is_empty(&2,String,rm(body)) && p126ci_fields(ks(body),nt_reverse(U32,ids,[])),
    u => nt_choose(Bool,String.eq(tg(body),"Lam") && U32.is_eq(terms_len(ks(body)),1) &&
      (U32.is_eq(qt(body),1) || U32.is_eq(qt(body),2)) && List.is_empty(&2,String,rm(body)),
      v => nt_choose(Bool,Bool.not(p126ci_has(ids,ix(body))),
        w => p126ci_lambdas(kid(body,0),name,U32.sub(left,1),Con{ix(body),ids}),w => False{}),
      v => False{}))

@unsafe
def p126ci_result(+book: List<&2,KDef>, +ctor: KDef, +head: KTerm, +seen: List<&2,U32>) -> Bool:
  nt_choose(Bool,String.eq(tg(head),"ADT") && List.is_empty(&2,KTerm,ks(head)) &&
    List.is_empty(&2,String,rm(head)) && Bool.not(nq_layout_dep(head,seen)),
    u => p126ci_owner(book,ctor,lookup(book,nm(head))),u => False{})

@unsafe
def p126ci_owner(+book: List<&2,KDef>, +ctor: KDef, +owner: KDef) -> Bool:
  +member = lookup(dc(owner),dn(ctor))
  String.eq(dk(owner),"ADT") && U32.is_eq(da(owner),0) && U32.is_eq(dx(owner),0) && Bool.not(db(owner)) &&
    String.eq(dk(member),"Ctr") && U32.is_eq(da(member),da(ctor)) && U32.is_eq(dx(member),0) && norm_exact(dt(member),dt(ctor))

# Normalize only declared telescope/type aliases through the existing bounded
# layout reader. No value evaluation or general expression normalization.
@unsafe
def p126ci_telescope(+book: List<&2,KDef>, +ctor: KDef, +ty: KTerm, +left: U32, +seen: List<&2,U32>) -> Bool:
  +head = nq_layout_type(book,ty)
  nt_choose(Bool,U32.is_eq(left,0),u => p126ci_result(book,ctor,head,seen),
    u => nt_choose(Bool,String.eq(tg(head),"All") && U32.is_eq(terms_len(ks(head)),2) &&
      (U32.is_eq(qt(head),1) || U32.is_eq(qt(head),2)) && List.is_empty(&2,String,rm(head)),
      v => nt_choose(Bool,Bool.not(nq_layout_dep(nq_layout_type(book,kid(head,0)),seen)) && Bool.not(p126ci_has(seen,ix(head))),
        w => p126ci_telescope(book,ctor,kid(head,1),U32.sub(left,1),Con{ix(head),seen}),w => False{}),
      v => False{}))

@unsafe
def p126ci_declared(+book: List<&2,KDef>, +mat: KTerm, +ctor: KDef) -> Bool:
  nt_choose(Bool,String.eq(dk(ctor),"Ctr") && U32.is_eq(dx(ctor),0) &&
    U32.is_ge(da(ctor),2) && U32.is_le(da(ctor),8) && U32.is_eq(ix(mat),U32.inc(da(ctor))) &&
    String.eq(nc_ctor_identity(book,dn(ctor)),nm(mat)),
    u => nt_choose(Bool,U32.is_le(nq_layout_size([dt(ctor)],513),512),
      v => nt_choose(Bool,p126ci_telescope(book,ctor,dt(ctor),da(ctor),[]),
        w => p126ci_lambdas(kid(mat,0),nm(mat),da(ctor),[]),w => False{}),v => False{}),
    u => False{})

@unsafe
def p126ci_match(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  nt_choose(Bool,String.eq(tg(t),"NMatch") && U32.is_eq(terms_len(ks(t)),2) && p126ci_plain(kid(t,1)),
    u => p126ci_match_head(book,kid(t,0)),u => False{})

@unsafe
def p126ci_match_head(+book: List<&2,KDef>, +mat: KTerm) -> Bool:
  nt_choose(Bool,String.eq(tg(mat),"Mat") && U32.is_eq(terms_len(ks(mat)),2) &&
    U32.is_ge(ix(mat),3) && U32.is_le(ix(mat),9) && List.is_empty(&2,String,rm(mat)) &&
    Bool.not(nw_applicable(mat) || nb_contains(["Emit","Halt","Succ","Zero","Chr","U32","F32","True","False","ALeaf","ANode"],nm(mat))),
    u => nt_choose(Bool,p126ci_lambdas(kid(mat,0),nm(mat),U32.sub(ix(mat),1),[]),
      v => p126ci_declared(book,mat,nc_find_ctor(book,nc_ctor_display(nm(mat)))),v => False{}),u => False{})
