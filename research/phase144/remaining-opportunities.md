# What the current evidence supports after Phase144

This is a conditional research ranking, not a speed forecast. The fresh
[integrated profile](integrated-profile.md) covers source `992893e`, with the
original runtime. It precedes the final predicate/append composition and does
not profile the separate serial-runtime image. Finish those already-planned
whole-request measurements before repeating a full profile or crediting their
gains twice.

| Next discriminator | Existing evidence and scope | Cheapest useful test | Limit |
| --- | --- | --- | --- |
| Carry compact local identities/facts across verification and an optimization consumer | Optimizer plus first verifier is still 64.43 diagnostic seconds; `p111v_*` represents 14.66% of all active samples. The compact sum-record native verifier slice measured 11.06% less time. | One complete real function, preserving diagnostics and final verification; include name-to-ID preparation, updates/joins, lookup and teardown, then a second actual consumer. | The existing slice alone would imply only about 1.6% total improvement if its saving transferred to exactly the sampled verifier family. That conditional arithmetic is not evidence of whole-compiler gain. |
| Remove remaining emission materialization | Registry plus render/output remains 65.23 diagnostic seconds. The integrated suffix-aware flattening removes 4.01 seconds from the diagnostic output tail; instruction-string construction remains visible. | One complete real generated body, compared byte-for-byte, using existing fragments with a generic bounded UTF-8 sink; include partial-write/error/ownership behavior and all conversion cost. | This is a new IO contract if fragments cross the runtime boundary. A different concatenation loop or one IO operation per fragment may lose the gain. |
| Apply exact shared semantic facts to constructor-existence queries | The same ownership idea removed the old ownership scan from several stages. `constructor_exists` still contributes 223 samples, about 7.14 diagnostic CPU-equivalent seconds, mainly checking and checked-context construction. | Actual checker/context invocation with construction plus queries plus teardown and independent old-result comparison, preserving first-match, source and cache-view semantics. | Even removing the entire observed helper cannot explain the 37.67-second checking budget. This is a bounded conventional opportunity, not a route to 50 seconds by itself. |
| Resolve representation/admission composition before another compact-record rewrite | The compact verifier's first representation lost direct workers; a real sum entry restored them and improved its slice from a weak 1.9% to 11.06% gain. Existing production hot examples already have direct workers. | An actual rejection/dependency trace and one unrelated hot transfer case; retain original boxed fallback and readiness/final gates. | Missing workers alone do not diagnose product-specialization failure. Do not generalize from the deliberately changed prototype to all current code. |
| Bound parallel owner work after reducing shared preparation | Registry/render/raw and verification are substantial, potentially separable regions; historical machine-unit partitioning was slower cold. | Measure actual unit-time distribution, largest unit, serial setup, transport and retained memory; then one versus two workers on identical frozen units. | This has not demonstrated a speedup. Ordered helper readiness, global naming, immutable-context lifetime and output order constrain independence. |

The best near-term architectural test is the first row, not merely replacing
wide records with smaller records. The experiment already shows that data layout
and generated execution path interact. Producer-owned IDs must survive at least
one subsequent pass so that removed hashing, projection and allocation are not
reintroduced at every boundary. Preserve the independent final verifier and
the diagnostic name table. A private duplicate of the whole verifier is useful
as a falsifier but should not become a second maintained implementation.

The renderer is similarly a whole-computation problem. The current implementation
already has chunk finishing and constructor-tail workers. Useful improvement
must remove an actual materialization/ownership boundary, preserve native append
fallbacks, or avoid repeated region discovery. The registry interval contains
up to six continuation-region passes, so treating all 17.40 seconds as string
numbering would select the wrong optimization.

The 50-second goal needs an explicit scope. Relative to the separate 249.68-second
clean serial-runtime request, **50 seconds for compiler execution alone requires
approximately 5×**. If the goal includes a hypothetical 15-second machine/link
tail, it leaves 35 seconds for the compiler, requiring approximately 7.1×.
That 15-second allowance is a budget illustration, not a freshly measured final
candidate tail. Use its actual final build receipt before claiming an end-to-end
ratio.

A falsifiable target budget for compiler-only 50 seconds might allocate frontend
15 s, raw preparation/lowering 7 s, optimization/verification 13 s, observer
composition 4 s, registry/output 10 s and fixed costs 1 s. These are requirements
to test, not additive predicted gains. The current diagnostic partitions are
94.83/44.82/64.43/25.15/65.23 seconds respectively. Instrumented clocks cannot be
substituted for clean measurements, but they show that optimizing only one
partition cannot satisfy the target. The broader compact representation and
bounded-parallel proposals therefore require measured conversion, serial floor
and memory ceilings before any large rewrite.

Current physical drop/fade costs of 24.53% and register transport's 6.68% overlap
the source-stage budgets. The serial-runtime result already attacks related
execution costs. They are not new independent gains to multiply into the table.
For the next cycle, prefer one complete function or output-body experiment and
its independent oracle over another full compiler acquisition for each idea.

Sources are the current [verifier experiment](verifier.md),
[emission/append evidence](string-append.md), [compact and parallel audit](compact-and-parallel.md),
and [exact stage comparison](integrated-profile-v2.json). No new targets were run
for this ranking.
