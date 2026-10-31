
# Module: src/back/native/direct.bend:53
law nd_app_to:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  for +target: NC_Target
  NC_Code

# Module: src/back/native/direct.bend:5
@unsafe
def nd_scalar_known(+name: String) -> Bool:
  Bool.not(p88_string_eq(ni_template(name), "")) && Bool.not(p88_string_eq(name, "f32_show") || p88_string_eq(name, "f32_read"))

# Reject ordinary/non-call heads before building intrinsic names and templates.
# Scalar and allocating call classifiers share the same provenance/arity gate.

# Module: src/back/native/direct.bend:11
@unsafe
def nd_native_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  nt_choose(String, p98_tag_eq(t, "App"),
    u => nd_native_head(book, t, nd_head(t)), u => "")

# Module: src/back/native/direct.bend:16
@unsafe
def nd_native_head(+book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  nt_choose(String, p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)),
    u => nt_choose(String, nc_native_def(lookup(book, nm(head))),
      v => nd_native_saturated(t, nc_primitive_name(nm(head))), v => ""), u => "")

# Module: src/back/native/direct.bend:22
@unsafe
def nd_native_saturated(+t: KTerm, +name: String) -> String:
  nt_choose(String, U32.is_eq(terms_len(nd_args(t, Nil{})), nc_primitive_arity(name)), u => name, u => "")

# Module: src/back/native/direct.bend:26
@unsafe
def nd_scalar_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  +name = nd_native_call(book, t)
  nt_choose(String, p88_string_eq(name, ""), u => "", u => nt_choose(String, nd_scalar_known(name), v => name, v => ""))

# Module: src/back/native/direct.bend:31
@unsafe
def nd_bind_scalar(+name: String, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32, +id: U32, +body: KTerm) -> KTerm:
  nd_bind_value("NOp", name, args, acc, n, id, body)

# The same ordered argument sequencing serves scalar and allocating results.

# Module: src/back/native/direct.bend:36
@unsafe
def nd_bind_value(+tag: String, +name: String, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32, +id: U32, +body: KTerm) -> KTerm:
  match args:
    case Nil{}: nc_mklet(id, kt(tag, name, 0, 0, List.reverse(&2, KTerm, acc)), body)
    case Con{+h, +rest}: nc_mklet(nc_id(n), h, nd_bind_value(tag, name, rest, Con{var("", nc_id(n)), acc}, U32.inc(n), id, body))

# Module: src/back/native/direct.bend:42
@unsafe
def nd_prefix_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  +name = nd_native_call(book, t)
  nt_choose(String, p88_string_eq(name, ""), u => "", u => nt_choose(String, nc_array_known(name) || p88_string_eq(name, "nat_divmod"), v => name, v => ""))

# Module: src/back/native/direct.bend:47
@unsafe
def nd_scalar_word(+name: String, +words: List<&2, String>) -> String:
  +expr = ni_emit(name, words)
  nt_choose(String, p88_string_eq(name, "u32_cmp") || p88_string_eq(name, "nat_cmp"), u => "term_pak((" ++ expr ++ ") == 0 ? CID_LT : (" ++ expr ++ ") == 1 ? CID_EQ : CID_GT, 0)", u => expr)

# Saturated calls to a known leading lambda telescope use one register entry.
# Partial applications keep the closure ABI; eligible named prefixes skip factories.

# Module: src/back/native/direct.bend:62
@unsafe
def nd_name(name: String) -> String:
  "$direct." ++ name

# Module: src/back/native/direct.bend:66
@unsafe
def nd_head(+t: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(t, "App"), u => nd_head(kid(t, 0)), u => t)

# Module: src/back/native/direct.bend:70
@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, p98_tag_eq(t, "App"), u => nd_args(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

# Module: src/back/native/direct.bend:74
@unsafe
def nd_leading(+t: KTerm, +n: U32) -> U32:
  nt_choose(U32, p98_tag_eq(t, "Ann"), u => nd_leading(kid(t, 0), n), u =>
    nt_choose(U32, p98_tag_eq(t, "Lam"), u => nd_leading(kid(t, 0), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(t), 0))))), u => n))

