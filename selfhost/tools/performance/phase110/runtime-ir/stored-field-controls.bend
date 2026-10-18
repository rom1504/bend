# Structural controls for the selected exact override. Runtime source closure
# and refusal controls live in stored-field-admit.py; these do not assume an
# arbitrary raw constructor field is safe to omit sealing.
@unsafe
def nx110rts_control_report() -> String:
  nxlib_control_result("stored-field-candidate-exact-certificate",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})) ++
  nxlib_control_result("stored-field-public-memory-still-closed",Bool.not(nxlib_verify(nx110rt_machine(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})))) ++
  nxlib_control_result("stored-field-reject-modified-machine",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rt_control_corrupt(nx110rt_control_worker("single"))],["ir_worker"]}))) ++
  nxlib_control_result("stored-field-one-external-seal-allocation",U32.is_eq(nxo_p_calls(nx110rt_rebuild_fast("v2","v1",1,0),"rt_ir_alloc0"),1)) ++
  nxlib_control_result("stored-field-keeps-wrapper-release",U32.is_eq(nxo_p_calls(nx110rt_rebuild_fast("v2","v1",1,0),"rt_ir_hand0"),1)) ++
  nxlib_control_result("stored-field-preserves-shared-static-fallback",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_rebuild2_c1_k0"),1)) ++
  nxlib_control_result("stored-field-preserves-other-field-transfer",U32.is_eq(nxo_p_calls(nx110rt_control_body(nx110rt_control_worker("single")),"rt_fast_field"),1))
