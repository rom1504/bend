# Test-only original session orchestration, exact declaration renaming.
# Heavy frontend, lowering, optimization, verifier and rendering helpers are shared.
def p142ref_b_empty() -> P140BCache:
  P140BCache{P140VEmpty{},P134UCache{[],[]},P140VEmpty{},p140l_empty()}


@unsafe
def p142ref_b_session(+request: NR_Request, +previous: P140BCache, +lowering: P128RawLowering) -> P140BResult:
  match lowering:
    case P128RawLowering{P113DLowered{+program,+error},+raw}:
      nt_choose(P140BResult,String.is_empty(error),
        u => p142ref_b_open(request,previous,program,raw),
        u => P140BResult{p128raw_session_finish(request,p113a_certificate(request),lowering),previous,[]})


@unsafe
def p142ref_b_open(+request: NR_Request, +previous: P140BCache, program: P113DProgram, raw: List<&2,P113DCandidate>) -> P140BResult:
  match previous:
    case P140BCache{opened,optimized,array,late}:
      p142ref_b_opened(request,previous,raw,p140v_open(program,opened))


@unsafe
def p142ref_b_opened(+request: NR_Request, previous: P140BCache, raw: List<&2,P113DCandidate>, opened: P140VOpened) -> P140BResult:
  match previous opened:
    case P140BCache{old_open,optimized,array,late} P140VOpened{boundary,cache,counts}:
      p142ref_b_optimized(request,raw,cache,array,late,counts,p134u_optimize(boundary,optimized))


@unsafe
def p142ref_b_optimized(+request: NR_Request, raw: List<&2,P113DCandidate>, opened: P140VCache, array: P140VCache, late: P140LCache,
    counts: List<&2,U32>, optimized: P134UOptimized) -> P140BResult:
  match optimized:
    case P134UOptimized{boundary,cache,stats}:
      p142ref_b_lowered(request,raw,opened,cache,array,late,nt_append(U32,counts,stats),
        p113a_finish(p113a_certificate(request),P113DLowered{p114s_close(boundary),""}))


@unsafe
def p142ref_b_lowered(+request: NR_Request, +raw: List<&2,P113DCandidate>, +opened: P140VCache,
    +optimized: P134UCache, +array: P140VCache, +late: P140LCache, +stats: List<&2,U32>, lowered: P113ALowering) -> P140BResult:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P140BResult,String.is_empty(error),
        u => p142ref_b_array(request,raw,program,opened,optimized,late,stats,p140v_array(program,array)),
        u => P140BResult{P111Emission{[],"array native lowering: " ++ error},P140BCache{opened,optimized,array,late},stats})


@unsafe
def p142ref_b_array(request: NR_Request, raw: List<&2,P113DCandidate>, program: P113AProgram,
    opened: P140VCache, optimized: P134UCache, late: P140LCache, stats: List<&2,U32>, checked: P140VArrayChecked) -> P140BResult:
  match checked:
    case P140VArrayChecked{cache,error,counts}:
      p142ref_b_late(opened,optimized,cache,nt_append(U32,stats,counts),p140le_verified(request,raw,program,error,late))


@unsafe
def p142ref_b_late(opened: P140VCache, optimized: P134UCache, array: P140VCache, stats: List<&2,U32>, late: P140LEmission) -> P140BResult:
  match late:
    case P140LEmission{emission,cache,counts}:
      P140BResult{emission,P140BCache{opened,optimized,array,cache},nt_append(U32,stats,counts)}


def p142ref_s_empty() -> P140SCache:
  P140SCache{p140f_empty(),p140or_empty(),p142ref_b_empty()}


@unsafe
def p142ref_s_plan(seed: P86Seed, path: String, text: String, +previous: P140SCache, hint: U32, cut: U32) -> P140SResult:
  match previous:
    case P140SCache{front,raw,back}: p142ref_s_front(previous,p140f_plan(seed,path,text,front,hint,cut))


@unsafe
def p142ref_s_front(+previous: P140SCache, front: P140FResult) -> P140SResult:
  match front:
    case P140FResult{plan,cache,stats}:
      match plan:
        case P86PlanError{error}: P140SResult{P111Emission{[],error},previous,stats}
        case P86PlanReady{+request,verdict}: p142ref_s_admitted(previous,cache,stats,request,p111_runtime_admission(request))


@unsafe
def p142ref_s_admitted(+previous: P140SCache, +front: P140FCache, +stats: List<&2,U32>, +request: NR_Request, +error: String) -> P140SResult:
  match previous:
    case P140SCache{old,raw,back}:
      nt_choose(P140SResult,String.is_empty(error),
        u => p142ref_s_raw(previous,front,stats,request,p140or_lower(request,raw)),
        u => P140SResult{P111Emission{[],"compile: " ++ error},previous,stats})


@unsafe
def p142ref_s_raw(+previous: P140SCache, front: P140FCache, stats: List<&2,U32>, request: NR_Request, raw: P140ORResult) -> P140SResult:
  match previous raw:
    case P140SCache{old_front,old_raw,back} P140ORResult{lowering,cache,counts}:
      p142ref_s_finished(previous,front,cache,nt_append(U32,stats,counts),p142ref_b_session(request,back,lowering))


@unsafe
def p142ref_s_finished(+previous: P140SCache, +front: P140FCache, +raw: P140ORCache, +stats: List<&2,U32>, back: P140BResult) -> P140SResult:
  match back:
    case P140BResult{+emission,+cache,+counts}:
      match emission:
        case P111Emission{chunks,error}:
          nt_choose(P140SResult,String.is_empty(error),
            u => P140SResult{emission,P140SCache{front,raw,cache},nt_append(U32,stats,counts)},
            u => P140SResult{emission,previous,nt_append(U32,stats,counts)})
        case P134Planned{plan}: P140SResult{emission,P140SCache{front,raw,cache},nt_append(U32,stats,counts)}


@unsafe
def p142ref_s_named(seed: P86Seed, path: String, text: String, +previous: P140SCache, hint: U32, owner: String) -> P140SResult:
  match previous:
    case P140SCache{front,raw,back}: p142ref_s_front(previous,p140f_named(seed,path,text,front,hint,owner))

