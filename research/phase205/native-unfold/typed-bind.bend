# Recover only closed monomorphic result domains. Unknown/dependent/function
# types remain unannotated and the ordinary whole-definition recheck decides.
@unsafe
def p205u_closed_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,(p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) &&
    String.eq(dk(lookup(book,nm(ty))),"ADT"),u => ty,u => atom("Absent"))
@unsafe
def p205u_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),u => p205u_closed_type(book,ty),u =>
    kc(KTerm,p98_tag_eq(ty,"All"),v => p205u_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))
@unsafe
def p205u_bind_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(t,"Ann"),u => p205u_closed_type(book,kid(t,1)),u =>
  kc(KTerm,core_literal(t),v => p205u_closed_type(book,ref(nm(t))),v =>
  kc(KTerm,p98_tag_eq(t,"Let"),w => p205u_let_type(book,ks(t)),w =>
  kc(KTerm,p98_tag_eq(t,"App"),x => p205u_call_type(book,j_call_spine(t,[])),x =>
  kc(KTerm,p98_tag_eq(t,"Ctr"),y => p205u_after_args(book,dt(j_find_ctor(book,nm(t))),terms_len(ks(t))),y =>
  kc(KTerm,p98_tag_eq(t,"Ref"),z => p205u_closed_type(book,dt(lookup(book,nm(t)))),z => atom("Absent")))))))
@unsafe
def p205u_call_type(+book: List<&2,KDef>, +call: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(call,"Call"),u => p205u_after_args(book,dt(lookup(book,nm(call))),terms_len(ks(call))),u => atom("Absent"))
@unsafe
def p205u_let_type(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Con{last,Nil{}}: p205u_bind_type(book,last)
    case Con{binding,rest}: p205u_let_type(book,rest)
    case _: atom("Absent")
@unsafe
def p205u_typed_arg(+arg: KTerm, +ty: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(ty,"Absent"),u => arg,u => kt("Ann","",0,0,[arg,ty]))
