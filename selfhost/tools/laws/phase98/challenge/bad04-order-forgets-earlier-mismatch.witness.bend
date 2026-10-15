# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_bad04_order_forgets_earlier_mismatch_actual() -> Cmp:
  p88_string_order("b", "aa")

@unsafe
def p98_bad04_order_forgets_earlier_mismatch_baseline_expected() -> Cmp:
  GT{}

@unsafe
def p98_bad04_order_forgets_earlier_mismatch_challenge_expected() -> Cmp:
  LT{}
