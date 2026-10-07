# Compiler bottlenecks and useful next discriminators

The [completed 23-source diagnostics](diagnostics.md) support two broad priorities:
common frontend work and source-dependent string/reference handling. They do not
support optimizing only Lexer and Evening, or attributing the gap to one named
routine. The [clean measurements](measurements.md) establish the latency gap;
stage clocks and profiles explain observed work under separate diagnostic runs.

## Priorities grounded in this population

1. **Separate shared checking/setup from source-dependent checking.** Checking
   plus completion is the largest individual B2 stage in 22/23 inputs, with a
   611–726 ms range; cache/identity adds 188–212 ms. Both measured pipelines
   recheck Base. The [frontend audit](common-frontend.md) shows why a parsed Base
   cache is insufficient to skip that work. A useful next diagnostic would count
   Base/source/generated declarations and split the existing world setup,
   checking and completion boundaries. A checked-state reuse proposal needs its
   own state/diagnostic/specialization proof; this survey grants no permission to
   omit checks or weaken cache validation.
2. **Inspect string and emitted-reference transport in both backend-heavy and
   expression-heavy sources.** String frames exceed 5% of sampled allocation in
   18/23 inputs; reference/use frames do so in 8/23. MapSet’s library rendering
   is 746 ms and its String/reach-reference dispatchers account for 290.9/274.6 MB
   of sampled self allocation. Active ray tracing has 599.4 MB at the String
   dispatcher, but a different source-loading/checking balance. The next
   discriminator should distinguish immutable text scans, deduplication lists
   and their call contexts, preserving emitted-reference order and liveness.
   Shared `$scc` frame names do not justify assigning all work to one member.
3. **Keep indexes and substitution in every experiment’s coverage.** Index names
   exceed 5% of both CPU samples and sampled allocation in all 23 inputs;
   substitution exceeds 5% of allocation in 22. Numeric recurrence provides a
   low-string opposite case with 21.9% index and 11.6% substitution allocation.
   These families recur beyond the two previously profiled programs. Stable
   substitution/identity and persistent index behavior are semantic constraints,
   not merely implementation overhead that can be discarded.
4. **Treat primitive metadata as a smaller independent candidate.** Its names
   account for 2.0–5.9% of CPU samples and 2.2–4.3% of allocation across the
   population. A bounded table-lookup/materialization experiment may be useful,
   but the current data does not make it the main explanation of the gap.

These are priorities for falsifiable experiments, not predicted savings. CPU
sample counts, diagnostic stage clocks and sampled allocated bytes are separate
units. Unknown ancestry remains visible, and one observation cannot establish
variation or close rankings.

## Fast coverage with an explicit broad gate

The frozen [subset proposal](../../selfhost/tools/performance/phase60/analysis/fast-subsets-v1.json)
selected numeric recurrence plus MapSet for a 20-second rejection screen. A
60-second confirmation adds active ray tracing and a second rotated round.
Allocation evidence subsequently corroborated their distinct families: low
String/index-heavy; backend/reference-heavy; and high String/source-heavy.
Lexer and Evening stay held out. The full 23-source/45-point population remains
the broad gate; this subset is not a substitute for conformance or generality.

The actual whole-CLI replays passed in **17.529 s** and **49.510 s**, including
runner checks and orchestration but excluding inherited preparation and compiler
image generation. [Fast-loop instructions](fast-loop.md) bind the actual receipts,
frozen estimates and commands. They run first-only fresh workers, whereas the
broad clean campaign also records three later requests. New compiler candidates
need truthful new image/preparation bindings before comparison; the existing
observations cannot be relabelled as a new candidate.

No production source was changed and no optimization was selected in Phase60.
