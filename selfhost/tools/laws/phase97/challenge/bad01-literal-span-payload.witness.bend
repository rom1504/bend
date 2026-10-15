# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad01_literal_span_payload_actual() -> KTerm:
  k_with_span(KLiteral{"U32", 37, "", 2, 4}, 11, 19)

@unsafe
def p97_bad01_literal_span_payload_baseline_expected() -> KTerm:
  KLiteral{"U32", 37, "", 11, 19}

@unsafe
def p97_bad01_literal_span_payload_challenge_expected() -> KTerm:
  KLiteral{"U32", 0, "", 11, 19}
