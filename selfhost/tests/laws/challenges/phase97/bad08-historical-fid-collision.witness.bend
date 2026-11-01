# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad08_historical_fid_collision_actual() -> List<&2,String>:
  [nt_fid("foo"), nt_fid("Foo"), nt_fid("a.b"), nt_fid("a_b")]

@unsafe
def p97_bad08_historical_fid_collision_baseline_expected() -> List<&2,String>:
  ["FID_102_111_111_", "FID_70_111_111_", "FID_97_46_98_", "FID_97_95_98_"]

@unsafe
def p97_bad08_historical_fid_collision_challenge_expected() -> List<&2,String>:
  ["FID_FOO", "FID_FOO", "FID_A_B", "FID_A_B"]
