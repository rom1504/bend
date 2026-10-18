@unsafe
def nx110rtw_control_report() -> String:
  nxlib_control_result("wrapper-spare-single-certified",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})) ++
  nxlib_control_result("wrapper-spare-atomic-certified",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("atomic")],["ir_worker"]})) ++
  nxlib_control_result("wrapper-spare-public-memory-closed",Bool.not(nxlib_verify(nx110rt_machine(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})))) ++
  nxlib_control_result("wrapper-spare-reject-forged-machine",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_control_corrupt(nx110rt_control_worker("single"))],["ir_worker"]}))) ++
  nxlib_control_result("wrapper-spare-keeps-both-seal-fallbacks",U32.is_eq(nxo_p_calls(nx110rt_rebuild_fast("v2","v1",1,0),"rt_ir_alloc0"),2)) ++
  nxlib_control_result("wrapper-spare-release-if-unused",U32.is_eq(nxo_p_calls(nx110rtw_reserve(),"rt_ir_hand0"),1)) ++
  nxlib_control_result("wrapper-spare-consumption-no-allocation",U32.is_eq(nxo_p_calls(nx110rtw_seal_spare("ir_tail"),"rt_ir_alloc0"),0)) ++
  nxlib_control_result("wrapper-spare-consumption-no-free",U32.is_eq(nxo_p_calls(nx110rtw_seal_spare("ir_tail"),"rt_ir_hand0"),0)) ++
  nxlib_control_result("wrapper-spare-preserves-shared-static-fallback",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_rebuild2_c1_k0"),1)) ++
  nxlib_control_result("wrapper-spare-preserves-remaining-transfer",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_fast_field"),1))
