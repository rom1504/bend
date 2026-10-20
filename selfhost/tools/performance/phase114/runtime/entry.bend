@unsafe
def p113a_verify(program: P113AProgram) -> String:
  match program:
    case P113AProgram{+original,+certificate}:
      p114rt_verify_done(original,p113a_verify_after(original,certificate,p113d_verify(original)))

@unsafe
def p113a_admitted_chunks(program: P113AProgram) -> List<&2,String>:
  p114rt_admitted(program)
