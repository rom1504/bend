# Independent original list implementation and complete literal ordered outputs.
# Compiler-data only: deliberately malformed definition names remain supported.
type P175RNCase is Data:
  P175RNCase{+name: String, +book: List<&2,KDef>, +initial: List<&2,String>,
    +expected: List<&2,String>, +original: List<&2,String>, +candidate: List<&2,String>}

@unsafe
def p175rnc_original(+book: List<&2,KDef>, +seen: List<&2,String>) -> List<&2,String>:
  match book:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,String>,db(definition) || has_name(seen,dn(definition)),
        u => p175rnc_original(rest,seen),
        u => Con{dn(definition),p175rnc_original(rest,Con{dn(definition),seen})})

@unsafe
def p175rnc_def(name: String, native: Bool) -> KDef:
  KDef{name,"Def",0,0,KTerm{"Absent","",0,0,[],[],0,0},
    KTerm{"Absent","",0,0,[],[],0,0},[],native,False{}}

@unsafe
def p175rnc_case(name: String, +book: List<&2,KDef>, +initial: List<&2,String>, expected: List<&2,String>) -> P175RNCase:
  P175RNCase{name,book,initial,expected,p175rnc_original(book,initial),dr_own_names(book,initial)}

@unsafe
def p175rn_cases() -> List<&2,P175RNCase>:
  [p175rnc_case("empty",[],[],[]),
   p175rnc_case("initial-only",[],["a","a",""],[]),
   p175rnc_case("ordered",[p175rnc_def("b",False{}),p175rnc_def("a",False{}),p175rnc_def("c",False{})],[],["b","a","c"]),
   p175rnc_case("duplicate-first",[p175rnc_def("b",False{}),p175rnc_def("a",False{}),p175rnc_def("b",False{})],[],["b","a"]),
   p175rnc_case("seen-duplicates",[p175rnc_def("a",False{}),p175rnc_def("b",False{}),p175rnc_def("c",False{})],["a","a","c"],["b"]),
   p175rnc_case("native-before-own",[p175rnc_def("a",True{}),p175rnc_def("b",False{}),p175rnc_def("a",False{})],[],["b","a"]),
   p175rnc_case("own-before-native",[p175rnc_def("a",False{}),p175rnc_def("a",True{}),p175rnc_def("a",False{})],[],["a"]),
   p175rnc_case("all-native",[p175rnc_def("a",True{}),p175rnc_def("b",True{})],[],[]),
   p175rnc_case("empty-name",[p175rnc_def("",False{}),p175rnc_def("a",False{}),p175rnc_def("",False{})],[],["","a"]),
   p175rnc_case("empty-native-before-own",[p175rnc_def("",True{}),p175rnc_def("",False{})],[],[""]),
   p175rnc_case("empty-already-seen",[p175rnc_def("",False{}),p175rnc_def("a",False{})],[""],["a"]),
   p175rnc_case("hash-collision",[p175rnc_def("costarring",False{}),p175rnc_def("liquid",False{}),p175rnc_def("costarring",False{})],[],["costarring","liquid"]),
   p175rnc_case("seen-hash-collision",[p175rnc_def("costarring",False{}),p175rnc_def("liquid",False{})],["costarring"],["liquid"]),
   p175rnc_case("unicode",[p175rnc_def("商",False{}),p175rnc_def("𐀀",False{}),p175rnc_def("",False{}),p175rnc_def("商",False{})],[],["商","𐀀",""]),
   p175rnc_case("seen-unicode",[p175rnc_def("𐀀",False{}),p175rnc_def("",False{})],["𐀀"],[""])]

@unsafe
def p175rnc_equal(left: List<&2,String>, right: List<&2,String>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,as} Con{b,bs}: p88_string_eq(a,b) && p175rnc_equal(as,bs)
    case _ _: False{}

@unsafe
def p175rnc_result(row: P175RNCase) -> String:
  match row:
    case P175RNCase{name,book,initial,+expected,original,candidate}:
      name ++ nt_choose(String,p175rnc_equal(original,expected) && p175rnc_equal(candidate,expected),
        u => ":pass",u => ":FAIL")

@unsafe
def p175rnc_results(rows: List<&2,P175RNCase>) -> List<&2,String>:
  match rows:
    case Nil{}: []
    case Con{row,rest}: Con{p175rnc_result(row),p175rnc_results(rest)}

@unsafe
def p175rn_controls() -> List<&2,String>:
  p175rnc_results(p175rn_cases())
