
# Module: src/front/literals_arrays.bend:3
law f_contains:
  for +s: String
  for +c: Char
  Bool

# Module: src/front/literals_arrays.bend:8
law f_float:
  for +s: String
  KTerm

# Module: src/front/literals_arrays.bend:12
law f_float_read:
  for +m: Maybe<&2, F32>
  KTerm

# Module: src/front/literals_arrays.bend:16
law f_array:
  for +ts: FInput
  FParsed

# Module: src/front/literals_arrays.bend:20
law f_array_first:
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:24
law f_array_type:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:29
law f_array_size:
  for +n: KTerm
  for +ty: KTerm
  for +count: Bool
  for +p: FParsed
  FParsed

# Module: src/front/literals_arrays.bend:36
law f_power_bits:
  for +n: U32
  for +d: U32
  KTerm

# Module: src/front/literals_arrays.bend:41
law f_index:
  for +n: KTerm
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/literals_arrays.bend:47
law f_index_value:
  for +n: KTerm
  for +idx: KTerm
  for +end: U32
  for +p: FParsed
  for +min: U32
  FParsed

# Module: src/front/literals_arrays.bend:55
law f_nat_extend:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:134
law f_namespace_head:
  for +t: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:138
law f_namespace_operator:
  for +head: KTerm
  for +input: FInput
  Bool

# Module: src/front/literals_arrays.bend:61
@unsafe
def f_contains(s, c):
  f_choose(Bool, String.is_empty(s), u => False{}, u => Char.is_eq(f_head(s), c) || f_contains(f_tail(s), c))

# Module: src/front/literals_arrays.bend:65
@unsafe
def f_float(s):
  f_float_read(F32.read(s))

# Module: src/front/literals_arrays.bend:69
@unsafe
def f_float_read(m):
  match m:
    case None{}:
      kt("Error", "invalid f32 literal", 0, 0, Nil{})
    case Some{v}:
      f_float_bits(F32.bits(v))

# Module: src/front/literals_arrays.bend:77
@unsafe
def f_array(ts):
  f_choose(FParsed, f_eq(f_tx(ts), ";"), u => f_err(ts, "expected term; a list does not use semicolon separators"), u => f_choose(FParsed, f_eq(f_tx(ts), "]"), u => FParsed{kt("Ctr", f_context_own("Nil", ts, True{}), 0, 1, Nil{}), f_tl(ts)}, u => f_array_first(f_expr(ts, 0))))

# Module: src/front/literals_arrays.bend:81
@unsafe
def f_array_first(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_array_type(n, f_expr(f_tl(ts), 12)), u => f_list(f_args(f_choose(FInput, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), "]", [n]))))

# Module: src/front/literals_arrays.bend:87
@unsafe
def f_array_type(n, p):
  match p:
    case FParsed{+ty, +ts}:
      +rest = f_space(ts)
      f_choose(FParsed, f_eq(tg(ty), "Error"), u => FParsed{ty, ts}, u => f_choose(FParsed, f_eq(f_tx(rest), "*") || f_eq(f_tx(rest), "^"), u => f_array_size(n, ty, f_eq(f_tx(rest), "*"), f_expr(f_tl(rest), 0)), u => fpe_error(rest, "expected * or ^ after array element type", "'^'")))

# Module: src/front/literals_arrays.bend:94
@unsafe
def f_array_size(n, ty, count, p):
  match p:
    case FParsed{+size, +ts}:
      f_choose(FParsed, f_eq(tg(size), "Error"), u => FParsed{size, ts}, u => f_array_closed(n, ty, count, f_expect(FParsed{size, f_space(ts)}, "]")))

# Module: src/front/literals_arrays.bend:100
@unsafe
def f_power_bits(n, d):
  f_choose(KTerm, U32.is_eq(n, 1), u => f_nat(d), u => f_choose(KTerm, U32.is_eq(n, 0) || U32.is_eq(U32.and(n, 1), 1), u => kt("Error", "array count must be a positive power of two", 0, 0, Nil{}), u => f_power_bits(U32.shrn(n, 1n), U32.add(d, 1))))

