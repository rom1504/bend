# Bounded private first-order regions. Analysis reads original terms; private
# positional/call/match nodes are emitter plans and are never reduced.
type JRegion is Data:
  JRegion{+zero: KTerm, +succ: KTerm, +helpers: List<&2,KDef>}

type JRegionBuild is Data:
  JRegionBuild{+term: KTerm, +helpers: List<&2,KDef>, +fuel: U32, +valid: Bool}

# A selected root carries its emitted code and the optimization already proved.
# Strong plans remove intermediate values or close every residual source call.
# This is selection metadata, not an additional legality analysis.
type JRootPlan is Data:
  JRootPlan{+code: String, +strong: Bool}

@unsafe
def j_root_plan_wrap(+prefix: String, +plan: JRootPlan, +suffix: String) -> JRootPlan:
  match plan:
    case JRootPlan{code, strong}: JRootPlan{prefix ++ code ++ suffix, strong}

@unsafe
def j_region_term(+s: JRegionBuild) -> KTerm:
  match s:
    case JRegionBuild{t, ds, fuel, valid}: t

@unsafe
def j_region_helpers(+s: JRegionBuild) -> List<&2,KDef>:
  match s:
    case JRegionBuild{t, ds, fuel, valid}: ds

@unsafe
def j_region_fuel(+s: JRegionBuild) -> U32:
  match s:
    case JRegionBuild{t, ds, fuel, valid}: fuel

@unsafe
def j_region_valid(+s: JRegionBuild) -> Bool:
  match s:
    case JRegionBuild{t, ds, fuel, valid}: valid

@unsafe
def j_region_result(+s: JRegionBuild, +t: KTerm) -> JRegionBuild:
  JRegionBuild{t, j_region_helpers(s), j_region_fuel(s), j_region_valid(s)}

@unsafe
def j_region_fail(+s: JRegionBuild) -> JRegionBuild:
  JRegionBuild{atom("Absent"), j_region_helpers(s), 0, False{}}

@unsafe
def j_region_tick(+s: JRegionBuild) -> JRegionBuild:
  JRegionBuild{j_region_term(s), j_region_helpers(s), U32.sub(j_region_fuel(s), 1), j_region_valid(s)}

@unsafe
def j_region_scalar(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  String.contains("|U32|Bool|Nat|F32|", "|" ++ nm(head) ++ "|") && j_primitive_type(book, head, nm(head))

# Public record results remain inert flat terminal constructors. The separate
# local-type proof admits internal containers without changing this boundary.
@unsafe
def j_region_result_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_region_scalar(book, ty), u => True{}, u => j_region_record(book, wnf(book, ty)))

@unsafe
def j_region_record(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, nm(ty))
  +kind = wnf(book, dt(owner))
  kc(Bool, String.eq(tg(ty), "ADT") && U32.is_eq(terms_len(ks(ty)), 0) && List.is_empty(&2, String, rm(ty)) &&
    String.eq(dk(owner), "ADT") && Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) && String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2),
    u => j_region_record_ctor(book, ty, dc(owner)), u => False{})

@unsafe
def j_region_record_ctor(+book: List<&2,KDef>, +ty: KTerm, +ctors: List<&2,KDef>) -> Bool:
  match ctors:
    case Con{c, Nil{}}:
      kc(Bool, String.eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_eq(dx(c), 0) && U32.is_le(da(c), 32),
        u => j_region_record_fields(book, dt(c), nm(ty), da(c)), u => False{})
    case other: False{}

@unsafe
def j_region_record_fields(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => String.eq(tg(head), "ADT") && String.eq(nm(head), owner) &&
    U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)), u =>
    kc(Bool, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) && j_region_scalar(book, kid(head, 0)),
      u => j_region_record_fields(book, kid(head, 1), owner, U32.sub(left, 1)), u => False{}))

# Deferred constructor fields contain only inert values or proved scalar
# comparisons. Ordinary build thunks retain their original forcing order.
@unsafe
def j_region_field_values(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +left: U32) -> Bool:
  match xs:
    case Nil{}: U32.is_eq(left, 0)
    case Con{h, rest}:
      +t = j_strip(h)
      kc(Bool, U32.is_gt(left, 0) && (j_region_field_atom(t) || j_region_field_compare(book, t)),
        u => j_region_field_values(book, rest, U32.sub(left, 1)), u => False{})

@unsafe
def j_region_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_region_scalar(book, head), u =>
    kc(Bool, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_region_signature(book, kid(head, 0), 0),
      u => j_region_signature(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

@unsafe
def j_region_capture_eligible(+book: List<&2,KDef>, +d: KDef) -> Bool:
  j_string_literal(book, d) || kc(Bool, String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0) &&
    U32.is_gt(da(d), 0) && U32.is_le(da(d), 32), u =>
    kc(Bool, String.eq(tg(j_strip(dv(d))), "Lam") || String.eq(tg(j_strip(dv(d))), "Mat"),
      u => j_region_local_signature(book, dt(d), da(d)) || j_pure_signature(book, dt(d), da(d)), u => False{}), u => False{})

@unsafe
def j_region_annotate(+t: KTerm, +ty: KTerm) -> KTerm:
  kt("Ann", "", 0, 0, [t, ty])

@unsafe
def j_region_type(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Lit"), u => kt("ADT", nm(t), 0, 0, Nil{}), u =>
    kc(KTerm, String.eq(tg(t), "Ctr") && (String.eq(nm(t), "True") || String.eq(nm(t), "False")),
      u => kt("ADT", "Bool", 0, 0, Nil{}), u => wnf(book, j_type(book, env, t))))

@unsafe
def j_region_variable(+env: List<&2,KTerm>, +t: KTerm) -> KTerm:
  match env:
    case Nil{}: atom("Absent")
    case Con{h, rest}:
      kc(KTerm, U32.is_eq(ix(h), ix(t)), u =>
        kc(KTerm, String.eq(tg(h), "JEnv"), u => kt("JSlot", "", qt(h), 0, Nil{}), u =>
          kc(KTerm, String.eq(tg(h), "JEnvNat"), u => kt("JNatRest", nm(h), qt(h), 0, Nil{}), u => t)),
        u => j_region_variable(rest, t))

@unsafe
def j_region_def_count(+ds: List<&2,KDef>) -> U32:
  match ds:
    case Nil{}: 0
    case Con{h, rest}: U32.inc(j_region_def_count(rest))

# Ordinary roots reuse the same analysis. Require a nested countdown so trivial
# scalar wrappers do not pay a closure guard without measured useful work.
@unsafe
def j_region_root_plan(+book: List<&2,KDef>, +d: KDef) -> JRootPlan:
  kc(JRootPlan, j_region_capture_eligible(book, d) && j_fold_root_signature(book, dt(d), da(d)) && String.eq(tg(j_strip(dv(d))), "Lam"), u =>
    kc(JRootPlan, j_u32_bounded([dv(d)], 8192) && U32.is_eq(j_nat_loop_count(dv(d), 0), da(d)), u =>
      kc(JRootPlan, j_nat_loop_distinct(dv(d), Nil{}) && Bool.not(j_l_deep(dv(d), 0)), u =>
        j_region_root_done(book, d, j_region_prefix(book, Nil{}, dv(d), dt(d), 0, da(d), True{}, "@root-return", [dn(d)], 0,
          JRegionBuild{atom("Absent"), Nil{}, 32768, True{}})), u => JRootPlan{"", False{}}), u => JRootPlan{"", False{}}), u => JRootPlan{"", False{}})

@unsafe
def j_region_has_loop(+book: List<&2,KDef>, +helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}: kc(Bool, Bool.not(db(d)) && (String.eq(tg(dv(d)), "Mat") || String.eq(tg(dv(d)), "JFold") || String.eq(tg(dv(d)), "JProducer")), u => True{}, u => kc(Bool, String.eq(tg(dv(d)), "JResidual") && j_pure_valid(j_component_cached(book, dn(d))), u => True{}, u => j_region_has_loop(book, rest)))

@unsafe
def j_region_root_done(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> JRootPlan:
  kc(JRootPlan, j_region_valid(s) && j_region_has_loop(book, j_region_helpers(s)), u =>
    j_region_root_selected(book, d, s, j_fusion_root_prefix(book, dv(d), dt(d), Nil{}, 0, da(d))), u => JRootPlan{"", False{}})

# The guard domain and selected body share the very same successful full proof.
# The successful plan also supplies rank; no second proof or emitted-text scan.
@unsafe
def j_region_root_selected(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild, +fusion: String) -> JRootPlan:
  j_root_plan_wrap(
    "(()=>{" ++ j_region_declarations(book, j_region_helpers(s)) ++ "const $guards=[" ++ j_quote(dn(d)) ++ "," ++ j_region_names(j_region_helpers(s)) ++ "];return " ++
    "fn(" ++ U32.show(da(d)) ++ ",exactCode(function(a,$entered){/* private scalar root */" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&" ++ kc(String, String.eq(fusion, ""), u => j_fold_root_guard(book, d, j_region_helpers(s)), u => "regionHostGuard(true)&&") ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++ "&&localGuard($guards)){",
    kc(JRootPlan, String.eq(fusion, ""), u => j_flat_root_scope(book, d, s), u =>
      JRootPlan{"const $previousProof=regionProofOpen($guards);try{" ++ fusion ++ "}finally{regionProofClose($previousProof);}", True{}}),
    "}" ++ j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()")

@unsafe
def j_region_plan(+book: List<&2,KDef>, +d: KDef, +zero: KTerm, +succ: KTerm, +total: U32) -> Maybe<&2,JRegion>:
  j_region_plan_zero(book, d, succ, total,
    j_region_prefix(book, Nil{}, zero, j_arm_type(book, wnf(book, dt(d)), "Zero"), 0, U32.sub(total, 1), True{}, "", [dn(d)], 0,
      JRegionBuild{atom("Absent"), Nil{}, 32768, True{}}))

@unsafe
def j_region_plan_zero(+book: List<&2,KDef>, +d: KDef, +succ: KTerm, +total: U32, +s: JRegionBuild) -> Maybe<&2,JRegion>:
  kc(Maybe<&2,JRegion>, j_region_valid(s), u => j_region_plan_done(j_region_term(s),
    j_region_prefix(book, Nil{}, succ, j_arm_type(book, wnf(book, dt(d)), "Succ"), 0, total, True{}, dn(d), [dn(d)], 0, s)), u => None{})

@unsafe
def j_region_plan_done(+zero: KTerm, +s: JRegionBuild) -> Maybe<&2,JRegion>:
  kc(Maybe<&2,JRegion>, j_region_valid(s),
    u => Some{JRegion{zero, j_region_term(s), j_region_helpers(s)}}, u => None{})

# Consume helper prefixes into positional slots, but preserve the owner's
# lambda spine so the existing worker remains responsible for tail transfers.
@unsafe
def j_region_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +keep: Bool, +tail: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0), u =>
    kc(JRegionBuild, U32.is_eq(left, 0), u => j_region_expr(book, env, t, ty, tail, active, depth, 0, s), u =>
      j_region_prefix_on(book, env, j_strip(t), wnf(book, ty), at, left, keep, tail, active, depth, j_region_tick(s))), u => j_region_fail(s))

@unsafe
def j_region_prefix_on(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +keep: Bool, +tail: String, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) && j_region_local_type(book, kid(ty, 0)), u =>
    kc(JRegionBuild, String.eq(tg(t), "Lam") && String.eq(j_l_name(t), ""), u =>
      j_region_prefix_lam(t, keep, j_region_prefix(book,
        Con{kt(kc(String, keep, u => "Env", u => "JEnv"), "", ix(t), at, [wnf(book, kid(ty, 0))]), env},
        kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), U32.inc(at), U32.sub(left, 1), keep, tail, active, depth, s)), u =>
      kc(JRegionBuild, Bool.not(keep) && String.eq(tg(t), "Mat") && j_primitive_type(book, wnf(book, kid(ty, 0)), "Bool"),
        u => j_region_match(book, env, t, ty, at, left, active, depth, s), u =>
        kc(JRegionBuild, Bool.not(keep) && String.eq(tg(t), "Mat"),
          u => kc(JRegionBuild, j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") &&
            (U32.is_eq(left, 1) || has_name(active, "@producer")),
            u => j_region_nat_select(book, env, t, ty, at, left, 0, active, depth, s),
            u => kc(JRegionBuild, U32.is_eq(left, 1), u => j_region_unpack(book, env, t, ty, at, active, depth, s),
              u => j_region_fail(s))), u => j_region_fail(s)))), u => j_region_fail(s))

