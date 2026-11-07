# Finite compiler-data controls, not a new source-typing or correctness theorem.
# The unmodified nc_erase is the independent structural oracle.
law p175sc_exact:
  for +left: KTerm
  for +right: KTerm
  Bool

@unsafe
def p175sc_kind(term: KTerm) -> U32:
  match term:
    case KTerm{a,b,c,d,e,f,g,h}: 0
    case KLambda{a,b,c,d,e,f,g,h}: 1
    case KLiteral{a,b,c,d,e}: 2

@unsafe
def p175sc_children(left: List<&2,KTerm>, right: List<&2,KTerm>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,as} Con{b,bs}: p175sc_exact(a,b) && p175sc_children(as,bs)
    case _ _: False{}

@unsafe
def p175sc_exact(left,right):
  norm_exact(left,right) && U32.is_eq(kb(left),kb(right)) && U32.is_eq(ke(left),ke(right)) &&
    U32.is_eq(p175sc_kind(left),p175sc_kind(right)) &&
    U32.is_eq(Bool.to_u32(k_quantity_present(left)),Bool.to_u32(k_quantity_present(right))) &&
    p175sc_children(ks(left),ks(right))

@unsafe
def p175sc_row(name: String, passed: Bool) -> String:
  name ++ nt_choose(String,passed,u => ":pass",u => ":FAIL")

@unsafe
def p175sc_type() -> KTerm:
  kt("ADT","P175Box",0,0,[])

@unsafe
def p175sc_book() -> List<&2,KDef>:
  [KDef{"P175Box","ADT",0,0,typ(2),kt("Absent","",0,0,[]),
    [KDef{"P175Make","Ctr",3,0,
      all(0,"T",1,typ(2),all(2,"x",2,var("T",1),all(1,"y",3,var("T",1),p175sc_type()))),
      kt("Absent","",0,0,[]),[],False{},False{}}],False{},False{}}]

@unsafe
def p175sc_field(term: KTerm, quantity: U32) -> KTerm:
  ka_field(ka_wrap(term,typ(2)),quantity)

@unsafe
def p175sc_input(+first: KTerm) -> KTerm:
  ka_wrap(kt("Ctr","P175Make",0,0,[first,p175sc_field(ref("x"),2),p175sc_field(var("v",17),1)]),p175sc_type())

@unsafe
def p175sc_valid() -> KTerm:
  p175sc_input(p175sc_field(typ(2),0))

@unsafe
def p175sc_expected() -> KTerm:
  kt("Ctr",nc_ctor_encode("P175Make"),0,0,[ref("x"),var("v",17)])

@unsafe
def p175sc_compare(+term: KTerm) -> Bool:
  p175sc_exact(nc_erase(p175sc_book(),term),p175sf_erase(p175sc_book(),term))

@unsafe
def p175sc_definition(+term: KTerm, templates: U32) -> KDef:
  KDef{"work","Def",0,templates,p175sc_type(),term,[],False{},False{}}

@unsafe
def p175sc_forged() -> KTerm:
  p175sc_input(p175sc_field(typ(2),2))

@unsafe
def p175sc_untrusted(+definition: KDef) -> Bool:
  p175sc_exact(nc_definition_plain(p175sc_book(),definition,0),
    p175sf_definition(p175sc_book(),[],definition))

@unsafe
def p175sc_template(+definition: KDef) -> Bool:
  p175sc_exact(nc_definition_plain(p175sc_book(),definition,0),
    p175sf_definition(p175sc_book(),[definition],definition))

@unsafe
def p175sf_controls() -> List<&2,String>:
  [p175sc_row("dependent-erased-first-exact",p175sc_compare(p175sc_valid())),
   p175sc_row("explicit-complete-expected",p175sc_exact(p175sf_erase(p175sc_book(),p175sc_valid()),p175sc_expected())),
   p175sc_row("marker-from-producer",p175sf_marked(p175sc_field(typ(2),0))),
   p175sc_row("unstamped-fallback",p175sc_compare(p175sc_input(ka_wrap(typ(2),typ(2))))),
   p175sc_row("wrong-tag-fallback",p175sc_compare(p175sc_input(kt("Var","",1,0,[])))),
   p175sc_row("name-refusal",Bool.not(p175sf_marked(KTerm{"Ann","named",1,0,[typ(2),typ(2)],[],0,0}))),
   p175sc_row("quantity-refusal",Bool.not(p175sf_marked(KTerm{"Ann","",1,3,[typ(2),typ(2)],[],0,0}))),
   p175sc_row("arity-refusal",Bool.not(p175sf_marked(KTerm{"Ann","",1,0,[typ(2)],[],0,0}))),
   p175sc_row("removed-refusal",Bool.not(p175sf_marked(KTerm{"Ann","",1,0,[typ(2),typ(2)],["x"],0,0}))),
   p175sc_row("span-refusal",Bool.not(p175sf_marked(KTerm{"Ann","",1,0,[typ(2),typ(2)],[],1,2}))),
   p175sc_row("malformed-marker-fallback",p175sc_compare(p175sc_input(KTerm{"Ann","bad",1,3,[typ(2)],[],9,11}))),
   p175sc_row("proof-erasure",p175sc_compare(ka_wrap(p175sc_valid(),kt("Eql","",0,0,[])))),
   p175sc_row("erased-lambda",p175sc_compare(k_lam("z",33,0,[p175sc_valid()],5,9,True{}))),
   p175sc_row("live-lambda",p175sc_compare(k_lam("z",33,2,[p175sc_valid()],5,9,True{}))),
   p175sc_row("nested-erasure",p175sc_compare(ka_wrap(kt("Ctr","P175Make",0,0,
     [p175sc_field(typ(2),0),p175sc_field(p175sc_valid(),2),p175sc_field(var("v",17),1)]),p175sc_type()))),
   p175sc_row("raw-marker-is-not-authority",Bool.not(p175sc_compare(p175sc_forged()))),
   p175sc_row("untrusted-definition-keeps-original",p175sc_untrusted(p175sc_definition(p175sc_forged(),0))),
   p175sc_row("template-keeps-original",p175sc_template(p175sc_definition(p175sc_forged(),1)))]

# Complete values for host serialization; order is input, independent original,
# candidate, literal expected, nested input/original/candidate. No checksum oracle.
@unsafe
def p175sf_values() -> List<&2,KTerm>:
  [p175sc_valid(),nc_erase(p175sc_book(),p175sc_valid()),
   p175sf_erase(p175sc_book(),p175sc_valid()),p175sc_expected(),
   k_lam("z",33,2,[p175sc_valid()],5,9,True{}),
   nc_erase(p175sc_book(),k_lam("z",33,2,[p175sc_valid()],5,9,True{})),
   p175sf_erase(p175sc_book(),k_lam("z",33,2,[p175sc_valid()],5,9,True{}))]
