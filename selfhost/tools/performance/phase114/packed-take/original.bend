# Exact table01 + transport final verifier, renamed only. If the optional bridge
# strengthens p114t_local_name, that existing namespace check remains in force.
@unsafe
def p114pk_original_verify(+program: P113AProgram) -> String:
  p114t_verify_done(program,p114t_original_verify(program))
