# Two pure scalar children use a private depth-first continuation stack. Public
# matcher entry and every refused shape keep the original generic evaluation.

@unsafe
def j_tree_global(+book: List<&2,KDef>, +d: KDef) -> String:
  +worker = j_tree_worker(book, d)
  kc(String, String.eq(worker, ""), u => j_region_global(book, d),
    u => "G[" ++ j_quote(dn(d)) ++ "]=" ++ worker ++ ";\n")

@unsafe
def j_tree_worker(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_nat_scalar_shape(book, d), u =>
    kc(String, j_region_signature(book, dt(d), da(d)), u =>
      j_tree_checked(book, d, kid(j_strip(dv(d)), 0), j_strip(kid(j_strip(kid(j_strip(dv(d)), 1)), 0))), u => ""), u => "")

@unsafe
def j_tree_checked(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +succ: KTerm) -> String:
  kc(String, j_tree_shape(j_nat_loop_unwrap(succ), dn(d), ix(succ), da(d)), u =>
    kc(String, j_tree_distinct(succ, j_nat_loop_unwrap(succ)), u => j_tree_zero(book, d, zero, succ,
      j_region_prefix(book, Nil{}, zero, j_arm_type(book, wnf(book, dt(d)), "Zero"), 0, U32.sub(da(d), 1), True{}, "", [dn(d)], 0,
        JRegionBuild{atom("Absent"), Nil{}, 32768, True{}})), u => ""), u => "")

@unsafe
def j_tree_shape(+t: KTerm, +name: String, +pred: U32, +total: U32) -> Bool:
  kc(Bool, String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 3), u =>
    kc(Bool, j_nat_loop_bindings(ks(t), pred, Nil{}) && Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) && Bool.not(U32.is_eq(qt(kid(t, 1)), 0)), u =>
      j_nat_loop_call(j_call_spine(kid(kid(t, 0), 0), Nil{}), name, pred, total) &&
      j_nat_loop_call(j_call_spine(kid(kid(t, 1), 0), Nil{}), name, pred, total), u => False{}), u => False{})

@unsafe
def j_tree_distinct(+t: KTerm, +body: KTerm) -> Bool:
  +head = j_strip(t)
  kc(Bool, String.eq(tg(head), "Lam"), u =>
    kc(Bool, Bool.not(U32.is_eq(ix(head), ix(kid(body, 0)))) && Bool.not(U32.is_eq(ix(head), ix(kid(body, 1)))),
      u => j_tree_distinct(kid(head, 0), body), u => False{}), u => True{})

@unsafe
def j_tree_zero(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +succ: KTerm, +s: JRegionBuild) -> String:
  kc(String, j_region_valid(s), u =>
    j_tree_done(book, d, zero, succ, j_region_term(s),
      j_tree_prefix(book, Nil{}, succ, j_arm_type(book, wnf(book, dt(d)), "Succ"), da(d), dn(d), s)), u => "")

# Both child RHSs see only the original parent environment. The combination
# sees only the two new results, so no parent capture survives an unwind.
@unsafe
def j_tree_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +left: U32, +name: String, +s: JRegionBuild) -> JRegionBuild:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0), u =>
    kc(JRegionBuild, U32.is_eq(left, 0), u =>
      j_tree_left(book, env, body, head, name,
        j_region_expr(book, env, kid(kid(body, 0), 0), head, name, [name], 0, 0, j_region_tick(s))), u =>
      j_region_prefix_lam(body, True{}, j_tree_prefix(book,
        Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
        subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.sub(left, 1), name, j_region_tick(s)))), u => j_region_fail(s))

@unsafe
def j_tree_left(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +name: String, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_tree_right(book, t, ty, name, k_with_children(kid(t, 0), [j_region_term(s)]),
      j_region_expr(book, env, kid(kid(t, 1), 0), ty, name, [name], 0, 0, s)), u => s)

@unsafe
def j_tree_right(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +name: String, +left: KTerm, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_tree_combine(t, ty, left, k_with_children(kid(t, 1), [j_region_term(s)]),
      j_region_expr(book, [kt("Env", "", ix(kid(t, 0)), 0, [ty]), kt("Env", "", ix(kid(t, 1)), 0, [ty])],
        kid(t, 2), ty, "", [name], 0, 0, s)), u => s)

@unsafe
def j_tree_combine(+t: KTerm, +ty: KTerm, +left: KTerm, +right: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(k_with_children(t, [left, right, j_region_term(s)]), ty))

@unsafe
def j_tree_done(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +succ: KTerm, +fastZero: KTerm, +s: JRegionBuild) -> String:
  kc(String, j_region_valid(s), u =>
    "scalarCapture(" ++ j_quote(dn(d)) ++ ",(()=>{" ++ j_region_declarations(book, j_region_helpers(s)) ++
    "const $guards=[" ++ j_quote(dn(d)) ++ kc(String, List.is_empty(&2, KDef, j_region_helpers(s)), u => "", u => "," ++ j_region_names(j_region_helpers(s))) ++ "];return " ++
    j_nat_loop_wrapper(book, d, zero, da(d),
      "if($entered&&" ++ j_region_host_guard(book, d, j_region_helpers(s)) ++ j_region_inputs(book, j_arm_type(book, wnf(book, dt(d)), "Succ"), 0, da(d), True{}) ++ "&&$s0<32n&&localGuard($guards)){/* private scalar tree */" ++
      j_tree_scope(book, d, j_region_helpers(s), j_tree_body(book, d, fastZero, j_region_term(s))) ++ "}" ++
      j_nat_loop_generic(book, Nil{}, succ, j_arm_type(book, wnf(book, dt(d)), "Succ"), 0)) ++ ";})())", u => "")

