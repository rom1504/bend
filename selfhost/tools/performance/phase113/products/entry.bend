@unsafe
def p113d_lower_request(request: NR_Request) -> P113DLowering:
  p113pl_lower_request(request)

@unsafe
def p113d_inspect_request(request: NR_Request) -> List<&2,P113DCandidate>:
  p113pl_inspect_request(request)
