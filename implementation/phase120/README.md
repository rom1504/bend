# Phase120: numeric gains, limited coverage, explicit compiler cost

The first bounded cycle improves the original45 generated-program screen from
**2.98283× to2.87077× pinned upstream C** in the same run: **3.76% less runtime**
by the existing equal-point geometric metric. All405 observations pass the
unchanged complete-output/count oracle. There are44 timed points and the original
zero-work correctness sentinel. This is useful progress, well short of parity.

[Design](../../design/phase120/runtime-specialization-and-parity.md) ·
[Cycle scope](../../design/phase120/first-cycle.md) ·
[Reproduce](../../selfhost/tools/performance/phase120/README.md).

The candidate is a checked Bend compiler hosted in JS that emits native QBE
programs. It is not a newly qualified native N1/N2 compiler. Phase118 safe03 and
installed selections remain authoritative. Historical3.00893× used an earlier
run; use this cycle's paired2.98283× denominator when attributing gains.
Timed producer `combined01` is the retained experimental candidate. A later
`combined03` has an authenticated byte-for-byte QBE bridge on all45 programs and
six controls, with the same runtime, but remains unselected after its compiler-cost
screen. No identical binaries were rerun to create a second timing claim.

## What changed

**Recover an exact signed-word operation.** Reaching-value facts connect a low32
logical shift, canonical sign test and sign-fill mask through copies and
supported branches. Their final OR becomes an exact arithmetic shift. A rendering
rule projects the U64 shift/shift/mask sequence to QBE word SAR with explicit zero
extension. QBE already supported SAR; lowering had lost the relationship between
the operations. Unknown effects, memory operations and unsupported control flow
invalidate facts. No benchmark names choose the transformation.

**Keep numeric work together.** Existing scalar-operand and local float-lane
prototypes are combined with new branch-local facts and bounded leaf expansion.
Verified immutable constructor IDs are admitted as metadata. A fixed profitability
rule reserves the growth budget for leaves with four unconditional floating
arithmetic operations before a branch. Arithmetic order, integer public/private
ABI, ownership, stack bounds and independent verification remain. This is not a
full typed ABI or SIMD pass.

Initially the region pass copied field selectors and left both hot intersection
calls intact. Constructor admission enabled one; selecting arithmetic work over
selectors enabled both. Each costs295 copied nodes, fitting the unchanged1024
budget. The four-site cap and existing caller/parameter/result/stack limits remain.
Unchanged functions now retain their original bodies rather than rerunning range
cleanup; empty tables retain the verified boundary. This shortcut preserves exact
QBE on the three focused programs.

## Generated-program results

Three rotated rounds, frozen inputs/runtime, serial CPU3, original counts scaled4×.
Medians are internal batch milliseconds, not one-shot latency.

| Program | Phase118 | Candidate | Upstream | Less runtime | Candidate/upstream |
| --- | ---: | ---: | ---: | ---: | ---: |
| Scalar region8192 |428|299|200|30.14%|1.495×|
| Mandelbrot |800|720|199|10.00%|3.618×|
| Mandelbrot grid5 |401|277|201|30.92%|1.378×|
| Active ray256 |1697|1329|202|21.69%|6.579×|
| Ordinary raytrace |1885|1840|229|2.39%|8.035×|
| List pipeline128 |677|678|200|−0.15%|3.390×|

The other Mandelbrot grid improves27.03%; the other active-ray input21.97%.
These transfer to variations of two algorithms, not many independent families.
Unrelated list/tree/map/lexer/recurrence workloads are broadly unchanged. The
largest median slowdown is1.05%; three rounds cannot rule out small regressions.

Separate active-ray ablations give operand-only0.9728×parent, existing local
lanes0.8698×, initial regions0.8297×, constructor admission0.7994× and arithmetic
selection0.7825×. Each has its own matched parent. Do not attribute the old lane
benefit entirely to the new pass or treat cross-run differences as precise effects.

The first word prototype reduces the whole scalar worker122→90 machine
instructions and seven→four setcc. The later word renderer replaces three shift
pairs by `sarl`. Both intended intersection calls disappear, but static stack and
instruction counts move in different directions in nearest/tail workers. Actual
runtime, not shorter IR, establishes the benefit. See the
[word audit](../../selfhost/tools/performance/phase120/word/results.md) and
[region audit](../../selfhost/tools/performance/phase120/regions/results06.md).

Equal weighting of22 frozen manifest family labels gives2.94756×upstream and
3.64% less time than parent. Labels still contain related computations; they do
not guarantee statistical independence. Per-round equal-point candidate/parent
ratios are0.96344,0.96210,0.96160: descriptive spread, not confidence intervals.
Total emitted QBE grows39,447,110→39,651,200bytes (+0.52%).

## Correctness, failures and complexity

The combined candidate passes14 signed-word admission/refusal controls and60
independently interpreted values,17 word-width controls, nine constructor-ID
controls,27 region eligibility/profit/budget/identity controls, six ordinary native
programs, and405 original45 observations. The unselected later source also passes13
narrower prefilter controls and rechecks the other controls. Ordinary controls include signed
boundaries, float rounding, NaNs, signed zero, conversions and division. Original
and final verifiers remain. This is finite qualification, not a whole-compiler
proof or parallel/GPU qualification.

A rejected Boolean simplification replaced a U64 comparison with an incompatible
U32 copy. The verifier preserved semantics through fallback, but restored slower
uninlined code: scalar1633ms versus299ms for the useful word candidate. Initial
shape controls missed that contract. The corrected width-preserving variant
passes full-function verification but gives no extra speed; both are excluded.
Correct final output alone does not show that an optimization was accepted.