# Share a complete checked entry only inside a scalar-input, independently pure
# residual graph. Delayed results and exceptions leave the proof in finally.
@unsafe
def j_tree_scope(+book: List<&2,KDef>, +d: KDef, +helpers: List<&2,KDef>, +body: String) -> String:
  kc(String, j_fold_root_signature(book, dt(d), da(d)) && j_region_has_residual(helpers), u =>
    kc(String, j_pure_valid(j_pure_graph(book, d, JPure{Nil{}, 32768, True{}})), u =>
      "const $previousProof=regionProofOpen($guards);try{" ++ body ++ "}finally{regionProofClose($previousProof);}", u => body), u => body)

@unsafe
def j_tree_body(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +succ: KTerm) -> String:
  "$s0=$s0+1n;const $frames=[];let $top=0,$value;$visit:for(;;){if($s0!==0n){" ++
  j_tree_enter(book, Nil{}, succ, j_arm_type(book, wnf(book, dt(d)), "Succ"), d, succ, 0, False{}) ++ "}{" ++
  j_region_body(book, Nil{}, zero, j_arm_type(book, wnf(book, dt(d)), "Zero"), 1, "$value=", False{}) ++ "}" ++
  "while($top){const $frame=$frames[$top-1];if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++
  j_tree_enter(book, Nil{}, succ, j_arm_type(book, wnf(book, dt(d)), "Succ"), d, succ, 0, True{}) ++ "}" ++
  j_tree_unwind(book, j_nat_loop_unwrap(succ)) ++ "--$top;}return $value;}"

@unsafe
def j_tree_enter(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +succ: KTerm, +at: U32, +right: Bool) -> String:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(String, String.eq(tg(body), "Lam"), u =>
    "const " ++ j_local(ix(body)) ++ "=" ++ kc(String, right,
      u => "$frame.args[" ++ U32.show(at) ++ "]",
      u => "$s" ++ U32.show(at) ++ kc(String, U32.is_eq(at, 0), u => "-1n", u => "")) ++ ";" ++
    j_tree_enter(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
      subst(kid(head, 1), ix(head), var(nm(body), ix(body))), d, succ, U32.inc(at), right), u =>
    j_nat_loop_next(book, env, ks(j_call_spine(kid(kid(body, kc(U32, right, u => 1, u => 0)), 0), Nil{})), dt(d), 0) ++
    kc(String, right, u => "", u => j_tree_push(succ)) ++
    j_nat_loop_assign(da(d), 0) ++ "continue $visit;")

@unsafe
def j_tree_push(+succ: KTerm) -> String:
  "const $saved=$frames[$top++];if($saved){" ++ j_tree_save(succ, 0) ++
  "$saved.phase=0;$saved.left=null;}else $frames[$top-1]={args:[" ++
  j_tree_aliases(succ) ++ "],phase:0,left:null};"

@unsafe
def j_tree_save(+t: KTerm, +at: U32) -> String:
  +body = j_strip(t)
  kc(String, String.eq(tg(body), "Lam"), u =>
    "$saved.args[" ++ U32.show(at) ++ "]=" ++ j_local(ix(body)) ++ ";" ++
    j_tree_save(kid(body, 0), U32.inc(at)), u => "")

@unsafe
def j_tree_aliases(+t: KTerm) -> String:
  +body = j_strip(t)
  kc(String, String.eq(tg(body), "Lam"), u => j_local(ix(body)) ++ "," ++ j_tree_aliases(kid(body, 0)), u => "")

@unsafe
def j_tree_unwind(+book: List<&2,KDef>, +body: KTerm) -> String:
  "const " ++ j_local(ix(kid(body, 0))) ++ "=$frame.left;const " ++ j_local(ix(kid(body, 1))) ++ "=$value;" ++
  "$value=" ++ j_expr(book, j_context(book, Nil{}, ks(body)), kid(body, 2), atom("Absent"), False{}) ++ ";"

# Closed two-result structural components share the existing scalar proof.
# Original typed prefixes and tagged values remain; only self calls use frames.
@unsafe
def j_component_plan(+book: List<&2,KDef>, +d: KDef) -> JPure:
  +head = wnf(book, dt(d))
  kc(JPure, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 8) && String.eq(tg(head), "All"), u =>
    kc(JPure, (String.eq(tg(wnf(book, kid(head, 0))), "ADT") && Bool.not(db(lookup(book, nm(wnf(book, kid(head, 0))))))) ||
      j_list_ground_type(book, kid(head, 0)) || j_pure_closed_list(book, kid(head, 0)) ||
      # Nat-to-scalar workers retain the existing scalar island selection.
      # The remaining purity proof verifies admitted data result types.
      (j_primitive_type(book, wnf(book, kid(head, 0)), "Nat") && j_nat_loop_native(book) &&
        Bool.not(j_region_scalar(book, j_fold_root_result(book, dt(d), da(d))))), u =>
    kc(JPure, j_u32_bounded([dv(d)], 512) && Bool.not(j_l_deep(dv(d), 0)), u =>
    kc(JPure, j_component_admit(book, d), u =>
    kc(JPure, j_region_capture_eligible(book, d) &&
      j_component_prefix(book, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0), u =>
        j_component_select(book, d, j_component_closed(d, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}}))),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}})

# Preserve recursive admission. Acyclic ADT-first wrappers need a direct
# reference to an independently admitted recursive component; scalar-first,
# Nat-first and List wrappers retain their previous selection.
@unsafe
def j_component_admit(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u => True{}, u =>
    j_component_wrapper_arg(book, wnf(book, kid(wnf(book, dt(d)), 0))))

@unsafe
def j_component_wrapper_arg(+book: List<&2,KDef>, +arg: KTerm) -> Bool:
  String.eq(tg(arg), "ADT") && Bool.not(db(lookup(book, nm(arg))))

