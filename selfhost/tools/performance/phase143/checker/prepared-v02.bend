# PRIVATE adapter for the existing identity-bound P86Seed/FPrefixLoad pair.
# All original admission, bounds, Base ordering and hash-collision fallback stay.
# No original function is overridden by this module.

@unsafe
def p143cb_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>,
    +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +logging: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound,delta,stamp,patches,ready}:
      +declared = check_declarations(suffix,kw_bound_book(book,U32.add(bound,stamp)))
      +ordered = base_prefix_world_order(declared,base_prefix_world_raw(book),suffix)
      +world: KWorld = KWorld{ordered,Nil{},KFreshKnown{U32.add(U32.add(bound,delta),1)},checked}
      p143cp_result(p143cp_walk(p143cs_plan(suffix),world,kw_bound_book(seen,bound),logging),logging)

@unsafe
def p143cb_resume(prepared: KBasePreparedWorld, suffix: List<&2,KDef>, bound: U32, logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,prefix,final,book,checked,seen,todos,checkedBound}:
      p143cb_resume_state(state,book,checked,seen,suffix,bound,logging)

@unsafe
def p143cb_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>,
    +bound: U32, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      nt_choose(DChecking,p143cp_regular(suffix) &&
        base_prefix_world_hash_disjoint(suffix,index_first(dc(index_first(saved)))),
        u => p143cb_resume(prepared,suffix,bound,logging),
        u => base_prefix_world_check_admitted(prepared,prefix,suffix,bound))

@unsafe
def p143cb_check_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String,
    +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool, +logging: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      nt_choose(DChecking,ready && String.is_empty(error) &&
        base_prefix_world_admitted(state,suffix,bound,final,saved),
        u => p143cb_admitted(prepared,prefix,suffix,bound,logging),
        u => dg_check_world(book))

@unsafe
def p143cb_check_load(+prepared: KBasePreparedWorld, load: FPrefixLoad, +logging: Bool) -> DChecking:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}:
              p143cb_check_book(prepared,book,error,prefix,suffix,ready,logging)

@unsafe
def p143cb_program_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String,
    +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool,
    +origins: List<&2,DOrigin>, +logging: Bool) -> DResult:
  match prepared:
    case KBasePreparedWorld{state,original,final,saved,checked,seen,todos,checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state),norm_max_book(suffix))
      nt_choose(DResult,ready && String.is_empty(error) &&
        base_prefix_world_admitted(state,suffix,bound,final,saved),
        u => driver_program_checked_prefix(suffix,todos,origins,
          p143cb_admitted(prepared,prefix,suffix,bound,logging)),
        u => driver_program_checked(book,origins,dg_check_world(book)))

@unsafe
def p143cb_program(load: FPrefixLoad, +origins: List<&2,DOrigin>, +prepared: KBasePreparedWorld,
    +logging: Bool) -> DResult:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{book,error,imports}:
              p143cb_program_book(prepared,book,error,prefix,suffix,ready,origins,logging)

# This optional private planner boundary reproduces p86_plan_loaded. A future
# qualified hook can delegate only that one entry here; dg_check_events and the
# original prepared-Base checker remain independent reference implementations.
@unsafe
def p143cb_plan_loaded(+seed: P86Seed, +load: FPrefixLoad, +logging: Bool) -> P86Plan:
  match seed load:
    case P86Seed{base,book,fresh,ready,+world} FPrefixLoad{trace,prefix,suffix,eligible}:
      match trace:
        case FLoadTrace{result,done,sources}:
          match result:
            case FResult{+original,+error,imports}:
              nt_choose(P86Plan,String.is_empty(error),
                u => p86_plan_checked(load,world,original,p143cb_program(load,[],world,logging)),
                u => P86PlanError{"parse: " ++ error})
