import Base

# Optional rejection-only replay. The original check_book verdict is always authoritative.
law dg_span_same:
  for +a: DSpan
  for +b: DSpan
  Bool

law dg_span_fields:
  for +s: String
  for +b0: U32
  for +e0: U32
  for +b: DSpan
  Bool

law dg_has_span:
  for +s: DSpan
  Bool

law dg_origin_scan:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +t: KTerm
  for +found: DSpan
  DSpan

law dg_origin_trail:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +trail: List<&2, KTerm>
  DSpan

law dg_origin_found:
  for +origins: List<&2, DOrigin>
  for +name: String
  for +rest: List<&2, KTerm>
  for +found: DSpan
  DSpan

law diagnostic_locate:
  for +diagnostic: DDiagnostic
  for +origins: List<&2, DOrigin>
  DDiagnostic

law diagnostic_result_locate:
  for +result: DResult
  for +origins: List<&2, DOrigin>
  DResult

law dg_finish:
  for +error: String
  for +book: List<&2, KDef>
  for +diagnostic: DDiagnostic
  for +origins: List<&2, DOrigin>
  DResult

law check_book_diagnostic:
  for +book: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  DResult

law dg_book_checked:
  for +book: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  for +error: String
  DResult

law dg_events:
  for +todo: List<&2, KDef>
  for +done: List<&2, KDef>
  for +origins: List<&2, DOrigin>
  for +error: String
  DResult

law dg_event_guard:
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  for +d: KDef
  for +origins: List<&2, DOrigin>
  for +error: String
  for +guard: String
  DResult

law dg_event_check:
  for +rest: List<&2, KDef>
  for +done: List<&2, KDef>
  for +d: KDef
  for +origins: List<&2, DOrigin>
  for +error: String
  for +checked: String
  DResult

law dg_definition:
  for +book: List<&2, KDef>
  for +d: KDef
  KChecked

law dg_definition_type:
  for +book: List<&2, KDef>
  for +d: KDef
  for +r: KChecked
  KChecked

law dg_template:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  KChecked

law dg_template_binder:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  KChecked

law dg_template_open:
  for +book: List<&2, KDef>
  for +d: KDef
  for +ty: KTerm
  for +body: KTerm
  for +lhs: KTerm
  for +n: U32
  for +name: String
  KChecked

law dg_quant_error:
  for +message: String
  for +name: String
  for +allowed: U32
  for +used: U32
  KChecked

law dg_constructor_names:
  for +ds: List<&2, KDef>
  String

law dg_ctor_error:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  for +ctr: KDef
  KChecked

@unsafe
def dg_span_same(a, b):
  match a:
    case DNoSpan{}: False{}
    case DSpan{s, b0, e0}: dg_span_fields(s, b0, e0, b)

@unsafe
def dg_span_fields(s, b0, e0, b):
  match b:
    case DNoSpan{}: False{}
    case DSpan{t, b1, e1}: String.eq(s, t) && U32.is_eq(b0, b1) && U32.is_eq(e0, e1)

@unsafe
def dg_has_span(s):
  match s:
    case DNoSpan{}: False{}
    case DSpan{source, begin, end}: True{}

@unsafe
def dg_origin_scan(origins, name, t, found):
  match origins:
    case Nil{}: found
    case Con{DOrigin{definition, term, source, begin, end, path}, rest}:
      kc(DSpan, String.eq(name, definition) && norm_exact(t, term), u => kc(DSpan, Bool.not(dg_has_span(found)) || dg_span_same(found, DSpan{source, begin, end}), u => dg_origin_scan(rest, name, t, DSpan{source, begin, end}), u => DNoSpan{}), u => dg_origin_scan(rest, name, t, found))

@unsafe
def dg_origin_trail(origins, name, trail):
  match trail:
    case Nil{}: DNoSpan{}
    case Con{h, rest}: dg_origin_found(origins, name, rest, dg_origin_scan(origins, name, h, DNoSpan{}))

@unsafe
def dg_origin_found(origins, name, rest, found):
  kc(DSpan, dg_has_span(found), u => found, u => dg_origin_trail(origins, name, rest))

@unsafe
def diagnostic_locate(diagnostic, origins):
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      DDiagnostic{expected, observed, has_observed, context, definition, kc(DSpan, dg_has_span(span), u => span, u => dg_origin_trail(origins, definition, trail)), note, trail}

@unsafe
def diagnostic_result_locate(result, origins):
  match result:
    case DResult{error, book, diagnostic}: DResult{error, book, diagnostic_locate(diagnostic, origins)}

