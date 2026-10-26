# Phase142: native warm-edit context findings

The strongest new lead is repeated linear name membership in the warm frontend.
The backend is substantially more distributed: structural comparisons, verifier
lookups, constructor queries and reclamation all remain visible. This supports
small algorithmic replacements before another broad cache or trust boundary.
These are profile observations and experiment priorities, not measured candidate
speedups.

## Workload and evidence quality

The diagnostic relinks the exact Phase141 N2 object with the established context
runtime, then runs one cold seed and the frozen late product-policy edit. Both
complete QBE products match their independent references. The compiler source is
`phase141/integrated-source02/compiler.bend`, SHA256 `f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`;
the compiled workload is the Phase137 compiler source and its Phase140 edit.

Evidence: [capture](../../selfhost/build/phase142/native-context01/report.json),
[summary](../../selfhost/build/phase142/native-context-plan01/analysis/summary.json),
[paired attribution](../../selfhost/build/phase142/native-context-plan01/analysis/attribution.json),
[generic-profiler adapter](../../selfhost/build/phase142/native-context-plan01/analysis/report.json).
The native process took 495.940s; capture plus transport took 509.042s. There are
24,594 samples, zero reported loss, plausible timer delivery, 99.44% main-thread
CPU coverage and 96.02% physical symbol resolution. The 979 unresolved samples
remain in denominators.

These are **diagnostic**, not clean timings. The context runtime differs from the
retained clean runtime. Context records identify the current dispatch owner;
synchronous private calls can retain an outer owner. There is no inclusive Bend
call stack or physical caller capture. The ELF/FID pointer mapping is checked,
but lexical ownership remains conditional on the emitter contract; the generic
receipt explicitly does not claim independently verified producer provenance.

Samples have CPU ordinals, not exact stage timestamps. The analyzer subtracts
all unassigned wall time (3.646s), wall-minus-main-CPU time (3.789s), and margins
to obtain conservative stage interiors. Interior distributions need not represent
the omitted stage edges. Owner and physical-leaf percentages overlap; never add
them or treat owner-prefix buckets as inclusive stage costs.

## Warm-stage observations

| Stage | Reported diagnostic time | Interior samples | Main observations within that interior |
| --- | ---: | ---: | --- |
| Frontend | 32.630s | 1,159 | `has_name` 42.6%; `constructor_exists` 11.1%; `norm_exact_head` 8.2% |
| Raw preparation | 14.255s | 240 | `norm_exact_head` 42.5%; `f_fresh_prefix_exact_terms` 19.6%; only 4.82s of conservative interior |
| Backend | 45.385s | 1,796 | `norm_exact_head` 10.3%; `p111v_get` 8.1%; exact-term comparison 7.7%; `nc_ctor_owned` 6.7%; `nol_scalar_specs` 5.7% |
| Registry | 11.277s | 91 | Structural and string comparisons visible; 1.84s interior is too small for a strong whole-stage estimate |
| Render/close | 7.682s | None | No conservative interior; no stage attribution claim |

The five warm timers total 111.229s. In the frontend interior, borrowed string
equality accounts for 400 physical samples (34.5%), consistent with the 494
active-`has_name` samples. This does not identify which caller contributes each
membership check. In the backend, `term_drop` and `span_fade` jointly account
for 539/1,796 samples (30.0%). Their active owners include scalar-schema
discovery, verifier lookup, exact comparison and constructor ownership lookup.
That locates executing work, not the origin of every allocation or an entirely
removable 30% budget.

## Source-connected priorities

Source references below refer to the exact selected source above, not a changed
candidate. Line numbers are stable in that pinned artifact.

1. **Index visited names in specific graph walks.** `has_name` at line5817
   compares strings while scanning a list. `kr_visit` at7543 tests a growing
   `seen`; `jl_visit` at17142 tests both `seen` and `stops`. These are concrete
   candidates for the existing collision-safe name index. Keep the original
   ordered result list separately for reachability: `kr_visit_def` at7550 adds
   resolved names, including observable duplicates. Preserve the layout sentinel
   before membership checks, traversal/error order, missing-name behavior,
   constructor-parent resolution, stop behavior and exact hash-collision lookup.
   First compare each consumer independently, then their combination, against
   complete products and the same native warm edit. The profile alone cannot
   assign all `has_name` samples to either consumer. `kr_filter` at7539 is
   already indexed, and the earlier report-name deduplication was already fixed;
   neither should be counted as a new saving.
