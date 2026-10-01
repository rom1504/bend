# Phase39 normal checked compiler cost

**PASS: all 27 fresh checked emissions reproduce their independently acquired
output bytes.** The final run completed in 184.338 seconds. Relative to installed
Phase37, request medians change by −1.60% for local-pair, +3.50% for tree-bitonic
and −1.68% for numeric recurrence. The tree request has disjoint observed ranges
and is a real cost to disclose; the small local/numeric reductions have overlapping
ranges. This campaign improves generated programs without demonstrating a general
improvement to compiler request speed. Requests remain **5.05–5.98× TypeScript**
on these three sources.

Root executed the planner and every measured process serially. This report was
written from the completed raw observations; its author performed only read-only
hash/statistics checks. No bound design, worker or experiment input was changed.

## Exact comparison and timing boundaries

The roles are installed Phase37 checked03
(API `ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`),
selected Phase39 checked05
(API `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`),
and TypeScript at `018751270e800bc222a93dad7f257083ee53a5f7`.
The selfhost runtime is unchanged:
`51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49`.
The fresh candidate acquisition is `selfhost/build/phase39/final-candidate01`.

The unchanged Phase30 worker measures a **normal checked-library request**.
Bend calls the normal driver `inspect(..., {mode: "library"})`; lazy API loading
and normal Base-cache handling remain inside the request. TypeScript loads and
checks the book and emits through its normal library function. This measures
neither an emission-only pass, a warmed persistent compiler server, a full
bootstrap nor generated-program execution.

Host import, request, import-plus-request and full process wall time are distinct.
Process wall includes verification and wrapper work. Bend's small host-import
measurement only imports the driver; it does not move lazy compiler loading out
of the request. Consequently the request-only and import-inclusive TypeScript
ratios answer different questions. Neither may be silently substituted for the
other.

Three sources (`local-pair`, `tree-bitonic`,
`coverage-numeric-recurrence-1024`) each have three fresh processes per role, with
role order rotated each round: 27 samples total. Root used Node v24.18.0 on CPU3,
a 1 GiB heap, a 2 GiB process-tree RSS ceiling/free-memory floor and 180 seconds
per request process. The sources cover a small historical input, a structural
workload and a numeric workload, not a representative distribution of compiler
inputs.

## Checked-request results

Times below are median [minimum–maximum], in milliseconds. Percentage change and
TypeScript gap use ratios of the request medians.

| Source | Phase37 request | Phase39 request | TypeScript request | Phase39 change | Phase39 / TS |
|---|---:|---:|---:|---:|---:|
| local-pair | 1,757.754 [1,717.241–1,899.325] | 1,729.627 [1,716.801–1,781.300] | 309.940 [309.826–311.744] | −1.60% | 5.581× |
| tree-bitonic | 1,696.055 [1,608.067–1,704.296] | 1,755.497 [1,749.430–1,918.923] | 293.686 [289.999–293.703] | +3.50% | 5.977× |
| numeric recurrence 1,024 | 1,344.882 [1,302.949–1,431.762] | 1,322.234 [1,321.825–1,324.165] | 261.796 [259.803–284.356] | −1.68% | 5.051× |

Pairing by the recorded round index preserves an additional view of variability:

| Source | Round 0 change | Round 1 change | Round 2 change | Median paired change |
|---|---:|---:|---:|---:|
| local-pair | −6.21% | +0.72% | −2.33% | −2.33% |
| tree-bitonic | +3.00% | +13.14% | +8.79% | +8.79% |
| numeric recurrence 1,024 | −1.54% | +1.45% | −7.65% | −1.54% |

These paired percentages are not the ratio of medians in the preceding table.
Tree compilation is slower in all three pairings, and its observed request
ranges do not overlap. Its ratio-of-medians increase is 59.443 ms; the larger
median paired percentage is retained rather than hidden. Local/numeric requests
each include one slower candidate pairing, so their small aggregate reductions
are not evidence of a reliable general compiler speedup. Three rounds are an
engineering cost check, not a statistical confidence interval or attribution to
an individual optimization pass.

## Host import and full process

The same median [range] convention applies, in milliseconds:

| Source / boundary | Phase37 | Phase39 | TypeScript |
|---|---:|---:|---:|
| local-pair / host import | 13.173 [3.653–13.386] | 3.776 [3.707–3.914] | 218.264 [217.534–238.425] |
| tree-bitonic / host import | 3.713 [3.640–13.515] | 3.726 [3.663–3.761] | 217.948 [217.245–219.207] |
| numeric / host import | 3.745 [3.684–13.318] | 3.674 [3.672–3.678] | 219.751 [217.585–239.388] |
| local-pair / import + request | 1,770.928 [1,720.894–1,912.711] | 1,733.334 [1,720.577–1,785.214] | 530.008 [527.360–548.365] |
| tree-bitonic / import + request | 1,707.936 [1,611.780–1,709.569] | 1,759.161 [1,753.191–1,922.649] | 510.948 [507.947–512.893] |
| numeric / import + request | 1,358.199 [1,306.633–1,435.506] | 1,325.908 [1,325.504–1,327.837] | 479.554 [479.381–523.744] |
| local-pair / process wall | 6,424.755 [6,080.309–6,749.937] | 6,328.262 [6,207.369–6,486.018] | 4,733.467 [4,712.023–4,772.353] |
| tree-bitonic / process wall | 6,261.913 [5,997.415–6,345.601] | 6,265.047 [6,225.692–6,670.868] | 4,733.323 [4,713.304–4,734.026] |
| numeric / process wall | 5,840.532 [5,629.446–6,016.252] | 5,774.147 [5,773.860–5,795.835] | 4,671.188 [4,651.492–5,158.288] |

