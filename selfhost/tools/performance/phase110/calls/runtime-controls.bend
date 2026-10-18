# Synthetic closure controls. Source admission is qualified separately against
# the frozen checked nt_append/nt_reverse declarations and graph harnesses.
@unsafe
def nx110rt_call_control_worker(+name: String, +arity: U32, +next: U32, +ops: List<&2,NxoOp>) -> Nx110RtWorker:
  Nx110RtWorker{name,arity,next,ops,"single",nx110rt_function(name,arity,next,ops,"single")}

def nx110rt_call_control_ok(result: Nx110RtLibraryResult) -> Bool:
  match result:
    case Nx110RtLibraryResult{library,error}: String.eq(error,"")

@unsafe
def nx110rt_call_control_source(name: String, sources: List<&2,NxcSource>, exports: List<&2,String>, view: String, expected: Bool) -> String:
  nxlib_control_result(name,U32.is_eq(nx_bool32(nx110rt_call_control_ok(nx110rt_lower_library(sources,nxc_control_ctors(),exports,view))),nx_bool32(expected)))

@unsafe
def nx110rt_call_control_report() -> String:
  +identity = nxc_control_identity("identity","identity")
  +caller = nxc_control_caller(nxc_control_call("identity"))
  +nested = nxc_control_caller(nxc_control_app(nxc_control_ref("identity"),nxc_control_call("identity")))
  +worker = nx110rt_call_control_worker("identity",1,0,[NxoReturn{"p0"}])
  +invoke = nx110rt_call_control_worker("caller",1,1,[NxoCall{"v0","identity",["p0"]},NxoReturn{"v0"}])
  +keep = nx110rt_call_control_worker("caller",1,1,[NxoCall{"v0","rt_fast_keep",["p0"]},NxoReturn{"v0"}])
  nx110rt_call_control_source("runtime-call-source-closed",[caller,identity],["caller"],"single",True{}) ++
  nx110rt_call_control_source("runtime-call-source-atomic",[caller,identity],["caller"],"atomic",True{}) ++
  nx110rt_call_control_source("runtime-call-source-nested",[nested,identity],["caller"],"single",True{}) ++
  nx110rt_call_control_source("runtime-call-source-missing",[caller],["caller"],"single",False{}) ++
  nx110rt_call_control_source("runtime-call-source-duplicate",[caller,identity,identity],["caller"],"single",False{}) ++
  nx110rt_call_control_source("runtime-call-source-unknown-view",[caller,identity],["caller"],"unknown",False{}) ++
  nx110rt_call_control_source("runtime-call-source-unknown-export",[caller,identity],["absent"],"single",False{}) ++
  nxlib_control_result("runtime-call-direct-closed",nx110rt_verify(Nx110RtLibrary{[invoke,worker],["caller"]})) ++
  nxlib_control_result("runtime-call-direct-missing",Bool.not(nx110rt_verify(Nx110RtLibrary{[invoke],["caller"]}))) ++
  nxlib_control_result("runtime-call-import-has-machine-signature",nx110rt_machine_ok(nx110rt_machine(Nx110RtLibrary{[keep],["caller"]}))) ++
  nxlib_control_result("runtime-call-import-has-credits",nx110rt_workers_ok([keep])) ++
  nxlib_control_result("runtime-call-import-rejected",Bool.not(nx110rt_verify(Nx110RtLibrary{[keep],["caller"]}))) ++
  nxlib_control_result("runtime-call-arity-rejected",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_call_control_worker("caller",2,1,[NxoCall{"v0","identity",["p0","p1"]},NxoReturn{"v0"}]),worker],["caller"]}))) ++
  nxlib_control_result("runtime-call-credit-rejected",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_call_control_worker("caller",1,2,[NxoCall{"v0","identity",["p0"]},NxoCall{"v1","identity",["p0"]},NxoSink{"v0"},NxoReturn{"v1"}]),worker],["caller"]}))) ++
  nxlib_control_result("runtime-call-branch-import-rejected",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_call_control_worker("caller",1,1,[NxoBranch{"p0",0,[NxoCall{"v0","rt_fast_keep",["p0"]},NxoReturn{"v0"}],[NxoReturn{"p0"}]}])],["caller"]})))
