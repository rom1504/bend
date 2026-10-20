# Explicit final scalar-profile entry override; no recursive self-reference.
@unsafe
def p113d_lower_request(request: NR_Request) -> P113DLowering:
  p113i_lowered(p113i_scalar_lower_request(request))
