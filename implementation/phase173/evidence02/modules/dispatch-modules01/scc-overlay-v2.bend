# Revision2: the seeded caller passes its occupied function index.
# Private overlay body. Load scc.bend before acquiring the candidate compiler.
# This replaces the implementation of the existing p126sc_candidates only.
@unsafe
def p126sc_candidates(+candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  p173sc_candidates(candidates)

@unsafe
def p168_candidates(+mode: U32, source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    +remaining: U32, +workers: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>,
    retry: List<&2,NO_Plan>, +raw: List<&2,P113DCandidate>) -> P167Lowered:
  +ready = p113e_signatures(workers,missing())
  p168_closed(mode,source,book,names,constructors,nodes,bangs,
    [mode,U32.sub(nt_count(String,names),remaining),nt_count(P113DFunction,workers),remaining,nt_count(P113DCandidate,raw)],
    helpers,retry,ready,p113d_passes(p173sc_candidates_reserved(raw,ready),ready,nt_reverse(P113DFunction,workers,[]),32))

