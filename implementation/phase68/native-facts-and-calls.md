# Native facts, ordinary fallback and the foreign callback gap

[Design](../../design/phase68/native-facts-and-calls.md) ·
[P68-019](../../experiments/phase68/P68-019-native-facts-and-runtime-ids.md) ·
[P68-020](../../experiments/phase68/P68-020-native-representation-and-calls.md) ·
[P68-021](../../experiments/phase68/P68-021-optional-product-fallback.md).

Selected source checkpoint: `b2ec0a2`, checked compiler23. Upstream stays pinned
to `059266225b77c8ca256ac6b25ee5c21449bab151`. This is still the compiler written
in Bend: B1 and genuine B2 are JavaScript compiler images that emit C; Clang then
builds the native programs. Program runtime, compiler requests and Clang time
are different measurements.

## Results and scope

The known foreign callback gap is fixed: **37/37 selected native integration
cases pass**, previously 36/37. The compilation ownership scan is much cheaper.
Alternating old/new measurements show **8.3% less B1 compilation time and
5.4% less B2 compilation time** on the three-program C-emission set.
The generated-program gain is small: the lexer improves about 2–3%; the other
five benchmark families emit exactly the previous C. This round does not reach
runtime or compilation parity.

The new six-family runtime geometric mean is **1.724× upstream C**. Do not
attribute its whole difference from the previous 1.745× result to this change:
unchanged programs moved too. Numeric/array remain approximately at parity;
tree, lexer, Map and closure allocation/transport remain the larger gaps.

Three balanced rotations, identical work/source/Clang recipe, CPU3, one native
thread, GPU off. All 54 observations pass independent checksums and the 100 ms
clock floor. Medians in milliseconds:

| Family | Compiler20 | Compiler23 | Upstream C |23 / upstream| C unchanged20→23 |
|---|---:|---:|---:|---:|---|
| Numeric |251|251|253|0.992×|yes|
| Array |169|169|168|1.006×|yes|
| Closures |398|398|223|1.785×|yes|
| Tree |711|658|211|3.118×|yes|
| Map |782|777|435|1.786×|yes|
| Lexer |612|598|226|2.646×|no|

The earlier lexer-only screen independently observed 565→549ms versus 208 ms
upstream. Both screens show a modest improvement, not a large general speedup.
The apparent tree timing gain cannot be credited to compiler optimization.

## What changed

1. **Avoid eager analysis.** `Bool.or`/`Bool.and` evaluate their arguments.
   Reordering operands in compiler21 therefore did not avoid `nq_uses` scanning
   the whole function. The generated B1 confirmed it even scanned for
   non-variable nodes. Explicit `nt_choose` branches now skip these scans for
   non-variables and proven array-free values, and stop after a failed proof.
   Unknown variables retain the same saturated, branch-aware use count. This
   avoids adding a use-summary map or another analysis representation.
2. **Keep ordinary worker fallback.** The lexer had a valid ordinary worker
   whose dependencies included a rejected product worker. Its String match's
   raw impossible branch prevents the existing parameter-demand proof. We did
   not declare those tag tests exhaustive. Instead, preserve admitted workers,
   remove unavailable product call signatures and retry dependency-blocked
   ordinary workers once. The existing boxed ABI, tail-self goto loop and
   acyclic dependency admission then apply. Candidates with lowering errors
   remain rejected. No new scheduler context or C recursion scheme was added.
3. **Resolve the runtime FID.** `FID(Clo~apply)` is a reserved runtime closure
   dispatcher, rendered as `BEND_CLO_APPLY`; it need not be a source definition.
   Namespace precedence, other IDs, unknown-name errors and lexical shields
   keep their previous behavior.

An independent source review found no ownership, stack or semantic blocker.
The initial admitted set remains valid because those bodies are preserved;
the second dependency pass still rejects new mutual recursion cycles. Device
fallback bodies are retained; this is not a fresh physical GPU validation.

## Compilation speed

Twenty-seven clean requests compare three sources × B1/B2/upstream × three
balanced rotations. Every request reproduces its complete qualified C oracle.
Base preparation is explicit and outside the request. Imports/API loading and
Clang are also excluded; these are not CLI timings or the 45-program JS corpus.

| Source | B1 request ms | B2 request ms | Upstream TS ms |
|---|---:|---:|---:|
| Numeric |2602|1721|725|
| Array |2489|1711|781|
| Lexer |3048|2051|895|

Geometric ratios: **3.389× B1**, **2.284× B2**. Compiler20's earlier corresponding
ratios were 3.713×/2.387×; compiler21's intervening no-op reorder screen gave
3.660×/2.359×. Those separate campaigns alone do not establish the size of the
speedup, so a fresh alternating20/23 comparison is recorded separately below.

That comparison completes **48 exact-C requests**: three programs, two image
stages, two compiler versions and four alternating rounds. Its geometric
new/old request ratios are **0.91665 B1 (8.3% less time)** and
**0.94589 B2 (5.4% less time)**. All six source/stage medians improve. This is
the direct improvement estimate; the upstream ratios above come from the
separate upstream-resolved campaign.

