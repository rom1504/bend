# Text-only fixture. Root checks entry/loop ordering; this synthetic owning graph
# is never executed and is not a source ownership witness.
@unsafe
def p113ah_control_text(+loop: Bool, +arrays: Bool) -> String:
  +body = nt_choose(List<&2,P113DStmt>,arrays,
    u => [P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"a"}}},
      P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Const{0,0}}},
      P113DScalar{N111Alloca{"p113p_out_1",16,8}},
      P113DScalar{N111Call{"status",N111U64{},"p113_rt_array_pair",
        [p111_state(),p111_u32(72),p111_scratch(),p111_u32(2),N111Arg{N111Ptr{},N111Local{"p113p_out_1"}},p111_u32(2)]}},
      P113DScalar{N111Load{"a",N111U64{},N111Local{"p113p_out_1"},0}}],u => [])
  +tail = nt_choose(P113DStmt,loop,u => P113DAgain{[N111Local{"a"}]},u => P113DResult{[N111Local{"a"}]})
  p113ah_function(P113DFunction{"$product.heap_probe",[NC_Binding{0,"a",N_Box{}}],1,False{},nt_append(P113DStmt,body,[tail])},
    N111Ids{missing(),missing()},51413504)
