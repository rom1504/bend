# CtorId is a verified immutable integer catalogue index, not a pointer or Term.
# Original p111v_value requires integer width and presence in the same catalogue;
# p111q_value renders that index through p111q_id. Symbols/FuncId stay refused.
@unsafe
def p120nr_operand(value: N111Value, +buffers: List<&2,String>) -> Bool:
  match value:
    case N111Const{lo,hi}: True{}
    case N111CtorId{name}: True{}
    case N111Local{name}: Bool.not(String.eq(name,"state")) && Bool.not(p114so_member(buffers,name))
    case _: False{}
