# Reusable analysis facts, laws and native optimization

The [Phase131 campaign](../../implementation/phase131/README.md) experiments
with compiler algorithms and QBE code generation separately. Consult its final
candidate receipt for qualification; a checked prototype is not an installed
compiler. The [experiment frontier](../../experiments/STEERING.md) identifies the
latest qualified source, runtime, native images and measurement policy.

## Facts that can survive a computation

The compiler already has independent ownership and final-IR verifiers. The
useful next abstraction is a small reusable fact with a precise validity domain,
rather than another analysis that rediscovers the same fact after every call.

| Fact | Validity domain | Work it can remove |
|---|---|---|
| Sparse variable-use summary | One immutable body and the exact count semantics | Repeated body traversals for different IDs |
| Closed immutable constructor | The prepared static image and its constructor layout | Repeated construction/destruction of constants |
| Borrowed helper result | Held roots, verified reader, exact owning fallback | Owning projections and reconstruction inside a query |
| Virtual scalar/product result | Verified field origins and an immediate nonescaping consumer | Temporary result allocation and field extraction |
| Callable worker summary | Actual emitted worker bundle and its calling convention | Generic scheduler transitions around known helpers |

Usage counts are saturated at two. Sequence, two-arm alternatives and the
compiler's `NWPattern` nodes have different minimum/maximum rules. Missing
summary entries mean zero, but this convention alone does not prove a summary
correct. Counts must remain bounded, keys must have the required ordering, and
the body traversal must match the original analyzer. Retain the old query as
an independent differential oracle during an implementation change.

Borrowed results must not outlive their held roots. Unknown layouts, escaping
values and unsupported consumers keep their owning behavior. A wrapper that
merely forwards a product does not justify replacing the original traversal.
Phase131's projection experiment retains the exact reader body and compares
against a worker-closure-only control, so readiness and allocation elimination
are measured separately.

## What the laws establish

The [law package](../../selfhost/tools/performance/phase131/laws/README.md)
contains actual proof bodies checked through the unchanged independent BendTT
kernel. Its source bridge authenticates the declarations used in an acquired
compiler; similar-looking model functions are insufficient.

The proved first-order map algorithms are equivalent to the earlier safe
algorithms for all input lists and keys. That equivalence is broader than the
current specification theorem: full merge-lookup correctness for different
ordered key sequences and the complete KTerm traversal are separate obligations.
For example, a theorem using saturated addition must require bounded input
counts; an absent-side identity cannot silently turn an arbitrary count of
three into two. State this premise explicitly.

Neither a forward `law` signature nor finite predicates establish a theorem.
Neither a theorem about a safe helper nor its checked source establishes native
backend, runtime, ownership or whole-compiler correctness. Mutation controls
test whether the unchanged theorem rejects an actual wrong helper. Native
oracles and the final verifier remain independent gates.

Proof erasure removes proof terms from execution. It does not make analysis
facts free to compute, and it does not excuse an expensive representation.
Phase131's first safe closure implementation was2.56 times slower than its
fast proxy. A proved first-order rewrite and a separate general selector fix
recovered nearly all of that difference through different mechanisms.

## Fast experiment order

1. Freeze the original semantics, output oracle and exact source/tool identities.
2. Prove a small production-connected rule and challenge it with a wrong rule.
3. Check a real extracted compiler computation, including construction and cleanup.
4. Inspect the actual installed worker and machine path; an eligible unused plan
   is not an optimization.
5. Measure paired native runtime and complete compiler-request cost separately.
6. Acquire a full native candidate only after useful transfer. Reproduce the
   fixed source and run the independent ordinary corpus before qualification.

Compiler-only algorithms should preserve complete emitted QBE. Codegen changes
need their own semantic and generated-runtime evidence; changed output cannot
be waived merely because a proxy is faster. Keep negative attempts and report
research overhead separately from compiler throughput.