@unsafe
def j_region_prefix_lam(+t: KTerm, +keep: Bool, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, keep, u => j_region_result(s, k_with_children(t, [j_region_term(s)])), u => s)

@unsafe
def j_region_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +rest = j_strip(kid(t, 1))
  kc(JRegionBuild, U32.is_eq(terms_len(ks(t)), 2) && String.eq(tg(rest), "Mat") && U32.is_eq(terms_len(ks(rest)), 2) &&
    ((String.eq(nm(t), "True") && String.eq(nm(rest), "False")) || (String.eq(nm(t), "False") && String.eq(nm(rest), "True"))) &&
    String.eq(tg(j_strip(kid(rest, 1))), "Efq"), u =>
    j_region_match_first(book, env, t, ty, at, left, active, depth,
      j_region_prefix(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), U32.inc(at), U32.sub(left, 1), False{}, "", active, depth, s)), u => j_region_fail(s))

@unsafe
def j_region_match_first(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_region_match_done(nm(t), at, j_region_term(s), j_region_prefix(book, env, kid(j_strip(kid(t, 1)), 0),
      j_arm_type(book, ty, nm(j_strip(kid(t, 1)))), U32.inc(at), U32.sub(left, 1), False{}, "", active, depth, s)), u => s)

@unsafe
def j_region_match_done(+tag: String, +at: U32, +first: KTerm, +s: JRegionBuild) -> JRegionBuild:
  +cond = j_region_annotate(kt("JSlot", "", at, 0, Nil{}), kt("ADT", "Bool", 0, 0, Nil{}))
  +yes = kc(KTerm, String.eq(tag, "True"), u => first, u => j_region_term(s))
  +no = kc(KTerm, String.eq(tag, "True"), u => j_region_term(s), u => first)
  j_region_result(s, j_region_annotate(kt("JIf", "", 0, 0, [cond, yes, no]), kid(first, 1)))

# Finite Nat decisions inside an already guarded private region. Each branch
# is analyzed normally, retaining live helper dependencies and leaf demand.
# Remainder binders denote the original input minus the matched Succ depth.
@unsafe
def j_region_nat_select(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +offset: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0) && U32.is_le(offset, 64), u =>
    j_region_nat_select_on(book, env, j_strip(t), wnf(book, ty), at, left, offset, active, depth, j_region_tick(s)), u => j_region_fail(s))

@unsafe
def j_region_nat_select_on(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +offset: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, String.eq(tg(ty), "All") && Bool.not(U32.is_eq(qt(ty), 0)) && j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat"), u =>
    kc(JRegionBuild, String.eq(tg(t), "Lam") && String.eq(j_l_name(t), ""), u =>
      j_region_prefix(book, Con{kt("JEnvNat", U32.show(offset), ix(t), at, [wnf(book, kid(ty, 0))]), env},
        kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), U32.inc(at), U32.sub(left, 1), False{}, "", active, depth, s), u =>
      j_region_nat_match(book, env, t, ty, at, left, offset, active, depth, s)), u => j_region_fail(s))

@unsafe
def j_region_nat_match(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +offset: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +rest = j_strip(kid(t, 1))
  kc(JRegionBuild, String.eq(tg(t), "Mat") && String.eq(nm(t), "Zero") && U32.is_eq(terms_len(ks(t)), 2) &&
    String.eq(tg(rest), "Mat") && String.eq(nm(rest), "Succ") && U32.is_eq(terms_len(ks(rest)), 2) &&
    String.eq(tg(j_strip(kid(rest, 1))), "Efq") && U32.is_eq(terms_len(ks(j_strip(kid(rest, 1)))), 0), u =>
      j_region_nat_first(book, env, t, ty, at, left, offset, active, depth,
        j_region_prefix(book, env, kid(t, 0), j_arm_type(book, ty, "Zero"), U32.inc(at), U32.sub(left, 1), False{}, "", active, depth, s)), u => j_region_fail(s))

@unsafe
def j_region_nat_first(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +left: U32, +offset: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_region_nat_done(at, offset, j_region_term(s), j_region_nat_select(book, env, kid(j_strip(kid(t, 1)), 0),
      j_arm_type(book, ty, "Succ"), at, left, U32.inc(offset), active, depth, s)), u => s)

@unsafe
def j_region_nat_done(+at: U32, +offset: U32, +first: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(kt("JNatCase", "", at, offset, [first, j_region_term(s)]), kid(first, 1)))

@unsafe
def j_region_expr(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: String, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0) && U32.is_lt(level, 128), u =>
    kc(JRegionBuild, j_region_local_type(book, ty), u =>
      j_region_expr_on(book, env, t, wnf(book, ty), tail, active, depth, U32.inc(level), j_region_tick(s)), u => j_region_fail(s)), u => j_region_fail(s))

@unsafe
def j_region_expr_on(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tail: String, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, String.eq(tg(t), "Ann"), u =>
    kc(JRegionBuild, j_region_local_type(book, kid(t, 1)) && j_region_same_type(book, kid(t, 1), ty),
      u => j_region_expr(book, env, kid(t, 0), ty, tail, active, depth, level, s), u => j_region_fail(s)), u =>
  kc(JRegionBuild, String.eq(tg(t), "Var"), u =>
    kc(JRegionBuild, j_region_local_type(book, j_env(env, ix(t))) && j_region_same_type(book, j_env(env, ix(t)), ty),
      u => j_region_result(s, j_region_annotate(j_region_variable(env, t), ty)), u => j_region_fail(s)), u =>
  kc(JRegionBuild, String.eq(tg(t), "Lit"), u =>
    kc(JRegionBuild, String.eq(nm(t), nm(ty)) && (String.eq(nm(t), "U32") || String.eq(nm(t), "Nat") || String.eq(nm(t), "F32")),
      u => j_region_result(s, j_region_annotate(t, ty)), u => j_region_fail(s)), u =>
  kc(JRegionBuild, String.eq(tg(t), "Ctr"), u =>
    kc(JRegionBuild, String.eq(nm(ty), "Bool") && U32.is_eq(terms_len(ks(t)), 0) && (String.eq(nm(t), "True") || String.eq(nm(t), "False")),
      u => j_region_result(s, j_region_annotate(t, ty)), u => j_region_constructor(book, env, t, ty, String.eq(tail, "@root-return"), active, depth, level, s)), u =>
  kc(JRegionBuild, String.eq(tg(t), "Let"), u =>
    j_region_let_done(t, ty, j_region_bindings(book, env, j_context(book, env, ks(t)), ks(t), ty, tail, active, depth, level, 0, s)), u =>
  kc(JRegionBuild, String.eq(tg(t), "App"), u =>
    j_region_call(book, env, j_call_spine(t, Nil{}), ty, tail, active, depth, level, s), u => j_region_fail(s)))))))

@unsafe
def j_region_constructor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +root: Bool, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  +c = j_producer_ctor(book, ty, nm(t), active)
  kc(JRegionBuild, j_region_local_type(book, ty) && String.eq(dk(c), "Ctr") && String.eq(dn(c), nm(t)) &&
    U32.is_eq(terms_len(ks(t)), da(c)) &&
    kc(Bool, j_fold_type(book, ty), u => j_producer_fields(book, ks(t), da(c), active), u =>
      kc(Bool, j_region_record(book, ty), u => kc(Bool, root, u => j_fold_terminal_fields(book, ks(t), da(c)),
        u => j_region_field_values(book, ks(t), da(c))), u => True{})), u =>
    j_region_constructor_done(book, t, ty, j_region_args(book, env, ks(t), j_specialize(book, dt(c), ks(ty)), active, depth, level, s)), u => j_region_fail(s))

@unsafe
def j_region_constructor_done(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(kc(KTerm, j_region_local_vector(book, ty),
    u => kt("JVector", nm(t), 0, 0, ks(j_region_term(s))),
    u => k_with_children(t, ks(j_region_term(s)))), ty))

@unsafe
def j_region_let_done(+t: KTerm, +ty: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(k_with_children(t, ks(j_region_term(s))), ty))

# Each parallel RHS sees the old environment. Only the final body receives the
# extended environment; immutable binder identities and evaluation order stay.
@unsafe
def j_region_bindings(+book: List<&2,KDef>, +env: List<&2,KTerm>, +bodyEnv: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +tail: String, +active: List<&2,String>, +depth: U32, +level: U32, +count: U32, +s: JRegionBuild) -> JRegionBuild:
  match xs:
    case Nil{}: j_region_fail(s)
    case Con{body, Nil{}}:
      j_region_list_one(j_region_expr(book, bodyEnv, body, ty, tail, active, depth, level, s))
    case Con{bind, rest}:
      kc(JRegionBuild, j_region_valid(s) && U32.is_lt(count, 128) && String.eq(tg(bind), "Bind") &&
        Bool.not(U32.is_eq(qt(bind), 0)) && U32.is_eq(terms_len(ks(bind)), 1) && j_region_local_type(book, j_region_type(book, env, kid(bind, 0))), u =>
        j_region_binding_first(book, env, bodyEnv, bind, rest, ty, tail, active, depth, level, count,
          j_region_expr(book, env, kid(bind, 0), j_region_type(book, env, kid(bind, 0)), "", active, depth, level, s)), u => j_region_fail(s))

