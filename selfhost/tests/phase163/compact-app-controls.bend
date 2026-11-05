# Private compiler-data controls. No host ABI or wire-format changes.
# Structural equality keeps the physical term/child variants. Observation erases
# only KApp storage into the exact legacy App fields, recursively.

@unsafe
def p163t_strings(a: List<&2,String>, b: List<&2,String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: String.eq(x,y) && p163t_strings(xs,ys)
    case _ _: False{}

@unsafe
def p163t_terms(a: List<&2,KTerm>, b: List<&2,KTerm>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p163t_equal(x,y) && p163t_terms(xs,ys)
    case _ _: False{}

@unsafe
def p163t_children_equal(a: KChildren, b: KChildren) -> Bool:
  match a b:
    case KCZero{} KCZero{}: True{}
    case KCOne{x} KCOne{y}: p163t_equal(x,y)
    case KCTwo{a0,a1} KCTwo{b0,b1}: p163t_equal(a0,b0) && p163t_equal(a1,b1)
    case KCMany{a0,a1,a2,ar} KCMany{b0,b1,b2,br}:
      p163t_equal(a0,b0) && p163t_equal(a1,b1) && p163t_equal(a2,b2) && p163t_terms(ar,br)
    case _ _: False{}

@unsafe
def p163t_equal(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{at,an,ai,aq,ak,ar,ab,ae} KTerm{bt,bn,bi,bq,bk,br,bb,be}:
      String.eq(at,bt) && String.eq(an,bn) && U32.is_eq(ai,bi) && U32.is_eq(aq,bq) &&
      p163t_terms(ak,bk) && p163t_strings(ar,br) && U32.is_eq(ab,bb) && U32.is_eq(ae,be)
    case KLambda{an,ai,aq,ak,ar,ab,ae,ap} KLambda{bn,bi,bq,bk,br,bb,be,bp}:
      String.eq(an,bn) && U32.is_eq(ai,bi) && U32.is_eq(aq,bq) && p163t_terms(ak,bk) &&
      p163t_strings(ar,br) && U32.is_eq(ab,bb) && U32.is_eq(ae,be) && Bool.not(Bool.xor(ap,bp))
    case KLiteral{ak,an,at,ab,ae} KLiteral{bk,bn,bt,bb,be}:
      String.eq(ak,bk) && U32.is_eq(an,bn) && String.eq(at,bt) && U32.is_eq(ab,bb) && U32.is_eq(ae,be)
    case KApp{aq,ac,ab,ae} KApp{bq,bc,bb,be}:
      U32.is_eq(aq,bq) && p163t_children_equal(ac,bc) && U32.is_eq(ab,bb) && U32.is_eq(ae,be)
    case _ _: False{}

@unsafe
def p163t_kids(c: KChildren) -> List<&2,KTerm>:
  match c:
    case KCZero{}: []
    case KCOne{a}: [a]
    case KCTwo{a,b}: [a,b]
    case KCMany{a,b,c,rest}: Con{a,Con{b,Con{c,rest}}}

@unsafe
def p163t_pack(xs: List<&2,KTerm>) -> KChildren:
  match xs:
    case Nil{}: KCZero{}
    case Con{a,Nil{}}: KCOne{a}
    case Con{a,Con{b,Nil{}}}: KCTwo{a,b}
    case Con{a,Con{b,Con{c,rest}}}: KCMany{a,b,c,rest}

@unsafe
def p163t_observe_terms(xs: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{p163t_observe(x),p163t_observe_terms(rest)}

@unsafe
def p163t_observe(t: KTerm) -> KTerm:
  match t:
    case KTerm{+tag,name,id,q,kids,removed,begin,end}:
      KTerm{tag,name,id,q,p163t_observe_terms(kids),removed,begin,end}
    case KLambda{name,id,q,kids,removed,begin,end,present}:
      KLambda{name,id,q,p163t_observe_terms(kids),removed,begin,end,present}
    case KLiteral{kind,number,text,begin,end}: KLiteral{kind,number,text,begin,end}
    case KApp{q,children,begin,end}:
      KTerm{"App","",0,q,p163t_observe_terms(p163t_kids(children)),[],begin,end}

@unsafe
def p163t_same(a: KTerm, b: KTerm) -> Bool:
  p163t_equal(p163t_observe(a),p163t_observe(b))

@unsafe
def p163t_at(xs: List<&2,KTerm>, +n: U32) -> KTerm:
  match xs:
    case Nil{}: KTerm{"Absent","",0,0,[],[],0,0}
    case Con{head,tail}: kc(KTerm,U32.is_eq(n,0),u => head,u => p163t_at(tail,U32.sub(n,1)))

@unsafe
def p163t_fields(+t: KTerm, +tag: String, name: String, id: U32, q: U32,
  +kids: List<&2,KTerm>, removed: List<&2,String>, begin: U32, end: U32,
  present: Bool, literal: Bool, number: U32, text: String) -> Bool:
  String.eq(tg(t),tag) && String.eq(nm(t),name) && U32.is_eq(ix(t),id) && U32.is_eq(qt(t),q) &&
  p163t_terms(ks(t),kids) && p163t_strings(rm(t),removed) && U32.is_eq(kb(t),begin) && U32.is_eq(ke(t),end) &&
  Bool.not(Bool.xor(k_quantity_present(t),present)) && Bool.not(Bool.xor(core_literal(t),literal)) &&
  U32.is_eq(kl_number(t),number) && String.eq(kl_text(t),text) && p98_tag_eq(t,tag) &&
  Bool.not(p98_tag_eq(t,"NotARealTermTag")) &&
  p163t_equal(kid(t,0),p163t_at(kids,0)) && p163t_equal(kid(t,1),p163t_at(kids,1)) &&
  p163t_equal(kid(t,2),p163t_at(kids,2)) && p163t_equal(kid(t,3),p163t_at(kids,3)) &&
  p163t_equal(kid(t,4),p163t_at(kids,4)) && p163t_equal(kid(t,4294967295),p163t_at(kids,4294967295))

@unsafe
def p163t_api(+t: KTerm) -> Bool:
  match t:
    case KTerm{+tag,name,id,q,kids,removed,begin,end}:
      p163t_fields(t,tag,name,id,q,kids,removed,begin,end,String.eq(tag,"Lam"),False{},0,"")
    case KLambda{name,id,q,kids,removed,begin,end,present}:
      p163t_fields(t,"Lam",name,id,q,kids,removed,begin,end,present,False{},0,"")
    case KLiteral{kind,number,text,begin,end}:
      p163t_fields(t,"Lit",kind,0,0,[],[],begin,end,False{},True{},number,text)
    case KApp{q,children,begin,end}:
      p163t_fields(t,"App","",0,q,p163t_kids(children),[],begin,end,False{},False{},0,"")

@unsafe
def p163t_a() -> KTerm:
  KTerm{"Ref","left",4294967295,3,[],["removed"],1,2}

@unsafe
def p163t_b() -> KTerm:
  KLiteral{"U32",4294967295,"",3,4}

@unsafe
def p163t_c() -> KTerm:
  KLambda{"x",17,2,[KTerm{"Var","x",17,1,[],[],7,8}],["outer"],5,9,False{}}

@unsafe
def p163t_sets() -> List<&2,List<&2,KTerm>>:
  +a = p163t_a()
  +b = p163t_b()
  +c = p163t_c()
  [[],[a],[a,b],[a,b,c],[a,b,c,KApp{1,KCTwo{b,a},10,20}]]

@unsafe
def p163t_last_writes(+t: KTerm, +first: List<&2,KTerm>, lasts: List<&2,List<&2,KTerm>>) -> Bool:
  match lasts:
    case Nil{}: True{}
    case Con{+last,rest}:
      p163t_equal(k_with_children(k_with_children(t,first),last),k_with_children(t,last)) &&
      p163t_last_writes(t,first,rest)

@unsafe
def p163t_all_writes(+t: KTerm, firsts: List<&2,List<&2,KTerm>>) -> Bool:
  match firsts:
    case Nil{}: True{}
    case Con{first,rest}: p163t_last_writes(t,first,p163t_sets()) && p163t_all_writes(t,rest)

@unsafe
def p163t_rebuild_law(+t: KTerm, +kids: List<&2,KTerm>) -> Bool:
  p163t_equal(k_with_children(t,kids),k_rebuild(t,nm(t),ix(t),qt(t),kids,rm(t),kb(t),ke(t)))

@unsafe
def p163t_update_laws(+t: KTerm, lists: List<&2,List<&2,KTerm>>) -> Bool:
  match lists:
    case Nil{}: True{}
    case Con{+kids,rest}:
      p163t_rebuild_law(t,kids) &&
      p163t_equal(k_with_span(k_with_children(t,kids),31,37),k_with_children(k_with_span(t,31,37),kids)) &&
      p163t_update_laws(t,rest)

@unsafe
def p163t_laws(+t: KTerm) -> Bool:
  p163t_equal(k_with_children(t,ks(t)),t) && p163t_equal(k_with_span(t,kb(t),ke(t)),t) &&
  p163t_equal(k_rebuild(t,nm(t),ix(t),qt(t),ks(t),rm(t),kb(t),ke(t)),t) &&
  p163t_equal(k_with_span(k_with_span(t,11,19),23,29),k_with_span(t,23,29)) &&
  U32.is_eq(kb(k_with_span(t,31,37)),31) && U32.is_eq(ke(k_with_span(t,31,37)),37) &&
  p163t_all_writes(t,p163t_sets()) && p163t_update_laws(t,p163t_sets())

@unsafe
def p163t_case(+q: U32, +kids: List<&2,KTerm>, +begin: U32, +end: U32) -> Bool:
  +compact : KTerm = KApp{q,p163t_pack(kids),begin,end}
  +legacy : KTerm = KTerm{"App","",0,q,kids,[],begin,end}
  +replacement : KTerm = KLiteral{"String",0,"replacement",41,52}
  p163t_children_equal(p163c_children(kids),p163t_pack(kids)) &&
  p163t_terms(p163c_list(p163t_pack(kids)),kids) && p163t_api(compact) && p163t_api(legacy) &&
  p163t_same(compact,legacy) && Bool.not(p163t_equal(compact,legacy)) &&
  p163t_laws(compact) && p163t_laws(legacy) &&
  p163t_same(subst(compact,17,replacement),subst(legacy,17,replacement)) &&
  p163t_same(core_beta(compact),core_beta(legacy)) &&
  Bool.not(Bool.xor(core_subst_stable(compact),core_subst_stable(legacy)))

@unsafe
def p163t_shape_cases(+q: U32, shapes: List<&2,List<&2,KTerm>>) -> Bool:
  match shapes:
    case Nil{}: True{}
    case Con{kids,rest}: p163t_case(q,kids,11,29) && p163t_shape_cases(q,rest)

@unsafe
def p163t_legacy() -> KTerm:
  KTerm{"App","noncanonical",4294967295,4294967295,[p163t_a(),p163t_b(),p163t_c()],["gone","again"],61,79}

@unsafe
def p163t_legacy_kept() -> Bool:
  +t = p163t_legacy()
  +kids : List<&2,KTerm> = [p163t_b(),p163t_a()]
  p163t_api(t) && p163t_laws(t) &&
  p163t_equal(k_with_children(t,kids),KTerm{"App","noncanonical",4294967295,4294967295,kids,["gone","again"],61,79}) &&
  p163t_equal(k_with_span(t,83,97),KTerm{"App","noncanonical",4294967295,4294967295,[p163t_a(),p163t_b(),p163t_c()],["gone","again"],83,97})

@unsafe
def p163t_changed_metadata() -> Bool:
  +t : KTerm = KApp{1,KCTwo{p163t_a(),p163t_b()},11,29}
  +kids : List<&2,KTerm> = [p163t_c()]
  p163t_equal(k_rebuild(t,"changed",7,3,kids,["removed"],31,43),
    KTerm{"App","changed",7,3,kids,["removed"],31,43})

@unsafe
def p163t_substitution() -> Bool:
  +x : KTerm = KTerm{"Var","f",17,1,[],[],3,7}
  +a : KTerm = KLiteral{"U32",7,"",11,13}
  +f : KTerm = KTerm{"Ref","g",0,0,[],[],17,19}
  +t : KTerm = KApp{1,KCTwo{x,a},23,31}
  p163t_same(subst(t,17,f),KTerm{"App","",0,0,[f,a],[],23,31}) &&
  p163t_equal(subst(KTerm{"Var","f",17,0,[a],["kept"],3,7},17,f),f) &&
  p163t_equal(core_force(KTerm{"Var","cell",9,0,[a],[],1,2}),a)

@unsafe
def p163t_beta() -> Bool:
  +a : KTerm = KLiteral{"String",0,"argument",19,31}
  +lam : KTerm = KLambda{"x",17,1,[KTerm{"Var","x",17,0,[],[],7,8}],["outer"],3,11,True{}}
  p163t_equal(core_beta(KApp{1,KCTwo{lam,a},41,53}),a) &&
  p163t_equal(subst(KApp{1,KCTwo{lam,a},41,53},99,p163t_b()),a)

@unsafe
def p163t_stability() -> Bool:
  +f : KTerm = KTerm{"Ref","f",0,0,[],[],0,0}
  +x : KTerm = KLiteral{"U32",1,"",0,0}
  core_subst_stable(KApp{0,KCTwo{f,x},1,2}) &&
  Bool.not(core_subst_stable(KApp{1,KCTwo{f,x},1,2})) &&
  Bool.not(core_subst_stable(KApp{0,KCZero{},1,2})) &&
  Bool.not(core_subst_stable(KApp{0,KCOne{f},1,2})) &&
  Bool.not(core_subst_stable(KApp{0,KCMany{f,x,x,[]},1,2})) &&
  Bool.not(core_subst_stable(KApp{0,KCTwo{p163t_c(),x},1,2}))

@unsafe
def p163t_producers() -> Bool:
  +f = p163t_a()
  +x = p163t_b()
  +y = p163t_c()
  +unlocated : KTerm = KLiteral{"U32",7,"",0,0}
  p163t_equal(app(f,x),KApp{0,KCTwo{f,x},0,0}) &&
  p163t_equal(p163c_app(1,f,x,11,29),KApp{1,KCTwo{f,x},11,29}) &&
  p163t_equal(f_app(f,[x,y]),KApp{1,KCTwo{KApp{1,KCTwo{f,x},0,0},y},0,0}) &&
  p163t_equal(f_app(f,[]),f) &&
  p163t_equal(f_app_span(f,[x,y],11,29),KApp{1,KCTwo{KApp{1,KCTwo{f,x},11,29},y},11,29}) &&
  p163t_equal(f_app_span(f,[],11,29),f) &&
  p163t_equal(core_apply_span(f,x,11,29),KApp{0,KCTwo{f,x},11,29}) &&
  p163t_equal(core_apply_span(y,x,11,29),x) &&
  p163t_equal(core_apply_span(y,unlocated,11,29),unlocated) &&
  p163t_equal(f_scope_app_span(f,x,11,29),KApp{0,KCTwo{f,x},11,29}) &&
  p163t_equal(f_scope_app_span(y,x,11,29),x) &&
  p163t_equal(f_scope_app_span(y,unlocated,11,29),KLiteral{"U32",7,"",7,8}) &&
  p163t_equal(j_region_app(f,[x,y]),KApp{0,KCTwo{KApp{0,KCTwo{f,x},0,0},y},0,0}) &&
  p163t_equal(j_region_app(f,[]),f)

@unsafe
def p163t_other_variants() -> Bool:
  +literal : KTerm = KLiteral{"String",0,"text",5,9}
  +lambda = p163t_c()
  +legacyLam : KTerm = KTerm{"Lam","x",17,2,[p163t_b()],["r"],5,9}
  p163t_api(literal) && p163t_api(lambda) && p163t_api(legacyLam) &&
  p163t_laws(literal) && p163t_laws(lambda) && p163t_laws(legacyLam) &&
  p163t_equal(k_with_children(literal,[lambda]),literal) &&
  Bool.not(k_quantity_present(lambda)) && k_quantity_present(legacyLam)

@unsafe
def p163t_front_spans() -> Bool:
  +f : KTerm = KTerm{"Ref","f",0,1,[],[],0,0}
  +x : KTerm = KLiteral{"U32",7,"",3,5}
  +t : KTerm = KApp{1,KCTwo{f,x},0,0}
  +legacy : KTerm = KTerm{"App","",0,1,[f,x],[],0,0}
  +located : KTerm = KApp{1,KCTwo{f,x},7,9}
  p163t_same(f_span_created(t,11,19),f_span_created(legacy,11,19)) &&
  p163t_equal(f_span_created(t,0,0),t) && p163t_equal(f_span_created(located,11,19),located) &&
  p163t_same(f_pattern_value(t,11,19),f_pattern_value(legacy,11,19)) &&
  p163t_same(f_pattern_value(located,0,0),f_pattern_value(p163t_observe(located),0,0)) &&
  p163t_laws(f_span_created(t,11,19)) && p163t_laws(f_pattern_value(t,11,19))

@unsafe
def p163t_normalized_children() -> Bool:
  +t : KTerm = KApp{1,KCTwo{p163t_a(),p163t_b()},11,29}
  +kids : List<&2,KTerm> = [p163t_c(),p163t_b(),p163t_a()]
  p163t_equal(k_snf_children(t,kids),KApp{1,KCMany{p163t_c(),p163t_b(),p163t_a(),[]},11,29}) &&
  p163t_equal(k_lambda_presence(t,True{}),t) && p163t_equal(k_lambda_presence(t,False{}),t)

@unsafe
def p163t_snapshots() -> Bool:
  +t : KTerm = KApp{1,KCTwo{p163t_a(),p163t_b()},11,29}
  prefix_state_exact_term(t,t) && f_fresh_prefix_exact_terms([t],[t]) &&
  Bool.not(prefix_state_exact_term(t,k_with_span(t,11,31))) &&
  Bool.not(f_fresh_prefix_exact_terms([t],[k_with_span(t,11,31)])) &&
  p152c_variant(t,t) && Bool.not(p152c_variant(t,p163t_observe(t)))

@unsafe
def p163t_row(name: String, good: Bool) -> String:
  match good:
    case True{}: name ++ ":pass"
    case False{}: name ++ ":fail"

@unsafe
def p163t_controls() -> List<&2,String>:
  [p163t_row("compact-q0-shapes-and-laws",p163t_shape_cases(0,p163t_sets())),
   p163t_row("compact-q1-shapes-and-laws",p163t_shape_cases(1,p163t_sets())),
   p163t_row("compact-qmax-shapes-and-laws",p163t_shape_cases(4294967295,p163t_sets())),
   p163t_row("compact-zero-span",p163t_case(0,[p163t_a(),p163t_b()],0,0)),
   p163t_row("compact-point-span",p163t_case(1,[p163t_a(),p163t_b()],13,13)),
   p163t_row("compact-max-span",p163t_case(1,[p163t_a(),p163t_b()],4294967295,4294967295)),
   p163t_row("compact-legacy-metadata-preserved",p163t_legacy_kept()),
   p163t_row("compact-changed-metadata-fallback",p163t_changed_metadata()),
   p163t_row("compact-substitution-and-variable-cell",p163t_substitution()),
   p163t_row("compact-beta-preserves-argument",p163t_beta()),
   p163t_row("compact-substitution-stability",p163t_stability()),
   p163t_row("compact-direct-producers",p163t_producers()),
   p163t_row("compact-lambda-and-literal-contracts",p163t_other_variants()),
   p163t_row("compact-front-origin-walk",p163t_front_spans()),
   p163t_row("compact-normalized-children-and-presence",p163t_normalized_children()),
   p163t_row("compact-snapshot-and-prepared-variant",p163t_snapshots())]
