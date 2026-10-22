# Bounded closed scalar evaluation. Only authenticated primitive definitions and
# closed, saturated ordinary helpers are interpreted; every actual is evaluated.
law p126s_eval:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_float(bits: U32) -> F32:
  match bits:
    case U32{word}: F32{word}

@unsafe
def p126s_kind(+book: List<&2,KDef>, +ty: KTerm) -> String:
  +head = wnf(book,ty)
  nt_choose(String,j_primitive_type(book,head,"F32"),u => "F32",u =>
    nt_choose(String,j_primitive_type(book,head,"U32"),u => "U32",u => ""))

@unsafe
def p126s_literal(+kind: String, value: Maybe<&2,U32>) -> KTerm:
  match value:
    case None{}: atom("Absent")
    case Some{+bits}:
      nt_choose(KTerm,String.eq(kind,"U32") || j_private_float_finite(bits),
        u => kl_make(kind,bits,""),u => atom("Absent"))

@unsafe
def p126s_atom(+term: KTerm, +kind: String) -> KTerm:
  nt_choose(KTerm,core_literal(term) && String.eq(nm(term),kind),
    u => p126s_literal(kind,Some{kl_number(term)}),u =>
    nt_choose(KTerm,String.eq(tg(term),"Ctr") && String.eq(nm(term),kind) && U32.is_eq(terms_len(ks(term)),1),
      u => p126s_literal(kind,j_word(j_strip(kid(term,0)),0,0)),u => atom("Absent")))

@unsafe
def p126s_result(+op: String, +a: U32, +b: U32) -> KTerm:
  +value = nt_choose(F32,String.eq(op,"U32.to_f32"),u => U32.to_f32(a),u =>
    nt_choose(F32,String.eq(op,"F32.add"),u => F32.add(p126s_float(a),p126s_float(b)),u =>
    nt_choose(F32,String.eq(op,"F32.sub"),u => F32.sub(p126s_float(a),p126s_float(b)),u =>
    nt_choose(F32,String.eq(op,"F32.mul"),u => F32.mul(p126s_float(a),p126s_float(b)),u => F32.div(p126s_float(a),p126s_float(b))))))
  p126s_literal("F32",Some{F32.bits(value)})

@unsafe
def p126s_primitive_second(+op: String, +first: KTerm, +second: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(second),u => p126s_result(op,kl_number(first),kl_number(second)),u => atom("Absent"))

@unsafe
def p126s_primitive_first(+book: List<&2,KDef>, +call: KTerm, +fuel: U32, +first: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(first),u =>
    nt_choose(KTerm,String.eq(nm(call),"U32.to_f32"),u => p126s_result(nm(call),kl_number(first),0),u =>
      p126s_primitive_second(nm(call),first,p126s_eval(book,kid(call,1),"F32",fuel))),u => atom("Absent"))

law p126s_helper_arg:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +ty: KTerm
  for +arg: KTerm
  for +rest: List<&2,KTerm>
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_helper(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +kind: String, +fuel: U32) -> KTerm:
  match args:
    case Nil{}:
      nt_choose(KTerm,String.eq(p126s_kind(book,ty),kind),u => p126s_eval(book,body,kind,fuel),u => atom("Absent"))
    case Con{arg,rest}: p126s_helper_arg(book,j_strip(body),wnf(book,ty),arg,rest,kind,fuel)

@unsafe
def p126s_helper_value(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +rest: List<&2,KTerm>, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u =>
    p126s_helper(book,subst(kid(body,0),ix(body),value),subst(kid(ty,1),ix(ty),value),rest,kind,fuel),u => atom("Absent"))

@unsafe
def p126s_helper_arg(book,body,ty,arg,rest,kind,fuel):
  +input = p126s_kind(book,kid(ty,0))
  nt_choose(KTerm,String.eq(tg(body),"Lam") && U32.is_eq(terms_len(ks(body)),1) && String.eq(j_l_name(body),"") &&
    String.eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) && Bool.not(String.is_empty(input)),u =>
      p126s_helper_value(book,body,ty,rest,kind,fuel,p126s_eval(book,arg,input,fuel)),u => atom("Absent"))

