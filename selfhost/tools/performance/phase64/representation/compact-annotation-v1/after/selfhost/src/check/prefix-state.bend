import Base

# Private checked Base-prefix state; public KTerm and existing checker ABI stay unchanged.
@unsafe
def prefix_state_join(+left: List<&2,KDef>, +right: List<&2,KDef>) -> List<&2,KDef>:
  match left:
    case Nil{}: right
    case Con{h, rest}: Con{h, prefix_state_join(rest, right)}

law prefix_state_exact_defs:
  for +left: List<&2,KDef>
  for +right: List<&2,KDef>
  Bool

law prefix_state_exact_terms:
  for +left: List<&2,KTerm>
  for +right: List<&2,KTerm>
  Bool

@unsafe
def prefix_state_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KAnnotation{term, typ}:
      3
    case KLambda{name, id, quant, kids, removed, begin, end, present}: 1
    case KLiteral{kind, number, text, begin, end}: 2

# Unlike conversion/reflexivity, the snapshot key retains source intervals too.
@unsafe
def prefix_state_exact_term(+left: KTerm, +right: KTerm) -> Bool:
  U32.is_eq(prefix_state_variant(left), prefix_state_variant(right)) && norm_exact_head(left, right) && Bool.not(Bool.xor(k_quantity_present(left), k_quantity_present(right))) && U32.is_eq(kb(left), kb(right)) && U32.is_eq(ke(left), ke(right)) && prefix_state_exact_terms(ks(left), ks(right))

@unsafe
def prefix_state_exact_terms(left, right):
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}: kc(Bool, prefix_state_exact_term(a, b), u => prefix_state_exact_terms(ar, br), u => False{})
    case other_left other_right: False{}

@unsafe
def prefix_state_exact_bool(+a: Bool, +b: Bool) -> Bool:
  kc(Bool, a, u => b, u => Bool.not(b))

@unsafe
def prefix_state_exact_def(+a: KDef, +b: KDef) -> Bool:
  String.eq(dn(a), dn(b)) && String.eq(dk(a), dk(b)) && U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && prefix_state_exact_bool(db(a), db(b)) && prefix_state_exact_bool(du(a), du(b)) && prefix_state_exact_term(dt(a), dt(b)) && prefix_state_exact_term(dv(a), dv(b)) && prefix_state_exact_defs(dc(a), dc(b))

@unsafe
def prefix_state_exact_defs(left, right):
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}: kc(Bool, prefix_state_exact_def(a, b), u => prefix_state_exact_defs(ar, br), u => False{})
    case other_left other_right: False{}

@unsafe
def prefix_state_headers(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{kc(KDef, String.eq(tg(dv(d)), "Foreign"), u => d, u => declared(d)), prefix_state_headers(rest)}

# Prefix fills must be internal to the prefix. Otherwise dg_event_publish and
# signature_mode inspect suffix bodies; header equality would not suffice.
@unsafe
def prefix_state_disjoint(+prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> Bool:
  match prefix:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, String.eq(dk(lookup(suffix, dn(d))), "Absent"), u => prefix_state_disjoint(rest, suffix), u => False{})

# Cold-prefix experiment. PRIVATE prepared capability only; not yet selected.
# No carrier is inferred from a source-only validation marker. The driver must
# bind it to the exact checked API, Base bytes and source interval before use.
# Fresh-offset equivariance remains a separate source-review/control obligation.
type KBasePrefixState is Data:
  KBasePrefixState{+bound: U32, +delta: U32, +stamp: U32, +patches: List<&2,KDef>, +ready: Bool}

law base_prefix_patch:
  for +defs: List<&2,KDef>
  for +patches: List<&2,KDef>
  List<&2,KDef>

law base_prefix_deltas:
  for +defs: List<&2,KDef>
  for +raw: List<&2,KDef>
  List<&2,KDef>

@unsafe
def base_prefix_final(+prefix: List<&2,KDef>) -> List<&2,KDef>:
  book_final_reverse(book_final_fast(prefix, Nil{}), Nil{})

@unsafe
def base_prefix_deltas(defs, raw):
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, prefix_state_exact_def(d, lookup(raw, dn(d))),
      u => base_prefix_deltas(rest, raw), u => Con{d, base_prefix_deltas(rest, raw)})

