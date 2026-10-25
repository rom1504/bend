# Diagnostic bridge: preserve the original fresh optimizer and all validators.
# The sole experimental replacement is the initial p128br_scan computation.
@unsafe
def p140lc_original(+request: NR_Request, lowering: P128RawLowering) -> P113ALowering:
  match lowering:
    case P128RawLowering{lowered,raw}:
      p113a_finish(p113a_certificate(request),
        p114s_close_lowered(p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(lowered)))))

@unsafe
def p140lc_fresh(request: NR_Request, original: P113AProgram) -> P128BROpen:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),[],[],[])

@unsafe
def p140lc_cached(request: NR_Request, original: P113AProgram, previous: P140LCache) -> P140LResult:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p140l_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),previous)

@unsafe
def p140lc_complete(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +scan: P128BROpen) -> P111Emission:
  +error = p113a_verify(original)
  nt_choose(P111Emission,String.is_empty(error),u => p140lc_permitted(request,raw,original,scan),
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p140lc_permitted(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +scan: P128BROpen) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{+scalar,unshared}}:
      nt_choose(P111Emission,scalar || p118i_permission(request),
        u => p140lc_scanned(request,raw,original,scalar,scan),u => P134Planned{P134Admitted{original}})

@unsafe
def p140lc_scanned(request: NR_Request, raw: List<&2,P113DCandidate>, original: P113AProgram, cold: Bool, scan: P128BROpen) -> P111Emission:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p128raw_br_scanned(raw,original,book,source,names,cold,scan)
