# Private expansion of an unchanged verified owning runtime call. The original
# graph remains the public verifier input; only exact runtime11301 is admitted.
@unsafe
def p114rt_name(n: U32, role: String) -> String:
  "p114rt_" ++ U32.show(n) ++ "_" ++ role

@unsafe
def p114rt_value(n: U32, role: String) -> N111Value:
  N111Local{p114rt_name(n,role)}

@unsafe
def p114rt_take2(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U64{},word},
      Con{N111Arg{N111Ptr{},N111Local{output}},Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}:
        String.eq(symbol,"p111_rt_take") && String.eq(state,"state") && p113j_buffer_origin(output,True{})
    case _: False{}

# Every descriptor constructor gets one full-width Boolean entry, avoiding an
# out-of-object wide load from the original compact byte arity table.
@unsafe
def p114rt_arity_words(constructors: List<&2,N_Constructor>) -> List<&2,P111QDatum>:
  match constructors:
    case Nil{}: []
    case Con{N_Constructor{name,arity,hot},rest}:
      Con{P111QLong{Bool.to_u32(U32.is_eq(arity,2)),0},p114rt_arity_words(rest)}

@unsafe
def p114rt_arity_table(constructors: List<&2,N_Constructor>) -> P111QData:
  P111QData{"p114rt_arity2",8,False{},p111q_nonempty(p114rt_arity_words(constructors))}

@unsafe
def p114rt_address(+n: U32, +role: String, location: N111Value) -> List<&2,N111Stmt>:
  [N111Bin{p114rt_name(n,role ++ "_bytes"),N111U64{},"shl",location,N111Const{3,0}},
   N111Offset{p114rt_name(n,role),N111Local{"p113a_heap_base"},p114rt_value(n,role ++ "_bytes")}]
