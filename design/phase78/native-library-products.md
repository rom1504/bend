# Native library products: the larger remaining experiment

This extends [the Phase78 design](b1-parity.md), after the first exact-C screens.
It is a proposal to test, not an implemented optimization or a parity claim.

Compiler11 remains1.73× upstream in the short paired B1 screen. Numeric profiling
attributes about86ms to annotation,43ms layout,99ms native preparation,73ms static
preparation,92ms ordinary worker candidates,123ms observer routing and96ms final
rendering. These are coarse instrumented clocks; profiles overlap public stages.
`String.cmp` is the successful expensive observer route, not necessarily a failed
optimization. `Nat.read.trim` bears the first large annotation cost; cold JIT work
can be charged to that entry, so its time is not evidence of an algorithmic bug.

## Trial: compile an immutable library once

The checked Base world already has a persistent identity and disjoint-context
admission. Extend the *optional* prepared product with Bend-produced annotated
Base definitions, erased bodies/arity, static bodies, and private worker/observer
plans. The host only transports versioned products; all compilation and admission
logic remains Bend. No benchmark names or source programs enter the selection.

Start with a discriminator that records actual reused work and includes file read,
validation, decode, admission and request-time lookup. The earlier64-node annotation
product did not establish a cold gain, so storing more data is not automatically
beneficial. Abort or narrow if materialization costs consume its savings.

## Stability requirements

- Bind compiler, Base, core/span ABI and prepared-world graph identity. Reuse only
  after the existing checked prefix/world admission and disjoint-name check.
- Source annotation and public raw APIs keep their ordinary behavior. Never trust
  a user-created BookCache payload as a backend certificate.
- Native worker local counters are per-function, but static image locations and
  generic continuation labels are not. Do not cache emitted text containing
  request-dependent addresses without a relocation rule.
- A possible first static rule reserves the complete small Base static image as
  a prefix, then appends request statics. Measure unused image growth explicitly;
  later compact relocation is a separate optimization.
- Product signatures and observer layouts must come from the same immutable Base
  dependency closure. User definitions cannot supply missing library assumptions.
- Cache only admitted, segment-free workers initially. Negative candidate/retry
  results and generic continuation fragments require separate proof obligations.

## Measurements and promotion

Report the current fresh-process prepared-frontend-only baseline alongside a
separately labelled fresh-process **prepared native library** result. Charge all
request-time reading/admission inside the request clock. Report one-time product
construction, artifact size and RSS separately; never silently move measured work
outside the clock or call a warm-process result cold parity.

Require held-outs without the common benchmark IO reader, custom/changed Base,
shadowing, erased dependencies, static address correctness, exact or differential
C execution, B1/B2 and generated-program speed. A package containing these products
must invalidate them on compiler changes and support ordinary fallback. Only a
qualified usable release may become the default.
