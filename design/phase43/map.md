# P43-002: guarded Map component

Status: saved-JS controls and supplemental mechanism screen passed; source
prototype awaits checked compiler admission. Phase42 Map32/128
remain approximately91× TypeScript with about48× sampled allocation; the isolated
per-edge Map.bit rewrite regressed44%/30%. That experiment does not identify how
much cost came from repeated guards.

The smallest discriminator has three roles from one saved module: unchanged;
one enclosing scalar-request guard and direct prefix-bit control; the same guard
and direct complete seek/put/ins/pop control. Both candidates retain source
crit-bit positions, key reconstruction, order, native Tuple/Maybe/Map constructors
and scalar payloads. String.cmp and Map.diff remain exact residual calls. This
makes the whole role a graph-control discriminator, not a claim to remove every
String allocation. Expected useful outcome is a large family gain (target ≥2×);
whole failing to beat amortized rejects immediate graph integration.

One operation guard would require immutable public graph ownership or a validated
observer-free graph. A WeakSet alone is insufficient because callers can mutate a
previously returned Map. This discriminator instead owns an enclosing scalar
request: fresh Maps stay inside its synchronous call graph, and only the scalar
result escapes. Public Map APIs and observer-bearing arguments keep generic
execution. Fixture APIs exposing full maps exist only in research modules.

Guard dependencies are the actual emitted reachable graph, including native
runtime overrides. The guard refuses any changed binding/descriptor/code/env,
post-import host/prototype hooks, active proof, reentry or non-UInt32 scalar
arguments. Keys admitted to direct bit are ASCII at most64 UTF16 units; remaining
keys use generic Map.bit. Direct workers use explicit frames, never native
recursive descent. No regionProof is opened. String project/ctor operations retain
the native ABI rather than replacing reconstructed keys with original strings.

## Generic compiler implementation path

Extend the component planner, not an owner-name allowlist. Starting from any
eligible saturated definition, establish exact closure rows for its whole
reachable graph; prove inputs and return scalar, each Map root fresh, all payloads
scalar, no intermediate Map escape, and all remaining effects observer-free under
explicit host-family obligations. Carry String host obligations separately from
JPure. Emit one entry guard, then direct owned workers and an exact generic
fallback. Ground Map/String rows require quantity-specific constructor proofs;
shared String/Sigma consumers must be qualified immediately. No benchmark-name
special casing, key replacement, new dictionary representation, altered crit-bit
algorithm or Unicode permission follows from this ASCII diagnostic. The preparer
accepts an explicit root argument and checks source shape; those checks are not
this compiler proof. Production implementation belongs to root after correctness
and timing survive.

Literal source fixture: [fixture.bend](../../selfhost/tools/performance/phase43/map/fixture.bend).
It intentionally returns complete content; it is a correctness fixture, not the
scalar enclosing-boundary timing fixture.

The saved discriminator now meets its family hypothesis: root measured 2.64× and
2.76× whole-Map speedups over original at32/128. The residual 33.0×/28.2× gap
to TypeScript prevents claiming that Map control alone solves the application.
The coherent source prototype specializes erased prefixes only at saturated known
calls, retaining original definition identity and exact slot facts in request-local
JSPlanContext. Its separate analysis view proves live specialized signatures with
JPure and emits lexical workers using existing explicit component stacks. Exact
original guards and native String family obligations remain boundary conditions.
