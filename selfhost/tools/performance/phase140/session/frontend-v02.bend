# Private fixed-Base session. Cache publication belongs to the successful full
# request; errors retain the previous successful frontend capability.
type P140FCache is Data:
  P140FCache{+parser: Maybe<&2,P140PCache>, +checker: P140CPCheckpoint, +owners: P140OFCache}

type P140FResult is Data:
  P140FResult{+plan: P86Plan, +cache: P140FCache, +stats: List<&2,U32>}

def p140f_empty() -> P140FCache:
  P140FCache{None{},P140CPEmpty{},p140of_empty()}

@unsafe
def p140f_plan(+seed: P86Seed, path: String, text: String, +previous: P140FCache, hint: U32, cut: U32) -> P140FResult:
  match previous:
    case P140FCache{parser,checker,owners}:
      p140f_loaded(seed,previous,cut,p140pl_load(seed,path,text,parser,hint))

@unsafe
def p140f_error(error: String, previous: P140FCache) -> P140FResult:
  P140FResult{P86PlanError{error},previous,[]}

@unsafe
def p140f_loaded(+seed: P86Seed, +previous: P140FCache, +cut: U32, parsed: P140PLoadResult) -> P140FResult:
  match parsed:
    case P140PLoadError{error,cache}: p140f_error(error,previous)
    case P140PLoadReady{+load,cache,hit}: p140f_load(seed,previous,cut,load,cache,hit)

@unsafe
def p140f_load(seed: P86Seed, +previous: P140FCache, cut: U32, +load: FPrefixLoad, parser: Maybe<&2,P140PCache>, hit: Bool) -> P140FResult:
  match seed previous load:
    case P86Seed{base,book,fresh,ready,+world} P140FCache{old_parser,checker,owners} FPrefixLoad{FLoadTrace{FResult{+original,+error,imports},done,sources},prefix,suffix,eligible}:
      nt_choose(P140FResult,String.is_empty(error),
        u => p140f_checked(load,world,previous,parser,hit,original,
          p140cb_check("phase140-fixed-producer-v1",load,world,checker,cut,[])),
        u => p140f_error("parse: " ++ error,previous))

@unsafe
def p140f_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +previous: P140FCache,
    +parser: Maybe<&2,P140PCache>, +parsed: Bool, +original: List<&2,KDef>, checked: P140CBResult) -> P140FResult:
  match checked:
    case P140CBResult{DResult{+error,+book,diagnostic},+checkpoint,+reused,+skipped,reason}:
      nt_choose(P140FResult,String.is_empty(error),
        u => p140f_reported(load,world,previous,parser,parsed,checkpoint,reused,skipped,book,p140dr_report_data(original)),
        u => p140f_error("check: " ++ error,previous))

@unsafe
def p140f_reported(+load: FPrefixLoad, +world: KBasePreparedWorld, +previous: P140FCache,
    +parser: Maybe<&2,P140PCache>, +parsed: Bool, +checkpoint: P140CPCheckpoint, +reused: Bool, +skipped: U32,
    +book: List<&2,KDef>, report: DR_Report) -> P140FResult:
  match report:
    case DR_Report{verdict,names}:
      p140f_owned(load,world,previous,parser,parsed,checkpoint,reused,skipped,book,verdict,driver_emit_owned(book))

@unsafe
def p140f_owned(+load: FPrefixLoad, +world: KBasePreparedWorld, +previous: P140FCache,
    +parser: Maybe<&2,P140PCache>, +parsed: Bool, +checkpoint: P140CPCheckpoint, +reused: Bool, +skipped: U32,
    +book: List<&2,KDef>, +verdict: String, +error: String) -> P140FResult:
  nt_choose(P140FResult,String.is_empty(error),
    u => p140f_entry(load,world,previous,parser,parsed,checkpoint,reused,skipped,book,verdict,j_compile_error(book)),
    u => p140f_error("compile: " ++ error,previous))

@unsafe
def p140f_entry(load: FPrefixLoad, world: KBasePreparedWorld, +previous: P140FCache,
    parser: Maybe<&2,P140PCache>, parsed: Bool, checkpoint: P140CPCheckpoint, reused: Bool, skipped: U32,
    book: List<&2,KDef>, verdict: String, +error: String) -> P140FResult:
  match previous:
    case P140FCache{old_parser,old_checker,owners}:
      nt_choose(P140FResult,String.is_empty(error),
        u => p140f_owners(previous,parser,parsed,checkpoint,reused,skipped,
          p140of_context(book_context_world(book,load,world),verdict,owners)),
        u => p140f_error("compile: " ++ error,previous))

@unsafe
def p140f_owners(+previous: P140FCache, parser: Maybe<&2,P140PCache>, parsed: Bool,
    checkpoint: P140CPCheckpoint, reused: Bool, skipped: U32, result: P140OFResult) -> P140FResult:
  match result:
    case P140OFResult{+plan,cache,stats}:
      match plan:
        case P86PlanError{error}: p140f_error(error,previous)
        case P86PlanReady{request,verdict}:
          P140FResult{plan,P140FCache{parser,checkpoint,cache},
            Con{Bool.to_u32(parsed),Con{Bool.to_u32(reused),Con{skipped,stats}}}}

@unsafe
def p140f_named(+seed: P86Seed, path: String, text: String, +previous: P140FCache, hint: U32, +owner: String) -> P140FResult:
  match previous:
    case P140FCache{parser,checker,owners}:
      p140f_named_loaded(seed,previous,owner,p140pl_load(seed,path,text,parser,hint))

@unsafe
def p140f_named_loaded(+seed: P86Seed, +previous: P140FCache, +owner: String, parsed: P140PLoadResult) -> P140FResult:
  match parsed:
    case P140PLoadError{error,cache}: p140f_error(error,previous)
    case P140PLoadReady{+load,cache,hit}: p140f_load(seed,previous,p140cb_owner_cut(load,owner),load,cache,hit)