# Reuse the already computed complete graph, rather than proving it twice.
@unsafe
def j_component_select(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> JPure:
  kc(JPure, j_pure_valid(pure), u =>
    kc(JPure, U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u => pure, u =>
      kc(JPure, j_component_wrapper_calls(book, d, j_pure_defs(pure)), u => pure,
        u => JPure{Nil{}, 0, False{}})), u => pure)

@unsafe
def j_component_wrapper_calls(+book: List<&2,KDef>, +d: KDef, +ds: List<&2,KDef>) -> Bool:
  match ds:
    case Nil{}: False{}
    case Con{callee, rest}:
      # Only positive-self-reference candidates reach the nested planner, so
      # planning never follows an acyclic wrapper chain recursively. The full
      # typed graph independently guarantees saturated, first-order calls.
      kc(Bool, U32.is_gt(j_component_refs([dv(callee)], dn(callee), 1024, 0), 0) &&
        U32.is_gt(j_component_refs([dv(d)], dn(callee), 1024, 0), 0), u =>
        kc(Bool, j_pure_valid(j_component_cached(book, dn(callee))), u => True{}, u =>
          j_component_wrapper_calls(book, d, rest)), u => j_component_wrapper_calls(book, d, rest))

# Reject mutual backedges into this worker: forcing such a leaf could otherwise
# nest native worker calls instead of remaining in the runtime tail trampoline.
@unsafe
def j_component_closed(+d: KDef, +pure: JPure) -> JPure:
  kc(JPure, j_pure_valid(pure) && j_component_backedges(j_pure_defs(pure), dn(d)), u => pure,
    u => JPure{Nil{}, 0, False{}})

@unsafe
def j_component_backedges(+ds: List<&2,KDef>, +name: String) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, String.eq(dn(d), name) || U32.is_eq(j_component_refs([dv(d)], name, 8192, 0), 0),
        u => j_component_backedges(rest, name), u => False{})

@unsafe
def j_component_refs(+todo: List<&2,KTerm>, +name: String, +fuel: U32, +count: U32) -> U32:
  match todo:
    case Nil{}: count
    case Con{t, rest}:
      kc(U32, U32.is_eq(fuel, 0) || U32.is_ge(count, 3), u => 3, u =>
        j_component_refs(List.append(&2, KTerm, ks(t), rest), name, U32.sub(fuel, 1),
          U32.add(count, kc(U32, String.eq(tg(t), "Ref") && String.eq(nm(t), name), u => 1, u => 0))))

@unsafe
def j_component_slots(+at: U32, +total: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => Nil{}, u =>
    Con{kc(String, U32.is_eq(at, 0), u => "@root", u => ""), j_component_slots(U32.inc(at), total)})

@unsafe
def j_component_fields(+origin: String, +left: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(left, 0), u => rest, u =>
    Con{kc(String, String.eq(origin, ""), u => "", u => "@child"), j_component_fields(origin, U32.sub(left, 1), rest)})

# Every recursive first argument is a proper field descendant of the first
# original ADT, or the primitive predecessor extracted by a guarded Nat match.
# Reconstructed/equal Nat expressions are refused by the unchanged Var-origin
# check. No caller-provided value is admitted by this compile-time test.
@unsafe
def j_component_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +slots: List<&2,String>, +d: KDef, +depth: U32) -> Bool:
  match slots:
    case Nil{}: j_component_leaf(book, env, j_strip(t), d)
    case Con{origin, rest}:
      +body = j_strip(t)
      +head = wnf(book, ty)
      kc(Bool, U32.is_lt(depth, 32) && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)), u =>
        kc(Bool, String.eq(tg(body), "Lam") && String.eq(j_l_name(body), ""), u =>
          j_component_prefix(book, Con{kt("Env", origin, ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
            subst(kid(head, 1), ix(head), var(nm(body), ix(body))), rest, d, U32.inc(depth)), u =>
        kc(Bool, String.eq(tg(body), "Efq"), u => True{}, u =>
          j_component_match(book, env, body, head, slots, d, depth))), u => False{})

@unsafe
def j_component_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +slots: List<&2,String>, +d: KDef, +depth: U32) -> Bool:
  match slots:
    case Nil{}: False{}
    case Con{origin, rest}:
      +arg = wnf(book, kid(ty, 0))
      +owner = lookup(book, nm(arg))
      +c = lookup(dc(owner), nm(t))
      kc(Bool, String.eq(tg(t), "Mat") && String.eq(j_l_name(t), "") && U32.is_eq(terms_len(ks(t)), 2) &&
        String.eq(dk(c), "Ctr") && (j_primitive_type(book, arg, "Bool") || j_list_ground_type(book, arg) ||
          j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) || (j_primitive_type(book, arg, "Nat") && j_nat_loop_native(book)) || (Bool.not(db(owner)) && Bool.not(db(c)))), u =>
        j_component_prefix(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), j_component_fields(origin, da(c), rest), d, U32.inc(depth)) &&
        j_component_prefix(book, env, kid(t, 1), ty, slots, d, U32.inc(depth)), u => False{})

@unsafe
def j_component_origin(+env: List<&2,KTerm>, +id: U32) -> String:
  match env:
    case Nil{}: ""
    case Con{h, rest}: kc(String, U32.is_eq(ix(h), id), u => nm(h), u => j_component_origin(rest, id))

