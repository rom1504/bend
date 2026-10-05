# Literal-array regions retain ordinary ctor handles and lazy arraydata. The
# capability is a bounded planning context, never the raw-array BookCache flag.
@unsafe
def j_array_literal_name(+name: String) -> Bool:
  String.eq(name, "ALeaf") || String.eq(name, "ANode")

# This syntactic fence excludes helper calls and effects inside constructor
# fields. F32 literal realization still keeps its original left-to-right order.
@unsafe
def j_array_literal_fields(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        kc(Bool, String.eq(tg(t), "Ann"),
          u => j_array_literal_fields(Con{kid(t, 0), rest}, U32.sub(fuel, 1)), u =>
        kc(Bool, String.eq(tg(t), "Ctr") && j_array_literal_name(nm(t)),
          u => j_array_literal_fields(List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1)), u =>
          String.contains("|Var|JSlot|Lit|JF32|", "|" ++ tg(t) ++ "|") &&
            j_array_literal_fields(rest, U32.sub(fuel, 1)))), u => False{})

# Called by the shared constructor planner; its ordinary typed argument walk
# still checks every specialized field and result. Outside this context unchanged.
@unsafe
def j_array_literal_ctor(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm, +active: List<&2,String>) -> KDef:
  kc(KDef, has_name(active, "@array-handles") && j_array_effect_array(book, ty) &&
    j_array_literal_name(nm(t)) && j_array_literal_fields([t], 256),
    u => j_array_literal_ctor_checked(book, t), u => j_producer_ctor(book, ty, nm(t), active))

@unsafe
def j_array_literal_ctor_checked(+book: List<&2,KDef>, +t: KTerm) -> KDef:
  +c = lookup(dc(lookup(book, "Array")), nm(t))
  kc(KDef, j_pure_native_ctor(c, nm(t), kc(U32, String.eq(nm(t), "ALeaf"), u => 1, u => 2)) &&
    U32.is_eq(terms_len(ks(t)), da(c)), u => c, u => missing())

# A cheap structural fence bounds applicability before expensive region planning.
# No specific source definition or benchmark identity participates.
@unsafe
def j_array_literal_present(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_gt(fuel, 0), u =>
        kc(Bool, String.eq(tg(t), "Ctr") && j_array_literal_name(nm(t)), u => True{}, u =>
          j_array_literal_present(List.append(&2,KTerm, ks(t), rest), U32.sub(fuel, 1))), u => False{})

@unsafe
def j_array_literal_root(+book: List<&2,KDef>, +d: KDef) -> String:
  kc(String, j_instance_source_definition(d) && Bool.not(db(d)) && U32.is_le(da(d), 32) &&
    U32.is_eq(j_lambda_count(dv(d)), da(d)) && j_region_signature(book, dt(d), da(d)) &&
    j_array_literal_present([dv(d)], 2048) && j_u32_bounded([dv(d)], 8192) &&
    Bool.not(j_l_deep(dv(d), 0)) && j_nat_loop_distinct(dv(d), Nil{}), u =>
    j_array_literal_root_done(book, d, j_region_prefix(book, Nil{}, dv(d), dt(d), 0, da(d), True{},
      "@root-return", [dn(d), "@array-handles"], 0, JRegionBuild{atom("Absent"), Nil{}, 32768, True{}})), u => "")

