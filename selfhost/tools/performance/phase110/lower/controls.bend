# Additive policy shape controls. Runtime lifetime witnesses are separate.
@unsafe
def nxo110_available(+ops: List<&2,NxoOp>) -> Bool:
  nxo_p_available_result(nxo110_try_fusion(ops,"specialized"))

@unsafe
def nxo110_error(+result: NxoResult) -> Bool:
  match result:
    case NxoResult{function,ownership,error}: Bool.not(String.eq(error,""))

@unsafe
def nxo110_policy_report() -> String:
  nxo_p_case("v2_tagged_policy",nxlib_runtime110_policy_valid("tagged"),True{}) ++
  nxo_p_case("v2_specialized_policy",nxlib_runtime110_policy_valid("specialized"),True{}) ++
  nxo_p_case("v2_reject_unknown_policy",nxlib_runtime110_policy_valid("unknown"),False{}) ++
  nxo_p_case("v2_reject_raw_policy",nxlib_runtime110_policy_valid("raw"),False{}) ++
  nxo_p_case("v2_head_fusion",nxo110_available(nxo_p_fixture("v0","p1",["v1","v2"])),True{}) ++
  nxo_p_case("v2_tail_fusion",nxo110_available(nxo_p_fixture("v1","p1",["v0","v2"])),True{}) ++
  nxo_p_case("v2_permuted_tail",nxo110_available(nxo_p_fixture("v0","p1",["v2","v1"])),True{}) ++
  nxo_p_case("v2_reject_external_alias",nxo110_available(nxo_p_fixture("v0","v1",["v1","v2"])),False{}) ++
  nxo_p_case("v2_reject_dropped_result",nxo110_available(nxo_p_fixture("v0","p1",["v1","v1"])),False{}) ++
  nxo_p_case("v2_reject_intervening_effect",nxo110_available([NxoTake{"p0",["v0","v1"]},NxoKeep{"v0"},NxoBuild{"v2",1,["v0","p1"]},NxoTail{["v1","v2"]}]),False{}) ++
  nxo_p_case("v2_tagged_removes_id_call",U32.is_eq(nxo_p_calls(nxo110_ops(nxo_p_chain(),"tagged",""),"rt_fast_id"),0),True{}) ++
  nxo_p_case("v2_tagged_retains_generic_rebuild",U32.is_eq(nxo_p_calls(nxo110_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"tagged",""),"rt_rebuild2"),1),True{}) ++
  nxo_p_case("v2_specialized_removes_generic_rebuild",U32.is_eq(nxo_p_calls(nxo110_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"specialized",""),"rt_rebuild2"),0),True{}) ++
  nxo_p_case("v2_specialized_keeps_first",U32.is_eq(nxo_p_calls(nxo110_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"specialized",""),"rt_rebuild2_c1_k0"),1),True{}) ++
  nxo_p_case("v2_specialized_keeps_second",U32.is_eq(nxo_p_calls(nxo110_ops(nxo_p_fixture("v1","p1",["v0","v2"]),"specialized",""),"rt_rebuild2_c1_k1"),1),True{}) ++
  nxo_p_case("v2_specialized_transfers_remaining",U32.is_eq(nxo_p_calls(nxo110_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"specialized",""),"rt_fast_field"),1),True{}) ++
  nxo_p_case("v2_tagged_machine_valid",nxlib_verify(NxLibrary{nxlib_runtime110_imports_policy("tagged"),[nxo110_function("v2_worker",2,3,nxo_p_fixture("v0","p1",["v1","v2"]),"tagged")],["v2_worker"]}),True{}) ++
  nxo_p_case("v2_specialized_machine_valid",nxlib_verify(NxLibrary{nxlib_runtime110_imports_policy("specialized"),[nxo110_function("v2_worker",2,3,nxo_p_fixture("v0","p1",["v1","v2"]),"specialized")],["v2_worker"]}),True{}) ++
  nxo_p_case("v2_branch_machine_valid",nxlib_verify(NxLibrary{nxlib_runtime110_imports_policy("tagged"),[nxo110_function("v2_worker",1,0,nxo_p_chain(),"tagged")],["v2_worker"]}),True{}) ++
  nxo_p_case("v2_unknown_policy_refuses_before_codegen",nxo110_error(nxo110_finish("v2_worker",1,NxoCode{[NxoReturn{"p0"}],0,""},"unknown")),True{}) ++
  nxo_p_case("v2_owned_graph_refuses_before_codegen",nxo110_error(nxo110_finish("v2_worker",2,NxoCode{[NxoReturn{"p0"}],0,""},"specialized")),True{})
