# U32 offsets retain their zero extension; U64 offsets preserve their full
# width. No pointer/offset expression is admitted to the public opaque slice.
def nx110rt_width_env() -> List<&2,NxParam>:
  [NxParam{"ptr",NxPtr{}},NxParam{"wide",NxU64{}},NxParam{"narrow",NxU32{}}]

@unsafe
def nx110rt_width_report() -> String:
  nxlib_control_result("runtime-offset-u32",nx_type_equal(nx_expr_type(NxOffset{NxVar{"ptr"},NxVar{"narrow"}},nx110rt_width_env(),[]),NxPtr{})) ++
  nxlib_control_result("runtime-offset-u64",nx_type_equal(nx_expr_type(NxOffset{NxVar{"ptr"},NxVar{"wide"}},nx110rt_width_env(),[]),NxPtr{})) ++
  nxlib_control_result("runtime-offset-reject-pointer-bytes",Bool.not(nx_type_equal(nx_expr_type(NxOffset{NxVar{"ptr"},NxVar{"ptr"}},nx110rt_width_env(),[]),NxPtr{}))) ++
  nxlib_control_result("runtime-offset-reject-integer-base",Bool.not(nx_type_equal(nx_expr_type(NxOffset{NxVar{"wide"},NxVar{"narrow"}},nx110rt_width_env(),[]),NxPtr{}))) ++
  nxlib_control_result("runtime-offset-public-memory-refusal",Bool.not(nxlib_expr_ok(NxOffset{NxVar{"ptr"},NxVar{"wide"}})))
