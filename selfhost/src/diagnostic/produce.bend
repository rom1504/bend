
# Module: src/diagnostic/produce.bend:99
type DChecking is Data:
  DChecking{+result: KChecking, +diagnostic: DDiagnostic}

# Module: src/diagnostic/produce.bend:4
law dg_origin_found:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +rest: List<&2, KTerm>
  for +found: DSpan
  DSpan

# Module: src/diagnostic/produce.bend:11
law check_book_diagnostic:
  for +book: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  DResult

# Module: src/diagnostic/produce.bend:16
law dg_quant_error:
  for +world: KWorld
  for +message: String
  for +name: String
  for +allowed: U32
  for +used: U32
  KChecking

# Module: src/diagnostic/produce.bend:24
law dg_constructor_names:
  for +ds: List<&2, KDef>
  String

# Module: src/diagnostic/produce.bend:28
law dg_ctor_error:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  for +ctr: KDef
  KChecking

# Module: src/diagnostic/produce.bend:35
law dg_adt_error:
  for +world: KWorld
  for +t: KTerm
  for +d: KDef
  KChecking

# Module: src/diagnostic/produce.bend:116
law dg_check_events:
  for +todo: List<&2,KDef>
  for +world: KWorld
  for +seen: List<&2,KDef>
  DChecking

# Module: src/diagnostic/produce.bend:201
law dg_result_error:
  for +result: DResult
  String

# Module: src/diagnostic/produce.bend:42
@unsafe
def dg_has_span(+s: DSpan) -> Bool:
  match s:
    case DNoSpan{}: False{}
    case DSpan{source, begin, end}: True{}

# Positive ranges resolve by their owning immutable source interval, not by
# definition names or structural term equality. EOF is the reserved last point.

# Module: src/diagnostic/produce.bend:50
@unsafe
def dg_origin_span(+origins: List<&2,DOrigin>, +begin: U32, +end: U32) -> DSpan:
  match origins:
    case Nil{}: DNoSpan{}
    case Con{DSourceOrigin{source, first, limit}, rest}:
      kc(DSpan, U32.is_gt(first, 0) && U32.is_gt(limit, first) && U32.is_ge(begin, first) && U32.is_ge(end, begin) && U32.is_lt(end, limit),
        u => DSpan{source, U32.sub(begin, first), U32.sub(end, first)},
        u => dg_origin_span(rest, begin, end))

# Module: src/diagnostic/produce.bend:59
@unsafe
def dg_origin_trail(
  +origins: List<&2, DOrigin>,
  +name: String,
  +trail: List<&2, KTerm>,
) -> DSpan:
  match trail:
    case Nil{}: DNoSpan{}
    case Con{h, rest}: dg_origin_found(origins, name, rest, dg_origin_span(origins, kb(h), ke(h)))

# Module: src/diagnostic/produce.bend:69
@unsafe
def dg_origin_found(origins, name, rest, found):
  kc(DSpan, dg_has_span(found), u => found, u => dg_origin_trail(origins, name, rest))

# Module: src/diagnostic/produce.bend:73
@unsafe
def diagnostic_locate(
  +diagnostic: DDiagnostic,
  +origins: List<&2, DOrigin>,
) -> DDiagnostic:
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      DDiagnostic{expected, observed, has_observed, context, definition, kc(DSpan, dg_has_span(span), u => span, u => dg_origin_trail(origins, definition, trail)), note, trail}

# Module: src/diagnostic/produce.bend:82
@unsafe
def diagnostic_result_locate(
  +result: DResult,
  +origins: List<&2, DOrigin>,
) -> DResult:
  match result:
    case DResult{error, book, diagnostic}: DResult{error, book, diagnostic_locate(diagnostic, origins)}

# Module: src/diagnostic/produce.bend:90
@unsafe
def dg_finish(
  +error: String,
  +book: List<&2, KDef>,
  +diagnostic: DDiagnostic,
  +origins: List<&2, DOrigin>,
) -> DResult:
  DResult{error, book, diagnostic_locate(diagnostic, origins)}

# One source-event checker carries semantic state and diagnostic metadata.

# Module: src/diagnostic/produce.bend:103
@unsafe
def dg_checking_result(+r: DChecking) -> KChecking:
  match r:
    case DChecking{result, diagnostic}: result

# Module: src/diagnostic/produce.bend:108
@unsafe
def dg_check_world(+book: List<&2,KDef>) -> DChecking:
  dg_check_seed(book, norm_max_book(book))

# Module: src/diagnostic/produce.bend:112
@unsafe
def dg_check_seed(+book: List<&2,KDef>, +bound: U32) -> DChecking:
  +seed = book_cached(Nil{}, bound)
  dg_check_events(book, kw_seed(check_declarations(book, seed), bound), seed)

# Module: src/diagnostic/produce.bend:123
@unsafe
def dg_check_events(todo, world, seen):
  match todo:
    case Nil{}: DChecking{bad(world, ""), dg_no_report("", "")}
    case Con{d, rest}:
      dg_check_guard(rest, world, seen, d, event_error(seen, d, lookup(seen, dn(d))))

# Module: src/diagnostic/produce.bend:130
@unsafe
def dg_check_guard(+rest: List<&2,KDef>, +world: KWorld, +seen: List<&2,KDef>, +d: KDef, +guard: String) -> DChecking:
  kc(DChecking, p88_string_eq(guard, ""),
    u => dg_check_next(rest, seen, d, check_definition_world(world, signature_mode(d, rest), 0)),
    u => DChecking{bad(world, dn(d) ++ ": " ++ guard), dg_no_report(dn(d), guard)})

