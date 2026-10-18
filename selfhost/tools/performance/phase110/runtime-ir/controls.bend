def nx110rt_control_owned() -> List<&2,NxoOp>:
  [NxoBranch{"p0",1,nxo_p_fixture("v0","p1",["v1","v2"]),[NxoFail{1}]}]

@unsafe
def nx110rt_control_worker(+view: String) -> Nx110RtWorker:
  Nx110RtWorker{"ir_worker",2,3,nx110rt_control_owned(),view,nx110rt_function("ir_worker",2,3,nx110rt_control_owned(),view)}

@unsafe
def nx110rt_control_corrupt(+worker: Nx110RtWorker) -> Nx110RtWorker:
  match worker:
    case Nx110RtWorker{name,arity,next,ownership,view,function}:
      Nx110RtWorker{name,arity,next,ownership,view,NxFunction{name,Con{NxParam{"ctx",NxPtr{}},nxo_params("p",0,arity)},NxU64{},[],[NxReturn{NxVar{"p0"}}]}}

@unsafe
def nx110rt_control_code(+worker: Nx110RtWorker) -> NxFunction:
  match worker:
    case Nx110RtWorker{name,arity,next,ownership,view,function}: function

@unsafe
def nx110rt_control_body(+worker: Nx110RtWorker) -> List<&2,NxStmt>:
  nx110rt_control_function_body(nx110rt_control_code(worker))

def nx110rt_control_function_body(function: NxFunction) -> List<&2,NxStmt>:
  match function:
    case NxFunction{name,params,result,locals,body}: body

@unsafe
def nx110rt_control_report() -> String:
  nxlib_control_result("runtime-ir-single-template",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})) ++
  nxlib_control_result("runtime-ir-atomic-template",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("atomic")],["ir_worker"]})) ++
  nxlib_control_result("runtime-ir-reject-unknown-view",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("unknown")],["ir_worker"]}))) ++
  nxlib_control_result("runtime-ir-reject-changed-machine-graph",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_control_corrupt(nx110rt_control_worker("single"))],["ir_worker"]}))) ++
  nxlib_control_result("runtime-ir-public-opaque-boundary-closed",Bool.not(nxlib_verify(nx110rt_machine(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})))) ++
  nxlib_control_result("runtime-ir-entry-checks-heap",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_ir_heap"),1)) ++
  nxlib_control_result("runtime-ir-entry-checks-allocator",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_ir_alc"),1)) ++
  nxlib_control_result("runtime-ir-single-no-view-call",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_ir_view"),0)) ++
  nxlib_control_result("runtime-ir-atomic-keeps-view-call",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("atomic")),"rt_ir_view"),1)) ++
  nxlib_control_result("runtime-ir-retains-specialized-fallback",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_rebuild2_c1_k0"),1)) ++
  nxlib_control_result("runtime-ir-retains-fallback-transfer",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_fast_field"),1)) ++
  nxlib_control_result("runtime-ir-keeps-load-barrier",Bool.not(nx_pure(NxLoad{NxU64{},NxVar{"ir_heap"},0})))
