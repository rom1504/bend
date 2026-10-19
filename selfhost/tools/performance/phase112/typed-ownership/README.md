# Early reuse of checked scalar ownership facts

The `facts` profile extends `gap-if`; it excludes the failed experimental
immediate keep/sink emitter. Five exact declaration replacements preserve the
mature scalar facts until ownership insertion. All machine arguments and
results remain U64 and the original structured verifier remains mandatory.

`p111_extend` uses the mature `nf_worker_kinds` and `nk_typed_bindings` helpers.
They require the checked declaration's live arity and resolve canonical builtin
U32, F32, Char, and Bool through the existing bounded type-layout resolver.
Nat, boxed values, unknown types, mismatched arities and nonbuiltin lookalikes
remain opaque. The original source book index supplies the telescope; erased
body facts do not replace it. `nk_binding` preserves known kinds through local
variable aliases in both normal and liveness lowering. Keep/sink insertion then
omits only bindings classified N_W32. Unclassified primitive and ordinary-call
results still retain the original ownership operations.

The existing word-pattern lowerer is another N_W32 producer. Its selected
implementation explicitly masks values to32 bits and optional bits to1; the
source admission binds that implementation too. Every direct-backend binding
reader was inspected: parameter/frame transport, values, fields and worker
planning preserve or ignore kind and retain U64 words. No NF scalar C argument
renderer is introduced. The binding's word field remains a local identifier.

These facts are derived inside the checked source pipeline. Arbitrary serialized
books or NC_Binding records are not ownership certificates. Original metadata,
helpers, runtime04 and ABI11101 are bound by `admit.py`, which defaults to the
exact no-immediate statement-hook composition. Its optional `--immediate` flag
records a different experimental composition and does not qualify that failed
candidate. Source admission is separate from native semantic qualification.

Root reported27 structural controls and the11 complete outputs in
`semantics.bend` passing for both baseline and candidate. They cover scalar
aliases, canonical-kind and arity guards, opaque and shadowed bindings,
preserved captures, unknown results, unchanged U64 transport, scalar overflow,
mixed scalar/owned captures, String shadowing, Bool/Char/F32 and conservative
Nat handling. The immutable expectations are in `expected.stdout`.

The root-run structural witness uses one actual checked request and invokes both
Bend lowerers, verifies both original IR graphs, then counts statements only:

```sh
node selfhost/tools/performance/phase112/typed-ownership/witness.mjs \
  BASE_API CANDIDATE_API \
  selfhost/build/phase93/fixtures01/scalar-region-8192.bend \
  selfhost/build/phase112/facts-admission01/report.json FRESH_OUT
```

It expects a reduction in post-frame keeps in `$direct.mit`. It does not perform
host lowering or claim that continuation transport disappears. Native output,
lifetime and matched timing results remain separate evidence. The motivating
source comparison is recorded in `implementation/phase112/broad-gap.md`.

The immediate overlay is excluded because the complete Unicode workload failed
its success counters despite correct initial text. Source comparison isolated
that failure to its conditional helper expansion: collapsing those107 templates
back to the original calls makes all637 generated function bodies match the
passing gap-if product. The underlying backend/CFG cause remains unresolved.
