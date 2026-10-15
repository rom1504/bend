# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_good01_reconstruct_literal_exactly_actual() -> KTerm:
  k_with_children(KLiteral{"U32", 37, "retained", 13, 29}, [KTerm{"Var", "x", 2147483649, 1, Nil{}, ["hidden"], 31, 47}])

@unsafe
def p98_good01_reconstruct_literal_exactly_baseline_expected() -> KTerm:
  KLiteral{"U32", 37, "retained", 13, 29}

@unsafe
def p98_good01_reconstruct_literal_exactly_challenge_expected() -> KTerm:
  KLiteral{"U32", 37, "retained", 13, 29}
