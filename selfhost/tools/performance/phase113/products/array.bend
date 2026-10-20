# Runtime extension profile11301. IDs retain the exact Phase111 catalogue.
# New helper writes two independently owned output Terms and returns status0.
@unsafe
def p113p_array_arity(id: U32) -> U32:
  match id:
    case 72: 2
    case 74: 3
    case 75: 1
    case 76: 1
    case _: 0

@unsafe
def p113p_array_pair(+name: String, +count: U32) -> Bool:
  +arity = p113p_array_arity(p111_op_id(name))
  U32.is_gt(arity,0) && U32.is_eq(arity,count)

# Structural signature only. The direct verifier additionally proves that both
# buffers are valid local allocas, with count*8 and16 bytes respectively, and
# prohibits a state pointer masquerading as either buffer.
@unsafe
def p113p_array_call(+symbol: String, args: List<&2,N111Arg>) -> Bool:
  match symbol args:
    case _ Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{+input}},
      Con{N111Arg{N111U32{},N111Const{+count,0}},
      Con{N111Arg{N111Ptr{},N111Local{+output}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}}:
        String.eq(symbol,"p113_rt_array_pair") && String.eq(state,"state") &&
        String.eq(input,"scratch") && String.starts_with(output,"p113p_out_") &&
        U32.is_gt(p113p_array_arity(id),0) && U32.is_eq(p113p_array_arity(id),count)
    case _ _: False{}

@unsafe
def p113p_pair_code(+id: U32, +values: List<&2,N111Value>, +n: U32) -> P113PValueCode:
  +out = "p113p_out_" ++ U32.show(n)
  +first = "p113p_first_" ++ U32.show(n)
  +second = "p113p_second_" ++ U32.show(n)
  P113PValueCode{nt_append(N111Stmt,p111_store(values,0),[
    N111Alloca{out,16,8},
    N111Call{"p113p_status_" ++ U32.show(n),N111U64{},"p113_rt_array_pair",
      [p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values)),N111Arg{N111Ptr{},N111Local{out}},p111_u32(2)]},
    N111Load{first,N111U64{},N111Local{out},0},
    N111Load{second,N111U64{},N111Local{out},8}]),
    [N111Local{first},N111Local{second}],""}

@unsafe
def p113p_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_array_pair(name,nt_count(N111Value,values)) && p113p_known(wanted) && String.eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2),
    u => p113p_pair_code(p111_op_id(name),values,n),
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"primitive product shape unsupported"},
      v => p113p_boxed(p111_intrinsic(name,values))))
