# Source book remains canonical. A separate, explicitly audited analysis view
# contains uniquely named private definitions with exact instance provenance.
# All private calls use LIVE argument slots; original/null-prefix ABI survives
# solely in the unchanged generic/public path and boundary facts.
@unsafe
def j_instance_original(+fact: KDef) -> KDef:
  index_first(dc(fact))

@unsafe
def j_instance_name(+at: U32) -> String:
  "$instance." ++ U32.show(at)

@unsafe
def j_instance_alias(+d: KDef) -> KDef:
  KDef{dn(d), "JErasedInstance", 0, da(d), dt(d), dv(d), [d], True{}, False{}}

@unsafe
def j_instance_aliases(+ds: List<&2,KDef>, +tail: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: tail
    case Con{d, rest}: Con{j_instance_alias(d), j_instance_aliases(rest, tail)}

@unsafe
def j_instance_fact_exact(+book: List<&2,KDef>, +fact: KDef) -> Bool:
  +original = j_instance_original(fact)
  String.eq(dk(fact), "JErasedInstance") && db(fact) &&
    exact_def(original, lookup(book, dn(original))) && U32.is_eq(dx(fact), da(original)) && U32.is_le(da(fact), dx(fact)) &&
    kc(Bool, U32.is_eq(da(fact), 0), u => exact_def(fact, j_instance_alias(original)), u =>
      j_instance_fact_replay(book, fact, j_erased_instance(book, Nil{},
        kt("Call", dn(original), 0, 0, List.append(&2,KTerm, j_instance_slot_args(j_instance_tail_defs(dc(fact))), j_instance_placeholders(U32.sub(da(original), da(fact))))))))

@unsafe
def j_instance_fact_replay(+book: List<&2,KDef>, +fact: KDef, +r: Maybe<&2,KDef>) -> Bool:
  match r:
    case None{}: False{}
    case Some{again}: j_erased_instance_same(fact, again)

@unsafe
def j_instance_slot_args(+slots: List<&2,KDef>) -> List<&2,KTerm>:
  match slots:
    case Nil{}: Nil{}
    case Con{slot, rest}: Con{dv(slot), j_instance_slot_args(rest)}

@unsafe
def j_instance_placeholders(+left: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>, U32.is_eq(left, 0), u => Nil{}, u => Con{atom("Absent"), j_instance_placeholders(U32.sub(left, 1))})

@unsafe
def j_instance_fact_index(+rows: List<&2,KDef>, +fact: KDef, +at: U32) -> U32:
  match rows:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, j_erased_instance_same(h, fact), u => at, u => j_instance_fact_index(rest, fact, U32.inc(at)))

@unsafe
def j_instance_source_index(+rows: List<&2,KDef>, +d: KDef, +at: U32) -> U32:
  match rows:
    case Nil{}: 4294967295
    case Con{h, rest}: kc(U32, U32.is_eq(da(h), 0) && exact_def(j_instance_original(h), d), u => at,
      u => j_instance_source_index(rest, d, U32.inc(at)))

@unsafe
def j_instance_drop(+args: List<&2,KTerm>, +left: U32) -> List<&2,KTerm>:
  kc(List<&2,KTerm>, U32.is_eq(left, 0), u => args, u =>
    kc(List<&2,KTerm>, List.is_empty(&2,KTerm, args), u => Nil{}, u => j_instance_drop(j_instance_tail_terms(args), U32.sub(left, 1))))

@unsafe
def j_instance_rewrite(+book: List<&2,KDef>, +rows: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u => k_with_children(t, [j_instance_rewrite(book, rows, kid(t, 0)), kid(t, 1)]), u =>
    kc(KTerm, String.eq(tg(t), "App"), u => j_instance_rewrite_call(book, rows, t, j_call_spine(t, Nil{})), u =>
      k_with_children(t, j_instance_rewrites(book, rows, ks(t)))))

@unsafe
def j_instance_rewrites(+book: List<&2,KDef>, +rows: List<&2,KDef>, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_instance_rewrite(book, rows, t), j_instance_rewrites(book, rows, rest)}

