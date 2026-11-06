# Pure finite admission/output controls. No malformed runtime body is executed.
# The reference is the original private gate followed by its old renderer gate.

@unsafe
def p169svc_reference(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    +program: P113DProgram) -> P169Prepared:
  p169s_verified(program,adapters,p167ob_final(book,bangs,adapters,program))

@unsafe
def p169svc_emissions(a: P111Emission, b: P111Emission, +success: Bool) -> Bool:
  match a b:
    case P111Emission{+left,+error} P111Emission{right,other}:
      String.eq(error,other) && U32.is_eq(Bool.to_u32(String.is_empty(error)),Bool.to_u32(success)) &&
        p134v_list(~String,~String.eq,left,right) &&
        (success || List.is_empty(&2,String,left))
    case _ _: False{}

@unsafe
def p169svc_case(+program: P113DProgram, +adapters: KDef, success: Bool) -> Bool:
  p169svc_emissions(p169s_collect(p169sv_prepare(p167c_book(),[],adapters,program)),
    p169s_collect(p169svc_reference(p167c_book(),[],adapters,program)),success)

def p169svc_generic() -> N111Segment:
  N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]}

def p169svc_worker(name: String, public: Bool, body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,[],1,public,body}

@unsafe
def p169svc_reject(worker: P113DFunction) -> Bool:
  p169svc_case(p167c_program([p167c_segment()],[worker],[],[]),p167c_adapters(),False{})

@unsafe
def p169svc_error(prepared: P169Prepared, expected: String) -> Bool:
  match prepared:
    case P169Prepared{Nil{},P134End{},error}: String.eq(error,expected)
    case _: False{}

# A real dependency is checked in both private and stricter public forms. Its
# actual original header supplies the public ABI; no invented success is passed.
@unsafe
def p169svc_public_dependency(+public: Bool) -> Bool:
  +original : P111Program = P111Program{[
    p169svc_generic(),N111Segment{"helper",0,1,0,0,[N111Return{N111Const{9,0}}]}],[],[0],[],[],True{}}
  String.is_empty(p118b_verify_functions([
    p169svc_worker("helper",public,[P113DResult{[N111Const{9,0}]}]),
    p169svc_worker("main",False{},[
      P113DCall{["answer"],"helper",[]},P113DResult{[N111Local{"answer"}]}])],original))

@unsafe
def p169svc_public_abi_refused() -> Bool:
  +original : P111Program = P111Program{[
    N111Segment{"main",1,1,0,0,[N111Return{N111Const{7,0}}]}],[],[0],[],[],True{}}
  Bool.not(String.is_empty(p118b_verify_functions([
    p169svc_worker("main",True{},[P113DResult{[N111Const{7,0}]}])],original)))

@unsafe
def p169sv_controls() -> List<&2,String>:
  +bad : P113DFunction = p169svc_worker("main",False{},[P113DResult{[N111Local{"missing"}]}])
  +request : NR_Request = NR_Request{p167c_book(),p167c_book(),["main"],[],[],None{}}
  [p167c_row("single-verify-valid-generic-complete-output",p169svc_case(
     p167c_program([p169svc_generic()],[],[],[]),missing(),True{})),
   p167c_row("single-verify-valid-adapter-complete-output",p169svc_case(
     p167c_program([p167c_segment()],[p167c_worker()],[],[]),p167c_adapters(),True{})),
   p167c_row("single-verify-valid-private-complete-output",p169svc_case(
     p167c_program([p169svc_generic()],[p169svc_worker("helper",False{},[P113DResult{[N111Const{9,0}]}])],[],[]),missing(),True{})),
   p167c_row("single-verify-private-dependency",p169svc_public_dependency(False{})),
   p167c_row("single-verify-public-dependency",p169svc_public_dependency(True{})),
   p167c_row("single-verify-public-ABI-refused",p169svc_public_abi_refused()),
   p167c_row("single-verify-undefined-local-old-error",p169svc_reject(bad)),
   p167c_row("single-verify-unknown-call-old-error",p169svc_reject(p169svc_worker("main",False{},[
     P113DCall{["answer"],"missing",[]},P113DResult{[N111Local{"answer"}]}]))),
   p167c_row("single-verify-missing-terminal-old-error",p169svc_reject(p169svc_worker("main",False{},[]))),
   p167c_row("single-verify-public-input-old-error",p169svc_reject(
     p169svc_worker("main",True{},[P113DResult{[N111Const{7,0}]}]))),
   p167c_row("single-verify-nonadapter-public-refused",p169svc_case(p167c_program(
     [p169svc_generic()],[p169svc_worker("helper",True{},[P113DResult{[N111Const{9,0}]}])],[],[]),missing(),False{})),
   p167c_row("single-verify-header-before-body-error",p169svc_case(
     p167c_program([],[bad],[],[]),p167c_adapters(),False{})),
   p167c_row("single-verify-adapter-arity-old-error",p169svc_case(
     p167c_program([p167c_segment()],[p167c_worker()],[],[]),p164a_put(missing(),"main","main",1),False{})),
   p167c_row("single-verify-error-prefers-original",p169svc_error(p169sv_refused("view","original"),
     "adapter renderer original final IR: original")),
   p167c_row("single-verify-view-error-if-original-passed",p169svc_error(p169sv_refused("view",""),
     "adapter imports view verification: view")),
   p167c_row("single-verify-lowering-error-emits-nothing",p169svc_error(p169s_lowered(request,
     P167Lowered{p167c_program([],[],[],[]),missing(),"lowering",[]}),"adapter renderer lowering: lowering"))]
