# Request-local layout context. BookCache source and planner payload stay exact.
@unsafe
def j_flat_active(+book: List<&2,KDef>) -> Bool:
  match book:
    case Con{c, rest}: String.eq(dk(c), "BookCache") && j_flat_children(book, dc(c))
    case other: False{}

@unsafe
def j_flat_children(+book: List<&2,KDef>, +ds: List<&2,KDef>) -> Bool:
  match ds:
    case Con{source, Con{plans, Con{flat, Nil{}}}}:
      String.eq(dk(plans), "JSPlanContext") && String.eq(dk(flat), "JSFlatContext") && String.eq(dn(flat), "$js.flat") && db(flat) && Bool.not(List.is_empty(&2, KDef, dc(flat))) && j_covered_defs(book, dc(flat), dc(flat))
    case other: False{}

@unsafe
def j_flat_book(+book: List<&2,KDef>, +graph: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Con{c, rest}: j_flat_book_children(c, rest, dc(c), graph)
    case other: book

@unsafe
def j_flat_book_children(+c: KDef, +rest: List<&2,KDef>, +children: List<&2,KDef>, +graph: List<&2,KDef>) -> List<&2,KDef>:
  match children:
    case Con{source, Con{plans, tail}}:
      kc(List<&2,KDef>, String.eq(dk(c), "BookCache") && String.eq(dk(plans), "JSPlanContext"), u =>
        Con{KDef{dn(c), dk(c), da(c), dx(c), dt(c), dv(c), [source, plans, KDef{"$js.flat", "JSFlatContext", 0, 0, atom("Absent"), atom("Absent"), graph, True{}, False{}}], db(c), du(c)}, rest}, u => Con{c, rest})
    case other: Con{c, rest}

@unsafe
def j_flat_data(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_flat_active(book) && Bool.not(j_region_scalar(book, ty)) && String.eq(tg(wnf(book, ty)), "ADT")

# Reject even nested native containers/observers, not only top-level argument types.
@unsafe
def j_flat_type(+book: List<&2,KDef>, +ty: KTerm, +seen: List<&2,String>, +fuel: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_gt(fuel, 0), u => kc(Bool, j_region_scalar(book, head), u => True{}, u =>
    kc(Bool, j_pure_type(book, head) && Bool.not(j_list_ground_type(book, head)) && String.eq(tg(head), "ADT") && U32.is_eq(terms_len(ks(head)), 0), u =>
      kc(Bool, has_name(seen, nm(head)), u => True{}, u => j_flat_types(book, dc(lookup(book, nm(head))), Con{nm(head), seen}, U32.sub(fuel, 1))), u => False{})), u => False{})

@unsafe
def j_flat_types(+book: List<&2,KDef>, +cs: List<&2,KDef>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match cs:
    case Nil{}: True{}
    case Con{c, rest}: j_flat_signature(book, dt(c), da(c), seen, fuel) && j_flat_types(book, rest, seen, fuel)

@unsafe
def j_flat_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +seen: List<&2,String>, +fuel: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_gt(fuel, 0), u => kc(Bool, U32.is_eq(left, 0), u => j_flat_type(book, head, seen, fuel), u =>
    String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_flat_type(book, kid(head, 0), seen, fuel) &&
    j_flat_signature(book, kid(head, 1), U32.sub(left, 1), seen, U32.sub(fuel, 1))), u => False{})

# Normalize only region residual nodes. Structural self-call source nodes remain
# untouched: the existing continuation emitter, never native recursion, owns them.
@unsafe
def j_flat_term(+book: List<&2,KDef>, +graph: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u => k_with_children(t, [j_flat_term(book, graph, kid(t, 0)), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "JGeneric"), u => j_flat_generic(book, graph, t), u => k_with_children(t, j_flat_terms(book, graph, ks(t)))))

@unsafe
def j_flat_terms(+book: List<&2,KDef>, +graph: List<&2,KDef>, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_flat_term(book, graph, t), j_flat_terms(book, graph, rest)}

@unsafe
def j_flat_generic(+book: List<&2,KDef>, +graph: List<&2,KDef>, +t: KTerm) -> KTerm:
  +app = j_region_app(ref(nm(t)), j_flat_terms(book, graph, ks(t)))
  j_covered_app(book, graph, app, app)

# Negative audit of actual normalized emission frontiers. No generic observer or
# unsupported lowering node can reach flat data merely because its source is pure.
@unsafe
def j_flat_audit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +self: String, +t: KTerm, +fuel: U32) -> Bool:
  kc(Bool, U32.is_gt(fuel, 0), u => kc(Bool, String.eq(tg(t), "Ann"), u => j_flat_audit(book, graph, locals, self, kid(t, 0), U32.sub(fuel, 1)), u =>
  kc(Bool, String.eq(tg(t), "App"), u => j_flat_app_audit(book, graph, locals, self, j_call_spine(t, Nil{}), U32.sub(fuel, 1)), u =>
  kc(Bool, String.eq(tg(t), "JCall"), u => j_flat_call_audit(book, graph, locals, t) && j_flat_audits(book, graph, locals, self, ks(t), U32.sub(fuel, 1)), u =>
  kc(Bool, String.eq(tg(t), "JDirectCall"), u => j_pure_valid(j_direct_cached(book, nm(t))) && j_covered_defs(book, graph, j_pure_defs(j_direct_cached(book, nm(t)))) &&
    j_flat_audits(book, graph, locals, self, ks(t), U32.sub(fuel, 1)), u =>
    String.contains("|Lam|Mat|Ctr|Let|Bind|Var|Lit|JUnpack|JSlot|JLoopSlot|JNatRest|JNatCase|JIf|Efq|", "|" ++ tg(t) ++ "|") &&
    j_flat_audits(book, graph, locals, self, kc(List<&2,KTerm>, String.eq(tg(t), "JUnpack"), u => [kid(t, 0)], u => ks(t)), U32.sub(fuel, 1))))), u => False{})

@unsafe
def j_flat_audits(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +self: String, +ts: List<&2,KTerm>, +fuel: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{t, rest}: j_flat_audit(book, graph, locals, self, t, fuel) && j_flat_audits(book, graph, locals, self, rest, U32.sub(fuel, 1))

@unsafe
def j_flat_app_audit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +self: String, +spine: KTerm, +fuel: U32) -> Bool:
  String.eq(tg(spine), "Call") && (j_primitive_call(book, spine) ||
    (Bool.not(String.eq(self, "")) && String.eq(nm(spine), self) && U32.is_eq(terms_len(ks(spine)), da(lookup(book, self))))) &&
    j_flat_audits(book, graph, locals, self, ks(spine), fuel)

@unsafe
def j_flat_call_audit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +t: KTerm) -> Bool:
  kc(Bool, U32.is_eq(qt(t), 1), u => j_pure_valid(j_component_cached(book, nm(t))) &&
    j_covered_defs(book, graph, j_pure_defs(j_component_cached(book, nm(t)))), u => String.eq(dk(lookup(locals, nm(t))), "Def") && Bool.not(String.eq(tg(dv(lookup(locals, nm(t)))), "JResidual"))) &&
    U32.is_eq(terms_len(ks(t)), da(lookup(book, nm(t))))

@unsafe
def j_flat_graph_audit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +root: String, +ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{d, rest}: j_flat_signature(book, dt(d), da(d), Nil{}, 128) &&
      kc(Bool, String.eq(dn(d), root), u => True{}, u => kc(Bool, db(d), u => j_pure_bool_native(book, d), u => j_flat_def_audit(book, graph, locals, d, j_component_cached(book, dn(d))))) &&
      j_flat_graph_audit(book, graph, locals, root, rest)

@unsafe
def j_flat_def_audit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +d: KDef, +pure: JPure) -> Bool:
  kc(Bool, j_pure_valid(pure), u => j_flat_linear_safe(dv(d), dn(d)) && j_flat_audit(book, graph, locals, dn(d), j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dv(d)), 8192), u =>
    kc(Bool, j_pure_valid(j_direct_cached(book, dn(d))), u => j_flat_audit(book, graph, locals, "", j_direct_term(book, dv(d)), 8192), u =>
      String.eq(dk(lookup(locals, dn(d))), "Def")))

