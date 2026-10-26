# New private session entry. Ordinary p140s_* and all original verifiers stay intact.
# Both raw and first-open verifier caches are extracted from ONE successful base.
# The witness exists only during this request; neither IO nor an API input supplies it.
def p142w_seed(seed: P86Seed) -> P142WSession:
  P142WSession{seed,p140s_empty()}

@unsafe
def p142w_named(previous: P142WSession, path: String, text: String, hint: U32, owner: String) -> P142WResult:
  p142w_request(previous,path,text,hint,owner,False{})

@unsafe
def p142w_diagnose(previous: P142WSession, path: String, text: String, hint: U32, owner: String) -> P142WResult:
  p142w_request(previous,path,text,hint,owner,True{})

@unsafe
def p142w_request(+previous: P142WSession, path: String, text: String, hint: U32, owner: String, diagnostic: Bool) -> P142WResult:
  match previous:
    case P142WSession{seed,P140SCache{front,raw,back}}:
      p142w_front(previous,diagnostic,p140f_named(seed,path,text,front,hint,owner))

@unsafe
def p142w_front(+previous: P142WSession, +diagnostic: Bool, front: P140FResult) -> P142WResult:
  match front:
    case P140FResult{plan,cache,stats}:
      match plan:
        case P86PlanError{error}: P142WResult{P111Emission{[],error},previous,stats,p142w_zero()}
        case P86PlanReady{+request,verdict}:
          p142w_admitted(previous,cache,stats,request,diagnostic,p111_runtime_admission(request))

@unsafe
def p142w_admitted(+previous: P142WSession, +front: P140FCache, +stats: List<&2,U32>,
    +request: NR_Request, +diagnostic: Bool, +error: String) -> P142WResult:
  match previous:
    case P142WSession{seed,P140SCache{old,raw,back}}:
      nt_choose(P142WResult,String.is_empty(error),
        u => p142w_raw(previous,front,stats,request,diagnostic,p142or_lower(request,raw)),
        u => P142WResult{P111Emission{[],"compile: " ++ error},previous,stats,p142w_zero()})

@unsafe
def p142w_raw(+previous: P142WSession, front: P140FCache, stats: List<&2,U32>, request: NR_Request,
    diagnostic: Bool, raw: P142ORResult) -> P142WResult:
  match previous raw:
    case P142WSession{seed,P140SCache{old_front,old_raw,back}} P142ORResult{lowering,cache,runs,counts}:
      p142w_finished(previous,front,cache,nt_append(U32,stats,counts),p142b_session(request,back,lowering,runs,diagnostic))

@unsafe
def p142b_session(+request: NR_Request, +previous: P140BCache, +lowering: P128RawLowering,
    +runs: List<&2,P142WRun>, +diagnostic: Bool) -> P142BResult:
  match lowering:
    case P128RawLowering{P113DLowered{+program,+error},+raw}:
      nt_choose(P142BResult,String.is_empty(error),
        u => p142b_open(request,previous,program,raw,runs,diagnostic),
        u => P142BResult{P140BResult{p128raw_session_finish(request,p113a_certificate(request),lowering),previous,[]},p142w_zero()})

@unsafe
def p142b_open(+request: NR_Request, +previous: P140BCache, program: P113DProgram,
    raw: List<&2,P113DCandidate>, runs: List<&2,P142WRun>, diagnostic: Bool) -> P142BResult:
  match previous:
    case P140BCache{opened,optimized,array,late}:
      p142b_opened(request,previous,raw,p142v_open(program,opened,runs,diagnostic))

def p142w_mismatches(counts: P142WCounts) -> U32:
  match counts:
    case P142WCounts{retained,compared,mismatches}: mismatches

# An explicit differential failure cannot be lost in boundary.valid or fallback.
@unsafe
def p142b_opened(+request: NR_Request, +previous: P140BCache, +raw: List<&2,P113DCandidate>, opened: P142VOpened) -> P142BResult:
  match previous opened:
    case P140BCache{old_open,+optimized,+array,+late} P142VOpened{+first,+counts}:
      nt_choose(P142BResult,U32.is_gt(p142w_mismatches(counts),0),
        u => P142BResult{P140BResult{P111Emission{[],"phase142 diagnostic: retained raw-body witness disagrees with exact comparison"},previous,[]},counts},
        u => p142b_continue(request,raw,optimized,array,late,first,counts))

@unsafe
def p142b_continue(request: NR_Request, raw: List<&2,P113DCandidate>, optimized: P134UCache,
    array: P140VCache, late: P140LCache, first: P140VOpened, counts: P142WCounts) -> P142BResult:
  match first:
    case P140VOpened{boundary,cache,stats}:
      P142BResult{p140b_optimized(request,raw,cache,array,late,stats,p134u_optimize(boundary,optimized)),counts}

@unsafe
def p142w_finished(+previous: P142WSession, front: P140FCache, raw: P140ORCache,
    stats: List<&2,U32>, result: P142BResult) -> P142WResult:
  match previous result:
    case P142WSession{+seed,prior} P142BResult{P140BResult{+emission,+back,more},+counts}:
      p142w_publish(previous,seed,front,raw,back,nt_append(U32,stats,more),emission,counts)

@unsafe
def p142w_publish(+previous: P142WSession, +seed: P86Seed, +front: P140FCache, +raw: P140ORCache,
    +back: P140BCache, +stats: List<&2,U32>, +emission: P111Emission, +counts: P142WCounts) -> P142WResult:
  match emission:
    case P111Emission{chunks,+error}:
      nt_choose(P142WResult,String.is_empty(error),
        u => P142WResult{emission,P142WSession{seed,P140SCache{front,raw,back}},stats,counts},
        u => P142WResult{emission,previous,stats,counts})
    case P134Planned{plan}:
      P142WResult{emission,P142WSession{seed,P140SCache{front,raw,back}},stats,counts}