@unsafe
def j_region_binding_first(+book: List<&2,KDef>, +env: List<&2,KTerm>, +bodyEnv: List<&2,KTerm>, +bind: KTerm, +rest: List<&2,KTerm>, +ty: KTerm, +tail: String, +active: List<&2,String>, +depth: U32, +level: U32, +count: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u => j_region_list_prepend(k_with_children(bind, [j_region_term(s)]),
    j_region_bindings(book, env, bodyEnv, rest, ty, tail, active, depth, level, U32.inc(count), s)), u => s)

@unsafe
def j_region_list_one(+s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, kt("JList", "", 0, 0, [j_region_term(s)]))

@unsafe
def j_region_list_prepend(+t: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, kt("JList", "", 0, 0, Con{t, ks(j_region_term(s))}))

@unsafe
def j_region_call(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +tail: String, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  +d = lookup(book, nm(spine))
  kc(JRegionBuild, String.eq(tg(spine), "Call") && U32.is_gt(da(d), 0) && U32.is_le(da(d), 32) && U32.is_eq(terms_len(ks(spine)), da(d)), u =>
    kc(JRegionBuild, j_primitive_call(book, spine) || (Bool.not(String.eq(tail, "")) && String.eq(nm(spine), tail)), u =>
      j_region_call_done(book, spine, ty, False{}, j_region_args(book, env, ks(spine), dt(d), active, depth, level, s)), u =>
      kc(JRegionBuild, j_region_local_native(book, spine),
        u => j_region_native_done(spine, ty, j_region_args(book, env, ks(spine), dt(d), active, depth, level, j_region_native_dependency(d, s))), u =>
        j_region_try_helper(book, env, spine, ty, active, depth, level, s, j_region_helper(book, d, active, depth, s)))), u => j_region_fail(s))

@unsafe
def j_region_call_helper(+book: List<&2,KDef>, +env: List<&2,KTerm>, +spine: KTerm, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_region_call_done(book, spine, ty, True{}, j_region_args(book, env, ks(spine), dt(lookup(book, nm(spine))), active, depth, level, s)), u => s)

@unsafe
def j_region_call_done(+book: List<&2,KDef>, +spine: KTerm, +ty: KTerm, +private: Bool, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(kc(KTerm, private,
    u => kt(kc(String, String.eq(tg(dv(lookup(j_region_helpers(s), nm(spine)))), "JResidual"), u => "JGeneric", u =>
      kc(String, j_region_read_call(book, spine, s), u => "JReadCall", u => "JCall")), nm(spine), 0, 0, ks(j_region_term(s))),
    u => j_region_app(ref(nm(spine)), ks(j_region_term(s)))), ty))

# Only a proved native read immediately consumed by a complete private pair
# match can use the bridge. All other producers keep their existing tuple ABI.
@unsafe
def j_region_read_call(+book: List<&2,KDef>, +spine: KTerm, +s: JRegionBuild) -> Bool:
  +last = j_strip(j_body(ks(j_region_term(s))))
  String.eq(tg(last), "JNative") && String.eq(nm(last), "Array.get") && U32.is_eq(terms_len(ks(last)), 3) &&
  j_region_read_consumer(book, lookup(j_region_helpers(s), nm(spine)))

@unsafe
def j_region_read_consumer(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +body = j_strip(dv(d))
  Bool.not(db(d)) && U32.is_gt(da(d), 0) && String.eq(tg(body), "JUnpack") &&
  U32.is_eq(U32.inc(ix(body)), da(d)) && U32.is_eq(qt(body), 2) && j_region_local_pair(book, kid(body, 1))

@unsafe
def j_region_app(+head: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: j_region_app(kt("App", "", 0, 0, [head, h]), rest)

@unsafe
def j_region_args(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  match args:
    case Nil{}:
      kc(JRegionBuild, j_region_local_type(book, ty), u => j_region_result(s, kt("JList", "", 0, 0, Nil{})), u => j_region_fail(s))
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(JRegionBuild, j_region_valid(s) && String.eq(tg(head), "All"), u =>
        kc(JRegionBuild, U32.is_eq(qt(head), 0), u =>
          kc(JRegionBuild, j_primitive_type(book, wnf(book, h), "U32"),
            u => j_region_arg_first(book, env, rest, j_app_type(head, h), active, depth, level, j_region_result(s, h)), u => j_region_fail(s)), u =>
          kc(JRegionBuild, j_region_local_type(book, kid(head, 0)), u =>
            j_region_arg_first(book, env, rest, j_app_type(head, h), active, depth, level,
              j_region_expr(book, env, h, kid(head, 0), "", active, depth, level, s)), u => j_region_fail(s))), u => j_region_fail(s))

@unsafe
def j_region_arg_first(+book: List<&2,KDef>, +env: List<&2,KTerm>, +rest: List<&2,KTerm>, +ty: KTerm, +active: List<&2,String>, +depth: U32, +level: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u => j_region_list_prepend(j_region_term(s),
    j_region_args(book, env, rest, ty, active, depth, level, s)), u => s)

@unsafe
def j_region_helper(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, String.eq(dk(lookup(j_region_helpers(s), dn(d))), "Def") &&
    Bool.not(String.eq(tg(dv(lookup(j_region_helpers(s), dn(d)))), "JResidual")), u => s, u =>
    kc(JRegionBuild, j_region_valid(s) && U32.is_lt(depth, 16) && U32.is_lt(j_region_def_count(j_region_helpers(s)), 32) &&
      Bool.not(has_name(active, dn(d))), u =>
      kc(JRegionBuild, j_region_capture_eligible(book, d), u =>
        kc(JRegionBuild, j_u32_bounded([dv(d)], 8192), u =>
          j_fold_helper(book, d, active, depth, s, j_fold_plan(book, d)),
          u => j_region_fail(s)), u => j_region_fail(s)), u => j_region_fail(s)))

# Nested loops share the enclosing active chain, completed cache and fuel.
@unsafe
def j_region_nested(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  j_region_nested_zero(book, d, active, depth,
    j_region_prefix(book, Nil{}, kid(j_strip(dv(d)), 0), j_arm_type(book, wnf(book, dt(d)), "Zero"), 0, U32.sub(da(d), 1), False{}, "", active, depth, s))

@unsafe
def j_region_nested_zero(+book: List<&2,KDef>, +d: KDef, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u => j_region_nested_done(d, j_region_term(s),
    j_region_prefix(book, Nil{}, kid(j_strip(kid(j_strip(dv(d)), 1)), 0), j_arm_type(book, wnf(book, dt(d)), "Succ"), 0, da(d), True{}, dn(d), active, depth, s)), u => s)

@unsafe
def j_region_nested_done(+d: KDef, +zero: KTerm, +s: JRegionBuild) -> JRegionBuild:
  +outer = j_strip(dv(d))
  +inner = j_strip(kid(outer, 1))
  j_region_helper_done(d, j_region_result(s, k_with_children(outer, [zero, k_with_children(inner, [j_region_term(s), kid(inner, 1)])])))

@unsafe
def j_region_helper_done(+d: KDef, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s) && U32.is_lt(j_region_def_count(j_region_helpers(s)), 32), u =>
    JRegionBuild{j_region_term(s), Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), j_region_term(s), dc(d), db(d), du(d)}, j_pure_remove(j_region_helpers(s), dn(d))}, j_region_fuel(s), True{}},
    u => j_region_fail(s))

@unsafe
def j_region_names(+helpers: List<&2,KDef>) -> String:
  match helpers:
    case Nil{}: ""
    case Con{d, Nil{}}: j_quote(dn(d))
    case Con{d, rest}: j_quote(dn(d)) ++ "," ++ j_region_names(rest)

@unsafe
def j_region_declarations(+book: List<&2,KDef>, +helpers: List<&2,KDef>) -> String:
  j_region_definitions(book, j_region_inline_defs(book, helpers, helpers))

# Delimited codepoints preserve source identity without a private name table.
@unsafe
def j_region_name(+name: String) -> String:
  "$R" ++ j_region_name_chars(name)

@unsafe
def j_region_name_chars(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}: "_" ++ U32.show(Char.to_u32(c)) ++ j_region_name_chars(rest)

@unsafe
def j_region_definitions(+book: List<&2,KDef>, +helpers: List<&2,KDef>) -> String:
  match helpers:
    case Nil{}: ""
    case Con{d, rest}:
      kc(String, db(d) || String.eq(tg(dv(d)), "JResidual"), u => "", u =>
        "function " ++ j_region_name(dn(d)) ++ "(" ++ j_region_parameters(0, da(d)) ++ "){" ++
        kc(String, String.eq(tg(dv(d)), "JFold"), u => j_fold_emit(book, d), u =>
          kc(String, String.eq(tg(dv(d)), "JProducer"), u => j_producer_emit(book, d), u =>
          kc(String, String.eq(tg(dv(d)), "Mat"), u => j_region_nested_body(book, d),
            u => j_region_return(book, Nil{}, dv(d), kid(dv(d), 1))))) ++ "}") ++
        j_region_read_definition(book, d) ++ j_region_definitions(book, rest)

# The suffix cannot collide with the decimal-only encoded private helper name.
# Perform the read before the consumer arm, including when that scalar is unused.
@unsafe
def j_region_read_definition(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_region_read_consumer(book, d), u =>
    "function " ++ j_region_name(dn(d)) ++ "$get(" ++ j_region_parameters(0, U32.sub(da(d), 1)) ++
    kc(String, U32.is_gt(da(d), 1), u => ",", u => "") ++ "_t,$array,$index){" ++
    "const $p" ++ U32.show(da(d)) ++ "=$array;const $data=arraydata($array);const $p" ++ U32.show(U32.inc(da(d))) ++
    "=$data[Number($index)%$data.length];" ++ j_region_return(book, Nil{}, kid(j_strip(dv(d)), 0), kid(dv(d), 1)) ++ "}", u => "")

# Private callers already demand the result before the next source operation.
# Complete fields in order here; preserve parallel RHS scope and fresh aliases.
@unsafe
def j_region_return(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  kc(String, String.eq(tg(t), "Ann"), u => j_region_return(book, env, kid(t, 0), kid(t, 1)), u =>
  kc(String, String.eq(tg(t), "Let"), u => "{" ++ j_nat_loop_values(book, env, ks(t), 0) ++ "{" ++
    j_nat_loop_names(ks(t), 0) ++ j_region_return(book, j_context(book, env, ks(t)), j_body(ks(t)), ty) ++ "}}", u =>
  kc(String, String.eq(tg(t), "JUnpack"), u => "{const $unpack=" ++ j_flat_unpack(book, kid(t, 1), "$p" ++ U32.show(ix(t))) ++ ";{" ++
    j_flat_bindings(book, kid(t, 1), ix(t), 0, qt(t)) ++ j_region_return(book, env, kid(t, 0), ty) ++ "}}", u =>
  kc(String, String.eq(tg(t), "JInline") || String.eq(tg(t), "JInlineRead"), u => j_region_inline_return(book, env, t, ty), u =>
    "return " ++ j_expr(book, env, t, ty, False{}) ++ ";"))))

# Capture the input outside the field-binding scope. Nested unpacking may reuse
# the temporary, while parallel lets and initial-zero rebinding keep their scope.
@unsafe
def j_region_field_bindings(+slot: U32, +at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u =>
    "const $p" ++ U32.show(U32.add(U32.inc(slot), at)) ++ "=$unpack[" ++ U32.show(at) ++ "];" ++
    j_region_field_bindings(slot, U32.inc(at), total))

@unsafe
def j_region_nested_body(+book: List<&2,KDef>, +d: KDef) -> String:
  "if($p0===0n){return ((" ++ j_region_parameters(0, U32.sub(da(d), 1)) ++ ")=>{" ++ j_region_return(book, Nil{}, kid(dv(d), 0), kid(kid(dv(d), 0), 1)) ++ "})(" ++ j_region_parameters(1, da(d)) ++ ");}" ++
  kc(String, j_region_number_counter(book, d), u => "let $s0=regionCounterNumber($p0)-1;", u => "let $s0=$p0-1n;") ++ j_region_nested_slots(1, da(d)) ++
  kc(String, U32.is_gt(j_region_vector_count(book, d), 0), u => j_region_vector_body(book, d, kid(j_strip(kid(dv(d), 1)), 0), da(d), j_region_vector_count(book, d)), u =>
    j_nat_loop_body(book, d, kid(j_strip(kid(dv(d), 1)), 0), da(d)))

@unsafe
def j_region_nested_slots(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u =>
    "let $s" ++ U32.show(at) ++ "=$p" ++ U32.show(at) ++ ";" ++ j_region_nested_slots(U32.inc(at), total))

@unsafe
def j_region_parameters(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u =>
    "$p" ++ U32.show(at) ++ kc(String, U32.is_eq(U32.inc(at), total), u => "", u => "," ++ j_region_parameters(U32.inc(at), total)))

# Native descriptors enter the same definition-time dependency guard, but have
# no emitted private body. Erased U32 arguments keep their null ABI slots.
@unsafe
def j_region_native_dependency(+d: KDef, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, String.eq(dk(lookup(j_region_helpers(s), dn(d))), "Def"), u => s, u =>
    kc(JRegionBuild, U32.is_lt(j_region_def_count(j_region_helpers(s)), 32),
      u => JRegionBuild{j_region_term(s), Con{d, j_region_helpers(s)}, j_region_fuel(s), j_region_valid(s)}, u => j_region_fail(s)))

@unsafe
def j_region_native_done(+spine: KTerm, +ty: KTerm, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(kt("JNative", nm(spine), 0, 0, ks(j_region_term(s))), ty))

# A private record matcher consumes the complete specialized field telescope.
# The input is the last ordinary argument; its field slots follow all inputs.
@unsafe
def j_region_unpack(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +at: U32, +active: List<&2,String>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +arg = wnf(book, kid(ty, 0))
  +c = j_region_local_ctor(book, arg)
  kc(JRegionBuild, String.eq(dk(c), "Ctr") && String.eq(nm(t), dn(c)) && U32.is_eq(terms_len(ks(t)), 2) &&
    String.eq(tg(j_strip(kid(t, 1))), "Efq") && U32.is_eq(terms_len(ks(j_strip(kid(t, 1)))), 0) &&
    j_nat_loop_lambdas(book, kid(t, 0), j_arm_type(book, ty, nm(t)), da(c)), u =>
    j_region_unpack_done(nm(t), arg, at, da(c), j_region_prefix(book, env, kid(t, 0), j_arm_type(book, ty, nm(t)), U32.inc(at), da(c), False{}, "", active, depth, s)), u => j_region_fail(s))

@unsafe
def j_region_unpack_done(+name: String, +arg: KTerm, +at: U32, +fields: U32, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, j_region_annotate(kt("JUnpack", name, at, fields, [j_region_term(s), arg]), kid(j_region_term(s), 1)))

# Inline bounded private plans only after the closed-region proof. A shared
# visit budget includes copied bodies; failure keeps the original helper intact.
@unsafe
def j_region_inline_defs(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +rest: List<&2,KDef>) -> List<&2,KDef>:
  match rest:
    case Nil{}: Nil{}
    case Con{d, more}:
      +s = kc(JRegionBuild, String.eq(tg(dv(d)), "JResidual"), u => JRegionBuild{dv(d), Nil{}, 2048, True{}}, u =>
        j_region_inline_term(book, helpers, dv(d), 0, JRegionBuild{atom("Absent"), Nil{}, 2048, True{}}))
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), kc(KTerm, j_region_valid(s), u => j_region_term(s), u => dv(d)), dc(d), db(d), du(d)}, j_region_inline_defs(book, helpers, more)}

