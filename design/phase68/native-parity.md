# Phase68: remove native transport costs, then reduce C compilation costs

Registered 2026-10-08; work began 10:16:29 UTC at `b6eb5751f9bd460acfb7858b0ae8908e9335b6a0`.
Pinned upstream remains `059266225b77c8ca256ac6b25ee5c21449bab151`.

The user authorizes investigation, implementation, documentation and commits/pushes.
The ambition is upstream native runtime parity, or 0.5× its execution time;
this is a target, not a prediction. Afterwards improve B1 and B2 C compilation,
and share sound backend analyses where doing so reduces complexity.

## Frozen baseline and distinct metrics

Preserve the seven installed release files and 110 inherited Phase6 files before
changes. The installed checked B1 is `c76f1113…`, genuine B2 `cbffd1f8…`.
The previous six-family native result is 10.4136× upstream C, with array 84.99×,
numeric 7.20×, closures 2.46×, tree 9.78×, Map 5.90×, lexer 14.71×.
These limited-corpus figures do not describe all Bend programs. JS program speed
and historical JS request speed remain separate evidence (Phase67 report).

Record separately: native program execution, B1 Bend-to-C request time, B2
Bend-to-C request time, external Clang time, generated C bytes, conformance and
source complexity. Imports/cache preparation are distinct from requests. Keep
exact source/toolchain/API identities and output oracles in every receipt.

## 1. Bounded investigation before production edits

Budget approximately 60–90 minutes, stopping early when a strong hypothesis has
both a discriminating test and a small implementation. Replay cached native
binaries with the seven-second six-family loop. Gather instrumented allocation,
refcount, continuation/closure frequency deltas on numeric/array/lexer, paired
with pinned upstream. Where available, collect bounded gprof samples; retain
failed perf capability probes. Diagnostic clocks are never clean speed claims.

Read current Bend native and JS paths, emitted C and pinned upstream `comp.ts`.
Research primary compiler sources for transferable mechanisms, building on the
existing research rather than collecting unrelated literature. Two initial
source findings: native direct arity stops at a matcher, and its nominal direct
calls still use scheduler continuation frames. Upstream raises arity through
matching and uses ordinary C workers and multiword product layouts.

Deliverables: [upstream audit](../../research/phase68/upstream-native.md),
[world compiler research](../../research/phase68/world-compilers.md), native
request profile, ranked options with gain hypotheses, effort and falsifiers.
The estimates are overlapping hypotheses, not additive promises.

## 2. Composable, measured optimization slices

Start with match-aware saturated calls using existing typed JS arity knowledge.
Keep ordinary curried entries for partial application, erased arguments, bangs
and opaque functions. Bind residual matcher arguments explicitly to preserve
ownership. Evaluate effects and competing errors against upstream as well as
the old backend: an inherited semantic discrepancy must be identified openly.
Test the allocation mechanism, exact outputs and six-family runtime separately.

Next prefer the smallest general structural improvement supported by profiles:
forward fresh constructor/result fields without boxing; omit unused ordinary
entries when no partial/escaping use exists; or add eligible ordinary-C workers
and local joins. Flat workers require explicit ownership and return destinations,
not text rewriting of emitted C. Restrict initial eligibility (no bang, unknown
calls or unsafe recursion), retain adapters, and expand only when controls pass.
Typed arrays, borrowing and allocation reuse come after transport is removed
unless profiles show they dominate sooner. Avoid benchmark-name recognition.

Keep each candidate, failure and decision in its own hypothesis record. Apply
one causal slice before comparing; reject regressions even if another benchmark
improves. Broad gains justify integration. Do not stop solely because a modest
micro-optimization succeeds while the main measured mechanism remains.

## 3. B1/B2 C compilation and simplification

Measure real checked B1 and genuine B2 requests with mandatory preparation
outside the request clock, and upstream on identical inputs. Profile only the
request and record public stages. Separate repeated erasure, reachability and
annotation work from emission and external Clang compilation. First candidates
are reusing per-definition erased products and avoiding duplicate closure/direct
body emission; neither is accepted without exact emitted-output or semantic
qualification appropriate to the change.

Share arity or other pure backend facts in a small common module when this
removes duplication without pulling the JS emitter into native-only assembly.
Keep frontend checking and JS output exact where possible. Track physical/code
lines, modules, definitions and new concepts; a larger structured improvement
must earn its complexity in broad speed or a simpler invariant.

## Fast and slow gates

Root alone executes one guarded CPU3 target tree at a time (Node heap1GiB,
stack4MiB, tree RSS2GiB, available-memory floor4GiB). Source/research/review agents
use CPU0. Raw Phase67 and all earlier evidence remain immutable. All new raw is
under `selfhost/build/phase68`; reuse saved binaries and bounded fixtures.

The inner loop is checked B1, minimal native acquisition, independent golden/
error/ownership controls, and cached six-family timing. Candidate clocks under
100ms trigger common recalibration before a numerical claim. Do not rebuild
Clang products just to repeat runtime measurements. Agent lanes are independent
source audits, research, method preparation, candidate implementation and review;
heavy execution remains serial to avoid memory pressure and biased timings.

Only selected candidates earn genuine B2 construction, own-source checking and
self-reproduction, broader native threads1/4 controls, strict/diagnostic gates,
JS emitted-byte joins and appropriate retained frontend conformance admission.
Then install one checked version, validate installed interfaces, preserve old
release lineage, record all limitations and archive fresh evidence. Failed gates
block promotion, not investigation. Commit/push design, source and report
checkpoints; do not post PR comments.

[Live report](../../implementation/phase68/README.md).
