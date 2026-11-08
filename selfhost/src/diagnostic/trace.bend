
# Module: src/diagnostic/trace.bend:4
law dg_text:
  for +s: String
  KTerm

# Module: src/diagnostic/trace.bend:8
law dg_bad_detail:
  for +world: KWorld
  for +message: String
  for +expected: KTerm
  for +observed: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:15
law dg_bad_message:
  for +world: KWorld
  for +message: String
  for +expected: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:21
law dg_trace:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +r: KChecking
  KChecking

# Module: src/diagnostic/trace.bend:29
law dg_trace_detail:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +r: KChecking
  for +detail: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:37
law dg_reason:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +code: String
  KTerm

# Module: src/diagnostic/trace.bend:46
@unsafe
def dg_text(s):
  kt("DText", s, 0, 0, Nil{})

# Module: src/diagnostic/trace.bend:50
@unsafe
def dg_bad_detail(world, message, expected, observed):
  KChecking{kt("DDetail", "", 0, 1, [expected, observed]), {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, message, world, 0}

# Module: src/diagnostic/trace.bend:54
@unsafe
def dg_bad_message(world, message, expected):
  KChecking{kt("DDetail", "", 0, 0, [expected, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]), {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, message, world, 0}

# Module: src/diagnostic/trace.bend:58
@unsafe
def dg_pair(
  +expected: KTerm,
  +observed: KTerm,
) -> KTerm:
  kt("DDetail", "", 0, 1, [expected, observed])

# Module: src/diagnostic/trace.bend:65
@unsafe
def dg_family(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  match book:
    case Nil{}: ""
    case Con{d, rest}: kc(String, p88_string_eq(dk(d), "ADT") && Bool.not(p88_string_eq(dk(lookup(dc(d), name)), "Absent")), u => dn(d), u => dg_family(rest, name))

# Module: src/diagnostic/trace.bend:74
@unsafe
def dg_trace(e, ctx, t, ty, r):
  kc(KChecking, good(r), u => r, u => kc(KChecking, p98_tag_eq(ct(r), "DTrace"), u => KChecking{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), kid(ct(r), 3), kt("DTrail", "", 0, 0, norm_join(ks(kid(ct(r), 4)), [t])), kid(ct(r), 5)]), cy(r), cs(r), ce(r), rw(r), rx(r)}, u => dg_trace_detail(ke_world(e, rw(r)), ctx, t, r, kc(KTerm, p98_tag_eq(ct(r), "DDetail"), u => ct(r), u => dg_reason(ke_world(e, rw(r)), ctx, t, ty, ce(r))))))

# Module: src/diagnostic/trace.bend:78
@unsafe
def dg_unqualified_name(+rest: String, +name: String) -> String:
  match rest:
    case SNil{}: name
    case SCon{head,tail}: dg_unqualified_name(tail,kc(String,Char.is_eq(head,':'),u => tail,u => name))

@unsafe
def dg_datatype_braces(+book: List<&2,KDef>, +name: String) -> String:
  +bare = dg_unqualified_name(name,name)
  +found = kc(String,p88_string_eq(dk(lookup(book,name)),"ADT"),u => name,
    u => kc(String,p88_string_eq(dk(lookup(book,bare)),"ADT"),v => bare,v => ""))
  kc(String,Bool.not(String.is_empty(found)) && String.is_empty(dg_family(book,name)),
    u => "Note: " ++ found ++ " is a datatype: write its arguments as <>",u => "")

@unsafe
def dg_trace_detail(e, ctx, t, r, detail):
  KChecking{kt("DTrace", cn(e), 0, qt(detail), [kid(detail, 0), kid(detail, 1), kt("DCtx", "", 0, 0, ctx), t, kt("DTrail", "", 0, 0, [t]), dg_text(kc(String, p88_string_eq(ce(r), "constructor requires a datatype goal"), u => dg_datatype_braces(cb(e),nm(t)), u => ""))]), cy(r), cs(r), ce(r), rw(r), rx(r)}