Parser/affinity failures, a wrong constructor-control catalogue, an unavailable
helper spelling, and a late prefilter's missing law declarations remain with
their diagnostics. Separate versions repair failures; no oracle or verifier was
weakened. These costs and rejected variants count as research work.

Retained composition grows52,411→53,610physical Bend lines (+2.29%), including
controls, with140 added declarations. Unselected03 has53,655lines and144 added
declarations. Runtime and ABI are unchanged. Rejected
variants and host tools are outside that compiler count. This adds capability,
not simplification; consolidate accepted modules/facts before promotion.

## Compiler cost and decision

The initial word-only screen increases prepared compilation cost28–36% on the
affected cases. Fixed-graph profiling finds2.368s in word analysis and0.519s in
verification. Analysis is about82% of their sum: repeated list-based fact
maintenance matters more than removing checks. The region shortcut retains
exact code but does not remove this dominant cost.

The combined candidate's paired hosted cost uses pinned Bun1.4.3, one warmup,
three rotated measured rounds, separate identically prepared Base states and
exact emitted-byte checks. Whole prepared-request medians:

| Program | Parent seconds | Candidate seconds | Candidate/parent |
| --- | ---: | ---: | ---: |
| Mandelbrot |8.634|11.416|1.322×|
| Active ray256 |17.547|25.675|1.463×|
| Lexer |7.262|7.480|1.030×|
| Numeric recurrence1024 |3.193|3.102|0.971×|

The four-case geometric cost increases17.95%; admitted-entry cost increases21.54%.
This is frontend+admission+complete checked emission, with import/preparation and
host serialization reported separately. It is not native B1/B2 or upstream
compilation speed. The32 successful warmup/measured emissions took361.11s under
the guard. Numeric speedups carry a real compilation-cost tradeoff, so they are
not promoted. This table describes the retained timed-source `combined01`.

The narrower syntax filter preserves exact code and reduces Mandelbrot word
analysis2.3678→0.9658s; verification remains0.5192/0.5351s. On the ray graph,
word analysis is already only0.0565s and falls to0.0167s, while verification stays
1.4352/1.4298s. Thus ray's larger whole-request overhead is not explained by
word fact-table cost. Next separate region planning, lane rendering and unchanged
verification work. These are hosted stage diagnostics, not native timings.

The later combined03 screen measures1.193×parent on Mandelbrot,1.630× on active
ray,1.083× on lexer and1.003× on recurrence: **1.20558× overall**, versus the
retained candidate's1.17954× in its separate paired screen. Samples vary and overlap;
this does not establish a precise filter-induced regression. It does establish
that the isolated analysis gain did not demonstrate a whole four-case win.
Keep the simpler candidate and preserve the narrower filter as an unselected
cost experiment. Do not call the filter a measured research-loop acceleration.

No full native acquisition, N1/N2 self-reproduction, native compiler throughput
measurement or default promotion is included. Program gains cannot be relabeled
as native compiler speed or recursive research acceleration. Disk headroom also
does not support the prior full-image campaign; small guarded products suffice
for this experiment.

## Highest-value next work

Exact semantic identities fit the existing IR and remove meaningful work. Region
admission and profitability are separate concerns: metadata rejection and spending
the budget on selectors hid useful arithmetic. However, the region improvement
is22%, not the proposed2× architecture signal.

For broader runtime gains, test bounded producer/consumer fusion or scalar
replacement that removes intermediate construction, access and destruction
together, starting with the profiled list pipeline and an unrelated transfer.
Further numeric polish alone cannot close deficits in other families.

For a cheaper research engine, replace quadratic current-fact maintenance or reuse
existing range facts, requiring exact-output comparisons on the prepared graph.
Keep verifier and successful-transform activation checks. Retain these useful
prerequisites, fix their analysis cost, and seek elimination of a different
category of runtime work before expanding architecture or rebuilding full images.

## Evidence and research cost

[Results](results.json) retain every per-case sample summary, frozen-family
weighting, size accounting, both paired cost screens and stage diagnostics.
[Candidate](candidate.json) pins the retained source/API/runtime and the unselected
exact-code bridge. [Accounting](accounting.json) records all87 serial guards,
including10 failed source/control attempts. The evidence capsule preserves small
receipts, output logs, commands, bounded disassembly and failures; large artifacts
remain external with recorded identities. Digest replay checks integrity, not
correctness or timing. The exact candidate recipe was successfully recomposed.
The [sealed capsule](evidence/receipts01.tar.gz) contains3565 payloads,
6,778,519raw bytes in918,061compressed bytes; all payload digests replayed.
See its [manifest](evidence/manifest.json) and [summary](evidence/summary.json).

Through16:51:49UTC, the cycle took86.65min wall time, including47.04min guarded
work. Exclusive guarded categories are4.17min checked API acquisition,
17.59min checked emission,8.61min native build/output/runtime checks,16.22min
compiler-cost measurements, and0.46min finite controls/analysis. Failures consume
31.63s within those totals. Two agents perform offline source/audit work; root
owns serial CPU3 execution. Agent inference/token cost is not metered, and the
remaining wall time is not a measured inference total. Final sealing/commit time
follows this accounting snapshot.

Peak guarded tree RSS is1.856GiB under the2GiB cap; minimum available memory is
22.23GiB, above the16GiB floor. No guard resource failure or native output failure
occurred. No full image was built. The late filter's full51-output bridge could
have been postponed until its complete small cost screen: that ordering would
have saved roughly four minutes after its local-only gain failed to transfer.
Use whole-request cost on a few exact-output cases before another broad bridge
for compiler-cost-only variants.

Repository whitespace checking reports only the retained trailing blank line in
the frozen unselected prefilter08/09 modules. Their authenticated experiment bytes
are preserved; the remaining staged changes pass that check.
