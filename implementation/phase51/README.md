# Phase51: V8-guided guard and application changes

**Phase51 is installed and release-verified; all 42 ordinary/relocated CLI checks
pass.** The compiler combines a small IO helper with reuse of an already-completed
String check within a single contextual entry. The full comparison passes all
669 samples across 45 points and 23 source programs.

| Geometric weighting | Fresh RNFA04 / TypeScript | Phase51 / TypeScript | Speedup |
| --- | ---: | ---: | ---: |
| Equal point | 3.007942× | **2.927825×** | **1.027364×** |
| Equal source | 4.077637× | 3.929390× | 1.037728× |
| Equal family | 4.364108× | 4.206544× | 1.037457× |

This is **2.66% less execution time**, a 2.74% speedup by equal point. It is a
modest improvement, not parity. Unicode16/64 improve 1.242×/1.083×; Map churn32
improves 1.061×. Thirty-four point medians improve and 11 regress. The largest
regression is tree-bitonic, 2.65%, followed by the large fold variation, 2.04%.
All medians, regressions and drift appear in the [complete results](results.md).

Evening's 1.460× standard-protocol gain contributes 31.1% of the net logarithmic
gain; the other 44 points collectively improve 1.0192×. With 32,768 fixed-work
warmup calls, the isolated IO change improves Evening only 1.0477×. Its sampled
allocation is effectively unchanged: 177,349→177,524 bytes/call. These observations
support improved dispatch/inlining behavior, not an allocation-removal claim.

The historical RNFA04 ratio was 2.678937×. Its **unchanged output** measures
3.007942× in this fresh comparison, so this phase does not claim a new absolute
record against that historical number. Warmup/tiering and substantial drift are
observed; their contribution to the entire cross-campaign shift is not isolated.
The controlled improvement uses the freshly paired baseline above. This maintained
corpus informed development; it is not an untouched holdout or typical-program
guarantee. The full three-batch comparison took 19m03s, excluding compilation.

The [design](../../design/phase51/v8-guided-runtime.md) was committed and pushed
before target execution. Independent agents prepared guard and dispatch
experiments, semantic review and qualification commands. Root alone executes
resource-limited targets; saved outputs avoid a compiler build for each idea.

| Experiment | Finding | Decision |
| --- | --- | --- |
| Batched String descriptors | Equivalent mutation behavior, but slower on RLE and Unicode. | Reject. |
| Four extracted application branches | `apply` inlines, but useful `force` inlining is displaced; timings are mixed. | Do not select. |
| Four branches plus exact-call split | Added structure does not consistently beat the smaller alternative. | Do not select. |
| Only extract the IO branch | 27 differential controls pass; fixed-work Evening improves 1.0477× after 32,768 warmup calls. | Installed. |
| Same-entry String proof | 33 boundary observations pass; five of six screened points improve, with a small record-256 screen regression retained. | Installed. |

The [guard report](guards.md), [dispatch report](dispatch.md) and
[static review](review.md) preserve the negative results, exact input identities,
protocols and caveats. The [runtime guide](../../docs/self_hosted/v8-guided-runtime.md)
explains the production proof boundary and maintenance obligations.

The largest apparent dispatch gain was warmup-sensitive: Evening's 1.55× result
under the one-second protocol became 1.0477× under fixed-work warmup. The latter
driver does not measure within-window drift. Neither number alone establishes
whole-corpus speed, a general steady-state gain or physical context elimination.

## Correctness and complexity

The [qualification report](qualification.md) distinguishes actual checked-output
controls from prototypes. Focused exact-entry/nullary/array controls and all eight
maintained suites pass. The backend census resolves to **69 execution passes,
eight N/A and four shared failures** across 81 outcomes. A sandbox Clang refusal
required retrying only the native batch; the first failed run remains preserved.
The existing full frontend inventory remains historical. No new fixed point,
full native/GPU conformance or universal host-equivalence proof is claimed.

[Source accounting](accounting.md): Bend code lines and definitions are unchanged
at 19,489 and 2,673. Two proof-comment lines bring physical Bend lines to 23,662.
The authoritative JavaScript runtime adds six lines/304 bytes: one helper and
one private identity. There is no new compiler pass, source-name recognizer or
permission cache across calls. Compiler throughput was not newly benchmarked.

## Usable version and evidence

API: `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061`.
Runtime: `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
Assembled source: `95a6656f37047ccbe83ce2b72be92b23995d466670c1f4d562f3367c9901b66c`.
The pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.

The [release manifest](../../selfhost/dist/release.json),
[selected qualification](../../selfhost/tools/performance/phase51/evidence/selected-qualification.json)
and [closed raw archive](../../selfhost/tools/performance/phase51/evidence/raw/archive.json)
bind the installed image, successes, rejected experiments and failures.
The [portable benchmark guide](../../selfhost/tools/performance/phase51/README.md)
provides 20/60/300-second selections and full batches. The packaged replay passes
27 fresh samples across three points; it checks the published artifacts rather
than supplying a second full performance claim.

See [time accounting](time-use.md) for execution occupancy versus elapsed phase
time. All 103 pre-existing unrelated files remain unchanged. No PR comment was
posted. Design and implementation checkpoints were pushed as `a79c114` and
`109247e`; the final publication commits contain the release and complete report.

## What this changes about the next experiment

Use V8 evidence to choose a small falsifiable change, but require clean timing and
boundary controls: descriptor batching lost, and aggressive splitting displaced
useful inlining. The smallest implementation won. Larger gains still require
reducing genuinely necessary guard work or generic closure/constructor transport.
The allocation bottleneck remains; another helper split alone is unlikely to
remove it. Start those experiments on saved output, as here, before rebuilding.
