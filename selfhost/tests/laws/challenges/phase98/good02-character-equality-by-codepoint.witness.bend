# Append to an assembly containing the exact helper dependency closure.

@unsafe
def p98_good02_character_equality_by_codepoint_actual() -> List<&2, Bool>:
  [p88_string_eq("Ł", "A"), p88_string_eq("Ł", "Ł"), p88_string_eq("ax", "ay")]

@unsafe
def p98_good02_character_equality_by_codepoint_baseline_expected() -> List<&2, Bool>:
  [False{}, True{}, False{}]

@unsafe
def p98_good02_character_equality_by_codepoint_challenge_expected() -> List<&2, Bool>:
  [False{}, True{}, False{}]
