# The mature checked-request factory and fixed runtime capability gate remain.
@unsafe
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p113d_emit_lowered(p113d_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})
