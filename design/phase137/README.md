# Phase137 — Make real compiler queries use borrowed scalar readers

Start2026-10-24 at`4778aff1249cad08cb3f90e01cfff56bce01da36`.
The objective is lower cold native compiler latency while preserving semantic
correctness and generated-program performance. Phase136 measured375.923s for a
full source-to-executable build. Its three main definition queries occupy18.16%
of active-context samples and repeatedly transfer unwanted KDef field references.

## Hypotheses and smallest decisive experiment

Reuse the existing Phase131 four-bound wider-record capability on exact qualified
Phase134 source. KDef has nine fields, beyond the current eight-field admission
policy. Keep the runtime, scratch/capacity verifier, late field-read template,
calling convention, proof bodies and all protected verifier declarations intact.

Width alone may not help functions returning owned records. Preserve complete
scalar name/kind predicates inside the actual lookup/constructor-query consumers
so existing borrowed-reader derivation can see them. Keep record-return and
unknown/escaping paths owning. Separate two factors: width8/16 and original/fused
scalar consumers. Actual emitted calls and ownership operations determine whether
the intended transformation occurred; a source spelling change is insufficient.

Use extracted current compiler declarations, independent expected answers,
retained aliases, misses, declaration shadowing, BookCache behavior, opaque
fields and Unicode. Include an unrelated record/tree query. Reuse the previous
wide-layout controls, scalar-selector proof where definitions actually match,
native aligned builder and clean timing harness. Do not create another benchmark
framework or treat a finite control as a universal correctness theorem.

## Execution and selection

1. Freeze source/method/oracle identities. Independently source-check the rebased
   candidate and its finite width/contract controls. Review changed declarations.
2. Emit/build small two-factor variants. Inspect QBE and native code; require
   independently correct outputs and removal of actual take/sink work. Use short
   calibrated native repetitions and rotated timing, with one root-owned CPU3 lane.
3. If the ceiling transfers, apply the minimal source predicate composition to
   actual hot compiler consumers and measure whole small requests. Track analysis
   overhead, emitted size and source growth. Reject or narrow broad regressions.
4. Only then acquire a full candidate natively. Separate fixed-source algorithm
   speed from generated-compiler quality: wider code generation can first benefit
   a successor compiler. Measure N1 and N2 explicitly and compare the same full
   historical source against a fresh qualified control.
5. A selected successor requires native self-reproduction, independent ordinary
   semantic/ownership gates and generated-program checks appropriate to the
   changed code. Keep Phase134 and installed selections intact until qualified.

Full source timings are end-to-end request/build observations, not isolated
getter speedups. Fresh generated-program timing is required wherever emitted
code changes; exact-output compiler-only changes can reuse matching products.
Do not infer45-program or upstream parity from a small screen.

## Fallback and broader ambition

If width/consumer composition is neutral or cannot reach real calls economically,
preserve that result and try the measured second factor: an exact earlier
constructor-ownership fact or parser-prior lookup boundary. Existing scope indexes
can differ in precedence/payload; no blind replacement is legal. Do not add a
global cache wrapper after Phase135's mixed result.

The larger architectural direction is an immutable held compiler context with
reusable scalar facts and explicit owner units. It should emerge from successful
query/preparation boundaries. A wholesale indexed-IR rewrite, byte-emitter rewrite
or incremental frontend is outside this first experiment unless decisive new
evidence makes it the better route.

## Cost discipline and deliverables

Three bounded agents own width integration, real-query fixtures and independent
semantic/generated-code audit. Only the coordinator executes targets. Large jobs
use4GiB RSS and16GiB available-memory guards; ordinary jobs use2–3GiB. Disk starts
with12GB free. Preserve failed attempts and immutable receipts. Reuse retained
objects/runtime and keep new full images to justified qualification milestones.

Report measured query gains, work removed, transfer/negative cases, compiler
request and full-build cost, generated-code quality, complexity and qualification
status separately. Commit and push design, validated code and evidence; post no
PR comments.5–12% whole-build savings remains a hypothesis, not a promised result.
