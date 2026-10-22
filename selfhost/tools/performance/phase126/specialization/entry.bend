@unsafe
def p113pl_boxed_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  p126s_candidate(book,name,signatures,p126s_plan(book,lookup(book,name)))
