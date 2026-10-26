# Experimental fast policy: keep the range pass already used by inlining,
# omit the outer pass and its commit. All verifier declarations remain exact.
# This may change program quality; it is not an idempotence claim.
@unsafe
def p114s_ranges(boundary: P114SBoundary) -> P114SBoundary:
  boundary
