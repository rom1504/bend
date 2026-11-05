# Phase166 — attribute execution and backend work after the source cuts

Start from `9721a54`, keeping Phase152's explicit qualified native image and
maintained source unchanged. Phase165 showed near-neutral complete checking when
our safe equality implementation replaced bendc's native predicate. That does
not measure its individual cost or explain the remaining backend work.

Investigate two bounded questions before another optimization campaign:

1. How does the **same complete compiler lookup computation** execute under our
   QBE, mature C and bendc C routes? Reuse source-derived lookup/digest fixtures,
   including sharing, duplicates, legacy inputs and varied names. Consume every
   result with an independent oracle. Distinguish borrowed readers from their
   ownership adapters, index traversal, reconstruction and teardown. Inspect
   generated code only after measuring a real difference. Construction and
   machine costs are separate from repeated program execution.
2. What work occurs after a shared checked `NR_Request`? Reuse the retained checked
   hosted API and Phase165's exact C/QBE products. Add reversible diagnostic
   counters at actual generated function/loop entries and ordered stage markers.
   If economical, count logical constructor events by tag. Do not time trampoline
   returns as completed computation or force deferred work to simplify the hooks.
   Report counter units, incomplete coverage and instrumentation overhead.

The first cases are the retained Map and verifier-compilation slice. The verifier
source exercises compilation of real verifier code; its executed empty-program
control is not a large runtime verifier benchmark. No full self-emission, new
compiler acquisition, upstream update or broad benchmark is needed merely to
screen these hypotheses.

## Decisions and gates

- Source/API/image/runtime/Base/toolchain identities must be explicit. The default
  asset named `qbe-n2` is older than Phase152; use its qualified image and receipt.
- Preserve ordinary source checking and independent semantic output gates. New
  diagnostics must reproduce the complete prior C/QBE products. Instrumented
  clocks describe the diagnostic run; clean comparisons remain separate.
- Counters distinguish calls, loop iterations, logical constructors, native
  allocations and sampled CPU. Never add inclusive stages as disjoint totals.
  Require marker order/multiplicity or label the stage attribution invalid.
- Use cheap controls and bounded workload scaling. Stop on output mismatch,
  unsupported source/ABI, excessive memory or an inconclusive tiny timing.
  Preserve failures. Make only evidence-supported follow-up measurements.
- Root owns one CPU3 resource-intensive lane. Bounded agents prepare sources,
  audit existing evidence and challenge hypotheses; no competing builds.
- Keep the 5 GiB reserve and explicit disk/RSS/deadline budgets. Avoid duplicate
  request graphs. Reuse current archives only through authenticated restoration;
  close every run and retain source, evidence and the qualified compiler.

## Expected information, not promised speedups

The lookup comparison can distinguish an algorithmic problem from generated
representation/calling overhead, but a small kernel is not a full-build forecast.
The backend census can reveal unnecessary candidate construction, repeated
verification/traversal or large transient representations; it cannot by itself
assign native CPU cost to every constructor. Rank the next intervention by
measured whole-region cost, removable work, generality and the cheapest falsifier.

Deliver a concise report with exact observations, negative results, confidence
limits and the strongest next experiment. Commit and push the investigation;
do not promote a compiler or weaken correctness gates to improve a diagnostic.