@unsafe
def j_array_literal_root_done(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  kc(String, j_region_valid(s) && j_region_has_loop(book, j_region_helpers(s)) &&
    j_array_literal_effect(j_region_helpers(s)) &&
    j_array_view_terms_mode(book, j_region_helpers(s), [j_region_term(s)], 8192, True{}) &&
    j_array_view_helpers_mode(book, j_region_helpers(s), j_region_helpers(s), True{}),
    u => j_array_literal_emit(book, d, s), u => "")

@unsafe
def j_array_literal_effect(+helpers: List<&2,KDef>) -> Bool:
  match helpers:
    case Nil{}: False{}
    case Con{d, rest}: (db(d) && j_array_effect_known(dn(d))) || j_array_literal_effect(rest)

# Code and helpers are created once; each public nullary demand recomputes its
# body. exactCode's nullary form preserves code.length, missing args and new code.
@unsafe
def j_array_literal_emit(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  "(()=>{" ++ j_region_declarations(book, j_array_view_normalize_defs(book, j_region_helpers(s), j_region_helpers(s))) ++
    "const $guards=[" ++ j_quote(dn(d)) ++ "," ++ j_region_names(j_region_helpers(s)) ++ "];return fn(" ++
    U32.show(da(d)) ++ ",exactCode(function(a,$entered){" ++ j_nat_loop_slots(da(d), 0) ++
    "if($entered&&" ++ j_array_literal_count_guard(book, d, s) ++ "arrayViewHostGuard()&&" ++ j_region_inputs(book, dt(d), 0, da(d), False{}) ++
    "&&localGuard($guards)){/* private literal array handles */" ++
    j_nat_loop_generic(book, Nil{}, j_array_view_normalize(book, j_region_helpers(s), j_region_term(s), ""), dt(d), 0) ++ "}" ++
    j_nat_loop_generic(book, Nil{}, dv(d), dt(d), 0) ++ "}" ++
    kc(String, U32.is_eq(da(d), 0), u => ",false,true", u => "") ++ "));})()"

# The caller reaches this only after the original region plan was not strong.
# Never displace an existing nonempty region plan with the new handle adapter.
@unsafe
def j_l_def_array_literal(+book: List<&2,KDef>, +d: KDef, +region: String) -> String:
  j_l_def_array_literal_done(book, d, region,
    kc(String, String.eq(region, ""), u => j_array_literal_root(book, d), u => ""))

@unsafe
def j_l_def_array_literal_done(+book: List<&2,KDef>, +d: KDef, +region: String, +worker: String) -> String:
  kc(String, String.eq(worker, ""), u => j_l_def_instance(book, d, region, j_instance_root(book, lookup(book, dn(d)))),
    u => j_l_def_selected(book, d, j_l_global_worker(book, d, dv(d), worker)))

# Decline-only profitability fence for one directly visible Nat countdown.
# Existing accepted literal plan owns all semantics/typing/loop proof.
@unsafe
def j_array_literal_count_guard(+book: List<&2,KDef>, +d: KDef, +s: JRegionBuild) -> String:
  +loop = j_array_literal_single_loop(j_region_helpers(s), "", 32)
  kc(String, String.eq(loop, ""), u => "", u =>
    j_array_literal_count_text(j_array_literal_count_walk(book, d, loop,
      [j_region_term(s)], 256, atom("Absent"))))

# A fold/producer/residual or second matcher keeps the original entry policy.
@unsafe
def j_array_literal_single_loop(+helpers: List<&2,KDef>, +found: String, +fuel: U32) -> String:
  match helpers:
    case Nil{}: found
    case Con{d, rest}:
      kc(String, U32.is_gt(fuel, 0), u =>
        kc(String, String.contains("|Mat|JFold|JProducer|JResidual|", "|" ++ tg(j_strip(dv(d))) ++ "|"), u =>
          kc(String, String.eq(found, "") && String.eq(tg(j_strip(dv(d))), "Mat") &&
            String.eq(nm(j_strip(dv(d))), "Zero"),
            u => j_array_literal_single_loop(rest, dn(d), U32.sub(fuel, 1)), u => ""),
          u => j_array_literal_single_loop(rest, found, U32.sub(fuel, 1))), u => "")

# Visit at most 256 plan nodes; annotation types are not executable children.
# Exactly one direct loop call is required. No helper expansion or substitution.
@unsafe
def j_array_literal_count_walk(+book: List<&2,KDef>, +d: KDef, +loop: String,
  +todo: List<&2,KTerm>, +fuel: U32, +found: KTerm) -> KTerm:
  match todo:
    case Nil{}: found
    case Con{t, rest}:
      kc(KTerm, U32.is_gt(fuel, 0), u =>
        j_array_literal_count_node(book, d, loop, j_strip(t), rest, U32.sub(fuel, 1), found),
        u => atom("Absent"))

@unsafe
def j_array_literal_count_node(+book: List<&2,KDef>, +d: KDef, +loop: String,
  +t: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +found: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "JCall") && String.eq(nm(t), loop), u =>
    kc(KTerm, String.eq(tg(found), "Absent") && U32.is_gt(terms_len(ks(t)), 0), u =>
      j_array_literal_count_after(book, d, loop, List.append(&2,KTerm, ks(t), rest), fuel,
        j_array_literal_count_value(book, d, kid(t, 0))), u => atom("JCountUnknown")), u =>
    j_array_literal_count_walk(book, d, loop, List.append(&2,KTerm, ks(t), rest), fuel, found))

@unsafe
def j_array_literal_count_after(+book: List<&2,KDef>, +d: KDef, +loop: String,
  +rest: List<&2,KTerm>, +fuel: U32, +found: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(found), "JCountSlot"),
    u => j_array_literal_count_walk(book, d, loop, rest, fuel, found), u => atom("JCountUnknown"))