# Module: src/diagnostic/produce.bend:136
@unsafe
def dg_check_next(+rest: List<&2,KDef>, +seen: List<&2,KDef>, +d: KDef, +r: KChecking) -> DChecking:
  kc(DChecking, good(r),
    u => dg_check_events(rest, dg_event_publish(rest, d, r), book_put(seen, d)),
    u => dg_event_failed(r, dn(d)))

# Module: src/diagnostic/produce.bend:142
@unsafe
def dg_event_failed(+r: KChecking, +fallback: String) -> DChecking:
  +owner = kc(String, p98_tag_eq(ct(r), "DTrace"), u => nm(ct(r)), u => fallback)
  DChecking{KChecking{ct(r), cy(r), cs(r), kc(String, p88_string_eq(owner, ""), u => "", u => owner ++ ": ") ++ ce(r), rw(r), rx(r)}, dg_report(r, fallback)}

# Module: src/diagnostic/produce.bend:147
@unsafe
def dg_event_publish(+rest: List<&2,KDef>, +d: KDef, +r: KChecking) -> KWorld:
  kc(KWorld, p88_string_eq(dk(lookup(rest, dn(d))), "Absent"),
    u => kw_put_checked(kw_with_book(rw(r), book_put(kw_book(rw(r)), d)), dg_event_output(d, ct(r))),
    u => rw(r))

# Module: src/diagnostic/produce.bend:153
@unsafe
def dg_event_output(+d: KDef, +body: KTerm) -> KDef:
  kc(KDef, p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(p98_tag_eq(dv(d), "Absent")) && Bool.not(p98_tag_eq(dv(d), "Foreign")),
    u => KDef{dn(d), dk(d), da(d), dx(d), dt(d), body, dc(d), db(d), du(d)},
    u => d)

# Module: src/diagnostic/produce.bend:159
@unsafe
def check_book_diagnostic(book, origins):
  dg_legacy_result(book, origins, dg_check_world(book))

# Module: src/diagnostic/produce.bend:163
@unsafe
def dg_legacy_result(+original: List<&2,KDef>, +origins: List<&2,DOrigin>, +r: DChecking) -> DResult:
  match r:
    case DChecking{result, diagnostic}:
      kc(DResult, good(result),
        u => dg_legacy_finish(original, origins, kw_book(rw(result)), check_open(kw_book(rw(result)))),
        u => dg_finish(ce(result), kw_book(rw(result)), diagnostic, origins))

# Module: src/diagnostic/produce.bend:171
@unsafe
def dg_legacy_finish(+original: List<&2,KDef>, +origins: List<&2,DOrigin>, +book: List<&2,KDef>, +error: String) -> DResult:
  dg_finish(error, kc(List<&2,KDef>, p88_string_eq(error, ""), u => original, u => book), dg_no_report("", error), origins)

# Module: src/diagnostic/produce.bend:175
@unsafe
def dg_quant_error(world, message, name, allowed, used):
  dg_bad_detail(world, message, dg_text(kp_quant(allowed) ++ name), dg_text(kc(String, U32.is_eq(used, 2), u => name ++ " (consumed more than once)", u => kp_quant(used) ++ name)))

# Module: src/diagnostic/produce.bend:179
@unsafe
def dg_constructor_names(ds):
  match ds:
    case Nil{}: ""
    case Con{d, rest}: name_key(dn(d)) ++ kc(String, defs_empty(rest), u => "", u => ", " ++ dg_constructor_names(rest))

# Module: src/diagnostic/produce.bend:185
@unsafe
def dg_ctor_error(e, t, ty, ctr):
  kc(KChecking, Bool.not(p88_string_eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))), u => dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text(name_key(nm(t)) ++ " with " ++ U32.show(da(ctr)) ++ kc(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields")), t), u => kc(KChecking, p88_string_eq(dg_family(cb(e), nm(t)), ""), u => dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text("a declared constructor (" ++ name_key(nm(ty)) ++ " declares " ++ dg_constructor_names(dc(lookup(cb(e), nm(ty)))) ++ ")"), t), u => dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", ty, ref(dg_family(cb(e), nm(t))))))


# Source-only prefix caches cannot restore live memo/output state. Recheck
# through the same event worker until a validated state-bearing cache exists.

# Module: src/diagnostic/produce.bend:192
@unsafe
def check_book_diagnostic_from_exact_prefix(+book: List<&2,KDef>, +validated: List<&2,KDef>, +origins: List<&2,DOrigin>) -> DResult:
  check_book_diagnostic(book, origins)

# The checker verdict stays unchanged; only rejection metadata differs.

# Module: src/diagnostic/produce.bend:197
@unsafe
def dg_adt_error(world, t, d):
  kc(KChecking, p88_string_eq(dk(d), "ADT"), u => dg_bad_detail(world, "unknown family or wrong parameter count", dg_text(name_key(nm(t)) ++ " with " ++ U32.show(da(d)) ++ kc(String, U32.is_eq(da(d), 1), u => " parameter", u => " parameters")), t), u => dg_bad_message(world, "unknown family or wrong parameter count", dg_text("a declared datatype (unknown: " ++ name_key(nm(t)) ++ ")")))

# Compatibility projections and explicit capability for hosts using one verdict.

# Module: src/diagnostic/produce.bend:205
@unsafe
def dg_result_error(result):
  match result:
    case DResult{error, book, diagnostic}: error

# Module: src/diagnostic/produce.bend:209
@unsafe
def compiler_check_result_abi() -> U32:
  2
