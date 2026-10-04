# Phase43 generated-program profiles

Pre-final checked14 diagnostic, `checked14-map-callback-profiles01`, reuses the
exact modules from the successful four-point screen. All 12 CPU/allocation
profiles complete. Profiling and unprofiled timings are separate observations.

| Point | Role | Sampled allocation estimate per call |
|---|---|---:|
| Map128 | TypeScript | 2.18 MB |
| Map128 | Phase42 baseline | 105.78 MB |
| Map128 | checked14 | 29.10 MB |
| Closures256 | TypeScript | 159.37 kB |
| Closures256 | Phase42 baseline | 441.90 kB |
| Closures256 | checked14 | 8.69 kB |

The Map change removes much generic dispatch, but substantial wrapper and
continuation allocation remains. Ordinary control instrumentation measures
259,965 to 49,807 generic applies at size128. The sampled allocation estimate is
about 3.6 times lower than the previous release and still about 13 times TS.
Its hottest sampled candidate frame is the runtime function wrapper (15.0%);
the specialized Map.bit.go instance is a large allocation contributor (18.2%).
This points to remaining generic graph edges and continuation storage as the
next investigation targets. Counts and samples identify hypotheses; they do not
by themselves prove how much a further change would save.

Closure construction/application fusion removes the environment graph and the
bounded numeric loop removes BigInt countdown arithmetic on proved U32 counts.
The sampled allocation estimate drops roughly 51 times relative to Phase42.
Now 52.4% of CPU samples are in regionHostGuard; descriptor lookup accounts for
50.2% of sampled allocation. Entry overhead is a larger share after the loop is
cheap. Further guard reduction needs exact capability ownership and mutation
controls, not unconditional removal of host checks.

Generated code grows: Map's full module is 271,639 bytes versus baseline122,580
and TS46,419. The contextual graph is nested inside the root registration, so
source-owned syntax accounting includes specialized Base functions there;
148,540 candidate source-owned bytes cannot be read as a like-for-like source
algorithm size. Closure full-module size grows from79,767 to83,455 bytes while
runtime allocation falls. Static array/function sites are not executed allocation
counts. The aligned source viewer and raw profiles remain in the diagnostic run.

These are sampled allocations, not retained heap or exact counts. CPU attribution
can charge inlined work to callers. Final corpus timing and semantic release gates
remain separate evidence.

## Next experiments suggested by the surviving gap

Prioritize Map's residual mutually recursive String/bit operations and allocation
sites. A bounded mutually recursive worker loop could remove the remaining
call/apply transitions without opening public mutation boundaries; test it first
as a saved-module experiment with per-edge execution counts and the existing
full Map values, aliases, mutation and deep controls. A separate experiment should
replace private continuation argument arrays and native String projection arrays
with proved local variables, then inspect CPU/allocation profiles before claiming
a win. Keep both interventions separate so a faster result has an attributable
cause. The observed13-times allocation gap is an opportunity estimate, not a
prediction of13-times execution improvement.

For small closures, specialize entry guards to the exact capabilities used by the
proved numeric kernel, retaining descriptor/mutation/Error tests. This could help
fixed entry overhead; it cannot explain Map's remaining tens-of-milliseconds gap.
The current implementation already beats TS on the larger closure input because
it removes the intermediate closure graph entirely.

Reading the paired emitted Map JavaScript adds two concrete distinctions. TS emits
Map.bit.go as ordinary recursive functions, uses Number-valued Nat counters there,
and reads native String components directly. Its tuples use named fields. Our
selected instance uses stack-safe continuation storage, BigInt Nat counters and
projection arrays. These differences motivate separate bounded-Number, bounded
native-recursion and projection-elimination ablations. Any native-recursion fast
path must retain the existing deep-input fallback; any Number Nat path needs a
proved exact range and original arbitrary-precision fallback. A source-level
comparison identifies these differences, but only controlled experiments can
attribute their speed contributions.
