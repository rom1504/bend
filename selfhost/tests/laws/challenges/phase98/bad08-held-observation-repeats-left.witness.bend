@unsafe
def p98_bad08_held_observation_repeats_left_actual() -> P98EqHeld:
  p98_eq_observe("left", "right")

@unsafe
def p98_bad08_held_observation_repeats_left_baseline_expected() -> P98EqHeld:
  P98EqHeld{False{}, "left", "right"}

@unsafe
def p98_bad08_held_observation_repeats_left_challenge_expected() -> P98EqHeld:
  P98EqHeld{False{}, "left", "left"}

