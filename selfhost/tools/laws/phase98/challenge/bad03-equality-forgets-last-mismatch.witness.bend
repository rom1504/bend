# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_bad03_equality_forgets_last_mismatch_actual() -> Bool:
  p88_string_eq("ax", "ay")

@unsafe
def p98_bad03_equality_forgets_last_mismatch_baseline_expected() -> Bool:
  False{}

@unsafe
def p98_bad03_equality_forgets_last_mismatch_challenge_expected() -> Bool:
  True{}
