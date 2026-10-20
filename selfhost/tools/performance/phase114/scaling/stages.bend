# Stage wrappers expose the existing Bend work to an ordinary timestamping
# transport. A transport never reconstructs programs, functions, or sessions.
@unsafe
def p114s_open_lowered(lowered: P113DLowering) -> P114SLowered:
  match lowered:
    case P113DLowered{+program,+error}:
      P114SLowered{nt_choose(P114SBoundary,String.is_empty(error),
        u => p114s_open(program),u => p114s_unchecked(program)),error}

@unsafe
def p114s_inline_lowered(lowered: P114SLowered) -> P114SLowered:
  match lowered:
    case P114SLowered{boundary,error}: P114SLowered{p114s_inline(boundary),error}

@unsafe
def p114s_ranges_lowered(lowered: P114SLowered) -> P114SLowered:
  match lowered:
    case P114SLowered{boundary,error}: P114SLowered{p114s_ranges(boundary),error}

@unsafe
def p114s_close_lowered(lowered: P114SLowered) -> P113DLowering:
  match lowered:
    case P114SLowered{boundary,error}: P113DLowered{p114s_close(boundary),error}

@unsafe
def p114s_lower_request(request: NR_Request) -> P113DLowering:
  p114s_close_lowered(p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(p113pl_lower_request(request)))))
