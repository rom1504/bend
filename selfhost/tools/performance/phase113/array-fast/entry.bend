# Final explicit native-entry override. The mature factory/runtime admission
# remains outside this hook, and the final direct/product inliner is called once.
@unsafe
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p113a_emit_lowered(p113a_lower_request(request)),
    u => P111Emission{[],"compile: " ++ error})
