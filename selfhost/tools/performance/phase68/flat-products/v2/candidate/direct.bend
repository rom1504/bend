# Scalar built-ins use the same intrinsic C expression at their call site.
# Base provenance, exact saturation and non-bang entry are required. String
# read/show and arrays retain their allocating or consuming runtime boundaries.
@unsafe
def nd_scalar_known(+name: String) -> Bool:
  Bool.not(String.eq(ni_template(name), "")) && Bool.not(String.eq(name, "f32_show") || String.eq(name, "f32_read"))

@unsafe
def nd_scalar_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  +head = nd_head(t)
  +name = nc_primitive_name(nm(head))
  nt_choose(String, String.eq(tg(t), "App") && String.eq(tg(head), "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && nc_native_def(lookup(book, nm(head))) && nd_scalar_known(name) && U32.is_eq(terms_len(nd_args(t, Nil{})), nc_primitive_arity(name)), u => name, u => "")

@unsafe
def nd_bind_scalar(+name: String, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32, +id: U32, +body: KTerm) -> KTerm:
  nd_bind_value("NOp", name, args, acc, n, id, body)

# The same ordered argument sequencing serves scalar and allocating results.
@unsafe
def nd_bind_value(+tag: String, +name: String, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32, +id: U32, +body: KTerm) -> KTerm:
  match args:
    case Nil{}: nc_mklet(id, kt(tag, name, 0, 0, List.reverse(&2, KTerm, acc)), body)
    case Con{+h, +rest}: nc_mklet(nc_id(n), h, nd_bind_value(tag, name, rest, Con{var("", nc_id(n)), acc}, U32.inc(n), id, body))

@unsafe
def nd_prefix_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  +head = nd_head(t)
  +name = nc_primitive_name(nm(head))
  nt_choose(String, String.eq(tg(t), "App") && String.eq(tg(head), "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && nc_native_def(lookup(book, nm(head))) && (nc_array_known(name) || String.eq(name, "nat_divmod")) && U32.is_eq(terms_len(nd_args(t, Nil{})), nc_primitive_arity(name)), u => name, u => "")

@unsafe
def nd_scalar_word(+name: String, +words: List<&2, String>) -> String:
  +expr = ni_emit(name, words)
  nt_choose(String, String.eq(name, "u32_cmp") || String.eq(name, "nat_cmp"), u => "term_pak((" ++ expr ++ ") == 0 ? CID_LT : (" ++ expr ++ ") == 1 ? CID_EQ : CID_GT, 0)", u => expr)

# Saturated calls to a known leading lambda telescope use one register entry.
# Partial applications retain the ordinary closure entry and its ownership ABI.
law nd_app_to:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  for +target: NC_Target
  NC_Code

@unsafe
def nd_name(name: String) -> String:
  "$direct." ++ name

@unsafe
def nd_head(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "App"), u => nd_head(kid(t, 0)), u => t)

@unsafe
def nd_args(+t: KTerm, +acc: List<&2, KTerm>) -> List<&2, KTerm>:
  nt_choose(List<&2, KTerm>, String.eq(tg(t), "App"), u => nd_args(kid(t, 0), Con{kid(t, 1), acc}), u => acc)

@unsafe
def nd_leading(+t: KTerm, +n: U32) -> U32:
  nt_choose(U32, String.eq(tg(t), "Ann"), u => nd_leading(kid(t, 0), n), u =>
    nt_choose(U32, String.eq(tg(t), "Lam"), u => nd_leading(kid(t, 0), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(t), 0))))), u => n))

@unsafe
def nd_foreign_arity(+book: List<&2, KDef>, +ty: KTerm, +n: U32) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, String.eq(tg(tel), "All"), u => nd_foreign_arity(book, kid(tel, 1), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(tel), 0))))), u => n)

@unsafe
def nd_arity(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, nc_native_def(d), u => nc_primitive_arity(nc_primitive_name(name)), u =>
    nt_choose(U32, String.eq(tg(nc_unann(dv(d))), "Foreign"), u => nd_foreign_arity(book, dt(d), 0), u => U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d)))))

