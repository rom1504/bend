# Separate exact override. Requires the authenticated stored-field admission
# receipt; no other sealing or unique/static classification is changed.
@unsafe
def nx110rt_rebuild_fast(+dest: String, +remaining: String, +cid: U32, +index: U32) -> List<&2,NxStmt>:
  nxo_join(NxStmt,
    [NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}},
     NxSet{"ir_old1",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8}},
     NxIf{NxBin{"eq",NxVar{"ir_rfc"},nx110rt_u(1)},nx110rt_free_wrapper(),[]},
     NxSet{"ir_head",NxVar{nx_choose(String,U32.is_eq(index,0),u => "ir_old0",u => "ir_old1")}},
     NxSet{remaining,NxVar{nx_choose(String,U32.is_eq(index,0),u => "ir_old1",u => "ir_old0")}}],
    nxo_join(NxStmt,nx110rt_seal("ir_tail"),
      [NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0,NxVar{"ir_head"}},
       NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8,NxVar{"ir_tail"}},
       NxSet{dest,NxBin{"or",NxBin{"or",NxBin{"shl",nx110rt_u(2),nx110rt_u(56)},NxBin{"shl",nx110rt_u(cid),nx110rt_u(40)}},NxVar{"ir_src"}}} ]))
