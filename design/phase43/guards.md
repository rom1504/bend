# Phase43 entry guard hypothesis

P43-005 addresses the fixed entry cost visible in the selected16 List512
profile: host guard 40.75% self CPU; scalar guard 15.31%; descriptor queries
79.5% estimated allocation. No timing has been run by this owner.

The proposed saved-output ablation adds `localGuardAfterHost` and a separate
`scalarGuardAfterHost`. The original scalar/local guards and complete host guard
remain byte-identical. Only a root clause with an immediately preceding successful
host guard and inert canonical scalar tests uses the new helper. Exact Object and
Array prototype key inventories imply absence of all marker keys checked again
by local/scalar guards under the published standard-at-import contract. The new
helper preserves Object/Function/primitive prototype checks, Function.call and
all original dependency descriptors, identities, metadata and bound lengths.
Its direct descriptor-value checks avoid per-dependency `[a,c,e,b]` arrays and
`.every` closures; indexed primitive checks avoid the temporary spread array.

This is invocation-local logical implication, not memoization: no flag, token,
proof or host fact is saved for the next entry. Existing proof coverage and Error
suspension/cleanup remain unchanged. Standalone scalar guards must retain their
original observer behavior because Array.every/iterator mutations can execute
there when no host guard dominates. A wider initial draft was rejected for that
reason before execution.

Expected family benefit is uncertain. The campaign's 1.2–2× short-workload
hypothesis requires a measured substantial reduction in entry cost. This first
ablation only attacks part of the 15.31% scalar cost plus repeated local checks;
1.05–1.2× is a more defensible prior. Retaining the 40.75% host guard establishes
a hard limit. Removing irrelevant numeric host checks requires a separately
proved dependency-specific host domain and activation policy, and is deferred.

The smallest falsifier is canonical fusion activation plus equal result/error
and demand trace under a single changed descriptor. Timing is justified only
after the complete oracle and independent review. No production file is edited.

## Separate P43-005b: full total-U32 fusion host domain

Root authorized this larger ablation after the exact guard study. Batch descriptor
retrieval was rejected statically: it still allocates one descriptor per property
plus an aggregate object and asks for unrelated keys (Math44 vs selected21;
globalThis over100 vs selected7). No mutable host version exists to cache safely.

A full successful `j_fusion_root_prefix` proof already establishes all public
inputs/result as U32 and every producer/selector/map/fold scalar operation in the
total U32 whitelist. The resulting complete loop has no generic/residual calls,
no floating input validation, no F32 literals and no DataView use. Thus retain the
full guard's globals, Object/Reflect/WeakSet mechanisms, all Array/object protocol
and key checks, Number.isInteger and Math.imul; omit other Math methods,
Number.isNaN/isFinite, DataView instance/prototype/method checks. This removes
25 host descriptor checks plus four instance descriptors and one prototype query.
It permits private activation under an irrelevant floating hook mutation, while
requiring exact result/error/demand-trace equivalence to the old generic fallback.

The saved independent domain candidate leaves ordinary scalar/local guards
unchanged. This separates numeric host-domain benefit from AfterHost temporary
array and duplicate-check reduction. Oracle permits activation differences only
for the explicitly omitted floating hooks; every observed trace/value must match.
The 1.2–2× prior is plausible for short fused lists but remains hypothetical.

Source hook proposal: compute `j_fusion_root_prefix` once at root emission and
thread its successful body through both guard choice and body selection. A
nonempty full fusion body chooses `regionHostGuardU32Fusion`; emit that exact
full body in the proof try/finally. An empty fusion result retains ordinary full
host guard and `j_flat_root_scope` path. Do not select a narrow guard by searching
emitted comments, by graph purity alone, or by having some U32 helpers. Reuse the
same proof result to avoid a second analysis and forbid mixed residual/float bodies.