@unsafe
def j_component_self(+env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  +spine = j_call_spine(j_strip(t), Nil{})
  +first = j_strip(kid(spine, 0))
  String.eq(tg(spine), "Call") && String.eq(nm(spine), dn(d)) && U32.is_eq(terms_len(ks(spine)), da(d)) &&
    String.eq(tg(first), "Var") && String.eq(j_component_origin(env, ix(first)), "@child")

@unsafe
def j_component_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  +calls = j_component_refs([t], dn(d), 1024, 0)
  kc(Bool, U32.is_eq(calls, 0), u => True{}, u =>
    kc(Bool, U32.is_eq(calls, 2) && String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 3), u =>
      j_nat_loop_bindings(ks(t), 0, Nil{}) && j_component_independent(env, t) &&
      Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) && Bool.not(U32.is_eq(qt(kid(t, 1)), 0)) &&
      j_component_self(env, kid(kid(t, 0), 0), d) && j_component_self(env, kid(kid(t, 1), 0), d), u => kc(Bool, U32.is_eq(calls, 2), u => j_sequence_leaf(book, env, t, d), u => j_linear_leaf(book, env, t, d))))

# Calls keep the existing generic fallback and require the COMPLETE graph,
# rather than just the immediate function's descriptor, in the active proof.
@unsafe
def j_component_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String) -> String:
  +d = lookup(book, nm(spine))
  kc(String, U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    j_component_call(book, env, spine, generic, j_component_cached(book, dn(d))), u => generic)

@unsafe
def j_component_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    "(regionProof!==null&&regionProofCovers([" ++ j_region_names(j_pure_defs(pure)) ++ "])?" ++
      j_region_name(nm(spine)) ++ "$tree(" ++ j_apply_args(book, env, ks(spine), dt(lookup(book, nm(spine)))) ++ "):" ++ generic ++ ")", u => generic)

@unsafe
def j_component_declaration(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    j_component_covered_declaration(book, d, j_owned_term(j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dn(d), dv(d)))), u => "")

@unsafe
def j_component_covered_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  kc(String, j_flat_active(book) && U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0) &&
    j_hybrid_binary_shape(dv(d), dn(d), 8192),
    u => j_hybrid_declaration(book, d, body),
    u => j_component_stack_declaration(book, d, body, "$tree"))

# The normal and exhausted-budget declarations use the original iterative body.
# Only their private names differ; generic/public declarations stay unchanged.
@unsafe
def j_component_stack_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm, +suffix: String) -> String:
  "function " ++ j_region_name(dn(d)) ++ suffix ++ "(" ++ j_region_parameters(0, da(d)) ++ "){/* private structural component */" ++
    j_region_nested_slots(0, da(d)) ++ kc(String, U32.is_eq(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u =>
      "let $value;$step:{" ++ j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 0) ++ "}return $value;}\n", u =>
    "const $frames=[];let $top=0,$value;$visit:for(;;){$step:{" ++
    j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 0) ++ "}" ++
    "while($top){const $frame=$frames[$top-1];" ++ j_component_restore(0, da(d)) ++
    "if($frame.phase===2){" ++ j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 3) ++ "--$top;}else if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++
    j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 1) ++ "}else{" ++
    j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 2) ++ "--$top;}}return $value;}}\n")
@unsafe
def j_component_values(+at: U32, +total: U32) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, total), u => Nil{}, u => Con{"$s" ++ U32.show(at), j_component_values(U32.inc(at), total)})

@unsafe
def j_component_restore(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => "$s" ++ U32.show(at) ++ "=$frame.args[" ++ U32.show(at) ++ "];" ++ j_component_restore(U32.inc(at), total))

@unsafe
def j_component_save(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => "$s" ++ U32.show(at) ++ "," ++ j_component_save(U32.inc(at), total))

# Prefix emission repeats only inert private reads on resume. Leaf work occurs
# once; each child argument vector is evaluated at its original source phase.
@unsafe
def j_component_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +args: List<&2,String>, +d: KDef, +phase: U32) -> String:
  match args:
    case Nil{}: j_component_finish(book, env, j_strip(t), wnf(book, ty), d, phase)
    case Con{arg, rest}:
      +body = j_strip(t)
      +head = wnf(book, ty)
      kc(String, String.eq(tg(body), "Lam"), u =>
        "const " ++ j_local(ix(body)) ++ "=" ++ arg ++ ";" ++
        j_component_emit(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
          subst(kid(head, 1), ix(head), var(nm(body), ix(body))), rest, d, phase), u =>
      kc(String, String.eq(tg(body), "Mat"), u => j_component_emit_match(book, env, body, head, arg, rest, d, phase),
        u => "return bad('private component prefix invariant');"))

# Full original JPure coverage plus exact closed native Sigma identity proves
# the sole Tuple arm. Its owned pair fields are dense slots, not tagged .a.
@unsafe
def j_component_emit_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>, +d: KDef, +phase: U32) -> String:
  kc(String, j_pure_closed_sigma(book, wnf(book, kid(ty, 0))) && String.eq(nm(t), "Tuple"),
    u => "{" ++ j_component_emit(book, env, kid(t, 0), j_arm_type(book, ty, "Tuple"), j_native_tuple_fields(arg, 0, rest), d, phase) ++ "}",
    u => j_component_emit_match_tagged(book, env, t, ty, arg, rest, d, phase))

@unsafe
def j_component_emit_match_tagged(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>, +d: KDef, +phase: U32) -> String:
  +input = wnf(book, kid(ty, 0))
  +c = lookup(dc(lookup(book, nm(input))), nm(t))
  "if(" ++ kc(String, j_primitive_type(book, input, "Bool"),
    u => "(" ++ arg ++ ")===" ++ kc(String, String.eq(nm(t), "True"), u => "true", u => "false"),
    u => kc(String, j_primitive_type(book, input, "Nat"),
      u => "(" ++ arg ++ ")" ++ kc(String, String.eq(nm(t), "Zero"), u => "===0n", u => "!==0n"),
      u => "(" ++ arg ++ ").$===" ++ j_quote(nm(t)))) ++ "){" ++
    j_component_emit(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)),
      kc(List<&2,String>, j_primitive_type(book, input, "Nat"),
        u => kc(List<&2,String>, String.eq(nm(t), "Zero"), u => rest, u => Con{"(" ++ arg ++ "-1n)", rest}),
        u => j_flat_fields(book, input, arg, 0, da(c), rest)), d, phase) ++ "}else{" ++
    j_component_emit(book, env, kid(t, 1), ty, Con{arg, rest}, d, phase) ++ "}"

