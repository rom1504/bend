# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad03_membership_high_bit_actual() -> Bool:
  nu_has(NU_Leaf{1}, 2147483649)

@unsafe
def p97_bad03_membership_high_bit_baseline_expected() -> Bool:
  False{}

@unsafe
def p97_bad03_membership_high_bit_challenge_expected() -> Bool:
  True{}
