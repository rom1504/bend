# Explicit final product-profile entry override. Product-private workers keep
# their bodies; the inliner currently changes scalar public-compatible workers.
@unsafe
def p113d_lower_request(request: NR_Request) -> P113DLowering:
  p113i_lowered(p113pl_lower_request(request))
