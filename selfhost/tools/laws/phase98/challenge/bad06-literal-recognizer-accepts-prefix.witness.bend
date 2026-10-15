@unsafe
def p98_literal_prefix_actual() -> Bool:
  p98_eq_var("Varx")

@unsafe
def p98_literal_prefix_baseline_expected() -> Bool:
  False{}

@unsafe
def p98_literal_prefix_challenge_expected() -> Bool:
  True{}
