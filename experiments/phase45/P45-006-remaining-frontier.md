# P45-006 — Remaining runtime frontier and public entry guards

Read-only diagnosis, 2026-10-04. No compiler/runtime edits, target execution,
new timing or qualification claim. Phase44 checked04 evidence is historical;
Phase45 worker work is in progress.

## Quantitative frontier

The exact [Phase44 summary](../../selfhost/build/phase44/full-runtime-summary04.json)
has 45 points / 23 sources / 669 samples. Candidate slowdown is 6.0832× TS by
point and 8.3015× by source. Contributions below are shares of log geometric
slowdown, not elapsed runtime or recoverable optimization estimates.

| Group | Candidate / TS | Point log-gap share | Source log-gap share |
| --- | ---: | ---: | ---: |
| Four library tests, records, Map churn | 25–71× | 38.56% | 49.11% |
| Raytrace | 18–26× | 11.56% | 12.63% |
| Unicode and lexer | 7–22× | 14.85% | 10.37% |
| Generic row and scalar zero | 56–62× at those points | 10.04% | 9.30% |

The last source share includes other points from those sources. Counterfactually
putting the first six sources at parity still leaves 3.0324× point / 2.9362×
source slowdown. Putting the first three groups at parity leaves 1.8825× by
point. Closures and list pipelines already average near parity. Focus broad
mechanisms on mixed library graphs rather than another specialized callback case.

The [Phase44 profiles](../../implementation/phase44/diagnostics.md) estimate
records allocations at 46.39× TS and Map at 13.53×. They motivate removal of
transient argument/frame/constructor storage; they do not quantify its achievable
speedup. The current worker IR removes private generic dispatch and field
projection, but worker-emit.bend still emits a new register vector for each
JWDirectCall, saved register arrays for non-tail calls, ctor field arrays and
callOwned vectors for JWNative. General liveness/frame reuse, owned
constructor/destructor cancellation and first-order closure conversion remain
eligible mechanisms. P44-002 retained generic dispatch and was rejected; adding
another known-target invocation helper is not supported by that result.

## Public guard diagnosis

Source sites are selfhost/src/runtime/js/core.mjs: invokeExact (40),
scalarGuard (124), localGuard (157), regionHostGuard (198), stringHostGuard (236),
and source selection in region.bend:132–157, tree.bend:771–789 and fold.bend:248.
Line numbers describe the inspected current tree and can move.

The actual Phase44 scalar-region G["bench"] root has six dependencies:
bench, mit, b2u, asr8, sel, sel.go. Its guard is exact entry + native scalar
input tests + localGuard($guards). It has **no regionHostGuard call** and no
regionProofOpen in its chosen flat scalar body. Therefore shrinking the full
numeric host inventory cannot explain its scalar-zero deficit: 4.165 microseconds
versus 0.067 microseconds TS. Successful localGuard→scalarGuard inspection entails
77 descriptor reads and 18 prototype reads for these six dependencies, excluding
invokeExact and argument validation. This is a static count, not a CPU attribution.
Each dependency additionally creates [a,c,e,b] and an every callback; the protocol
scan builds a spread array. G/code/env/bound identities remain freshly checked.

Cross-entry guard memoization is invalid: public G bindings, descriptor fields,
code.call, bound, prototypes and host methods can change between calls. Error
construction can reenter, so proof suspension/restoration in bad and finally
cleanup must stay. A result cache is likewise outside this hypothesis.

A narrow general experiment can compare an allocation-free private metadata
plan against the current guard while retaining the same descriptor/prototype
check order and short-circuit decisions. The plan contains names and privately
captured snapshots, not results of prior validation; descriptors remain read
on every public entry. Where array every/spread mechanics are removed, first
establish the required canonical host/protocol capability. A mutated Array.every
or reflection hook must retain the old guarded path rather than silently skip
its observable callbacks. In roots already calling regionHostGuard, reuse its
successful **per-entry** capability to avoid duplicate Array/Object prototype
and protocol checks in localGuard/scalarGuard. Do not grant that capability to
scalar-only roots that never ran the host guard.

A broader follow-up collects a precise capability from both emitted worker
operations and the generic ABI operations being removed. It cannot consider
only arithmetic in the leaf: skipped force/apply/constructor demand can observe
protocol markers and changed native methods. Reuse existing exact proof context,
source identity and guard finally boundary. Capability-specific omission is
safe only for hooks proven irrelevant to that entire execution path; preserve
full fallback for unknown/foreign/dynamic calls.

Cheapest discriminating experiment: unchanged checked emitted module versus
saved guard-plan instrumentation only, ordinary public entry at zero/small/large
inputs across at least two unrelated sources. Count exactly one root admission,
fresh dependency validation and clean proof restoration. Compare complete values
and event/error traces under G binding/code/env/bound getters and mutations,
Function.call/Array.every/iterator/prototype markers, numeric/String hooks and
Error-hook reentry. A zero-point benefit without small/large or mixed-source
benefit is fixed-cost evidence only; no broad parity claim follows. Root owns
serial execution. This record adds no executable derivative.

## Why the tiny library roots bypass workers

Actual Phase44 modules under selfhost/build/phase44/full-preparation04/modules/
show morning and evening main.out as fn(0,function(){...}), without scalarCapture,
exactCode, scalar root markers or any regionProofOpen sites. Their helper
registrations still contain guarded private alternatives, but regionProof remains
null through ordinary entry. This is generated-source evidence, not inferred
activation counters for the new Phase45 image.

j_region_capture_eligible (region.bend:97) and j_pure_eligible (jpure.bend:152)
require arity>0; j_pure_call (262) rejects arity zero except exact String literals.
Thus general closed nullary runtime values have no owning root proof. Nullary
get auto-invokes each current descriptor; adding a worker must preserve that
execution and demand timing, not memoize a value or fold this fixture's output.

Morning also exposes a distinct first-order grammar gap: Str.split returns
Char→List<String>, and Str.join returns String→String; generated code contains
nested callOwned applications and fresh returned descriptors. Admitting main.out
alone cannot make this graph completely JPure. A general known-function-value
representation with capture, saturation and escape facts is required, or this
part must remain generic. Evening has no analogous user-defined returned-function
chain in the inspected source, but calls the nullary fpart and combines mutable
Array.swap/F32 operations with Map/Set and parsing. Zero-arity admission alone
does not prove those effect/native boundaries safe.

This separates three hypotheses: closed nullary root coverage, compositional
function-value lowering, and repeated guard/allocation cost. An ordinary-entry
counter on a fresh selected Phase45 emission is required before attributing a
performance result to any of them.
