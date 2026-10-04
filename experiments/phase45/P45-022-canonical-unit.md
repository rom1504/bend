# P45-022: canonical Unit in private first-order graphs

Status: worker22 built and passed the maintained suites and focused independent
Unit controls. Representative performance and final release qualification remain
separate; no speedup is claimed here.

## Hypothesis and change

`Set()` is `Map<&2, Unit>` in the pinned Base. The current complete-graph proof
admits scalar Map payloads but excludes canonical Unit in two places: the Map
payload predicate and the general internal type predicate. Closing this leaf-type
gap should let existing general workers compile Set operations and compositions
of List/Maybe/Unit without changing their algorithms or recognizing program names.

The isolated `unit-map-assessment18/unit-map.patch` adds 11 physical lines to
`jpure.bend`. A shared predicate requires the exact native, zero-parameter Unit
owner of Data kind, exactly one native nullary Unit constructor, and that
constructor's normalized result to have the same owner. It uses the existing
native owner and constructor proofs. Map then accepts its existing scalar
payloads or this proved Unit type. All other Map owner, quantity, constructor,
field, recursive-type, complete dependency and host checks remain unchanged.

A same-named local type does not meet the native-owner proof. Arbitrary nullary
or recursive ADTs do not become admissible Map payloads. This is a general leaf
type extension, separate from the nullary-function work in P45-021.

## Representation and semantic obligations

Unit remains internal to the closed graph. Public root arguments stay scalar;
root results stay scalar or immutable String. Public Unit/Map arguments or
results remain on the ordinary path. Residual native-call input boundaries do
not admit Unit.

The worker's existing tagged layout emits a nullary private Unit as
`{$:'Unit'}`. A Unit case only inspects its tag and has no projected fields.
There is no singleton substitution or escaping layout change. Public runtime
construction remains `{$:'Unit',a:[]}` with fresh ordinary objects. The older
owned-constructor emitter still refuses native Unit and keeps ordinary runtime
construction; its shared type proof does not grant ownership to public objects.

Actual Set helpers must remain observable through public `G`, descriptor fields
and code `.call` hooks whenever their complete guard fails. Partial application,
ungranted raw `.code`, oversaturation and public field getters must preserve
baseline behavior. Passing a generic fallback alone does not demonstrate the new
coverage: the independent controls require actual private branch entries.

## Independent qualification

The new [fixture](../../selfhost/tools/performance/phase45/fixtures/unit-map-workers-v1.bend),
[catalog](../../selfhost/tools/performance/phase45/unit-map-workers-catalog-v1.json)
and [controller](../../selfhost/tools/performance/phase45/unit-map-workers-controls-v1.mjs)
are separate from existing benchmark programs. The renamed positive-arity Set
graph initializes a typed `MTip{}` directly, inserts Unicode key λ and key elm,
deletes elm, observes membership and counts the result. Its independent result
is `seed` at zero iterations and `(seed+2) mod 2^32` otherwise. Direct `MTip`
isolates this proof extension from computed-nullary `Set.new()`.

A second graph combines Unit aliases, List and Maybe, with independent result
`(seed+3) mod 2^32`. An unrelated `Map<Bead>` source checks that the payload gate
does not broaden to arbitrary custom ADTs. All ambiguous fixture locals are typed.

The controller binds its source, catalog, three checked module receipts, compiler
identities and recorded inputs. It checks 27 small numeric points against pinned
TypeScript, the parent and candidate; 5 catalog points; candidate deep 50,000
iteration behavior plus replay; and assignment-specific private-entry counters
in a separate diagnostic module. It compares ten genuine public helper mutations
with the baseline, requiring guard refusal and identical values/event order.
Additional controls compare public descriptor metadata, staged demand, raw code,
oversaturation, getter-bearing public Maps, Unit identity and fresh public Unit
shape. Public host-object observations are baseline/candidate controls because
TypeScript uses a different public runtime representation.

The source patch and controller passed independent static review. Controller
syntax and catalog/source identity checks also passed. All counters are
diagnostic and provide no timing measurements or claim of arbitrary
hostile-preimport compatibility.

## Decision rule and scope

Build only after the parent nullary candidate passes. Acquire checked fixture
modules for that exact parent, the Unit candidate and pinned TypeScript; require
all value, activation and boundary controls before benchmarking. Then compare
representative Set rows and general fast canaries on the same input manifest.
Retain ordinary compilation if the complete graph or existing resource bounds
cannot prove a program.

Closing this type gap does not establish whole-program eligibility for every Set
consumer: the evening program also contains Array/F32 and number-text paths.
The full representative suite must determine the actual benefit and regression
risk. The patch adds no new worker backend, runtime protocol or public ABI.

## Executed result: worker22

The exact parent21/candidate22/TypeScript checked acquisition and fresh controller
run passed. `selfhost/build/phase45/unit22-controls-v1/report.json` records 27
three-role numeric oracles, four actual activation observations, ten live helper
mutation boundaries and two public ABI/object bundles. The activation checks
include the 50,000-iteration Set graph and a small replay at Node's default
984KiB stack. Public Unit/Set boundaries retain their ordinary representation,
identity and demand behavior; the unrelated Map payload remains refused. These
are newly executed candidate22 checks, not byte-identity reuse of an older image.

The strict build took 51.602 seconds including its enclosing job; the eight
maintained semantic suites passed in 16.529 seconds. Checked fixture acquisition
took 7.704 seconds for parent21, 13.613 seconds for candidate22 and 1.719 seconds
for pinned TypeScript. These are acquisition/control costs, not generated-program
speed measurements. The corresponding raw receipts are
`checked-worker22/attempt.json`, `qualify-worker22/report.json`,
`unit22-baseline/preparation.json`, `unit22-candidate/preparation.json` and
`unit22-typescript/preparation.json`, all relative to `selfhost/build/phase45`.

The candidate API is
`e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`.
The general type-coverage hypothesis is supported: both independently composed
Unit graphs actually enter the private backend and preserve the tested values
and public boundaries. This does not establish a representative runtime gain,
full frontend/backend conformance, arbitrary hostile-preimport compatibility,
or an installed release. Final qualification must use the selected image.

## Corpus screen and emitted-code identity

The fresh nine-point parent21/candidate22 screen completed with passing values:
five fast/adapter points in 35.397 seconds and four existing whole-program points
in 28.617 seconds. Observed parent/candidate median ratios ranged from 0.917 to
1.011. The apparent roughly9% slowdowns on two short rows are not evidence of a
compiler regression from this patch: `unit22-emitted-identity.json` verifies
**all ten emitted module files are byte-identical** for the nine sources/eleven
points previously acquired for21. The screen variation therefore measures
execution noise and warmup behavior of the same generated code.

The raw screen reports are `runtime-worker22-fast-vs21/report.json` and
`runtime-worker22-nullary-vs21/report.json`, relative to `selfhost/build/phase45`.
This extension provides new, independently demonstrated Unit graph coverage;
it earns **no runtime speedup claim on those existing corpus programs**. The
complete45-point candidate acquisition also passed in 193.920 seconds, but its
existence is not full timing or release qualification. A subsequent runtime
entry-guard correction is separate from the Unit type-admission change.
