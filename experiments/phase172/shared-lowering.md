# Phase172: scope the shared-lowering hypothesis before a new IR

Read-only source/evidence audit at `fbdf8a0`. No compiler or target jobs.

The remaining duplicated category is genuine but smaller than the original
architectural story suggests. `p168_selected` builds raw private/product
candidates, dependency admission can discard their bodies, `p167l_family`
then builds demanded scheduled families, and late registry construction
rediscovers callable regions. `NativeStaticBody` is already reused; admitted
direct owners already avoid their generic body. Repeating either improvement
is not a new optimization.

The actual function families worth distinguishing are recursive verifier
body/schema walkers and persistent Map/index reconstruction. Non-tail self
calls and unresolved SCC interfaces block direct admission. Their semantic
dependency graph differs from merely unsupported syntax. A syntax feasibility
scan alone cannot safely declare all otherwise-valid callers dead, nor replace
the independent final verification.

The only retained complete raw-fate census found is historical Phase167:
127 raw identities,116 error-free,11 errors;55 raw owners admitted plus one
generated SCC helper;61 error-free dependency-blocked owners. The comparison
SCC subsequently admitted16 dependents. These numbers precede the restored
observer/early-import route and **are not current candidate counts**. Phase171's
current import inspection retains aggregate plans, not every failed raw body.
Do not present its zero additions as a current raw-lowering waste census.

The current diagnostic region totals impose an important ceiling:

| Region | Diagnostic seconds |
|---|---:|
| Raw candidate production |24.985|
| Demanded generic families/adapters |8.508|
| IDs/tables/index/registry |12.271|
| Rendering/output/exit |30.454|

These disjoint diagnostic regions sum76.218s. They include required work and
are not directly subtractable from the clean180.677s build. Halving all four
would remove38.109 diagnostic seconds, still far short of the80.677 clean
seconds needed for100s. Generic-body omission alone has only an8.5s region
ceiling. A25s raw-production idea must not consume another large campaign
without proving a broader downstream or generated-execution benefit.

`P113D` already retains structured scalar operations, calls, conditionals,
results, and loop backedges. An extended checked suspend/resume interface is a
more credible future shared representation than wrapping the current output
in a second universal IR. The smallest architectural experiment would replace
one real blocked SCC's private/generic/late-region reconstruction with a single
checked resumable graph and derived execution interfaces. It must count actual
discarded nodes and analysis visits eliminated, and demonstrate a complete
request/runtime improvement. The old source-level persistent zipper was neutral;
merely replacing continuations with another boxed path repeats that failure.

For this run, the bounded runtime-inlining falsifier in
[inline-runtime.md](inline-runtime.md) is cheaper to reject and directly tests
an observed C/bendc machine-code difference. It does not establish that shared
lowering is unnecessary or promise a100s outcome.

Evidence: [current profile](../phase171/candidate-profile.md),
[previous decision audit](../phase171/decision-audit.md),
[architecture audit](../phase171/architecture-audit.md),
[historical admission obstructions](../phase167/admission-obstructions.md).
