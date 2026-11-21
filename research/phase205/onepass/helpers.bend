# Synthetic helpers remain ordinary checked definitions, never foreign intrinsics.
type P205OHelpers is Data:
  P205OHelpers{+context: List<&2,KDef>, +annotated: List<&2,KDef>, +emitName: String, +replaceName: String, +bound: U32}

@unsafe
def p205o_v(+base: U32, offset: U32) -> KTerm:
  var("$p205",U32.add(base,offset))

@unsafe
def p205o_lam(+base: U32, offset: U32, quant: U32, body: KTerm) -> KTerm:
  kt("Lam","$p205",U32.add(base,offset),quant,[body])

@unsafe
def p205o_all(+base: U32, offset: U32, quant: U32, name: String, rest: KTerm) -> KTerm:
  all(quant,"$p205",U32.add(base,offset),ref(name),rest)

@unsafe
def p205o_ctor(name: String, children: List<&2,KTerm>) -> KTerm:
  kt("Ctr",name,0,0,children)

@unsafe
def p205o_case(name: String, arm: KTerm, rest: KTerm) -> KTerm:
  kt("Mat",name,0,0,[arm,rest])

@unsafe
def p205o_call(+name: String, separator: KTerm, delimiter: KTerm, input: KTerm) -> KTerm:
  app(app(app(ref(name),separator),delimiter),input)

@unsafe
def p205o_emit(+base: U32, name: String) -> KDef:
  +signature = p205o_all(base,1,1,"String",p205o_all(base,2,1,"U32",p205o_all(base,3,1,"String",p205o_all(base,4,1,"Bool",ref("String")))))
  +body = p205o_lam(base,1,1,p205o_lam(base,2,1,p205o_lam(base,3,1,
    p205o_case("True",p205_pair("String.append",p205o_v(base,1),p205o_v(base,3)),
      p205o_case("False",p205o_ctor("SCon",[p205o_ctor("Chr",[p205o_v(base,2)]),p205o_v(base,3)]),atom("Efq"))))))
  KDef{name,"Def",4,0,signature,body,[],False{},False{}}

@unsafe
def p205o_replace(+base: U32, +name: String, +emit: String) -> KDef:
  +signature = p205o_all(base,8,2,"String",p205o_all(base,9,2,"U32",p205o_all(base,10,1,"String",ref("String"))))
  +step = app(app(app(app(ref(emit),p205o_v(base,8)),p205o_v(base,13)),
    p205o_call(name,p205o_v(base,8),p205o_v(base,9),p205o_v(base,12))),
    p205_pair("U32.is_eq",p205o_v(base,13),p205o_v(base,9)))
  +bind = kt("Bind","$p205word",U32.add(base,13),2,[p205o_v(base,11)])
  +body = p205o_lam(base,8,2,p205o_lam(base,9,2,
    p205o_case("SNil",p205o_ctor("SNil",[]),
      p205o_case("SCon",p205o_case("Chr",p205o_lam(base,11,1,p205o_lam(base,12,1,kt("Let","",0,0,[bind,step]))),atom("Efq")),atom("Efq")))))
  KDef{name,"Def",3,0,signature,body,[],False{},False{}}

@unsafe
def p205o_bound(+context: List<&2,KDef>, +base: U32) -> List<&2,KDef>:
  kw_bound_book(context,U32.add(base,16))

@unsafe
def p205o_checked_replace(+context: List<&2,KDef>, +base: U32, +emit: KDef, +replace: KDef, +result: KChecking) -> Maybe<&2,P205OHelpers>:
  kc(Maybe<&2,P205OHelpers>,good(result),u => p205o_helpers_done(context,base,emit,dg_event_output(replace,ct(result))),u => None{})

@unsafe
def p205o_helpers_done(+context: List<&2,KDef>, +base: U32, +emit: KDef, +replace: KDef) -> Maybe<&2,P205OHelpers>:
  +book = p205o_bound(book_put(context,replace),base)
  Some{P205OHelpers{book,[ka_def(book,emit),ka_def(book,replace)],dn(emit),dn(replace),U32.add(base,16)}}

@unsafe
def p205o_checked_emit(+context: List<&2,KDef>, +base: U32, +emit: KDef, +replace: KDef, +result: KChecking) -> Maybe<&2,P205OHelpers>:
  kc(Maybe<&2,P205OHelpers>,good(result),u => p205o_replace_check(context,base,dg_event_output(emit,ct(result)),replace),u => None{})

@unsafe
def p205o_replace_check(+context: List<&2,KDef>, +base: U32, +emit: KDef, +replace: KDef) -> Maybe<&2,P205OHelpers>:
  +book = p205o_bound(book_put(context,emit),base)
  p205o_checked_replace(book,base,emit,replace,check_definition_world(kw_initial(book),replace,0))

@unsafe
def p205o_prepare_defs(+context: List<&2,KDef>, +base: U32, +emit: KDef, +replace: KDef) -> Maybe<&2,P205OHelpers>:
  +book = p205o_bound(book_put_many(context,[emit,replace]),base)
  p205o_checked_emit(book,base,emit,replace,check_definition_world(kw_initial(book),emit,0))

@unsafe
def p205o_prepare(+context: List<&2,KDef>, +base: U32, +emit: String, +replace: String) -> Maybe<&2,P205OHelpers>:
  kc(Maybe<&2,P205OHelpers>,U32.is_lt(base,4294901760) && String.eq(dk(lookup(context,emit)),"Absent") &&
      String.eq(dk(lookup(context,replace)),"Absent") && Bool.not(String.eq(emit,replace)),
    u => p205o_prepare_defs(context,base,p205o_emit(base,emit),p205o_replace(base,replace,emit)),u => None{})
