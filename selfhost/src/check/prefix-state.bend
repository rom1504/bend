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
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      ready && U32.is_eq(base_bound, norm_max_book(prefix)) && U32.is_ge(bound, base_bound) && U32.is_le(delta, 1048576) && U32.is_le(stamp, delta) && U32.is_le(bound, 1048576) && base_prefix_names(suffix) && prefix_state_disjoint(prefix, book_context(suffix)) && base_prefix_ctor_disjoint(suffix, final)

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
  +bound = norm_max_book(prefix_state_join(prefix, suffix))
  +final = base_prefix_final(prefix)
  kc(DChecking, base_prefix_admitted_final(state, prefix, suffix, bound, final),
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
