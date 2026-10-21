# Phase124: verified helpers compose with local continuations

Experimental checked-hosted source02 extends Phase123 with an authenticated
callable view and one explicit helper/resume operation. The installed compiler,
Phase118 qualified native chain, runtime and assembler policy are unchanged.
All405 original45 observations pass. The same-run44-point geometric runtime
ratio improves2.00033→1.92014×upstream (4.01% less). No full compiler acquisition
or native N1/N2 claim is made.

[Design](../../design/phase124/local-ready-resume.md) ·
[Reproduction](../../selfhost/tools/performance/phase124/README.md) ·
[Semantic interface](../../docs/self_hosted/local-ready-resume.md).

## New insight and removed work

The existing optimizer could recognize a local recursive region and separately
verify complete helpers, but its region planner consumed only the older ready
catalogue. It also allowed captured frames before self descent, not before a
helper that returns into the local region. Useful information existed; the
composition boundary prevented using it.

The selected Bend change adds an immutable view over both already verified
catalogues and `P114RResumeReady{frame,call,result}`. Existing direct/H/R/G successes
retain priority. The extended H attempt replaces a redundant final H attempt;
there is no new unconditional whole-program traversal or persistent cache.
Arguments are snapshotted, the original capture/frame effects remain ordered, and
the helper result enters the existing local unwind table. Original graph/private
verification, ownership operations, exact frame/arity gates and fallbacks remain.
Closed helper calls cannot reenter the owner; source recursion still uses an
explicit loop/stack. Unrelated renderers fail closed on the new node.

For original RLE, three scheduler edges disappear from the selected computation:
expand→lrepeat, continuation→expand, continuation→lconcat. Two helper public
wrappers' argument-register reads and runtime returns are bypassed. The private
closure contains zero scheduler jump/return/apply sites and no native owner
reentry. Captures, allocation, consuming takes and a frame call remain. These are
static call-path facts, not dynamic instruction counts. See
[RLE evidence](../../selfhost/tools/performance/phase124/ready-call/evidence/rle01/README.md).

Independent owned list/tree controls show the same mechanism: their old selected
regions contain3/5 scheduler jump sites; the new private regions contain zero.
Both preserve complete transformed outputs and externally observed originals at
ordinary depths4,096/2,048. The controls are not just checksums or specially
malformed native IR.

## Final broad results

Same original45 source programs,44 timed points and one zero-work sentinel; pinned
upstream products, exact original output/count oracle, three rotated observations
per role, CPU3 and unchanged fourfold batch scale. Phase123 and the candidate use
the same explicitly aligned assembler policy. Raw receipts and the full per-case
table are in [results.json](results.json).

| Diagnostic | Same-run Phase123 | Phase124 |
| --- | ---: | ---: |
| Geometric runtime / upstream | 2.00033× | **1.92014×** |
| Mean positive log-slowdown | 0.94870 | **0.90847** |
| exp(mean positive log-slowdown) | 2.58235 | **2.48052** |
| Above1.1× / above2× upstream | 40 /24 | 40 /24 |
| Sum of fixed-batch medians | 27,446ms | **26,065ms** |
| Sum of positive excess over upstream | 19,349ms | **17,969ms** |

Positive log-slowdown falls4.24%; fixed-batch time falls5.03%, positive excess7.13%.
Equal frozen-family weighting gives0.96432×parent and1.97879×upstream. Those22
family labels are historical strata, not22 independent algorithm lineages or a
model of real-world program prevalence. exp(L) is a diagnostic, not measured
geometric runtime. Descriptive per-round candidate/parent ratios are0.95521,
0.95507 and0.95841; three observations do not establish a population confidence
interval. The median-based aggregate is0.95991×parent.

Broad RLE improves22.82%, the three generate-and-lex inputs34.49–37.13%, and two
Unicode-text inputs3.59–3.87%. The largest regression is1.29% on
coverage-record-aggregation-64. Expression128 improves3.05% without a new
application region; do not attribute that to the new mechanism without further
evidence. Trees, maps, scalar programs and most other points stay near neutral.

The static census has96 additional local workers across45 files:90 are repeated
String.cmp.fin/String.order library workers; six are application workers (three
lexical generators, two text repeaters and RLE expand). Emitted workers are not
proof of hotness. QBE text grows39,460,096→39,698,679 bytes (0.605%).

Final-source alias/depth controls pass. Source01→source02 and fast→broad bytes are
explicitly bridged for measured cases; no hidden test-only optimization is selected.
The17 finite predicates and independent ordinary outputs are bounded validation,
not a proof of whole-compiler correctness or full-language conformance.

## Focused results and attribution

The original-source four-case screen passes36 output/count observations. Median
RLE time falls1563→1212ms (22.46% less); lexer835→560ms (32.93% less). Tree-bitonic
959→946ms and map-churn727→720ms are near-neutral. These are diagnostic subset
results; their4.17×upstream geometric ratio is not the broad corpus score.