@unsafe
def base_prefix_patch(defs, patches):
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{kc(KDef, String.eq(dk(lookup(patches, dn(d))), "Absent"), u => d, u => lookup(patches, dn(d))), base_prefix_patch(rest, patches)}

@unsafe
def base_prefix_put(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  book_put_many(book, defs)

@unsafe
def base_prefix_seen(+prefix: List<&2,KDef>, +bound: U32) -> List<&2,KDef>:
  base_prefix_put(book_cached(Nil{}, bound), prefix)

# Only raw Ref/ADT names may query definitions while checking this closed seed.
# Synthetic comptime binders use the reserved ~ namespace checked on the suffix.
@unsafe
def base_prefix_closed_terms(+terms: List<&2,KTerm>, +context: List<&2,KDef>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, (Bool.not(String.eq(tg(t), "Ref") || String.eq(tg(t), "ADT")) || Bool.not(String.eq(dk(lookup(context, nm(t))), "Absent"))),
      u => base_prefix_closed_terms(norm_join(ks(t), rest), context), u => False{})

@unsafe
def base_prefix_closed(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, base_prefix_closed_terms(Con{dt(d), Con{dv(d), Nil{}}}, context) && base_prefix_closed(dc(d), context), u => base_prefix_closed(rest, context), u => False{})

@unsafe
def base_prefix_names(+defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, Bool.not(String.eq(dn(d), "")) && Bool.not(String.contains(dn(d), "~")) && Bool.not(String.contains(dn(d), "$kernel.")) && (String.eq(dk(d), "Def") || String.eq(dk(d), "ADT") || String.eq(dk(d), "Ctr")) && base_prefix_names(dc(d)), u => base_prefix_names(rest), u => False{})

@unsafe
def base_prefix_ctor_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, Bool.not(constructor_exists(context, dn(d))) && base_prefix_ctor_disjoint(dc(d), context), u => base_prefix_ctor_disjoint(rest, context), u => False{})

@unsafe
def base_prefix_native(+prefix: List<&2,KDef>) -> Bool:
  match prefix:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, db(d), u => base_prefix_native(rest), u => False{})

@unsafe
def base_prefix_world_raw(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, String.eq(dk(d), "BookCache"), u => rest, u => book)

@unsafe
def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:
  match book:
    case Nil{}: bound
    case Con{d, rest}: kc(U32, String.eq(dk(d), "BookCache"), u => da(d), u => bound)

@unsafe
def base_prefix_prepare_known(+prefix: List<&2,KDef>, +bound: U32, +result: DChecking, +world: KWorld, +next: U32) -> KBasePrefixState:
  +final = base_prefix_final(prefix)
  +checked = kw_checked(world)
  +stamp = base_prefix_stamp(kw_book(world), bound)
  +ordered = book_final_reverse(checked, Nil{})
  +patches = base_prefix_deltas(ordered, book_context(final))
  +seed = book_cached(Nil{}, bound)
  +replayed = kw_bound_book(base_prefix_put(check_declarations(prefix, seed), final), stamp)
  KBasePrefixState{bound, U32.sub(U32.sub(next, bound), 1), U32.sub(stamp, bound), patches,
    good(dg_checking_result(result)) && String.eq(check_open(kw_book(world)), "") && U32.is_gt(next, bound) && U32.is_ge(stamp, bound) && U32.is_le(stamp, U32.sub(next, 1)) && base_prefix_native(prefix) && base_prefix_names(prefix) && base_prefix_closed(prefix, book_context(final)) && List.is_empty(&2, KSpecMemo, kw_memo(world)) && U32.is_le(norm_max_book(checked), bound) && U32.is_le(norm_max_book(base_prefix_world_raw(kw_book(world))), bound) && prefix_state_exact_defs(base_prefix_patch(final, book_context(patches)), ordered) && prefix_state_exact_defs(replayed, kw_book(world))}

@unsafe
def base_prefix_prepare_fresh(+prefix: List<&2,KDef>, +bound: U32, +result: DChecking, +world: KWorld, +fresh: KWorldFresh) -> KBasePrefixState:
  match fresh:
    case KFreshKnown{next}: base_prefix_prepare_known(prefix, bound, result, world, next)
    case KFreshDeferred{roots}: KBasePrefixState{bound, 0, 0, Nil{}, False{}}