2. **Reuse constructor lookup information at a real preparation boundary.**
   `constructor_exists` at8928 scans definitions/children; `nc_ctor_owned` at30589
   scans ADTs and returns the first matching constructor's ownership. Together
   these affect separate measured frontend/backend work. A cheap discriminator
   should preserve ordered first-match semantics, BookCache exclusion, child
   namespaces and current-book identity before introducing a shared index.
3. **Reduce repeated structural comparison and its destruction cost.**
   Exact-head/term comparisons occur in both raw and backend interiors. Identify
   the actual producer and consumer first, then carry exact immutable facts
   through that seam. Existing reuse prototypes show why a high hit rate is
   insufficient: admission comparison and reclamation can consume the saving.
4. **Investigate verifier lookup and scalar-schema construction separately.**
   `p111v_get` and `nol_scalar_specs` have meaningful backend samples. The latter
   (line36205) constructs a type while traversing definitions. Establish which
   work can disappear without weakening error order, ownership or final checks.
   The evidence does not support removing the entire 45s backend through one
   cached verdict. Registry and render need better attribution before escalation.

No percentage above is a predicted whole-request gain. A successful local
algorithm replacement can help both cold and warm compilation; it need not
change cache invalidation or skip semantic validation.

## Why this changes the priority

The earlier witness and same-request verifier prototypes preserve products, but
have no robust broad speed result. The shared-API same-request experiment gave
Lexer +3.63% median paired full time and Map -2.57%, with order/drift disagreement;
an unchanged-path A/A comparison itself showed an apparent +5.56%. Completed-
prefix freshening gave approximately +0.71%/-2.46% full-request paired ratios on
Lexer/Map despite stronger component gains. See the retained
[request metrics](../../implementation/phase142/request-metrics01.json).

The new evidence measures substantial executing linear membership work on the
actual full native edit. It justifies testing an asymptotic improvement with
unchanged validation obligations. It does not retroactively establish a native
gain for the earlier hosted prototypes or guarantee 10× incremental builds.

## Existing native acquisition boundary

The Phase141 acquisition used qualified `phase111/p137-n3/program` to compile
the exact source above, taking 369.697s native; its N1 reproduced the same QBE.
The retained Phase141 N2 is `phase111/p141-integrated-n2/program` (SHA256
`e1350aed9ff60485f36a0fb5f5a3f8433b53ff707f81b14ccc006678d27fc20c`).
Use this fixed producer for candidate revisions; a new candidate image does not
inherit its qualification. Original recipes are
[source emission](../../selfhost/build/phase130/p141-integrated-emit01/report.json),
[self reproduction](../../selfhost/build/phase130/p141-integrated-self01/report.json)
and [N2 machine build](../../selfhost/build/phase111/p141-integrated-n2/report.json).

Run `phase130/native-request.py` with `--image` the fixed clean producer,
`--source` the current independently checked candidate, `--carrier-receipt
selfhost/build/phase130/base-carrier01/receipt.json`, a **fresh Phase130** `--out`,
and `--seconds 600`. Then run `phase123/build-aligned.py` with that emitted
`program.ssa`, a **fresh Phase111** `--out`, `--seconds 60`, and **clean** runtime
`selfhost/build/phase128/runtime-borrow01/runtime.o`
(`9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749`).
Each is separately supervised by the Phase111 guard, CPU3, 3GiB RSS, at least
16GiB available memory; neither method replaces the outer process-tree guard.
The builder retains QBE1.3, GNU as branch-boundary alignment, and the existing
GCC linker flags; the historical machine build cost was 15.17s.

Do not link the context runtime into clean measurements. Preserve the installed
selection, qualify the new image's outputs independently, and pay for native
self-reproduction/broad qualification only when the bounded native result
justifies adoption. No target executions were performed for this synthesis.
