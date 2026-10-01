# Research method and estimate contract

## Scope

The user requested a substantial collection of compiler research documents,
followed by mining the most promising ideas with gain and risk estimates.
Reading source, literature and existing evidence is authorized. Proposed
optimizations are not implemented in this phase. No PR comment is posted.
Installed Phase37 and its closed evidence remain the baseline.

Selection favors a concrete connection to observed costs: generic calls and
forcing in lists/trees, descriptor checks in ray programs, allocation inside
numeric loops, and checked compilation latency. Native optimizing compilers
also supply counterexamples and constraints; relevance does not require their
runtime to match JavaScript.

## Evidence levels

| Label | Meaning | What it does not establish |
| --- | --- | --- |
| Local measurement | Preserved matched run on identified compiler/module/input | Representative language-wide speed |
| Local source observation | A concrete implementation or emitted-code pattern | Dynamic frequency or causal timing |
| External implementation | A mechanism inspected in versioned compiler code | Correct transfer to Bend |
| Published result | Authors' experiment in their stated environment | Our expected multiplier |
| Hypothesis / planning range | Our engineering estimate for a named workload | A confidence interval or achieved gain |

Code examples in the notes are explanatory pseudocode unless identified as
short excerpts or exact local observations. No downloaded compiler is built
or benchmarked. Sources are primary repositories, authors' papers and official
documentation. A web-fetch failure is not evidence that code does not exist;
local pinned Bend source supplies its own hash-identified evidence.

## Forecasts

Speed multipliers are **incremental against installed Phase37 checked03**, on
the named eligible workload, unless an explicit historical or prospective
comparator is named (for example, fusion versus a direct unfused worker).
`1.5×` means old time/new time = 1.5, a one-third time reduction. Ranges are
planning judgments, conditional on the proposed mechanism being admitted and
executed; the null result and regressions remain possible. They are not formal
probabilities. Compiler-time percentage reductions use their own denominator.

Risk is qualitative and decomposed when useful:

- **Low:** narrow existing proof, representation and owner controls; small blast radius.
- **Medium:** new admission cases or analysis with bounded scope; meaningful
  demand/order/fallback obligations and a plausible code-size regression.
- **High:** new ownership, representation, effect or calling-convention proof;
  many public observations or large architecture/maintenance cost.

Evidence confidence and risk are different. An appealing high-headroom idea
may have low confidence and high correctness risk. Effort estimates are focused
engineering time, including controls and review, not a promise of wall-clock
completion or an instruction to run a campaign for that duration.

## Bound speed claims with mechanisms

For a removable fraction `p` of total runtime, the optimistic Amdahl ceiling
is `1 / (1 - p)`, assuming the rest is unchanged and removal has zero cost.
CPU sample shares only approximate that fraction. JIT attribution, GC and
code-layout changes can break a literal interpretation; the bound is a sanity
check, not a measured result.

Active-ray guard frames total about 42.02% of sampled self CPU, suggesting an
idealized 1.72× ceiling for removing all of that cost alone. This rules out
selling a 3× guard-only forecast from those profiles. List application/forcing
frames sum to about 51.21%; a larger gain would require changes to additional
allocation, matching or actual loop work. Sampling allocations are not retained
heap or exact object counts.

Proposals overlap. Direct components, callback specialization and fusion all
remove some call traffic. Guard amortization can already be part of a larger
component. Representation and ownership changes may remove the same allocations.
Do not multiply the table's optimistic endpoints.

## How a technique earns implementation

1. Identify the first missing fact or expensive runtime transition in actual
   emitted code, and name the owner of its semantic obligations.
2. Preserve baseline outputs and create one isolated saved-output variant plus
   refusal and boundary controls. Separate instrumented counts from clean timing.
3. Confirm the mechanism runs; compare exact values, errors, ordering, alias
   behavior, host mutation and reentry where relevant.
4. Screen under 20/60-second execution ceilings; use a second unrelated shape.
5. Implement only the smallest general rule that both examples justify.
6. Measure checked compilation, source size, emitted bytes and execution;
   broaden to 300/600-second selections and fresh holdouts before promotion.

No amount of benchmark speed compensates for silently changing public ABI,
partial application, erased arguments, constructor identity, deferred demand,
F32 rounding, Nat failure timing or bounded tail stack. A fallback is useful
only if admission itself has not already invoked an observable hook or moved
an error. Error construction can reenter our module, so exception paths matter.

## Practical limits

Phase37 has 45 input points from 23 source files, not 45 independent programs
or a weighted production sample. Some outputs are checksums. Its old heldouts
are now exposed and must become regression cases. List selectivity needs new
non-cycle inputs. Large graphs, long-lived heaps, IO/FFI and native/GPU behavior
remain underrepresented. No proposed JS optimization implies native parity,
full conformance or a self-emitted fixed point.