@unsafe
def base_prefix_prepare(+prefix: List<&2,KDef>) -> KBasePrefixState:
  +result = dg_check_world(prefix)
  +world = rw(dg_checking_result(result))
  base_prefix_prepare_fresh(prefix, norm_max_book(prefix), result, world, kw_fresh(world))

@unsafe
def base_prefix_admitted(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32) -> Bool:
  base_prefix_admitted_final(state, prefix, suffix, bound, base_prefix_final(prefix))

@unsafe
def base_prefix_admitted_final(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>) -> Bool:
  base_prefix_admitted_bound(state, prefix, suffix, bound, final, norm_max_book(prefix))

@unsafe
def base_prefix_admitted_bound(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>, +prefix_bound: U32) -> Bool:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      ready && U32.is_eq(base_bound, prefix_bound) && U32.is_ge(bound, base_bound) && U32.is_le(delta, 1048576) && U32.is_le(stamp, delta) && U32.is_le(bound, 1048576) && base_prefix_names(suffix) && prefix_state_disjoint(prefix, book_context(suffix)) && base_prefix_ctor_disjoint(suffix, final)

@unsafe
def base_prefix_resume_saved(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>) -> DChecking:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      +ordered = base_prefix_patch(final, book_context(patches))
      +seed = book_cached(Nil{}, bound)
      +declared = check_declarations(prefix_state_join(prefix, suffix), seed)
      +world: KWorld = KWorld{kw_bound_book(base_prefix_put(declared, final), U32.add(bound, stamp)), Nil{}, KFreshKnown{U32.add(U32.add(bound, delta), 1)}, book_final_reverse(ordered, Nil{})}
      dg_check_events(suffix, world, base_prefix_seen(prefix, bound))

