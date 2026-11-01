
# Consume the hit product before lowering miss; only its fields stay live.

@unsafe
def nc_match_apply_hit_to(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target, +mat: KTerm, +arg: KTerm, +word: String, +count: U32, hit: NC_Code) -> NC_Code:
  match hit:
    case NC_Code{hit_body, hit_segs, hit_next, hit_error, hit_calls}:
      nc_match_apply_join(nm(mat), word, count, n, ntr_target(target), hit_body, hit_segs, hit_error, hit_calls,
        nc_lower_to(book, nd_reapply(app(kid(mat, 1), arg), nd_match_rest(t)), env, hit_next, target))

# Bodies are affine inputs: no child NC_Code survives parent body construction.

@unsafe
def nc_match_apply_join(+name: String, +word: String, +count: U32, +n: U32, +reuse: Bool, hit_body: NC_Text, hit_segs: List<&2, N_Segment>, +hit_error: String, hit_calls: List<&2, String>, miss: NC_Code) -> NC_Code:
  match miss:
    case NC_Code{miss_body, miss_segs, miss_next, miss_error, miss_calls}:
      +guard = nt_choose(String, p88_string_eq(name, "Emit") || p88_string_eq(name, "Halt"), u => "if (term_aux(" ++ word ++ ") != CID_EMIT && term_aux(" ++ word ++ ") != CID_HALT) { err_post(e.mem, ERR_TAGS); return 0; }\n", u => "")
      NC_Code{nct_cat(nct_leaf(guard ++ "if (" ++ nc_condition(name, word) ++ ") {\n" ++ ntr_destructure_mode(name, word, count, n, reuse)), nct_cat(hit_body, nct_cat(nct_leaf("} else {\n"), nct_cat(miss_body, nct_leaf("}\n"))))), nt_append(N_Segment, hit_segs, miss_segs), miss_next, nt_choose(String, p88_string_eq(hit_error, ""), u => miss_error, u => hit_error), List.append(&2, String, hit_calls, List.append(&2, String, miss_calls, Nil{}))}

