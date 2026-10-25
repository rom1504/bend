# Compare complete original ordered NR_Closure names and facts. These controls
# work with either the old body-only or the new body-plus-nc_refs entry shape.
@unsafe
def p140ec_equal(left: NR_Closure, right: NR_Closure) -> Bool:
  match left right:
    case NR_Closure{a,af} NR_Closure{b,bf}:
      p140o_strings(a,b) && f_fresh_prefix_exact_defs(af,bf)

@unsafe
def p140ec_result(result: P140OEResult) -> NR_Closure:
  match result:
    case P140OEResult{closure,entries,hits,misses}: closure

@unsafe
def p140ec_case(+book: List<&2,KDef>) -> Bool:
  p140ec_after(book,p140oe_apply(book,P140OAnalysis{False{},missing(),[],0},[]))

@unsafe
def p140ec_after(+book: List<&2,KDef>, +cold: P140OEResult) -> Bool:
  match cold:
    case P140OEResult{closure,entries,hits,misses}:
      p140ec_equal(closure,nr_walk(book,["main"],[],[])) &&
        p140ec_equal(p140ec_result(p140oe_apply(book,P140OAnalysis{True{},missing(),[],0},entries)),nr_walk(book,["main"],[],[]))

@unsafe
def p140ec_controls() -> List<&2,String>:
  [p140oc_row("erasure-index-chain-cold-and-warm-exact",p140ec_case(p140oc_book(1,8))),
   p140oc_row("erasure-index-cycle-cold-and-warm-exact",p140ec_case(p140oc_cycle(1))),
   p140oc_row("erasure-index-duplicates-preserve-order",p140ec_case(book_cached([
     p140oc_def("main",kt("App","",0,0,[ref("a"),ref("b"),ref("a")])),p140oc_def("a",ref("b")),p140oc_def("b",KLiteral{"U32",0,"",0,0})],40))),
   p140oc_row("erasure-index-missing-name-matches-original",p140ec_case(book_cached([p140oc_def("main",ref("missing"))],40))),
   p140oc_row("erasure-index-real-hash-collision",p140ec_case(book_cached([
     p140oc_def("main",kt("App","",0,0,[ref("costarring"),ref("liquid")])),p140oc_def("costarring",KLiteral{"U32",0,"",0,0}),p140oc_def("liquid",KLiteral{"U32",1,"",0,0})],40)))]
