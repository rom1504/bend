# Phase129 profiler audit

Audited HEAD `a4ecad0`, the qualified Phase128 N1 captures in
`selfhost/build/phase129/profile01/`, and `profile-comparison01.json`.
This was offline analysis only: no target execution, builds, compiler edits or
new profiler infrastructure. [The compact evidence](profiler-audit.json) pins
every joined analysis/capture/caller vector, the existing unwind table, methods
and exact native image.

## Main new observation: the unknown libc bucket is register copying

The existing authenticated CFI table resolves **all 218 libc samples** to its
copy region and recovers `p111_set_regs` as the physical caller for every one.
There are **zero sampled fill-region instructions**. This is not the earlier
Phase126 clearing regression.

| Request | Copy samples / all samples | Weighted copy share | Approximate clean CPU in copy | Copy plus exclusive `p111_set_regs` leaves |
| --- | ---: | ---: | ---: | ---: |
| lexer | 84 / 886 | 9.37% | 0.2045s | 12.32% |
| closures | 62 / 717 | 8.41% | 0.0505s | 12.78% |
| Map churn | 72 / 1,176 | 6.14% | 0.1782s | 9.25% |

The final column is a union of two disjoint physical sample categories, not a
complete inclusive function profile or a predicted optimization gain. Some
register transport is semantically required. Nevertheless, this establishes a
concrete cost category worth examining when comparing calling conventions,
register widths and transitions through the generic runtime.

Four samples remain unresolved by the generic symbol reader: one closure sample
and three Map samples, all at ELF `0x402090`. Exact disassembly identifies that
address as `memmove@plt`; the instruction evidence is retained in the JSON.
Adding general PLT symbolization would improve completeness but would not change
the optimization decision here.

## Capture quality is adequate; interpretation is the main remaining gap

All 20 sampled captures have zero reported loss/overruns, intact handlers,
plausible delivery and valid main-thread/lifecycle coverage. All captures are
accepted by the existing comparison gates. Pooled counts are 886, 717 and 1,176;
capture CPU covers at least 99.55% of the measured child CPU. The clean CPU
medians are 2.182057s, 0.600559s and 2.902105s. Absolute exposure estimates are
therefore available under the existing approximation policy.

However:

- Each individual capture is short. A pooled count above 500 is not a confidence
  interval for small helpers or evidence against periodic aliasing.
- The 8ms and 13ms samples disagree enough that small ranking changes should not
  drive implementation. Map reclamation is 26.58% versus 22.00%; closures'
  generated-code bucket is 38.34% versus 32.84%. These differences can reflect
  ordinary sampling variation or aliasing, not demonstrated compiler behavior.
- Current captures are unchanged-image physical profiles without active Bend
  contexts or event counts. They cannot say which source computations cause
  the remaining drop/copy work. The coordinator's separate diagnostic relink
  and `context02` captures are now complete; their owner analysis is not
  duplicated in this physical-profile audit.
- Three short requests do not establish full-source compiler exposure. Phase127
  full-source owners and Phase128 pre-optimization decoder/use-query shares
  are useful hypothesis sources but stale quantitative estimates.

The fresh physical reclamation shares are 21.95% for lexer, 11.73% for closures
and 24.28% for Map. Allocation-helper leaves are only 1.40%, 1.59% and 1.94%.
Allocation-volume reductions alone therefore remain a poor profitability proxy;
an intermediate-value transformation should account for ownership, traversal,
transport and reclamation as well.

## Small improvements with immediate decision value

1. **Attach the existing caller summary to routine comparison output.** The
   necessary captures and CFI tables already exist. An offline join turns a
   6–9% “unknown library” bucket into a specific register-copy path without
   rerunning the compiler. Preserve the original unresolved symbol status;
   report the authenticated instruction region and physical caller separately.

2. **Show period/repetition stability beside a proposed hotspot.** Report the
   8ms and 13ms shares and per-capture range for the few functions/families used
   to justify an experiment. Retain pooled raw and weighted denominators. This
   is a small reporting addition, not a request for a statistical framework or
   a broader benchmark campaign.

3. **Make a bounded decision table from the completed diagnostic relink.** For
   each candidate computation, put fresh physical exposure, active-owner samples,
   relevant event counts, explicit entry-segment counts and a cheap semantic
   oracle on one row. Keep these distinct measurements; do not multiply event
   counts into claimed CPU time or label active dispatch an inclusive stack.
   Use it to choose between repeated AST queries and checked-Base decoding.

4. **Only if pass-level attribution is still necessary**, add a few explicitly
   measured preparation/lowering/emission boundaries, or use an exact-output
   ablation. More owner names will not recover separately dispatched ancestors.
   A large logical-stack profiler is not justified for this decision.

Do not spend the next cycle extending unwind coverage, rebuilding generic
profiling infrastructure or collecting another broad suite solely to improve
symbol coverage. The existing machinery has already resolved the largest
unknown bucket. The missing information is fresh ownership/context evidence
for a small set of candidate computations, followed by a controlled fast-loop
experiment showing what work actually disappears.

## A small origin/cost sidecar could make the next decision easier

If the next experiment crosses helper/continuation boundaries, preserve a
**bounded metadata sidecar** from the already checked lowering, rather than
recovering more facts from generated symbol strings. Useful fields are:

- Exact QBE, compiler-source and runtime-ABI identities; final segment/FID and
  private symbol; stable originating definition IDs where known. Composite or
  erased origins stay explicitly unknown, rather than receiving an invented
  enclosing source function.
- Transition kind, input/result widths, local-resume eligibility and known
  ownership/borrowing contracts. Retain the existing admission/certificate
  reference that justifies a fact; profiling observations do not grant legality.
- Analysis/query kind and request-local input identity when an existing pass
  already computes them. This can expose repeated equivalent use queries or
  preparation without copying ASTs or creating a global cache.

The first useful cost report would join that catalogue to the existing active
FID and register-word counters. It should distinguish **static potential cost**
from **observed frequency and time**. Current counters report total requested
copy words, not every caller→callee transition or its width distribution. Do not
assign one helper's measured cost to every static transition or call the
catalogue an inclusive cost graph.

Only if that missing distribution changes experiment selection, add a small
bounded diagnostic width histogram or selected transition counter on the chosen
proxy. Avoid an unbounded dense FID-pair matrix. Measure its overhead separately.
This would help falsify whole-computation/register-transport hypotheses while
preserving the ordinary compiler and its independent final verifier.

Metadata-only sidecars should leave generated program bytes unchanged and be
bound to the actual emitted artifact. This is a targeted extension to measured
optimization experiments, not a new universal IR, optimization policy engine or
proof of source provenance from names alone.

## Reproduction

For one existing capture, choose a fresh output directory:

```sh
taskset -c 1 python3 -B selfhost/tools/profiler/attribute.py \
  --analysis selfhost/build/phase129/profile01/lexer/003-sample-lexer-phase128/analysis.json \
  --callers selfhost/build/phase129/profile01/lexer/003-sample-lexer-phase128/callers.txt \
  --table selfhost/build/phase127/libc-unwind01/table.json \
  --summary-only --out /tmp/phase129-caller-audit-fresh
```

The audit aggregates these already ordered/pinned vectors at their actual
sampling periods. It does not modify samples, expectations or qualified images.
