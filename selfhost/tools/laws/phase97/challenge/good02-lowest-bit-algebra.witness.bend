# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_good02_lowest_bit_algebra_actual() -> List<&2,U32>:
  [index_split_bit(0), index_split_bit(1), index_split_bit(12), index_split_bit(2147483648), index_split_bit(4294967295)]

@unsafe
def p97_good02_lowest_bit_algebra_baseline_expected() -> List<&2,U32>:
  [0, 1, 4, 2147483648, 1]

@unsafe
def p97_good02_lowest_bit_algebra_challenge_expected() -> List<&2,U32>:
  [0, 1, 4, 2147483648, 1]