@unsafe
def nd_reapply(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: nd_reapply(app(head, h), rest)

@unsafe
def nd_beta(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{+arg, +rest}:
      nt_choose(KTerm, String.eq(tg(head), "Lam"),
        u => nt_choose(KTerm, String.eq(tg(arg), "Var"),
          u => nd_beta(subst(kid(head, 0), ix(head), arg), rest),
          u => nc_mklet(ix(head), arg, nd_beta(kid(head, 0), rest))),
        u => nd_reapply(head, Con{arg, rest}))

@unsafe
def nd_match_to(+book: List<&2, KDef>, +head: KTerm, +arg: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, (String.eq(tg(arg), "Var") || (Bool.not(nf_scheduler(target)) && String.eq(tg(arg), "NQBundle"))),
    u => nc_lower_to(book, kt("NMatch", "", 0, 0, [head, arg]), env, n, target),
    u => nc_lower_to(book, nc_mklet(nc_id(n), arg, kt("NMatch", "", 0, 0, [head, var("", nc_id(n))])), env, U32.inc(n), target))

# Remaining matcher arguments are already evaluated. Fresh aliases let the
# ordinary sharing prelude retain a scrutinee also used by another argument or
# by a captured branch before matching consumes its own reference.
@unsafe
def nd_match_vars(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{h, rest}: String.eq(tg(h), "Var") && nd_match_vars(rest)

@unsafe
def nd_match_sequence(+head: KTerm, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: kt("NMatch", "", 0, 0, Con{head, nt_reverse(KTerm, acc, Nil{})})
    case Con{+h, +rest}: nc_mklet(nc_id(n), h, nd_match_sequence(head, rest, Con{var("", nc_id(n)), acc}, U32.inc(n)))

@unsafe
def nd_match_rest(+t: KTerm) -> List<&2, KTerm>:
  nd_match_rest_list(ks(t))

@unsafe
def nd_match_rest_list(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Con{head, Con{arg, rest}}: rest
    case _: Nil{}

@unsafe
def nd_app_to(book, t, env, n, target):
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  +scalar = nd_scalar_call(book, t)
  nt_choose(NC_Code, Bool.not(String.eq(scalar, "")), u => nc_lower_to(book, nc_sequence("NOp", scalar, args, Nil{}, n), env, U32.add(n, terms_len(args)), target), u =>
  nt_choose(NC_Code, String.eq(tg(head), "Efq") && Bool.not(nf_scheduler(target)), u => nc_lower_to(book, head, env, n, target), u =>
  nt_choose(NC_Code, String.eq(tg(head), "Lam"), u => nc_lower_to(book, nd_beta(head, args), env, n, target), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Mat") && U32.is_eq(terms_len(args), 1), u => nd_match_to(book, head, kid(t, 1), env, n, target), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Mat") && U32.is_gt(terms_len(args), 1) && (nd_match_vars(args) || (Bool.not(nf_scheduler(target)) && nq_match_args(args))),
      u => nc_lower_to(book, nd_match_sequence(head, args, Nil{}, n), env, U32.add(n, terms_len(args)), target), u =>
    nt_choose(NC_Code, String.eq(tg(head), "Ref"), u =>
    nt_choose(NC_Code, Bool.not(U32.is_eq(qt(head), 3)) && U32.is_gt(terms_len(args), 0) && U32.is_eq(nd_arity(book, nm(head)), terms_len(args)),
      u => nc_lower_to(book, nc_sequence(nt_choose(String, nf_scheduler(target), v => "NCall", v => "NFCall"), nt_choose(String, nf_scheduler(target), v => nd_name(nc_ref_name(book, nm(head))), v => nm(head)), args, Nil{}, n), env, U32.add(n, terms_len(args)), target),
      u => nf_slow_app(book, t, env, n, target)), u => nf_slow_app(book, t, env, n, target)))))))

@unsafe
def nd_body(+t: KTerm) -> KTerm:
  nt_choose(KTerm, String.eq(tg(t), "Lam"), u => nd_body(kid(t, 0)), u => t)

@unsafe
def nd_bindings(+t: KTerm, +acc: List<&2, NC_Binding>) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, String.eq(tg(t), "Lam"), u => nd_bindings(kid(t, 0), Con{nc_binding(ix(t)), acc}), u => nt_reverse(NC_Binding, acc, Nil{}))

@unsafe
def nd_join(+base: NC_Code, +body: NC_Code, name: String, params: List<&2, NC_Binding>) -> NC_Code:
  NC_Code{nc_body(base), nt_append(N_Segment, nc_segs(base), Con{N_Segment{nd_name(name), nc_params(params), 1, N_Direct{}, nc_body(body), Nil{}, False{}, False{}, False{}, False{}}, nc_segs(body)}), nc_fresh(body), nc_first_error(base, body), List.append(&2, String, nc_calls(base), List.append(&2, String, nc_calls(body), Nil{}))}

@unsafe
def nd_entry_params(+left: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(left, 0), u => Nil{}, u =>
    Con{nc_binding(nc_id(n)), nd_entry_params(U32.sub(left, 1), U32.inc(n))})

@unsafe
def nd_entry_args(params: List<&2, NC_Binding>) -> List<&2, KTerm>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{id, word}, rest}: Con{var("", id), nd_entry_args(rest)}

