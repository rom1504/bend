@unsafe
def p134u_emitted(request: NR_Request, certificate: P113ACertificate, raw: List<&2,P113DCandidate>, error: String, optimized: P134UOptimized) -> P134UEmission:
  match optimized:
    case P134UOptimized{boundary,cache,stats}:
      P134UEmission{p128raw_lowered(request,raw,p113a_finish(certificate,
        P113DLowered{p114s_close(boundary),error})),cache,stats}