@unsafe
def dg_finish(error, book, diagnostic, origins):
  DResult{error, book, diagnostic_locate(diagnostic, origins)}

@unsafe
def check_book_diagnostic(book, origins):
  dg_book_checked(book, origins, check_book(book))

@unsafe
def dg_book_checked(book, origins, error):
  kc(DResult, String.eq(error, ""), u => DResult{"", book, dg_no_report("", "")}, u => dg_events(book, book_cached(Nil{}, norm_max_book(book)), origins, error))

@unsafe
def dg_events(todo, done, origins, error):
  match todo:
    case Nil{}: dg_finish(error, done, dg_no_report("", error), origins)
    case Con{d, rest}: dg_event_guard(rest, done, d, origins, error, event_error(done, d, lookup(done, dn(d))))

@unsafe
def dg_event_guard(rest, done, d, origins, error, guard):
  kc(DResult, String.eq(guard, ""), u => dg_event_check(rest, done, d, origins, error, check_definition(book_put(done, declared(d)), signature_mode(d, rest))), u => dg_finish(error, done, dg_no_report(dn(d), guard), origins))

@unsafe
def dg_event_check(rest, done, d, origins, error, checked):
  kc(DResult, String.eq(checked, ""), u => dg_events(rest, book_put(done, d), origins, error), u => dg_finish(error, book_put(done, declared(d)), dg_report(dg_definition(book_put(done, declared(d)), signature_mode(d, rest)), dn(d)), origins))

@unsafe
def dg_definition(book, d):
  dg_definition_type(book, d, check(KEnv{book, dn(d), ref(dn(d)), 0, Nil{}, du(d)}, Nil{}, dt(d), 0, typ(1)))

@unsafe
def dg_definition_type(book, d, r):
  kc(KChecked, Bool.not(good(r)), u => r, u => kc(KChecked, String.eq(dk(d), "ADT") || String.eq(tg(dv(d)), "Absent") || String.eq(tg(dv(d)), "Foreign"), u => bad(check_definition(book, d)), u => dg_template(book, d, dt(d), dv(d), ref(dn(d)), dx(d))))

@unsafe
def dg_template(book, d, ty, body, lhs, n):
  kc(KChecked, U32.is_eq(n, 0), u => check(KEnv{book, dn(d), lhs, self_pending(d, body), tele_quantities(book, dt(d), da(d)), du(d)}, Nil{}, body, 1, ty), u => dg_template_binder(book, d, wnf(book, ty), body, lhs, n))

@unsafe
def dg_template_binder(book, d, ty, body, lhs, n):
  kc(KChecked, String.eq(tg(ty), "All"), u => dg_template_open(book, d, ty, body, lhs, n, dn(d) ++ "~" ++ nm(ty) ++ U32.show(ix(ty))), u => bad("template telescope is too short"))

@unsafe
def dg_template_open(book, d, ty, body, lhs, n, name):
  dg_template(book_put(book, KDef{name, "Def", 0, 0, kid(ty, 0), atom("Absent"), Nil{}, True{}, False{}}), d, subst(kid(ty, 1), ix(ty), ref(name)), kapply(body, ref(name)), app(lhs, ref(name)), U32.sub(n, 1))

@unsafe
def dg_quant_error(message, name, allowed, used):
  dg_bad_detail(message, dg_text(kp_quant(allowed) ++ name), dg_text(kc(String, U32.is_eq(used, 2), u => name ++ " (consumed more than once)", u => kp_quant(used) ++ name)))

@unsafe
def dg_constructor_names(ds):
  match ds:
    case Nil{}: ""
    case Con{d, rest}: dn(d) ++ kc(String, defs_empty(rest), u => "", u => ", " ++ dg_constructor_names(rest))

@unsafe
def dg_ctor_error(e, t, ty, ctr):
  kc(KChecked, Bool.not(String.eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))), u => dg_bad_detail("constructor does not belong to goal or field count differs", dg_text(nm(t) ++ " with " ++ U32.show(da(ctr)) ++ kc(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields")), t), u => kc(KChecked, String.eq(dg_family(cb(e), nm(t)), ""), u => dg_bad_detail("constructor does not belong to goal or field count differs", dg_text("a declared constructor (" ++ nm(ty) ++ " declares " ++ dg_constructor_names(dc(lookup(cb(e), nm(ty)))) ++ ")"), t), u => dg_bad_detail("constructor does not belong to goal or field count differs", ty, ref(dg_family(cb(e), nm(t))))))

