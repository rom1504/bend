# Read-only diagnostics from the actual checked request, not caller-made facts.
@unsafe
def p126s_inspect(request: NR_Request, +name: String) -> Maybe<&2,List<&2,U32>>:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}: p126s_plan(book,lookup(book,name))

@unsafe
def p126s_float_bits(bits: U32) -> U32:
  F32.bits(p126s_float(bits))

@unsafe
def p126s_projection_control() -> String:
  +params : List<&2,NC_Binding> = [NC_Binding{0,"v_0",N_Imm64{}}]
  +function : P113DFunction = P113DFunction{"selector",params,1,False{},p126s_decision("v_0",[0,2147483648,1065353216,4294967295],0)}
  nt_choose(String,p126s_is_table(function) && String.contains(p126s_emit(function),"loadl") &&
    String.contains(p126s_emit(function),"cultl %v_v_0, 3"),u => "table-projection:pass",u => "table-projection:FAIL")
