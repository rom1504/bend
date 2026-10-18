def nx110rtg_control_take() -> List<&2,NxoOp>:
  [NxoBranch{"p0",1,[NxoTake{"p0",["v0","v1"]},NxoSink{"v0"},NxoReturn{"v1"}],[NxoFail{1}]}]

def nx110rtg_control_suffix() -> List<&2,NxoOp>:
  [NxoBranch{"p0",1,[NxoTake{"p0",["v0","v1"]},NxoBuild{"v2",1,["v0","p1"]},NxoSink{"v1"},NxoReturn{"v2"}],[NxoFail{1}]}]

@unsafe
def nx110rtg_control_worker(+arity: U32, +next: U32, +body: List<&2,NxoOp>) -> Nx110RtWorker:
  Nx110RtWorker{"ir_general",arity,next,body,"single",nx110rt_function("ir_general",arity,next,body,"single")}

@unsafe
def nx110rtg_control_report() -> String:
  nxlib_control_result("runtime-take-original-ownership",nxo_verify(nx110rtg_control_take(),1)) ++
  nxlib_control_result("runtime-suffix-original-ownership",nxo_verify(nx110rtg_control_suffix(),2)) ++
  nxlib_control_result("runtime-take-certified-machine",nx110rt_verify(Nx110RtLibrary{[nx110rtg_control_worker(1,2,nx110rtg_control_take())],["ir_general"]})) ++
  nxlib_control_result("runtime-suffix-certified-machine",nx110rt_verify(Nx110RtLibrary{[nx110rtg_control_worker(2,3,nx110rtg_control_suffix())],["ir_general"]})) ++
  nxlib_control_result("runtime-suffix-fuses-without-tail",U32.is_eq(nxo_p_calls(nx110rtg_ops(nx110rtg_control_suffix(),"single",""),"rt_rebuild2_c1_k0"),1)) ++
  nxlib_control_result("runtime-suffix-removes-separate-build",U32.is_eq(nxo_p_calls(nx110rtg_ops(nx110rtg_control_suffix(),"single",""),"rt_fast_build2"),0)) ++
  nxlib_control_result("runtime-take-keeps-shared-static-fallback",U32.is_eq(nxo_p_calls(nx110rtg_ops(nx110rtg_control_take(),"single",""),"rt_fast_take2"),1)) ++
  nxlib_control_result("runtime-take-has-class1-handoff",U32.is_eq(nxo_p_calls(nx110rtg_ops(nx110rtg_control_take(),"single",""),"rt_ir_hand1"),1)) ++
  nxlib_control_result("runtime-suffix-reject-other-parent",Bool.not(nx110rtg_fusion_shape("p0","v0","v1","v2",1,"v0","p0"))) ++
  nxlib_control_result("runtime-suffix-reject-other-child",Bool.not(nx110rtg_fusion_shape("p0","v0","v1","v2",1,"v0","v1"))) ++
  nxlib_control_result("runtime-suffix-reject-destination-alias",Bool.not(nx110rtg_fusion_shape("p0","v0","v1","p1",1,"v0","p1"))) ++
  nxlib_control_result("runtime-suffix-reject-nullary",Bool.not(nx110rtg_fusion_shape("p0","v0","v1","v2",0,"v0","p1"))) ++
  nxlib_control_result("runtime-suffix-no-effect-crossing",U32.is_eq(nxo_p_calls(nx110rtg_ops([NxoTake{"p0",["v0","v1"]},NxoKeep{"v1"},NxoBuild{"v2",1,["v0","p1"]},NxoTail{["v1","v2"]}],"single",""),"rt_rebuild2_c1_k0"),0)) ++
  nxlib_control_result("runtime-suffix-kept-escape-rejected",Bool.not(nxo_verify([NxoBranch{"p0",1,[NxoTake{"p0",["v0","v1"]},NxoBuild{"v2",1,["v0","p1"]},NxoSink{"v1"},NxoSink{"v2"},NxoReturn{"v0"}],[NxoFail{1}]}],2)))
