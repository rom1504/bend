
# The same certificate permits root-preserving observers: the current native
# catalog and audited IO.args/print/now handlers expose no immutable-root
# identity or mutation. Any foreign whitelist extension must preserve that
# stronger property or split observer permission from scalar-array permission.
# Preconditions: checked/specialized/annotated book, validated layouts, trusted
# runtime and effect ABI. The host proves the narrow effect-source permission.

# Module: src/back/native/scalar-array.bend:60
# Safe predicate used by the actual scoped observer-permission classifier.
# Host authentication and unannotation supply the two explicit flags.
def no_effect_provider_member(names: List<&2, String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}: p88_string_eq(head, name) || no_effect_provider_member(rest, name)

def no_effect_foreign_allowed(trusted: Bool, filled: Bool, name: String) -> Bool:
  trusted && filled && no_effect_provider_member(["IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err", "File.open", "File.open_bytes", "File.read", "File.read_line", "File.read_bytes", "File.read_at", "File.size", "File.write", "File.write_bytes", "File.write_at", "File.close"], name)

# Checked observer permission is independent of packed arrays and narrowing.
# The host authenticates Base/runtime/provider bytes; names alone grant nothing.
# Keep the old rewrite refusal. The observer's own typed schema/residual checks
# separately exclude Array roots, allocating Word views and foreign calls.
@unsafe
def no_effect_terms(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{+t, rest}: Bool.not(String.eq(tg(t), "Rwt")) && no_effect_terms(ks(t)) && no_effect_terms(rest)

@unsafe
def no_effect_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d), u => True{}, u => nt_choose(Bool, nc_foreign(d),
        v => no_effect_foreign_allowed(db(d), String.eq(tg(nc_unann(dv(d))), "Foreign"), dn(d)),
        v => String.eq(dk(d), "Def") && no_effect_terms([dv(d)]))), u => no_effect_definitions(book, rest), u => False{})