@unsafe
def j_instance_rewrite_call(+book: List<&2,KDef>, +rows: List<&2,KDef>, +original: KTerm, +spine: KTerm) -> KTerm:
  +d = lookup(book, nm(spine))
  kc(KTerm, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    kc(KTerm, U32.is_eq(qt(wnf(book, dt(d))), 0) && String.eq(tg(wnf(book, dt(d))), "All"), u =>
      j_instance_rewrite_fact(book, rows, spine, j_erased_instance(book, Nil{}, spine)), u =>
      j_instance_rewrite_live(book, rows, spine, j_instance_source_index(rows, d, 0), 0)), u => atom("Absent"))

@unsafe
def j_instance_rewrite_fact(+book: List<&2,KDef>, +rows: List<&2,KDef>, +spine: KTerm, +r: Maybe<&2,KDef>) -> KTerm:
  match r:
    case None{}: atom("Absent")
    case Some{fact}:
      +at = j_instance_fact_index(rows, fact, 0)
      kc(KTerm, U32.is_eq(at, 4294967295), u => atom("Absent"), u =>
        kc(KTerm, U32.is_eq(da(fact), dx(fact)), u =>
          kc(KTerm, U32.is_eq(terms_len(ks(j_strip(dv(fact)))), 0) &&
            (String.eq(tg(j_strip(dv(fact))), "Ctr") || String.eq(tg(j_strip(dv(fact))), "Lit")),
            u => dv(fact), u => atom("Absent")), u =>
          j_instance_rewrite_live(book, rows, spine, at, da(fact))))

@unsafe
def j_instance_rewrite_live(+book: List<&2,KDef>, +rows: List<&2,KDef>, +spine: KTerm, +at: U32, +prefix: U32) -> KTerm:
  +args = j_instance_rewrites(book, rows, j_instance_drop(ks(spine), prefix))
  kc(KTerm, U32.is_eq(at, 4294967295), u => j_region_app(ref(nm(spine)), args), u => j_region_app(ref(j_instance_name(at)), args))

@unsafe
def j_instance_view_defs(+book: List<&2,KDef>, +rows: List<&2,KDef>, +todo: List<&2,KDef>, +at: U32) -> List<&2,KDef>:
  match todo:
    case Nil{}: Nil{}
    case Con{fact, rest}:
      Con{KDef{j_instance_name(at), "Def", U32.sub(dx(fact), da(fact)), 0, dt(fact),
        j_instance_rewrite(book, rows, dv(fact)), [fact, j_instance_edge_row(j_instance_rewrite(book, rows, dv(fact)))], False{}, du(j_instance_original(fact))},
        j_instance_view_defs(book, rows, rest, U32.inc(at))}

@unsafe
def j_instance_tail_defs(+ds: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

@unsafe
def j_instance_tail_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

@unsafe
def j_instance_attach(+book: List<&2,KDef>, +rows: List<&2,KDef>, +sources: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      kc(List<&2,KDef>, String.eq(dk(cache), "BookCache"), u =>
        Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
          [index_first(dc(cache)), KDef{"$js.plans", "JSPlanContext", 0, 0, atom("Absent"), atom("Absent"),
            [missing(), missing(), KDef{"$js.instances", "JSInstanceContext", 0, 0, atom("Absent"), atom("Absent"),
              [KDef{"rows", "JSInstanceRows", 0, 0, atom("Absent"), atom("Absent"), rows, True{}, False{}},
               KDef{"sources", "JSInstanceSources", 0, 0, atom("Absent"), atom("Absent"), sources, True{}, False{}}], True{}, False{}}], False{}, False{}}], db(cache), du(cache)}, rest}, u => book)

