# Original-handle composite result adapter

Status: root completed checked-composite01, the independent controls, actual
row.probe entry witness and a two-point screen. This agent reviewed their saved
data only; it executed no compiler build, generated program or timing job.
Independent static review passed. These scoped results do not promote a release. The design is
[composite-results.md](../../design/phase48/composite-results.md).

## Candidate source

New [array-result.bend](../../selfhost/src/back/js/array-result.bend) adds a
bounded root planner and final public-shell adapter. Shared region, emitter,
runtime, tree, source graph and compiler files were not edited by this agent.
Root should attempt j_array_result_root_plan only when the existing region root
plan is empty, preserving prior selection precedence.

Admission requires canonical scalar arguments and a flat monomorphic nonnative
single-constructor user record with 1–32 live scalar/canonical Array fields,
including at least one array. The existing local-type proof supplies canonical
layouts and excludes recursive/dependent shapes. The candidate additionally
checks each field telescope and a plain owner result; public container arguments,
nested records, functions and arbitrary data outputs are refused.

Reuse the existing bounded region prefix planner and nested-loop eligibility.
The complete original helper graph must pass the existing closed array executable
audit, with an original Array.new dependency. Unknown or effectful producers and
opaque callbacks refuse. The book must not carry the raw-array marker.

This first slice retains original handles, Array.new/get/set operations and
ordinary handle-based private helpers. The only representation conversion is
one final ctor(name, vector). Observable array-handle and backing sharing stay
unchanged because neither is reconstructed. Internal private record vectors do
not cross a public input boundary and only the final record shell escapes.

Full fresh arrayViewHostGuard precedes canonical inputs and the complete local
source guard. It retains active-proof refusal; no permission is opened or cached.
On failure the old generic source body is emitted unchanged. Existing loop,
ordered field construction and tail transfer emitters remain responsible for
demand and stack behavior. This is not a raw composite escape adapter or an
array-identity registry.

## Controls prepared

[Fixture](../../selfhost/tools/performance/phase48/controls/composite-results-v1.bend),
[controller](../../selfhost/tools/performance/phase48/controls/composite-results-v3.mjs),
and [catalog](../../selfhost/tools/performance/phase48/controls/composite-results-catalog-v1.json)
are new versioned inputs. The catalog's scalar main=0 only anchors acquisition;
it grants no composite semantic credit. The controller pins the exact fixture catalog/source/upstream, extracts complete
G assignments with Acorn AST ranges, and calculates 15 independent values per role.
Separate counter-only derived bytes witness executed make fast/fallback selection
and external/nested public entries; marker presence alone grants no activation.
It checks fresh/distinct public record, handle and backing objects, public own
keys/prototypes/tag/field order, source-helper handle identity, and post-return
mutation. Six baseline/candidate trace comparisons cover mutated Array.new
returning one shared handle or distinct handles sharing backing storage, fill
throw/reentry, native code getter, and demanded allocation failure.

The same-handle cases are explicit host-dependency mutations and must take the
old fallback; they are not source-level affine handle duplication admitted into
the fast path. Their identity checks guard against future adapter changes that
might reconstruct handles on refusal. Every admitted execution transports the
original handles, which supplies the direct alias-preservation argument.

The general AST-based
[entry producer](../../selfhost/tools/performance/phase48/composite-result-entry-probe-v1.mjs)
can instrument the acquired maintained row.probe assignment and replay its
independent existing expected point. This real row activation remains required;
a fixture marker alone is insufficient. Counter derivatives are excluded from
timing and host-introspection claims. Earlier controller versions and the Python
entry producer remain preserved but are superseded and unexecuted.

Node 24.18.0 --check of the JavaScript controller and entry producer passed. This is syntax validation
only. Those source typechecking, activation and controls subsequently passed in
the root-owned jobs recorded below.
The initial preparation established no runtime or compiler-speed result. Raw
backing materialization would still need a separate use, sharing and escape
proof rather than opportunistic widening of this handle-preserving adapter.


## Checked candidate and executed outcome

Root's `selfhost/build/phase48/checked-composite01/attempt.json` is checked,
with strict acquisition passing. API SHA256
`bec513e634527dd292834811e5875e36c40b5c7873dfe4ebc326e74a4c40ec3c`;
runtime SHA256
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
Its unchanged runtime is the Phase47 array06 runtime. Source snapshot and
acquisition details remain in the original attempt and emission receipts.

`composite-controls02/report.json` passes 30 independent value oracles and
six full boundary trace comparisons. Its executed derivative witness counts are
make fast 2/fallback 1, external 1, nested 1. Same-handle/shared-backing injections
exercise fallback, not selected-path affine handle duplication. The exact fixture
modules remain the semantic subjects; the derivative only supplies entry evidence.
A read-only audit additionally verified that both CLI module paths/hashes equal
their receipt output paths/hashes. Controller v4 adds those explicit assertions
for future runs; it is syntax-checked but unexecuted. Consumed v3 remains unchanged.

The actual acquired maintained row module in `composite-runtime01` has SHA256
`27d6c45f290de37d050dca2e4b73adfabce7759556f989081374600ec32dbf8f`.
`composite-row-entry01/observations.json` verifies its independent expected
Dp/four-array result and row.probe before 0/0, after 1 fast/0 fallback. This is actual
executed private entry, not a marker-presence inference. The observation file
parses as valid JSON and ends with newline byte 10. Its generated runner contains
the correct JavaScript newline escape, and its hash matches the producer manifest;
no literal trailing backslash-n or post-run repair was found.

The fresh `composite-screen01/report.json` has three balanced rounds for each
of two points. Data-only medians and exact receipt bindings are saved in
[evidence/composite-results-screen.json](evidence/composite-results-screen.json).

| Point | Baseline ms | Candidate ms | Pinned TS ms | Baseline/candidate |
| --- | ---: | ---: | ---: | ---: |
| complete-generic-row32 | 0.385457 | 0.0306253 | 0.00703592 | 12.586x |
| local-pair | 1.44921 | 1.44195 | 1.24270 | 1.005x |

Candidate generic row is 4.353x pinned TypeScript on this screen; local-pair
is neutral. Generic-row candidate samples span 0.029209–0.033678 ms and include
-22.94% half drift; TypeScript row half drift is roughly -11.4% to -12.4%.
Short warmups and three rounds are a rejection/continuation screen, not a
steady-state estimate or broad conformance result. The large scoped gain supports
private dispatch plus handle-preserving boundary restoration as useful without
raw array escape. It does not assign the residual gap to V8, serialization,
allocation, guards or a particular loop instruction without further evidence.

## Minimal potential broadening, separately unimplemented

Canonical flat Sigma/Tuple results are a plausible next structural slice:
`Array<U32> & U32` or two canonical arrays, with no nested/dependent field type.
Existing local Sigma proof already establishes its exact native Tuple layout;
existing private regions transport it as a vector. A specialized constructor
field telescope could prove only scalar/Array fields and restore the canonical
public Tuple via ctor(Tuple,vector), which returns the ordinary native array.
No array handle reconstruction or ownership registry would be needed.

This is motivated by source coverage, not a speed forecast: the current candidate
explicitly refuses native constructors, while the Phase47 escaped-storage
fixture and Array.get-style results already use canonical public Tuple. First
require a renamed tuple root with actual fast-entry witness, post-return source
mutation and exact prototype/index descriptors; shared/distinct handles on
fallback; and refusal for value-dependent/nested tuples. Do not broaden arbitrary
records, functions, public array inputs or raw backing escape. Confirm the current
record adapter under longer-warmup and maintained gates before adding this slice
unless the independent tuple coverage itself is the next intended falsifier.