The lexing core's QBE is unchanged. The new local region optimizes `gen`, which
constructs source text inside each frozen timed generate-and-lex iteration.
Therefore this is a workload improvement, not a claim of32.9% faster tokenization
on prebuilt input. The callable-catalogue bridge and local-resume capability both
belong to this experiment; no ablation isolates their individual runtime shares.
See [exact attribution](../../selfhost/tools/performance/phase124/controls/lexer-attribution.md).

## Cost, simplicity and negative evidence

The paired hosted compiler-cost screen, with one warmup and three measured rounds
per role/case, gives0.99532×Phase123 whole prepared request time over RLE/lexer:
RLE0.96855×, lexer1.02283×. This is approximately neutral, not a compiler-speed
breakthrough. Per-role output is deterministic; final source02 output hashes match
source01 with its test-only predicates removed. This clock includes frontend,
admission, lowering, planning, verification and emission, but is not native N1/N2
execution or end-to-end cold compiler acquisition.

Selected compiler source grows52,764→52,936 lines: +172 (0.326%), +7,700 bytes.
Runtime/ABI are unchanged. Test/oracle/report/tool files are separate from that
composed compiler line count. No source-name benchmark recognizer is added.

A separate51-line overlay expands frame calls only inside authenticated local
case buffers. A global matching-name extension was rejected during design because
it would confuse spelling with provenance. The scoped prototype passes12 pure
controls and18 benchmark output observations, but RLE median improvement1.25% and
lexer2.10% are weak evidence for extra rendering logic; one RLE sample regresses.
It is **excluded** from source02. No broad or alias/depth qualification is claimed
for this rejected overlay.

The first five-case emission hit its60-second deadline after four completed cases.
Every retained input/output was rehashed before a separate explicit completed-prefix
receipt was used for the fast screen. The original batch remains failed; the
unfinished list-pipeline case was excluded. The final broad emission is fresh and
complete. An initial bare `bun` invocation also failed because it was not on PATH;
all actual executions use the pinned Bun1.4.3 binary. Neither failure is erased.

## What this means for the next optimization

The abstraction worth preserving is a verified call returning into a closed,
explicit continuation region, with ownership/argument/effect obligations separate
from target emission. It is useful now without a universal IR. Additional catalogue
search alone would not have made this optimization legal or expressible.

RLE still constructs two list spines: lrepeat builds a temporary list, and lconcat
consumes and reconstructs it before attaching the final suffix. A general
producer/consumer or destination-passing composition could eliminate this whole
category. The next cheap experiment should count constructions/takes, preserve
result order, aliases and effects, and transfer to another producer/concat
computation. Do not replace this with a named RLE recognizer or another frame-helper
micro-optimization. Opcode24 here is an identity U32.to_nat dispatch, not unary
Nat allocation; its cost must not be misdiagnosed.

The compiler's cached-book field decoder has an analogous call/result/continuation
shape, but the old short physical-leaf profile does not establish inclusive hotness
or admission. It remains an explicit follow-up, not a compiler-throughput claim.
No new native compiler image was built. Before adopting this compiler as a research
tool, qualify native self-reproduction and measure whether acquisition plus future
experiment savings pay back. This phase demonstrates useful general capability
and bounded experiment reuse, **not recursive research acceleration**.

## Research cost and retained evidence

Through20:44:11UTC, this phase used27.20min wall time, including16.96min in19
serial guarded jobs. Measured categories: checked emission9.72min, native
build/output/runtime checks4.69min, hosted compiler-cost1.83min, three checked API
acquisitions39.25s, finite controls3.21s. Two failed jobs are included: the60.05s
batch deadline and0.023s missing-PATH invocation. Four completed outputs from the
failed batch were reused, with an explicit new receipt; no failed batch was hidden.
One broad emission took465.27s and one broad native screen230.52s. No full compiler
image was acquired. Two existing agents handled bounded offline code/proof/control
work; root owned integration and the only target lane. Non-target editing, analysis
and agent work overlap; the residual10.24min is not a measurement of inference time.
Token/quota cost is unavailable and is not inferred from wall time.

Peak process-tree RSS was1.844GiB; available memory stayed above21.918GiB, with a
16GiB floor. The installed/native qualified selections were not changed.
[Accounting](accounting.json) includes all guard identities. The
[evidence capsule](evidence/summary.json) retains small receipts, ordinary outputs,
failures, copied methods and machine excerpts, and verifies every archived payload.
Large compiler/API/SSA/binary artifacts remain external with their recorded hashes.
[Candidate](candidate.json) pins the exact source, API, runtime, machine-build policy
and qualification receipts; the source recipe reproduces its exact bytes.
