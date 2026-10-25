# Optional exact replacement for the orchestration of p128raw_verified.
# Original retry/closure/final verifier remains p128raw_br_scanned's path.
type P140LEmission is Data:
  P140LEmission{+emission: P111Emission, +cache: P140LCache, +stats: List<&2,U32>}

@unsafe
def p140le_verified(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +error: String, +previous: P140LCache) -> P140LEmission:
  nt_choose(P140LEmission,String.is_empty(error),u => p140le_prepare(request,raw,original,previous),
    u => P140LEmission{P111Emission{[],"array structured IR: " ++ error},previous,[]})

@unsafe
def p140le_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +previous: P140LCache) -> P140LEmission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P140LEmission,scalar,u => p140le_scan(request,raw,original,True{},previous),u =>
        nt_choose(P140LEmission,p118i_permission(request),
          v => p140le_scan(request,raw,original,False{},previous),
          v => P140LEmission{P134Planned{P134Admitted{original}},previous,[]}))

@unsafe
def p140le_scan(request: NR_Request, raw: List<&2,P113DCandidate>, +original: P113AProgram, cold: Bool, +previous: P140LCache) -> P140LEmission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p140le_scanned(raw,original,book,source,names,cold,previous,
        p140l_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),previous))

@unsafe
def p140le_scanned(raw: List<&2,P113DCandidate>, original: P113AProgram, book: List<&2,KDef>, source: List<&2,KDef>, names: List<&2,String>,
    cold: Bool, previous: P140LCache, result: P140LResult) -> P140LEmission:
  match result:
    case P140LResult{scan,cache,stats}:
      p140le_publish(previous,cache,stats,p128raw_br_scanned(raw,original,book,source,names,cold,scan))

@unsafe
def p140le_publish(+previous: P140LCache, +cache: P140LCache, stats: List<&2,U32>, +emission: P111Emission) -> P140LEmission:
  match emission:
    case P111Emission{chunks,+error}:
      P140LEmission{emission,nt_choose(P140LCache,String.is_empty(error),u => cache,u => previous),stats}
    case P134Planned{plan}: P140LEmission{emission,cache,stats}
