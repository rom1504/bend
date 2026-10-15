# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad06_environment_remove_all_actual() -> List<&2,NC_Binding>:
  nc_remove_env([NC_Binding{7, "first", N_Box{}}, NC_Binding{8, "middle", N_W32{}}, NC_Binding{7, "second", N_W64{}}], 7)

@unsafe
def p97_bad06_environment_remove_all_baseline_expected() -> List<&2,NC_Binding>:
  [NC_Binding{8, "middle", N_W32{}}, NC_Binding{7, "second", N_W64{}}]

@unsafe
def p97_bad06_environment_remove_all_challenge_expected() -> List<&2,NC_Binding>:
  [NC_Binding{8, "middle", N_W32{}}]
