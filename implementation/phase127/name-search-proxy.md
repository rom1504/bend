# Name-search proxy: a large ownership-lowering gap

The unchanged compiler name-search kernel runs **14.65× slower through direct
QBE than through upstream C/Clang O3** on this deliberately narrow workload.
Accepted physical profiles put **54.20%** of QBE samples in `term_drop` and
`span_fade`. Inspection finds a concrete representation difference: upstream
walks borrowed list/string fields, while the QBE path repeatedly performs owned
constructor takes and reference-management calls.

This qualifies a fast optimization proxy. It is not a new speedup, a
whole-compiler ratio, or a representative user-program score.

## Frozen workload and correctness

[`benchmark.bend`](../../selfhost/tools/performance/phase127/name-search/benchmark.bend)
has SHA256 `c599109a40883b3136fc0d0e5c56243e3a1046f0a54d3c1dcb7f9be8fbd20b1b`.
Five definitions were extracted unchanged from the compiler: `has_name`,
`has_name_next`, `p88_string_eq`, `p88_string_eq_go`, and `p98_eq_finish`.
The scaffold generates names from real optimizer identifiers, exercises
present/absent/common-prefix searches, and retains independent digest oracles.

The measured arguments are **`512 2 1024 0`**: 512 timed repetitions,
two warmups, 1,024 generated names plus two Unicode names, and a reserved argument. Expected digest output was
derived before execution and is `192636846`, `385273692`, `4140784640`, followed
by one variable millisecond timing line. Both upstream and QBE passed the
ordinary independent controls and this timing contract.

The two checked scaffold refusals remain preserved: a computed match scrutinee
in `p127-name-search-emit01`, then missing affine annotations in `emit02`.
Only wrapper code was corrected; the five extracted definitions and oracle
results stayed unchanged. The earlier incomplete multiline extraction also
remains in `name-search-preparation01`. Failed preparation has no performance
meaning.

## Clean timing and diagnostic costs

Three clean observations, rotated across variants, give:

| Executable | Median process wall | Wall range | Median internal time |
|---|---:|---:|---:|
| direct QBE | 1.495706 s | 1.4934–1.4977 s | 1,485 ms |
| upstream C/Clang O3 | 0.102076 s | 0.1020–0.1028 s | 100 ms |

The ratios are **14.653× process wall** and **14.85× internal time**. The
internal interval excludes source/list construction but includes evaluation
and printing of the timed digest. Total process timing includes controls,
construction, warmup and shutdown. Neither interval measures compilation.

The context-only diagnostic binary takes 1.597894 s, **6.83% above clean QBE**.
Enabling event counters takes 2.466738 s, **64.92% above clean QBE**. Those costs
are explicitly separate from production timings and from each other.

## The failed sampling attempt and successful repeat

The first campaign used 2 ms and 3 ms periods. **Every capture had timer
overruns**: totals were 1,000 for QBE, 1,067 for diagnostic QBE and 64 for
upstream. Delivered counts were materially below expected clock periods.
`name-search-comparison01.json` rejects all twelve captures. Their raw leaf
shapes remain negative evidence; they do not justify quantitative CPU shares.

The same frozen manifest was sampled again at **8, 13, 8 and 13 ms**. All twelve
repeat captures had zero recorded loss and accepted delivery/coverage:

| Executable | Accepted pooled samples | ≥500 threshold |
|---|---:|---|
| direct QBE | 603 | Yes |
| diagnostic QBE | 642 | Yes |
| upstream | 38 | No |

The fresh `name-search-comparison02.json` retains rejected captures while
pooling only the accepted repeat, using the original independent clean
timings. Upstream is too short for a quantitative profile here; all 38 observed
samples resolving to `WL_FID_HAS_NAME` are descriptive only. No threshold was
weakened to admit them.

Period-weighted QBE physical fractions are `term_drop` **29.35%**, `span_fade`
**24.85%**, `p125_rt_take2` **12.50%**, and the direct `p88_string_eq_go` worker
**12.01%**. The context-instrumented distribution differs: drop/fade total
**59.74%**. Use the clean-binary physical distribution for cost ranking.

All 642 diagnostic samples retain `p127ns_loop` as their dispatcher owner:
private synchronous calls do not update it. The libc unwind table recovers no
physical caller edges here because the hot leaves are runtime functions in
the executable, outside that table. Owner attribution alone cannot identify
which nested equality call caused a particular drop.

## What work is visible

All three counter runs are complete, have no overflow/invalid context and
produce identical totals:

| Runtime event | Count |
|---|---:|
| `term_drop` entries | 66,530,802 |
| constructor takes | 55,924,305 |
| keep calls | 13,593,434 |
| sink calls | 17,594,469 |
| allocation calls | 63,613 |
| free calls | 63,613 |
| dispatcher entries | 187 |
| continuation frames | 0 |
| requested register-clear words | 0 |

99.8% of drops occur under the outer timed-loop dispatcher. Entry counts do
not mean 66 million objects were reclaimed: immediate-value tests, shared
references and traversal all differ from actual frees. The evidence identifies
ownership-operation churn, with little scheduler activity or allocation volume.

The generated artifacts explain why this is a useful proxy:

- Upstream `name-search-upstream01/source.1.c:1351`, `spin_3`, follows string
  tails using `term_peek` and direct field reads. It performs no keep/take/sink
  in the comparison loop. `spin_4:1400` returns the Boolean without consuming
  the retained strings. `WL_FID_HAS_NAME:1855` similarly peeks list fields.
- QBE `p127-name-search-emit03/compiler-name-search.ssa:1650` keeps both roots,
  calls its direct equality worker, and sinks both roots afterward. Its worker
  at line 1452 repeatedly calls `p125_rt_take2`; the separate finish helper at
  line 1640 explicitly sinks its two string arguments.

These are different lowering choices before machine optimization. The next
high-value experiment is a legal borrowed-observer route for retained roots
and a scalar/nonowning result, compared independently against this unchanged
baseline. Preserve ownership, aliases, early exits, Unicode and bounded stack
behavior. Do not simply delete drop calls: the capability needs a lifetime and
result-ownership justification.

Even perfect removal of the measured 54.20% drop/fade bucket alone would give
only a conditional **2.18×** proxy speedup (`1/(1-0.5420)`), leaving roughly
6.71× of the current upstream ratio. Matching the upstream borrowed traversal
could also remove takes, keeps, sinks and representation work; that broader
effect is a hypothesis, not yet demonstrated. Validate the proxy first, then
test real compiler requests before claiming transfer.

## Separate tree transfer check

The live-register-bank correction also reduces tree-bitonic clean wall time
from **1.046738 to 0.930735 seconds**, **11.08% less time**, over three repeats.
`tree-machine-identity01.json` verifies identical `.text` and layout; only one
capability data byte (11→15) and the linker build ID differ. This supports a
runtime-work explanation rather than a changed-instruction-layout explanation.
It is separate from the unoptimized name-search proxy.

The committed derived evidence is
[`name-search-proxy-summary.json`](name-search-proxy-summary.json). Complete
comparisons and summary-only attribution artifacts remain under
`selfhost/build/phase127/name-search-comparison0{1,2}.json` and
`name-search-attribution0{1,2}`. All analysis in this report was offline; the
root coordinator owned every target execution.
