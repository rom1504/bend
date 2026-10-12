# Phase70: compilation baseline and avoidable work

The native emitter is the largest measured compiler stage. In diagnostic requests
from the released Phase69 compiler it occupies 56–61% of B2 request time and 68%
of the sampled B1 numeric request. The immediate opportunity is to stop redundant
analysis and term rebuilding inside that emitter. Program execution is a separate
metric: the existing six-family C executable suite was already at 1.0332× upstream
in Phase69; that result does not imply that the compiler itself runs at parity.

This report is a source/data analysis. It does not claim a Phase70 speedup.

## Identity and scope

The baseline is the released, checked Phase69 `typed-build10` compiler:

- B1 API SHA256: `674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553`.
- Genuine B2 API: `c858dfa5424c534444a2b733c0336a7009fc260da272d64c52f33a188d3f066e`.
- Pinned upstream: `059266225b77c8ca256ac6b25ee5c21449bab151`.
- New diagnostic plan: `selfhost/build/phase70/compiler69-profile02/plan.json`,
  SHA256 `1f9ac7dba7a51ba02ec1ec7e346cab22c84ded32f88a6f73d0d7b5ca5a334fa3`.
- Its analysis: `compiler69-profile02-summary.json`,
  SHA256 `c7e513c92bfc3655f47f0092cfa5c09d43622df9be0a358c8f2ce256429c877e`.
- Additional data-only family unions: `compiler69-profile02-families.json`,
  SHA256 `925fc546d8e3474397cdbe630c41af171c6cadeffa7385203717cd4f7df41248`.

The compiler images execute as JavaScript and emit C; Clang then builds the C
programs. These requests measure checked C generation. They exclude Clang and the
resulting executable's runtime. Each image owns a freshly prepared Base cache;
imports and explicit preparation have separate clocks. TypeScript's normal
`book_load` includes Base checking within its request. Every emitted C byte must
match the previously validated Phase69 acquisition. No weaker output oracle was
introduced for these profiles.

The installed B1 image was verified against the frozen API, but workers consume
the immutable frozen API. The new diagnostic campaign completed both preparations
and all four profiles. It intentionally contains no clean timing requests.

## Clean comparison, from the separate Phase69 campaign

The following are medians of three position-balanced rounds in
`selfhost/build/phase69/typed10-compilation01-summary.json`. All 27 clean requests
and both preparation jobs passed; that whole plan's `complete: false` is solely
because its four optional profile jobs were deliberately omitted. New Phase70
instrumented times must not be substituted for these medians.

| Workload | B1 request ms | B2 request ms | Upstream request ms | B1/upstream | B2/upstream |
|---|---:|---:|---:|---:|---:|
| numeric | 2267.99 | 1548.85 | 712.73 | 3.182× | 2.173× |
| array | 2339.85 | 1559.32 | 716.26 | 3.267× | 2.177× |
| lexer | 2873.31 | 1945.91 | 885.35 | 3.245× | 2.198× |
| Geometric mean ratio | | | | **3.231×** | **2.183×** |

This is a three-workload compiler-speed sample, not a language-wide compilation
or execution guarantee. B2's lower cost also shows that B1's descriptor/runtime
representation matters; optimizing source work can benefit both images, but
removing a B1 runtime frame is not automatically a B2 optimization.

## Where the diagnostic time goes

| Diagnostic request | Request ms | `nc_compile_checked` ms | Emitter share | Type checking ms |
|---|---:|---:|---:|---:|
| B2 numeric | 1680.45 | 994.81 | 59.2% | 53.79 |
| B2 array | 1720.79 | 1051.32 | 61.1% | 71.26 |
| B2 lexer | 2181.86 | 1211.79 | 55.5% | 139.04 |
| B1 numeric | 2527.22 | 1725.49 | 68.3% | 51.87 |

These stage clocks instrument the actual public entry used by the driver. A
source preflight found that the inherited worker only wrapped `nc_compile`, while
the released driver calls `nc_compile_checked`. Internal calls do not necessarily
re-enter an exported wrapper. The initial `compiler69-profile01` plan was therefore
left unexecuted. The exact corrected successor adds the checked entry and requires
whichever entry the API exposes; its derivation is recorded in
`selfhost/tools/performance/phase70/methods/profile-entry-upgrade.json`.

V8 sampling identifies `bridge.bend`, `term.bend`, `index.bend`, normalization,
product lowering, emission and erasure among the largest recognized source
owners. There is substantial host/runtime/unattributed time. B1 numeric has
857.5 ms of anonymous leaf samples, 463.5 ms in `run_loop`, and 270.7 ms of GC leaf
samples. These are diagnostic samples, not separately measured optimizations or
budgets to add to source-owner totals. Inlining and descriptor names prevent an
exact source decomposition.

For a more targeted bound, `methods/profile-families.py` walks each saved sample's
ancestor chain and counts it at most once per function-name family:

| Inclusive sampled family, ms | B2 numeric | B2 array | B2 lexer | B1 numeric |
|---|---:|---:|---:|---:|
| `nc_uses*` membership summaries | 151.220 | 138.386 | 149.858 | 395.500 |
| `nq_uses*` / `nq_min_uses*` product counts | 57.540 | 63.174 | 64.976 | 89.934 |
| `ne_template*` output assembly | 69.264 | 76.657 | 85.558 | 71.813 |
| `nc_erase*` erasure | 132.634 | 129.046 | 148.657 | 186.920 |
| `norm_*` / `wnf` normalization | 175.245 | 171.857 | 215.639 | 143.355 |
| `index_*` index operations | 168.397 | 151.936 | 188.887 | 81.781 |

