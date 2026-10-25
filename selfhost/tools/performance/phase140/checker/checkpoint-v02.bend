# Experimental fixed-producer, in-process checker-prefix capability.
# Inputs are actual validated, globally freshened declaration events.
# Capture delegates every semantic transition to the existing checker.
# This module does not parse source, accept serialized checkpoints, or override
# the selected entry. Epoch equality is necessary, not provenance by itself.

type P140CPCheckpoint is Data:
  P140CPEmpty{}
  P140CPSaved{+epoch: String, +prefix: List<&2,KDef>, +headers: List<&2,KDef>,
    +bound: U32, +world: KWorld, +seen: List<&2,KDef>, +cut: U32, +steps: U32}

type P140CPCapture is Data:
  P140CPCaptured{+checkpoint: P140CPCheckpoint, +suffix: List<&2,KDef>}
  P140CPCaptureFailed{+checked: DChecking}

type P140CPSeed is Data:
  P140CPSeed{+checkpoint: P140CPCheckpoint, +checked: DChecking}

type P140CPSplit is Data:
  P140CPSplit{+prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +complete: Bool}

type P140CPAdmission is Data:
  P140CPAccepted{+suffix: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>, +steps: U32}
  P140CPRefused{+reason: String}

type P140CPReplay is Data:
  P140CPReplay{+checked: DChecking, +reused: Bool, +skipped: U32, +reason: String}

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
