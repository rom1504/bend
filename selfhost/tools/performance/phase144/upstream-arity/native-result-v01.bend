# Private native adapter only. p140n_backend terminates with IO.die for EVERY
# P111Emission, so its failure branch never observes this provisional cache.
# Generic p140s_finished keeps its original rollback contract unchanged.
@unsafe
def p144cn_native_result(front: P140FCache, raw: P140ORCache, stats: List<&2,U32>, back: P140BResult) -> P140SResult:
  match back:
    case P140BResult{emission,cache,counts}:
      P140SResult{emission,P140SCache{front,raw,cache},nt_append(U32,stats,counts)}

# Exact native timing/control flow, without retaining the obsolete complete
# session across p140b_session solely to construct an unobservable rollback.
@unsafe
def p140n_raw(started: Nat, frontend: Nat, previous: P140NCache, output: String,
    front: P140FCache, stats: List<&2,U32>, request: NR_Request, result: P140ORResult) -> IO(P140NResult):
  match previous:
    case P140NCache{session,registry,render}:
      match session:
        case P140SCache{old_front,old_raw,back}:
          match result:
            case P140ORResult{lowering,cache,counts}:
              do IO<P140NResult>:
                raw : Nat <- IO.now()
                p140n_backend(started,frontend,raw,registry,render,output,
                  p144cn_native_result(front,cache,nt_append(U32,stats,counts),p140b_session(request,back,lowering)))
