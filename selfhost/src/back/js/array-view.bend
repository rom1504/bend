# A private representation fact for a completely closed scalar region. The
# existing typed region proof supplies canonical layouts and source dependencies;
# this bounded audit refuses every route by which an array could escape or enter.
@unsafe
def j_array_view_plan(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> Bool:
  j_array_view_plan_terms(book, d, s, [j_region_term(s)], False{})

# Tree plans supply both checked arms. Their already-proved self calls are legal
# lookup targets, while only the original helper list contributes executed bodies.
@unsafe
def j_array_view_plan_terms(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild, +terms: List<&2,KTerm>, +recursive: Bool) -> Bool:
  j_region_valid(s) && j_region_signature(book, dt(d), da(d)) &&
    String.eq(dk(lookup(j_region_helpers(s), "Array.new")), "Def") &&
    j_array_view_terms(book, kc(List<&2,KDef>, recursive, u => Con{d, j_region_helpers(s)}, u => j_region_helpers(s)), terms, 8192) &&
    j_array_view_helpers(book, j_region_helpers(s), j_region_helpers(s))

# Raw consumers never opt into handle constructors. The separate literal-array
# adapter uses the same closed-graph walk with an explicit representation mode.
@unsafe
def j_array_view_helpers(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +todo: List<&2,KDef>) -> Bool:
  j_array_view_helpers_mode(book, helpers, todo, False{})

@unsafe
def j_array_view_terms(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  j_array_view_terms_mode(book, helpers, todo, fuel, False{})

@unsafe
def j_array_view_helpers_mode(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +todo: List<&2,KDef>, +handles: Bool) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, db(d), u => j_array_effect_known(dn(d)) || String.eq(dn(d), "F32.to_u32"),
        u => j_array_view_terms_mode(book, helpers, [dv(d)], 8192, handles)) && j_array_view_helpers_mode(book, helpers, rest, handles)

# Ann and unpack carry type terms as metadata; only their executable child is
# visited. Array nodes have one already-checked erased U32/F32 element argument.
@unsafe
def j_array_view_terms_mode(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32, +handles: Bool) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        j_array_view_node_mode(book, helpers, t, rest, U32.sub(fuel, 1), tg(t), handles), u => False{})

@unsafe
def j_array_view_node_mode(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +t: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +tag: String, +handles: Bool) -> Bool:
  kc(Bool, String.eq(tag, "Ann"),
    u => j_array_view_terms_mode(book, helpers, Con{kid(t, 0), rest}, fuel, handles), u =>
  kc(Bool, String.eq(tag, "JUnpack"),
    u => Bool.not(j_region_local_array(book, kid(t, 1))) && j_array_view_terms_mode(book, helpers, Con{kid(t, 0), rest}, fuel, handles), u =>
  kc(Bool, String.eq(tag, "JNative"),
    u => j_array_effect_native(book, kt("Call", nm(t), 0, 0, ks(t))) &&
      j_array_view_native_args_mode(book, helpers, nm(t), ks(t), rest, fuel, handles), u =>
  kc(Bool, String.eq(tag, "App"),
    u => j_array_view_app_mode(book, helpers, j_call_spine(t, Nil{}), rest, fuel, handles), u =>
  kc(Bool, String.contains("|JCall|JReadCall|JInline|JInlineRead|", "|" ++ tag ++ "|"),
    u => String.eq(dk(lookup(helpers, nm(t))), "Def") && Bool.not(db(lookup(helpers, nm(t)))) &&
      j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, ks(t), rest), fuel, handles), u =>
  kc(Bool, String.eq(tag, "Ctr"),
    u => kc(Bool, handles && j_array_literal_name(nm(t)),
      u => j_u32_native_ctor(book, "Array", nm(t)) && j_array_literal_fields([t], 256), u =>
      (Bool.not(db(lookup(book, nm(t)))) || String.contains("|True|False|Zero|Succ|", "|" ++ nm(t) ++ "|")) &&
      Bool.not(j_array_literal_name(nm(t)))) &&
      j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, ks(t), rest), fuel, handles), u =>
  kc(Bool, String.eq(tag, "Mat"),
    u => (String.eq(nm(t), "Zero") || String.eq(nm(t), "Succ")) &&
      j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, ks(t), rest), fuel, handles), u =>
  kc(Bool, String.eq(tag, "Lit") || String.eq(tag, "JF32"),
    u => j_array_view_terms_mode(book, helpers, rest, fuel, handles), u =>
    String.contains("|Var|Lam|Let|Bind|Efq|JSlot|JNatRest|JLoopSlot|JVector|JIf|JNatCase|", "|" ++ tag ++ "|") &&
      j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, ks(t), rest), fuel, handles)))))))))