@unsafe
def j_region_inline_term(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +t: KTerm, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s) && U32.is_gt(j_region_fuel(s), 0), u =>
    j_region_inline_children(book, helpers, t, depth, j_region_inline_terms(book, helpers, ks(t), depth, j_region_tick(s))), u => j_region_fail(s))

@unsafe
def j_region_inline_terms(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +xs: List<&2,KTerm>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  match xs:
    case Nil{}: j_region_result(s, kt("JList", "", 0, 0, Nil{}))
    case Con{h, rest}: j_region_inline_first(book, helpers, rest, depth, j_region_inline_term(book, helpers, h, depth, s))

@unsafe
def j_region_inline_first(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +rest: List<&2,KTerm>, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  kc(JRegionBuild, j_region_valid(s), u =>
    j_region_list_prepend(j_region_term(s), j_region_inline_terms(book, helpers, rest, depth, s)), u => s)

@unsafe
def j_region_inline_children(+book: List<&2,KDef>, +helpers: List<&2,KDef>, +t: KTerm, +depth: U32, +s: JRegionBuild) -> JRegionBuild:
  +d = lookup(helpers, nm(t))
  kc(JRegionBuild, j_region_valid(s) && U32.is_lt(depth, 8) &&
    (String.eq(tg(t), "JCall") || String.eq(tg(t), "JReadCall")) &&
    String.eq(dk(d), "Def") && Bool.not(db(d)) && String.eq(tg(dv(d)), "Ann") &&
    j_region_local_vector(book, kid(dv(d), 1)), u =>
    j_region_inline_done(t, da(d), ks(j_region_term(s)), j_region_inline_term(book, helpers,
      kc(KTerm, String.eq(tg(t), "JReadCall"), u => kid(j_strip(dv(d)), 0), u => dv(d)), U32.inc(depth), s)),
    u => j_region_result(s, k_with_children(t, ks(j_region_term(s)))))

@unsafe
def j_region_inline_done(+t: KTerm, +arity: U32, +args: List<&2,KTerm>, +s: JRegionBuild) -> JRegionBuild:
  j_region_result(s, kt(kc(String, String.eq(tg(t), "JReadCall"), u => "JInlineRead", u => "JInline"), nm(t), arity, 0, Con{j_region_term(s), args}))

@unsafe
def j_region_inline_args(+t: KTerm) -> List<&2,KTerm>:
  j_region_inline_args_on(ks(t))

@unsafe
def j_region_inline_args_on(+xs: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Con{body, args}: args
    case Nil{}: Nil{}

# Capture all arguments before introducing positional names: callers can use
# those same names. Flatten a proved read only at its original producer point.
@unsafe
def j_region_inline_return(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  j_region_inline_output(book, env, t, ty, "", 0)

@unsafe
def j_region_inline_output(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +out: String, +fields: U32) -> String:
  +read = String.eq(tg(t), "JInlineRead")
  +virtual = j_region_inline_virtual(t)
  "{" ++ j_region_inline_values(book, env, j_region_inline_args(t), dt(lookup(book, nm(t))), 0, read, virtual) ++ "{" ++
  j_region_inline_bind(0, kc(U32, read || virtual, u => U32.sub(ix(t), 1), u => ix(t))) ++
  kc(String, read, u => "const $array=$i" ++ U32.show(ix(t)) ++ ";const $index=$i" ++ U32.show(U32.inc(ix(t))) ++
    ";const $p" ++ U32.show(ix(t)) ++ "=$array;const $data=arraydata($array);const $p" ++ U32.show(U32.inc(ix(t))) ++
    "=$data[Number($index)%$data.length];", u => "") ++
  kc(String, virtual, u => j_region_inline_virtual_bind(ix(t), 0, qt(j_strip(kid(t, 0)))), u => "") ++
  j_region_emit_output(book, Nil{}, kc(KTerm, virtual, u => kid(j_strip(kid(t, 0)), 0), u => kid(t, 0)), ty, out, fields) ++ "}}"

@unsafe
def j_region_inline_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +at: U32, +read: Bool, +virtual: Bool) -> String:
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      +head = wnf(book, ty)
      kc(String, virtual && List.is_empty(&2, KTerm, rest), u => "", u =>
      kc(String, read && List.is_empty(&2, KTerm, rest), u =>
        j_region_inline_values(book, env, ks(j_strip(h)), dt(lookup(book, "Array.get")), at, False{}, False{}), u =>
        "const $i" ++ U32.show(at) ++ "=" ++ kc(String, U32.is_eq(qt(head), 0), u => "null", u => j_expr(book, env, h, kid(head, 0), False{})) ++ ";" ++
        j_region_inline_values(book, env, rest, j_app_type(head, h), U32.inc(at), read, virtual)))

@unsafe
def j_region_inline_bind(+at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u =>
    "const $p" ++ U32.show(at) ++ "=$i" ++ U32.show(at) ++ ";" ++ j_region_inline_bind(U32.inc(at), total))

# Scalarize only the final private vector argument of an admitted countdown.
# Other uses reify a value; complete inlined matches read virtual fields directly.
@unsafe
def j_region_vector_count(+book: List<&2,KDef>, +d: KDef) -> U32:
  +ty = j_region_last_input(book, dt(d), da(d))
  kc(U32, j_region_local_vector(book, ty), u => j_region_local_field_count(book, ty), u => 0)

@unsafe
def j_region_last_input(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> KTerm:
  +head = wnf(book, ty)
  kc(KTerm, U32.is_eq(left, 1), u => kid(head, 0), u =>
    kc(KTerm, U32.is_gt(left, 1), u => j_region_last_input(book, kid(head, 1), U32.sub(left, 1)), u => atom("Absent")))

@unsafe
def j_region_vector_names(+prefix: String, +at: U32, +total: U32) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => prefix ++ U32.show(at) ++ "," ++ j_region_vector_names(prefix, U32.inc(at), total))

@unsafe
def j_region_vector_copy(+to: String, +from: String, +at: U32, +total: U32, +index: Bool) -> String:
  kc(String, U32.is_eq(at, total), u => "", u => to ++ U32.show(at) ++ "=" ++ from ++
    kc(String, index, u => "[" ++ U32.show(at) ++ "]", u => U32.show(at)) ++ ";" ++
    j_region_vector_copy(to, from, U32.inc(at), total, index))

@unsafe
def j_region_vector_body(+book: List<&2,KDef>, +d: KDef, +succ: KTerm, +total: U32, +fields: U32) -> String:
  j_region_vector_copy("let $w", "$p" ++ U32.show(U32.sub(total, 1)), 0, fields, True{}) ++
  "for(;;){" ++ j_region_vector_enter(book, Nil{}, succ, j_arm_type(book, wnf(book, dt(d)), "Succ"), d, 0, total, fields) ++ "}"

@unsafe
def j_region_vector_enter(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +at: U32, +total: U32, +fields: U32) -> String:
  +body = j_strip(t)
  +head = wnf(book, ty)
  kc(String, String.eq(tg(body), "Lam"), u =>
    kc(String, U32.is_eq(U32.inc(at), total), u => "", u => "const " ++ j_local(ix(body)) ++ "=$s" ++ U32.show(at) ++ ";") ++
    j_region_vector_enter(book, Con{kt("Env", "", ix(body), 0, [kid(head, 0)]), env},
      kc(KTerm, U32.is_eq(U32.inc(at), total), u => subst(kid(body, 0), ix(body), kt("JVirtual", "", fields, 0, Nil{})), u => kid(body, 0)),
      subst(kid(head, 1), ix(head), var(nm(body), ix(body))), d, U32.inc(at), total, fields),
    u => j_region_vector_emit(book, env, body, head, d, total, fields))

@unsafe
def j_region_vector_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +total: U32, +fields: U32) -> String:
  +last = U32.sub(total, 1)
  +out = "$n" ++ U32.show(last) ++ "_"
  kc(String, String.eq(tg(t), "Ann"), u => j_region_vector_emit(book, env, kid(t, 0), kid(t, 1), d, total, fields), u =>
  kc(String, String.eq(tg(t), "Let"), u => "{" ++ j_nat_loop_values(book, env, ks(t), 0) ++ "{" ++ j_nat_loop_names(ks(t), 0) ++
    j_region_vector_emit(book, j_context(book, env, ks(t)), j_body(ks(t)), ty, d, total, fields) ++ "}}", u =>
    j_region_vector_next(book, env, ks(j_call_spine(t, Nil{})), dt(d), 0, last, fields) ++
    "if($n0===" ++ kc(String, j_region_number_counter(book, d), u => "0", u => "0n") ++ "){const $n" ++ U32.show(last) ++ "=[" ++ j_region_vector_names(out, 0, fields) ++ "];" ++ j_nat_loop_zero(book, d, total) ++ "}" ++
    "$s0=$n0-" ++ kc(String, j_region_number_counter(book, d), u => "1", u => "1n") ++ ";" ++ j_nat_loop_assign(last, 1) ++ j_region_vector_copy("$w", out, 0, fields, False{}) ++ "continue;"))

@unsafe
def j_region_vector_next(+book: List<&2,KDef>, +env: List<&2,KTerm>, +args: List<&2,KTerm>, +ty: KTerm, +at: U32, +last: U32, +fields: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{h, rest}:
      +head = wnf(book, ty)
      +out = "$n" ++ U32.show(at) ++ "_"
      kc(String, U32.is_eq(at, last), u => "let " ++ j_region_vector_names(out, 0, U32.sub(fields, 1)) ++ out ++ U32.show(U32.sub(fields, 1)) ++ ";" ++
        j_region_vector_return(book, env, h, kid(head, 0), out, fields), u =>
        "const $n" ++ U32.show(at) ++ "=" ++ j_expr(book, env, h, kid(head, 0), False{}) ++ ";" ++
        j_region_vector_next(book, env, rest, j_app_type(head, h), U32.inc(at), last, fields))

# Result destinations are fresh next-state slots. All fields are completed in
# source order before any current loop slot changes; aliases remain snapshots.
@unsafe
def j_region_vector_return(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +out: String, +fields: U32) -> String:
  kc(String, String.eq(tg(t), "Ann"), u => j_region_vector_return(book, env, kid(t, 0), kid(t, 1), out, fields), u =>
  kc(String, String.eq(tg(t), "Let"), u => "{" ++ j_nat_loop_values(book, env, ks(t), 0) ++ "{" ++ j_nat_loop_names(ks(t), 0) ++
    j_region_vector_return(book, j_context(book, env, ks(t)), j_body(ks(t)), ty, out, fields) ++ "}}", u =>
  kc(String, String.eq(tg(t), "JInline") || String.eq(tg(t), "JInlineRead"), u => j_region_inline_output(book, env, t, ty, out, fields), u =>
  kc(String, String.eq(tg(t), "JUnpack"), u => "{const $unpack=$p" ++ U32.show(ix(t)) ++
    kc(String, j_region_local_vector(book, kid(t, 1)), u => "", u => ".a") ++ ";{" ++ j_region_field_bindings(ix(t), 0, qt(t)) ++
    j_region_vector_return(book, env, kid(t, 0), ty, out, fields) ++ "}}", u =>
  kc(String, String.eq(tg(t), "JIf"), u => "if(" ++ j_expr(book, env, kid(t, 0), kt("ADT", "Bool", 0, 0, Nil{}), False{}) ++ "){" ++
    j_region_vector_return(book, env, kid(t, 1), ty, out, fields) ++ "}else{" ++ j_region_vector_return(book, env, kid(t, 2), ty, out, fields) ++ "}", u =>
  kc(String, String.eq(tg(t), "JVector"), u => j_region_vector_values(book, env, ks(t), j_region_local_fields(book, ty), out, 0), u =>
  kc(String, String.eq(tg(t), "JVirtual"), u => j_region_vector_copy(out, "$w", 0, fields, False{}), u =>
    "{const $result=" ++ j_expr(book, env, t, ty, False{}) ++ ";" ++ j_region_vector_copy(out, "$result", 0, fields, True{}) ++ "}")))))))

@unsafe
def j_region_vector_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +xs: List<&2,KTerm>, +ty: KTerm, +out: String, +at: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, rest}:
      +head = wnf(book, ty)
      out ++ U32.show(at) ++ "=" ++ j_expr(book, env, h, kid(head, 0), False{}) ++ ";" ++
      j_region_vector_values(book, env, rest, j_app_type(head, h), out, U32.inc(at))

@unsafe
def j_region_inline_virtual(+t: KTerm) -> Bool:
  +body = j_strip(kid(t, 0))
  +last = j_strip(j_body(j_region_inline_args(t)))
  String.eq(tg(t), "JInline") && String.eq(tg(body), "JUnpack") &&
  U32.is_eq(U32.inc(ix(body)), ix(t)) && String.eq(tg(last), "JVirtual") && U32.is_eq(qt(body), ix(last))

@unsafe
def j_region_inline_virtual_bind(+at: U32, +field: U32, +total: U32) -> String:
  kc(String, U32.is_eq(field, total), u => "", u =>
    "const $p" ++ U32.show(U32.add(at, field)) ++ "=$w" ++ U32.show(field) ++ ";" ++ j_region_inline_virtual_bind(at, U32.inc(field), total))

@unsafe
def j_region_emit_output(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +out: String, +fields: U32) -> String:
  kc(String, U32.is_gt(fields, 0), u => j_region_vector_return(book, env, t, ty, out, fields), u => j_region_return(book, env, t, ty))

# Ordinary integer regions retain their existing guard cost. Floating operations
# require the host-intrinsic/protocol guard before Math-based input validation.
@unsafe
def j_region_float_terms(+todo: List<&2,KTerm>) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, String.eq(nm(t), "F32") || String.starts_with(nm(t), "F32.") || String.eq(nm(t), "U32.to_f32"), u => True{},
        u => j_region_float_terms(List.append(&2, KTerm, ks(t), rest)))

@unsafe
def j_region_float_helpers(+book: List<&2,KDef>, +helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}: kc(Bool, j_region_float_signature(book, dt(d), da(d)) || j_region_float_terms([dt(d), dv(d)]), u => True{}, u => j_region_float_helpers(book, rest))

@unsafe
def j_region_host_guard(+book: List<&2,KDef>, +d: KDef, +helpers: List<&2,KDef>) -> String:
  kc(String, j_fold_has(helpers) || j_region_has_residual(helpers) || j_region_float_signature(book, dt(d), da(d)) || j_region_float_terms([dt(d), dv(d)]) || j_region_float_helpers(book, helpers), u => "regionHostGuard()&&", u => "")

# Alias normalization is essential even for an unused floating input: its
# canonical-input test calls Math.fround before any body expression executes.
@unsafe
def j_region_float_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => String.eq(nm(head), "F32"), u =>
    kc(Bool, String.eq(tg(head), "All"), u => String.eq(nm(wnf(book, kid(head, 0))), "F32") ||
      j_region_float_signature(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Primitive comparisons on inert scalar operands preserve deferred field demand.
# No helper, constructor, conversion or Math method is evaluated by this rule.
@unsafe
def j_region_field_atom(+t: KTerm) -> Bool:
  +body = j_strip(t)
  String.eq(tg(body), "Var") || String.eq(tg(body), "Lit") ||
    (String.eq(tg(body), "Ctr") && U32.is_eq(terms_len(ks(body)), 0) && (String.eq(nm(body), "True") || String.eq(nm(body), "False")))

@unsafe
def j_region_field_compare(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  +spine = j_call_spine(t, Nil{})
  (String.starts_with(nm(spine), "U32.is_") || String.starts_with(nm(spine), "F32.is_")) &&
    j_primitive_call(book, spine) && j_region_field_operands(ks(spine))

@unsafe
def j_region_field_operands(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_region_field_atom(h) && j_region_field_operands(rest)

# A private Nat below 2^48 fits exactly in a Number. Change only a loop
# predecessor occurring once, as the first self-tail argument: it cannot escape
# through source arithmetic, stores, results, type terms or copied helper plans.
@unsafe
def j_region_number_counter(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +succ = j_strip(kid(j_strip(kid(dv(d), 1)), 0))
  kc(Bool, String.eq(tg(succ), "Lam"), u =>
    kc(Bool, j_nat_loop_tail(j_nat_loop_unwrap(succ), dn(d), ix(succ), da(d)), u =>
      U32.is_eq(j_region_counter_uses([kid(succ, 0)], ix(succ), 0), 1), u => False{}), u => False{})

# Stop after two uses. Inspect every child, including closures and annotations;
# globally fresh frontend IDs make copied helper binders unambiguous here.
@unsafe
def j_region_counter_uses(+todo: List<&2,KTerm>, +id: U32, +count: U32) -> U32:
  match todo:
    case Nil{}: count
    case Con{t, rest}:
      kc(U32, U32.is_ge(count, 2), u => count, u =>
        j_region_counter_uses(List.append(&2, KTerm, ks(t), rest), id,
          U32.add(count, kc(U32, String.eq(tg(t), "Var") && U32.is_eq(ix(t), id), u => 1, u => 0))))

# A scalar-only use of a closed total producer/filter/map/fold pipeline may erase
# its private lists. This is selected only after the existing whole-root proof.
@unsafe
def j_fusion_var(+t: KTerm, +id: U32) -> Bool:
  +h = j_strip(t)
  String.eq(tg(h), "Var") && U32.is_eq(ix(h), id)

@unsafe
def j_fusion_has_var(+xs: List<&2,KTerm>, +id: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, rest}: U32.is_eq(ix(h), id) || j_fusion_has_var(rest, id)

# No arbitrary JPure calls: these native U32 operations are total under the
# unchanged numeric host guard. Existing emission owns per-operation wrapping
# and mod's zero-divisor behavior; this pass does not reassociate arithmetic.
@unsafe
def j_fusion_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, String.eq(tg(h), "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
    kc(Bool, String.eq(tg(h), "Lit"), u => String.eq(nm(h), "U32"), u =>
      String.eq(tg(s), "Call") && j_primitive_call(book, s) && U32.is_eq(terms_len(ks(s)), 2) &&
      (String.eq(nm(s), "U32.add") || String.eq(nm(s), "U32.sub") || String.eq(nm(s), "U32.mul") ||
       String.eq(nm(s), "U32.mod") || String.eq(nm(s), "U32.is_eq") ||
       String.eq(nm(s), "U32.is_gt") || String.eq(nm(s), "U32.is_lt")) &&
      j_fusion_scalars(book, ks(s), vars)))

@unsafe
def j_fusion_scalars(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +vars: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_fusion_scalar(book, h, vars) && j_fusion_scalars(book, rest, vars)

@unsafe
def j_fusion_after(+t: KTerm, +left: U32) -> KTerm:
  +h = j_strip(t)
  kc(KTerm, U32.is_eq(left, 0), u => h, u =>
    kc(KTerm, String.eq(tg(h), "Lam") && U32.is_eq(terms_len(ks(h)), 1),
      u => j_fusion_after(kid(h, 0), U32.sub(left, 1)), u => atom("Absent")))

@unsafe
def j_fusion_binder(+t: KTerm, +at: U32) -> KTerm:
  +h = j_strip(t)
  kc(KTerm, String.eq(tg(h), "Lam"), u =>
    kc(KTerm, U32.is_eq(at, 0), u => h, u => j_fusion_binder(kid(h, 0), U32.sub(at, 1))), u => atom("Absent"))

@unsafe
def j_fusion_unlet(+t: KTerm, +left: U32) -> KTerm:
  +h = j_strip(t)
  +b = kid(h, 0)
  kc(KTerm, U32.is_gt(left, 0) && String.eq(tg(h), "Let") && U32.is_eq(terms_len(ks(h)), 2) &&
    String.eq(tg(b), "Bind") && Bool.not(U32.is_eq(qt(b), 0)) && U32.is_eq(terms_len(ks(b)), 1) &&
    String.eq(tg(j_strip(kid(b, 0))), "Var"),
    u => j_fusion_unlet(subst(kid(h, 1), ix(b), j_strip(kid(b, 0))), U32.sub(left, 1)), u => h)

@unsafe
def j_fusion_cases(+t: KTerm, +empty: String, +link: String) -> Bool:
  +h = j_strip(t)
  +r = j_strip(kid(h, 1))
  String.eq(tg(h), "Mat") && String.eq(nm(h), empty) && U32.is_eq(terms_len(ks(h)), 2) &&
    String.eq(tg(r), "Mat") && String.eq(nm(r), link) && U32.is_eq(terms_len(ks(r)), 2) &&
    String.eq(tg(j_strip(kid(r, 1))), "Efq")

@unsafe
def j_fusion_empty(+d: KDef) -> KTerm:
  kid(j_strip(dv(d)), 0)

@unsafe
def j_fusion_link(+d: KDef) -> KTerm:
  kid(j_strip(kid(j_strip(dv(d)), 1)), 0)

@unsafe
def j_fusion_def(+d: KDef, +arity: U32) -> Bool:
  String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0) && U32.is_eq(da(d), arity)

@unsafe
def j_fusion_ctor(+t: KTerm, +name: String, +fields: U32) -> Bool:
  +h = j_strip(t)
  String.eq(tg(h), "Ctr") && String.eq(nm(h), name) && U32.is_eq(terms_len(ks(h)), fields)

@unsafe
def j_fusion_call(+s: KTerm, +name: String, +arity: U32) -> Bool:
  String.eq(tg(s), "Call") && String.eq(nm(s), name) && U32.is_eq(terms_len(ks(s)), arity)

@unsafe
def j_fusion_owner(+book: List<&2,KDef>, +ty: KTerm, +empty: String, +link: String) -> Bool:
  +h = wnf(book, ty)
  +d = lookup(book, nm(h))
  +c = lookup(dc(d), link)
  +z = lookup(dc(d), empty)
  +tel = wnf(book, j_specialize(book, dt(c), ks(h)))
  +tail = wnf(book, kid(tel, 1))
  String.eq(tg(h), "ADT") && (j_fold_type(book, h) || j_list_ground_type(book, h)) &&
    U32.is_eq(j_region_def_count(dc(d)), 2) && Bool.not(String.eq(empty, link)) &&
    String.eq(dk(z), "Ctr") && U32.is_eq(da(z), 0) &&
    String.eq(dk(c), "Ctr") && U32.is_eq(da(c), 2) &&
    String.eq(tg(tel), "All") && Bool.not(U32.is_eq(qt(tel), 0)) && j_primitive_type(book, wnf(book, kid(tel, 0)), "U32") &&
    String.eq(tg(tail), "All") && Bool.not(U32.is_eq(qt(tail), 0)) && j_region_same_type(book, kid(tail, 0), h) &&
    j_region_same_type(book, kid(tail, 1), h)

@unsafe
def j_fusion_producer(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +z = j_fusion_empty(d)
  +s = j_fusion_link(d)
  +body = j_fusion_after(s, 2)
  +call = j_call_spine(kid(body, 1), Nil{})
  j_fusion_def(d, 2) && j_fusion_cases(dv(d), "Zero", "Succ") &&
    String.eq(tg(j_fusion_binder(z, 0)), "Lam") && j_fusion_ctor(j_fusion_after(z, 1), empty, 0) &&
    String.eq(tg(j_fusion_binder(s, 1)), "Lam") && j_fusion_ctor(body, link, 2) &&
    j_fusion_call(call, dn(d), 2) && j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 0))) &&
    j_fusion_scalar(book, kid(body, 0), [j_fusion_binder(s, 1)]) &&
    j_fusion_scalar(book, kid(call, 1), [j_fusion_binder(s, 1)])

@unsafe
def j_fusion_map(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +s = j_fusion_link(d)
  +body = j_fusion_after(s, 2)
  +call = j_call_spine(kid(body, 1), Nil{})
  j_fusion_def(d, 1) && j_fusion_cases(dv(d), empty, link) && j_fusion_ctor(j_fusion_empty(d), empty, 0) &&
    String.eq(tg(j_fusion_binder(s, 1)), "Lam") && j_fusion_ctor(body, link, 2) &&
    j_fusion_call(call, dn(d), 1) && j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 1))) &&
    j_fusion_scalar(book, kid(body, 0), [j_fusion_binder(s, 0)])

@unsafe
def j_fusion_fold(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +z = j_fusion_empty(d)
  +s = j_fusion_link(d)
  +call = j_call_spine(j_fusion_after(s, 3), Nil{})
  j_fusion_def(d, 2) && j_fusion_cases(dv(d), empty, link) &&
    String.eq(tg(j_fusion_binder(z, 0)), "Lam") && j_fusion_var(j_fusion_after(z, 1), ix(j_fusion_binder(z, 0))) &&
    String.eq(tg(j_fusion_binder(s, 2)), "Lam") && j_fusion_call(call, dn(d), 2) &&
    j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 1))) &&
    j_fusion_scalar(book, kid(call, 1), [j_fusion_binder(s, 0), j_fusion_binder(s, 2)])

