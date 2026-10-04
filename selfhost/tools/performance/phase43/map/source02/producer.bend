# Private dynamic-depth sum producers reuse the existing two-child tree stack.
# No public recursive-record arguments or result representation are introduced.
@unsafe
def j_producer_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_fold_type(book, head), u =>
    String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_region_scalar(book, kid(head, 0)) &&
      j_producer_signature(book, kid(head, 1), U32.sub(left, 1)))

# Normalize only independent single sequential lets; order stays left then right.
# Globally fresh binder identities make the complete RHS use check decisive.
@unsafe
def j_producer_normalize(+t: KTerm) -> KTerm:
  +body = j_strip(t)
  kc(KTerm, String.eq(tg(body), "Lam"), u => k_with_children(body, [j_producer_normalize(kid(body, 0))]), u =>
    kc(KTerm, String.eq(tg(body), "Let") && U32.is_eq(terms_len(ks(body)), 2), u =>
      j_producer_nested_let(body, j_strip(kid(body, 1))), u => body))

@unsafe
def j_producer_nested_let(+outer: KTerm, +inner: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(inner), "Let") && U32.is_eq(terms_len(ks(inner)), 2) &&
    U32.is_eq(j_region_counter_uses([kid(kid(inner, 0), 0)], ix(kid(outer, 0)), 0), 0), u =>
      k_with_children(outer, [kid(outer, 0), kid(inner, 0), kid(inner, 1)]), u => outer)

@unsafe
def j_producer_plan(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_nat_shape(book, d, True{}) && j_producer_signature(book, dt(d), da(d)), u =>
    j_producer_shape(book, d, active, depth, s, j_producer_normalize(kid(j_strip(kid(j_strip(dv(d)), 1)), 0))), u => j_region_fail(s))

@unsafe
def j_producer_shape(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild, +succ: KTerm) -> JRegionBuild:
  kc(JRegionBuild, j_tree_shape(j_nat_loop_unwrap(succ), dn(d), ix(succ), da(d)) &&
    j_tree_distinct(succ, j_nat_loop_unwrap(succ)), u =>
    j_producer_pure(book, d, active, depth, s, succ,
      j_pure_graph(book, d, JPure{Nil{}, j_region_fuel(s), True{}})),
      u => j_producer_unary_shape(book, d, active, depth, s, succ))

@unsafe
def j_producer_pure(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild, +succ: KTerm, +pure: JPure) -> JRegionBuild:
  kc(JRegionBuild, j_pure_valid(pure), u =>
    j_producer_zero(book, d, active, depth, succ,
      j_region_prefix(book, Nil{}, kid(j_strip(dv(d)), 0), j_arm_type(book, wnf(book, dt(d)), "Zero"),
        0, U32.sub(da(d), 1), True{}, "", Con{"@producer", Con{dn(d), active}}, U32.inc(depth),
        j_region_residual_merge(j_pure_defs(pure), JRegionBuild{j_region_term(s), j_region_helpers(s), j_pure_fuel(pure), True{}}))), u => j_region_fail(s))

@unsafe
def j_producer_zero(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +succ: KTerm, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_producer_done(d, j_region_term(s), j_producer_prefix(book, Nil{}, succ,
      j_arm_type(book, wnf(book, dt(d)), "Succ"), da(d), dn(d), Con{"@producer", Con{dn(d), active}}, U32.inc(depth), s)), u => s)

# Parent scalars and the two child results stay in distinct immutable slots.
@unsafe
def j_producer_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +left: U32, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0), u =>
    kc(JRegionBuild, U32.is_eq(left, 0), u =>
      j_producer_left(book, env, body, head, name, active, depth,
        j_region_expr(book, env, kid(kid(body, 0), 0), head, name, active, depth, 0, j_region_tick(s))), u =>
      j_region_prefix_lam(body, True{}, j_producer_prefix(book,
        Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
        subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.sub(left, 1), name, active, depth, j_region_tick(s)))), u => j_region_fail(s))

@unsafe
def j_producer_left(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_producer_right(book, env, t, ty, active, depth, k_with_children(kid(t, 0), [j_region_term(s)]),
      j_region_expr(book, env, kid(kid(t, 1), 0), ty, name, active, depth, 0, s)), u => s)

@unsafe
def j_producer_right(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +active: List<&2,String>, +depth: U32, +left: KTerm, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_tree_combine(t, ty, left, k_with_children(kid(t, 1), [j_region_term(s)]),
      j_region_expr(book, Con{kt("Env", "", ix(kid(t, 0)), 0, [ty]), Con{kt("Env", "", ix(kid(t, 1)), 0, [ty]), env}},
        kid(t, 2), ty, "", active, depth, 0, s)), u => s)

