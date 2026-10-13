# Phase80: checker types and compact body analyses

**Implemented and measured; no new compiler version promoted.** Whole-book
checker-type retention makes annotation substantially cheaper but enlarges the
graph enough to erase the benefit and regress held-outs. A second, compact
native occurrence-summary prototype saves **2.15%** on the three-source B1 loop,
with essentially unchanged small-program time and **1.31% slower functions65**.
That is a small, mixed result, not the proposed route to parity. Preserve the
implementations for reuse; keep the qualified Phase78 compiler as the default.

[Design](../../design/phase80/checker-to-backend-ir.md) ·
[type-retention experiment](../../experiments/phase80/P80-001-checker-types.md) ·
[analysis counts](../../experiments/phase80/P80-002-request-analysis-reuse.md) ·
[body summaries](../../experiments/phase80/P80-003-body-occurrence-summary.md) ·
[methods](../../selfhost/tools/performance/phase80/README.md).

## What was implemented

The checker already reconstructs completed terms and separates its chronological
semantic world from the graph published to backends. Compiler01 attaches retained
types to successful results, records constructor-field quantities, and replaces
type reconstruction during annotation with structural readback. Retained types
are normalized in the **final** specialized world; an early normal form is not
assumed valid after later declarations fill laws. Failure results and the semantic
world stay on their original paths. Lambda quantities and specialization's
consumed-argument count remain part of the boundary.

The first prototype passes frontend36 but fails the benchmark's prepared-Base
requirement. A diagnostic observes retained type binders up to3470 versus the
source prefix bound3464. These checking-local identities cannot simply be admitted
into a future suffix. Compiler02 preserves the original admission invariant and
drops retained annotations for affected Base definitions. Compiler03 additionally
omits annotations inside erased checking regions, retaining field boundary facts.
Both produce the complete expected C in their measured requests.

After those results, an observational probe on unchanged Phase78 investigates
upstream-style analysis reuse. It finds that different-binder occurrence queries
repeatedly traverse the same body. Compiler04 computes a body-local saturated
occurrence map using the existing checker quantity algebra and shares it within
constructor-sharing and array-sharing analyses. Compiler05 replaces its generic
term lists with two existing integer tries, representing used and multiply-used
binders. Sequential traversal increments with saturation; alternatives join by
maximum, implemented as set union. No node IDs, global memo, serialized product
or JavaScript implementation of compiler semantics is added.

All five implementations are retained as
[reviewable patches](../../experiments/phase80/prototypes/) and full frozen source
snapshots. The final working production source, driver and installed image match
Phase78 exactly. The last
[release verification](../../selfhost/build/phase80/final-restored-release-guard/process.json)
passes: B2 `cc99ac9b93def164705504e2d7f422240f7c288338e7a6c1d61a88c319e9c1f3`,
flattened source `1ac3aae05d8cf4bf12d4e91866ee63fec7537c3447e6d43934197d9c1146451a`.

## Controlled results

Each screen interleaves fresh processes against frozen Phase78 B1 and upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. The request includes user-source loading,
checking and complete C emission; imports, explicitly prepared Bend Base, Clang
and execution are separate. Upstream checks Base inside its request. Every Bend
role uses `backendProducts:false`. Output must match previously executed C
byte-for-byte. No process reuse or prototype B2 is measured.

Ratios below are candidate time / paired Phase78 time; lower is better.
Screens have two samples per role/case except compiler05's five. Held-out03 has
two, held-out04/05 three. These are bounded measurements, not a confidence claim
about all Bend programs. [Complete samples, medians and pins](measurements.json).

| Prototype | Numeric | Array.map | Lexer | Three-source mean | Small held-out | Functions65 held-out |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 02: all checked types |0.9967|0.9874|0.9975|0.9939|not run|not run|
| 03: live checked types |0.9849|0.9848|0.9928|0.9875|1.1741|1.0888|
| 04: list occurrence summary |0.9771|1.0294|0.9827|0.9961|0.9983|1.0054|
| 05: integer-set summary |0.9709|0.9846|0.9802|0.9785|0.9974|1.0131|

Compiler04 includes an unusually slow Array candidate sample; it is retained,
not discarded. The final compiler05 screen uses45 fresh requests. Its median
times are:

| Source | Phase78 B1 | Prototype05 B1 | Pinned TypeScript |
| --- | ---: | ---: | ---: |
| Numeric |1185.1ms|1150.6ms|696.2ms|
| Array.map |1207.2ms|1188.5ms|703.2ms|
| Lexer |1635.8ms|1603.4ms|890.4ms|
| Small, separate held-out run |332.6ms|331.7ms|301.7ms|
| Functions65, separate held-out run |671.3ms|680.1ms|365.8ms|

The final three-source prototype ratio is1.71338× TypeScript versus1.75097× for
the paired baseline. It does **not** replace the official Phase78 B1/B2 results;
it is a different measurement campaign of an unpromoted B1 prototype.

## Why type retention did not pay off

The separate two-profile comparison confirms that the intended local saving is
real. On Numeric, compiler02's annotation stage falls84.86→25.51ms. But annotated
context construction increases20.87→33.93ms; the source-completion stage containing
prepared graph handling rises110.93→141.78ms. V8 attributes13.05→21.55ms of
exclusive samples to `decodeBaseArena` and8.44→19.55ms to `norm_max_term`.
These are noisy diagnostic observations, not additive clean-time accounting.
[Stage clocks and complete profiles](profiles.json).

