# Visible before the original p126sc_candidates overlay body.
law p173sc_candidates:
  for +candidates: List<&2,P113DCandidate>
  List<&2,P113DCandidate>

law p173sc_candidates_reserved:
  for +candidates: List<&2,P113DCandidate>
  for +occupied: KDef
  List<&2,P113DCandidate>