@unsafe
def p126s_call(+book: List<&2,KDef>, +call: KTerm, +kind: String, +fuel: U32) -> KTerm:
  +name = nm(call)
  +d = lookup(book,name)
  nt_choose(KTerm,String.eq(kind,"F32") && String.contains("|U32.to_f32|F32.add|F32.sub|F32.mul|F32.div|","|" ++ name ++ "|") && j_primitive_call(book,call),
    u => p126s_primitive_first(book,call,fuel,p126s_eval(book,kid(call,0),j_primitive_input(name,0),fuel)),u =>
    nt_choose(KTerm,String.eq(dk(d),"Def") && Bool.not(db(d) || nc_foreign(d)) && U32.is_eq(dx(d),0) &&
      U32.is_gt(da(d),0) && U32.is_le(da(d),2) && U32.is_eq(da(d),terms_len(ks(call))) && j_u32_bounded([dv(d)],64),
      u => p126s_helper(book,dv(d),dt(d),ks(call),kind,fuel),u => atom("Absent")))

@unsafe
def p126s_eval_spine(+book: List<&2,KDef>, +kind: String, +fuel: U32, +spine: KTerm) -> KTerm:
  nt_choose(KTerm,String.eq(tg(spine),"Call"),u => p126s_call(book,spine,kind,fuel),u => atom("Absent"))

@unsafe
def p126s_eval_next(+book: List<&2,KDef>, +term: KTerm, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u => value,u => p126s_eval_spine(book,kind,fuel,j_call_spine(term,[])))

@unsafe
def p126s_eval(book,term,kind,fuel):
  nt_choose(KTerm,U32.is_gt(fuel,0),u =>
    p126s_eval_next(book,j_strip(term),kind,U32.sub(fuel,1),p126s_atom(j_strip(term),kind)),u => atom("Absent"))

law p126s_rows:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +ty: KTerm
  for +kind: String
  for +left: U32
  Maybe<&2,List<&2,U32>>

@unsafe
def p126s_cons(first: KTerm, rest: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match rest:
    case None{}: None{}
    case Some{values}: Some{Con{kl_number(first),values}}

@unsafe
def p126s_row_first(+book: List<&2,KDef>, +term: KTerm, +ty: KTerm, +kind: String, +left: U32, +first: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,core_literal(first),u =>
    p126s_cons(first,p126s_rows(book,kid(j_strip(kid(term,1)),0),j_arm_type(book,ty,"Succ"),kind,U32.sub(left,1))),u => None{})

@unsafe
def p126s_last(+value: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,core_literal(value),u => Some{[kl_number(value)]},u => None{})

@unsafe
def p126s_rows_on(+book: List<&2,KDef>, +term: KTerm, +ty: KTerm, +kind: String, +left: U32) -> Maybe<&2,List<&2,U32>>:
  +rest = j_strip(kid(term,1))
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(term),"Lam") && U32.is_eq(terms_len(ks(term)),1) && String.eq(j_l_name(term),""),
    u => p126s_last(p126s_eval(book,kid(term,0),kind,8)),u =>
    nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(term),"Mat") && String.eq(nm(term),"Zero") && U32.is_eq(terms_len(ks(term)),2) &&
      String.eq(tg(rest),"Mat") && String.eq(nm(rest),"Succ") && U32.is_eq(terms_len(ks(rest)),2) &&
      String.eq(tg(j_strip(kid(rest,1))),"Efq") && U32.is_eq(terms_len(ks(j_strip(kid(rest,1)))),0),
      u => p126s_row_first(book,term,ty,kind,left,p126s_eval(book,kid(term,0),kind,8)),u => None{}))

@unsafe
def p126s_rows(book,term,ty,kind,left):
  +head = wnf(book,ty)
  nt_choose(Maybe<&2,List<&2,U32>>,U32.is_gt(left,0) && String.eq(tg(head),"All") && Bool.not(U32.is_eq(qt(head),0)) &&
    j_primitive_type(book,wnf(book,kid(head,0)),"Nat"),u => p126s_rows_on(book,j_strip(term),head,kind,left),u => None{})

@unsafe
def p126s_plan_result(+book: List<&2,KDef>, +d: KDef, +ty: KTerm, +kind: String) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,Bool.not(String.is_empty(kind)) && j_u32_bounded([dv(d)],4096),
    u => p126s_rows(book,dv(d),ty,kind,64),u => None{})

@unsafe
def p126s_plan_type(+book: List<&2,KDef>, +d: KDef, +ty: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) &&
    j_primitive_type(book,wnf(book,kid(ty,0)),"Nat"),
    u => p126s_plan_result(book,d,ty,p126s_kind(book,kid(ty,1))),u => None{})

@unsafe
def p126s_plan(+book: List<&2,KDef>, +d: KDef) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,String.eq(dk(d),"Def") && U32.is_eq(da(d),1) && U32.is_eq(dx(d),0) &&
    Bool.not(db(d) || nc_foreign(d)) && String.eq(tg(j_strip(dv(d))),"Mat"),
    u => p126s_plan_type(book,d,wnf(book,dt(d))),u => None{})
