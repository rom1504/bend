# P107-003 — preserve effects while removing leaf call boundaries

2026-10-18. Hypothesis, not an established result: the shared/borrowed observer
workloads remain slower under lightweight native backends because the current
scalar-pure inliner excludes every pointer parameter, load and store. The remaining
paired ratios reported by the root campaign are approximately3.9×/2.58× C; the exact
run receipts belong in the final report. An ordinary call-free memory helper can
be inlined without proving it pure or changing its ownership operations.

The optional Bend API `nx_inline_leaf(program,budget)` admits verified U32/U64/Ptr
helpers with at most16 parameters,32 locals and256 body nodes. There are no direct
or indirect calls, loops, or mixed early-return/fallthrough layouts in an admitted
callee. Loads, stores, pointer offsets, allocation/free and pointer results remain
in source order. The common expander evaluates each argument once into a fresh
local, resets callee locals per invocation and binds every terminal result before
the original continuation. No borrow analysis, RC elimination, load motion, alias
assumption or allocation removal is performed. The whole-program budget remains
4096, with256-function/65536-node admission limits and post-transform verification.

The shared renamer gains missing memory-expression/statement cases. Existing
baseline/deep/entry scalar eligibility does not change. Require byte-identical
outputs for previously accepted scalar transformations against frozen APIs before
interpreting the extension as a harmless shared-engine change.

Freeze tests before performance: aliased parameter pointers; load-store-load
ordering; a returned interior pointer; pointers stored into and loaded from a
cell; explicit alloc/free; multiple uses of a mutable parameter; local reset in a
caller loop; effectful branch merge; and direct/indirect recursion/loop refusal.
Use independent full-result expectations and before/after native/interpreter
comparisons where supported. Deliberately delete or reorder a store/reset in an
emitted-IR mutant to establish sensitivity. Pointer safety remains a trusted
well-formed-program assumption, not a theorem of the structural verifier.

Only after those gates: compare unchanged, leaf-inline, and leaf-inline plus
reachability on shared/shared_borrow and unrelated memory controls under the same
C/Cranelift/QBE profiles. Record optimizer time, AST size, object time and complete
runtime checksum. Reject a policy whose runtime gain is erased by iteration cost
for the intended check horizon. Do not infer full-compiler gains or ownership-law
coverage from this bounded memory slice. Production defaults remain unchanged.

Status: implementation and controls being prepared; no target execution by this
agent, no speed result or promotion decision.