# The selector consumes head, child and Bool; True reconstructs exactly one
# original node and False returns exactly the child. Arbitrary callbacks refuse.
@unsafe
def j_fusion_choose(+d: KDef, +link: String) -> Bool:
  +t = j_fusion_after(dv(d), 2)
  +yes = j_strip(kid(t, 0))
  +no = j_strip(kid(t, 1))
  j_fusion_def(d, 3) && String.eq(tg(j_fusion_binder(dv(d), 1)), "Lam") &&
    j_fusion_cases(t, "True", "False") && j_fusion_ctor(yes, link, 2) &&
    j_fusion_var(kid(yes, 0), ix(j_fusion_binder(dv(d), 0))) &&
    j_fusion_var(kid(yes, 1), ix(j_fusion_binder(dv(d), 1))) &&
    j_fusion_var(kid(no, 0), ix(j_fusion_binder(dv(d), 1)))

@unsafe
def j_fusion_filter(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +s = j_fusion_link(d)
  +call = j_call_spine(j_fusion_unlet(j_fusion_after(s, 2), 8), Nil{})
  +child = j_call_spine(kid(call, 1), Nil{})
  j_fusion_def(d, 1) && j_fusion_cases(dv(d), empty, link) && j_fusion_ctor(j_fusion_empty(d), empty, 0) &&
    String.eq(tg(j_fusion_binder(s, 1)), "Lam") && String.eq(tg(call), "Call") && U32.is_eq(terms_len(ks(call)), 3) &&
    j_fusion_choose(lookup(book, nm(call)), link) && j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 0))) &&
    j_fusion_call(child, dn(d), 1) && j_fusion_var(kid(child, 0), ix(j_fusion_binder(s, 1))) &&
    j_fusion_scalar(book, kid(call, 2), [j_fusion_binder(s, 0)])