@unsafe
def j_producer_done(+d: KDef, +zero: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_helper_done(d, j_region_result(s, kt("JProducer", "", 0, 0, [zero, j_region_term(s)])))

@unsafe
def j_producer_or_regular(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild, +producer: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(producer), u => producer, u =>
    kc(JRegionBuild, j_nat_local_shape(book, d),
      u => j_region_nested(book, d, Con{dn(d), active}, U32.inc(depth), s),
      u => j_region_helper_done(d, j_region_prefix(book, Nil{}, dv(d), dt(d), 0, da(d), False{}, "", Con{dn(d), active}, U32.inc(depth), s))))

@unsafe
def j_producer_emit(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, U32.is_eq(qt(dv(d)), 1), u => j_producer_unary_emit(book, d), u => j_producer_binary_emit(book, d))

@unsafe
def j_producer_binary_emit(+book: List<&2,KDef>, +d: KDef) -> String:
  "/* private sum producer */" ++ j_region_nested_slots(0, da(d)) ++ "const $frames=[];let $top=0,$value;$visit:for(;;){if($s0!==0n){" ++
    j_tree_enter(book, Nil{}, kid(dv(d), 1), j_arm_type(book, wnf(book, dt(d)), "Succ"), d, kid(dv(d), 1), 0, False{}) ++ "}{" ++
    j_region_body(book, Nil{}, kid(dv(d), 0), j_arm_type(book, wnf(book, dt(d)), "Zero"), 1, "$value=", False{}) ++ "}" ++
    "while($top){const $frame=$frames[$top-1];if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++
    j_tree_enter(book, Nil{}, kid(dv(d), 1), j_arm_type(book, wnf(book, dt(d)), "Succ"), d, kid(dv(d), 1), 0, True{}) ++ "}" ++
    j_producer_unwind(book, Nil{}, kid(dv(d), 1), j_arm_type(book, wnf(book, dt(d)), "Succ"), 0) ++
    "--$top;}return $value;}"

@unsafe
def j_producer_unwind(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32) -> String:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(String, String.eq(tg(body), "Lam"), u =>
    "const " ++ j_local(ix(body)) ++ "=$frame.args[" ++ U32.show(at) ++ "];" ++
    j_producer_unwind(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
      subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.inc(at)), u =>
    "const " ++ j_local(ix(kid(body, 0))) ++ "=$frame.left;const " ++ j_local(ix(kid(body, 1))) ++ "=$value;" ++
    "$value=" ++ j_expr(book, j_context(book, env, ks(body)), kid(body, 2), head, False{}) ++ ";")

# Constructor admission is confined to a whole-graph-proved producer context.
# Existing Ctr emission preserves the original tag/field-array representation.
@unsafe
def j_producer_ctor(+book: List<&2,KDef>, +ty: KTerm, +name: String, +active: List<&2,String>) -> KDef:
  kc(KDef, (has_name(active, "@producer") && j_fold_type(book, ty)) || j_list_ground_type(book, ty) || j_pure_closed_map(book, ty),
    u => lookup(dc(lookup(book, nm(ty))), name), u => j_region_local_ctor(book, ty))

# One child in a known saturated combiner call. Argument order is split at the
# child: earlier values are captured during descent, later values on unwind.
@unsafe
def j_producer_unary_shape(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild, +succ: KTerm) -> JRegionBuild:
  +spine = j_call_spine(j_nat_loop_unwrap(succ), Nil{})
  kc(JRegionBuild, String.eq(tg(spine), "Call") && Bool.not(String.eq(nm(spine), dn(d))) &&
    U32.is_gt(terms_len(ks(spine)), 0) && U32.is_le(terms_len(ks(spine)), 8), u =>
    kc(JRegionBuild, j_u32_bounded([dv(d)], 512), u =>
    kc(JRegionBuild, U32.is_eq(j_component_refs([dv(d)], dn(d), 1024, 0), 1) &&
      U32.is_lt(j_producer_unary_index(ks(spine), dn(d), ix(succ), da(d), 0), terms_len(ks(spine))), u =>
      j_producer_unary_pure(book, d, active, depth, s, succ,
        j_component_closed(d, j_pure_graph(book, d, JPure{Nil{}, j_region_fuel(s), True{}}))),
      u => j_region_fail(s)), u => j_region_fail(s)), u => j_region_fail(s))

@unsafe
def j_producer_unary_index(+args: List<&2,KTerm>, +name: String, +pred: U32, +total: U32, +at: U32) -> U32:
  match args:
    case Nil{}: 32
    case Con{h, rest}:
      kc(U32, j_nat_loop_call(j_call_spine(j_strip(h), Nil{}), name, pred, total), u => at,
        u => j_producer_unary_index(rest, name, pred, total, U32.inc(at)))

@unsafe
def j_producer_unary_pure(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild, +succ: KTerm, +pure: JPure) -> JRegionBuild:
  kc(JRegionBuild, j_pure_valid(pure), u =>
    j_producer_unary_zero(book, d, active, depth, succ,
      j_region_prefix(book, Nil{}, kid(j_strip(dv(d)), 0), j_arm_type(book, wnf(book, dt(d)), "Zero"),
        0, U32.sub(da(d), 1), True{}, "", Con{"@producer", Con{dn(d), active}}, U32.inc(depth),
        j_region_residual_merge(j_pure_defs(pure), JRegionBuild{j_region_term(s), j_region_helpers(s), j_pure_fuel(pure), True{}}))),
    u => j_region_fail(s))

@unsafe
def j_producer_unary_zero(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +succ: KTerm, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_producer_unary_done(d, j_region_term(s), j_producer_unary_prefix(book, Nil{}, succ,
      j_arm_type(book, wnf(book, dt(d)), "Succ"), da(d), dn(d), Con{"@producer", Con{dn(d), active}}, U32.inc(depth), s)), u => s)

@unsafe
def j_producer_unary_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +left: U32, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0), u =>
    kc(JRegionBuild, U32.is_eq(left, 0), u =>
      j_producer_unary_call(book, env, j_call_spine(body, Nil{}), head, name, active, depth, j_region_tick(s)), u =>
      j_region_prefix_lam(body, True{}, j_producer_unary_prefix(book,
        Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
        subst(kid(head, 1), ix(head), var(nm(body), ix(body))), U32.sub(left, 1), name, active, depth, j_region_tick(s)))), u => j_region_fail(s))

