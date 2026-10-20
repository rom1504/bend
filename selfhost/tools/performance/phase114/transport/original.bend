# Exact candidate31 statement renderer and final verifier, renamed only.
# Keeping these separate prevents an unchanged helper call recursing into the
# transport expander and preserves all previous width/accessor/float behavior.
@unsafe
def p114t_original_stmt(+stmt: N111Stmt, +ids: N111Ids, code: P111QCode) -> P111QCode:
  p112fp_after_accessors(stmt,ids,p112fp_expand(stmt,code))

@unsafe
def p114t_original_verify(program: P113AProgram) -> String:
  match program:
    case P113AProgram{+original,certificate}: p113a_verify_after(original,certificate,p113d_verify(original))