@unsafe
def base_prefix_resume(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> DChecking:
  +prefix_bound = norm_max_book(prefix)
  +suffix_bound = norm_max_book(suffix)
  +bound = norm_max(prefix_bound, suffix_bound)
  +final = base_prefix_final(prefix)
  kc(DChecking, base_prefix_admitted_bound(state, prefix, suffix, bound, final, prefix_bound),
    u => base_prefix_resume_saved(state, prefix, suffix, bound, final),
    u => dg_check_world(prefix_state_join(prefix, suffix)))

type KBasePrefixTail is Data:
  KBasePrefixTail{+suffix: List<&2,KDef>, +matched: Bool}

@unsafe
def base_prefix_split(+book: List<&2,KDef>, +prefix: List<&2,KDef>) -> KBasePrefixTail:
  match prefix:
    case Nil{}: KBasePrefixTail{book, True{}}
    case Con{d, rest}: base_prefix_split_head(book, d, rest)

@unsafe
def base_prefix_split_head(+book: List<&2,KDef>, +d: KDef, +rest: List<&2,KDef>) -> KBasePrefixTail:
  match book:
    case Nil{}: KBasePrefixTail{Nil{}, False{}}
    case Con{h, tail}: kc(KBasePrefixTail, prefix_state_exact_def(d, h), u => base_prefix_split(tail, rest), u => KBasePrefixTail{Nil{}, False{}})

@unsafe
def base_prefix_check_tail(+state: KBasePrefixState, +book: List<&2,KDef>, +prefix: List<&2,KDef>, +tail: KBasePrefixTail) -> DChecking:
  match tail:
    case KBasePrefixTail{suffix, matched}: kc(DChecking, matched, u => base_prefix_resume(state, prefix, suffix), u => dg_check_world(book))

@unsafe
def base_prefix_check(+state: KBasePrefixState, +book: List<&2,KDef>, +prefix: List<&2,KDef>) -> DChecking:
  base_prefix_check_tail(state, book, prefix, base_prefix_split(book, prefix))

# PRIVATE driver-only consumer of the native loader's provenance carrier.
# Its actual suffix was produced by f_prefix_graph_trace, not supplied as an
# independent argument. Raw public state/book checks above retain exact split.
@unsafe
def base_prefix_check_load(+state: KBasePrefixState, +load: FPrefixLoad) -> DChecking:
  match load:
    case FPrefixLoad{trace, prefix, suffix, ready}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{book, error, imports}:
              kc(DChecking, ready && String.is_empty(error),
                u => base_prefix_resume(state, prefix, suffix),
                u => dg_check_world(book))

# Optional driver bridge. Only its private authenticated seed path calls this;
# the original check_program_diagnostic method remains the complete checker.
@unsafe
def check_program_diagnostic_seed(+book: List<&2,KDef>, +validated: List<&2,KDef>, +origins: List<&2,DOrigin>, +state: KBasePrefixState) -> DResult:
  driver_program_checked(book, origins, base_prefix_check(state, book, validated))

@unsafe
def check_program_diagnostic_prefix(+load: FPrefixLoad, +validated: List<&2,KDef>, +origins: List<&2,DOrigin>, +state: KBasePrefixState) -> DResult:
  match load:
    case FPrefixLoad{trace, prefix, suffix, ready}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{book, error, imports}:
              driver_program_checked(book, origins, base_prefix_check_load(state, load))

# PRIVATE ready world. Its producer consumes the identity-bound checked prefix
# state; the driver binds this whole immutable record to that same Base seed.
# Raw books and old prefix-state exports retain their full admission paths.
type KBasePreparedWorld is Data:
  KBasePreparedWorld{+state: KBasePrefixState, +prefix: List<&2,KDef>, +final: List<&2,KDef>, +book: List<&2,KDef>, +checked: List<&2,KDef>, +seen: List<&2,KDef>, +todos: U32}

@unsafe
def base_prefix_world_prepare(+prefix: List<&2,KDef>, +state: KBasePrefixState) -> KBasePreparedWorld:
  +bound = norm_max_book(prefix)
  +final = base_prefix_final(prefix)
  kc(KBasePreparedWorld, base_prefix_admitted_bound(state, prefix, Nil{}, bound, final, bound),
    u => base_prefix_world_saved(prefix, state, final, bound, rw(dg_checking_result(base_prefix_resume_saved(state, prefix, Nil{}, bound, final)))),
    u => KBasePreparedWorld{KBasePrefixState{bound, 0, 0, Nil{}, False{}}, prefix, final, Nil{}, Nil{}, Nil{}, 0})

@unsafe
def base_prefix_world_saved(+prefix: List<&2,KDef>, +state: KBasePrefixState, +final: List<&2,KDef>, +bound: U32, +world: KWorld) -> KBasePreparedWorld:
  KBasePreparedWorld{state, prefix, final, kw_book(world), kw_checked(world), base_prefix_seen(prefix, bound), driver_count_todos(final)}

# Sequential declaration installation puts suffix headers first in the list,
# but prefix event publication historically puts Base definitions first. Keep
# that observable list order while retaining the already extended lookup index.
# Only list cells are copied; Base terms and index subtrees stay shared.
@unsafe
def base_prefix_world_order(+declared: List<&2,KDef>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> List<&2,KDef>:
  match suffix:
    case Nil{}: declared
    case Con{d, rest}: base_prefix_world_order_tail(declared, prefix, suffix)

@unsafe
def base_prefix_world_order_tail(+book: List<&2,KDef>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, more}: Con{cache, prefix_state_join(prefix, book_final_fast(prefix_state_headers(suffix), Nil{}))}

@unsafe
def base_prefix_resume_world(+prepared: KBasePreparedWorld, +suffix: List<&2,KDef>, +bound: U32) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state, prefix, final, book, checked, seen, todos}:
      base_prefix_world_resume_state(state, book, checked, seen, suffix, bound)

@unsafe
def base_prefix_world_resume_state(+state: KBasePrefixState, +book: List<&2,KDef>, +checked: List<&2,KDef>, +seen: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32) -> DChecking:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      +declared = check_declarations(suffix, kw_bound_book(book, U32.add(bound, stamp)))
      +ordered = base_prefix_world_order(declared, base_prefix_world_raw(book), suffix)
      +world: KWorld = KWorld{ordered, Nil{}, KFreshKnown{U32.add(U32.add(bound, delta), 1)}, checked}
      dg_check_events(suffix, world, kw_bound_book(seen, bound))

# Full hash collisions preserve lookup semantics but change the exact bucket
# event order when suffix headers move after Base publication. Retain the old
# replay path for that rare case instead of weakening whole-world equality.
@unsafe
def base_prefix_world_hash_disjoint(+suffix: List<&2,KDef>, +index: KDef) -> Bool:
  match suffix:
    case Nil{}: True{}
    case Con{d, rest}:
      +hash = index_hash(dn(d), 2166136261)
      +tip = index_tip(index, hash)
      kc(Bool, String.eq(dk(tip), "Absent") || Bool.not(U32.is_eq(da(tip), hash)),
        u => base_prefix_world_hash_disjoint(rest, index), u => False{})

@unsafe
def base_prefix_world_names_disjoint(+suffix: List<&2,KDef>, +saved: List<&2,KDef>) -> Bool:
  match suffix:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, String.eq(dk(lookup(saved, dn(d))), "Absent"),
      u => base_prefix_world_names_disjoint(rest, saved), u => False{})