# Module: src/front/literals_arrays.bend:104
@unsafe
def f_index(n, p, min):
  match p:
    case FParsed{idx, ts}:
      f_choose(FParsed, f_context_stop(idx), u => p, u => f_index_ready(n, f_context_namespace(idx, ref(f_context_own("U32", ts, False{})), ts), ts, min))

# Module: src/front/literals_arrays.bend:110
@unsafe
def f_index_ready(+n: KTerm, +idx: KTerm, +ts: FInput, +min: U32) -> FParsed:
  f_choose(FParsed, f_context_stop(idx), u => FParsed{idx, ts},
    u => f_choose(FParsed, f_eq(f_tx(ts), "<-"), u => f_index_value(n, idx, f_previous_end(ts), f_expr(f_tl(ts), 2), min), u => f_grow(FParsed{f_app_span(k_with_span(ref(f_context_own("Array.get", ts, False{})), kb(n), f_previous_end(ts)), [k_with_span(ref(f_context_own("U32", ts, False{})), kb(n), f_previous_end(ts)), n, idx], kb(n), f_previous_end(ts)), ts}, min)))

# Module: src/front/literals_arrays.bend:115
@unsafe
def f_index_value(n, idx, end, p, min):
  match p:
    case FParsed{v, ts}:
      f_choose(FParsed, f_context_stop(v), u => p,
        u => f_grow(FParsed{f_app_span(k_with_span(ref(f_context_own("Array.set", ts, False{})), kb(n), end), [k_with_span(ref(f_context_own("U32", ts, False{})), kb(n), end), n, idx, v], kb(n), end), ts}, min))

# Module: src/front/literals_arrays.bend:122
@unsafe
def f_nat_extend(a, b):
  f_nat_extend_value(a, b, f_choose(KTerm, f_eq(tg(b), "Literal") && String.ends_with(nm(b), "n"), u => f_literal(nm(b)), u => b))

# Module: src/front/literals_arrays.bend:126
@unsafe
def f_nat_extend_value(+a: KTerm, +b: KTerm, +value: KTerm) -> KTerm:
  f_choose(KTerm, core_nat(a) && core_nat(value) && U32.is_le(kl_number(value), U32.sub(4294967295, kl_number(a))), u => kt("Literal", U32.show(U32.add(kl_number(a), kl_number(value))) ++ "n", 0, 1, Nil{}),
    u => f_choose(KTerm, core_nat(a) && U32.is_le(kl_number(a), 256), u => f_nat_prefix(kl_number(a), b), u => f_app(ref("Nat.add"), [a, b])))

# Module: src/front/literals_arrays.bend:131
@unsafe
def f_nat_prefix(+n: U32, +b: KTerm) -> KTerm:
  f_choose(KTerm, U32.is_eq(n, 0), u => b, u => kt("Ctr", "Succ", 0, 1, [f_nat_prefix(U32.sub(n, 1), b)]))

# Module: src/front/literals_arrays.bend:143
@unsafe
def f_namespace_head(t):
  f_choose(KTerm, f_eq(tg(t), "App") || f_eq(tg(t), "Call"), u => f_namespace_head(kid(t, 0)), u => t)

# Module: src/front/literals_arrays.bend:147
@unsafe
def f_implicit_operator(+name: String) -> Bool:
  Char.is_eq(f_head(name), '.') && Bool.not(String.contains(f_tail(name), "."))

# Module: src/front/literals_arrays.bend:151
@unsafe
def f_namespace_operator(head, input):
  f_eq(tg(head), "Ref") && (f_implicit_operator(nm(head)) || f_eq(nm(head), f_context_own("Bool.and", input, False{})) || f_eq(nm(head), f_context_own("Bool.or", input, False{})) || f_eq(nm(head), f_context_own("String.append", input, False{})))

# Module: src/front/literals_arrays.bend:155
@unsafe
def f_array_depth_at(+size: KTerm, +value: KTerm) -> KTerm:
  f_choose(KTerm, f_eq(tg(value), "Error"), u => fpe_message_at(size, nm(value), "a power of two count (^d takes a depth)"), u => k_with_span(value, kb(size), ke(size)))

# Module: src/front/literals_arrays.bend:159
@unsafe
def f_array_closed(+n: KTerm, +ty: KTerm, +count: Bool, +p: FParsed) -> FParsed:
  match p:
    case FParsed{size, ts}:
      f_choose(FParsed, f_context_stop(size), u => p,
        u => f_array_namespaced(size, ty, count, ts, f_context_namespace(n, ty, ts)))