Families overlap: index work can be inside occurrence work, for example. Never
sum this table or add it to stage clocks. It is sampled attribution, not exact
call counting, and one profile per source/image is insufficient for precision.

## Ranked proposals

### 1. Skip product-demand scans when admission has already failed

`nq_bind_choose` in `src/back/native/product.bend` computes product shape, maximum
uses and minimum uses in one `&&` expression. Bend's eager Boolean arguments mean
both full-body count traversals still execute when the value has no product shape,
or when maximum use has already rejected it. Three explicit `nt_choose` branches
preserve the decision while skipping the unused traversals.

The source-only proposal is `tools/performance/phase70/product-demand/lazy-v1.patch`:
four added physical lines, no new definitions or representation. Independent
review confirmed pure bounded-count traversal and identical success/fallback
arguments. This differs from Phase68 Facts23, which fixed eager evaluation in
`ns_unshared_terms`; it is another concrete consumer, not a rerun of that patch.

A first estimate is 1–3% of whole B2 compilation, with a similar order of gain in
B1, for roughly 30–60 minutes of implementation and a short paired validation.
This is a hypothesis: the entire sampled product-count family is only about
3–4% of the request, and some admitted cases must still execute it. A much larger
claim would require new evidence. Full emitted-C equality and existing
missing/duplicate/minimum-use controls are stronger gates than runtime timing
alone for this transformation.

### 2. Reuse the already compact prepared definition

Phase69 `ns_defs` prepares every ordinary reachable definition, not only static
constants: it compacts the erased definition, applies static-term conversion, and
stores `NativeStaticBody`. Scheduler, ordinary-worker and product-worker consumers
can retrieve that body and immediately compact it again. A small fact-aware
accessor could return the prepared body while preserving the complete old path
for absent, foreign, intrinsic and unprepared definitions.

This is P70-005, owned by the independent compiler-work source lane. It is not a
proposal to add an erased-definition cache—that cache already exists. It must
first prove the restricted fixed-point property of the actual prepared producer;
arbitrary `nc_compact` idempotence must not be assumed. Raw malformed terms, fresh
IDs, forged/stale request facts and original foreign metadata are explicit
boundaries. The proposed helper controls compare whole terms to the old expression.

Implementation is small (about 5–8 lines plus three consumers); a 30–90 minute
prototype/control loop is reasonable. A subsequent hash-verified reduction in
`compiler-work/profile-work-v2.json` isolates complete `nc_compact` stack unions
of 17.138/17.344/20.308 ms for B2 numeric/array/lexer: about 1% of each captured
profile. Mandatory first compaction consumes most of this budget; removable
consumers account for only about 5–6 ms. Revise the screening estimate to 0–1%,
likely below 0.5% of whole B2 requests, not a measured gain. Parent-owned
integration combines P70-004 and P70-005; any measured gain from that build must
be attributed to the combination unless an ablation is actually run.

### 3. Share occurrence analysis across overlapping subtrees and let suffixes

Phase68 Uses08 removed the multiplicative per-environment lookup scan. Reuse11
then reused an already computed summary within several individual lowering calls.
The current emitter still repeatedly visits overlapping subtrees:
`nc_lower_to` prepares the environment of each recursive term, and local-let
lowering repeatedly constructs a suffix and summarizes its body. A transient
bottom-up analysis tree or suffix summary could carry that work forward once.

This is a larger architectural opportunity rather than another local variable
reuse. The measured occurrence-family budget is around 7–9% of B2 request samples
and 15.5% of B1 numeric. A plausible prototype target is 4–8% B2 / 8–15% B1 request
reduction, taking 2–4 hours; these are estimates bounded by overlapping samples,
not promised gains. This proposal should follow the cheaper admission/compaction
screens. Avoid introducing a persistent cache or a second term representation
without demonstrating a worthwhile reduction in repeated traversal.

Correctness must preserve full U32 variable IDs, ordered duplicate environment
rows, `Var` as a leaf even with malformed children, exact first-error behavior and
fresh-ID allocation. Product substitution changes the body: an old summary cannot
be attached to a newly substituted term. The existing Reuse11 report explicitly
left that case separate for this reason.

## Reserve opportunity and iteration rules

Output assembly remains measurable. The existing emitter already has a runtime
marker splitter and fallback; replacing the older sequential four-fill algorithm
again would be stale advice. A new request-local presegmented runtime template or
structured generated payload could avoid repeated scanning of roughly 83 KB of
runtime and repeated payload marker checks. The observed family gives an
approximate 2–4% B2 target for a 1–2 hour prototype. It must preserve arbitrary
runtime-text fallback and exact bytes, including the 32 established template
helper cases. This is lower priority than changes requiring no new representation.

The source-only B1 paired preparer (`methods/prepare-b1-pair-v2.py`) reuses the
existing exact-C worker and serial guarded runner. It accepts a newly checked B1
attempt without requiring a fresh B2: two fresh Base preparations, two alternating
rounds over numeric/array/lexer, and one separate candidate numeric profile. Each
clean role emits exactly the retained Phase69 C. Its two samples per cell are a
fast screen, not a final precision claim. Target work remains root-owned and
serial on CPU3; source/data lanes use CPU0. Keep profile, compilation, Clang and
native-runtime clocks separate. Only surviving changes need genuine B2 generation
and the larger conformance/release gates.

Prior references:
[occurrence summary](../phase68/occurrence-summary.md),
[occurrence reuse](../phase68/occurrence-reuse.md), and
[native facts and calls](../phase68/native-facts-and-calls.md).
