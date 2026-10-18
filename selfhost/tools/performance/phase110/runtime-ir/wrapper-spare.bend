# A private owning class0 spare, scoped to one admitted reconstruction. It is
# created only from the consumed wrapper of a count1 dynamic parent, after both
# child owners have been loaded. Zero means no spare. Nonzero is exclusive and
# cannot escape: it becomes the external field's RFC wrapper, then is cleared.
# No allocator class, representation, public ABI or source operation is added.

def nx110rtw_raw_constructor(+word: String) -> NxExpr:
  NxBin{"eq",NxBin{"lshr",NxVar{word},nx110rt_u(56)},nx110rt_u(2)}

def nx110rtw_reserve() -> List<&2,NxStmt>:
  [NxSet{"ir_spare",nx110rt_u(0)},
   NxIf{NxBin{"eq",NxVar{"ir_rfc"},nx110rt_u(1)},
     [NxIf{nx110rtw_raw_constructor("ir_tail"),
       [NxSet{"ir_spare",NxVar{"ir_loc"}}],nx110rt_free_wrapper()}],[]}]

# The same rfc_wrap cell and Term encoding as production, but the exclusive
# consumed wrapper supplies the storage. Raw static CTRs must also be wrapped.
@unsafe
def nx110rtw_seal_spare(+word: String) -> List<&2,NxStmt>:
  [NxStore{NxU64{},nx110rt_addr(NxVar{"ir_spare"}),0,
     NxBin{"or",NxBin{"shl",nx110rt_loc(NxVar{word}),nx110rt_u(24)},nx110rt_u(1)}},
   NxSet{word,NxBin{"or",NxBin{"or",
     NxBin{"shl",NxBin{"lshr",NxVar{word},nx110rt_u(40)},nx110rt_u(40)},
     NxBin{"shl",nx110rt_u(1),nx110rt_u(63)}},NxVar{"ir_spare"}}},
   NxSet{"ir_spare",nx110rt_u(0)}]

@unsafe
def nx110rtw_rebuild_fast(+dest: String, +remaining: String, +cid: U32, +index: U32) -> List<&2,NxStmt>:
  nxo_join(NxStmt,
    [NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}},
     NxSet{"ir_old1",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8}},
     NxSet{"ir_head",NxVar{nx_choose(String,U32.is_eq(index,0),u => "ir_old0",u => "ir_old1")}},
     NxSet{remaining,NxVar{nx_choose(String,U32.is_eq(index,0),u => "ir_old1",u => "ir_old0")}}],
    nxo_join(NxStmt,nx110rtw_reserve(),
      nxo_join(NxStmt,nx110rt_seal("ir_head"),
        [NxIf{NxBin{"eq",NxVar{"ir_spare"},nx110rt_u(0)},
           nx110rt_seal("ir_tail"),nx110rtw_seal_spare("ir_tail")},
         NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0,NxVar{"ir_head"}},
         NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8,NxVar{"ir_tail"}},
         NxSet{dest,NxBin{"or",NxBin{"or",NxBin{"shl",nx110rt_u(2),nx110rt_u(56)},NxBin{"shl",nx110rt_u(cid),nx110rt_u(40)}},NxVar{"ir_src"}}} ])))