@unsafe
def j_component_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32) -> String:
  kc(String, U32.is_eq(phase, 4), u => j_hybrid_finish(book, env, t, ty, d), u =>
  kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 0), u =>
    kc(String, U32.is_eq(phase, 0), u => "$value=" ++ j_expr(book, env, t, ty, False{}) ++ ";break $step;",
      u => "return bad('private component continuation invariant');"), u =>
    kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 1), u => j_linear_finish(book, env, t, ty, d, phase), u =>
    kc(String, j_linear_emit_self(t, d), u => j_sequence_finish(book, env, t, d, phase), u =>
    kc(String, U32.is_eq(phase, 2), u =>
      "const " ++ j_local(ix(kid(t, 0))) ++ "=$frame.left;const " ++ j_local(ix(kid(t, 1))) ++ "=$value;" ++
      "$value=" ++ j_expr(book, j_context(book, env, ks(t)), kid(t, 2), ty, False{}) ++ ";", u =>
      j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase))))))

@unsafe
def j_component_enter(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +d: KDef, +phase: U32) -> String:
  "const $next=[" ++ j_apply_args(book, env, ks(spine), dt(d)) ++ "];" ++
    kc(String, U32.is_eq(phase, 0), u =>
      "let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={args:null,left:null,phase:0};" ++
      "$saved.args=[" ++ j_component_save(0, da(d)) ++ "];$saved.left=null;$saved.phase=0;++$top;", u => "") ++
    j_component_assign(0, da(d)) ++ "continue $visit;"

@unsafe
def j_component_assign(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => "$s" ++ U32.show(at) ++ "=$next[" ++ U32.show(at) ++ "];" ++ j_component_assign(U32.inc(at), total))

# Parallel RHSs see only the original prefix environment. JPure checks this
# independently; explicit freshness/use tests also justify emitted JS scopes.
@unsafe
def j_component_independent(+env: List<&2,KTerm>, +t: KTerm) -> Bool:
  String.eq(tg(j_env(env, ix(kid(t, 0)))), "Absent") && String.eq(tg(j_env(env, ix(kid(t, 1)))), "Absent") &&
    U32.is_eq(j_region_counter_uses([kid(kid(t, 0), 0), kid(kid(t, 1), 0)], ix(kid(t, 0)), 0), 0) &&
    U32.is_eq(j_region_counter_uses([kid(kid(t, 0), 0), kid(kid(t, 1), 0)], ix(kid(t, 1)), 0), 0)
# One structural child: direct tail transfer, or reconstruction through a tagged
# constructor / saturated known combiner. An inert sequential alias may precede
# the call; effectful or allocating lets remain generic.
@unsafe
def j_linear_alias(+t: KTerm, +name: String) -> Bool:
  String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 2) &&
    Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) && j_region_field_atom(j_strip(kid(kid(t, 0), 0))) &&
    U32.is_eq(j_component_refs([kid(t, 0)], name, 1024, 0), 0)

@unsafe
def j_linear_spine(+t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ctr"), u => kt("Call", nm(t), 0, 0, ks(t)), u => j_call_spine(t, Nil{}))

@unsafe
def j_linear_tel(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ctr"),
    u => j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))),
    u => dt(lookup(book, nm(j_linear_spine(t)))))

@unsafe
def j_linear_child(+env: List<&2,KTerm>, +args: List<&2,KTerm>, +d: KDef, +at: U32) -> U32:
  match args:
    case Nil{}: 32
    case Con{h, rest}: kc(U32, j_component_self(env, h, d), u => at, u => j_linear_child(env, rest, d, U32.inc(at)))

@unsafe
def j_linear_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  kc(Bool, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 1), u =>
    kc(Bool, j_linear_alias(t, dn(d)), u => j_linear_leaf(book, j_context(book, env, ks(t)), j_strip(kid(t, 1)), d), u =>
    kc(Bool, j_component_self(env, t, d), u => True{}, u =>
      j_linear_combine(book, env, t, d, j_linear_spine(t)))), u => False{})

@unsafe
def j_linear_combine(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef, +spine: KTerm) -> Bool:
  +target = lookup(book, nm(spine))
  (String.eq(tg(t), "Ctr") || (String.eq(tg(spine), "Call") && Bool.not(String.eq(nm(spine), dn(d))) &&
    Bool.not(j_primitive_call(book, spine)) && U32.is_eq(terms_len(ks(spine)), da(target)))) &&
    U32.is_lt(j_linear_child(env, ks(spine), d, 0), terms_len(ks(spine)))

@unsafe
def j_linear_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32) -> String:
  kc(String, j_linear_alias(t, dn(d)), u =>
    "{" ++ j_nat_loop_values(book, env, ks(t), 0) ++ "{" ++ j_nat_loop_names(ks(t), 0) ++
    j_linear_finish(book, j_context(book, env, ks(t)), j_strip(kid(t, 1)), ty, d, phase) ++ "}}", u =>
    kc(String, j_linear_emit_self(t, d), u =>
      "const $next=[" ++ j_apply_args(book, env, ks(j_call_spine(t, Nil{})), dt(d)) ++ "];" ++
      j_component_assign(0, da(d)) ++ "continue $visit;", u =>
      j_linear_split(book, env, t, ty, d, phase, j_linear_spine(t))))