@unsafe
def j_array_view_native_args_mode(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +name: String, +args: List<&2,KTerm>, +rest: List<&2,KTerm>, +fuel: U32, +handles: Bool) -> Bool:
  kc(Bool, String.eq(name, "F32.to_u32"),
    u => j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, args, rest), fuel, handles),
    u => j_array_view_erased_args_mode(book, helpers, args, rest, fuel, handles))

@unsafe
def j_array_view_erased_args_mode(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +args: List<&2,KTerm>, +rest: List<&2,KTerm>, +fuel: U32, +handles: Bool) -> Bool:
  match args:
    case Con{erased, live}: j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, live, rest), fuel, handles)
    case Nil{}: False{}

@unsafe
def j_array_view_app_mode(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +spine: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +handles: Bool) -> Bool:
  kc(Bool, j_array_view_native_app(book, helpers, spine),
    u => j_array_view_native_args_mode(book, helpers, nm(spine), ks(spine), rest, fuel, handles), u => String.eq(tg(spine), "Call") &&
    (j_primitive_call(book, spine) ||
      j_array_view_helper_app(helpers, spine)) &&
    j_array_view_terms_mode(book, helpers, List.append(&2, KTerm, ks(spine), rest), fuel, handles))

# Source Apps can remain inside otherwise typed region plans. Reuse the exact
# native telescope/owner proof, and require its original dependency guard too.
@unsafe
def j_array_view_native_app(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +spine: KTerm) -> Bool:
  String.eq(tg(spine), "Call") && (j_array_effect_known(nm(spine)) || String.eq(nm(spine), "F32.to_u32")) &&
    String.eq(dk(lookup(helpers, nm(spine))), "Def") && db(lookup(helpers, nm(spine))) &&
    j_region_local_native(book, spine)

# The complete region proof supplies typed, guarded helper bodies. Refuse partial
# and overapplication; all private helper parameters are live positional slots.
@unsafe
def j_array_view_helper_app(+helpers: List<&2,KDef>, +spine: KTerm) -> Bool:
  +d = lookup(helpers, nm(spine))
  String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") && Bool.not(db(d)) &&
    U32.is_eq(dx(d), 0) && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d))

# Normalize admitted executable source Apps before any raw helper emission.
# Type metadata is preserved verbatim; erased operands remain unexecuted.
# Only the current countdown helper keeps its self App for loop-tail lowering.
# Every other proved helper call stays inside the private representation ABI.
@unsafe
def j_array_view_normalize(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +t: KTerm, +loop: String) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann") || String.eq(tg(t), "JUnpack"),
    u => k_with_children(t, [j_array_view_normalize(book, helpers, kid(t, 0), loop), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "App"), u =>
    j_array_view_normalize_app(book, helpers, t, j_call_spine(t, Nil{}), loop),
    u => k_with_children(t, j_array_view_normalize_terms(book, helpers, ks(t), loop))))

@unsafe
def j_array_view_normalize_app(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +t: KTerm, +spine: KTerm, +loop: String) -> KTerm:
  kc(KTerm, j_array_view_native_app(book, helpers, spine),
    u => kt("JNative", nm(spine), 0, 0, j_array_view_normalize_terms(book, helpers, ks(spine), loop)),
    u => kc(KTerm, j_array_view_helper_app(helpers, spine) && Bool.not(String.eq(nm(spine), loop)),
      u => kt("JCall", nm(spine), 0, 0, j_array_view_normalize_terms(book, helpers, ks(spine), loop)),
      u => k_with_children(t, j_array_view_normalize_terms(book, helpers, ks(t), loop))))

@unsafe
def j_array_view_normalize_terms(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +terms: List<&2,KTerm>, +loop: String) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{j_array_view_normalize(book, helpers, t, loop), j_array_view_normalize_terms(book, helpers, rest, loop)}

@unsafe
def j_array_view_normalize_defs(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +todo: List<&2,KDef>) -> List<&2,KDef>:
  match todo:
    case Nil{}: Nil{}
    case Con{d, rest}:
      Con{kc(KDef, db(d), u => d, u => KDef{dn(d), dk(d), da(d), dx(d), dt(d),
        j_array_view_normalize(book, helpers, dv(d), kc(String, String.eq(tg(dv(d)), "Mat"), u => dn(d), u => "")), dc(d), db(d), du(d)}), j_array_view_normalize_defs(book, helpers, rest)}

# The marker is private request metadata, never a source definition. Preserve
# the exact source index and existing planner payload. No mutable global mode.
@unsafe
def j_array_view_active(+book: List<&2,KDef>) -> Bool:
  match book:
    case Con{cache, rest}:
      String.eq(dk(cache), "BookCache") && j_array_view_context(dc(cache))
    case other: False{}

@unsafe
def j_array_view_context(+children: List<&2,KDef>) -> Bool:
  match children:
    case Con{source, Con{plans, Con{marker, Nil{}}}}:
      String.eq(dk(plans), "JSPlanContext") && String.eq(dk(marker), "JSArrayViewContext") && db(marker)
    case other: False{}

