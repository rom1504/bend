

@unsafe
def p140cp_header(+d: KDef) -> KDef:
  kc(KDef,p98_tag_eq(dv(d),"Foreign"),u => d,u => declared(d))


@unsafe
def p140cp_headers(ds: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: []
    case Con{d,rest}: Con{p140cp_header(d),p140cp_headers(rest)}


@unsafe
def p140cp_split(+ds: List<&2,KDef>, +left: U32, +prefix: List<&2,KDef>) -> P140CPSplit:
  kc(P140CPSplit,U32.is_eq(left,0),
    u => P140CPSplit{nt_reverse(KDef,prefix,[]),ds,True{}},
    u => p140cp_split_more(ds,left,prefix))


@unsafe
def p140cp_split_more(ds: List<&2,KDef>, left: U32, prefix: List<&2,KDef>) -> P140CPSplit:
  match ds:
    case Nil{}: P140CPSplit{nt_reverse(KDef,prefix,[]),[],False{}}
    case Con{head,rest}: p140cp_split(rest,U32.sub(left,1),Con{head,prefix})

# A trusted native adapter may pass its actual already-checked Base prefix and
# the exact starting world/seen. The generic seed below uses dg_check_seed's
# initialization verbatim. Do not manufacture a world from header hashes.

@unsafe
def p140cp_capture_from(+epoch: String, +prefix: List<&2,KDef>, +events: List<&2,KDef>,
    world: KWorld, seen: List<&2,KDef>, count: U32) -> P140CPCapture:
  p140cp_walk(epoch,events,world,seen,count,nt_reverse(KDef,prefix,[]),
    norm_max_book(norm_defs_join(prefix,events)),nt_count(KDef,prefix),0)


@unsafe
def p140cp_walk(+epoch: String, +todo: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>,
    +left: U32, +prefix: List<&2,KDef>, +bound: U32, +cut: U32, +steps: U32) -> P140CPCapture:
  kc(P140CPCapture,U32.is_eq(left,0),
    u => P140CPCaptured{P140CPSaved{epoch,nt_reverse(KDef,prefix,[]),p140cp_headers(todo),bound,world,seen,cut,steps},todo},
    u => p140cp_event(epoch,todo,world,seen,left,prefix,bound,cut,steps))


@unsafe
def p140cp_event(+epoch: String, todo: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>,
    +left: U32, +prefix: List<&2,KDef>, +bound: U32, +cut: U32, +steps: U32) -> P140CPCapture:
  match todo:
    case Nil{}: P140CPCaptureFailed{dg_check_events([],world,seen)}
    case Con{+d,+rest}:
      p140cp_guard(epoch,rest,world,seen,d,left,prefix,bound,cut,steps,event_error(seen,d,lookup(seen,dn(d))))


@unsafe
def p140cp_guard(+epoch: String, +rest: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>,
    +d: KDef, +left: U32, +prefix: List<&2,KDef>, +bound: U32, +cut: U32, +steps: U32, +guard: String) -> P140CPCapture:
  kc(P140CPCapture,String.is_empty(guard),
    u => p140cp_next(epoch,rest,seen,d,left,prefix,bound,cut,steps,check_definition_world(world,signature_mode(d,rest),0)),
    u => P140CPCaptureFailed{DChecking{bad(world,dn(d) ++ ": " ++ guard),dg_no_report(dn(d),guard)}})


@unsafe
def p140cp_next(epoch: String, +rest: List<&2,KDef>, seen: List<&2,KDef>, +d: KDef,
    left: U32, prefix: List<&2,KDef>, bound: U32, cut: U32, steps: U32, +r: KChecking) -> P140CPCapture:
  kc(P140CPCapture,good(r),
    u => p140cp_walk(epoch,rest,dg_event_publish(rest,d,r),book_put(seen,d),U32.sub(left,1),Con{d,prefix},bound,U32.inc(cut),U32.inc(steps)),
    u => P140CPCaptureFailed{dg_event_failed(r,dn(d))})


@unsafe
def p140cp_seed(+epoch: String, +book: List<&2,KDef>, cut: U32) -> P140CPSeed:
  +bound = norm_max_book(book)
  +seed = book_cached([],bound)
  p140cp_seed_finish(p140cp_capture_from(epoch,[],book,kw_seed(check_declarations(book,seed),bound),seed,cut))


@unsafe
def p140cp_seed_finish(capture: P140CPCapture) -> P140CPSeed:
  match capture:
    case P140CPCaptured{+checkpoint,suffix}:
      match checkpoint:
        case P140CPSaved{epoch,prefix,headers,bound,world,seen,cut,steps}:
          P140CPSeed{checkpoint,dg_check_events(suffix,world,seen)}
        case P140CPEmpty{}: P140CPSeed{checkpoint,dg_check_world(suffix)}
    case P140CPCaptureFailed{checked}: P140CPSeed{P140CPEmpty{},checked}


@unsafe
def p140cp_admit(+epoch: String, +book: List<&2,KDef>, checkpoint: P140CPCheckpoint) -> P140CPAdmission:
  match checkpoint:
    case P140CPEmpty{}: P140CPRefused{"no checkpoint"}
    case P140CPSaved{saved,prefix,headers,bound,world,seen,+cut,steps}:
      kc(P140CPAdmission,String.eq(epoch,saved),
        u => kc(P140CPAdmission,U32.is_eq(norm_max_book(book),bound),
          v => p140cp_admit_split(prefix,headers,world,seen,steps,p140cp_split(book,cut,[])),
          v => P140CPRefused{"fresh bound"}),
        u => P140CPRefused{"producer epoch"})


@unsafe
def p140cp_admit_split(+prefix: List<&2,KDef>, +headers: List<&2,KDef>, world: KWorld,
    seen: List<&2,KDef>, steps: U32, split: P140CPSplit) -> P140CPAdmission:
  match split:
    case P140CPSplit{current,+suffix,+complete}:
      kc(P140CPAdmission,complete,
        u => kc(P140CPAdmission,f_fresh_prefix_exact_defs(prefix,current),
          v => kc(P140CPAdmission,f_fresh_prefix_exact_defs(headers,p140cp_headers(suffix)),
            w => P140CPAccepted{suffix,world,seen,steps},w => P140CPRefused{"ordered declaration view"}),
          v => P140CPRefused{"checked prefix"}),
        u => P140CPRefused{"prefix length"})

# Misses retain the existing independent checker. The adapter may instead use
# p140cp_admit directly and its unchanged prepared-Base fallback on refusal.

@unsafe
def p140cp_replay(+epoch: String, +book: List<&2,KDef>, checkpoint: P140CPCheckpoint) -> P140CPReplay:
  p140cp_replay_admitted(book,p140cp_admit(epoch,book,checkpoint))


@unsafe
def p140cp_replay_admitted(book: List<&2,KDef>, admission: P140CPAdmission) -> P140CPReplay:
  match admission:
    case P140CPAccepted{suffix,world,seen,steps}: P140CPReplay{dg_check_events(suffix,world,seen),True{},steps,""}
    case P140CPRefused{reason}: P140CPReplay{dg_check_world(book),False{},0,reason}


def p140cp_saved(seed: P140CPSeed) -> P140CPCheckpoint:
  match seed:
    case P140CPSeed{checkpoint,checked}: checkpoint


def p140cp_seed_checked(seed: P140CPSeed) -> DChecking:
  match seed:
    case P140CPSeed{checkpoint,checked}: checked


def p140cp_replay_checked(replay: P140CPReplay) -> DChecking:
  match replay:
    case P140CPReplay{checked,reused,skipped,reason}: checked


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

@unsafe
def p140cb_owner_cut(load: FPrefixLoad, name: String) -> U32:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}: p140cb_owner_events(suffix,name,0)