# Bounded saturated selector expansion. The syntax gate admits no references,
# primitive calls, data fields, or free variables from the callee body.
@unsafe
def nbc_closed(+t: KTerm, +bound: List<&2, NC_Binding>) -> Bool:
  nt_choose(Bool, core_literal(t), u => p88_string_eq(nm(t), "Nat") || p88_string_eq(nm(t), "U32") || p88_string_eq(nm(t), "F32"), u =>
  nt_choose(Bool, p98_tag_eq(t, "Var"), u => U32.is_eq(terms_len(ks(t)), 0) && Bool.not(p88_string_eq(nc_word(ix(t), bound), "NATIVE_UNBOUND_VARIABLE")), u =>
  nt_choose(Bool, p98_tag_eq(t, "Lam") && U32.is_eq(terms_len(ks(t)), 1), u =>
    nt_choose(Bool, p88_string_eq(nc_word(ix(t), bound), "NATIVE_UNBOUND_VARIABLE"), v => nbc_closed(kid(t, 0), Con{nc_binding(ix(t)), bound}), v => False{}), u =>
  nt_choose(Bool, (p98_tag_eq(t, "App") || (p98_tag_eq(t, "Mat") && U32.is_eq(ix(t), 1))) && U32.is_eq(terms_len(ks(t)), 2), u =>
    nbc_closed(kid(t, 0), bound) && nbc_closed(kid(t, 1), bound), u =>
  nt_choose(Bool, p98_tag_eq(t, "NWord") && U32.is_eq(terms_len(ks(t)), 0),
    u => ns_canonical(nm(t), U32.read(nm(t))),
    u => (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Efq")) && U32.is_eq(terms_len(ks(t)), 0))))))

# The erased source retains KLiteral leaves; structured native lowering uses
# NWord. Compact only the bounded callee, never substituted caller callbacks.
# Precheck excludes String literals before compaction: one literal leaf could
# otherwise expand into an unbounded string spine. Unknown kinds stay refused.
# The old unbounded/unknown/foreign fallbacks remain exactly Absent.

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
          u => nbc_filled(f_fresh_term(body, Nil{}, nc_id(U32.add(n, 63))), args, n), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
# Phase152 experimental overlay. Replace only nbc_definition and p113_value_kind.
# Original source admission runs before prepared facts are inspected. The only
# accepted body difference is nullary Ctr -> authenticated packed NStatic.
# No selector/name recognizer, raw marker admission, new IR, or verifier bypass.
@unsafe
def p152c_nullary(+constructors: KDef, +term: KTerm) -> Bool:
  p98_tag_eq(term,"NStatic") && U32.is_eq(qt(term),1) && U32.is_eq(ix(term),0) &&
    List.is_empty(&2,KTerm,ks(term)) && p112s_constructor_ok(constructors,nm(term),0)

@unsafe
def p152c_immediate(+book: List<&2,KDef>, +term: KTerm) -> Bool:
  p98_tag_eq(dt(ns_context(book)),"P112StaticImage") && p152c_nullary(p112s_context_ctors(book),term)

@unsafe
def p152c_strings(a: List<&2,String>, b: List<&2,String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: String.eq(x,y) && p152c_strings(xs,ys)
    case _ _: False{}

def p152c_variant(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{a0,a1,a2,a3,a4,a5,a6,a7} KTerm{b0,b1,b2,b3,b4,b5,b6,b7}: True{}
    case KLambda{a0,a1,a2,a3,a4,a5,a6,a7} KLambda{b0,b1,b2,b3,b4,b5,b6,b7}: Bool.not(Bool.xor(a7,b7))
    case _ _: False{}

@unsafe
def p152c_pair(+constructors: KDef, +source: KTerm, +prepared: KTerm) -> Bool:
  nt_choose(Bool,p98_tag_eq(prepared,"NStatic"),
    u => p98_tag_eq(source,"Ctr") && String.eq(nm(source),nm(prepared)) &&
      List.is_empty(&2,KTerm,ks(source)) && p152c_nullary(constructors,prepared),
    u => p152c_variant(source,prepared) && String.eq(tg(source),tg(prepared)) &&
      String.eq(nm(source),nm(prepared)) && U32.is_eq(ix(source),ix(prepared)) &&
      U32.is_eq(qt(source),qt(prepared)) && U32.is_eq(kb(source),kb(prepared)) &&
      U32.is_eq(ke(source),ke(prepared)) && p152c_strings(rm(source),rm(prepared)) &&
      p152c_pairs(constructors,ks(source),ks(prepared)))

@unsafe
def p152c_pairs(+constructors: KDef, a: List<&2,KTerm>, b: List<&2,KTerm>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p152c_pair(constructors,x,y) && p152c_pairs(constructors,xs,ys)
    case _ _: False{}

# Same-name freshly prepared fact with its retained erased source. A bounded
# correspondence check rejects stale substitutions, fields, boxes and scalars.
# Actual factory preparation already blocked effects before producing markers.
@unsafe
def p152c_fact(+book: List<&2,KDef>, +name: String, +source: KTerm, +fact: KDef) -> KTerm:
  +prior = index_first(dc(fact))
  nt_choose(KTerm,p98_tag_eq(dt(ns_context(book)),"P112StaticImage") &&
    String.eq(dk(fact),"NativeStaticBody") && String.eq(dn(fact),name) &&
    String.eq(dk(prior),"NativeErasedBody") && String.eq(dn(prior),name) &&
    U32.is_gt(nq_layout_remaining([dv(fact)],33),0),
    u => nt_choose(KTerm,p152c_pair(p112s_context_ctors(book),source,dv(fact)),
      v => dv(fact),v => source),u => source)

# These are the incumbent nbc_select gates, applied to the original compact
# body. The leaf-only substitution changes neither binders nor evaluation order.
@unsafe
def p152c_select(+book: List<&2,KDef>, +name: String, +body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([body],33),0),u =>
    nt_choose(KTerm,nbc_closed(body,[]) && nbc_match_list([body]),u =>
      nt_choose(KTerm,nbc_applicable(body,args),u =>
        nt_choose(KTerm,nd_comb_fresh(body,args,env,n,64),
          u => nbc_filled(f_fresh_term(p152c_fact(book,name,body,ns_body(book,name)),[],nc_id(U32.add(n,63))),args,n),
          u => atom("Absent")),u => atom("Absent")),u => atom("Absent")),u => atom("Absent"))

@unsafe
def p152c_source(+book: List<&2,KDef>, +name: String, +body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([body],33),0) && nbc_closed(body,[]),
    u => p152c_select(book,name,nc_compact(body),args,env,n,count),u => atom("Absent"))

# Preserve the exact previous classifier on every other case. N_Imm64 retains
# the constructor tag in the full U64 word; N_W32 would truncate that tag.
@unsafe
def p152c_prior_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"Ctr") || p98_tag_eq(value,"NCtr"),
    u => nt_choose(N_WordKind,p113n_constructor(book,nm(value),terms_len(ks(value))),v => N_Imm64{},v => p113n_original_value_kind(book,value,env)),
    u => p113n_original_value_kind(book,value,env))

@unsafe
def nbc_definition(+book: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => p152c_source(book,dn(d),nc_source_body(book,d,n),args,env,n,count),u => atom("Absent"))

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
