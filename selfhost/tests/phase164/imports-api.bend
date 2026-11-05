# Adapter for the existing experiment harness. Load with imports-only, never
# with hybrid-entry: lowering and all verification remain the original route.
@unsafe
def p164h_emit_plan(plan: P86Plan) -> P111Emission:
  p134e_plan(plan)

@unsafe
def p164h_summary(emission: P111Emission) -> String:
  p164j_summary(emission)
