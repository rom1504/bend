# Only the ordinary planner's private, identity-bound Base path is redirected.
# Independent raw/prepared checkers and incremental-session checking stay intact.
@unsafe
def p86_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  p143cb_plan_loaded(seed,load,True{})
