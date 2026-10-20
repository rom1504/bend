# Optional product profile. The product lowerer has its own implementation and
# never delegates back to this public adapter, avoiding a hook cycle.
@unsafe
def p113d_lower_request(request: NR_Request) -> P113DLowering:
  p113pl_lower_request(request)
