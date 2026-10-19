# Compose after accessors/{original,emit} and its both-mode entry. The fallback
# remains the audited tag/register renderer; all other statements are exact.
@unsafe
def p112fp_after_accessors(+stmt: N111Stmt, +ids: N111Ids, result: P112FPEmission) -> P111QCode:
  match result:
    case P112FPEmission{expanded,+code}:
      nt_choose(P111QCode,expanded,u => code,u => p112a_stmt(3,stmt,ids,code))

@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, code: P111QCode) -> P111QCode:
  p112fp_after_accessors(stmt,ids,p112fp_expand(stmt,code))
