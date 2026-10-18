# Test-only generic operator entry. It uses the exact production template
# builders, then transfers the second owned result to checked context scratch.
# There is no source function name, loop or algorithm substitution here.
def nx110rt_probe_name(+cid: U32, +index: U32) -> String:
  "ir_probe_c" ++ U32.show(cid) ++ "_k" ++ U32.show(index)

@unsafe
def nx110rt_probe_function(+cid: U32, +index: U32, +view: String) -> NxFunction:
  NxFunction{nx110rt_probe_name(cid,index),[NxParam{"ctx",NxPtr{}},NxParam{"p0",NxU64{}},NxParam{"p1",NxU64{}}],NxU64{},
    nxo_join(NxParam,[NxParam{"built",NxU64{}},NxParam{"remaining",NxU64{}}],nx110rt_locals()),
    nxo_join(NxStmt,[NxSet{"ir_heap",NxCall{"rt_ir_heap",[NxVar{"ctx"}]}},NxSet{"ir_alc",NxCall{"rt_ir_alc",[NxVar{"ctx"}]}}],
      nxo_join(NxStmt,nx110rt_classify("p0",view),
        [NxIf{NxVar{"ir_ok"},Con{NxSet{"ir_tail",NxVar{"p1"}},nx110rt_rebuild_fast("built","remaining",cid,index)},
          [NxSet{"built",NxCall{nxo110_rebuild_name(cid,index),[NxVar{"ctx"},NxVar{"p0"},NxVar{"p1"}]}},NxSet{"remaining",NxCall{"rt_fast_field",[NxVar{"ctx"},NxConst{NxU32{},0}]}}]},
         NxSet{"ir_status",NxCall{"rt_ir_probe_transfer",[NxVar{"ctx"},NxVar{"remaining"}]}},NxReturn{NxVar{"built"}}]))}

@unsafe
def nx110rt_probe_machine(+view: String) -> NxLibrary:
  NxLibrary{Con{NxImport{"rt_ir_probe_transfer",[NxParam{"ctx",NxPtr{}},NxParam{"remaining",NxU64{}}],NxU32{}},nx110rt_imports()},
    [nx110rt_probe_function(1,0,view),nx110rt_probe_function(1,1,view),nx110rt_probe_function(3,0,view)],
    [nx110rt_probe_name(1,0),nx110rt_probe_name(1,1),nx110rt_probe_name(3,0)]}

@unsafe
def nx110rt_probe_qbe(+view: String) -> String:
  nx_choose(String,nx110rt_view_valid(view) && nx110rt_machine_ok(nx110rt_probe_machine(view)),u => nxlib_qbe_verified(nx110rt_probe_machine(view)),u => "INVALID_RUNTIME_PROBE\n")

@unsafe
def nx110rt_probe_c(+view: String) -> String:
  nx_choose(String,nx110rt_view_valid(view) && nx110rt_machine_ok(nx110rt_probe_machine(view)),u => nx110rt_c_machine(nx110rt_probe_machine(view)),u => "#error INVALID_RUNTIME_PROBE\n")
