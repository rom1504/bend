# Private prepared-Base bridge. The caller couples load and prepared to the
# same authenticated Base seed, as p86_plan_loaded already does. No new public
# permission is granted to raw worlds or user-supplied epoch strings.
type P140CBResult is Data:
  P140CBResult{+result: DResult, +checkpoint: P140CPCheckpoint, +reused: Bool, +skipped: U32, +reason: String}

@unsafe
def p140cb_check(+epoch: String, +load: FPrefixLoad, +prepared: KBasePreparedWorld,
    +checkpoint: P140CPCheckpoint, +cut: U32, +origins: List<&2,DOrigin>) -> P140CBResult:
  match load:
    case FPrefixLoad{trace,+prefix,+suffix,+ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}:
              p140cb_book(epoch,load,prepared,checkpoint,cut,origins,book,error,prefix,suffix,ready)

@unsafe
def p140cb_book(+epoch: String, +load: FPrefixLoad, +prepared: KBasePreparedWorld,
    +checkpoint: P140CPCheckpoint, +cut: U32, +origins: List<&2,DOrigin>,
    +book: List<&2,KDef>, +error: String, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool) -> P140CBResult:
  match prepared:
    case KBasePreparedWorld{+state,original,+final,+saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      kc(P140CBResult,ready && String.is_empty(error) && base_prefix_world_admitted(state,suffix,bound,final,saved) &&
          base_prefix_world_hash_disjoint(suffix,index_first(dc(index_first(saved)))),
        u => p140cb_admitted(epoch,prepared,checkpoint,cut,origins,prefix,suffix,bound,p140cp_admit(epoch,book,checkpoint)),
        u => P140CBResult{check_program_diagnostic_world(load,origins,prepared),checkpoint,False{},0,"original Base fallback"})

@unsafe
def p140cb_admitted(+epoch: String, +prepared: KBasePreparedWorld, +checkpoint: P140CPCheckpoint,
    +cut: U32, +origins: List<&2,DOrigin>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32,
    admission: P140CPAdmission) -> P140CBResult:
  match admission:
    case P140CPAccepted{tail,world,seen,steps}:
      p140cb_finish(prepared,suffix,origins,checkpoint,True{},steps,"",dg_check_events(tail,world,seen))
    case P140CPRefused{reason}:
      p140cb_seeded(prepared,suffix,origins,checkpoint,reason,
        p140cp_seed_finish(p140cb_capture(epoch,prepared,prefix,suffix,bound,cut)))

# This is exactly base_prefix_world_resume_state's admitted starting state;
# only the subsequent dg_check_events traversal is split at a source boundary.
@unsafe
def p140cb_capture(+epoch: String, prepared: KBasePreparedWorld, +prefix: List<&2,KDef>,
    +suffix: List<&2,KDef>, +bound: U32, +cut: U32) -> P140CPCapture:
  match prepared:
    case KBasePreparedWorld{state,original,final,+book,checked,seen,todos,checkedBound}:
      match state:
        case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
          +declared = check_declarations(suffix,kw_bound_book(book,U32.add(bound,stamp)))
          +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
          +world: KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
          p140cp_capture_from(epoch,prefix,suffix,world,kw_bound_book(seen,bound),cut)

@unsafe
def p140cb_seeded(prepared: KBasePreparedWorld, suffix: List<&2,KDef>, origins: List<&2,DOrigin>,
    prior: P140CPCheckpoint, reason: String, seed: P140CPSeed) -> P140CBResult:
  match seed:
    case P140CPSeed{checkpoint,checked}:
      p140cb_finish(prepared,suffix,origins,p140cb_retain(checkpoint,prior),False{},0,reason,checked)

# A failed early edit must not destroy the previous successful checkpoint.
def p140cb_retain(current: P140CPCheckpoint, prior: P140CPCheckpoint) -> P140CPCheckpoint:
  match current:
    case P140CPEmpty{}: prior
    case other: other

@unsafe
def p140cb_finish(prepared: KBasePreparedWorld, suffix: List<&2,KDef>, origins: List<&2,DOrigin>,
    checkpoint: P140CPCheckpoint, reused: Bool, skipped: U32, reason: String, checked: DChecking) -> P140CBResult:
  match prepared:
    case KBasePreparedWorld{state,prefix,final,book,outputs,seen,todos,checkedBound}:
      P140CBResult{driver_program_checked_prefix(suffix,todos,origins,checked),checkpoint,reused,skipped,reason}
