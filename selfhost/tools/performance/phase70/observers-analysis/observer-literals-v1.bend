# Source-only Phase70 proposal; no compiler/target validation yet.
# Analyze nc_definition_plain directly, including every expanded helper.
# Incoming NWord is deliberately unsupported: its source kind is already lost.

@unsafe
def no_literal_native(+book: List<&2, KDef>, +kind: String) -> Bool:
  +d = lookup(book, kind)
  String.eq(dk(d), "ADT") && db(d) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0)

# The child is the emitter atom; name is the exact scalar kind and id the U32
# payload. F32 retains its raw bits. Nat literals fit below native NAT_IMM.
@unsafe
def no_literal_typed(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  nt_choose(KTerm, core_literal(t) && nb_contains(["Nat", "U32", "F32"], nm(t)) && no_literal_native(book, nm(t)),
    u => kt("NO_TypedWord", nm(t), kl_number(t), 0, [kt("NWord", U32.show(kl_number(t)), 0, 0, Nil{})]),
    u => atom("Absent"))

# Optional: one structural step only. The caller must re-enter its ordinary
# budgeted evaluator and spend fuel again; never recursively expand here.
@unsafe
def no_literal_string_step(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  nt_choose(KTerm, core_literal(t) && String.eq(nm(t), "String") && no_literal_native(book, "String"),
    u => core_literal_step(t), u => atom("Absent"))

# A virtual constructor would erase nat_chk/term_word demand. Refuse even if
# the value will be discarded later. Source KLiteral is handled above instead.
# Chr is separate: admit only one argument whose exact proven type is U32.
@unsafe
def no_literal_demanding_ctor(+name: String) -> Bool:
  nb_contains(["Succ", "U32", "F32"], name)