# Module: src/front/literals_arrays.bend:166
@unsafe
def f_array_namespaced(+size: KTerm, +ty: KTerm, +count: Bool, +ts: FInput, +n: KTerm) -> FParsed:
  f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts},
    u => f_array_sized(n, ty, ts, f_choose(KTerm, count, u => f_array_depth_at(size, f_array_nat_depth(size, 0)), u => size)))

# Module: src/front/literals_arrays.bend:171
@unsafe
def f_array_sized(+n: KTerm, +ty: KTerm, +ts: FInput, +depth: KTerm) -> FParsed:
  f_choose(FParsed, f_context_stop(depth), u => FParsed{depth, ts}, u => FParsed{f_scope_apply_span(ref(f_context_own("Array.new", ts, False{})), [ty, depth, n], 0, 0), ts})

# Module: src/front/literals_arrays.bend:175
@unsafe
def f_array_nat_depth(+term: KTerm, +offset: U32) -> KTerm:
  f_choose(KTerm, core_nat(term) && U32.is_le(kl_number(term), U32.sub(4294967295, offset)), u => f_power_bits(U32.add(kl_number(term), offset), 0),
    u => f_choose(KTerm, f_eq(tg(term), "Ctr") && f_eq(nm(term), "Zero") && List.is_empty(&2,KTerm,ks(term)), u => f_power_bits(offset, 0),
      u => f_choose(KTerm, f_eq(tg(term), "Ctr") && f_eq(nm(term), "Succ") && U32.is_eq(terms_len(ks(term)), 1) && U32.is_lt(offset, 4294967295), u => f_array_nat_depth(kid(term, 0), U32.add(offset, 1)), u => kt("Error", "array count must be a natural power of two", 0, 0, Nil{}))))

# Module: src/front/literals_arrays.bend:181
@unsafe
def f_context_namespace(+term: KTerm, +ty: KTerm, +input: FInput) -> KTerm:
  f_context_namespace_at(term, ty, input, f_previous_end(input))

# Module: src/front/literals_arrays.bend:185
@unsafe
def f_context_namespace_at(+term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32) -> KTerm:
  f_choose(KTerm, f_eq(tg(term), "Let"), u => f_context_namespace_let(term, f_context_namespace_at(f_last(ks(term)), ty, input, cursor)),
      u => f_context_namespace_head(term, ty, input, cursor, f_namespace_head(term)))

# Module: src/front/literals_arrays.bend:190
@unsafe
def f_context_namespace_head(+term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32, +head: KTerm) -> KTerm:
  f_choose(KTerm, f_namespace_operator(head, input),
    u => f_choose(KTerm, f_eq(tg(term), "App"), u => f_context_namespace_app(term, f_context_namespace_at(kid(term, 0), ty, input, cursor), f_context_namespace_at(kid(term, 1), ty, input, cursor)),
      u => f_choose(KTerm, f_implicit_operator(nm(head)), u => f_context_namespace_type(term, f_namespace_head(ty), input, cursor), u => term)),
    u => term)

# Module: src/front/literals_arrays.bend:197
@unsafe
def f_context_namespace_app(+term: KTerm, +head: KTerm, +arg: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(head), u => head, u => f_choose(KTerm, f_context_stop(arg), u => arg, u => k_with_children(term, [head, arg])))

# Module: src/front/literals_arrays.bend:201
@unsafe
def f_context_namespace_type(+term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32) -> KTerm:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_choose(KTerm, f_eq(tg(ty), "Var") || f_eq(tg(ty), "FName") || f_eq(tg(ty), "Ref") || f_eq(tg(ty), "ADT"),
            u => f_context_namespace_resolved(term, f_context_resolve(kt_span("Ref", nm(ty) ++ nm(term), 0, 1, Nil{}, cursor, cursor), scope)),
            u => fpe_message_at(ty, "expected an operator type name", "a type name after : (the operators' namespace)"))

# Module: src/front/literals_arrays.bend:211
@unsafe
def f_context_namespace_resolved(+origin: KTerm, +resolved: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(resolved), u => resolved, u => k_with_span(resolved, kb(origin), ke(origin)))

