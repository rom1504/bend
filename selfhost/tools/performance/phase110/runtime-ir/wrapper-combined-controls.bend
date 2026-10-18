# Shared structural controls for exact combined and delayed-load overrides.
# The selected variant and dynamic-writer/frame premises are source-authenticated.
@unsafe
def nx110rtc_control_report() -> String:
  nxlib_control_result("combined-single-certified",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})) ++
  nxlib_control_result("combined-atomic-certified",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("atomic")],["ir_worker"]})) ++
  nxlib_control_result("combined-public-memory-closed",Bool.not(nxlib_verify(nx110rt_machine(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})))) ++
  nxlib_control_result("combined-reject-forged-machine",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_control_corrupt(nx110rt_control_worker("single"))],["ir_worker"]}))) ++
  nxlib_control_result("combined-one-external-seal-allocation",U32.is_eq(nxo_p_calls(nx110rt_rebuild_fast("v2","v1",1,0),"rt_ir_alloc0"),1)) ++
  nxlib_control_result("combined-release-unused-spare",U32.is_eq(nxo_p_calls(nx110rtw_reserve(),"rt_ir_hand0"),1)) ++
  nxlib_control_result("combined-spare-consumption-no-allocation",U32.is_eq(nxo_p_calls(nx110rtw_seal_spare("ir_tail"),"rt_ir_alloc0"),0)) ++
  nxlib_control_result("combined-preserves-shared-static-fallback",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_rebuild2_c1_k0"),1)) ++
  nxlib_control_result("combined-preserves-remaining-transfer",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_fast_field"),1)) ++
  nxlib_control_result("combined-namespace-rejects-spare-owner",Bool.not(nx110rtn_check([NxoReturn{"ir_spare"}],1,1)))
