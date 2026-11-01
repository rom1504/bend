# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_bad01_logical_literal_is_constructor_actual() -> Bool:
  core_literal(KTerm{"Lit", "U32", 7, 2, [KLiteral{"U32", 37, "retained", 13, 29}], ["kept"], 13, 29})

@unsafe
def p98_bad01_logical_literal_is_constructor_baseline_expected() -> Bool:
  False{}

@unsafe
def p98_bad01_logical_literal_is_constructor_challenge_expected() -> Bool:
  True{}
