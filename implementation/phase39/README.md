# Phase39: apply the compiler research through measured experiments

**[Checked05 is installed and verified](release-05.md)**: all 42 ordinary/relocated
CLI checks and all 15 post-install audit groups pass, with 227 canonical files
matching the checked snapshot.
This phase implements the [Phase38 research recommendations](../../design/phase38/ideas.md)
through the prospective [Phase39 design](../../design/phase39/README.md), isolated
saved-output experiments, actual checked emissions and final-image validation.

API SHA256: `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
The upstream target remains `018751270e800bc222a93dad7f257083ee53a5f7`.
The selected image is a checked B1 derivative, not a newly self-emitted fixed point.

## Retained changes and main finding

Four changes preserve existing tagged values and public behavior:

- [Private Number countdowns](countdown.md) extend the existing occurrence proof
  to eligible scalar loops. Observable or escaping Nat predecessors remain BigInt.
- [One outer proof scope](guard-scope.md) reuses the existing complete-graph proof
  for an eligible scalar root. Repeated ray helpers share the entry check.
- [Structural recursive components](components.md) use explicit frames for two
  independent recursive children, keeping generic leaf/combine behavior.
- [Unary producers](unary-producer.md) avoid generic recursive calls through a
  known saturated combiner, while preserving pre-child/post-child argument order.

The useful research transfer was preserving known call and shape facts across
an entire useful component. A general optimizer IR or new data representation
was unnecessary for these gains. Complete values, aliases, demand/error order,
host mutation, reentry and deep recursion remain explicit obligations. Read
[the findings](findings.md) and [backend rules](backend-rules.md) for the mechanism
and limits.

[Known-callback specialization](callbacks.md) was investigated and rejected.
The original list-pipeline fixture was already first-order; a new affine callback
fixture was needed. Direct dispatch recovered 4–5% against its added scope, but
that combined saved-output variant was 9.5–13.8% slower than the original in the
short screen. No callback specialization, broader callback proof or fusion was
retained.

## Generated-program performance

All **45 points / 23 sources** pass **669 primary samples** across four
same-run comparisons totaling **1,076.213 seconds (17.94 minutes)**. Four focused
canaries add 60 separate confirmation samples and 98.328 seconds; they are not
pooled with primary measurements. [Every point, range and drift observation](execution/report.md)
is retained in the exact-module aggregate.

| Changed workload | Phase37 / Phase39 speedup | Phase39 / TypeScript time |
|---|---:|---:|
| Expression production, two depths | 4.46–8.05× | 5.24–10.47× |
| Active ray, two inputs | 2.62–2.87× | 31.03–33.65× |
| Tree, three depths | 1.76–2.25× | 31.85–44.00× |
| Symbolic regression, three inputs | 1.75–1.83× | 2.14–2.20× |
| Numeric recurrence, two sizes | 1.07–1.22× | 2.79–7.52× |
| Scalar loop, 8,192 steps | 1.20× | 1.17× |

All these changed-module points have disjoint observed ranges and five paired
wins, but some tree/ray samples still have substantial half-run drift. Ratios
characterize this protocol, not universal steady-state or average application
speed. Earlier screens are kept separately and do not replace these results.

The changed generic-row canary costs **0.97%** in the primary comparison and
**1.66%** in confirmation, losing all five pairs each time; confirmation ranges
overlap. This measured cost is retained. **23 of 45 points have byte-identical
baseline and candidate JavaScript**, including lexer, lists, closures, BST,
map and record workloads. Their apparent gains and regressions cannot be caused
by these source changes. The unchanged evening program even shows a 1.50×
ratio in this run: a useful negative control against attributing every measured
shift to optimization. All adverse medians, pairings and repeats remain visible
in [the admission decision](performance-admission.md).

Large gaps remain: map churn is about 96–103× TypeScript and BST about 183–223×
on these inputs. No parity claim follows. Formerly held-out families are exposed
regression tests now.

All **42 separate CPU/allocation captures** pass on exact timed modules. Sampled
allocation falls about **50% tree, 60% active ray, 79% numeric and 83% expression**.
These are sampling estimates, not exact object counts; [profile findings](profile-findings.md)
separate remaining dispatch/guard costs from clean speed ratios.

## Compiler cost and complexity

All **27 checked compiler-cost emissions** reproduce their independently
prepared JavaScript bytes. Same-run request medians change by **−1.60% local,
+3.50% tree and −1.68% numeric** against Phase37. Only tree has disjoint ranges;
all three tree pairs are slower. Requests remain **5.05–5.98× TypeScript** for
these three sources. Import and complete-process boundaries give different
ratios. No general compiler-throughput improvement is established. See the
[complete cost report](compiler-cost.md).

[Source counts](source-size-checked05.json) use the same ordered compiler-module
method as Phase37:

| Measure | Phase37 | Phase39 | Change |
|---|---:|---:|---:|
| Physical Bend lines | 18,358 | 18,722 | +364 / +1.98% |
| Nonblank Bend lines | 15,709 | 16,031 | +322 |
| Definitions | 2,045 | 2,087 | +42 |
| Modules / types / laws | 70 / 71 / 640 | 70 / 71 / 640 | unchanged |
| Runtime bytes / physical lines | 53,346 / 663 | 53,346 / 663 | unchanged |
| Generated compiler API bytes | 1,181,753 | 1,217,056 | +35,303 |

The unary producer adds a case to an existing flag. Reusing types and runtime
machinery does not mean zero conceptual cost. This phase buys selected execution
speed with a modest compiler-size increase; it does not claim simplification.

## Correctness and release identity

The [integration report](integration.md) binds all checks to checked05:

- **3,026 main + 196 broader exact frontend observations**, zero differences.
  Main verdicts retain their previous scope: 2,525 passes, 497 observations and
  four shared failures.
- **81 backend rows:** 69 pass, eight not applicable, four shared failures.
- **56,205 primitive**, **3,759 worker**, **144 nested** and **1,129 primitive-guard**
  observations; 15 selected upstream executions; 23 libraries / 127 points;
  40 worker refusals / two witnesses; 22 component observations and 42 exact HVM
  stdout bytes.
- **15 Phase35 + seven Phase36 + three Phase37 owner groups**, plus
  [four new owner groups](new-owner-gates.md) with actual-emission value,
  structure, alias, admission, boundary and error-order controls.
- **154 expanded application executions** and **227 canonical source identities**.

Counts overlap and are not one additive coverage score. Exact agreement preserves
known shared failures; it is not full backend/GPU conformance or an independent
proof-validity claim. [Installation and relocated CLI receipts](release-05.md) pass separately after
performance admission; the first sandbox-denied native smoke run is preserved.

## Fast iteration, evidence and failures

Use the [Phase39 benchmark guide](../../selfhost/tools/performance/phase39/README.md)
for portable previous/current/TypeScript output bundles and selected **20 / 60 /
300 / 600-second ceilings**. Build, source acquisition, semantic controls,
execution timing and profiling are separate operations. Time-budgeted benchmark
runs spend fixed warmup/sample windows, so faster programs execute more calls
rather than automatically shortening the full-suite wall time. The checked05 build plus
36 focused probes took **42.295 seconds**, peaking at **1,194,725,376 bytes** RSS.
The complete suite is an integration check, not an edit-loop prerequisite.

Root alone executes heavy jobs, serially on CPU3, with Node24.18, a 1 GiB heap,
2 GiB process-tree RSS ceiling and 2 GiB available-memory floor. Agents author
and independently review disjoint changes. No unbounded large-Nat trip counts
or concurrent compiler jobs are used.

Failed checked02/03 tree declaration emission, rejected fixture revisions,
short-screen drift, callback regressions and auditor schema/path mistakes are
preserved rather than rewritten. The old counter assertion required scalar
BigInt; its reviewed successor requires the newly proved Number path while
retaining all value, escape/refusal and mutation checks. All successor auditors
keep explicit provenance verification. See [integration](integration.md) for
receipt paths and the distinction between semantic and metadata failures.

The 103 unrelated starting files and closed Phase35/36/37 evidence remain outside
this phase's changes. No PR comment is posted. The [release record](release-05.md) and [evidence capsule](evidence/README.md)
bind the installed result and preserved experiments after [writer closure](raw-closure.json).