@unsafe
def j_array_view_book(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Con{cache, rest}: j_array_view_book_children(cache, rest, dc(cache))
    case other: book

@unsafe
def j_array_view_book_children(+cache: KDef, +rest: List<&2,KDef>, +children: List<&2,KDef>) -> List<&2,KDef>:
  match children:
    case Con{source, Con{plans, tail}}:
      kc(List<&2,KDef>, String.eq(dk(cache), "BookCache") && String.eq(dk(plans), "JSPlanContext"),
        u => Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
          [source, plans, KDef{"$js.array.view", "JSArrayViewContext", 0, 0, atom("Absent"), atom("Absent"), Nil{}, True{}, False{}}], db(cache), du(cache)}, rest},
        u => Con{cache, rest})
    case other: Con{cache, rest}

@unsafe
def j_array_view_data(+book: List<&2,KDef>, +value: String) -> String:
  kc(String, j_array_view_active(book), u => value, u => "arraydata(" ++ value ++ ")")

# Keep the original root's guards and handle-based path intact. The new private
# closure is allocated once, and its raw helpers cannot reach the old fallback.
@unsafe
def j_array_view_declaration(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  "const $arrayViewBody=(()=>{" ++ j_region_declarations(book,
    j_array_view_normalize_defs(book, j_region_helpers(s), j_region_helpers(s))) ++
    "return function(" ++ j_region_vector_names("$s", 0, da(d)) ++ "){" ++
    j_nat_loop_generic(book, Nil{}, j_array_view_normalize(book, j_region_helpers(s), j_region_term(s), ""), dt(d), 0) ++ "};})();"

@unsafe
def j_array_view_entry(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  "if(" ++ j_array_view_host_guard(book, d, s, atom("Absent")) ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++
    "&&localGuard($guards)){/* private raw array root */return $arrayViewBody(" ++
    j_region_vector_names("$s", 0, da(d)) ++ ");}"

# Statement destinations are existing region result slots or a return. Capture
# every argument before the store, then continue with the identical array value.
# The lexical block keeps reserved temporaries fresh across adjacent fields.
@unsafe
def j_array_view_statement(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +result: String) -> String:
  +body = j_strip(t)
  kc(String, j_array_view_active(book) && String.eq(tg(body), "JNative") &&
    String.eq(nm(body), "Array.set") && U32.is_eq(terms_len(ks(body)), 4), u =>
    "{" ++ j_array_view_store_values(book, env, ks(body), dt(lookup(book, "Array.set")), 0) ++
    "$arraySet1[Number($arraySet2)%$arraySet1.length]=$arraySet3;" ++ result ++ "$arraySet1;}",
    u => result ++ j_expr(book, env, t, ty, False{}) ++ ";")

@unsafe
def j_array_view_store_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +at: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{arg, rest}:
      +head = wnf(book, ty)
      "const $arraySet" ++ U32.show(at) ++ "=" ++
        kc(String, U32.is_eq(qt(head), 0), u => "null", u => j_expr(book, env, arg, kid(head, 0), False{})) ++ ";" ++
        j_array_view_store_values(book, env, rest, j_app_type(head, arg), U32.inc(at))


# Scalar trees consume the same array facts and normalizer, with their existing
# frame emitter. The original handle declarations and entry remain on refusal.
@unsafe
def j_array_view_tree_declaration(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +s: JRegionBuild) -> String:
  "const $arrayViewTreeBody=(()=>{" ++ j_region_declarations(book,
    j_array_view_normalize_defs(book, j_region_helpers(s), j_region_helpers(s))) ++
    "return function(" ++ j_region_vector_names("$s", 0, da(d)) ++ "){" ++
    j_tree_body(book, d, j_array_view_normalize(book, j_region_helpers(s), zero, dn(d)),
      j_array_view_normalize(book, j_region_helpers(s), j_region_term(s), dn(d))) ++ "};})();"

@unsafe
def j_array_view_tree_entry(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +s: JRegionBuild) -> String:
  "if($entered&&" ++ j_array_view_host_guard(book, d, s, zero) ++
    j_region_inputs(book, j_arm_type(book, wnf(book, dt(d)), "Succ"), 0, da(d), True{}) ++
    "&&$s0<32n&&localGuard($guards)){/* private raw array tree */return $arrayViewTreeBody(" ++
    j_region_vector_names("$s", 0, da(d)) ++ ");}"


# Even unused canonical/aliased F32 inputs need floating validation hooks.
# Only a complete absence across source, checked arms and helpers selects less.
@unsafe
def j_array_view_host_guard(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild, +zero: KTerm) -> String:
  "arrayViewHostGuard(" ++ kc(String, j_region_float_signature(book, dt(d), da(d)) ||
    j_region_float_terms([dt(d), dv(d), zero, j_region_term(s)]) || j_region_float_helpers(book, j_region_helpers(s)),
    u => "", u => "true") ++ ")&&"
