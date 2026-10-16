# Bounded saturated selector expansion. The syntax gate admits no references,
# primitive calls, data fields, or free variables from the callee body.
@unsafe
def nbc_closed(+t: KTerm, +bound: List<&2, NC_Binding>) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Var"), u => U32.is_eq(terms_len(ks(t)), 0) && Bool.not(p88_string_eq(nc_word(ix(t), bound), "NATIVE_UNBOUND_VARIABLE")), u =>
  nt_choose(Bool, p98_tag_eq(t, "Lam") && U32.is_eq(terms_len(ks(t)), 1), u =>
    nt_choose(Bool, p88_string_eq(nc_word(ix(t), bound), "NATIVE_UNBOUND_VARIABLE"), v => nbc_closed(kid(t, 0), Con{nc_binding(ix(t)), bound}), v => False{}), u =>
  nt_choose(Bool, (p98_tag_eq(t, "App") || (p98_tag_eq(t, "Mat") && U32.is_eq(ix(t), 1))) && U32.is_eq(terms_len(ks(t)), 2), u =>
    nbc_closed(kid(t, 0), bound) && nbc_closed(kid(t, 1), bound), u =>
    (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Efq")) && U32.is_eq(terms_len(ks(t)), 0))))

@unsafe
def nbc_match_list(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{+h, rest}: nt_choose(Bool, p98_tag_eq(h, "Mat"), u => True{}, u => nbc_match_list(List.append(&2, KTerm, ks(h), rest)))

@unsafe
def nbc_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{+h, rest}: U32.add(nt_choose(U32, p98_tag_eq(h, "Var"), u => Bool.to_u32(U32.is_eq(ix(h), id)), u => nbc_uses_list(ks(h), id)), nbc_uses_list(rest, id))

# Only exclusive nullary matcher arms may discard a literal branch. Nonliteral
# actuals are evaluated into outer ordered lets before the match is inspected.
@unsafe
def nbc_applicable(+body: KTerm, +args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+arg, +rest}:
      nt_choose(Bool, p98_tag_eq(body, "Lam"), u =>
        nt_choose(Bool, Bool.not(p98_tag_eq(arg, "Lam")) || U32.is_le(nbc_uses_list([kid(body, 0)], ix(body)), 1),
          v => nbc_applicable(kid(body, 0), rest), v => False{}), u =>
        nt_choose(Bool, p98_tag_eq(body, "Mat") && Bool.not(p98_tag_eq(arg, "Lam")),
          v => nbc_matchable(body, rest), v => False{}))

@unsafe
def nbc_matchable(+body: KTerm, +args: List<&2, KTerm>) -> Bool:
  nt_choose(Bool, p98_tag_eq(body, "Efq"), u => True{}, u =>
    nt_choose(Bool, p98_tag_eq(body, "Mat"),
      v => nbc_applicable(kid(body, 0), args) && nbc_matchable(kid(body, 1), args), v => False{}))

@unsafe
def nbc_expand(+body: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: body
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(body, "Lam"),
        u => nbc_expand(nq_layout_subst(kid(body, 0), ix(body), arg), rest),
        u => app(nbc_expand_match(body, rest), arg))

@unsafe
def nbc_expand_match(+body: KTerm, +args: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(body, "Efq"), u => body, u =>
    k_rebuild(body, nm(body), ix(body), qt(body), [nbc_expand(kid(body, 0), args), nbc_expand_match(kid(body, 1), args)], rm(body), kb(body), ke(body)))

@unsafe
def nbc_evaluate(+body: KTerm, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: nbc_expand(body, nt_reverse(KTerm, acc, Nil{}))
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(arg, "Lam"),
        u => nbc_evaluate(body, rest, Con{arg, acc}, U32.inc(n)),
        u => nc_mklet(nc_id(n), arg, nbc_evaluate(body, rest, Con{var("", nc_id(n)), acc}, U32.inc(n))))

@unsafe
def nbc_filled(fresh: FFresh, args: List<&2, KTerm>, n: U32) -> KTerm:
  match fresh:
    case FFresh{term, next}: nbc_evaluate(term, args, Nil{}, n)

@unsafe
def nbc_select(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm, U32.is_gt(nq_layout_remaining([body], 33), 0), u =>
    nt_choose(KTerm, nbc_closed(body, Nil{}) && nbc_match_list([body]), u =>
      nt_choose(KTerm, nbc_applicable(body, args), u =>
        nt_choose(KTerm, nd_comb_fresh(body, args, env, n, 64),
          u => nbc_filled(f_fresh_term(body, Nil{}, nc_id(U32.add(n, 63))), args, n), u => atom("Absent")),
        u => atom("Absent")), u => atom("Absent")), u => atom("Absent"))

@unsafe
def nbc_definition(+book: List<&2, KDef>, +d: KDef, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => nbc_select(nc_source_body(book, d, n), args, env, n, count), u => atom("Absent"))

@unsafe
def nbc_call(+book: List<&2, KDef>, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +count: U32) -> NC_Code:
  nc_lower_to(book, nc_sequence(nt_choose(String, nf_scheduler(target), v => "NCall", v => "NFCall"), nt_choose(String, nf_scheduler(target), v => nd_name(nc_ref_name(book, nm(head))), v => nm(head)), args, Nil{}, n), env, U32.add(n, count), target)

@unsafe
def nbc_selected(+book: List<&2, KDef>, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +count: U32, +selected: KTerm) -> NC_Code:
  nt_choose(NC_Code, p98_tag_eq(selected, "Absent"),
    u => nbc_call(book, head, args, env, n, target, count),
    u => nc_lower_to(book, selected, env, U32.add(n, 64), target))

@unsafe
def nbc_saturated(+book: List<&2, KDef>, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +count: U32) -> NC_Code:
  nt_choose(NC_Code, U32.is_gt(count, 0) && U32.is_le(count, 4) && U32.is_lt(n, 4294967231) && nd_comb_literal(args),
    u => nbc_selected(book, head, args, env, n, target, count, nbc_definition(book, lookup(book, nm(head)), args, env, n, count)),
    u => nbc_call(book, head, args, env, n, target, count))
