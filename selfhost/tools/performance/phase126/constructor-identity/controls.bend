# Invented checked-IR eligibility controls are never executed as native code.
@unsafe
def p126cit_book(+builtin: Bool, +dependent: Bool) -> List<&2,KDef>:
  +tree = kt("ADT","Grove",0,0,[])
  +field = nt_choose(KTerm,dependent,u => var("",10),u => tree)
  +node = KDef{"Fork","Ctr",2,0,kt("All","a",10,1,[tree,kt("All","b",11,1,[field,tree])]),atom("Absent"),[],builtin,False{}}
  [KDef{"Grove","ADT",0,0,atom("Data"),atom("Absent"),[node],builtin,False{}}]

@unsafe
def p126cit_body(+name: String, +fields: List<&2,KTerm>) -> KTerm:
  k_lam("a",101,1,[k_lam("b",102,1,[kt("Ctr",name,0,0,fields)],0,0,False{})],0,0,False{})

@unsafe
def p126cit_term(+name: String, +body: KTerm, +arity: U32) -> KTerm:
  kt("NMatch","",0,0,[kt("Mat",name,arity,0,[body,atom("Efq")]),var("",77)])

@unsafe
def p126cit_good() -> KTerm:
  +name = nc_ctor_encode("Fork")
  p126cit_term(name,p126cit_body(name,[var("",101),var("",102)]),3)

@unsafe
def p126cit_row(+name: String, +result: Bool) -> String:
  nt_choose(String,result,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126cit_bad(+body: KTerm) -> Bool:
  Bool.not(p126ci_match(p126cit_book(False{},False{}),p126cit_term(nc_ctor_encode("Fork"),body,3)))

@unsafe
def p126cit_keep_shape(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{dest,typ,symbol,Con{state,Con{N111Arg{wordtyp,N111Local{word}},Nil{}}}},rest}:
      String.eq(symbol,"p111_rt_sink") && String.eq(word,"unrelated")
    case _: False{}

@unsafe
def p126cit_cleanup(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111If{condition,yes,no},rest}: p126cit_keep_shape(yes)
    case Con{stmt,rest}: p126cit_cleanup(rest)

@unsafe
def p126ci_controls() -> List<&2,String>:
  +name = nc_ctor_encode("Fork")
  +book = p126cit_book(False{},False{})
  +good = p126cit_good()
  [p126cit_row("exact-owner-return",p126ci_match(book,good)),
   p126cit_row("unknown-constructor",Bool.not(p126ci_match([],good))),
   p126cit_row("builtin-layout-refusal",Bool.not(p126ci_match(p126cit_book(True{},False{}),good))),
   p126cit_row("dependent-field-refusal",Bool.not(p126ci_match(p126cit_book(False{},True{}),good))),
   p126cit_row("wrong-arity",Bool.not(p126ci_match(book,p126cit_term(name,p126cit_body(name,[var("",101),var("",102)]),4)))),
   p126cit_row("legacy-unspecified-arity",Bool.not(p126ci_match(book,p126cit_term(name,p126cit_body(name,[var("",101),var("",102)]),0)))),
   p126cit_row("wrong-constructor",p126cit_bad(p126cit_body(nc_ctor_encode("Other"),[var("",101),var("",102)]))),
   p126cit_row("swapped-fields",p126cit_bad(p126cit_body(name,[var("",102),var("",101)]))),
   p126cit_row("duplicate-field",p126cit_bad(p126cit_body(name,[var("",101),var("",101)]))),
   p126cit_row("dropped-field",p126cit_bad(p126cit_body(name,[var("",101)]))),
   p126cit_row("changed-field",p126cit_bad(p126cit_body(name,[var("",101),kt("Ctr","Zero",0,0,[])]))),
   p126cit_row("observed-field",p126cit_bad(p126cit_body(name,[app(ref("observe"),var("",101)),var("",102)]))),
   p126cit_row("free-alias",p126cit_bad(p126cit_body(name,[var("",103),var("",102)]))),
   p126cit_row("erased-binder",p126cit_bad(k_lam("a",101,0,[k_lam("b",102,1,[kt("Ctr",name,0,0,[var("",101),var("",102)])],0,0,False{})],0,0,False{}))),
   p126cit_row("repeated-binder",p126cit_bad(k_lam("a",101,1,[k_lam("b",101,1,[kt("Ctr",name,0,0,[var("",101),var("",101)])],0,0,False{})],0,0,False{}))),
   p126cit_row("remaining-argument",Bool.not(p126ci_match(book,k_with_children(good,nt_append(KTerm,ks(good),[var("",90)]))))),
   p126cit_row("non-variable-owner",Bool.not(p126ci_match(book,k_with_children(good,[kid(good,0),ref("owner")])))),
   p126cit_row("special-representation",Bool.not(p126ci_match_head(book,kt("Mat","ANode",3,0,[p126cit_body("ANode",[var("",101),var("",102)]),atom("Efq")])))),
   p126cit_row("unused-owner-cleanup",p126cit_cleanup(p111_body(p126ci_generic_hit(book,good,[NC_Binding{77,"original",N_Box{}},NC_Binding{88,"unrelated",N_Box{}}],0))))]
