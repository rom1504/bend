# Reference is the original kr_filter algorithm, independent of the new index.
# Fixed expected sequences additionally protect duplicate payloads and order.

@unsafe
def p128rfc_reference(book: List<&2,KDef>, +live: List<&2,String>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      kc(List<&2,KDef>,has_name(live,dn(d)),
        u => Con{d,p128rfc_reference(rest,live)},u => p128rfc_reference(rest,live))

@unsafe
def p128rfc_def(+name: String, +id: U32) -> KDef:
  KDef{name,"P128Fixture",id,U32.add(id,17),
    kt_span("Type",name,id,2,[],id,U32.add(id,1)),
    kt_span("Value",name,U32.add(id,3),1,[],U32.add(id,2),U32.add(id,4)),
    [KDef{"child","Ctr",id,0,atom("Data"),atom("Absent"),[],False{},True{}}],
    U32.is_eq(U32.and(id,1),1),U32.is_eq(U32.and(id,2),2)}

@unsafe
def p128rfc_bool(+a: Bool, +b: Bool) -> Bool:
  (a && b) || (Bool.not(a) && Bool.not(b))

@unsafe
def p128rfc_term(+a: KTerm, +b: KTerm) -> Bool:
  norm_exact(a,b) && U32.is_eq(kb(a),kb(b)) && U32.is_eq(ke(a),ke(b))

@unsafe
def p128rfc_defs(a: List<&2,KDef>, b: List<&2,KDef>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{+x,xs} Con{+y,ys}:
      String.eq(dn(x),dn(y)) && String.eq(dk(x),dk(y)) &&
      U32.is_eq(da(x),da(y)) && U32.is_eq(dx(x),dx(y)) &&
      p128rfc_term(dt(x),dt(y)) && p128rfc_term(dv(x),dv(y)) &&
      p128rfc_bool(db(x),db(y)) && p128rfc_bool(du(x),du(y)) &&
      p128rfc_defs(dc(x),dc(y)) && p128rfc_defs(xs,ys)
    case Nil{} Con{y,ys}: False{}
    case Con{x,xs} Nil{}: False{}

@unsafe
def p128rfc_equal(+book: List<&2,KDef>, +live: List<&2,String>) -> Bool:
  p128rfc_defs(kr_filter(book,live),p128rfc_reference(book,live))

@unsafe
def p128rfc_range(+left: U32, +key: String) -> List<&2,KDef>:
  kc(List<&2,KDef>,U32.is_eq(left,0),u => [],
    u => Con{p128rfc_def(key,left),p128rfc_range(U32.sub(left,1),key)})

@unsafe
def p128rfc_rows(+left: U32) -> List<&2,KDef>:
  kc(List<&2,KDef>,U32.is_eq(left,0),u => [],
    u => Con{p128rfc_def("name." ++ U32.show(left),left),p128rfc_rows(U32.sub(left,1))})

@unsafe
def p128rfc_names(+left: U32) -> List<&2,String>:
  kc(List<&2,String>,U32.is_eq(left,0),u => [],
    u => Con{"name." ++ U32.show(left),p128rfc_names(U32.sub(left,1))})

@unsafe
def p128rfc_row(+label: String, good: Bool) -> String:
  label ++ kc(String,good,u => ":pass",u => ":FAIL")

@unsafe
def p128rf_controls() -> List<&2,String>:
  +a = p128rfc_def("alpha",1)
  +a2 = p128rfc_def("alpha",9)
  +b = p128rfc_def("beta",2)
  +empty = p128rfc_def("",3)
  +unicode = p128rfc_def("λ.树",4)
  +collisionA = p128rfc_def("costarring",5)
  +collisionB = p128rfc_def("liquid",6)
  +leaf : KDef = KIndexLeaf{17,[a,b]}
  +node : KDef = KIndexNode{17,1,leaf,missing()}
  +cache : KDef = KDef{"$kernel.cache","BookCache",7,0,atom("Absent"),atom("Absent"),[node],True{},False{}}
  +book : List<&2,KDef> = [a,b,a2,empty,unicode,collisionA,collisionB,leaf,node,cache]
  [p128rfc_row("reach-empty-both",p128rfc_equal([],[])),
   p128rfc_row("reach-empty-book",p128rfc_equal([],["alpha","λ.树"])),
   p128rfc_row("reach-empty-live",p128rfc_defs(kr_filter(book,[]),[])),
   p128rfc_row("reach-no-match",p128rfc_defs(kr_filter(book,["absent"]),[])),
   p128rfc_row("reach-duplicate-definitions-retained-in-order",p128rfc_defs(kr_filter(book,["alpha"]),[a,a2])),
   p128rfc_row("reach-duplicate-live-does-not-duplicate-output",p128rfc_defs(kr_filter(book,["alpha","alpha"]),[a,a2])),
   p128rfc_row("reach-book-order-not-live-order",p128rfc_defs(kr_filter(book,["beta","alpha"]),[a,b,a2])),
   p128rfc_row("reach-empty-name-includes-index-values",p128rfc_defs(kr_filter(book,[""]),[empty,leaf,node])),
   p128rfc_row("reach-unicode-name",p128rfc_defs(kr_filter(book,["λ.树"]),[unicode])),
   p128rfc_row("reach-exact-case-sensitive",p128rfc_defs(kr_filter(book,["Alpha"]),[])),
   p128rfc_row("reach-cache-name-retains-original-payload",p128rfc_defs(kr_filter(book,["$kernel.cache"]),[cache])),
   p128rfc_row("reach-collision-premise",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261))),
   p128rfc_row("reach-collision-a-only",p128rfc_defs(kr_filter(book,["costarring"]),[collisionA])),
   p128rfc_row("reach-collision-b-only",p128rfc_defs(kr_filter(book,["liquid"]),[collisionB])),
   p128rfc_row("reach-collision-both",p128rfc_defs(kr_filter(book,["liquid","costarring"]),[collisionA,collisionB])),
   p128rfc_row("reach-reference-all-shapes",p128rfc_equal(book,["alpha","","λ.树","liquid","costarring","$kernel.cache"])),
   p128rfc_row("reach-reference-mixed-misses",p128rfc_equal(book,["absent","β","beta","","λ.树","alpha","alpha"])),
   p128rfc_row("reach-128-duplicate-events",p128rfc_equal(p128rfc_range(128,"alpha"),["alpha","missing"])),
   p128rfc_row("reach-128-distinct-events",p128rfc_equal(p128rfc_rows(128),p128rfc_names(128))),
   p128rfc_row("reach-128-mixed-membership",p128rfc_equal(p128rfc_rows(128),["name.1","name.64","name.128","name.129"]))]