@unsafe
def j_linear_split(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32, +spine: KTerm) -> String:
  +child = j_linear_emit_child(ks(spine), d, 0)
  +tel = j_linear_tel(book, t, ty)
  kc(String, U32.is_eq(phase, 3), u =>
    "$value=" ++ kc(String, String.eq(tg(t), "Ctr"),
      u => kc(String, j_owned_ctor(book, t, ty), u => kc(String, j_flat_data(book, ty), u => "({$:" ++ j_quote(nm(t)) ++ "," ++ j_flat_linear_args(book, env, ks(spine), tel, child, 0) ++ "})", u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "]})"), u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "])" ),
      u => j_linear_combiner_emit(book, nm(spine), j_producer_unary_resume(book, env, ks(spine), tel, child, 0))) ++ ";", u =>
    j_producer_unary_before(book, env, ks(spine), tel, child, 0) ++
    "const $next=[" ++ j_apply_args(book, env, ks(j_call_spine(j_strip(terms_at(ks(spine), child)), Nil{})), dt(d)) ++ "];" ++
    "let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={args:null,left:null,phase:0,before:null};" ++
    "$saved.args=[" ++ j_component_save(0, da(d)) ++ "];$saved.before=[" ++ j_region_vector_names("$u", 0, child) ++
    "];$saved.phase=2;++$top;" ++ j_component_assign(0, da(d)) ++ "continue $visit;")

@unsafe
def j_linear_combiner_emit(+book: List<&2,KDef>, +name: String, +args: String) -> String:
  +d = lookup(book, name)
  kc(String, j_finite_ready(book, d), u =>
    "((" ++ j_region_parameters(0, da(d)) ++ ")=>{" ++
      j_finite_emit(book, Nil{}, dv(d), dt(d), j_finite_slots(0, da(d))) ++ "})(" ++ args ++ ")",
    u => "callOwned(get(G," ++ j_quote(name) ++ "),[" ++ args ++ "])")

# The preceding analysis proved descendant ownership. Emission's lexical Env
# carries types and names, not @child provenance, so it uses only the already
# proved saturated self-call shape to recover the continuation position.
@unsafe
def j_linear_emit_self(+t: KTerm, +d: KDef) -> Bool:
  +spine = j_call_spine(j_strip(t), Nil{})
  String.eq(tg(spine), "Call") && String.eq(nm(spine), dn(d)) && U32.is_eq(terms_len(ks(spine)), da(d))

@unsafe
def j_linear_emit_child(+args: List<&2,KTerm>, +d: KDef, +at: U32) -> U32:
  match args:
    case Nil{}: 32
    case Con{h, rest}: kc(U32, j_linear_emit_self(h, d), u => at, u => j_linear_emit_child(rest, d, U32.inc(at)))


# Inherited proof context is used only for the body of an independently admitted
# private worker. Its public and generic call boundaries retain the complete
# graph guard. Exact definitions prevent same-name or stale graph substitution.
@unsafe
def j_covered_defs(+book: List<&2,KDef>, +context: List<&2,KDef>, +needed: List<&2,KDef>) -> Bool:
  match needed:
    case Nil{}: True{}
    case Con{d, rest}:
      +found = lookup(context, dn(d))
      kc(Bool, String.eq(dk(found), "Def") && exact_def(d, found) && exact_def(d, lookup(book, dn(d))),
        u => j_covered_defs(book, context, rest), u => False{})

# Annotation preserves original call-result typing for the ordinary shared
# binder/argument emitter. Lowering plans are never sent back to the checker.
@unsafe
def j_covered_result(+ty: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: ty
    case Con{h, rest}: j_covered_result(j_app_type(ty, h), rest)

# Preserve the original saturated App/Call shell around a structural self call.
# Unary classification needs that shell to discover its continuation child;
# inherited proof lowering may still transform independent argument expressions.
@unsafe
def j_covered_term(+book: List<&2,KDef>, +context: List<&2,KDef>, +owner: String, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u =>
    k_with_children(t, [j_covered_term(book, context, owner, kid(t, 0)), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "Var") || String.eq(tg(t), "Ref") || String.eq(tg(t), "Lit"), u => t, u =>
  kc(KTerm, String.eq(tg(t), "App"), u =>
    j_covered_shape_app(book, context, owner, t, k_with_children(t, j_covered_terms(book, context, owner, ks(t)))), u =>
    k_with_children(t, j_covered_terms(book, context, owner, ks(t))))))

@unsafe
def j_covered_terms(+book: List<&2,KDef>, +context: List<&2,KDef>, +owner: String, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_covered_term(book, context, owner, h), j_covered_terms(book, context, owner, rest)}


@unsafe
def j_covered_shape_app(+book: List<&2,KDef>, +context: List<&2,KDef>, +owner: String, +original: KTerm, +rebuilt: KTerm) -> KTerm:
  kc(KTerm, String.eq(owner, "") || U32.is_eq(j_component_refs([original], owner, 8192, 0), 0),
    u => j_covered_app(book, context, original, rebuilt), u => rebuilt)

@unsafe
def j_covered_app(+book: List<&2,KDef>, +context: List<&2,KDef>, +original: KTerm, +rebuilt: KTerm) -> KTerm:
  +spine = j_call_spine(original, Nil{})
  +d = lookup(book, nm(spine))
  kc(KTerm, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(ks(spine)), da(d)) &&
    String.eq(dk(lookup(context, dn(d))), "Def") && exact_def(d, lookup(context, dn(d))), u =>
      j_covered_component(book, context, original, rebuilt, d, j_component_cached(book, dn(d))),
    u => j_direct_call_term(book, context, rebuilt))

