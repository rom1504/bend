# Analysis-only source certificate prototype; no compiler selection hook.
# Checks the two positive branches only. Other branches remain exact fallback.
@unsafe
def p126lr_lam(+term: KTerm) -> Bool:
  String.eq(tg(term),"Lam") && U32.is_eq(terms_len(ks(term)),1) &&
    (U32.is_eq(qt(term),1) || U32.is_eq(qt(term),2))

@unsafe
def p126lr_ids(+a: U32, +b: U32, +c: U32, +d: U32) -> Bool:
  Bool.not(U32.is_eq(a,b) || U32.is_eq(a,c) || U32.is_eq(a,d) ||
    U32.is_eq(b,c) || U32.is_eq(b,d) || U32.is_eq(c,d))

@unsafe
def p126lr_result(+body: KTerm, +name: String, +a: U32, +b: U32, +c: U32, +d: U32) -> Bool:
  +left = j_strip(kid(body,0))
  +right = j_strip(kid(body,1))
  j_fusion_ctor(body,name,2) && j_fusion_ctor(left,name,2) && j_fusion_ctor(right,name,2) &&
    p126lr_ids(a,b,c,d) && j_fusion_var(kid(left,0),a) && j_fusion_var(kid(left,1),c) &&
    j_fusion_var(kid(right,0),b) && j_fusion_var(kid(right,1),d)

@unsafe
def p126lr_second(+first: KTerm, +second: KTerm, +name: String) -> Bool:
  +a = j_fusion_binder(first,0)
  +b = j_fusion_binder(first,1)
  +c = j_fusion_binder(kid(second,0),0)
  +d = j_fusion_binder(kid(second,0),1)
  String.eq(tg(second),"Mat") && String.eq(nm(second),name) && U32.is_eq(terms_len(ks(second)),2) &&
    p126lr_lam(a) && p126lr_lam(b) && p126lr_lam(c) && p126lr_lam(d) &&
    p126lr_result(j_fusion_after(kid(second,0),2),name,ix(a),ix(b),ix(c),ix(d))

@unsafe
def p126lr_equation(+d: KDef) -> Bool:
  +first = j_strip(dv(d))
  nt_choose(Bool,String.eq(tg(first),"Mat") && U32.is_eq(terms_len(ks(first)),2),
    u => p126lr_second(kid(first,0),j_fusion_after(kid(first,0),2),nm(first)),u => False{})

@unsafe
def p126lr_owner(+book: List<&2,KDef>, +owner: KTerm, +name: String) -> Bool:
  +o = lookup(book,nm(owner))
  +c = lookup(dc(o),name)
  +first = nq_layout_type(book,dt(c))
  +second = nq_layout_type(book,kid(first,1))
  String.eq(tg(owner),"ADT") && List.is_empty(&2,KTerm,ks(owner)) && List.is_empty(&2,String,rm(owner)) &&
    String.eq(dk(o),"ADT") && U32.is_eq(da(o),0) && U32.is_eq(dx(o),0) && Bool.not(db(o)) &&
    String.eq(dk(c),"Ctr") && U32.is_eq(da(c),2) && U32.is_eq(dx(c),0) &&
    String.eq(tg(first),"All") && U32.is_eq(qt(first),1) && String.eq(tg(second),"All") && U32.is_eq(qt(second),1) &&
    j_pure_same_closed(book,kid(first,0),owner,64) && j_pure_same_closed(book,kid(second,0),owner,64) &&
    j_pure_same_closed(book,kid(second,1),owner,64)

@unsafe
def p126lr_types(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +first = nq_layout_type(book,dt(d))
  +second = nq_layout_type(book,kid(first,1))
  +owner = nq_layout_type(book,kid(first,0))
  String.eq(tg(first),"All") && U32.is_eq(qt(first),1) && String.eq(tg(second),"All") && U32.is_eq(qt(second),1) &&
    j_pure_same_closed(book,kid(second,0),owner,64) && j_pure_same_closed(book,kid(second,1),owner,64) &&
    p126lr_owner(book,owner,nm(j_strip(dv(d))))

@unsafe
def p126lr_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  nt_choose(Bool,j_fusion_def(d,2),u => nt_choose(Bool,p121f_bounded(dv(d)) &&
    U32.is_le(U32.sub(513,nq_layout_remaining([dt(d)],513)),512),v =>
      nt_choose(Bool,p126lr_equation(d),w => p126lr_types(book,d),w => False{}),v => False{}),u => False{})

@unsafe
def p126lr_inspect(request: NR_Request, name: String) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: p126lr_admitted(book,lookup(book,name))
