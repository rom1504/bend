# Count actual globally freshened SOURCE events, excluding Base. A repeated
# law/fill name chooses the first event conservatively; missing means no reuse.
@unsafe
def p140cb_owner_cut(load: FPrefixLoad, name: String) -> U32:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}: p140cb_owner_events(suffix,name,0)

@unsafe
def p140cb_owner_events(events: List<&2,KDef>, +name: String, +count: U32) -> U32:
  match events:
    case Nil{}: 0
    case Con{d,+rest}:
      kc(U32,String.eq(dn(d),name),u => count,
        u => p140cb_owner_events(rest,name,U32.inc(count)))

# Data-level controls for event selection; parser/checker admission is separate.
@unsafe
def p140cb_cut_def(name: String) -> KDef:
  KDef{name,"Def",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}

@unsafe
def p140cb_cut_load(+events: List<&2,KDef>) -> FPrefixLoad:
  FPrefixLoad{FLoadTrace{FResult{events,"",[]},[],[]},[p140cb_cut_def("BaseOnly")],events,True{}}

@unsafe
def p140cb_cut_controls() -> List<&2,String>:
  +load = p140cb_cut_load([p140cb_cut_def("alpha"),p140cb_cut_def("pick"),p140cb_cut_def("middle"),p140cb_cut_def("pick"),p140cb_cut_def("last")])
  [p131u_row(U32.is_eq(p140cb_owner_cut(load,"alpha"),0),"cut-first-source-event"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"pick"),1),"cut-first-law-before-fill"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"middle"),2),"cut-middle-source-event"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"last"),4),"cut-last-source-event"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"absent"),0),"cut-missing-refuses-reuse"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"BaseOnly"),0),"cut-does-not-count-Base"),
   p131u_row(U32.is_eq(p140cb_owner_cut(p140cb_cut_load([]),"absent"),0),"cut-empty-source")]
