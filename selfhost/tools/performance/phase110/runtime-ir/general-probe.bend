# Generated Take2 operator probe. The two ownership results use the same
# test-only scratch bridge as reconstruction probes; no worker imports it.
@unsafe
def nx110rtg_probe_function(+view: String) -> NxFunction:
  NxFunction{"ir_probe_take2",[NxParam{"ctx",NxPtr{}},NxParam{"p0",NxU64{}}],NxU64{},
    nxo_join(NxParam,[NxParam{"built",NxU64{}},NxParam{"remaining",NxU64{}},NxParam{"status",NxU32{}}],nx110rt_locals()),
    nxo_join(NxStmt,[NxSet{"ir_heap",NxCall{"rt_ir_heap",[NxVar{"ctx"}]}},NxSet{"ir_alc",NxCall{"rt_ir_alc",[NxVar{"ctx"}]}}],
      nxo_join(NxStmt,nx110rtg_take("p0","built","remaining",view),
        [NxSet{"ir_status",NxCall{"rt_ir_probe_transfer",[NxVar{"ctx"},NxVar{"remaining"}]}},NxReturn{NxVar{"built"}}]))}

@unsafe
def nx110rtg_probe_machine(+view: String) -> NxLibrary:
  NxLibrary{Con{NxImport{"rt_ir_probe_transfer",[NxParam{"ctx",NxPtr{}},NxParam{"remaining",NxU64{}}],NxU32{}},nx110rt_imports()},
    [nx110rtg_probe_function(view)],["ir_probe_take2"]}

@unsafe
def nx110rtg_probe_qbe(+view: String) -> String:
  nx_choose(String,nx110rt_view_valid(view) && nx110rt_machine_ok(nx110rtg_probe_machine(view)),u => nxlib_qbe_verified(nx110rtg_probe_machine(view)),u => "INVALID_RUNTIME_TAKE_PROBE\n")

@unsafe
def nx110rtg_probe_c(+view: String) -> String:
  nx_choose(String,nx110rt_view_valid(view) && nx110rt_machine_ok(nx110rtg_probe_machine(view)),u => nx110rt_c_machine(nx110rtg_probe_machine(view)),u => "#error INVALID_RUNTIME_TAKE_PROBE\n")
