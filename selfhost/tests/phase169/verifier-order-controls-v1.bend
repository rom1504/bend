# Supplemental private-boundary controls; no generated malformed code runs.
# Some views deliberately promote a header-incompatible private worker. The
# normal authenticated adapter producer cannot do that; these stronger inputs
# discriminate the cold fallback's error precedence, not source admission.

def p169svo_good() -> List<&2,P113DStmt>:
  [P113DResult{[N111Const{7,0}]}]

def p169svo_bad_body() -> List<&2,P113DStmt>:
  [P113DResult{[N111Local{"undefined"}]}]

def p169svo_bad_projection() -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{"borrowed",N111U64{},"p118_rt_borrow_fields",[
    N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U64{},N111Const{0,0}},
    N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111CtorId{"Unknown"}},
    N111Arg{N111U32{},N111Const{2,0}}]}},P113DResult{[N111Const{7,0}]}]

@unsafe
def p169svo_original(+id: U32) -> P111Program:
  P111Program{[p169svc_generic(),N111Segment{"helper",
    nt_choose(U32,U32.is_eq(id,0) || U32.is_eq(id,2) || U32.is_eq(id,3),u => 1,u => 0),1,0,0,
    [N111Return{N111Const{7,0}}]}],[],[0],[],[],True{}}

@unsafe
def p169svo_functions(+id: U32) -> List<&2,P113DFunction>:
  nt_choose(List<&2,P113DFunction>,U32.is_eq(id,1),
    u => [p169svc_worker("main",False{},p169svo_bad_body()),
      p169svc_worker("helper",False{},p169svo_bad_projection())],u =>
  nt_choose(List<&2,P113DFunction>,U32.is_eq(id,2),
    u => [p169svc_worker("helper",False{},p169svo_good()),
      p169svc_worker("main",False{},p169svo_bad_projection())],u =>
  nt_choose(List<&2,P113DFunction>,U32.is_eq(id,5),
    u => [p169svc_worker("main",False{},[
      P113DCall{["answer"],"helper",[]},P113DResult{[N111Local{"answer"}]}]),
      p169svc_worker("helper",False{},p169svo_good())],u =>
    [p169svc_worker("helper",U32.is_eq(id,4),p169svo_good()),
     p169svc_worker("main",False{},nt_choose(List<&2,P113DStmt>,U32.is_eq(id,0),
       v => p169svo_bad_body(),v => p169svo_good()))])))

# Exact flag-only copy: body/name/parameters/result/order are retained.
@unsafe
def p169svo_view(functions: List<&2,P113DFunction>, +reset: Bool) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{+name,params,result,public,body},rest}:
      Con{P113DFunction{name,params,result,Bool.not(reset) && String.eq(name,"helper"),body},
        p169svo_view(rest,reset)}

def p169svo_format(generic_error: String, original_error: String, view_error: String,
    prepared: P169Prepared) -> List<&2,String>:
  match prepared:
    case P169Prepared{Nil{},P134End{},error}: [generic_error,original_error,view_error,error,"empty"]
    case P169Prepared{chunks,cursor,error}: [generic_error,original_error,view_error,error,"NONEMPTY"]

@unsafe
def p169svo_observe(+id: U32) -> List<&2,String>:
  +original = p169svo_original(id)
  +functions = p169svo_functions(id)
  +program : P113DProgram = P113DProgram{P112StaticProgram{original,[]},functions}
  +view = p169svo_view(functions,U32.is_eq(id,4))
  +view_error = p118b_verify_functions(view,original)
  p169svo_format(p167v_original(p167c_book(),[],program,missing()),
    p167ob_final(p167c_book(),[],missing(),program),view_error,
    nt_choose(P169Prepared,U32.is_eq(id,4),
      u => p169sv_prepare(p167c_book(),[],missing(),program),
      u => p169sv_checked(p167c_book(),[],missing(),program,original,[],view,view_error)))

@unsafe
def p169svo_rows() -> List<&2,List<&2,String>>:
  [p169svo_observe(0),p169svo_observe(1),p169svo_observe(2),
   p169svo_observe(3),p169svo_observe(4),p169svo_observe(5)]

@unsafe
def p169svo_expected(+id: U32) -> List<&2,String>:
  +body = "direct terminal vector has wrong arity/type or undefined value"
  +abi = "public direct wrapper does not preserve original scalar ABI"
  +projection = "borrowed import: constructor/count contract"
  +private = "observer first final worker must be private"
  +forward = "unknown/cyclic direct call or argument/result mismatch: helper"
  +prefix = "adapter renderer original final IR: "
  nt_choose(List<&2,String>,U32.is_eq(id,0),u => ["",body,abi,prefix ++ body,"empty"],u =>
  nt_choose(List<&2,String>,U32.is_eq(id,1) || U32.is_eq(id,2),
    u => ["",projection,projection,prefix ++ projection,"empty"],u =>
  nt_choose(List<&2,String>,U32.is_eq(id,3),u => ["","",abi,"adapter imports view verification: " ++ abi,"empty"],u =>
  nt_choose(List<&2,String>,U32.is_eq(id,4),u => ["",private,"",prefix ++ private,"empty"],
    u => ["",forward,forward,prefix ++ forward,"empty"]))))

@unsafe
def p169svo_case(+id: U32, name: String) -> String:
  p167c_row(name,p134v_list(~String,~String.eq,p169svo_observe(id),p169svo_expected(id)))

@unsafe
def p169svo_controls() -> List<&2,String>:
  [p169svo_case(0,"order-early-view-ABI-later-original-body"),
   p169svo_case(1,"order-later-projection-before-earlier-body"),
   p169svo_case(2,"order-later-projection-before-earlier-view-ABI"),
   p169svo_case(3,"order-view-ABI-only"),
   p169svo_case(4,"order-private-input-before-view-reset"),
   p169svo_case(5,"order-public-forward-callee-still-refused")]