Prepared Base grows **1,182,240→2,160,193 bytes** in screen02, and explicit
preparation takes3.220→4.184seconds. This is part of the existing checked-prefix
payload, even with optional backend products disabled. Avoiding inference while
shipping and scanning more generic term nodes is insufficient. The live-only
version still saves only1.25% on the IO-based screen and loses badly on the two
smaller held-outs. Do not promote either or expand them into a global typed-IR
rewrite based solely on annotation-stage savings.

## What the analysis counters establish

The counters wrap the unchanged compiled Bend functions, recompute every original
result and require exact C. They distinguish exact argument tuples from term-only
identity. Instrumentation drains B1 trampolines and materially changes costs;
recursive inclusive times overlap. Counts are the useful evidence here, not a
prediction that all sampled time can be eliminated. [Full records](analysis-counts.json).

| Analysis, Numeric | Calls | Repeated complete argument tuples | Additional observation |
| --- | ---: | ---: | --- |
| `nc_uses` |2,658|110|2,548 distinct root terms|
| recursive `nc_uses_term` |28,697|52|5,450 distinct terms; accumulator differs|
| `nq_uses` |49,732|1,099|271 top-level queries on45 root terms;2,243 distinct terms overall|
| `nd_arity` |882|729|153 distinct book/name tuples|
| `nc_erase` |3,160|166|most exact repeated calls are small|
| `wnf` |16,141|5,240|key includes the actual immutable book|

A generic `(term,id)` cache misses most occurrence work: different IDs ask
different questions over the same tree. A per-body summary is the better
algorithmic formulation, and the prototypes validate that formulation. Its
end-to-end benefit is nevertheless modest after charging construction and lookup.
The existing frontend graph should not be enlarged just to support these facts.

These counters do not rule out bottom-up subtree summaries, batching other
queries, or better retention through rewrites. Nor do they justify a term-only
normalization cache: changing books and environments must remain in its key.

## Correctness, complexity and selection

- Five checked B1 builds each pass the same frontend36 gate with zero exact
  differences; this is36 distinct selected witnesses, not180 distinct tests.
- All147 clean requests, two V8 profiles and two analysis-counter requests
  preserve the expected complete C. Cases cover Numeric, Array.map, lexer,
  small and functions65, with different coverage per prototype above.
- Both summary representations match the old Bend query on1,206 deterministic
  generated trees and15,678 binder queries each. Cases include branch maxima,
  saturated sequential sums, NWPattern rows, malformed Vars/Mat arities and
  U32 boundary IDs. This is a finite differential check, not a compiler proof.
- First prepared-Base failure and an initial diagnostic launch missing its API
  environment are preserved. No OOM or compiler-build failure occurred.
- Prototype02/03 adds82 physical/63 code lines and one module. List summary04
  adds34/25 lines; integer-set summary05 adds66/51 lines and one private datatype.
  Neither summary adds a module. Production has **zero net source growth**.

[Build identities and qualification boundaries](qualification.json).

The original representation experiment misses its5% discriminator and regresses
held-outs. The narrower summary is promising as a component but insufficient as
this phase's production change: about2% on the main loop, no held-out gain,
added representation and maintenance cost. **Defer the summary patch; reject the
whole-book typed representation.** This is an engineering selection decision,
not a claim that the summary is semantically wrong or has no local benefit.

No new full frontend/native100/raw31/JS45/runtime campaign, genuine B2 self-check,
B3 reproduction or installation is claimed for these prototypes. Running those
gates before a worthwhile selection would spend time without resolving the
failed performance hypothesis. The unchanged installed Phase78 retains its
[existing qualification](../phase78/source-qualification.json): historical paired
B1/B2 C ratios1.73205×/1.38187× upstream, native execution1.06678× on12 families,
seven known reference native failures and13 broader native API gaps. Its source
remains32,471 physical/26,523 code lines in132 modules.

## Next boundary and work accounting

Upstream's useful lesson is to make facts cheap to produce, retain and consume.
Copying its typed-output shape into our larger generic term/transport format did
not reproduce its performance advantage. The next larger prototype should bind
compact backend facts to the already-produced native body and replace multiple
consumer traversals together, with no frontend/cache enlargement. Benchmark its
**whole request** and functions65 before widening it. Treat node IDs as a possible
implementation detail, not a performance result in themselves. Preserve the
original frontend and qualified fallback until that boundary demonstrates a
material gain. There is no measured projection to1× or0.5× from this phase.

Targets ran serially on CPU3, bounded to2GiB aggregate RSS, with4GiB available
memory floor and Node1GiB heap/4MiB stack. Peak aggregate RSS was1.60GiB.
[Guard accounting](timing-account.json) records10.68minutes supervised execution
within a38.96minute first-target-to-last-target span. About28.28minutes inside
that span were between guarded jobs; reading, reasoning, implementation and
method/report work dominate that interval, rather than validation waiting.
Initial design work and later preservation/reporting lie outside the recorded
span. No quota estimate is inferred from wall time. No agents or PR comments.

[Complete verified evidence](../../selfhost/tools/performance/phase80/evidence01/README.md)
preserves frozen candidates, failed setup, observations, C outputs, profiles,
methods and release verification.
