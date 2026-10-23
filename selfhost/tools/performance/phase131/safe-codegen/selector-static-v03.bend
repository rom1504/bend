# Phase131 V03: reuse validated prepared nullary constants after V02 admission.
# Scalar constants are closed, effect-free values in a checked
# selector. Preserve every existing size, saturation, affinity, freshness and
# evaluation-order gate. No function-name test or unsafe-source exemption.
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
    u => (p98_tag_eq(t, "NStatic") && U32.is_eq(qt(t),1) && U32.is_eq(ix(t),0) && U32.is_eq(terms_len(ks(t)),0)) || (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Efq")) && U32.is_eq(terms_len(ks(t)), 0))))))

# The erased source retains KLiteral leaves; structured native lowering uses
# NWord. Compact only the bounded callee, never substituted caller callbacks.
# Precheck excludes String literals before compaction: one literal leaf could
# otherwise expand into an unbounded string spine. Unknown kinds stay refused.
# The old unbounded/unknown/foreign fallbacks remain exactly Absent.
@unsafe
def p131sc_definition_body(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm, U32.is_gt(nq_layout_remaining([body],33),0) && nbc_closed(body,[]),
    u => nbc_select(nc_compact(body),args,env,n,count),
    u => atom("Absent"))

@unsafe
def nbc_definition(+book: List<&2, KDef>, +d: KDef, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => p131sc_definition_static(book,d,nc_source_body(book,d,n),args,env,n,count),
    u => atom("Absent"))

# Only already prepared packed nullary words may cross this boundary. One-field
# packed zero and boxed/static graph values are deliberately excluded. Read the
# constructor catalogue once; final p112s_value/image verification remains.
@unsafe
def p131sc_static_terms(+constructors: KDef, terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{+head,+rest}:
      nt_choose(Bool,p98_tag_eq(head,"NStatic"),
        u => U32.is_eq(qt(head),1) && U32.is_eq(ix(head),0) && List.is_empty(&2,KTerm,ks(head)) && p112s_constructor_ok(constructors,nm(head),0) && p131sc_static_terms(constructors,rest),
        u => p131sc_static_terms(constructors,ks(head)) && p131sc_static_terms(constructors,rest))

@unsafe
def p131sc_prepared_body(+book: List<&2,KDef>, +name: String, +source: KTerm, +fact: KDef) -> KTerm:
  nt_choose(KTerm,p88_string_eq(dk(fact),"NativeStaticBody") && p88_string_eq(dn(fact),name) && p98_tag_eq(dt(ns_context(book)),"P112StaticImage") && U32.is_gt(nq_layout_remaining([dv(fact)],33),0),
    u => nt_choose(KTerm,p131sc_static_terms(p112s_context_ctors(book),[dv(fact)]),
      v => dv(fact),v => nc_compact(source)),
    u => nc_compact(source))

@unsafe
def p131sc_definition_static(+book: List<&2,KDef>, +d: KDef, +source: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([source],33),0) && nbc_closed(source,[]),
    u => nbc_select(p131sc_prepared_body(book,dn(d),source,ns_body(book,dn(d))),args,env,n,count),
    u => atom("Absent"))
