# Architectural synthesis: share facts, keep boundaries explicit

The research points toward a bounded component analysis serving the existing
JS emitter. It does not establish the need for a replacement compiler, a new
public representation or a general optimizer IR. This document is a proposal
to evaluate after isolated component experiments, not an implemented design.

## Current conceptual load

A contributor must understand typed source terms, erasure/arity, generic runtime
descriptors, deferred forcing, exact-entry permission, private plans, helper
capture, graph purity, host protocols and fallback. Several optimization families
ask overlapping questions. Some overlap is deliberate: pure does not mean fully
demanded, a known tag does not imply inert fields, and an internal function name
does not imply an unchanged public descriptor.

The simplification target is repeated **reasoning**, not simply fewer functions.
Combining all checks into a large predicate would hide obligations. A small
fact vocabulary with named refusals can let one analysis answer the same question
once and let multiple emitters consume it consistently.

## Minimal proposed fact vocabulary

| Fact | Producer | Consumer | Invalidation / refusal |
| --- | --- | --- | --- |
| Live signature and saturation | Checked type + erased-argument analysis | Direct calls and wrappers | Body/type/book context changes |
| Known callee and captured environment | Closed call graph / bounded callback specialization | Private call edge | Unknown function, partial call, mutated dependency |
| Constructor and field shape | Checked type plus construction/projection facts | Match selection and field layout | Unknown tag/field, observable mutation or host hook |
| Ownership, escape and representation permission | Private provenance plus explicit alias/lifetime analysis | Container elimination or reuse | Surviving observer, escaping alias, callback or uncertain lifetime |
| Demand point and cardinality | Existing prefix/producer proof, conservatively extended | Field materialization, worker result | Deferred or duplicated evaluation not justified |
| Control edge | Tail analysis of original term | Local loop or explicit frame | Non-tail use, escaping continuation |
| Host dependencies and scope | Purity graph plus runtime-protocol use | Entry guard, proof coverage | Callbacks, effects, unknown native, exception reentry |

Facts should be carried by a compact analysis result over existing typed terms
and stable binding IDs. Do not introduce a second general AST merely to encode
“known call” or “known constructor.” Existing plans may still be the output of
this analysis. Every fact should pay for a concrete removed runtime operation
or an eliminated duplicate compiler query.

Known shape is not ownership, and neither is full demand. An alias need not
invalidate a known immutable tag, but it may forbid mutation or replacing an
object's representation. A compiler-created value may still contain deferred
fields. Keep these facts independent rather than encoding one broad “private” bit.

Use explicit bounds: graph definitions, visited nodes, specialization clones,
unfolding fuel and output growth. Current finite/root limits are examples, not
universal limits for a new analysis. A refused optimization must leave the
ordinary path correct and bounded; it must not execute callbacks while probing.

## Worker structure

```text
public descriptor / partial-application stages
  -> exact entry and current dependency/host checks
  -> proved private component
       known saturated calls -> direct workers
       tail edges -> existing loop/frame strategy
       known data -> existing tagged layout initially
       unsupported edge -> refuse component or retain proved residual path
  -> existing result boundary

failed admission -> original generic behavior
```

Entering the component is an observable boundary. Its guard cannot assume a
previous call's host state is still valid. An internal residual must obey the
proof's scope; an arbitrary generic callback is not automatically safe because
the source is pure. Error construction suspends the proof for reentry, as the
existing runtime already does.

## Staged migration that can reduce complexity

1. **Inventory, no behavior change.** Count duplicate analyses and annotate their
   inputs. List every owner control. Distinguish shared syntax from shared proof.
2. **Unify one fact.** Replace repeated live-signature or dependency queries with
   a request-local result. Require identical emission, including refusal cases.
   If context is not in the cache key, do not cache the query.
3. **Reuse for one new edge.** Direct tagged recursive calls get a component
   summary and an explicit proof boundary. Preserve all public wrappers.
4. **Confirm a second family.** A callback/list or map component should consume
   the same facts without source-name exceptions. Otherwise keep the change local.
5. **Delete old duplication.** Retire superseded walkers and special-case paths
   after mapping all previous owner controls to the replacement.
6. **Only then change representation.** Measure remaining allocation and choose
   destination emission, unboxing or reuse as separate experiments.

Each migration has its own design, report, emitted-code diff and complexity
account. It is not acceptable to call a larger abstraction “simpler” while
leaving both old and new paths indefinitely active.

## Complexity scorecard

Record physical/nonblank lines, definitions, types, modules and generated bytes,
but also count independent representations, runtime protocols, analysis walks,
facts with invalidation rules, and fallback/admission owners. Record the number
of files a reviewer needs for one direct call, one constructor match and one
tail cycle. These are reproducible scenarios, not an invented universal score.

The provisional deletion target is 5–15% of the JS backend, not 50% of the
compiler. A stronger result would be one new optimization expressible using
existing facts and one emitter change rather than a new family of walkers.
No target justifies deleting documentation or semantic controls to shrink LOC.

## What research changes in our strategy

MLton/Flambda/TS favor known-call facts; GHC emphasizes demand and sharing;
Chez emphasizes pass invariants; Zig/Cranelift emphasize bounded analysis and
compiler cost; Lean/Koka constrain ownership assumptions; V8/JSC constrain
speculation. Together they favor a **small shared analysis with a larger useful
private scope**, rather than more narrow guarded leaves or a large optimizer
whose cost has not earned its place.

This can improve generated speed and reviewability together, but source reduction
and compiler speed remain hypotheses. Measure all three instead of treating an
architectural analogy as evidence of success.