| Source | B1 old→new ms | B2 old→new ms |
|---|---:|---:|
| Numeric |2562→2379|1657→1556|
| Array |2796→2489|1671→1581|
| Lexer |3274→3050|2076→1978|

Four diagnostic profiles are separate from clean clocks. B2 inclusive sampled
time in `ns_unshared_terms` falls from 162/168/170 ms to 21/20/26 ms for numeric,
array and lexer. The new retry traversal contributes roughly 18–24 ms inclusive;
its cost is included in every final request. Inclusive samples overlap and are
not additive stage accounting. B1's trampoline obscures the same function-level
attribution, so its tiny named samples are not treated as the full scan cost.

## Correctness and simplicity

- Checked B1, strict 36 focused frontend comparisons, 37 paired native cases:
  all pass. The original failing callback now passes in the actual native gate.
- 23 new query controls cover old/new ownership decisions, duplicate arrays,
  branch maxima, unknown types, bare variables, foreign namespaces, unknown IDs,
  quoted/comment shields and runtime-ID emission.
- 12 raw API controls pass for first errors, unused/mistyped products, ownership
  and sequential/nonsequential polling. The unchanged product-demand refusal
  remains part of the boundary.
- 2,991 generated functions reachable from exported non-native roots are exact.
  Only `kf_known` changes there, covered by the foreign controls. Runtime and
  export wrappers are exact. This is source closure evidence, not a rerun of
  every historical JS test.
- Genuine B2 generation and 8 sampled ordinary-driver observations pass. Final
  numeric/array/lexer B1/B2 requests emit equal C. Full-source self-check/B3
  reproduction and installed-release qualification were not rerun.

Compiler20→23 adds **27 physical /21 code Bend lines**, no module: 29,794→29,821
physical lines, 24,403→24,424 nonblank/noncomment lines, 120 modules. Four existing
compiler modules change; the native runtime and host are unchanged. Experiment
tools and archived evidence are additional and are not included in those Bend
counts. This is a small extension, not a line-count reduction.

## Investigation and rejected paths

The saved-C counter survey uses the actual compiler20 and upstream programs.
Differences between 17 and 1 repetitions isolate 16 dynamic inputs. Instrumented
runs pass independent outputs but their times are never used as benchmarks.
For example, lexer allocation counts are 1,596,879 versus 734,878 and scheduler
entries 3,902,165 versus 913,038. Tree allocations are 640,908 versus 231,424;
closure apply entries 16,432 versus 8,224. Allocation and calling convention
differences are broader than the one admitted lexer loop.

The more invasive scheduler-to-worker call-site context was deferred after
finding the smaller optional-route failure. This round does not establish its
benefit. Next useful discriminators are direct worker calls from recursive
scheduler bodies and scalar ownership facts that avoid generic retains; neither
can be justified by simply dropping reference-count operations.

Compiler21's reordered Boolean expression is retained as a measured no-op
experiment. Compiler22 failed during bootstrap because an intermediate
`NF_Worker` constructor needed an explicit type annotation;23 fixes it. The
first paired-plan preparation was rejected during source preflight, before any
target, for an incompatible plan tag and copied cache. Its original producer
and plan remain preserved; the successor uses fresh caches and the strict
existing worker. The worker-inspection successor briefly occupied the original
tool path; original bytes were restored, and both versions plus their hash
mapping are retained. No failed/preflight attempt is counted as a passing gate.

## Delivery and preservation

The design and implementation were committed and pushed to `selfhost/bootstrap`.
No PR comment was posted. Installed Phase67 remains separately identified by
`selfhost/dist/release.json`; this report qualifies the source candidate and
explicit images, not a new installed release.

Durable [evidence](evidence/native-facts23.json) records images, all measured
observations, qualifications, profiles and the paired comparison. The
[capsule](../../selfhost/tools/performance/phase68/facts-calls/evidence/README.md)
preserves this campaign's raw outputs, including failed attempts and the native
runtime baselines. System toolchains/upstream checkout and unrelated historical
compiler receipts remain external dependencies.

One heavy CPU3 target tree ran at a time, with 1 GiB Node heap, 4 MiB stack, 2 GiB tree
RSS and 4 GiB available-memory floor. Final checked B1 peaked at 1.51 GiB; B2's largest
stage at 1.17 GiB. No OOM or disk-full event. One existing advisor provided bounded
read-only advice/review; the leader owned implementation and all target runs.

The local usage interval covers 37.4 minutes before final documentation/publication:
68,805 reported output tokens, including 3,766 from the advisor; 14,488,704 of
14,813,945 input tokens were reported cached. The observed account window rose
2 percentage points. This is advisory local telemetry, not billing or exact
per-task quota. The extra 48-request paired comparison was justified by noisy
separate campaigns; it confirmed the smaller speedup instead of inflating it.
