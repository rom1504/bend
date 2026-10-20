@unsafe
def p113d_emit_verified(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p113e_admitted_chunks(program),""},
    u => P111Emission{[],"direct structured IR: " ++ error})

@unsafe
def p113d_emit_lowered(result: P113DLowering) -> P111Emission:
  match result:
    case P113DLowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p113d_emit_verified(program,p113d_verify(program)),
        u => P111Emission{[],"direct native lowering: " ++ error})
