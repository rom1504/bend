# Focused finite controls. Metadata expectations are literal; cache comparisons
# use the old selection/scan against the same exact book and complete plans.

@unsafe
def p169qc_direct(+name: String, arity: U32, result: U32, public: U32) -> KDef:
  index_set(missing(),KDef{name,"P113Direct",arity,result,
    atom("Absent"),kt("P113DSignature","",public,0,[]),[],False{},False{}},
    index_hash(name,2166136261),32)

@unsafe
def p169qc_import(arity: U32, result: U32, incoming: U32, flags: U32,
    direct: KDef) -> Bool:
  p168j_eligible(N111Segment{"probe",arity,result,incoming,flags,[]},direct)

@unsafe
def p169qc_candidate_names(candidates: List<&2,P112MultiCandidate>) -> List<&2,String>:
  match candidates:
    case Nil{}: []
    case Con{P112MultiCandidate{N111Segment{name,arity,result,incoming,flags,body}},rest}:
      Con{name,p169qc_candidate_names(rest)}

@unsafe
def p169qc_candidate_order() -> Bool:
  +segments : List<&2,N111Segment> = [
    N111Segment{"first",0,1,0,0,[]},N111Segment{"continuation",1,1,1,0,[]},
    N111Segment{"imported",0,1,0,0,[]},N111Segment{"last",0,1,0,0,[]}]
  +imports = p111v_put(missing(),"imported","P112Worker",0,0)
  p134v_list(~String,~String.eq,p169qc_candidate_names(p168j_candidates(segments,imports,[])),["first","last"])

@unsafe
def p169qc_book() -> List<&2,KDef>:
  [KDef{"U32","ADT",0,0,atom("Absent"),atom("Absent"),[],True{},False{}}]

@unsafe
def p169qc_plan(name: String, error: String) -> NO_Plan:
  NO_Plan{name,NO_Schema{[var("U32",10)],[0],var("U32",11),11,"U32",[],12,""},
    NO_Analysis{kt("NO_Return","",0,0,[var("",10)]),12,4095,""},error}

@unsafe
def p169qc_cached_flags(plans: List<&2,P169ScalarPlan>) -> Bool:
  match plans:
    case Con{P169ScalarPlan{+left,True{}},Con{P169ScalarPlan{+right,False{}},Nil{}}}:
      String.eq(no_plan_owner(left),"accepted") && String.eq(no_plan_owner(right),"refused") &&
      String.eq(no_plan_error(left),"") && String.eq(no_plan_error(right),"known refusal")
    case _: False{}

@unsafe
def p169qc_selection_equal(a: P168TSelection, b: P168TSelection) -> Bool:
  match a b:
    case P168TSelection{leftBlocked,leftTargets} P168TSelection{rightBlocked,rightTargets}:
      p140eq_def(leftBlocked,rightBlocked) && p140eq_def(leftTargets,rightTargets)

@unsafe
def p169qc_plan_equal(a: NO_Plan, b: NO_Plan) -> Bool:
  match a b:
    case NO_Plan{ao,NO_Schema{ap,ar,aw,av,at,asp,af,ae},NO_Analysis{ab,an,al,ax},az} NO_Plan{bo,NO_Schema{bp,br,bw,bv,bt,bsp,bf,be},NO_Analysis{bb,bn,bl,bx},bz}:
      String.eq(ao,bo) && norm_exact_lists(ap,bp) && p134v_list(~U32,~U32.is_eq,ar,br) &&
      norm_exact(aw,bw) && U32.is_eq(av,bv) && String.eq(at,bt) &&
      List.is_empty(&2,NO_Spec,asp) && List.is_empty(&2,NO_Spec,bsp) &&
      U32.is_eq(af,bf) && String.eq(ae,be) && norm_exact(ab,bb) &&
      U32.is_eq(an,bn) && U32.is_eq(al,bl) && String.eq(ax,bx) && String.eq(az,bz)

# These fixtures have no available owning function, so the complete scan must
# preserve the ordered retry plans while producing no functions or summaries.
@unsafe
def p169qc_scan_equal(a: P128BROpen, b: P128BROpen) -> Bool:
  match a b:
    case P128BROpen{af,ah,ar,ae} P128BROpen{bf,bh,br,be}:
      List.is_empty(&2,P113DFunction,af) && List.is_empty(&2,P113DFunction,bf) &&
      List.is_empty(&2,P128BRHelper,ah) && List.is_empty(&2,P128BRHelper,bh) &&
      p134v_list(~NO_Plan,~p169qc_plan_equal,ar,br) && String.eq(ae,be)

@unsafe
def p169q_controls() -> List<&2,String>:
  +book = p169qc_book()
  +plans : List<&2,NO_Plan> = [p169qc_plan("accepted",""),p169qc_plan("refused","known refusal")]
  +cached = p169q_plans(book,plans)
  [p167c_row("metadata-valid-import",p169qc_import(2,1,0,0,p169qc_direct("probe",2,1,1))),
   p167c_row("metadata-continuation-refused",Bool.not(p169qc_import(2,1,1,0,p169qc_direct("probe",2,1,1)))),
   p167c_row("metadata-flags-refused",Bool.not(p169qc_import(2,1,0,1,p169qc_direct("probe",2,1,1)))),
   p167c_row("metadata-results-refused",Bool.not(p169qc_import(2,0,0,0,p169qc_direct("probe",2,1,1)))),
   p167c_row("metadata-large-arity-refused",Bool.not(p169qc_import(33,1,0,0,p169qc_direct("probe",33,1,1)))),
   p167c_row("metadata-boundary-arity",p169qc_import(32,1,0,0,p169qc_direct("probe",32,1,1))),
   p167c_row("metadata-absent-import-refused",Bool.not(p169qc_import(2,1,0,0,missing()))),
   p167c_row("metadata-private-refused",Bool.not(p169qc_import(2,1,0,0,p169qc_direct("probe",2,1,0)))),
   p167c_row("metadata-wrong-import-arity",Bool.not(p169qc_import(2,1,0,0,p169qc_direct("probe",1,1,1)))),
   p167c_row("metadata-candidate-order",p169qc_candidate_order()),
   p167c_row("cache-actual-predicate-positive",p128bs_eligible(book,p169qc_plan("accepted",""))),
   p167c_row("cache-exact-positive-negative",p169qc_cached_flags(cached)),
   p167c_row("cache-complete-selection",p169qc_selection_equal(
     p168t_selection(book,plans,missing(),missing()),p169q_selection(book,cached,missing(),missing()))),
   p167c_row("cache-complete-retry-scan",p169qc_scan_equal(
     p168_scalars(book,plans,[],[],[],[]),p169q_scalars(book,cached,[],[],[],[])))]
