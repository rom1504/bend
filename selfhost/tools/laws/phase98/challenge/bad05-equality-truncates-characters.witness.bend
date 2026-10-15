# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_bad05_equality_truncates_characters_actual() -> Bool:
  p88_string_eq("Ł", "A")

@unsafe
def p98_bad05_equality_truncates_characters_baseline_expected() -> Bool:
  False{}

@unsafe
def p98_bad05_equality_truncates_characters_challenge_expected() -> Bool:
  True{}
