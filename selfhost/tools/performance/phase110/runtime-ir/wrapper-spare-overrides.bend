# Exact wrapper-spare private-template overrides.

@unsafe
def nx110rt_rebuild_fast(+dest: String, +remaining: String, +cid: U32, +index: U32) -> List<&2,NxStmt>:
  nx110rtw_rebuild_fast(dest,remaining,cid,index)

def nx110rt_locals() -> List<&2,NxParam>:
  [NxParam{"ir_spare",NxU64{}},NxParam{"ir_heap",NxPtr{}},NxParam{"ir_alc",NxPtr{}},NxParam{"ir_status",NxU32{}},NxParam{"ir_ok",NxU32{}},
   NxParam{"ir_loc",NxU64{}},NxParam{"ir_src",NxU64{}},NxParam{"ir_rfc",NxU64{}},NxParam{"ir_cell",NxU64{}},
   NxParam{"ir_old0",NxU64{}},NxParam{"ir_old1",NxU64{}},NxParam{"ir_head",NxU64{}},NxParam{"ir_tail",NxU64{}},
   NxParam{"ir_free",NxU64{}},NxParam{"ir_len",NxU64{}},NxParam{"ir_wrap",NxU64{}}]
