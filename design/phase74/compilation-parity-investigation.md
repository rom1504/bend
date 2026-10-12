# Phase74: locate a credible compilation-parity path

Investigation only; installed Phase73 stays unchanged. The user asks for roughly
3x faster compilation, not another marginal pass. No subagents, one CPU3 target
tree, 2GiB RSS/4GiB free-memory floor. Node1GiB heap/4MiB stack.

1. Read old/new compiler stage profiles and pinned upstream C pipeline. Count
   generated C/segments and identify duplicate lowering or overly broad reachability.
2. Measure one first request plus five repeats for Numeric/Array/Lexer under
   B1, B2 and upstream. Same checked requests and full C oracles; imports/Base
   preparation outside the clock. This tests warm-process opportunity, not
   fresh-process parity. Use ordinary inspect, without skipping checks/reports.
3. Derive a diagnostic B2 image with entry counters at pure native analysis and
   lowering boundaries. Count repeated argument tuples and per-definition work;
   no memoization or output change. Treat instrumented clocks as diagnostics.

Separate measured evidence, source inferences and proposed gains. Do not multiply
overlapping estimates. The parity budget must account for both backend emission
and frontend/report/transport work. Any future cache must preserve raw semantics,
full type instantiation and request context. Keep generated program speed through
exact output initially; route-selection/dead-code changes need stronger native
qualification when output necessarily differs. No compiler implementation in this
investigation and no PR comments.
