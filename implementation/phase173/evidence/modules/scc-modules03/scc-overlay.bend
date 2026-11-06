# Private overlay body. Load scc.bend before acquiring the candidate compiler.
# This replaces the implementation of the existing p126sc_candidates only.
@unsafe
def p126sc_candidates(+candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  p173sc_candidates(candidates)
