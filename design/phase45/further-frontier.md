# Phase45: broaden proved graphs before adding new public representations

The next small experiment should let the existing private worker backend consider monomorphic source-call graphs. It currently requires an erased call in the public root and at least one contextual specialization row, even though its collector already constructs exact aliases for ordinary source definitions. These are selection restrictions, separate from the complete graph, representation, and public-boundary proofs. Removing only that selection bottleneck can expose ordinary first-order programs to the same continuation IR and its subsequent passes.

This is a source inspection hypothesis, not a new performance result. The closed [Phase44 results](../../implementation/phase44/results.md) show raytrace at 18.35× TypeScript, active raytrace at 25.12–25.95×, Unicode text at 21.26–22.01×, and the complete generic row at 56.21×. The newer short worker screens do not remeasure that entire corpus. We must establish actual activation and fresh paired measurements before attributing any gain to the proposed admission change.

## What the existing backend can already express

The private continuation IR supports exact first-order source calls, mutual and non-tail recursion, ordered scalar operations, parallel lets, closed constructors and typed projections. Recursive SCCs have an explicit continuation machine; bounded native entries and native tail loops are optional execution paths over that same graph. Private tagged fields can stay in their private representation. The public root remains guarded and returns only a scalar or an immutable native String.

The full source and runtime proof is more important than the selection heuristic. Public `G`, descriptor `code`, `env`, `bound`, argument descriptors and host hooks remain observable. A new graph must still have exact source provenance, complete dependency coverage, admitted native boundaries and the same fresh public-entry guards. Unknown calls, function values, mutable ownership or unsupported layouts must retain the ordinary backend.

## First experiment: monomorphic source aliases

The isolated patch is based on frozen `source-worker11` and modifies only `jpure.bend`:

1. Keep the existing erased-call profitability condition. Also consider an exact saturated call to a positive-arity source definition, with the existing maximum of 32 callee parameters. Reuse the same bounded 2,048-node scan.
2. Let a successful collector provide source-alias rows even when it has no contextual specialization rows. The collector is seeded with the root, so the alias graph remains nonempty.
3. Keep positive root arity 1–8, scalar public arguments, scalar/String public result, source/row caps, collector fuel, exact alias reconstruction, complete JPure proof, coverage audit, worker lowering, host guards and generic fallback unchanged.

Literal and primitive-only leaves do not qualify for the new condition. Nullary roots remain excluded; this does not revive the rejected nullary-worker experiment. The scan only decides whether to attempt analysis. It is not a new purity or representation proof. A recursive monomorphic helper qualifies because its self-call is a source edge; a source wrapper qualifies only if the full downstream graph succeeds.

