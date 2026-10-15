# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_bad02_lambda_observation_loses_variant_actual() -> KTerm:
  k_with_children(KLambda{"bound", 17, 2, [KLiteral{"U32", 37, "retained", 13, 29}], ["A", "B"], 11, 53, False{}}, [KTerm{"Var", "x", 2147483649, 1, Nil{}, ["hidden"], 31, 47}])

@unsafe
def p98_bad02_lambda_observation_loses_variant_baseline_expected() -> KTerm:
  KLambda{"bound", 17, 2, [KTerm{"Var", "x", 2147483649, 1, Nil{}, ["hidden"], 31, 47}], ["A", "B"], 11, 53, False{}}

@unsafe
def p98_bad02_lambda_observation_loses_variant_challenge_expected() -> KTerm:
  KTerm{"Lam", "bound", 17, 2, [KTerm{"Var", "x", 2147483649, 1, Nil{}, ["hidden"], 31, 47}], ["A", "B"], 11, 53}
