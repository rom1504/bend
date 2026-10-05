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
