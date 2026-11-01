# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad04_empty_chunk_separator_actual() -> String:
  nt_join(["a", "", "b"], ",")

@unsafe
def p97_bad04_empty_chunk_separator_baseline_expected() -> String:
  "a,,b"

@unsafe
def p97_bad04_empty_chunk_separator_challenge_expected() -> String:
  "a,b"