@unsafe
def j_covered_component(+book: List<&2,KDef>, +context: List<&2,KDef>, +original: KTerm, +rebuilt: KTerm, +d: KDef, +pure: JPure) -> KTerm:
  kc(KTerm, j_pure_valid(pure) && j_covered_defs(book, context, j_pure_defs(pure)), u =>
    j_region_annotate(kt("JCall", dn(d), 0, 1, ks(j_call_spine(rebuilt, Nil{}))),
      j_covered_result(dt(d), ks(j_call_spine(original, Nil{})))),
    u => j_direct_call_term(book, context, rebuilt))


# Only independently admitted private bodies invoke this plan transform. Keep
# original Ctr shape and identity so structural linear reconstruction and shared
# binder typing still see their original source nodes. No public expression is
# marked, and no native representation is changed.
@unsafe
def j_owned_term(+t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u =>
    k_with_children(t, [j_owned_term(kid(t, 0)), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "Ctr"), u =>
    k_rebuild(t, nm(t), ix(t), qt(t), j_owned_terms(ks(t)), Con{"$private.owned.ctor", rm(t)}, kb(t), ke(t)),
    u => k_with_children(t, j_owned_terms(ks(t)))))

@unsafe
def j_owned_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_owned_term(h), j_owned_terms(rest)}

# The runtime ctor's nonnative branch is exactly {$:name,a:fields}; it has no
# registration or ownership side effect. Preserve its tag, field array, field
# order, fresh root allocation, and shared child references literally.
@unsafe
def j_owned_ctor(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> Bool:
  kc(Bool, has_name(rm(t), "$private.owned.ctor"),
    u => j_owned_ctor_type(book, t, wnf(book, ty)), u => False{})

@unsafe
def j_owned_ctor_type(+book: List<&2,KDef>, +t: KTerm, +head: KTerm) -> Bool:
  +owner = lookup(book, nm(head))
  +c = j_layout_ctor(book, head, nm(t))
  String.eq(tg(head), "ADT") &&
    String.eq(dk(owner), "ADT") && Bool.not(db(owner)) && j_pure_type(book, head) &&
    String.eq(dk(c), "Ctr") && String.eq(dn(c), nm(t)) && Bool.not(db(c)) &&
    U32.is_eq(terms_len(ks(t)), da(c))

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
  kc(Bool, String.eq(tg(t), "JDirectCall"), u => U32.is_eq(terms_len(ks(t)), da(lookup(book, nm(t)))) && exact_def(lookup(graph, nm(t)), lookup(book, nm(t))) && j_pure_valid(j_direct_cached(book, nm(t))) && j_covered_defs(book, graph, j_pure_defs(j_direct_cached(book, nm(t)))) &&
    j_flat_audits(book, graph, locals, self, ks(t), U32.sub(fuel, 1)), u =>
    String.contains("|Lam|Mat|Ctr|Let|Bind|Var|Lit|JUnpack|JSlot|JLoopSlot|JNatRest|JNatCase|JIf|Efq|", "|" ++ tg(t) ++ "|") &&
    j_flat_audits(book, graph, locals, self, kc(List<&2,KTerm>, String.eq(tg(t), "JUnpack"), u => [kid(t, 0)], u => ks(t)), U32.sub(fuel, 1)))))), u => False{})

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
    j_covered_defs(book, graph, j_pure_defs(j_component_cached(book, nm(t)))), u => String.eq(dk(lookup(locals, nm(t))), "Def") && Bool.not(db(lookup(locals, nm(t)))) && Bool.not(String.eq(tg(dv(lookup(locals, nm(t)))), "JResidual"))) &&
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
  kc(Bool, j_pure_valid(pure), u => j_flat_linear_safe(dv(d), dn(d)) && j_flat_audit(book, graph, locals, dn(d), j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dn(d), dv(d)), 8192), u =>
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
    j_flat_root_emit(j_flat_book(book, j_flat_source_root(book, graph, dn(d))), d, graph, locals, normal, j_owned_term(j_flat_term(book, graph, j_region_term(s)))), u => normal)

@unsafe
def j_flat_root_emit(+book: List<&2,KDef>, +d: KDef, +graph: List<&2,KDef>, +locals: List<&2,KDef>, +normal: String, +body: KTerm) -> String:
  kc(String, j_flat_active(book), u => "{/* private flat closed graph */" ++ j_flat_clones(book, graph) ++ j_region_definitions(book, locals) ++ j_nat_loop_generic(book, Nil{}, body, dt(d), 0) ++ "}", u => normal)

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

# A sequential structural tail call contains one descendant result in an inert
# scalar context. Both calls have independently proved proper-child origins.
@unsafe
def j_sequence_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  j_component_self(env, t, d) &&
    j_sequence_args(book, env, ks(j_call_spine(j_strip(t), Nil{})), d, 32)

@unsafe
def j_sequence_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +d: KDef, +fuel: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_sequence_context(book, env, j_strip(h), d, fuel) && j_sequence_args(book, env, rest, d, fuel)

@unsafe
def j_sequence_atoms(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_region_field_atom(j_strip(h)) && j_sequence_atoms(rest)

@unsafe
def j_sequence_context(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef, +fuel: U32) -> Bool:
  +spine = j_call_spine(t, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, j_region_field_atom(t), u => True{}, u =>
    kc(Bool, j_component_self(env, t, d), u =>
      U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 1) && j_sequence_atoms(ks(spine)), u =>
      j_primitive_call(book, spine) &&
        String.contains("|U32.add|U32.sub|U32.mul|U32.and|U32.or|U32.xor|", "|" ++ nm(spine) ++ "|") &&
        j_sequence_args(book, env, ks(spine), d, U32.sub(fuel, 1)))), u => False{})

# The original source proof establishes the unique descendant hole. The
# annotated existing slot preserves typing for the unchanged argument emitter.
@unsafe
def j_sequence_hole(+book: List<&2,KDef>, +t: KTerm, +d: KDef) -> KTerm:
  kc(KTerm, j_linear_emit_self(t, d), u =>
    j_region_annotate(kt("JSlot", "", 0, 0, Nil{}), j_fold_root_result(book, dt(d), da(d))), u =>
    k_with_children(t, j_sequence_holes(book, ks(t), d)))