@unsafe
def nd_extend_arity(+book: List<&2, KDef>, +body: KTerm, +base: NC_Code, +name: String, +arity: U32) -> NC_Code:
  +params = nd_entry_params(arity, nc_fresh(base))
  nt_choose(NC_Code, U32.is_eq(arity, 0), u => base, u =>
    nd_join(base, nc_lower(book, nd_reapply(body, nd_entry_args(params)), params, U32.add(nc_fresh(base), arity)), nc_ref_name(book, name), params))

@unsafe
def nd_extend(+book: List<&2, KDef>, +body: KTerm, +base: NC_Code, +name: String) -> NC_Code:
  nd_extend_arity(book, body, base, name, nd_arity(book, name))

# Named user-function values retain the curried ownership ABI. Their final
# closure tail-calls the full direct worker so only one copy of the actual
# body is lowered. Foreign, intrinsic and bang entries keep their old path.
@unsafe
def nd_eta_body(params: List<&2, NC_Binding>, +call: KTerm) -> KTerm:
  match params:
    case Nil{}: call
    case Con{NC_Binding{id, word}, rest}: k_lam("", id, 1, [nd_eta_body(rest, call)], 0, 0, False{})

@unsafe
def nd_eta_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +arity: U32) -> NC_Code:
  +params = nd_entry_params(arity, n)
  +call = kt("NCall", nd_name(nc_ref_name(book, name)), 0, 0, nd_entry_args(params))
  +base = nc_lower(book, nd_eta_body(params, call), Nil{}, U32.add(n, arity))
  nd_extend_arity(book, body, base, name, arity)

# Typed arity is computed once. Keep the original path when only a malformed
# raw definition's leading lambdas supply its positive arity.
@unsafe
def nd_user_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +d: KDef) -> NC_Code:
  +typed = jd_live_arity(book, dt(d), jd_arity(book, d))
  +arity = U32.max(nd_leading(dv(d), 0), typed)
  nt_choose(NC_Code, U32.is_gt(typed, 0) && U32.is_eq(arity, typed),
    u => nd_eta_entry(book, body, name, n, arity),
    u => nd_extend_arity(book, body, nc_lower(book, body, Nil{}, n), name, arity))

@unsafe
def nd_compile_entry(+book: List<&2, KDef>, +body: KTerm, +name: String, +n: U32, +bang: Bool) -> NC_Code:
  +d = lookup(book, name)
  nt_choose(NC_Code, Bool.not(bang) && Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d)),
    u => nd_user_entry(book, body, name, n, d),
    u => nd_extend(book, body, nc_lower(book, body, Nil{}, n), name))