@unsafe
def p140cb_owner_events(events: List<&2,KDef>, +name: String, +count: U32) -> U32:
  match events:
    case Nil{}: 0
    case Con{d,+rest}:
      kc(U32,String.eq(dn(d),name),u => count,
        u => p140cb_owner_events(rest,name,U32.inc(count)))

# Data-level controls for event selection; parser/checker admission is separate.

@unsafe
def p140cb_cut_def(name: String) -> KDef:
  KDef{name,"Def",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}


@unsafe
def p140cb_cut_load(+events: List<&2,KDef>) -> FPrefixLoad:
  FPrefixLoad{FLoadTrace{FResult{events,"",[]},[],[]},[p140cb_cut_def("BaseOnly")],events,True{}}


@unsafe
def p140cb_cut_controls() -> List<&2,String>:
  +load = p140cb_cut_load([p140cb_cut_def("alpha"),p140cb_cut_def("pick"),p140cb_cut_def("middle"),p140cb_cut_def("pick"),p140cb_cut_def("last")])
  [p131u_row(U32.is_eq(p140cb_owner_cut(load,"alpha"),0),"cut-first-source-event"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"pick"),1),"cut-first-law-before-fill"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"middle"),2),"cut-middle-source-event"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"last"),4),"cut-last-source-event"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"absent"),0),"cut-missing-refuses-reuse"),
   p131u_row(U32.is_eq(p140cb_owner_cut(load,"BaseOnly"),0),"cut-does-not-count-Base"),
   p131u_row(U32.is_eq(p140cb_owner_cut(p140cb_cut_load([]),"absent"),0),"cut-empty-source")]
