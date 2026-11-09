# Phase186 — remove native execution work across optimization boundaries

Start 2026-11-09 09:10:53 UTC, parent `1b46218`, branch
`selfhost/bootstrap`. Three-hour campaign through approximately12:11 UTC.
Goal: improve both QBE and direct AMD64 generated-program runtime toward1×,
ideally0.5×, our mature C backend. These are goals, not forecasts.

## Starting evidence and decisions

Phase185 actual N2 products measure1.47759×QBE/C and5.55592×assembly/C over44
timed native45 cases. Independent45-case outputs, native64 per target, assembly
runtime10 and native code reproduction pass. The installed selection remains
Phase183; named Phase185 N2 images are the new experimental reference.

The first task is to remove work visible in hot machine code, not add another
backend or repeat broad qualification before a candidate exists. Assembly's
admitted fold loop still has123 instructions versus QBE17, including dead tuple
stores, incomplete stack forwarding and simultaneous loop-argument snapshots.
F32 operations lose their inline effect information before register allocation.
QBE map/tree retain substantial ownership/transition costs, while its numeric
and closure regressions show why fewer instructions or bytes is insufficient.

## Hypotheses and ambition

1. **Bounded machine cleanup:** eliminate private stack stores whose addresses
   never escape and whose values cannot be observed; resolve simultaneous loop
   moves directly where legal. Preserve aliasing, setup lifetime, unknown calls,
   stack safety, widths and fallback paths. General transfer is required beyond
   the fold kernel. Falsifier: actual hot memory operations or runtime do not fall.
2. **Compose existing semantic knowledge:** share one exact inline-operation
   effect summary among F32 emission, register lifetimes and scratch forwarding.
   Do not treat an eventual instruction sequence as an unknown machine call.
   Unknown or unsupported operations keep their barriers. Falsifier: inadequate
   coverage, new spills, or machine/runtime regression despite fewer barriers.
3. **QBE whole-computation improvement:** compare map/tree and text/application
   code against same-source C; find a repeated ownership/continuation boundary
   that can be removed legally. Require measured hot work and a plausible whole
   workload ceiling before implementation, not static helper counts alone.

The10×-ambition path is a compact shared representation of private scalar/product
state and its effects, enabling several existing optimizations to compose.
The100×-ambition path eliminates entire constructor/continuation lifecycles
across a verified computation. Advance only when a bounded slice gives credible
evidence; ambition labels do not imply performance gains. No universal IR rewrite
or relaxation of correctness gates is required by this plan.

## Efficient schedule and ownership

- First20min: bounded independent audits and exact candidate designs; reuse
  current profiles/products. Root prepares controlled baseline manifests.
- Next60min: parallel implementation in disjoint Bend modules; root runs one
  CPU3 target lane, checked B1 controls and small paired runtime screens. Reject
  unproductive alternatives early and retain failures.
- Next45min: integrate the strongest mechanisms, test unrelated families and
  inspect remaining hot code. Freeze source for final gates by~11:15 where possible.
- Final55min: justified actual native acquisition/reproduction, finite semantic
  gates and full45 runtime comparison, report, commits and push. Metadata analysis
  proceeds during target execution. No broad rerun after unchanged code.

The coordinator owns integration, manifests and target execution. Bounded agents
own private-memory lowering, inline effect summaries, QBE machine/semantic audits,
profiling support and storage accounting. Agents do not launch competing timed
or full compiler jobs. Native/B1 differences and final source identities remain
explicit; production defaults change only through their existing release gates.

## Metrics and correctness

Primary comparison is runtime of identical Bend programs against our C target,
not handwritten C or upstream. Use retained Phase185 target products as the
before reference and same C products. Adaptive per-role batches target250ms,
minimum100ms, three rotated rounds. Every output and success count is checked.
Report case/family/source geometric means, positive log deficit, cases over1.1×
and2×, equal-work totals and individual regressions. No selective-score claims.

Keep independent final native IR verification, runtime ABI11102, ownership,
effects, FP/NaN behavior, unknown fallbacks and bounded native stack use intact.
Test temporary aliases, full-word values, parallel-move cycles and values live
across inlined operations. Source checking, executable facts, finite tests,
BendTT proofs and native reproduction are separate guarantees.

Record compiler execution/build cost and source growth separately from generated
runtime. Profiling is diagnostic; clean timings determine gains. Failed ideas,
tool failures and negative results remain part of the evidence.

## Resources and delivery

One controlled CPU3 lane,2GiB ordinary RSS,16GiB available-memory floor, explicit
disk budgets and5GiB reserve. Larger native-chain budgets need measured admission.
Preserve qualified images and reference products; reclaim only via authenticated
retention or exact immutable deduplication. No deletion by phase age.

Deliver maintained Bend implementation, reproducible experiment records, a report
under `implementation/phase186`, and committed/pushed work. Never label a small
kernel gain broad parity. No PR comments.
