# Checked scalar-array entry only: U32/F32/Char/Bool cells are immediate.
# Retain original raw/dynamic guards, layout, wrapped indexing and fallback.
@unsafe
def p113a_raw(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => nt_append(N111Stmt,p113a_class(n),p113a_pair_store(destination,output,p113a_value(n,"size"),n)),
    u => nt_append(N111Stmt,p117a_address(id,n),p113a_success(id,destination,output,n)))

@unsafe
def p117a_address(+id: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p113a_class(n),nt_append(N111Stmt,[
    N111Bin{p113a_name(n,"mask"),N111U64{},"sub",p113a_value(n,"size"),N111Const{1,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p113a_value(n,"mask")},
    N111Bin{p113a_name(n,"location"),N111U64{},"add",p113a_value(n,"location"),p113a_value(n,"index")},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
    N111Offset{p113a_name(n,"cell"),N111Local{"p113a_heap_base"},p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),N111U64{},p113a_value(n,"cell"),0}])))