# Module: src/back/native/direct.bend:79
@unsafe
def nd_foreign_arity(+book: List<&2, KDef>, +ty: KTerm, +n: U32) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, p98_tag_eq(tel, "All"), u => nd_foreign_arity(book, kid(tel, 1), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(tel), 0))))), u => n)

# Module: src/back/native/direct.bend:84
@unsafe
def nd_arity(+book: List<&2, KDef>, +name: String) -> U32:
  +fact = ns_body(book, name)
  nt_choose(U32, U32.is_eq(dx(fact), 1) && (p88_string_eq(dk(fact), "NativeStaticBody") || p88_string_eq(dk(fact), "NativeErasedBody")),
    u => da(fact), u => nd_arity_plain(book, name))

# Module: src/back/native/direct.bend:90
@unsafe
def nd_arity_plain(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, nc_native_def(d), u => nc_primitive_arity(nc_primitive_name(name)), u =>
    nt_choose(U32, p98_tag_eq(nc_unann(dv(d)), "Foreign"), u => nd_foreign_arity(book, dt(d), 0), u => U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d)))))

# Module: src/back/native/direct.bend:96
@unsafe
def nd_reapply(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: nd_reapply(app(head, h), rest)

# Module: src/back/native/direct.bend:102
@unsafe
def nd_beta(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(head, "Lam"),
        u => nt_choose(KTerm, p98_tag_eq(arg, "Var"),
          u => nd_beta(nq_layout_subst(kid(head, 0), ix(head), arg), rest),
          u => nc_mklet(ix(head), arg, nd_beta(kid(head, 0), rest))),
        u => nd_reapply(head, Con{arg, rest}))

# Module: src/back/native/direct.bend:113
@unsafe
def nd_match_to(+book: List<&2, KDef>, +head: KTerm, +arg: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, (p98_tag_eq(arg, "Var") || (Bool.not(nf_scheduler(target)) && p98_tag_eq(arg, "NQBundle"))),
    u => nc_lower_to(book, kt("NMatch", "", 0, 0, [head, arg]), env, n, target),
    u => nc_lower_to(book, nc_mklet(nc_id(n), arg, kt("NMatch", "", 0, 0, [head, var("", nc_id(n))])), env, U32.inc(n), target))

# Remaining matcher arguments are already evaluated. Fresh aliases let the
# ordinary sharing prelude retain a scrutinee also used by another argument or
# by a captured branch before matching consumes its own reference.

# Module: src/back/native/direct.bend:122
@unsafe
def nd_match_vars(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{h, rest}: p98_tag_eq(h, "Var") && nd_match_vars(rest)

# Module: src/back/native/direct.bend:128
@unsafe
def nd_match_sequence(+head: KTerm, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: kt("NMatch", "", 0, 0, Con{head, nt_reverse(KTerm, acc, Nil{})})
    case Con{+h, +rest}: nc_mklet(nc_id(n), h, nd_match_sequence(head, rest, Con{var("", nc_id(n)), acc}, U32.inc(n)))

# Module: src/back/native/direct.bend:134
@unsafe
def nd_match_rest(+t: KTerm) -> List<&2, KTerm>:
  nd_match_rest_list(ks(t))

# Module: src/back/native/direct.bend:138
@unsafe
def nd_match_rest_list(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Con{head, Con{arg, rest}}: rest
    case _: Nil{}

# Known partial calls only skip a factory when the actual body starts with the
# complete live lambda telescope. Type annotations alone never grant admission.
# Gates are lazy: worker, bang, saturated and non-user paths do no partial scan.

# Module: src/back/native/direct.bend:147
@unsafe
def nd_partial_term(+name: String, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32, +left: U32) -> KTerm:
  match args:
    case Nil{}:
      +params = nd_entry_params(left, n)
      nd_eta_body(params, kt("NCall", name, 0, 0, List.append(&2, KTerm, nt_reverse(KTerm, acc, Nil{}), nd_entry_args(params))))
    case Con{+h, rest}:
      nc_mklet(nc_id(n), h, nd_partial_term(name, rest, Con{var("", nc_id(n)), acc}, U32.inc(n), left))

# A small linear combinator exposes literal captures to the existing beta rule.
# Only its closed App/Var body is copied: <=8 parameters imply <=15 body nodes.

# Module: src/back/native/direct.bend:158
@unsafe
def nd_comb_literal(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{+h, rest}: nt_choose(Bool, p98_tag_eq(h, "Lam"), u => True{}, u => nd_comb_literal(rest))

# Module: src/back/native/direct.bend:164
@unsafe
def nd_comb_closed(+t: KTerm, +params: List<&2, NC_Binding>, +depth: U32) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Var"), u => Bool.not(p88_string_eq(nc_word(ix(t), params), "NATIVE_UNBOUND_VARIABLE")), u =>
    nt_choose(Bool, p98_tag_eq(t, "App") && U32.is_gt(depth, 0),
      u => nd_comb_closed(kid(t, 0), params, U32.sub(depth, 1)) && nd_comb_closed(kid(t, 1), params, U32.sub(depth, 1)), u => False{}))

# Module: src/back/native/direct.bend:170
@unsafe
def nd_comb_uses(+t: KTerm, +id: U32) -> U32:
  nt_choose(U32, p98_tag_eq(t, "Var"), u => nt_bool(U32.is_eq(ix(t), id)), u =>
    U32.add(nd_comb_uses(kid(t, 0), id), nd_comb_uses(kid(t, 1), id)))

# Module: src/back/native/direct.bend:175
@unsafe
def nd_comb_linear(params: List<&2, NC_Binding>, +body: KTerm) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{+id, word, +kind}, +rest}:
      nt_choose(Bool, p88_string_eq(nc_word(id, rest), "NATIVE_UNBOUND_VARIABLE") && U32.is_eq(nd_comb_uses(body, id), 1), u => nd_comb_linear(rest, body), u => False{})

# Refuse even malformed raw-ID collisions before using the ordinary substitution
# helper. Syntax-only substitution leaves demand-preserving beta to lowering.

# Module: src/back/native/direct.bend:184
@unsafe
def nd_comb_fresh(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +left: U32) -> Bool:
  p143o_range(body,args,env,n,left)

@unsafe
def nd_comb_rename(+t: KTerm, +n: U32, +left: U32) -> KTerm:
  nt_choose(KTerm, U32.is_eq(left, 0), u => t, u =>
    k_lam("", nc_id(n), 1, [nd_comb_rename(nq_layout_subst(kid(t, 0), ix(t), var("", nc_id(n))), U32.inc(n), U32.sub(left, 1))], 0, 0, False{}))

# Module: src/back/native/direct.bend:195
@unsafe
def nd_comb_fill(+body: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: body
    case Con{+h, +rest}:
      nt_choose(KTerm, p98_tag_eq(h, "Lam"),
        u => nd_comb_fill(nq_layout_subst(kid(body, 0), ix(body), h), rest),
        u => nc_mklet(ix(body), h, nd_comb_fill(kid(body, 0), rest)))

# Module: src/back/native/direct.bend:204
@unsafe
def nd_comb_try(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  +params = nd_bindings(body, Nil{})
  +value = nd_body(body)
  nt_choose(KTerm, U32.is_eq(nt_count(NC_Binding, params), arity), u =>
    nt_choose(KTerm, nd_comb_closed(value, params, 8), u =>
      nt_choose(KTerm, nd_comb_linear(params, value), u =>
        nt_choose(KTerm, nd_comb_fresh(body, args, env, n, arity),
          u => nd_comb_fill(nd_comb_rename(body, n, arity), args), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/direct.bend:215
@unsafe
def nd_partial_selected(+book: List<&2, KDef>, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +arity: U32, +d: KDef) -> KTerm:
  +selected = nt_choose(KTerm, U32.is_lt(arity, 9),
    u => nt_choose(KTerm, nd_comb_literal(args),
      v => nd_comb_try(nc_erase(book, dv(d)), args, env, n, arity), v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
  nt_choose(KTerm, p98_tag_eq(selected, "Absent"),
    u => nd_partial_term(nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n, U32.sub(arity, terms_len(args))), u => selected)

# Module: src/back/native/direct.bend:223
@unsafe
def nd_partial_def(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +arity: U32, +d: KDef) -> NC_Code:
  nt_choose(NC_Code, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d)),
    u => nt_choose(NC_Code, U32.is_eq(nd_leading(dv(d), 0), arity),
      v => nc_lower_to(book, nd_partial_selected(book, head, args, env, n, arity, d), env, U32.add(n, arity), target),
      v => nf_slow_app(book, t, env, n, target)),
    u => nf_slow_app(book, t, env, n, target))

# Module: src/back/native/direct.bend:231
@unsafe
def nd_ref_arity(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +count: U32, +arity: U32) -> NC_Code:
  nt_choose(NC_Code, U32.is_eq(arity, count),
    u => nbc_saturated(book, head, args, env, n, target, count),
    u => nt_choose(NC_Code, nf_scheduler(target) && U32.is_lt(count, arity),
      v => nd_partial_def(book, t, head, args, env, n, target, arity, lookup(book, nm(head))),
      v => nf_slow_app(book, t, env, n, target)))

# Module: src/back/native/direct.bend:239
@unsafe
def nd_ref_app(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  +count = terms_len(args)
  nt_choose(NC_Code, Bool.not(U32.is_eq(qt(head), 3)) && U32.is_gt(count, 0),
    u => nd_ref_arity(book, t, head, args, env, n, target, count, nd_arity(book, nm(head))),
    u => nf_slow_app(book, t, env, n, target))

# Module: src/back/native/direct.bend:246
@unsafe
def nd_app_to(book, t, env, n, target):
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  +scalar = nt_choose(String, Bool.not(p88_string_eq(dk(nf_host_payload(dc(index_first(book)))), "Absent")), u => nd_native_call(book, t), u => nd_scalar_call(book, t))
  nt_choose(NC_Code, Bool.not(p88_string_eq(scalar, "")), u => nc_lower_to(book, nc_sequence("NOp", scalar, args, Nil{}, n), env, U32.add(n, terms_len(args)), target), u =>
  nt_choose(NC_Code, p98_tag_eq(head, "Efq") && Bool.not(nf_scheduler(target)), u => nc_lower_to(book, head, env, n, target), u =>
  nt_choose(NC_Code, p98_tag_eq(head, "Lam"), u => nc_lower_to(book, nd_beta(head, args), env, n, target), u =>
    nt_choose(NC_Code, (p98_tag_eq(head, "Mat") || p98_tag_eq(head, "NWPattern")) && U32.is_eq(terms_len(args), 1), u => nd_match_to(book, head, kid(t, 1), env, n, target), u =>
    nt_choose(NC_Code, (p98_tag_eq(head, "Mat") || p98_tag_eq(head, "NWPattern")) && U32.is_gt(terms_len(args), 1) && (nd_match_vars(args) || (Bool.not(nf_scheduler(target)) && nq_match_args(args))),
      u => nc_lower_to(book, nd_match_sequence(head, args, Nil{}, n), env, U32.add(n, terms_len(args)), target), u =>
    nt_choose(NC_Code, p98_tag_eq(head, "Ref"), u => nd_ref_app(book, t, head, args, env, n, target), u => nf_slow_app(book, t, env, n, target)))))))

# Module: src/back/native/direct.bend:259
@unsafe
def nd_body(+t: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(t, "Lam"), u => nd_body(kid(t, 0)), u => t)

# Module: src/back/native/direct.bend:263
@unsafe
def nd_bindings(+t: KTerm, +acc: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, p98_tag_eq(t, "Lam"), u => nd_bindings(kid(t, 0), Con{nc_binding(ix(t)), acc}), u => nt_reverse(NC_Binding, acc, Nil{}))

# Module: src/back/native/direct.bend:267
@unsafe
def nd_join(+base: NC_Code, +body: NC_Code, name: String, params: List<&2, NC_Binding>, host: Bool) -> NC_Code:
  NC_Code{nc_text(base), nt_append(N_Segment, nc_segs(base), Con{N_Segment{nd_name(name), nc_params(params), 1, N_Direct{}, nc_body(body), Nil{}, host, False{}, False{}, False{}}, nc_segs(body)}), nc_fresh(body), nc_first_error(base, body), List.append(&2, String, nc_calls(base), List.append(&2, String, nc_calls(body), Nil{}))}

# Module: src/back/native/direct.bend:271
@unsafe
def nd_entry_params(+left: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(left, 0), u => Nil{}, u =>
    Con{nc_binding(nc_id(n)), nd_entry_params(U32.sub(left, 1), U32.inc(n))})

# Module: src/back/native/direct.bend:276
@unsafe
def nd_entry_args(params: List<&2, NC_Binding>) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{id, word, kind}, rest}: Con{var("", id), nd_entry_args(rest)}

# Module: src/back/native/direct.bend:282
@unsafe
def nd_extend_arity(+book: List<&2, KDef>, +body: KTerm, +base: NC_Code, +name: String, +arity: U32) -> NC_Code:
  +params = nk_typed_bindings(nd_entry_params(arity, nc_fresh(base)), nf_worker_kinds(book, name, arity))
  nt_choose(NC_Code, U32.is_eq(arity, 0), u => base, u =>
    nd_join(base, nt_choose(NC_Code, nf_host_selected(book, name, arity),
      u => NC_Code{nct_leaf(""), Nil{}, U32.add(nc_fresh(base), arity), "", Nil{}},
      u => nc_lower(book, nd_reapply(body, nd_entry_args(params)), params, U32.add(nc_fresh(base), arity))), nc_ref_name(book, name), params, nf_host_selected(book, name, arity)))

# Module: src/back/native/direct.bend:290
@unsafe
def nd_extend(+book: List<&2, KDef>, +body: KTerm, +base: NC_Code, +name: String) -> NC_Code:
  nd_extend_arity(book, body, base, name, nd_arity(book, name))

# Named user-function values retain the curried ownership ABI. Their final
# closure tail-calls the full direct worker so only one copy of the actual
# body is lowered. Foreign, intrinsic and bang entries keep their old path.

# Module: src/back/native/direct.bend:297
@unsafe
def nd_eta_body(params: List<&2, NC_Binding>, +call: KTerm) -> KTerm:
  match params:
    case Nil{}: call
    case Con{NC_Binding{id, word, kind}, rest}: k_lam("", id, 1, [nd_eta_body(rest, call)], 0, 0, False{})

# Module: src/back/native/direct.bend:303
@unsafe
def nd_eta_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +arity: U32) -> NC_Code:
  +params = nd_entry_params(arity, n)
  +call = kt("NCall", nd_name(nc_ref_name(book, name)), 0, 0, nd_entry_args(params))
  +base = nt_choose(NC_Code, nf_host_no_factory(book, name, arity), u => NC_Code{nct_leaf(""), Nil{}, n, "", Nil{}}, u => nc_lower(book, nd_eta_body(params, call), Nil{}, U32.add(n, arity)))
  nd_extend_arity(book, body, base, name, arity)

# Typed arity is computed once. Keep the original path when only a malformed
# raw definition's leading lambdas supply its positive arity.

# Module: src/back/native/direct.bend:312
@unsafe
def nd_user_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +d: KDef) -> NC_Code:
  +typed = jd_live_arity(book, dt(d), jd_arity(book, d))
  +arity = U32.max(nd_leading(dv(d), 0), typed)
  nt_choose(NC_Code, U32.is_gt(typed, 0) && U32.is_eq(arity, typed),
    u => nd_eta_entry(book, body, name, n, arity),
    u => nd_extend_arity(book, body, nc_lower(book, body, Nil{}, n), name, arity))

# Module: src/back/native/direct.bend:320
@unsafe
def nd_compile_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +bang: Bool) -> NC_Code:
  +d = lookup(book, name)
  nt_choose(NC_Code, Bool.not(bang) && Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d)),
    u => nd_user_entry(book, body, name, n, d),
    u => nt_choose(NC_Code, nf_host_no_factory(book, name, nd_arity(book, name)),
      v => nd_extend(book, body, NC_Code{nct_leaf(""), Nil{}, n, "", Nil{}}, name),
      v => nd_extend(book, body, nc_lower(book, body, Nil{}, n), name)))
