# Exact finite-runtime identities. One U64 assignment preserves the old result
# snapshot; no narrowing, additional proof domain, runtime helper or IR node.
@unsafe
def p125i_previous_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  nt_choose(P111ValueCode,U32.is_eq(id,0),u => P111ValueCode{Nil{},N111Const{0,0},"unknown native primitive " ++ name},
    u => P111ValueCode{nt_append(N111Stmt,p111_store(values,0),[N111Call{"value",N111U64{},"p111_rt_op",[
      p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values))]}]),N111Local{"value"},""})

@unsafe
def p112_intrinsic_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+value,Nil{}}:
      nt_choose(P111ValueCode,String.eq(name,"u32_to_nat") || String.eq(name,"f32_bits"),
        u => P111ValueCode{[N111Set{"value",N111U64{},value}],N111Local{"value"},""},
        u => p125i_previous_fallback(name,values))
    case _: p125i_previous_fallback(name,values)
