# Exact runtime11301 transfer identity, before inlining. This does not assert
# that the array is raw, unique, dynamic or scalar. Calls/effects stay ordered.
@unsafe
def p113ai_first(values: List<&2,N111Value>) -> N111Value:
  match values:
    case Con{value,rest}: value
    case Nil{}: N111Symbol{"invalid_array_identity"}

@unsafe
def p113ai_snapshot(+values: List<&2,N111Value>, +n: U32) -> N111Stmt:
  N111Set{"p113ai_array_" ++ U32.show(n),N111U64{},p113ai_first(values)}

@unsafe
def p113ai_set_done(+values: List<&2,N111Value>, +n: U32, original: P111ValueCode) -> P111ValueCode:
  match original:
    case P111ValueCode{body,value,error}:
      P111ValueCode{Con{p113ai_snapshot(values,n),nt_append(N111Stmt,body,[
        N111Set{"p113ai_result_" ++ U32.show(n),N111U64{},N111Local{"p113ai_array_" ++ U32.show(n)}}])},
        N111Local{"p113ai_result_" ++ U32.show(n)},error}

@unsafe
def p113ai_intrinsic(+name: String, +values: List<&2,N111Value>, +n: U32) -> P111ValueCode:
  nt_choose(P111ValueCode,String.eq(name,"array_set") && U32.is_eq(nt_count(N111Value,values),3),
    u => p113ai_set_done(values,n,p111_intrinsic(name,values)),
    u => p111_intrinsic(name,values))
