# Optional exact product-builder overrides. No calls are removed. A snapshot
# must precede the call: the helper may overwrite argument/output buffer memory.
@unsafe
def p113p_pair_code(+id: U32, +values: List<&2,N111Value>, +n: U32) -> P113PValueCode:
  +out = "p113p_out_" ++ U32.show(n)
  +first = "p113p_first_" ++ U32.show(n)
  +second = "p113p_second_" ++ U32.show(n)
  P113PValueCode{Con{p113ai_snapshot(values,n),nt_append(N111Stmt,p111_store(values,0),[
    N111Alloca{out,16,8},
    N111Call{"p113p_status_" ++ U32.show(n),N111U64{},"p113_rt_array_pair",
      [p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values)),N111Arg{N111Ptr{},N111Local{out}},p111_u32(2)]},
    N111Set{first,N111U64{},N111Local{"p113ai_array_" ++ U32.show(n)}},
    N111Load{second,N111U64{},N111Local{out},8}])},
    [N111Local{first},N111Local{second}],""}

@unsafe
def p113p_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_array_pair(name,nt_count(N111Value,values)) && p113p_known(wanted) && String.eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2),
    u => p113p_pair_code(p111_op_id(name),values,n),
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"primitive product shape unsupported"},
      v => p113p_boxed(p113ai_intrinsic(name,values,n))))
