# Accept only original buffer names or exact ancestry produced by the hygienic
# inliner. Types, op IDs, counts, capacities and state exclusion remain checked.
@unsafe
def p113j_buffer_origin(+name: String, +input: Bool) -> Bool:
  nt_choose(Bool,nt_choose(Bool,input,u => String.eq(name,"scratch"),u => String.starts_with(name,"p113p_out_")),
    u => True{},u => p113j_buffer_peel(name,input,0))

@unsafe
def p113j_buffer_peel(+name: String, +input: Bool, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,16),u => False{},u =>
    nt_choose(Bool,String.starts_with(name,"p113i_" ++ U32.show(site) ++ "_local_"),
      v => p113j_buffer_origin(String.drop(name,nt_choose(Nat,U32.is_lt(site,10),w => 14n,w => 15n)),input),
      v => p113j_buffer_peel(name,input,U32.inc(site))))

@unsafe
def p113j_array_call(+symbol: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{input}},
      Con{N111Arg{N111U32{},N111Const{count,0}},
      Con{N111Arg{N111Ptr{},N111Local{output}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}}:
        String.eq(symbol,"p113_rt_array_pair") && String.eq(state,"state") &&
        p113j_buffer_origin(input,True{}) && p113j_buffer_origin(output,False{}) &&
        U32.is_gt(p113p_array_arity(id),0) && U32.is_eq(p113p_array_arity(id),count)
    case _: False{}
