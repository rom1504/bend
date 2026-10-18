# Optional compact predicate variant; same ownership and fallback semantics.

def nx110rt_dynamic(+loc: NxExpr) -> NxExpr:
  NxBin{"ult",nx110rt_u(51413375),loc}

@unsafe
def nx110rt_seal(+word: String) -> List<&2,NxStmt>:
  [NxIf{NxBin{"eq",NxBin{"lshr",NxVar{word},nx110rt_u(56)},nx110rt_u(2)},
    nxo_join(NxStmt,nx110rt_alloc_wrapper(),
      [NxStore{NxU64{},nx110rt_addr(NxVar{"ir_wrap"}),0,NxBin{"or",NxBin{"shl",nx110rt_loc(NxVar{word}),nx110rt_u(24)},nx110rt_u(1)}},
       NxSet{word,NxBin{"or",NxBin{"or",NxBin{"shl",NxBin{"lshr",NxVar{word},nx110rt_u(40)},nx110rt_u(40)},NxBin{"shl",nx110rt_u(1),nx110rt_u(63)}},NxVar{"ir_wrap"}}}]),[] }]