@unsafe
def j_sequence_holes(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +d: KDef) -> List<&2,KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_sequence_hole(book, h, d), j_sequence_holes(book, rest, d)}

@unsafe
def j_sequence_find(+todo: List<&2,KTerm>, +d: KDef) -> KTerm:
  match todo:
    case Nil{}: atom("Absent")
    case Con{h, rest}: kc(KTerm, j_linear_emit_self(h, d), u => j_strip(h),
      u => j_sequence_find(List.append(&2, KTerm, ks(h), rest), d))

@unsafe
def j_sequence_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef, +phase: U32) -> String:
  +args = ks(j_call_spine(t, Nil{}))
  kc(String, U32.is_eq(phase, 3), u =>
    "const $p0=$value;const $next=[" ++ j_apply_args(book, env, j_sequence_holes(book, args, d), dt(d)) ++
    "];--$top;" ++ j_component_assign(0, da(d)) ++ "continue $visit;", u =>
    "const $next=[" ++ j_apply_args(book, env, ks(j_call_spine(j_sequence_find(args, d), Nil{})), dt(d)) ++ "];" ++
    "let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={args:null,left:null,phase:2};" ++
    "$saved.args=[" ++ j_component_save(0, da(d)) ++ "];$saved.phase=2;++$top;" ++
    j_component_assign(0, da(d)) ++ "continue $visit;")


# This helper is used only after a complete typed native Tuple arm is proved.
# Preserve binder order and aliases; no shape check or field vector is emitted.
@unsafe
def j_native_tuple_fields(+arg: String, +at: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, 2), u => rest, u =>
    Con{"(" ++ arg ++ ")[" ++ U32.show(at) ++ "]", j_native_tuple_fields(arg, U32.inc(at), rest)})

# The selected root carries checked annotations; the source index keeps its
# canonical definition. After the complete normalized audit, record that exact
# source root in the identity-only context; every other graph object stays exact.
@unsafe
def j_flat_source_root(+book: List<&2,KDef>, +graph: List<&2,KDef>, +root: String) -> List<&2,KDef>:
  match graph:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{kc(KDef, String.eq(dn(d), root), u => lookup(book, root), u => d), j_flat_source_root(book, rest, root)}


# A cycle containing a budget-reset component is already refused by its exact
# full-closure j_component_closed/backedges proof. Direct helpers independently
# require an acyclic closure; the flat audit covers every emitted consumer.
# Hence native depth is bounded by source graph depth, not input tree depth.
# This initial clone accepts only the existing two-child Let leaves; unary,
# sequential and tail continuations keep the original iterative emitter.
@unsafe
def j_hybrid_binary_shape(+t: KTerm, +owner: String, +fuel: U32) -> Bool:
  +body = j_strip(t)
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(body), "Lam"),
      u => j_hybrid_binary_shape(kid(body, 0), owner, U32.sub(fuel, 1)), u =>
    kc(Bool, String.eq(tg(body), "Mat"),
      u => j_hybrid_binary_shape(kid(body, 0), owner, U32.sub(fuel, 1)) &&
        j_hybrid_binary_shape(kid(body, 1), owner, U32.sub(fuel, 1)), u =>
    kc(Bool, U32.is_eq(j_component_refs([body], owner, 1024, 0), 0), u => True{}, u =>
      String.eq(tg(body), "Let") && U32.is_eq(terms_len(ks(body)), 3) &&
      U32.is_eq(j_component_refs([body], owner, 1024, 0), 2) &&
      String.eq(nm(j_call_spine(kid(kid(body, 0), 0), Nil{})), owner) &&
      String.eq(nm(j_call_spine(kid(kid(body, 1), 0), Nil{})), owner)))), u => False{})

# Check the budget before any source prefix or field demand. The fallback gets
# the captured current parameters once, without a new guard or proof extent.
@unsafe
def j_hybrid_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  +name = j_region_name(dn(d)) ++ "$tree"
  +args = j_region_parameters(0, da(d))
  "function " ++ name ++ "(" ++ args ++ "){return " ++ name ++ "$hybrid(" ++ args ++ ",16);}" ++
  "function " ++ name ++ "$hybrid(" ++ args ++ ",$budget){if($budget===0)return " ++ name ++ "$stack(" ++ args ++ ");" ++
    j_region_nested_slots(0, da(d)) ++ "let $value;$step:{" ++
    j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 4) ++ "}return $value;}" ++
    j_component_stack_declaration(book, d, body, "$tree$stack")

# Reuse original typed child arguments and binders. Phase0 child work finishes
# before phase1 arguments; the combiner sees exactly those two completed values.
@unsafe
def j_hybrid_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef) -> String:
  kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 0),
    u => "$value=" ++ j_expr(book, env, t, ty, False{}) ++ ";break $step;", u =>
      "const " ++ j_local(ix(kid(t, 0))) ++ "=" ++ j_region_name(dn(d)) ++ "$tree$hybrid(" ++
        j_apply_args(book, env, ks(j_call_spine(kid(kid(t, 0), 0), Nil{})), dt(d)) ++ "$budget-1);" ++
      "const " ++ j_local(ix(kid(t, 1))) ++ "=" ++ j_region_name(dn(d)) ++ "$tree$hybrid(" ++
        j_apply_args(book, env, ks(j_call_spine(kid(kid(t, 1), 0), Nil{})), dt(d)) ++ "$budget-1);" ++
      "$value=" ++ j_expr(book, j_context(book, env, ks(t)), kid(t, 2), ty, False{}) ++ ";break $step;")