@unsafe
def j_flat_locals(+book: List<&2,KDef>, +graph: List<&2,KDef>, +ds: List<&2,KDef>) -> List<&2,KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), j_owned_term(j_flat_term(book, graph, dv(d))), dc(d), db(d), du(d)}, j_flat_locals(book, graph, rest)}

@unsafe
def j_flat_local_audit(+book: List<&2,KDef>, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, String.eq(tg(dv(d)), "JResidual"), u => True{}, u =>
      kc(Bool, db(d), u => j_pure_bool_native(book, d), u => String.eq(tg(dv(d)), "Ann") && j_flat_audit(book, graph, locals, "", dv(d), 8192))) && j_flat_local_audit(book, graph, locals, rest)

@unsafe
def j_flat_clones(+book: List<&2,KDef>, +ds: List<&2,KDef>) -> String:
  match ds:
    case Nil{}: ""
    case Con{d, rest}: kc(String, j_pure_valid(j_component_cached(book, dn(d))), u => j_component_declaration(book, d, j_component_cached(book, dn(d))), u => "") ++ j_flat_clones(book, rest)

@unsafe
def j_flat_root_scope(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  +normal = j_fusion_root_body(book, d, j_nat_loop_generic(book, Nil{}, j_region_term(s), dt(d), 0))
  kc(String, j_fold_root_signature(book, dt(d), da(d)) && j_region_has_residual(j_region_helpers(s)), u =>
    j_flat_root_proof(book, d, s, normal, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}})), u => normal)

@unsafe
def j_flat_root_proof(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild, +normal: String, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u => "const $previousProof=regionProofOpen($guards);try{" ++
    j_flat_root_select(book, d, s, normal, j_pure_defs(pure), j_flat_locals(book, j_pure_defs(pure), j_region_helpers(s))) ++
    "}finally{regionProofClose($previousProof);}", u => normal)