@unsafe
def j_fusion_env(+vars: List<&2,KTerm>) -> List<&2,KTerm>:
  match vars:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{kt("Env", "", ix(h), 0, [ref("U32")]), j_fusion_env(rest)}

@unsafe
def j_fusion_expr(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>) -> String:
  j_expr(book, j_fusion_env(vars), t, ref("U32"), False{})

@unsafe
def j_fusion_emit(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +p: KDef, +f: KDef, +m: KDef, +r: KDef, +n: KTerm, +seed: KTerm, +initial: KTerm) -> String:
  +ps = j_fusion_link(p)
  +pb = j_fusion_after(ps, 2)
  +pc = j_call_spine(kid(pb, 1), Nil{})
  +fs = j_fusion_link(f)
  +fc = j_call_spine(j_fusion_unlet(j_fusion_after(fs, 2), 8), Nil{})
  +ms = j_fusion_link(m)
  +rs = j_fusion_link(r)
  +rc = j_call_spine(j_fusion_after(rs, 3), Nil{})
  "/* private total scalar fusion */let $f_n=" ++ j_fusion_expr(book, n, vars) ++
    ",$f_seed=" ++ j_fusion_expr(book, seed, vars) ++ ",$f_acc=" ++ j_fusion_expr(book, initial, vars) ++ ";" ++
    "while($f_n!==0){const " ++ j_local(ix(j_fusion_binder(ps, 1))) ++ "=$f_seed;const $f_head=" ++
    j_fusion_expr(book, kid(pb, 0), [j_fusion_binder(ps, 1)]) ++ ";--$f_n;$f_seed=" ++
    j_fusion_expr(book, kid(pc, 1), [j_fusion_binder(ps, 1)]) ++ ";{" ++
    "const " ++ j_local(ix(j_fusion_binder(fs, 0))) ++ "=$f_head;if(" ++
    j_fusion_expr(book, kid(fc, 2), [j_fusion_binder(fs, 0)]) ++ "){{const " ++
    j_local(ix(j_fusion_binder(ms, 0))) ++ "=$f_head;const $f_mapped=" ++
    j_fusion_expr(book, kid(j_fusion_after(ms, 2), 0), [j_fusion_binder(ms, 0)]) ++ ";{" ++
    "const " ++ j_local(ix(j_fusion_binder(rs, 0))) ++ "=$f_mapped;const " ++
    j_local(ix(j_fusion_binder(rs, 2))) ++ "=$f_acc;$f_acc=" ++
    j_fusion_expr(book, kid(rc, 1), [j_fusion_binder(rs, 0), j_fusion_binder(rs, 2)]) ++ ";}}}}}return $f_acc;"

