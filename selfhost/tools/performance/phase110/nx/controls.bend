# Structural mutations and transform boundaries. Runtime/output witnesses are
# separate and must execute both emitted consumers against the actual adapter.
type Nx110Control is Data:
  Nx110Control{+name: String, +library: Nx110Library, +expected: Bool}

def nx110_control_worker(body: List<&2,Nx110Stmt>) -> Nx110Function:
  Nx110Function{"worker",[NxParam{"ctx",NxPtr{}},NxParam{"term",NxU64{}}],NxU64{},
    [NxParam{"first",NxU64{}},NxParam{"second",NxU64{}},NxParam{"status",NxU32{}}],body}

def nx110_control_library(pairs: List<&2,Nx110ImportPair>, body: List<&2,Nx110Stmt>) -> Nx110Library:
  Nx110Library{nxlib_runtime_named("rt_fast_"),pairs,[nx110_control_worker(body)],["worker"]}

def nx110_control_pair(first: String, second: String, name: String, args: List<&2,NxExpr>) -> List<&2,Nx110Stmt>:
  [Nx110CallPair{first,second,name,args},Nx110Scalar{NxReturn{NxVar{"first"}}}]

def nx110_control_args() -> List<&2,NxExpr>:
  [NxVar{"ctx"},NxVar{"term"},NxVar{"term"}]

def nx110_control_body() -> List<&2,Nx110Stmt>:
  nx110_control_pair("first","second","pair",nx110_control_args())