# Module: src/diagnostic/trace.bend:82
@unsafe
def dg_reason(e, ctx, t, ty, code):
  kc(KTerm, p88_string_eq(code, "undefined name"), u => dg_pair(dg_text("a defined name"), t),
   u => kc(KTerm, p88_string_eq(code, "unbound variable"), u => dg_pair(dg_text("a bound variable"), kc(KTerm, p98_tag_eq(t, "FUnboundVar"), u => dg_text(nm(t) ++ kc(String, kp_bound(dg_scope(ctx, Nil{}), nm(t)), u => "^-1", u => "")), u => t)),
   u => kc(KTerm, p88_string_eq(code, "nondecreasing self-call"), u => dg_pair(dg_text("a decreasing self-call (arguments are read left to right: each passed unchanged until one shrinks)"), t),
   u => kc(KTerm, p88_string_eq(code, "live use of an unfilled law"), u => dg_pair(dg_text("a filled definition (an unfilled law is a dead claim: live code cannot use it)"), t),
   u => kc(KTerm, p88_string_eq(code, "a family requires angle-bracket parameters"), u => dg_pair(dg_text("a family instance (write " ++ name_key(nm(t)) ++ "<..>)"), t),
   u => kc(KTerm, p88_string_eq(code, "unresolved hole"), u => dg_pair(ty, t),
   u => kc(KTerm, p88_string_eq(code, "cannot infer: annotation required"), u => dg_pair(dg_text(kc(String, (p98_tag_eq(t, "Ctr") || core_literal(t)) && p88_string_eq(dg_family(cb(e), nm(kc(KTerm, core_literal(t), u => core_literal_step(t), u => t))), ""), u => "a declared constructor", u => "an annotated term (cannot infer)")), t),
   u => kc(KTerm, p88_string_eq(code, "lambda requires a function type") || p88_string_eq(code, "matcher requires a function type") || p88_string_eq(code, "reflexivity requires equality goal"), u => dg_pair(ty, dg_text("non-inferrable term")),
   u => kc(KTerm, p88_string_eq(code, "constructor requires a datatype goal"), u => dg_pair(ty, kc(KTerm, p88_string_eq(dg_family(cb(e), nm(t)), ""), u => dg_text("non-inferrable term"), u => ref(dg_family(cb(e), nm(t))))),
   u => kt("DDetail", "", 0, 0, [dg_text(code), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]))))))))))

# Module: src/diagnostic/trace.bend:95
@unsafe
def dg_as_expr(
  +t: KTerm,
) -> DExpr:
  kc(DExpr, p98_tag_eq(t, "DText"), u => DText{nm(t)}, u => DTerm{t})

# Module: src/diagnostic/trace.bend:101
@unsafe
def dg_no_report(
  +name: String,
  +message: String,
) -> DDiagnostic:
  DDiagnostic{DText{message}, DText{""}, False{}, Nil{}, name, DNoSpan{}, "", Nil{}}

# Module: src/diagnostic/trace.bend:108
@unsafe
def dg_report(
  +r: KChecking,
  +name: String,
) -> DDiagnostic:
  dg_report_payload(ct(r), ce(r), name)


# Keep the original closed-argument error, except an actual caller variable.

# Module: src/diagnostic/trace.bend:117
@unsafe
def dg_template_result(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, p88_string_eq(ce(r), "unbound variable") && p98_tag_eq(ct(r), "DTrace") && p98_tag_eq(kid(ct(r), 1), "Var") && Bool.not(p98_tag_eq(ctx_get(ctx, ix(kid(ct(r), 1))), "Absent")), u => dg_trace(e, ctx, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, kr_from(r, dg_bad_detail(rw(r), ce(r), dg_text("a template applied to closed ~ arguments (" ++ nm(kid(ct(r), 1)) ++ " is a variable here, not comptime: pass it at run time)"), t))), u => r)

# Module: src/diagnostic/trace.bend:121
@unsafe
def dg_kind_check(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +q: U32, +name: String) -> KChecking:
  dg_kind_at(e, ctx, t, q, name, t)

# Module: src/diagnostic/trace.bend:125
@unsafe
def dg_kind_at(+e: KEnv, +ctx: List<&2,KTerm>, +t: KTerm, +q: U32, +name: String, +site: KTerm) -> KChecking:
  +kind = typ(kindq(e, q))
  dg_kind_result(t, q, name, site, kind, check(e, ctx, t, 0, kind))

# Module: src/diagnostic/trace.bend:130
@unsafe
def dg_kind_result(+t: KTerm, +q: U32, +name: String, +site: KTerm, +kind: KTerm, +r: KChecking) -> KChecking:
  kc(KChecking, p88_string_eq(ce(r), "type mismatch") && p98_tag_eq(ct(r), "DTrace") && norm_exact(kid(ct(r), 0), kind) && norm_exact(kid(ct(r), 3), t) && (U32.is_eq(kb(t), 0) || U32.is_eq(kb(kid(ct(r), 3)), 0) || (U32.is_eq(kb(t), kb(kid(ct(r), 3))) && U32.is_eq(ke(t), ke(kid(ct(r), 3))))), u => KChecking{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), site, kt("DTrail", "", 0, 0, Con{site, ks(kid(ct(r), 4))}), kc(KTerm, U32.is_eq(q, 2), u => dg_text("Note: +" ++ name ++ " can be used many times, so its type must be Data."), u => kid(ct(r), 5))]), cy(r), cs(r), ce(r), rw(r), rx(r)}, u => r)

# Module: src/diagnostic/trace.bend:134
@unsafe
def dg_report_payload(+term: KTerm, +error: String, +name: String) -> DDiagnostic:
  kc(DDiagnostic, p98_tag_eq(term, "DTrace"), u => DDiagnostic{dg_as_expr(kid(term, 0)), dg_as_expr(kid(term, 1)), U32.is_eq(qt(term), 1), ks(kid(term, 2)), nm(term), DNoSpan{}, nm(kid(term, 5)), ks(kid(term, 4))}, u => dg_no_report(name, error))
