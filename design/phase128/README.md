# Phase128: eliminate ownership work and unused compiler work

Started 2026-10-23 from `00f9e0ea777bd0b01ee1e361112371353891ca19`.
Objective: faster cold source-to-QBE compilation without material regressions
in generated-program speed, correctness or simplicity. Parity is a research
objective, not a promised outcome of this phase.

## Evidence

Phase127's audited transport repair recovered 11.37% on three native requests
and 9.95% in one full-source pair. Changed compiler source still needs N1/N2
qualification. Preserve Phase126 and Phase125 qualified images.

The full-source profile attributes 40.03% of samples to destruction/reclamation.
The independent name-search proxy is 14.653x slower than upstream C and performs
millions of ownership operations despite little allocation. Upstream emits
borrowed traversal before Clang. This is not a 14x whole-compiler prediction;
context attribution and physical runtime percentages overlap.

Map also prepares and lowers a second candidate catalogue. Some flat workers
have exact symbols already in the ready set and are discarded after creation.
Avoid that creation before considering a general cache. Boxed factories may
produce additional workers and require a separate proof before skipping.

## Ambition levels

These expand research scope, not promised performance multipliers.

1. **Bounded plan:** adapt checked scalar-observer borrowing to the current
   pipeline; measure admission on the real name-search kernel; test independent
   ownership controls. Separately skip guaranteed-unused late flat lowering
   with byte-identical QBE. Integrate the transport repair and qualify a useful
   composition once.
2. **10x scope:** preserve borrowed fields and calls across a complete read-only
   search, with retained owning roots, nonescaping results, stack-safe recursion
   and independent verification. Require unrelated transfer and measure added
   compiler cost. Reuse immutable preparation only after simpler elimination.
3. **100x scope:** compact semantic ownership/name representations across passes,
   stable symbol identities and reusable verified summaries. Begin with a
   falsifiable extracted compiler computation. Do not undertake a wholesale
   backend rewrite or search framework simply to fulfill this ambition.

## Experiments and gates

- Freeze source/runtime/toolchain/input identities and independent output
  oracles. Compiler semantics remain in checked Bend. Host scripts only compose
  declarations, invoke tools and measure.
- Measure admission first. Correct fallback output is not optimization success.
  Preserve refusal causes, negative experiments and acquisition costs.
- Borrowing must preserve scalar result types, root lifetimes, unique/shared
  ownership, aliases, Unicode, fallback, call dependencies and stack safety.
  Keep independent request and final verification unchanged.
- Cleanup must produce byte-identical complete QBE on affected Map and
  unaffected requests, retaining candidate order and admission conditions.
- Use existing proxies for cheap falsification. Pair clean repetitions on CPU3;
  diagnostic profiles/counters do not establish acceptance timings. Use valid
  8/13ms sampling rather than rejected high-frequency samples.
- Acquire native images after useful proxy/transfer results. Distinguish hosted
  producer cost, N1/N2 cold requests, machine builds, generated-program runtime
  and complete research cost. Do not compare warm APIs with cold upstream.
- Retain geometric mean, positive log-slowdown, family effects, excess batch
  time and worst regressions. Native promotion requires source-bound hosted to
  N1 to N2 reproduction and independent correctness qualification.

## Research and resource discipline

Revisit existing research and official Zig, Go and Lean sources. Translate each
relevant principle into a measured opportunity; distinguish debug build speed
from emitted-code quality and compiler executable speed.

One coordinating agent integrates; bounded agents investigate borrowing,
ownership safety, discarded preparation and compiler research. Root owns one
serial resource-heavy lane. Use existing guards: checked API 4GiB, full compiler
up to 6GiB, minimum 16GiB available memory. Disk is nearly full; establish storage
headroom before full acquisition. Preserve unique evidence and qualified images.

Record stage costs, source growth and qualification separately. Commit the
design, reproducible results and an honest report with the next falsifiable test.