def nx110_control_cases() -> List<&2,Nx110Control>:
  [Nx110Control{"typed-pair",nx110_control_library([nx110_pair_import("pair")],nx110_control_body()),True{}},
   Nx110Control{"scalar-only",nx110_control_library([],[Nx110Scalar{NxReturn{NxVar{"term"}}}]),True{}},
   Nx110Control{"pair-in-branch",nx110_control_library([nx110_pair_import("pair")],[Nx110If{NxConst{NxU32{},1},nx110_control_body(),[Nx110Scalar{NxReturn{NxVar{"term"}}}]}]),True{}},
   Nx110Control{"pair-in-loop",nx110_control_library([nx110_pair_import("pair")],[Nx110While{NxConst{NxU32{},0},[Nx110CallPair{"first","second","pair",nx110_control_args()}]},Nx110Scalar{NxReturn{NxVar{"term"}}}]),True{}},
   Nx110Control{"missing-pair-import",nx110_control_library([],nx110_control_body()),False{}},
   Nx110Control{"duplicate-pair-import",nx110_control_library([nx110_pair_import("pair"),nx110_pair_import("pair")],nx110_control_body()),False{}},
   Nx110Control{"pair-scalar-collision",nx110_control_library([nx110_pair_import("rt_fast_keep")],[Nx110Scalar{NxReturn{NxVar{"term"}}}]),False{}},
   Nx110Control{"pair-definition-collision",nx110_control_library([nx110_pair_import("worker")],[Nx110Scalar{NxReturn{NxVar{"term"}}}]),False{}},
   Nx110Control{"pair-result-width",nx110_control_library([Nx110ImportPair{"pair",[],NxU32{},NxU64{}}],[Nx110Scalar{NxReturn{NxVar{"term"}}}]),False{}},
   Nx110Control{"pair-invalid-result",nx110_control_library([Nx110ImportPair{"pair",[],NxU64{},NxBad{}}],[Nx110Scalar{NxReturn{NxVar{"term"}}}]),False{}},
   Nx110Control{"pair-duplicate-output",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","first","pair",nx110_control_args())),False{}},
   Nx110Control{"pair-output-width",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("status","second","pair",nx110_control_args())),False{}},
   Nx110Control{"pair-missing-output",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("absent","second","pair",nx110_control_args())),False{}},
   Nx110Control{"pair-arity",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","second","pair",[NxVar{"ctx"},NxVar{"term"}])),False{}},
   Nx110Control{"pair-context-width",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","second","pair",[NxVar{"term"},NxVar{"term"},NxVar{"term"}])),False{}},
   Nx110Control{"pair-term-width",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","second","pair",[NxVar{"ctx"},NxConst{NxU32{},0},NxVar{"term"}])),False{}},
   Nx110Control{"pair-nested-effect",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","second","pair",[NxVar{"ctx"},NxCall{"rt_fast_keep",[NxVar{"ctx"},NxVar{"term"}]},NxVar{"term"}])),False{}},
   Nx110Control{"pair-cannot-be-scalar",nx110_control_library([nx110_pair_import("pair")],[Nx110Scalar{NxReturn{NxCall{"pair",nx110_control_args()}}}]),False{}},
   Nx110Control{"pair-no-raw-context-load",nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","second","pair",[NxVar{"ctx"},NxLoad{NxU64{},NxVar{"ctx"},0},NxVar{"term"}])),False{}},
   Nx110Control{"pair-scalar-wrapper-rejects-control",nx110_control_library([],[Nx110Scalar{NxIf{NxConst{NxU32{},1},[NxReturn{NxVar{"term"}}],[NxReturn{NxVar{"term"}}]}}]),False{}},
   Nx110Control{"pair-cannot-be-export",Nx110Library{[],[nx110_pair_import("pair")],[nx110_control_worker([Nx110Scalar{NxReturn{NxVar{"term"}}}])],["pair"]},False{}},
   Nx110Control{"pair-no-fallthrough",nx110_control_library([nx110_pair_import("pair")],[Nx110CallPair{"first","second","pair",nx110_control_args()}]),False{}}]

@unsafe
def nx110_control_report_cases(+cases: List<&2,Nx110Control>) -> String:
  match cases:
    case Nil{}: ""
    case Con{Nx110Control{name,library,expected},rest}:
      nxlib_control_result(name,U32.is_eq(nx_bool32(nx110_verify(library)),nx_bool32(expected))) ++ nx110_control_report_cases(rest)

@unsafe
def nx110_pair_count(+body: List<&2,Nx110Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: U32.add(nx110_pair_count_stmt(head),nx110_pair_count(rest))

@unsafe
def nx110_pair_count_stmt(+stmt: Nx110Stmt) -> U32:
  match stmt:
    case Nx110CallPair{first,second,name,args}: 1
    case Nx110If{condition,yes,no}: U32.add(nx110_pair_count(yes),nx110_pair_count(no))
    case Nx110While{condition,body}: nx110_pair_count(body)
    case _: 0

def nx110_control_rebuild() -> NxStmt:
  NxSet{"first",NxCall{"rt_rebuild2_c1_k0",nx110_control_args()}}

def nx110_control_field(context: String, index: U32, dest: String) -> NxStmt:
  NxSet{dest,NxCall{"rt_fast_field",[NxVar{context},NxConst{NxU32{},index}]}}

@unsafe
def nx110_control_transform(name: String, body: List<&2,NxStmt>, expected: U32) -> String:
  nxlib_control_result(name,U32.is_eq(nx110_pair_count(nx110_pair_body(body)),expected))

@unsafe
def nx110_control_report() -> String:
  nx110_control_report_cases(nx110_control_cases()) ++
  nx110_control_transform("pair-upgrade-adjacent",[nx110_control_rebuild(),nx110_control_field("ctx",0,"second")],1) ++
  nx110_control_transform("pair-upgrade-branch",[NxIf{NxConst{NxU32{},1},[nx110_control_rebuild(),nx110_control_field("ctx",0,"second")],[]}],1) ++
  nx110_control_transform("pair-upgrade-no-effect-crossing",[nx110_control_rebuild(),NxSet{"status",NxCall{"rt_fast_sink",[NxVar{"ctx"},NxVar{"term"}]}},nx110_control_field("ctx",0,"second")],0) ++
  nx110_control_transform("pair-upgrade-exact-field-index",[nx110_control_rebuild(),nx110_control_field("ctx",1,"second")],0) ++
  nx110_control_transform("pair-upgrade-same-context",[nx110_control_rebuild(),nx110_control_field("other_ctx",0,"second")],0) ++
  nx110_control_transform("pair-upgrade-distinct-output",[nx110_control_rebuild(),nx110_control_field("ctx",0,"first")],0) ++
  nxlib_control_result("pair-upgrade-invalid-library",Bool.not(nx110_verify(nx110_pair_library(NxLibrary{[],[],[]}))))
