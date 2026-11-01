# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_good01_direct_append_actual() -> List<&2,String>:
  nt_append(String, ["a", "", "a"], ["z"])

@unsafe
def p97_good01_direct_append_baseline_expected() -> List<&2,String>:
  ["a", "", "a", "z"]

@unsafe
def p97_good01_direct_append_challenge_expected() -> List<&2,String>:
  ["a", "", "a", "z"]
