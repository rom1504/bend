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
    kc(JPure, String.eq(tg(wnf(book, kid(head, 0))), "ADT") && Bool.not(db(lookup(book, nm(wnf(book, kid(head, 0)))))), u =>
    kc(JPure, j_u32_bounded([dv(d)], 512) && Bool.not(j_l_deep(dv(d), 0)), u =>
    kc(JPure, U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0), u =>
    kc(JPure, j_region_capture_eligible(book, d) &&
      j_component_prefix(book, Nil{}, dv(d), dt(d), j_component_slots(0, da(d)), d, 0), u =>
        j_component_closed(d, j_pure_graph(book, d, JPure{Nil{}, 32768, True{}})),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}),
      u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}}), u => JPure{Nil{}, 0, False{}})

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
# original ADT. No caller-provided value is admitted by this compile-time test.
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
        String.eq(dk(c), "Ctr") && (j_primitive_type(book, arg, "Bool") || (Bool.not(db(owner)) && Bool.not(db(c)))), u =>
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
      j_component_self(env, kid(kid(t, 0), 0), d) && j_component_self(env, kid(kid(t, 1), 0), d), u => False{}))

# Calls keep the existing generic fallback and require the COMPLETE graph,
# rather than just the immediate function's descriptor, in the active proof.
@unsafe
def j_component_named(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String) -> String:
  +d = lookup(book, nm(spine))
  kc(String, U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    j_component_call(book, env, spine, generic, j_component_plan(book, d)), u => generic)

@unsafe
def j_component_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +generic: String, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    "(regionProof!==null&&regionProofCovers([" ++ j_region_names(j_pure_defs(pure)) ++ "])?" ++
      j_region_name(nm(spine)) ++ "$tree(" ++ j_apply_args(book, env, ks(spine), dt(lookup(book, nm(spine)))) ++ "):" ++ generic ++ ")", u => generic)

@unsafe
def j_component_declaration(+book: List<&2,KDef>, +d: KDef, +pure: JPure) -> String:
  kc(String, j_pure_valid(pure), u =>
    "function " ++ j_region_name(dn(d)) ++ "$tree(" ++ j_region_parameters(0, da(d)) ++ "){/* private structural component */" ++
    j_region_nested_slots(0, da(d)) ++ "const $frames=[];let $top=0,$value;$visit:for(;;){$step:{" ++
    j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 0) ++ "}" ++
    "while($top){const $frame=$frames[$top-1];" ++ j_component_restore(0, da(d)) ++
    "if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++
    j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 1) ++ "}else{" ++
    j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 2) ++ "--$top;}}return $value;}}\n", u => "")

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

@unsafe
def j_component_emit_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>, +d: KDef, +phase: U32) -> String:
  +input = wnf(book, kid(ty, 0))
  +c = lookup(dc(lookup(book, nm(input))), nm(t))
  "if(" ++ kc(String, j_primitive_type(book, input, "Bool"),
    u => "(" ++ arg ++ ")===" ++ kc(String, String.eq(nm(t), "True"), u => "true", u => "false"),
    u => "(" ++ arg ++ ").$===" ++ j_quote(nm(t))) ++ "){" ++
    j_component_emit(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), j_finite_fields(arg, 0, da(c), rest), d, phase) ++ "}else{" ++
    j_component_emit(book, env, kid(t, 1), ty, Con{arg, rest}, d, phase) ++ "}"

@unsafe
def j_component_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32) -> String:
  kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 0), u =>
    kc(String, U32.is_eq(phase, 0), u => "$value=" ++ j_expr(book, env, t, ty, False{}) ++ ";break $step;",
      u => "return bad('private component continuation invariant');"), u =>
    kc(String, U32.is_eq(phase, 2), u =>
      "const " ++ j_local(ix(kid(t, 0))) ++ "=$frame.left;const " ++ j_local(ix(kid(t, 1))) ++ "=$value;" ++
      "$value=" ++ j_expr(book, j_context(book, env, ks(t)), kid(t, 2), ty, False{}) ++ ";", u =>
      j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase)))

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
