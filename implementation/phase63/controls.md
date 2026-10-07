# Phase63 independent correctness review and focused controls

Status: controllers and source review are prepared; this document does not claim
that a controller passed before its root-owned execution receipt exists.
Production edits belong to the Base, frontend, backend and host owners. This
reviewer neither runs compiler targets nor modifies installed artifacts.

## Boundaries that must remain separate

1. A checked Base prefix is not merely a parsed book with a matching digest.
   New ready worlds and parser indexes inherit the existing private, trusted-local
   producer contract, bound to API, Base bytes, canonical path and source range.
2. A private native carrier proves that the actual leading Base injection was
   followed by unchanged native module completion. Caller-created API/seed/carrier
   objects must not acquire that permission.
3. Reusing immutable state must reproduce the complete checker world, fresh bound,
   diagnostic, event order, checked output and source provenance. Matching final
   JavaScript alone would miss checker-state corruption.
4. A lowering plan owns one exact annotated context. Its runtime dependency set
   does not establish that compile-time type lookups are independent of definitions
   removed from runtime output.
5. Correctness diagnostics, clean latency, self-reproduction and installation are
   independent gates. Instrumented derivatives are never qualified compiler images.

## Focused prepared-world differential

Controller: [prefix-world-v1.mjs](../../selfhost/tools/performance/phase63/controls/prefix-world-v1.mjs).
Its [derivation](../../selfhost/tools/performance/phase63/controls/prefix-world-v1.derivation.json)
identifies the unchanged Phase61 carrier-v3 parent. Existing controlled cases are
reused rather than constructing another independent checker oracle.

Required actual helpers: `base_prefix_world_prepare`,
`base_prefix_check_world_load`, `base_prefix_resume_world`, plus the existing
Phase61 checker/carrier functions. The controller verifies the checked attempt,
recovers an exactly reversible diagnostic derivative, and compares three paths:

- ordinary `dg_check_world` on the whole book;
- original prepared-prefix replay;
- the new prepared-world consumer.

The assertion compares the entire `DChecking` value and complete driver result.
A single produced `KBasePreparedWorld` is deeply frozen and hash checked across
repeated and distinct sources. Existing cases cover changed/dropped/reordered
prefixes, suffix law/name collisions, constructor capture, reserved names,
empty suffixes and higher fresh-ID floors. New cases cover false-ready state,
oversized deltas, invalid stamps and an intentional Base/suffix full hash collision.

The independently computed collision is `Nat` and
`phase63.collision.RTPZTk`, both FNV-1a hash `2015040876`. The controller checks the
actual native hash and requires the collision path to invoke original replay,
not the reordered prepared world. The [fixture](../../selfhost/tools/performance/phase63/controls/base-collision-v1.json)
is data-only evidence until that compiler control executes.

Run from the repository root under the root's single supervisor, replacing the
attempt and new output paths. One Numeric source is the fast selector; adding
MapSet exercises the same prepared world across structurally different requests.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 180 --rss-mib 2048 --available-mib 4096 NEW_JOB -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase63/controls/prefix-world-v1.mjs \
  CANDIDATE_ATTEMPT \
  selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend \
  selfhost/tools/performance/phase37/fixtures-historical/test-map-set-ops.bend \
  selfhost/build/phase63/NEW_PREFIX_OUT
```

These private-helper controls assume that the host paired the prepared world and
load from the same Base producer. They do not reinterpret a shape-valid forged
snapshot as a proof. Host identity and raw-public refusal remain separate controls.

## Focused single-lowering reach differential

Controller: [plan-reach-v1.mjs](../../selfhost/tools/performance/phase63/controls/plan-reach-v1.mjs),
with its [derivation](../../selfhost/tools/performance/phase63/controls/plan-reach-v1.derivation.json).
It reuses Phase61's 22 scanner and 21 graph controls per role. The candidate calls
actual `jd_plan_visit`; the baseline calls original `jd_reach_visit`.

A diagnostic emitter supplies explicit metadata, so each successful graph has an
independent reach closure and expected output ordering. Checks include duplicate
roots/edges, self and mutual cycles, unknown targets, unspecialized roots,
unreachable invalid bodies, exact definition/edge fuel refusal and malformed
metadata. Each reachable definition must be lowered exactly once. The saved text
must concatenate in original definition order, not discovery order.

```sh
python3 -B selfhost/tools/performance/phase32/bounded-run.py \
  --seconds 120 --rss-mib 2048 --available-mib 4096 NEW_JOB -- \
  taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase63/controls/plan-reach-v1.mjs \
  BASELINE_ATTEMPT CANDIDATE_ATTEMPT \
  selfhost/build/phase63/NEW_PLAN_OUT
