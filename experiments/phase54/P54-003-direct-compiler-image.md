# P54-003: direct compiler-image qualification

Hypothesis: direct named-field exports can use the existing stage0/no-G host
loader contract, allowing compiler execution without the legacy descriptor ABI.
First test restricted checked exports and term transport, then compiler-scale
emission and checked self-emission. Legacy private-image transformations remain
separate consumers until migrated.

Falsifiers: transport/erasure mismatch, missing API, changed source result/error,
resource refusal, recursion failure or non-identical qualified successive stages.
No emitter/source golden may be weakened; no hidden TypeScript fallback.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md).
Preserve the working compatibility route until this experiment actually passes.

## Outcome

**Restricted transport passed; full compiler-image migration remains blocked by
the bounded emission gate.** The exact Phase53 checked-source probe selected 11
public roots, reached 84 source definitions and emitted 73 definitions in a
50,150-byte direct module. Five independent transport groups passed, including
a frozen 20,000-element list and shared named-field graph handoff. Worker times
were 23.096 seconds for emission and 0.047 seconds for the transport controls.
No positional adapter or hidden fallback was used.

The full 77 plan was then rebound to checked-graph02 and its exact source. It
reached the 240-second supervisor deadline without a complete image; its peak
process-tree RSS stayed below the 2 GiB limit. A separate 90-second diagnostic
retained durable phase progress: exact emitted reachability took 55.898 seconds,
layout 3.327 seconds, and final library emission began at elapsed 82.290 seconds
before the deadline. Profiling/progress timings are diagnostic only.

The full V8-log processor separately exhausted a 512 MiB local Node heap; the
compiler jobs did not report OOM. Retained deterministic one-in-ten tick sampling
processed successfully. In 7,857 retained ticks, `j_find_ctor` had 26.5% and
`missing` 11.2%; 98.6% of `missing` ticks were beneath `j_find_ctor`, and the main
constructor-search caller was arity recovery in `jd_raise_head`. This is a
specific optimization hypothesis, not a measured potential speedup.

Next bounded proposal: reuse the existing owner-typed `j_layout_ctor` query when
an expected ADT telescope is available; thread that type into arity recovery if
its matcher/erasure invariants can be preserved. Top-level `lookup` alone is not
a constructor index. Any later constructor index needs exact-context and
first-match/shadowing proofs. No query-cache or emitter rewrite was introduced
in this cleanup.

The reviewed ordinary-driver source/direct comparison and fresh self-check plus
self-emission plans are prepared **but unexecuted** because no full image passed
this gate. Keep the existing compiler-image/compatibility consumers. No full 77
ABI, compiler-throughput, self-emission equality or fixed-point claim is made.

[Detailed report and retained receipt paths](../../implementation/phase54/bootstrap.md).