# Only index-write syntax starts at its array binder; an explicit call does not.

# Module: src/front/literals_arrays.bend:216
@unsafe
def f_context_write(+term: KTerm, +begin: U32, +input: FInput) -> KTerm:
  f_choose(KTerm, f_eq(tg(term), "App") && f_eq(tg(kid(term, 0)), "App") && f_eq(tg(kid(kid(term, 0), 0)), "App") && f_eq(tg(kid(kid(kid(term, 0), 0), 0)), "App") && f_eq(tg(kid(kid(kid(kid(term, 0), 0), 0), 0)), "Ref") && f_eq(nm(kid(kid(kid(kid(term, 0), 0), 0), 0)), f_context_own("Array.set", input, False{})),
    u => f_context_write_var(kid(kid(kid(term, 0), 0), 1), begin), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/front/literals_arrays.bend:221
@unsafe
def f_context_write_var(+term: KTerm, +begin: U32) -> KTerm:
  f_choose(KTerm, (f_eq(tg(term), "Var") || f_eq(tg(term), "FName")) && U32.is_gt(begin, 0) && U32.is_eq(kb(term), begin), u => term, u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/front/literals_arrays.bend:225
@unsafe
def f_context_namespace_let(+term: KTerm, +body: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(body), u => body, u => k_with_children(term, norm_join(f_init(ks(term)), [body])))
# The higher pass visits eager children and beta-reduces an applied lambda.
# Lowering forces deferred binder children only when its caller demands them.

# Module: src/front/literals_arrays.bend:230
@unsafe
def f_context_materialize(+term: KTerm) -> KTerm:
  f_context_lower(f_context_higher(term))

# Module: src/front/literals_arrays.bend:234
@unsafe
def f_context_higher(+term: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(term), u => term,
    u => f_choose(KTerm, f_eq(tg(term), "FName"), u => f_context_higher(k_with_span(kid(term, 1), kb(term), ke(term))),
      u => f_choose(KTerm, f_eq(tg(term), "Ref") && f_implicit_operator(nm(term)), u => f_operator_error(term),
        u => f_context_material_children(term, ks(term), Nil{}, False{}))))

# Module: src/front/literals_arrays.bend:241
@unsafe
def f_context_lower(+term: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(term), u => term, u => f_context_material_children(term, ks(term), Nil{}, True{}))

# Module: src/front/literals_arrays.bend:245
@unsafe
def f_context_material_deferred(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>) -> Bool:
  f_eq(tg(term), "Lam") || (f_eq(tg(term), "All") && Bool.not(List.is_empty(&2,KTerm,built))) || (f_eq(tg(term), "Let") && List.is_empty(&2,KTerm,rest))

# Module: src/front/literals_arrays.bend:249
@unsafe
def f_context_material_children(+term: KTerm, +children: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool) -> KTerm:
  match children:
    case Nil{}: f_context_material_done(f_choose(KTerm, List.is_empty(&2,KTerm,built), u => term, u => k_with_children(term, List.reverse(&2,KTerm,built))), lower)
    case Con{head, rest}:
      +deferred = f_context_material_deferred(term, rest, built)
      f_choose(KTerm, Bool.not(lower) && deferred,
        u => f_context_material_children(term, rest, Con{head, built}, lower),
        u => f_context_material_next(term, rest, built, lower,
          f_choose(KTerm, lower,
            u => f_context_lower(f_choose(KTerm, deferred, u => f_context_higher(head), u => head)),
            u => f_context_higher(head))))

# Module: src/front/literals_arrays.bend:262
@unsafe
def f_context_material_next(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool, +head: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(head), u => head, u => f_context_material_children(term, rest, Con{head, built}, lower))

# Module: src/front/literals_arrays.bend:266
@unsafe
def f_context_material_done(+term: KTerm, +lower: Bool) -> KTerm:
  f_choose(KTerm, Bool.not(lower) && f_eq(tg(term), "App"),
    u => f_choose(KTerm, f_eq(tg(kid(term, 0)), "Lam"),
      u => f_context_higher(f_scope_app_span(kid(term, 0), kid(term, 1), kb(term), ke(term))), u => term),
    u => term)
