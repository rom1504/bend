# Private report-name deduplication. No dependency result or report is cached.
# The original ordered roots, native skips and final report machinery remain.
@unsafe
def p140dr_has(+seen: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(seen,name,index_hash(name,2166136261),32)),"P140ReportSeen")

@unsafe
def p140dr_mark(seen: KDef, +name: String) -> KDef:
  index_set(seen,KDef{name,"P140ReportSeen",0,0,KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p140dr_names(book: List<&2,KDef>, +seen: KDef) -> List<&2,String>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      +name = dn(d)
      nt_choose(List<&2,String>,db(d) || p140dr_has(seen,name),
        u => p140dr_names(rest,seen),
        u => Con{name,p140dr_names(rest,p140dr_mark(seen,name))})

@unsafe
def p140dr_report_data(+book: List<&2,KDef>) -> DR_Report:
  +names = dr_cached_names(book_cached(book_final_fast(book,[]),0),p140dr_names(book,missing()),missing())
  DR_Report{dr_verdict(names),names}