@unsafe
def j_fusion_pipeline(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +t: KTerm) -> String:
  +r = j_call_spine(t, Nil{})
  +m = j_call_spine(kid(r, 0), Nil{})
  +f = j_call_spine(kid(m, 0), Nil{})
  +p = j_call_spine(kid(f, 0), Nil{})
  kc(String, String.eq(tg(r), "Call") && U32.is_eq(terms_len(ks(r)), 2) &&
    String.eq(tg(m), "Call") && U32.is_eq(terms_len(ks(m)), 1) &&
    String.eq(tg(f), "Call") && U32.is_eq(terms_len(ks(f)), 1) &&
    String.eq(tg(p), "Call") && U32.is_eq(terms_len(ks(p)), 2),
    u => j_fusion_pipeline_defs(book, vars, r, m, f, p, lookup(book, nm(r)), lookup(book, nm(m)), lookup(book, nm(f)), lookup(book, nm(p))), u => "")

@unsafe
def j_fusion_pipeline_defs(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +rc: KTerm, +mc: KTerm, +fc: KTerm, +pc: KTerm, +r: KDef, +m: KDef, +f: KDef, +p: KDef) -> String:
  +owner = j_fold_root_result(book, dt(p), da(p))
  +empty = nm(j_fusion_after(j_fusion_empty(p), 1))
  +link = nm(j_fusion_after(j_fusion_link(p), 2))
  +n = j_call_spine(kid(pc, 0), Nil{})
  kc(String, j_fusion_owner(book, owner, empty, link) &&
    j_region_same_type(book, kid(wnf(book, dt(r)), 0), owner) &&
    j_region_same_type(book, kid(wnf(book, dt(m)), 0), owner) && j_region_same_type(book, j_fold_root_result(book, dt(m), da(m)), owner) &&
    j_region_same_type(book, kid(wnf(book, dt(f)), 0), owner) && j_region_same_type(book, j_fold_root_result(book, dt(f), da(f)), owner) &&
    j_primitive_type(book, j_fold_root_result(book, dt(r), da(r)), "U32") &&
    j_fusion_producer(book, p, empty, link) && j_fusion_filter(book, f, empty, link) &&
    j_fusion_map(book, m, empty, link) && j_fusion_fold(book, r, empty, link) &&
    j_fusion_call(n, "U32.to_nat", 1) && j_primitive_call(book, n) &&
    j_fusion_scalar(book, kid(n, 0), vars) && j_fusion_scalar(book, kid(pc, 1), vars) && j_fusion_scalar(book, kid(rc, 1), vars),
    u => j_fusion_emit(book, vars, p, f, m, r, kid(n, 0), kid(pc, 1), kid(rc, 1)), u => "")

# Only a nested scalar use is admitted. Let-bound/shared/returned intermediates
# and non-U32 root inputs refuse before any new code is emitted.
@unsafe
def j_fusion_root_prefix(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +vars: List<&2,KTerm>, +at: U32, +left: U32) -> String:
  +h = j_strip(t)
  +head = wnf(book, ty)
  kc(String, U32.is_eq(left, 0), u =>
    kc(String, j_primitive_type(book, head, "U32"), u => j_fusion_pipeline(book, vars, h), u => ""), u =>
    kc(String, String.eq(tg(h), "Lam") && String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_primitive_type(book, wnf(book, kid(head, 0)), "U32"), u =>
      j_fusion_root_bind(h, at, j_fusion_root_prefix(book, kid(h, 0), subst(kid(head, 1), ix(head), var(nm(h), ix(h))),
        Con{h, vars}, U32.inc(at), U32.sub(left, 1))), u => ""))

@unsafe
def j_fusion_root_bind(+t: KTerm, +at: U32, +body: String) -> String:
  kc(String, String.eq(body, ""), u => "", u => "const " ++ j_local(ix(t)) ++ "=$s" ++ U32.show(at) ++ ";" ++ body)

# Candidate source fragment for region.bend. No source-name specialization.
# Not checked: root owns acquisition and qualified integration.
@unsafe
def j_callback_fun_type(+book: List<&2,KDef>, +ty: KTerm, +arg: String) -> Bool:
  +h = wnf(book, ty)
  String.eq(tg(h), "All") && U32.is_eq(qt(h), 1) &&
    j_primitive_type(book, wnf(book, kid(h, 0)), arg) &&
    j_primitive_type(book, wnf(book, kid(h, 1)), "U32")

@unsafe
def j_callback_factory_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  String.eq(tg(h), "All") && Bool.not(U32.is_eq(qt(h), 0)) &&
    j_primitive_type(book, wnf(book, kid(h, 0)), "Nat") &&
    j_callback_fun_type(book, kid(h, 1), "U32")

@unsafe
def j_callback_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>, +pred: U32, +fuel: U32) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(h), "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
      kc(Bool, String.eq(tg(h), "Lit"), u => String.eq(nm(h), "U32"), u =>
        kc(Bool, j_fusion_call(s, "U32.from_nat", 1) && j_primitive_call(book, s),
          u => j_fusion_var(kid(s, 0), pred), u =>
          kc(Bool, String.eq(tg(s), "Call") && U32.is_eq(terms_len(ks(s)), 2) &&
            (String.eq(nm(s), "U32.add") || String.eq(nm(s), "U32.sub") || String.eq(nm(s), "U32.mul") || String.eq(nm(s), "U32.mod")) &&
            j_primitive_call(book, s), u =>
            kc(Bool, j_callback_scalar(book, kid(s, 0), vars, pred, U32.sub(fuel, 1)),
              u => j_callback_scalar(book, kid(s, 1), vars, pred, U32.sub(fuel, 1)), u => False{}), u => False{})))), u => False{})

# The exact generic composition domain is Type&1, with three erased q0
# binders. Type&2 native U32 is specialized only after that formal proof.
@unsafe
def j_callback_type_domain(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  String.eq(tg(h), "Typ") && String.eq(nm(h), "") && U32.is_eq(ix(h), 0) && U32.is_eq(qt(h), 0) &&
    List.is_empty(&2, String, rm(h)) && U32.is_eq(terms_len(ks(h)), 1) &&
    String.eq(tg(kid(h, 0)), "Qua") && String.eq(nm(kid(h, 0)), "") && U32.is_eq(ix(kid(h, 0)), 0) &&
    U32.is_eq(qt(kid(h, 0)), 1) && List.is_empty(&2, String, rm(kid(h, 0))) && U32.is_eq(terms_len(ks(kid(h, 0))), 0)

@unsafe
def j_callback_erased_prefix(+book: List<&2,KDef>, +ty: KTerm, +body: KTerm, +left: U32) -> Bool:
  +h = wnf(book, ty)
  +t = j_strip(body)
  kc(Bool, U32.is_eq(left, 0), u => True{}, u =>
    String.eq(tg(h), "All") && U32.is_eq(qt(h), 0) && j_callback_type_domain(book, kid(h, 0)) &&
    String.eq(tg(t), "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) &&
    j_callback_runtime_absent(kid(t, 0), ix(t), 2048) &&
    j_callback_erased_prefix(book, kid(h, 1), kid(t, 0), U32.sub(left, 1)))

@unsafe
def j_callback_live_compose_type(+book: List<&2,KDef>, +ty: KTerm, +body: KTerm, +left: U32) -> Bool:
  +h = wnf(book, ty)
  +t = j_strip(body)
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, h, "U32"), u =>
    String.eq(tg(h), "All") && U32.is_eq(qt(h), 1) && String.eq(tg(t), "Lam") &&
    U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) &&
    kc(Bool, U32.is_eq(left, 1), u => j_primitive_type(book, wnf(book, kid(h, 0)), "U32"),
      u => j_callback_fun_type(book, kid(h, 0), "U32")) &&
    j_callback_live_compose_type(book, kid(h, 1), kid(t, 0), U32.sub(left, 1)))

