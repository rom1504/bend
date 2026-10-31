
# Module: src/diagnostic/model.bend:4
type DExpr is Data:
  DText{+text: String}
  DTerm{+term: KTerm}

# Module: src/diagnostic/model.bend:8
type DSpan is Data:
  DNoSpan{}
  DSpan{+source: String, begin: U32, end: U32}

# Module: src/diagnostic/model.bend:12
type DOrigin is Data:
  DSourceOrigin{+source: String, begin: U32, end: U32}

# Module: src/diagnostic/model.bend:15
type DDiagnostic is Data:
  DDiagnostic{+expected: DExpr, +observed: DExpr, has_observed: Bool, +context: List<&2, KTerm>, +definition: String, +span: DSpan, +note: String, +trail: List<&2, KTerm>}

# Module: src/diagnostic/model.bend:18
type DResult is Data:
  DResult{+error: String, +book: List<&2, KDef>, +diagnostic: DDiagnostic}