@unsafe
def j_flat_root_select(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild, +normal: String, +graph: List<&2,KDef>, +locals: List<&2,KDef>) -> String:
  kc(String, j_region_signature(book, dt(d), da(d)) && j_flat_local_audit(book, graph, locals, locals) &&
    j_flat_guarded(graph, dn(d), j_region_helpers(s)) && j_flat_graph_audit(book, graph, locals, dn(d), graph) && j_flat_audit(book, graph, locals, "", j_flat_term(book, graph, j_region_term(s)), 8192), u =>
    j_flat_root_emit(j_flat_book(book, graph), d, graph, locals, j_owned_term(j_flat_term(book, graph, j_region_term(s)))), u => normal)

@unsafe
def j_flat_root_emit(+book: List<&2,KDef>, +d: KDef, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +body: KTerm) -> String:
  kc(String, j_flat_active(book), u => "{/* private flat closed graph */" ++ j_flat_clones(book, graph) ++ j_region_declarations(book, locals) ++ j_nat_loop_generic(book, Nil{}, body, dt(d), 0) ++ "}", u => "return bad('flat context invariant');")

@unsafe
def j_flat_fields(+book: List<&2,KDef>, +ty: KTerm, +value: String, +at: U32, +total: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, j_flat_data(book, ty), u => kc(List<&2,String>, U32.is_eq(at, total), u => rest, u => Con{"(" ++ value ++ ")._" ++ U32.show(at), j_flat_fields(book, ty, value, U32.inc(at), total, rest)}), u => j_finite_fields(value, at, total, rest))

@unsafe
def j_flat_ctor_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +tel: KTerm, +at: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, rest}: "_" ++ U32.show(at) ++ ":" ++ kc(String, U32.is_eq(qt(tel), 0), u => "null", u => j_expr(book, env, h, kid(tel, 0), False{})) ++ "," ++ j_flat_ctor_args(book, env, rest, j_app_type(tel, h), U32.inc(at))

@unsafe
def j_flat_unpack(+book: List<&2,KDef>, +ty: KTerm, +value: String) -> String:
  value ++ kc(String, j_flat_data(book, ty) || j_region_local_vector(book, ty), u => "", u => ".a")

@unsafe
def j_flat_bindings(+book: List<&2,KDef>, +ty: KTerm, +slot: U32, +at: U32, +total: U32) -> String:
  kc(String, j_flat_data(book, ty), u => kc(String, U32.is_eq(at, total), u => "", u => "const $p" ++ U32.show(U32.add(U32.inc(slot), at)) ++ "=$unpack._" ++ U32.show(at) ++ ";" ++ j_flat_bindings(book, ty, slot, U32.inc(at), total)), u => j_region_field_bindings(slot, at, total))

@unsafe
def j_flat_reads(+book: List<&2,KDef>, +ty: KTerm, +value: String, +at: U32, +total: U32) -> String:
  kc(String, j_flat_data(book, ty), u => kc(String, U32.is_eq(at, total), u => "", u => value ++ "._" ++ U32.show(at) ++ "," ++ j_flat_reads(book, ty, value, U32.inc(at), total)), u => j_region_field_reads(j_flat_unpack(book, ty, value), at, total))

# Unary constructor/tail continuations stay stack-safe. Other unary combiners
# may fall back to generic dispatch or emit unmarked constructors and refuse.
@unsafe
def j_flat_linear_safe(+t: KTerm, +name: String) -> Bool:
  kc(Bool, String.eq(tg(t), "Ann") || String.eq(tg(t), "Lam"), u => j_flat_linear_safe(kid(t, 0), name), u =>
    kc(Bool, String.eq(tg(t), "Mat"), u => j_flat_linear_safe(kid(t, 0), name) && j_flat_linear_safe(kid(t, 1), name), u => kc(Bool, U32.is_eq(j_component_refs([t], name, 8192, 0), 1), u =>
      kc(Bool, j_linear_alias(t, name), u => j_flat_linear_safe(kid(t, 1), name), u => String.eq(tg(t), "Ctr") || (String.eq(tg(j_call_spine(t, Nil{})), "Call") && String.eq(nm(j_call_spine(t, Nil{})), name))), u => True{})))

@unsafe
def j_flat_guarded(+ds: List<&2,KDef>, +root: String, +helpers: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{d, rest}: (String.eq(dn(d), root) || String.eq(dk(lookup(helpers, dn(d))), "Def")) && j_flat_guarded(rest, root, helpers)

@unsafe
def j_flat_linear_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +tel: KTerm, +child: U32, +at: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, rest}: "_" ++ U32.show(at) ++ ":" ++ kc(String, U32.is_lt(at, child), u => "$frame.before[" ++ U32.show(at) ++ "]", u => kc(String, U32.is_eq(at, child), u => "$value", u => j_expr(book, env, h, kid(wnf(book, tel), 0), False{}))) ++ "," ++ j_flat_linear_args(book, env, rest, j_app_type(wnf(book, tel), h), child, U32.inc(at))