```

This proves neither real lowering nor final-context equivalence. The backend
owner's real-source controls separately compare pruned and full annotated
contexts, runtime values/events, foreign demand and SCC behavior. Retain the
existing JDText small/cap tests if its representation or scan limits change.

## Independent source review

### Prepared world

The old public state APIs remain intact. The new producer builds from an admitted
prefix using original replay, retaining raw context values separately from checked
output. The consumer reconstructs only suffix declarations, preserving original
Base-before-suffix raw-list order and request-specific stamp/fresh bounds.
Cross-prefix full hash collisions explicitly select original replay because
bucket insertion order can change even if lookup values do not. The collision
fixture above is required before treating this case as qualified.

The driver must couple `prepared.prefix` with the exact injected raw book and
`prepared.state` with the admitted checker state. The consumer intentionally uses
a stored prefix-bound fact; comparing only counts or independent payload digests
would not establish this coupling.

### Frontend scopes and validation

Source reviewed: `load/prefix.bend`, `load/modules.bend`, `load/graph.bend`.
No source-level semantic blocker was identified in the initial candidate.

- Name extension visits declaration events forwards and replaces existing values,
  matching `index_build(reverse(prior))` and retaining the latest law/fill event.
- Constructor extension visits parent, children, then siblings and writes only
  missing names. This has the same first depth-first lookup winner as the old
  reverse-fold/overwrite `f_ctor_index`.
- Indexed completion retains the old alias filling, namespace/path changes,
  source intervals and error-selection helpers.
- Prefix preparation establishes no frontend Error and no duplicate-name error.
  Checking only the suffix therefore preserves whole-book error precedence;
  error refinement still receives the complete graph.
- A failed ready certificate or completion reverts to the ordinary carrier path.

The frontend owner's actual controls must cover imported law/fill pairs,
namespace constructor/name ambiguity, malformed suffixes, duplicate declarations,
prior errors and rejected seed producers. Internal index node ordering need not
match when hash collisions preserve the same lookup winner; complete completion
and trace values must match.

### Backend plan

`JDPlan` builds call facts from the original full annotated selection, lowers only
visited definitions, follows their actual JDText references, and renders saved
text in retained source order. Review finds the old visit, edge and definition
budgets and error selection retained. Unreachable invalid bodies remain unlowered.

The outstanding semantic obligation is using the full annotated context for final
emission and host wrappers where the old path re-overlaid only retained definitions.
`ka_def` preserves definition types/constructors/flags but transforms bodies;
normalization strips annotations, yet aliases can expose beta reduction, literal
representation or nested annotated arguments to type/host queries. Finite text
agreement on the 23 benchmark inputs is useful evidence, not a general proof.
Real controls should include Data families, beta-reduced erased aliases,
parameterized recursive ADT aliases, native/Nat host conversions, unequal-width
mutual SCCs and erased/dead foreign initializers.

### Graph transport

Initial `base-cache-graph.mjs` review finds a closed constructor/field schema,
strictly backward typed references and source/literal validation. Structural
interning includes all fields, origins and flags. It preserves values while adding
immutable sharing. Required host conditions:

- mandatory raw-book root must not be null;
- optional corrupt graphs discard accelerators, while mandatory book corruption
  rejects the cache;
- decoded prepared-world prefix/state must be the exact corresponding decoded
  raw-book/checker-state objects;
- public injected APIs cannot select private world or loader capability paths;
- frame/version/API/Base/path/span/producer invalidation and deep freezing remain.

Graph root nullability and trusted producer assumptions are intentionally called
out separately from structural decoding. The codec does not semantically prove
that an independently fabricated world represents its prefix.

## Integration decision

Run focused controls before spending on broad timing. A successful candidate then
needs actual source semantic/diagnostic gates, 23 raw-module and 45 observation
checks, separate genuine-B2 self-reproduction and own-source checks, and the
existing guarded latency protocol. Reuse an existing qualification when the
consumed implementation and artifacts are identical; do not claim a fresh result
from a historical receipt or skip a changed semantic boundary.

## State09 suffix-carry review

The ready frontend now carries the exact completed fragment in private
`FIndexedCompletion`. The initial seed establishes
`graph.book = prefix ++ suffix`, with an empty suffix and `count = length(prefix)`.
Each indexed completion uses the very same `fragment` both in
`f_graph_finish_module` (which appends it to the prior graph) and in the ready
carrier (which appends it to the prior suffix). Consequently the invariant is
preserved without rediscovering the fragment by dropping the Base prefix twice.
The old `matched && appended` checks were necessarily true on this admitted path.
A nonempty completion error still downgrades to the ordinary, non-ready carrier.

This is a producer-invariant argument, not permission inferred from a Boolean.
The host still creates the carrier locally, grants the path only to its own API,
threads native completion results without modifying them, and never accepts a
caller-provided carrier through `discoverSources`. The count/state equality at
seed creation is only one part of that private producer contract.

Manually fabricated or modified `FReadyPrefixGraph` values are outside that
contract. For example, an inconsistent count or an invented suffix can yield a
different `ready` flag or reconstructed trace now that the old drop operations no
longer incidentally reject or repair that inconsistency. Those drops never proved
that the supplied prefix, names, constructor index or freshening state belonged
to the graph, so the previous implementation also did not make arbitrary ready
carriers safe. Exporting the native functions for driver plumbing does not turn
these internal values into validated public snapshots.

Public raw entry points (`discoverSources` with supplied API/seed,
`f_graph_trace`, and `f_graph_trace_from_prefix`) retain their existing permission
or structural validation. The documented preservation claim covers those entry
points and correctly produced private carriers; it does not claim equivalent
behavior for forged internal ready carriers. Frontend controls test the actual
producer chain and public forged-seed refusal separately.

The indexed graph finisher also retains the original operation order and values:
fill imported declarations, select the existing fresh-name error, record the
post-fill declaration count, apply namespace/path transformations, then call the
same whole-graph error renderer. The explicit `List<&2,KTerm>` annotation on the
`loaded` local only resolves its source type; it changes no runtime operation.