# Check exact composition lambda binders, including erased prefix positions.
@unsafe
def j_callback_compose_on(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +f = j_fusion_binder(dv(d), 3)
  +g = j_fusion_binder(dv(d), 4)
  +x = j_fusion_binder(dv(d), 5)
  +body = j_fusion_after(dv(d), 6)
  +inner = j_strip(kid(body, 1))
  j_fusion_def(d, 5) && j_u32_bounded([dt(d), dv(d)], 2048) &&
    j_callback_erased_prefix(book, dt(d), dv(d), 3) &&
    j_callback_live_compose_type(book, j_specialize(book, dt(d), [ref("U32"), ref("U32"), ref("U32")]), j_fusion_after(dv(d), 3), 3) &&
    String.eq(tg(f), "Lam") && String.eq(tg(g), "Lam") && String.eq(tg(x), "Lam") &&
    String.eq(tg(body), "App") && U32.is_eq(terms_len(ks(body)), 2) &&
    j_fusion_var(kid(body, 0), ix(g)) && String.eq(tg(inner), "App") && U32.is_eq(terms_len(ks(inner)), 2) &&
    j_fusion_var(kid(inner, 0), ix(f)) && j_fusion_var(kid(inner, 1), ix(x))

@unsafe
def j_callback_factory_on(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +z = j_strip(j_fusion_empty(d))
  +s = j_fusion_link(d)
  +p = j_fusion_binder(s, 0)
  +body = j_fusion_after(s, 1)
  +binding = kid(body, 0)
  +call = j_call_spine(kid(body, 1), Nil{})
  +leaf = j_strip(kid(call, 3))
  +recur = j_call_spine(kid(call, 4), Nil{})
  j_fusion_def(d, 1) && j_callback_factory_type(book, dt(d)) && j_u32_bounded([dt(d), dv(d)], 4096) &&
    j_fusion_cases(dv(d), "Zero", "Succ") && String.eq(tg(z), "Lam") &&
    U32.is_eq(terms_len(ks(z)), 1) && j_fusion_var(kid(z, 0), ix(z)) &&
    String.eq(tg(p), "Lam") && String.eq(tg(body), "Let") && U32.is_eq(terms_len(ks(body)), 2) &&
    String.eq(tg(binding), "Bind") && Bool.not(U32.is_eq(qt(binding), 0)) && U32.is_eq(terms_len(ks(binding)), 1) &&
    j_callback_scalar(book, kid(binding, 0), Nil{}, ix(p), 256) &&
    String.eq(tg(call), "Call") && U32.is_eq(terms_len(ks(call)), 5) &&
    j_callback_compose(book, lookup(book, nm(call))) &&
    j_primitive_type(book, wnf(book, kid(call, 0)), "U32") &&
    j_primitive_type(book, wnf(book, kid(call, 1)), "U32") &&
    j_primitive_type(book, wnf(book, kid(call, 2)), "U32") &&
    String.eq(tg(leaf), "Lam") && U32.is_eq(terms_len(ks(leaf)), 1) &&
    j_fusion_scalar(book, kid(leaf, 0), [leaf, binding]) &&
    j_fusion_call(recur, dn(d), 1) && j_fusion_var(kid(recur, 0), ix(p))

# The source proof admits from_nat only on the predecessor. Inside a bounded
# U32 countdown its exact U32 image is the already numeric predecessor.
@unsafe
def j_callback_capture_u32(+t: KTerm) -> KTerm:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(KTerm, j_fusion_call(s, "U32.from_nat", 1), u => kid(s, 0), u =>
    kc(KTerm, String.eq(tg(h), "App"),
      u => k_with_children(h, j_callback_capture_u32_terms(ks(h))), u => h))

@unsafe
def j_callback_capture_u32_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_callback_capture_u32(h), j_callback_capture_u32_terms(rest)}

# Both paths reuse original scalar source expressions and semantic n-to-1 order.
@unsafe
def j_callback_application_loop(+book: List<&2,KDef>, +factory: KDef, +number: Bool) -> String:
  +s = j_fusion_link(factory)
  +p = j_fusion_binder(s, 0)
  +body = j_fusion_after(s, 1)
  +binding = kid(body, 0)
  +call = j_call_spine(kid(body, 1), Nil{})
  +leaf = j_strip(kid(call, 3))
  +capture = kc(KTerm, number, u => j_callback_capture_u32(kid(binding, 0)), u => kid(binding, 0))
  +capture_env = {[kt("Env", "", ix(p), 0, [ref(kc(String, number, u => "U32", u => "Nat"))])] : List<&2,KTerm>}
  "while($cb_n!==" ++ kc(String, number, u => "0", u => "0n") ++ "){const " ++ j_local(ix(p)) ++
    "=$cb_n-" ++ kc(String, number, u => "1", u => "1n") ++ ";const $cb_capture=" ++
    j_expr(book, capture_env, capture, ref("U32"), False{}) ++ ";const " ++ j_local(ix(binding)) ++ "=$cb_capture;const " ++
    j_local(ix(leaf)) ++ "=$cb_value;$cb_value=" ++ j_fusion_expr(book, kid(leaf, 0), [binding, leaf]) ++
    ";$cb_n=" ++ j_local(ix(p)) ++ ";}"

@unsafe
def j_callback_private_body(+book: List<&2,KDef>, +vars: List<&2,KTerm>, +factory: KDef, +count: KTerm, +seed: KTerm) -> String:
  "/* private total-U32 callback construction/application fusion */const $cb_count=" ++ j_fusion_expr(book, count, vars) ++
    ";let $cb_value=" ++ j_fusion_expr(book, seed, vars) ++ ";" ++
    "if(typeof $cb_count===\"number\"&&Number.isInteger($cb_count)&&$cb_count>=0&&$cb_count<=4294967295){" ++
    "/* private callback U32 countdown */let $cb_n=$cb_count;" ++ j_callback_application_loop(book, factory, True{}) ++
    "}else{/* private callback BigInt countdown fallback */let $cb_n=BigInt($cb_count);" ++
    j_callback_application_loop(book, factory, False{}) ++ "}return $cb_value;"

@unsafe
def j_callback_root_body(+book: List<&2,KDef>, +d: KDef) -> String:
  +vars = {[j_fusion_binder(dv(d), 0), j_fusion_binder(dv(d), 1)] : List<&2,KTerm>}
  +call = j_call_spine(j_fusion_after(dv(d), 2), Nil{})
  +count = j_call_spine(kid(call, 0), Nil{})
  +factory = lookup(book, nm(call))
  kc(String, j_fusion_def(d, 2) && j_fold_root_signature(book, dt(d), 2) &&
    j_primitive_type(book, j_fold_root_result(book, dt(d), 2), "U32") &&
    String.eq(tg(call), "Call") && U32.is_eq(terms_len(ks(call)), 2) &&
    j_fusion_call(count, "U32.to_nat", 1) && j_primitive_call(book, count) &&
    j_callback_scalar(book, kid(count, 0), vars, 4294967295, 256) &&
    j_callback_scalar(book, kid(call, 1), vars, 4294967295, 256) && j_callback_factory(book, factory),
    u => j_callback_private_body(book, vars, factory, kid(count, 0), kid(call, 1)), u => "")

@unsafe
def j_callback_root(+book: List<&2,KDef>, +d: KDef) -> String:
  +body = kc(String, j_fusion_def(d, 2) && j_region_capture_eligible(book, d) && j_u32_bounded([dt(d), dv(d)], 8192), u => j_callback_root_body(book, d), u => "")
  +call = j_call_spine(j_fusion_after(dv(d), 2), Nil{})
  +factory = lookup(book, nm(call))
  +compose = lookup(book, nm(j_call_spine(kid(j_fusion_after(j_fusion_link(factory), 1), 1), Nil{})))
  +helpers = {[factory, compose] : List<&2,KDef>}
  kc(String, Bool.not(String.eq(body, "")), u =>
    "(()=>{const $guards=[" ++ j_quote(dn(d)) ++ "," ++ j_region_names(helpers) ++ "];return fn(2,exactCode(function(a,$entered){" ++
    j_nat_loop_slots(2, 0) ++ "if($entered&&regionHostGuard(true)&&" ++ j_region_inputs(book, dt(d), 0, 2, False{}) ++ "&&localGuard($guards,callbackU32Guard)){" ++
    "const $previousProof=regionProofOpen($guards);try{const " ++ j_local(ix(j_fusion_binder(dv(d), 0))) ++ "=$s0;const " ++
    j_local(ix(j_fusion_binder(dv(d), 1))) ++ "=$s1;" ++ body ++ "}finally{regionProofClose($previousProof);}}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}));})()", u => "")

# Snapshot only cheap structurally eligible callable families; do not rerun the
# full new proof on every unrelated emitted definition.
@unsafe
def j_callback_capture_eligible(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, j_fusion_def(d, 1) && String.eq(tg(j_strip(dv(d))), "Mat"), u => j_callback_factory(book, lookup(book, dn(d))), u =>
    kc(Bool, j_fusion_def(d, 5) && String.eq(tg(j_strip(dv(d))), "Lam"), u => j_callback_compose(book, lookup(book, dn(d))), u => False{}))

@unsafe
def j_callback_compose(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, j_fusion_def(d, 5) && String.eq(tg(j_strip(dv(d))), "Lam"),
    u => kc(Bool, j_u32_bounded([dt(d), dv(d)], 2048), u => j_callback_compose_on(book, d), u => False{}), u => False{})

@unsafe
def j_callback_factory(+book: List<&2,KDef>, +d: KDef) -> Bool:
  kc(Bool, j_fusion_def(d, 1) && String.eq(tg(j_strip(dv(d))), "Mat"),
    u => kc(Bool, j_u32_bounded([dt(d), dv(d)], 4096), u => j_callback_factory_on(book, d), u => False{}), u => False{})

# Original checked source book and annotated emitter defs have distinct Lam
# metadata. The formal All telescope owns erasure (as j_lambda_bind does).
# This route admits only the original source Lam q1 spelling and proves its
# erased binder never occurs in runtime syntax; Ann type children are ignored.
@unsafe
def j_callback_runtime_absent(+t: KTerm, +id: U32, +fuel: U32) -> Bool:
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(t), "Ann"), u => j_callback_runtime_absent(kid(t, 0), id, U32.sub(fuel, 1)), u =>
      kc(Bool, String.eq(tg(t), "Var"), u => Bool.not(U32.is_eq(ix(t), id)),
        u => j_callback_runtime_absent_terms(ks(t), id, U32.sub(fuel, 1)))), u => False{})

@unsafe
def j_callback_runtime_absent_terms(+ts: List<&2,KTerm>, +id: U32, +fuel: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, j_callback_runtime_absent(h, id, fuel),
        u => j_callback_runtime_absent_terms(rest, id, fuel), u => False{})
