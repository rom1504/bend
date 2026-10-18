# Synthetic structural/credit controls, not authenticated checked source.
# Real nt_append and call-shape sources have separate frozen source/oracles.
def nxc_control_callees() -> List<&2,NxcCallee>:
  [NxcCallee{"identity","identity",1},NxcCallee{"merge","merge",2}]

@unsafe
def nxc_control_credit(name: String, ops: List<&2,NxoOp>, arity: U32, expected: Bool) -> String:
  nxlib_control_result(name,U32.is_eq(nx_bool32(nxc_verify(ops,arity,nxc_control_callees())),nx_bool32(expected)))

def nxc_control_ctors() -> List<&2,NxoCtor>:
  [NxoCtor{"Nil",0,0},NxoCtor{"Con",1,2},NxoCtor{"SNil",2,0},NxoCtor{"SCon",3,2}]

def nxc_control_var(id: U32) -> KTerm:
  kt("Var","",id,0,[])

def nxc_control_ref(name: String) -> KTerm:
  kt("Ref",name,0,0,[])

def nxc_control_app(fn: KTerm, arg: KTerm) -> KTerm:
  kt("App","",0,0,[fn,arg])

def nxc_control_fact(name: String, arity: U32, body: KTerm) -> KDef:
  KDef{name,"NativeErasedBody",arity,0,atom("Era"),body,[],False{},False{}}

def nxc_control_lam(id: U32, body: KTerm) -> KTerm:
  kt("Lam","x",id,1,[body])

def nxc_control_identity(name: String, symbol: String) -> NxcSource:
  NxcSource{nxc_control_fact(name,1,nxc_control_lam(1,nxc_control_var(1))),symbol}

def nxc_control_caller(body: KTerm) -> NxcSource:
  NxcSource{nxc_control_fact("caller",1,nxc_control_lam(1,body)),"caller"}

def nxc_control_call(name: String) -> KTerm:
  nxc_control_app(nxc_control_ref(name),nxc_control_var(1))

def nxc_control_result_ok(result: NxcLibraryResult) -> Bool:
  match result:
    case NxcLibraryResult{library,ownership,error}: String.eq(error,"")

@unsafe
def nxc_control_library(name: String, sources: List<&2,NxcSource>, exports: List<&2,String>, policy: String, expected: Bool) -> String:
  nxlib_control_result(name,U32.is_eq(nx_bool32(nxc_control_result_ok(nxc_lower_library(sources,nxc_control_ctors(),exports,policy))),nx_bool32(expected)))

@unsafe
def nxc_control_report() -> String:
  +identity = nxc_control_identity("identity","identity")
  +caller = nxc_control_caller(nxc_control_call("identity"))
  +nested = nxc_control_caller(nxc_control_app(nxc_control_ref("identity"),nxc_control_call("identity")))
  nxc_control_credit("call-owning-transfer",[NxoCall{"v0","identity",["p0"]},NxoReturn{"v0"}],1,True{}) ++
  nxc_control_credit("call-retained-duplicate",[NxoKeep{"p0"},NxoCall{"v0","merge",["p0","p0"]},NxoReturn{"v0"}],1,True{}) ++
  nxc_control_credit("call-overwrite-consumed-input",[NxoCall{"p0","identity",["p0"]},NxoReturn{"p0"}],1,True{}) ++
  nxc_control_credit("call-duplicate-without-keep",[NxoCall{"v0","merge",["p0","p0"]},NxoReturn{"v0"}],1,False{}) ++
  nxc_control_credit("call-overwrite-live-owner",[NxoCall{"p1","identity",["p0"]},NxoReturn{"p1"}],2,False{}) ++
  nxc_control_credit("call-use-after-consume",[NxoCall{"v0","identity",["p0"]},NxoCall{"v1","identity",["p0"]},NxoSink{"v0"},NxoReturn{"v1"}],1,False{}) ++
  nxc_control_credit("call-result-leak",[NxoCall{"v0","identity",["p0"]},NxoBuild{"v1",0,[]},NxoReturn{"v1"}],1,False{}) ++
  nxc_control_credit("call-result-double-consume",[NxoCall{"v0","identity",["p0"]},NxoSink{"v0"},NxoReturn{"v0"}],1,False{}) ++
  nxc_control_credit("call-missing-argument",[NxoCall{"v0","identity",[]},NxoSink{"p0"},NxoReturn{"v0"}],1,False{}) ++
  nxc_control_credit("call-unknown-callee",[NxoCall{"v0","unknown",["p0"]},NxoReturn{"v0"}],1,False{}) ++
  nxc_control_credit("call-result-not-refined",[NxoSink{"p0"},NxoBuild{"v0",0,[]},NxoCall{"v1","identity",["v0"]},NxoTake{"v1",[]},NxoBuild{"v2",0,[]},NxoReturn{"v2"}],1,False{}) ++
  nxc_control_library("call-closed-library",[caller,identity],["caller"],"specialized",True{}) ++
  nxc_control_library("call-closed-raw-library",[caller,identity],["caller"],"raw",True{}) ++
  nxc_control_library("call-nested-staging",[nested,identity],["caller"],"specialized",True{}) ++
  nxc_control_library("call-missing-definition",[caller],["caller"],"specialized",False{}) ++
  nxc_control_library("call-duplicate-source",[caller,identity,nxc_control_identity("identity","other")],["caller"],"specialized",False{}) ++
  nxc_control_library("call-duplicate-symbol",[caller,identity,nxc_control_identity("other","identity")],["caller"],"specialized",False{}) ++
  nxc_control_library("call-unknown-policy",[caller,identity],["caller"],"unknown",False{}) ++
  nxc_control_library("call-unknown-export",[caller,identity],["absent"],"specialized",False{}) ++
  nxc_control_library("call-duplicate-export",[caller,identity],["caller","caller"],"specialized",False{}) ++
  nxc_control_library("call-no-export",[caller,identity],[],"specialized",False{}) ++
  nxc_control_library("call-invalid-symbol",[caller,nxc_control_identity("identity","bad-name")],["caller"],"specialized",False{}) ++
  nxc_control_library("call-runtime-symbol-collision",[caller,nxc_control_identity("identity","rt_fast_keep")],["caller"],"specialized",False{}) ++
  nxc_control_library("call-dynamic-callee",[nxc_control_caller(nxc_control_app(nxc_control_var(1),kt("Ctr","Nil",0,0,[])))],["caller"],"specialized",False{}) ++
  nxc_control_library("call-partial-value",[nxc_control_caller(nxc_control_ref("identity")),identity],["caller"],"specialized",False{}) ++
  nxc_control_library("call-oversaturated",[nxc_control_caller(nxc_control_app(nxc_control_call("identity"),kt("Ctr","Nil",0,0,[]))),identity],["caller"],"specialized",False{}) ++
  nxlib_control_result("ordinary-call-remains-effectful",Bool.not(nx_pure(NxCall{"identity",[NxVar{"ctx"},NxVar{"p0"}]})))
