# Phase191 exact-product physical profile assessment

The completed capture confirms that **the local-pair row loop is the dominant
physical hotspot**, while map time is spread among generated workers and
runtime helpers. These captures compare Phase190 `baseline`, Phase191 `both`
and mature C. **The later `extra` candidate and numeric recurrence were not
profiled here.**

[Authenticated assessment](../../selfhost/build/phase191/profile-analysis01/report.json) ·
[Offline derivation](../../selfhost/build/phase191/profile-analysis01/derive.py) ·
[Original frozen plan](../../selfhost/build/phase191/profile-plan01/plan.json) ·
[Original comparison](../../selfhost/build/phase191/profile-plan01/comparison.json)

The assessment rechecks capture/manifest pins and plan denominators, then
recomputes the maintained comparator and matches its saved JSON exactly.
The comparator correctly produces **zero cross-role comparisons**. Every
case/role has a distinct workload name because repetitions differ; captures
are pooled only within the identical role command. No new targets were run.

## Quality and normalization

All six pools pass the maintained comparator's existing capture, pooled-count
and CPU-coverage gates: two accepted periods (8 and 13 ms), at least 500 samples,
zero rejected captures, dropped samples or overruns, valid thread lifecycle,
and more than 99.90% capture-window/child CPU coverage. Sampled-thread CPU
coverage exceeds 99.99%. Individual short captures have fewer than 500 samples;
the documented within-command pooling supplies the admitted denominator.

| Case / role | Repetitions | Samples | Unknown samples | Unknown weighted share | Clean CPU µs/repetition |
| --- | ---: | ---: | ---: | ---: | ---: |
| local-pair / baseline | 1,549 | 571 | 0 | 0% | 1,791.91 |
| local-pair / both | 3,010 | 570 | 0 | 0% | 942.22 |
| local-pair / C | 13,653 | 579 | 1 | 0.14% | 220.86 |
| map / baseline | 13,295 | 616 | 10 | 1.82% | 224.71 |
| map / both | 13,432 | 574 | 12 | 2.13% | 213.06 |
| map / C | 62,649 | 598 | 0 | 0% | 46.49 |

Each clean CPU number divides that role's **one** complete clean process CPU
observation by its recorded repetitions. Four warmups and startup remain
included. This is descriptive normalization, not a balanced timing experiment,
confidence interval or replacement for the runtime ablations. Sampled/clean
wall ratios range approximately 0.954–1.031 and are diagnostic observations.

Unknown samples remain in every denominator. The maintained comparator reports
them but does **not** require zero unknowns for `adequate` or
`estimateAvailable`. Therefore only local-pair baseline/both and map C satisfy
an additional zero-unknown rule like the old Phase190 role-analysis adapter's
strict admission flag. Do not describe the other three as fully resolved or
silently reassign unknown time. A 500-sample threshold is not a precision bound.

## Local-pair: bind the actual inline C loop

`$product.row` receives **99.21% baseline / 98.94% both** of period-weighted
samples. Its exact positive header/body spans account for **98.84% / 98.42%**
of all samples. The previous static row work is therefore connected to the
measured CPU hotspot, rather than merely being plausible repeated code.

Approximate clean CPU attributed to that physical function, divided by each
role's repetitions, is **1,777.76 / 932.20 µs**. These are sampled estimates,
not independently measured function timers; the remaining small functions
have too few observations for fine ranking.

The C executable spends **99.86% in `NF_FID_pair`**, which inlines the row/cell
arithmetic. It does not primarily execute the separately emitted `dp.row`
function inspected earlier. The actual C hot inner loop is
**`[0x10ca0,0x10cfc)`**, accounting for **99.16%** of period-weighted samples:
26 instructions, 92 bytes, five indexed memory operations, two `cmovb`, one
conditional backedge and no calls or rsp accesses. Its two syntactic rbp
references use rbp as an **array base**, not a frame pointer or spill slot.
The earlier `dp.row` loop remains a valid equivalent-code example; this new
exact-PC binding identifies the observed owner and removes the hotness ambiguity.

Both sampling periods independently identify the same dominant functions:
the x86 row shares are 98.84–99.56% for baseline and 98.15–99.72% for both;
C `pair` shares are 99.72–100%. This supports the hotspot conclusion without
claiming instruction-level causal attribution or inferring the Extra result.

## Map: several costs, with limited precision for small leaves

| Physical leaf | Baseline weighted share | Both weighted share | Baseline / Both estimated CPU µs per repetition |
| --- | ---: | ---: | ---: |
| borrowed `Map.bit.go` | 11.16% | 9.11% | 25.07 / 19.41 |
| `work_loop.constprop.0` | 6.10% | 5.45% | 13.71 / 11.61 |
| `p125_rt_take2` | 5.40% | 4.77% | 12.14 / 10.15 |
| `$direct.Map.ins.go` | 3.46% | 4.62% | 7.79 / 9.85 |
| `$direct.Map.seek.go` | 4.13% | 4.34% | 9.27 / 9.25 |

The bit worker is the largest single leaf in both x86 products, but map has no
local-pair-like dominant worker. Ownership/product helper groups account for
17.16% / 17.69%; `p111_rt_op` separately contributes 4.24% / 3.94%. The later
Extra frame audit removed many insertion-worker loads, but its corresponding
Both physical leaf is only 4.62% here. This does not cap the combined optimization:
forwarding changes other functions too, and leaf attribution omits callees.

Map ranks vary by period: the baseline bit-worker share is 12.66% at 8 ms and
9.50% at 13 ms; Both is 8.17% and 10.05%. Most listed helpers have only tens of
samples. Treat their ordering and differences as leads, not established causal
speed changes. Identical instructions in an inspected worker also need not
give identical physical sample shares across whole-program executions.

C's largest physical leaves include `Map.bit.go` (18.41%), `term_drop` (12.69%)
and `Map.seek.go` (9.27%). The generic grouping regex classifies **`WL_FID_*`
generated C workers as `scheduler`** because it matches `WL_` first. Consequently
the rendered C `scheduler` aggregate of 77.47% is not evidence of actual scheduler
overhead; use the physical functions. No grouping code or original receipt was
changed in this assessment.

No cache-miss, memory-latency, source-owner or numerical-regression explanation
is established by these profiles. Numeric body-entry alignment remains a
separate experiment motivated by unchanged worker instructions and changed
addresses, with its own ablation and correctness requirements.