@unsafe
def j_producer_unary_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +d = lookup(book, nm(spine))
  kc(JRegionBuild, U32.is_eq(da(d), terms_len(ks(spine))), u =>
    j_producer_unary_helper(book, env, spine, ty, name, active, depth,
      j_region_helper(book, d, active, depth, s)), u => j_region_fail(s))

@unsafe
def j_producer_unary_helper(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    kc(JRegionBuild, Bool.not(String.eq(tg(dv(lookup(j_region_helpers(s), nm(spine)))), "JResidual")), u =>
      j_region_call_done(book, spine, ty, True{}, j_producer_unary_args(book, env, ks(spine),
        dt(lookup(book, nm(spine))), name, active, depth, s)), u => j_region_fail(s)), u => s)

@unsafe
def j_producer_unary_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  match args:
    case Nil{}: j_region_result(s, kt("JList", "", 0, 0, Nil{}))
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(JRegionBuild, j_region_valid(s) && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)), u =>
        j_producer_unary_arg(book, env, rest, j_app_type(head, h), name, active, depth,
          j_region_expr(book, env, h, kid(head, 0), name, active, depth, 0, s)), u => j_region_fail(s))

@unsafe
def j_producer_unary_arg(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,KTerm>, +ty: KTerm, +name: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u => j_region_list_prepend(j_region_term(s),
    j_producer_unary_args(book, env, rest, ty, name, active, depth, s)), u => s)

@unsafe
def j_producer_unary_done(+d: KDef, +zero: KTerm, +s: JRegionBuild) -> JRegionBuild:
  +succ = j_region_term(s)
  +body = j_strip(j_nat_loop_unwrap(succ))
  +child = j_producer_unary_index(ks(body), dn(d), ix(succ), da(d), 0)
  kc(JRegionBuild, j_region_valid(s) && String.eq(tg(body), "JCall") && U32.is_lt(child, terms_len(ks(body))), u =>
    j_region_helper_done(d, j_region_result(s, kt("JProducer", "", child, 1, [zero, succ]))), u => j_region_fail(s))

