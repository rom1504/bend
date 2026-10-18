# The adversarial graph is inspected only. Never emit or execute it as a native
# worker: under generic Take2, assigning ir_old1 destroys the second child before
# the following v0 transfer. This witnesses the old credit/type/certificate gap.
def nx110rtn_attack() -> List<&2,NxoOp>:
  [NxoBranch{"p0",1,[NxoTake{"p0",["ir_old1","v0"]},NxoSink{"ir_old1"},NxoReturn{"v0"}],[NxoFail{1}]}]

@unsafe
def nx110rtn_attack_worker() -> Nx110RtWorker:
  Nx110RtWorker{"namespace_attack",1,1,nx110rtn_attack(),"single",nx110rt_function("namespace_attack",1,1,nx110rtn_attack(),"single")}

@unsafe
def nx110rtn_control_report() -> String:
  nxlib_control_result("namespace-prior-credit-check-admits-attack",nxo_verify(nx110rtn_attack(),1)) ++
  nxlib_control_result("namespace-prior-machine-check-admits-attack",nx110rt_machine_ok(nx110rt_machine(Nx110RtLibrary{[nx110rtn_attack_worker()],["namespace_attack"]}))) ++
  nxlib_control_result("namespace-final-certificate-rejects-attack",Bool.not(nx110rt_verify(Nx110RtLibrary{[nx110rtn_attack_worker()],["namespace_attack"]}))) ++
  nxlib_control_result("namespace-authentic-template-accepted",nx110rt_verify(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]})) ++
  nxlib_control_result("namespace-canonical-parameter",nx110rtn_check([NxoReturn{"p0"}],1,0)) ++
  nxlib_control_result("namespace-canonical-generated-word",nx110rtn_check([NxoBuild{"v0",0,[]},NxoReturn{"v0"}],1,1)) ++
  nxlib_control_result("namespace-reject-context",Bool.not(nx110rtn_check([NxoReturn{"ctx"}],1,1))) ++
  nxlib_control_result("namespace-reject-private-source",Bool.not(nx110rtn_check([NxoTake{"p0",["ir_src","v0"]}],1,1))) ++
  nxlib_control_result("namespace-reject-wrapper-spare",Bool.not(nx110rtn_check([NxoBuild{"ir_spare",0,[]}],1,1))) ++
  nxlib_control_result("namespace-reject-tail-temporary",Bool.not(nx110rtn_check([NxoTail{["next0"]}],1,1))) ++
  nxlib_control_result("namespace-reject-tag-temporary",Bool.not(nx110rtn_check([NxoBranch{"tag110",0,[],[]}],1,1))) ++
  nxlib_control_result("namespace-reject-status-temporary",Bool.not(nx110rtn_check([NxoKeep{"status"}],1,1))) ++
  nxlib_control_result("namespace-reject-outside-parameter-count",Bool.not(nx110rtn_check([NxoReturn{"p1"}],1,1))) ++
  nxlib_control_result("namespace-reject-outside-generated-count",Bool.not(nx110rtn_check([NxoReturn{"v1"}],1,1))) ++
  nxlib_control_result("namespace-reject-noncanonical-number",Bool.not(nx110rtn_check([NxoReturn{"v00"}],1,1))) ++
  nxlib_control_result("namespace-reject-call-result-collision",Bool.not(nx110rtn_check([NxoCall{"ir_old1","callee",["p0"]}],1,1))) ++
  nxlib_control_result("namespace-reject-call-argument-collision",Bool.not(nx110rtn_check([NxoCall{"v0","callee",["ir_head"]}],1,1))) ++
  nxlib_control_result("namespace-checks-both-branches",Bool.not(nx110rtn_check([NxoBranch{"p0",0,[NxoReturn{"p0"}],[NxoReturn{"ir_old1"}]}],1,1)))