@unsafe
def j_instance_all_exact(+book: List<&2,KDef>, +rows: List<&2,KDef>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{fact, rest}: j_instance_fact_exact(book, fact) && j_instance_all_exact(book, rest)

@unsafe
def j_instance_view_context(+view: List<&2,KDef>, +d: KDef, +pure: JPure) -> Bool:
  j_pure_valid(pure) && j_component_prefix(view, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0)

@unsafe
def j_instance_clones_ready(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, U32.is_eq(da(d), 0), u =>
        U32.is_eq(terms_len(ks(j_strip(dv(d)))), 0) &&
          (String.eq(tg(j_strip(dv(d))), "Ctr") || String.eq(tg(j_strip(dv(d))), "Lit")) && j_instance_clones_ready(view, rest), u =>
        j_pure_valid(j_pure_graph(view, d, JPure{Nil{}, 131072, True{}})) && j_instance_clones_ready(view, rest))

# Covered emission requires exact Def membership in the private view plus a
# provenance fact. Uncovered private instance names become Absent and fail the
# pre-emission audit; there is no G[private-name] fallback.
@unsafe
def j_instance_cover(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u => k_with_children(t, [j_instance_cover(view, defs, owner, kid(t, 0)), kid(t, 1)]), u =>
    kc(KTerm, String.eq(tg(t), "App"), u =>
      j_instance_cover_app(view, defs, owner, j_call_spine(t, Nil{})), u =>
      k_with_children(t, j_instance_covers(view, defs, owner, ks(t)))))

@unsafe
def j_instance_covers(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_instance_cover(view, defs, owner, t), j_instance_covers(view, defs, owner, rest)}

@unsafe
def j_instance_cover_app(+view: List<&2,KDef>, +defs: List<&2,KDef>, +owner: String, +spine: KTerm) -> KTerm:
  +d = lookup(view, nm(spine))
  +known = lookup(defs, nm(spine))
  +args = j_instance_covers(view, defs, owner, ks(spine))
  kc(KTerm, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(args), da(d)), u =>
    kc(KTerm, String.starts_with(nm(spine), "$instance."), u =>
      kc(KTerm, exact_def(d, known) && String.eq(dk(index_first(dc(d))), "JErasedInstance"), u =>
        kc(KTerm, String.eq(nm(spine), owner), u => j_region_app(ref(owner), args), u =>
          kc(KTerm, j_instance_emit_ready(view, d), u => j_region_annotate(kt("JCall", nm(spine), 0, 1, args), j_covered_result(dt(d), args)), u => j_instance_residual(view, d, args))), u => atom("Absent")), u =>
      j_region_app(ref(nm(spine)), args)), u => atom("Absent"))

@unsafe
def j_instance_no_absent(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0) && Bool.not(String.eq(tg(t), "Absent")),
      u => j_instance_no_absent(List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

@unsafe
def j_instance_covered_audit(+view: List<&2,KDef>, +defs: List<&2,KDef>, +rest: List<&2,KDef>) -> Bool:
  match rest:
    case Nil{}: True{}
    case Con{d, more}: j_instance_no_absent([j_instance_cover(view, defs, dn(d), dv(d))], 16384) && j_instance_covered_audit(view, defs, more)

@unsafe
def j_instance_declarations(+view: List<&2,KDef>, +defs: List<&2,KDef>, +rest: List<&2,KDef>) -> String:
  match rest:
    case Nil{}: ""
    case Con{d, more}: kc(String, j_instance_emit_ready(view, d), u =>
      j_component_stack_declaration(view, d, j_owned_term(j_instance_cover(view, defs, dn(d), dv(d))), "$tree"), u => "") ++
      j_instance_declarations(view, defs, more)

@unsafe
def j_instance_guards(+rows: List<&2,KDef>) -> String:
  match rows:
    case Nil{}: ""
    case Con{fact, rest}: j_quote(dn(j_instance_original(fact))) ++ "," ++ j_instance_guards(rest)

@unsafe
def j_instance_capture(+rows: List<&2,KDef>) -> String:
  match rows:
    case Nil{}: ""
    case Con{fact, rest}: "scalarCapture(" ++ j_quote(dn(j_instance_original(fact))) ++ ",G[" ++ j_quote(dn(j_instance_original(fact))) ++ "]);" ++ j_instance_capture(rest)

@unsafe
def j_instance_has_erased(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        j_instance_has_erased_node(book, t, rest, fuel, j_call_spine(t, Nil{})), u => False{})

@unsafe
def j_instance_has_erased_node(+book: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +spine: KTerm) -> Bool:
  +d = lookup(book, nm(spine))
  kc(Bool, String.eq(tg(t), "App") && String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") &&
    U32.is_eq(terms_len(ks(spine)), da(d)) && String.eq(tg(wnf(book, dt(d))), "All") && U32.is_eq(qt(wnf(book, dt(d))), 0),
    u => True{}, u => j_instance_has_erased(book, List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)))

