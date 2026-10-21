# Emit address scaling in the arithmetic form recognized by QBE's address matcher.
# For shifts0..3, U64 x<<k and x*(1<<k) agree modulo2^64 for every word x.
# All original array identity, index masks, ownership and fallback remain intact.
@unsafe
def p123a_scale(+name: String, +value: N111Value, +shift: U32) -> N111Stmt:
  nt_choose(N111Stmt,U32.is_le(shift,3),
    u => N111Bin{name,N111U64{},"mul",value,N111Const{U32.shl(1,shift),0}},
    u => N111Bin{name,N111U64{},"shl",value,N111Const{shift,0}})

@unsafe
def p117h_address(+id: U32, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p117h_ref(origin,"mask")},
    p123a_scale(p113a_name(n,"bytes"),p113a_value(n,"index"),p117h_index_shift()),
    N111Offset{p113a_name(n,"cell"),p117h_ref(origin,"base"),p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),p117h_cell_type(),p113a_value(n,"cell"),0}]))
