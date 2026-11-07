# Phase176 — calibrated software experiments before expensive qualification

Start: `de627cb`, Phase175 maintained source; installed Phase171 is unchanged.
The current result is 56.219s for an extracted complete frontend and 178.937s
for one fixed-source complete build. These have different measurement boundaries.

## Question and decision

Can a small software tournament reject weak frontend changes much faster without
rejecting genuine improvements? Then can it test a specialized stack-safe
semantic traversal, rather than another tiny parser lookup?

Phase175 spent 2,799.683 guarded target seconds across 62 runs. About 899s were
full images/reproduction/cold pairs and another 283s broad validation. Those are
largely fixed integration costs. We aim to improve screening throughput first;
3–5× screening and 1.5–2× campaign throughput are hypotheses, not promises.

## Gates and budget

1. Reuse authenticated Phase175 native images. Construct a manifest of independent
   comparisons on closed, real compiler sources at two smaller sizes. Calibrate
   lookahead (known positive), precedence (neutral), field reuse (neutral/slower),
   and combined changes (positive). Try the earlier regressing indexed store if
   its retained interface and inputs are compatible; otherwise explicitly exclude
   it instead of fabricating an equivalent baseline.
2. Run the identical manifest serially and with two workers under **one aggregate
   disk/process guard**. Use disjoint CPU affinity. Record aggregate wall/CPU/RSS,
   failures, complete outputs and child timings. Concurrent timings measure
   throughput and screening only; final candidate timing is isolated on CPU3.
   Never nest guards. Start with two workers; more require a measured benefit.
3. Determine whether small inputs preserve previous positive/neutral decisions.
   A weak or inverted signal rejects the proxy, not the compiler change. Keep
   complete 3.15MB compiler input held out until a useful smaller signal exists.
4. Inspect a real semantic traversal with generic continuation overhead. Implement
   one experimental Bend work machine with explicit bounded-stack frames if its
   semantic and cost obligations are tractable. Compare complete values to the
   unchanged implementation, including binder/quantity/aliasing cases. Include
   full construction and destruction, not only the inner walk. Source checking,
   finite equality tests and mathematical proofs remain distinct.
5. Use fast/scaling screens before at most one complete frontend comparison.
   Acquire/qualify a complete compiler only for a material transferable gain.
   No installed change or broad campaign merely to validate experimental tooling.

Keep initial calibration below five guarded minutes, semantic prototype below
one hour if practical, and stop/reassess if image acquisition or disk dominates.
Disk admission retains the 5GiB reserve; current free space barely exceeds it.
Reuse images and record small receipts first. Never delete historical evidence.

## Experiment implementation

The scheduler is host process/measurement tooling, not compiler logic. Bend still
executes parsing, semantic checking, traversals and observations. Reuse existing
pinning, native-image receipts and timeout helpers; no new compiler cache or
autonomous framework. A manifest identifies exact inputs, commands, output roots,
budgets and calibration expectations. Record all outcomes, not only winners.

Final claims separate output equivalence, component latency, full process cost,
batch throughput, acquisition cost and complete build time. Timing order rotates;
small noisy differences are neutral. Digests supplement independent full-value
oracles and never become a soundness claim.

## Research hypotheses

Successive resource allocation is inspired by
[Hyperband](https://www.jmlr.org/papers/v18/16-558.html), without transferring its
results to this compiler. [Defunctionalization](https://www.brics.dk/RS/01/23/)
suggests specializing the generic continuation machine for a complete traversal.
[Lean's borrowing/reuse](https://arxiv.org/abs/1908.05647) and
[rustc arenas/interning](https://rustc-dev-guide.rust-lang.org/memory.html)
suggest preserving ownership and lifetime information. Much analogous machinery
already exists here: prior owned decomposition and indexed-store experiments
failed to improve full builds. A new prototype must name the work it actually
avoids and measure it. No speculative arena or universal IR rewrite.

**10× ambition:** calibrated real-input replay plus direct stack-safe semantic
machines makes structural experiments cheap enough to test multiple alternatives.
**100× ambition:** reusable checked semantic units and compiler-generated legal
traversal variants turn repeated reconstruction into durable facts. This is a
research direction, not part of the initial implementation or a speed claim.