The supported host domain is the existing [standard-intrinsics-at-initialization contract](../../docs/PHASE42_GENERATED_JS.md#runtime-boundaries-and-maintenance), also stated in the selfhost architecture guide. Supported post-import mutations must still select fallback, and are part of qualification. This admission change can alter how often whole-graph versus individual-helper guards execute. It therefore does **not** prove equivalence for arbitrary callbacks installed in host intrinsics before import: a pre-import `Array.prototype.every` shim could observe changed dependency-check counts. Keeping guard code unchanged does not eliminate that limitation. The broader preservation requirement that stopped P45-007/P45-012 would also block claiming unrestricted host equivalence for this experiment. No new narrower host assumption is introduced here; no broader equivalence is claimed.

The patch and its source hashes are in `selfhost/build/phase45/alias-frontier-patch01/`. No maintained source is changed by constructing the experiment.

### Representative targets and possible blockers

| Program | Why it is a plausible target | What can still prevent admission or improvement |
| --- | --- | --- |
| Raytrace and active raytrace | Public arguments/results are scalar. The execution graph is first-order, with closed `Sph`/`Hit` records, F32 arithmetic and recursive row/column traversal. Record intermediates can remain private. | Graph/fuel/arity limits or an unsupported native can still refuse it. F32 rounding and operation order must remain exact. Algorithmic and allocation costs remain after dispatch is removed. |
| Unicode split/join | Scalar input root returns native String and calls recursive first-order helpers with closed list/tuple intermediates. | Downstream generic helpers, native boundaries or graph limits may refuse it. String concatenation and slicing can dominate even after successful admission. |
| Renamed scalar helper cycles | They exercise the general source-alias path without any benchmark-specific syntax. | Complete JPure and exact saturation remain mandatory. Mutation must refuse private entry. |

The estimated gain is deliberately broad: **1.5–5× on an activated dispatch-heavy target is plausible**, with a possibility of no gain or regression. This is not an estimate for all programs or the corpus geometric mean. The code change is small; compilation and measurement are the expensive steps. A short activation/value/mutation screen should decide whether to spend a full validation run on it.

### Compile cost and duplication risk

Each eligible public definition can own a private copy of its reachable graph. Opening monomorphic roots may multiply proof work, emitted code, parse/JIT cost and retained memory. Skipping primitive/literal leaves reduces gratuitous fanout but does not solve overlapping graphs. Existing caps are safety limits, not a profitability policy.

Record compiler wall time and maximum memory, generated module bytes, private root count, total private functions, and largest native/machine function for each selected source. Compare them with frozen worker11. Stop expanding the test set if compilation or output size grows sharply without corresponding activation and runtime benefit. Do not respond by raising analysis caps. A subsequent shared graph analysis cache or shared private declaration plan needs an explicit source identity and mutation-boundary design; it must not reuse stale runtime guards across entries.

### Fast qualification order

1. Build the isolated candidate once. First check renamed monomorphic recursion, a primitive-only leaf, a literal-only leaf and an unsupported higher-order/array graph. Count actual private entries separately from semantic equality.
2. Check exact argument order, parallel lets, non-tail deep recursion, F32 rounding, String values and Number-Nat boundaries. Run mutation/reentry controls against a newly admitted source helper, including `G` replacement, `code`/`env`/`bound` accessors, `.call`, raw ungranted entry and oversaturation.
3. Acquire the existing raytrace and Unicode sources. Record admission/refusal and code/compile costs before timing. Use the same saved modules, pinned TypeScript baseline and serial paired measurement protocol as the existing benchmark.
4. Screen a few existing representative points. Only promote a real improvement to the full corpus, backend boundaries and frontend qualification. Preserve unsuccessful evidence; do not silently replace a refused graph with a different benchmark.

## The next general IR pass: remove private aggregate round trips

A useful successor is constructor/projection forwarding and scalar replacement of a nonescaping, single-constructor aggregate. For example, a private helper can construct a record only for its caller to immediately test and extract its fields. After bounded inlining of a small acyclic helper, the IR can reuse the already evaluated field slots and remove the now-unobservable allocation.

This needs def-use/escape information. Every field expression must remain evaluated once in its original order, including fields not ultimately read. A record returned, stored in another escaping record, passed to an unknown/native boundary, or observed through identity cannot be removed. Branch joins require compatible field facts; recursion should not trigger unbounded inlining. The proof belongs to the private typed IR, so public descriptor observations remain at the existing entry boundary.

A rough implementation allowance is 150–300 lines plus targeted controls if the first pass is deliberately local. A **1.1–1.5× gain in allocation-heavy eligible loops** is plausible, but zero gain is equally possible where scalar replacement already occurs in V8. Allocation profiles and emitted before/after code should establish the opportunity first. General array state forwarding is a separate, larger extension.

## Why public composite results are not the first step

An owned composite result boundary would admit more public APIs, but it does not explain why scalar-result raytrace is excluded. Its records already stay inside the graph. It also does not by itself admit the generic row program: that program threads `Array<U32>` values inside a `Type` record and depends on array ownership/effects, which JPure currently rejects.

A correct result adapter must reconstruct the public typed layout while preserving shared aliases. A per-call memo maps each private object to exactly one public object; a fresh memo for every root call preserves freshness across calls. Reconstruction should be iterative for deep values, restore native tuple/constructor layouts and convert Number-Nat fields back to BigInt. It must refuse unknown or externally supplied objects and mutable handles until their ownership semantics are proved. Recursively copying each occurrence independently would change aliases and is not sufficient.

This adds O(reachable result size) work and allocation. It may enable substantial computation behind a small result, but can regress output-heavy functions. A first closed-data-only implementation is roughly 300–600 lines plus alias/freshness/depth controls; an estimated **0.8–3× change on newly admitted functions** is uncertain and excludes arrays. For the generic row frontier, prioritize typed owned-array operations and state forwarding before a broad export adapter.

## Closure specialization is a distinct architectural extension

The closure fixtures construct and compose functions, capture environments and store functions in records. The worker currently rejects function-valued arguments/results, partial applications and computed callees. A general solution needs closure conversion, explicit code/environment layouts, finite target-set analysis and exact saturation/demand boundaries. Escaping closures need public adapters; mutable descriptor observations and host callbacks cannot be skipped by ordinary unguarded beta reduction.

A guarded private graph could defunctionalize a proved finite set of local closures. Start with a nonescaping local lambda and a single exact call, then captured lambdas, then bounded target sets. Unknown functions and escaping descriptors retain the public ABI. This is likely 500–1,200+ lines and substantially more validation than source-alias admission. Gains of **1.5–5× on currently generic closure-heavy graphs** are conceivable; the existing closure benchmark is partly optimized already (Phase44 includes a point faster than TypeScript), so its gain cannot be assumed to represent the wider frontier.

The order is therefore: test the existing graph machinery on ordinary monomorphic programs, measure private allocation costs, add a small composable aggregate pass if justified, then extend ownership or closure semantics where the corpus demonstrates a gap. The goal is a larger proved program class with reusable optimizations, not more source-pattern recognizers.