# The saved index contains every prefix name. Reverse the old intersection
# query so admission does not rebuild a suffix index or walk the Base prefix.
@unsafe
def base_prefix_world_admitted(+state: KBasePrefixState, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>, +saved: List<&2,KDef>) -> Bool:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      ready && U32.is_ge(bound, base_bound) && U32.is_le(delta, 1048576) && U32.is_le(stamp, delta) && U32.is_le(bound, 1048576) && base_prefix_names(suffix) && base_prefix_world_names_disjoint(suffix, saved) && base_prefix_ctor_disjoint(suffix, final)

# The driver must couple prepared and load through the same authenticated Base
# injection. In that private scope state.bound is the already proved maximum
# of load.prefix, and only newly freshened suffix terms need a maximum scan.
@unsafe
def base_prefix_check_world_load(+prepared: KBasePreparedWorld, +load: FPrefixLoad) -> DChecking:
  match load:
    case FPrefixLoad{trace, prefix, suffix, ready}:
      base_prefix_check_world_trace(prepared, trace, prefix, suffix, ready)

@unsafe
def base_prefix_check_world_trace(+prepared: KBasePreparedWorld, +trace: FLoadTrace, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool) -> DChecking:
  match trace:
    case FLoadTrace{result, done, sources}:
      base_prefix_check_world_result(prepared, result, prefix, suffix, ready)

@unsafe
def base_prefix_check_world_result(+prepared: KBasePreparedWorld, +result: FResult, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool) -> DChecking:
  match result:
    case FResult{book, error, imports}:
      base_prefix_check_world_book(prepared, book, error, prefix, suffix, ready)

@unsafe
def base_prefix_world_bound(+state: KBasePrefixState) -> U32:
  match state:
    case KBasePrefixState{bound, delta, stamp, patches, ready}: bound

@unsafe
def base_prefix_check_world_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state, original, final, saved, checked, seen, todos}:
      +bound = norm_max(base_prefix_world_bound(state), norm_max_book(suffix))
      kc(DChecking, ready && String.is_empty(error) && base_prefix_world_admitted(state, suffix, bound, final, saved),
        u => base_prefix_world_check_admitted(prepared, prefix, suffix, bound),
        u => dg_check_world(book))

@unsafe
def base_prefix_world_check_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32) -> DChecking:
  match prepared:
    case KBasePreparedWorld{state, original, final, saved, checked, seen, todos}:
      kc(DChecking, base_prefix_world_hash_disjoint(suffix, index_first(dc(index_first(saved)))),
        u => base_prefix_resume_world(prepared, suffix, bound),
        u => base_prefix_resume_saved(state, prefix, suffix, bound, final))

# Count holes in final original events, not elaborated bodies. Admitted prefix
# and suffix names are disjoint, so finalization cannot remove a prefix event.
# Version-two host admission binds this precomputed count to the actual world.
@unsafe
def base_prefix_program_world_book(+prepared: KBasePreparedWorld, +book: List<&2,KDef>, +error: String, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +ready: Bool, +origins: List<&2,DOrigin>) -> DResult:
  match prepared:
    case KBasePreparedWorld{state, original, final, saved, checked, seen, todos}:
      +bound = norm_max(base_prefix_world_bound(state), norm_max_book(suffix))
      kc(DResult, ready && String.is_empty(error) && base_prefix_world_admitted(state, suffix, bound, final, saved),
        u => driver_program_checked_prefix(suffix, todos, origins, base_prefix_world_check_admitted(prepared, prefix, suffix, bound)),
        u => driver_program_checked(book, origins, dg_check_world(book)))

@unsafe
def check_program_diagnostic_world(+load: FPrefixLoad, +origins: List<&2,DOrigin>, +prepared: KBasePreparedWorld) -> DResult:
  match load:
    case FPrefixLoad{trace, prefix, suffix, ready}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{book, error, imports}:
              base_prefix_program_world_book(prepared, book, error, prefix, suffix, ready, origins)
