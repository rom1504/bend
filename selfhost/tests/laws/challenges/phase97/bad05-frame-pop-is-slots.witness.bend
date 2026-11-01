# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad05_frame_pop_is_slots_actual() -> U32:
  nb_frame_results(N_Frame{1, ["saved0", "saved1"]}, 5)

@unsafe
def p97_bad05_frame_pop_is_slots_baseline_expected() -> U32:
  3

@unsafe
def p97_bad05_frame_pop_is_slots_challenge_expected() -> U32:
  4
