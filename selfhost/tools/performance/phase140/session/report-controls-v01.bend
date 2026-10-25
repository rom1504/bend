@unsafe
def p140drc_def(name: String, native: Bool, unsafe: Bool) -> KDef:
  KDef{name,"Def",0,0,atom("Typ"),atom("Typ"),[],native,unsafe}

@unsafe
def p140drc_seed(names: List<&2,String>, seen: KDef) -> KDef:
  match names:
    case Nil{}: seen
    case Con{name,rest}: p140drc_seed(rest,p140dr_mark(seen,name))

@unsafe
def p140drc_names(+book: List<&2,KDef>, +seen: List<&2,String>, expected: List<&2,String>) -> Bool:
  +actual = p140dr_names(book,p140drc_seed(seen,missing()))
  p140o_strings(actual,dr_own_names(book,seen)) && p140o_strings(actual,expected)

@unsafe
def p140drc_reports(a: DR_Report, b: DR_Report) -> Bool:
  match a b:
    case DR_Report{av,an} DR_Report{bv,bn}: String.eq(av,bv) && p140o_strings(an,bn)

@unsafe
def p140drc_report(+book: List<&2,KDef>) -> Bool:
  p140drc_reports(driver_report_data(book),p140dr_report_data(book))

@unsafe
def p140dr_controls() -> List<&2,String>:
  +a = p140drc_def("a",False{},False{})
  +b = p140drc_def("b",False{},True{})
  +native_a = p140drc_def("a",True{},False{})
  +left = p140drc_def("costarring",False{},False{})
  +right = p140drc_def("liquid",False{},True{})
  [p131u_row(p140drc_names([],[],[]),"report-empty"),
   p131u_row(p140drc_names([a,b],[],["a","b"]),"report-source-order"),
   p131u_row(p140drc_names([a,b,a,b],[],["a","b"]),"report-duplicates"),
   p131u_row(p140drc_names([native_a,a,b],[],["a","b"]),"report-native-before-user"),
   p131u_row(p140drc_names([a,native_a,a,b],[],["a","b"]),"report-native-after-user"),
   p131u_row(p140drc_names([native_a,native_a],[],[]),"report-all-native"),
   p131u_row(p140drc_names([a,b],["b"],["a"]),"report-existing-seen"),
   p131u_row(p140drc_names([a,b],["a","a","b"],[]),"report-duplicate-seen"),
   p131u_row(U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261)) &&
     p140drc_names([left,right,left,right],[],["costarring","liquid"]),"report-real-hash-collision"),
   p131u_row(p140drc_names([p140drc_def("",False{},False{}),a,p140drc_def("",False{},False{})],[],["","a"]),"report-empty-name"),
   p131u_row(p140drc_names([p140drc_def("λ",False{},False{}),p140drc_def("λ",False{},False{})],[],["λ"]),"report-unicode-name"),
   p131u_row(p140drc_report([]),"report-complete-empty"),
   p131u_row(p140drc_report([a,b]),"report-complete-safe-unsafe"),
   p131u_row(p140drc_report([native_a,a,b,a]),"report-complete-native-shadow"),
   p131u_row(p140drc_report([left,right,left]),"report-complete-collision")]