@unsafe
def j_producer_unary_emit(+book: List<&2,KDef>, +d: KDef) -> String:
  "/* private unary producer */" ++ j_region_nested_slots(0, da(d)) ++
    "const $frames=[];let $top=0,$value;$visit:for(;;){if($s0!==0n){" ++
    j_producer_unary_enter(book, Nil{}, kid(dv(d), 1), j_arm_type(book, wnf(book, dt(d)), "Succ"), d, 0, False{}) ++ "}{" ++
    j_region_body(book, Nil{}, kid(dv(d), 0), j_arm_type(book, wnf(book, dt(d)), "Zero"), 1, "$value=", False{}) ++ "}" ++
    "while($top){const $frame=$frames[$top-1];" ++
    j_producer_unary_enter(book, Nil{}, kid(dv(d), 1), j_arm_type(book, wnf(book, dt(d)), "Succ"), d, 0, True{}) ++
    "--$top;}return $value;}"

@unsafe
def j_producer_unary_enter(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +at: U32, +resume: Bool) -> String:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(String, String.eq(tg(body), "Lam"), u =>
    "const " ++ j_local(ix(body)) ++ "=" ++ kc(String, resume,
      u => "$frame.args[" ++ U32.show(at) ++ "]",
      u => "$s" ++ U32.show(at) ++ kc(String, U32.is_eq(at, 0), u => "-1n", u => "")) ++ ";" ++
    j_producer_unary_enter(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env}, kid(body, 0),
      subst(kid(head, 1), ix(head), var(nm(body), ix(body))), d, U32.inc(at), resume), u =>
    kc(String, resume,
      u => "$value=" ++ j_region_name(nm(body)) ++ "(" ++ j_producer_unary_resume(book, env, ks(body),
        dt(lookup(book, nm(body))), ix(dv(d)), 0) ++ ");",
      u => j_producer_unary_descend(book, env, body, d)))

@unsafe
def j_producer_unary_descend(+book: List<&2,KDef>, +env: List<&2,KTerm>, +body: KTerm, +d: KDef) -> String:
  j_producer_unary_before(book, env, ks(body), dt(lookup(book, nm(body))), ix(dv(d)), 0) ++
  j_nat_loop_next(book, env, ks(j_call_spine(j_strip(kid(body, ix(dv(d)))), Nil{})), dt(d), 0) ++
  "$frames[$top++]={args:[" ++ j_tree_aliases(kid(dv(d), 1)) ++ "],before:[" ++
  j_region_vector_names("$u", 0, ix(dv(d))) ++ "]};" ++ j_nat_loop_assign(da(d), 0) ++ "continue $visit;"

@unsafe
def j_producer_unary_before(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +child: U32, +at: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(String, U32.is_eq(at, child), u => "", u =>
        "const $u" ++ U32.show(at) ++ "=" ++ j_expr(book, env, h, kid(head, 0), False{}) ++ ";" ++
        j_producer_unary_before(book, env, rest, j_app_type(head, h), child, U32.inc(at)))

@unsafe
def j_producer_unary_resume(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +child: U32, +at: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(String, U32.is_lt(at, child), u => "$frame.before[" ++ U32.show(at) ++ "]", u =>
        kc(String, U32.is_eq(at, child), u => "$value", u => j_expr(book, env, h, kid(head, 0), False{}))) ++ "," ++
      j_producer_unary_resume(book, env, rest, j_app_type(head, h), child, U32.inc(at))

# Only the already whole-graph-proved producer context may nest constructors.
# Leaves keep the existing atom/primitive grammar; typed argument planning still
# checks every constructor and field. Ordinary public/root admission is unchanged.
@unsafe
def j_producer_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +left: U32, +active: List<&2,String>) -> Bool:
  kc(Bool, has_name(active, "@producer"), u => j_producer_nested_fields(book, xs, left, 128),
    u => j_fold_terminal_fields(book, xs, left))

@unsafe
def j_producer_nested_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +left: U32, +fuel: U32) -> Bool:
  match xs:
    case Nil{}: U32.is_eq(left, 0)
    case Con{h, rest}:
      kc(Bool, U32.is_gt(left, 0) && U32.is_gt(fuel, 0), u =>
        j_producer_nested_field(book, h, U32.sub(fuel, 1)) &&
          j_producer_nested_fields(book, rest, U32.sub(left, 1), U32.sub(fuel, 1)), u => False{})

@unsafe
def j_producer_nested_field(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  +body = j_strip(t)
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, j_fold_terminal_expr(book, body, fuel), u => True{}, u =>
      kc(Bool, String.eq(tg(body), "Ctr"), u =>
        j_producer_nested_fields(book, ks(body), terms_len(ks(body)), U32.sub(fuel, 1)), u => False{})), u => False{})
