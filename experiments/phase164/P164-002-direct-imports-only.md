# P164-002 — isolate the useful composition interface

Added after the first ten native IO controls and machine inspection, 2026-11-05.
The initial mixed route is correct on those controls but fresh native requests
improve only 1–2%. Inspected runtime gains come from generic callers reaching
existing direct workers without scheduler round trips, rather than new arithmetic
or String worker algorithms.

Counter-hypothesis: a small verified import interface in the ordinary renderer
can obtain those execution gains and avoid redundant registry analysis, while
retaining original generic lowering and all original independent verification.
This might be a better immediate engineering tradeoff than the mixed route.

Keep the original preparation/lowering/optimization/final-verification pipeline.
At rendering, admit only real ordinary zero-capture, one-result scheduler entries
with matching final public direct signatures and bounded ordinary-call arity.
Create actual rank-zero direct imports/forwarders; exclude only those owners
from ordinary region candidates to avoid duplicate symbols. Preserve the full
original function/fusion index and independent semantic gates.

Compare three of the already tested original IO workloads first. Measure whole
backend time, actual generated runtime, emitted code and exact value/count oracles.
No claim that an existing valid direct signature alone is a universal new proof;
audit the ordinary-call ABI and stack/effect constraints. Root owns target runs.
Do not launch another full native acquisition unless the small economics merit it.