@unsafe
def j_instance_root(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_instance_source_definition(d) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) &&
    j_region_signature(book, dt(d), da(d)) && j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))) &&
    j_instance_has_erased(book, [dv(d)], 2048), u =>
      j_instance_root_collect(book, d, j_instances_collect(book, [dv(d)], JInstances{Nil{}, [d], 1048576, True{}})), u => "")

@unsafe
def j_instance_root_collect(+book: List<&2,KDef>, +d: KDef, +s: JInstances) -> String:
  kc(String, j_instances_valid(s) && Bool.not(List.is_empty(&2,KDef, j_instances_rows(s))), u =>
    j_instance_root_rows(book, d, j_instance_aliases(j_instances_sources(s), j_instances_rows(s))), u => "")

@unsafe
def j_instance_root_rows(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>) -> String:
  kc(String, j_instance_all_exact(book, rows) && U32.is_le(j_region_def_count(rows), 96), u =>
    j_instance_root_raw(book, d, rows, j_instance_view_defs(book, rows, rows, 0)), u => "")

@unsafe
def j_instance_root_view(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  +view = List.append(&2,KDef, defs, j_instance_attach(book, rows, j_instances_sources(JInstances{Nil{}, [d], 0, True{}})))
  kc(String, j_pure_valid(j_pure_graph(view, lookup(view, j_instance_name(j_instance_source_index(rows, d, 0))), JPure{Nil{}, 131072, True{}})) && j_instance_covered_audit(view, defs, defs) && j_instance_erased_emitted(view, defs), u =>
    j_instance_root_emit(book, view, d, rows, defs, j_instance_source_index(rows, d, 0)), u => "")

@unsafe
def j_instance_root_emit(+book: List<&2,KDef>, +view: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +defs: List<&2,KDef>, +at: U32) -> String:
  kc(String, U32.is_eq(at, 4294967295) || Bool.not(j_instance_emit_ready(view, lookup(view, j_instance_name(at)))), u => "", u =>
    "(()=>{" ++ j_instance_declarations(view, defs, defs) ++ "const $guards=[" ++ j_instance_guards(rows) ++ j_instance_native_guards(j_pure_defs(j_pure_graph(view, lookup(view, j_instance_name(at)), JPure{Nil{}, 131072, True{}}))) ++ "];return " ++
    "fn(" ++ U32.show(da(d)) ++ ",exactCode(function(a,$entered){" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&regionProof===null&&regionHostGuard()&&stringHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++
    "&&localGuard($guards)){/* private contextual instances */return " ++ j_region_name(j_instance_name(at)) ++ "$tree(" ++ j_region_vector_names("$s", 0, da(d)) ++ ");}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()")


@unsafe
def j_instance_emit_ready(+view: List<&2,KDef>, +d: KDef) -> Bool:
  +cap = index_first(j_instance_tail_defs(j_instance_tail_defs(dc(d))))
  String.eq(dn(cap), "$js.instance.emission") && String.eq(dk(cap), "JSInstanceEmission") && db(cap)

@unsafe
def j_instance_residual(+view: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>) -> KTerm:
  +fact = index_first(dc(d))
  +original = j_instance_original(fact)
  +full = List.append(&2,KTerm, j_instance_slot_args(j_instance_tail_defs(dc(fact))), args)
  j_region_annotate(kt("JGeneric", dn(original), 0, 0, full), j_covered_result(dt(original), full))

@unsafe
def j_instance_native_guards(+graph: List<&2,KDef>) -> String:
  match graph:
    case Nil{}: ""
    case Con{d, rest}: kc(String, String.starts_with(dn(d), "$instance."), u => "", u => j_quote(dn(d)) ++ ",") ++ j_instance_native_guards(rest)

@unsafe
def j_instance_erased_emitted(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: False{}
    case Con{d, rest}: (U32.is_gt(da(index_first(dc(d))), 0) && j_instance_emit_ready(view, d)) || j_instance_erased_emitted(view, rest)


@unsafe
def j_instance_edge_row(+body: KTerm) -> KDef:
  KDef{"$js.instance.edges", "JSInstanceEdges", 0, 0, atom("Absent"), atom("Absent"), j_instance_edges([body], Nil{}, 16384), True{}, False{}}

@unsafe
def j_instance_edges(+todo: List<&2,KTerm>, +names: List<&2,KDef>, +fuel: U32) -> List<&2,KDef>:
  match todo:
    case Nil{}: names
    case Con{t, rest}:
      kc(List<&2,KDef>, U32.is_gt(fuel, 0), u =>
        j_instance_edges(List.append(&2,KTerm, ks(t), rest),
          kc(List<&2,KDef>, String.eq(tg(t), "Ref") && String.starts_with(nm(t), "$instance.") && String.eq(dk(lookup(names, nm(t))), "Absent"),
            u => Con{KDef{nm(t), "JSInstanceEdge", 0, 0, atom("Absent"), atom("Absent"), Nil{}, True{}, False{}}, names}, u => names), U32.sub(fuel, 1)), u => [missing()])

# Metadata occupies fixed slots after provenance; original source names cannot
# shadow rows. Unexpected rows fail closed as an invalid graph edge.
@unsafe
def j_instance_edges_checked(+d: KDef) -> List<&2,KDef>:
  +row = index_first(j_instance_tail_defs(dc(d)))
  kc(List<&2,KDef>, String.eq(dn(row), "$js.instance.edges") && String.eq(dk(row), "JSInstanceEdges"),
    u => dc(row), u => [missing()])

@unsafe
def j_instance_cycle(+view: List<&2,KDef>, +todo: List<&2,KDef>, +root: String, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{edge, rest}:
      kc(Bool, U32.is_eq(fuel, 0) || Bool.not(String.eq(dk(edge), "JSInstanceEdge")) || String.eq(dn(edge), root), u => True{}, u =>
        kc(Bool, has_name(seen, dn(edge)), u => j_instance_cycle(view, rest, root, seen, U32.sub(fuel, 1)), u =>
          j_instance_cycle(view, List.append(&2,KDef, j_instance_edges_checked(lookup(view, dn(edge))), rest), root,
            Con{dn(edge), seen}, U32.sub(fuel, 1))))

@unsafe
def j_instance_caps(+view: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      +ready = U32.is_gt(da(d), 0) && j_component_prefix(view, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0) &&
        Bool.not(j_instance_cycle(view, index_remove(j_instance_edges_checked(d), dn(d)), dn(d), Nil{}, 8192))
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), dv(d),
        List.append(&2,KDef, dc(d), [KDef{"$js.instance.emission", "JSInstanceEmission", 0, 0, atom("Absent"), atom("Absent"), Nil{}, ready, False{}}]), db(d), du(d)},
        j_instance_caps(view, rest)}

@unsafe
def j_instance_root_raw(+book: List<&2,KDef>, +d: KDef, +rows: List<&2,KDef>, +raw: List<&2,KDef>) -> String:
  +view = List.append(&2,KDef, raw, j_instance_attach(book, rows, [d]))
  kc(String, j_pure_valid(j_pure_graph(view, lookup(view, j_instance_name(j_instance_source_index(rows, d, 0))), JPure{Nil{}, 131072, True{}})), u =>
    j_instance_root_view(book, d, rows, j_instance_caps(view, raw)), u => "")
