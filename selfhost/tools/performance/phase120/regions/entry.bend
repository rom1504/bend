# Runs after the existing inliner, before the independently owned range pass.
@unsafe
def p114s_inline(boundary: P114SBoundary) -> P114SBoundary:
  p120nr_boundary(p120nr_original_inline(boundary))