Phase39 import-plus-request is 3.270×/3.443×/2.765× TypeScript for
local/tree/numeric, respectively. Complete process ratios are 1.337×/1.324×/1.236×,
but common provenance verification and process overhead dominate that boundary;
those are not standalone compiler-request gaps. Relative to Phase37, complete
process medians change by −1.50%/+0.05%/−1.14%; all process ranges overlap.

## Memory and generated module size

Process-tree RSS below is median [range], converted from recorded bytes to MiB.
It is sampled live RSS, not allocation. The worker's separate `maxRssKiB` samples
remain in the raw report; the measurements differ slightly because their
observers and sampling differ.

| Source | Phase37 tree RSS, MiB | Phase39 tree RSS, MiB | TypeScript tree RSS, MiB |
|---|---:|---:|---:|
| local-pair | 515.121 [512.934–516.578] | 517.465 [517.367–517.738] | 494.457 [493.891–496.125] |
| tree-bitonic | 513.266 [513.109–515.895] | 517.152 [516.539–518.098] | 468.930 [466.840–488.402] |
| numeric recurrence 1,024 | 512.043 [511.902–512.535] | 511.594 [511.215–512.656] | 483.000 [482.109–485.340] |

Maximum observed process-tree RSS across all 27 runs is 518.098 MiB, below the
2,048 MiB ceiling. Worker maximum-RSS medians for Phase39 are
517.625/517.926/511.594 MiB for local/tree/numeric. This gate does not measure
large-source peak memory or establish immunity to an OOM on another workload.

| Source | Phase37 output bytes | Phase39 output bytes | Change | TypeScript output bytes |
|---|---:|---:|---:|---:|
| local-pair | 124,739 | 124,927 | +188 (+0.151%) | 12,457 |
| tree-bitonic | 91,332 | 98,342 | +7,010 (+7.675%) | 10,593 |
| numeric recurrence 1,024 | 79,384 | 79,458 | +74 (+0.093%) | 4,699 |

The tree output includes additional private component workers. These module
sizes include each backend's emitted support code and generic/public paths;
they are not directly a count of source concepts or an explanation of runtime
speed by themselves. The cost worker does not isolate which planner/emitter
accounts for the tree request increase.

## Receipt and emission closure

The [preparation report](compiler-cost-preparation.md) records the planner's
versioned archive mapping. The portable Phase39 baseline's `baseline` role maps
to the original checked Phase37 acquisition's `candidate`; the nested older
baseline never becomes this denominator. The original TypeScript acquisition is
verified separately. No historical timing is reused.

- Completed plan: `selfhost/build/phase39/compiler-cost-plan01/config.json`,
  SHA `786d8297b6953e9b09977c04838ad982dac0cee3cf9916d8f6ddb3d54699eea2`.
- Completed report: `selfhost/build/phase39/compiler-cost01/report.json`,
  SHA `92c640bc3dd319f313e7ee5b978b4626832459679c17869531240143fbcbb51d`.
- Unchanged measurement worker SHA:
  `f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42`.

All 27 process receipts report successful completion and all 27 observations
report a successful checked emission. The worker checks byte identity against
independently acquired output on every request. A separate read-only review of
this completed result rehashed every newly emitted file and matched all 27 to
the expected role/source SHA. Representative complete expected hashes:

| Source | Phase39 expected emitted SHA256 |
|---|---|
| local-pair | `ef1b7ce9359e9cd172b6475c686255c880d0dfeacd52dcd47eba816cb3e7965e` |
| tree-bitonic | `c0695bb8e900c1855d159b4b9533e50d6c76eb04baa344ecb74c0be62e89d0c5` |
| numeric recurrence 1,024 | `eb4042b71bc329b530065da57ebd15a8fb423b7634e170ad13466c7bf0885861` |

Each has three identical successful emissions; all six baseline/TypeScript
expected hashes and individual observations remain in the pinned config/report.
No source, cache, tool or input hash changed during the measured gate.

## Interpretation and reproduction

The normal compiler request remains about 1.3–1.8 seconds on these small sources.
This is a separate iteration cost from executing the resulting programs. The
candidate's tree request increase should be weighed alongside its execution
gain and added source/JS size; it must not be described as free optimization.
The narrow three-source gate gives no evidence about proof discovery on a much
larger program. Avoid multiplying compilation and generated-program ratios, or
averaging these three inputs into a claimed typical Bend compiler speed.

Reproduction requires the retained checked attempts, cache artifacts and clean
pinned checkout, unlike portable generated-program timing. Every output directory
must be new; planner and runner each own the shared resource lock:

```sh
python3 selfhost/tools/performance/phase39/compiler-cost-plan.py \
  selfhost/build/phase39/checked05 \
  selfhost/build/phase39/final-candidate01/manifest.json \
  selfhost/build/phase39-replay/compiler-cost-plan-NEW \
  --baseline-attempt selfhost/build/phase37/checked03 \
  --baseline-preparation selfhost/tools/performance/phase39/baseline/manifest.json
python3 selfhost/tools/performance/phase35/compiler-cost-run.py \
  selfhost/build/phase39-replay/compiler-cost-plan-NEW/config.json \
  selfhost/build/phase39-replay/compiler-cost-NEW
```

The planner accepts the fresh candidate preparation; its archive support is
specifically for the retained reference, not the published `current` archive.
Bound sources, tools and design inputs must stay unchanged during execution.
A failed preparation or sample would require a new output directory or explicit
versioned successor; completed and unsuccessful observations remain immutable.
