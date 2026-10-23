def p128rawc_request() -> NR_Request:
  NR_Request{[],[],[],[],[],None{}}

def p128rawc_original() -> P113AProgram:
  P113AProgram{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},P113ACertificate{False{},False{}}}

@unsafe
def p128rawc_same(left: P111Emission, right: P111Emission) -> Bool:
  match left right:
    case P111Emission{a,ae} P111Emission{b,be}:
      String.eq(ae,be) && String.eq(nt_join(a,""),nt_join(b,""))

@unsafe
def p128rawc_error(lowering: P128RawLowering) -> String:
  match lowering:
    case P128RawLowering{P113DLowered{program,error},raw}: error

@unsafe
def p128rawc_counts(lowering: P128RawLowering, +expected_raw: U32, +expected_functions: U32) -> Bool:
  match lowering:
    case P128RawLowering{P113DLowered{P113DProgram{original,functions},error},raw}:
      String.is_empty(error) && U32.is_eq(nt_count(P113DCandidate,raw),expected_raw) &&
        U32.is_eq(nt_count(P113DFunction,functions),expected_functions)

@unsafe
def p128rawc_text(functions: List<&2,P113DFunction>) -> String:
  nt_join(p113e_private_chunks(functions,N111Ids{missing(),missing()},[]),"")

@unsafe
def p128rawc_late(+caller: P113DCandidate, +helper: P113DFunction, +expected: P113DFunction) -> Bool:
  String.eq(p128rawc_text(p113d_passes([caller],p113e_signatures([helper],missing()),[helper],32)),
    p128rawc_text([helper,expected]))

@unsafe
def p128raw_controls() -> List<&2,String>:
  +request = p128rawc_request()
  +original = p128rawc_original()
  +base : P112SResult = P112SResult{P112StaticProgram{p111_empty(),[]},""}
  +a = p126sc_test_candidate(p126sc_test_function("a","b"))
  +b = p126sc_test_candidate(p126sc_test_function("b","a"))
  +helper : P113DFunction = P113DFunction{"$product.observe",[],1,False{},[P113DResult{[N111Const{17,0}]}]}
  +body : P113DFunction = P113DFunction{"consumer",[],1,False{},[
    P113DCall{["answer"],"$product.observe",[]},P113DResult{[N111Local{"answer"}]}]}
  +caller : P113DCandidate = P113DCandidate{body,"",["$product.observe"]}
  [p126bpc_row("raw-admission-error-exact",p128rawc_same(p128raw_emit_admitted(request,"control"),p111_emit_admitted(request,"control"))),
   p126bpc_row("raw-plan-error-exact",p128rawc_same(p128raw_emit_plan(P86PlanError{"control"}),p111_emit_plan(P86PlanError{"control"}))),
   p126bpc_row("raw-preparation-error-exact",p128rawc_same(
     p128raw_compile_prepared("x","",P86PreparationError{"control"}),
     p111_compile_prepared("x","",P86PreparationError{"control"}))),
   p126bpc_row("raw-static-preparation-error",String.eq(p128rawc_error(p128raw_prepared([],[],P112SPrepared{[],[],"control"})),"control")),
   p126bpc_row("raw-lowering-error-exact",p128rawc_same(
     p128raw_lowered(request,[],P113ALowered{original,"control"}),p118e_lowered(request,P113ALowered{original,"control"}))),
   p126bpc_row("raw-original-verifier-error-exact",p128rawc_same(
     p128raw_verified(request,[],original,"control"),p118e_verified(request,original,"control"))),
   p126bpc_row("raw-pre-scc-candidates-retained",p128rawc_counts(p128raw_plan_finish(base,[a,b]),2,3)),
   p126bpc_row("raw-blocked-candidate-retained",p128rawc_counts(p128raw_plan_finish(base,[caller]),1,0)),
   p126bpc_row("raw-late-dependency-admitted-exact-qbe",p128rawc_late(caller,helper,body)),
   p126bpc_row("raw-error-candidate-retained",p128rawc_counts(p128raw_plan_finish(base,[P113DCandidate{body,"control",[]}]),1,0)),
   p126bpc_row("raw-independent-verifier-refuses-invalid",Bool.not(String.is_empty(
     p113e_functions([P113DFunction{"invalid",[],0,False{},[]}],N111Ids{missing(),missing()},missing()))))]