@unsafe
def j_array_literal_count_value(+book: List<&2,KDef>, +d: KDef, +term: KTerm) -> KTerm:
  +t = j_strip(term)
  +call = j_call_spine(t, Nil{})
  kc(KTerm, String.eq(tg(call), "Call") && String.eq(nm(call), "U32.to_nat") &&
    U32.is_eq(terms_len(ks(call)), 1), u =>
      kc(KTerm, j_primitive_call(book, call),
        u => j_array_literal_count_slot(book, d, j_strip(kid(call, 0)), dv(d), dt(d), 0, "U32"),
        u => atom("JCountUnknown")), u =>
      j_array_literal_count_slot(book, d, t, dv(d), dt(d), 0, "Nat"))

# Root prefix binders remain Vars in the successful keep=True region plan.
# Direct count only: lets, arithmetic, casts other than exact to_nat and wrappers
# keep the prior policy, including constant Nat37 and nullary roots.
@unsafe
def j_array_literal_count_slot(+book: List<&2,KDef>, +d: KDef, +t: KTerm,
  +body: KTerm, +ty: KTerm, +at: U32, +kind: String) -> KTerm:
  kc(KTerm, U32.is_lt(at, da(d)) && U32.is_lt(at, 32), u =>
    j_array_literal_count_slot_on(book, d, t, j_strip(body), wnf(book, ty), at, kind),
    u => atom("JCountUnknown"))

@unsafe
def j_array_literal_count_slot_on(+book: List<&2,KDef>, +d: KDef, +t: KTerm,
  +body: KTerm, +ty: KTerm, +at: U32, +kind: String) -> KTerm:
  kc(KTerm, String.eq(tg(body), "Lam") && String.eq(tg(ty), "All"), u =>
    kc(KTerm, String.eq(tg(t), "Var") && U32.is_eq(ix(t), ix(body)), u =>
      kc(KTerm, j_primitive_type(book, wnf(book, kid(ty, 0)), kind),
        u => kt("JCountSlot", kind, at, 0, Nil{}), u => atom("JCountUnknown")), u =>
      j_array_literal_count_slot(book, d, t, kid(body, 0), kid(ty, 1), U32.inc(at), kind)),
    u => atom("JCountUnknown"))

@unsafe
def j_array_literal_count_text(+fact: KTerm) -> String:
  kc(String, String.eq(tg(fact), "JCountSlot"), u =>
    "!(typeof $s" ++ U32.show(ix(fact)) ++ "===\"" ++
    kc(String, String.eq(nm(fact), "U32"), u => "number", u => "bigint") ++
    "\"&&($s" ++ U32.show(ix(fact)) ++ "===" ++
    kc(String, String.eq(nm(fact), "U32"), u => "0", u => "0n") ++
    "||$s" ++ U32.show(ix(fact)) ++ "===" ++
    kc(String, String.eq(nm(fact), "U32"), u => "1", u => "1n") ++ "))&&", u => "")
