# Phase168: recover scalar-reader quality without restoring the full backend

Base: `85b03b1`, the frozen Phase167 observer-first experiment. Production and
the qualified Phase152 compiler remain unchanged. Root owns all checked
acquisitions, guarded targets, timing and qualification decisions. This lane
prepares only the additive Bend source and this design.

## Evidence and target

Phase167 moved general source-derived observers before raw dependency admission.
On the same complete 39,333-byte verifier request, its matched hosted
source-to-native build was 23.351s versus 31.343s, about 25.5% less time. Fully
matched generated execution was 0.6554s versus 0.4412s, 1.485 times as long. This
is a bounded hosted compiler pilot, not a native full self-build result.
See [Phase167 report](../../implementation/phase167/README.md).

The remaining baseline-only direct functions are ten scalar-reader/owned-fallback
pairs. Existing `p128bs` and `p128br` already implement the required guarded
borrowing and consumer composition. The next target is generated runtime at
most 1.10 times the matched baseline while retaining roughly the build saving.
These are experimental acceptance goals, not predicted results.

An important source-level prerequisite is the unchanged `p128bs_leaf` rule.
The raw `index_hash` body still calls `Char.to_u32`; the raw string equality loop
still calls `Char.is_eq`. They do not qualify as leaf owning fallbacks until
ordinary bounded inlining removes those calls. Loosening the leaf test would
change the ownership/fallback contract and is outside this design.

## Interfaces and ablation

`selfhost/tests/phase168/early-scalars.bend` exposes:

- `p168_plan(mode,plan) -> P111Emission`: checked request/runtime admission,
  one new lowering and unchanged actual-program final admission/emission.
- `p168_request_mode(mode,request) -> P167Lowered`: diagnostic access to that
  single semantic result; reuse it through `p167ob_lowered` when emitting.
- `p168_request(request)`: mode 0 convenience entry.

Mode 0 restores cached scalar/consumer composition without an inlining pass.
Mode 1 adds the maintained bounded inliner on ordinary admitted bodies before
scalar selection. Already verified general observer seeds are neither rewritten
nor entered into the inlining table. The original-clean table-insertion guard,
body/stack budgets and scalar-fact behavior remain exactly the maintained ones.
Both entry points reject modes above 1.

Both modes use the explicit plain segment renderer and checked live transport.
Neither restores the legacy region registry, array/cold policy changes, full
late product retries, or another raw candidate-production/admission pass.
The root may prepare a separate region-emission control; it is a distinct
treatment and must not be folded into the scalar comparison.

## One classification, then genuine fallbacks

1. Retain `p167ob_permission`: checked source plus the existing scalar-or-effects
   permission disjunction. Use the same constructor catalogue and static body
   preparation. Run `p128br_scan` with an empty original function list once.
   Its general observer workers and summaries are available immediately; scalar
   plans lacking genuine owned fallbacks are retained as cached `NO_Plan` values.
2. Independently verify the general observer workers using the Phase167 closed
   seed boundary. Skip raw production only for exact supplied source owner/arity
   pairs, then seed the existing ordered candidate admission. This preserves the
   Phase167 dependency mechanism and its actual source-bound guards.
3. Optionally run the bounded inliner described above. Consume the cached scalar
   plans with the unchanged `p128bs_eligible` and `p128bs_find`. A matching public,
   one-result, leaf owning fallback is mandatory. Otherwise keep the plan for a
   later consumer retry; never fabricate a fallback or remove the guard.
4. Each selected scalar produces the existing triple: the genuine owned body,
   the borrowed reader, and a guarded source ABI wrapper. On the safe borrowed
   path the original helper drops the retained roots exactly as before; otherwise
   it calls the owned body. Check the complete added triple list against actual
   constructors with the existing borrowed projection verifier and empty FIDs.
   This rejects unexpected external calls/identities rather than assuming closure.
5. Prepend these closed triples and remove only the replaced scalar public entries
   from the original ordered function list. General observer bodies remain.
   Publish only the existing `p128br_seed` summaries of the actual added workers.
   Run one `p128br_retry_plans` on remaining cached plans, followed by
   `p128br_apply`, to reuse the maintained consumer composition and ordered call
   rewriting. Scalar replacement occurs **after** initial candidate admission;
   it repairs generated code quality rather than automatically admitting more
   previously blocked candidates.
6. Build the actual demanded generic families/adapters from the final function
   list, then use `p167ob_lowered` unchanged. Actual generic/static/adapter
   obligations and `p118b_verify_functions` on all final private workers remain
   mandatory. Every runtime/static ID derives from the actual emitted program.

The prefix placement is valid only because the selected leaf fallback and
original no-helper scalar plan produce a closed triple. The explicit early
projection check establishes that structural condition. Consumer readers can use
the previously published actual summaries; the final ordered body checker
still refuses a missing, forward or cyclic dependency. There is no new verifier
exception or fabricated original body.

## Cost accounting and diagnostics

The implementation does not call `p167ob_request` and then repeat source analysis.
It reuses the same preparation primitives with one initial `p128br_scan`, retains
its plans, and materializes generic bodies only after composition. Mode 1 adds
one bounded inlining/scalar-fact traversal. Both modes add scalar triple
production/projection, summary publication, one consumer retry/apply and the
unchanged final checks. All their allocations, destruction and chunk emission
belong in the timing boundary.

The first seven `P167Lowered.stats` fields retain Phase167 demand meanings.
Eleven appended fields are:

```
mode, selectedGeneralOwners, generalSeedFunctions, remainingRawSourceNames,
rawCandidates, admittedBeforeScalar, scalarAddedFunctions, helperSummaries,
remainingRetryPlans, consumerPatches, finalFunctions
```

`scalarAddedFunctions` counts complete worker triples, not source owners or
rescued candidates. Compare final function identities with the frozen Phase167
list and the baseline reader/owned pairs. Do not derive speedup from function
count or run the baseline lowerer again inside the candidate's clean timer.

## Gates and stop conditions

Use the existing final-boundary controls, borrowed projection controls,
`p128bs_controls`, `p128br_controls` and relevant retained-root/runtime oracles.
Test complete output under ordinary and shared roots, unknown constructors,
wrong borrow widths/counts, missing owned fallback, missing reader and invalid
mode. Malformed native pointer programs are verifier tests only, never executed.
Source checking, structural backend validation and finite runtime agreement do
not constitute a kernel proof of the compiler.

First compare mode 0 and mode 1 on the same prepared complete verifier request,
then use matched clean process runs for compilation and generated execution.
Keep machine construction in the complete-build clock and record backend-only
diagnostics separately. Broaden to representative ordinary programs only if the
quality/cost pair is promising. A lower construction time with a persistent
large execution regression is not a promotion. If composition ordering or source
permission fails, retain the refusal and fix the representation boundary; do not
weaken eligibility, ownership guards or final checks.

The module has 207 lines and no production overrides. Independent source review
found no semantic blocker in the cached-plan, closed-prefix and final-verification
construction. Root reports the first checked API acquisition succeeded for the
1.604 MB / 4,715-declaration source (`fa83dbc7…`, zero overrides), and all 64
existing malformed/projection/guard/held-origin/layout controls passed.

## First result and selective alternative

The first complete verifier pilot did not meet the joint target. The recorded
source-to-executable times were 31.455s baseline, 24.599s scalar composition only,
and 31.014s broad inline plus composition. Backend plus rendering was 14.781s
without inlining and 21.275s with it. Four clean output-checked execution samples
per role gave medians 0.4454s baseline, 0.6051s scalar-only and 0.6268s broad-inline:
the two candidates were 1.359 and 1.407 times slower. These are the same bounded
verifier workload, not full compiler throughput. Receipts:
`selfhost/build/phase168/{baseline01,scalars01,inline01,runtime01}/report.json`.

Source/IR inspection explains a concrete ordering hazard worth isolating. Broad
inlining can copy an ordinary scalar consumer before its later borrowed
replacement exists. Replacing the owner's eventual definition cannot repair
that copied implementation. It also traverses and enlarges many functions that
are unrelated to the leaf-fallback eligibility question.

The additive `early-scalars-selective.bend` is an 89-line alternative. Its only
duplicate declaration is the explicitly permitted experimental `p168_closed`
handoff; it changes no production declaration or frozen source file. Acquiring
it after `early-scalars.bend` changes **this new API's** mode 1 policy. The old
API01 and all its evidence retain broad inlining. New `p168t_plan(mode,plan)` and
`p168t_request(mode,request)` reuse the existing mode validation, source/runtime
permission and final gates. Mode 0 remains the original no-inline route.

The selective policy derives two exact owner sets from cached source plans:
all cached scalar/retry owners are barred from the helper table, and only
`p128bs_eligible` owners are transformation targets. General observer seeds also
stay exact and never enter the table. A helper table entry must be the unchanged
original body, pass the maintained original-clean guard, be leaf under the
unchanged scalar predicate, and pass existing table size/return/stack budgets.
Only nonleaf target owners invoke the maintained bounded inliner. Keep its
result only if the original leaf predicate now succeeds; otherwise retain the
original body. No transformed target is published as an inline helper.

This deliberately forgoes transitive helper synthesis and unrelated consumer
inlining. It tests whether small source-independent helpers can establish scalar
fallback eligibility cheaply while avoiding premature copies of future borrowed
owners. It does not relax eligibility, fabricate a fallback, rerun candidate
admission, or restore a late registry. All cached-plan composition, closed-triple
checks and actual generic/static/adapter/borrowed final verification are unchanged.
Source checking and matched compiler/runtime measurements of this new API are
pending. There is no promotion based on the initial result.

## Authenticated callable view for the existing renderer

The initial region-rendering control is narrower than a direct-aware continuation
test. Its functions remain private; `p124r_complete` requires a public direct
signature, so simply invoking a region chunk renderer does not restore that
callable information. A neutral result there cannot rule out this boundary.

The additive `adapter-view.bend` exposes `p168v_plan(mode,plan)`. Both modes use
the same selective producer (`p168_request_mode(1,request)` in the new API),
run the unchanged `p167ob_final` on its original private program, and retain
identical bodies and ordering. Mode 0 passes the private list onward. Mode 1
constructs a renderer-only list whose public flags come strictly from actual
`P164Adapter` map entries matching the function identity, arity and one-result
ABI. Source identity, ordinary-function permission, actual headers and exact
adapter bodies have already been authenticated by the original final gate.
The map-selection helper is not an independent admission certificate.

Both modes then run the maintained `p118b_verify_functions` again against the
actual original program. Its ordinary direct checker additionally verifies any
public flags against actual scalar ABI headers. Failure refuses emission; the
original private gate is never weakened or bypassed. Successful results use
`p134e_prepare(original,nodes,view,False,live)` and `p134e_collect_cursor`, with
live eligibility obtained from the original already checked program. No fake
`P113AProgram` certificate is created, and arrays remain disabled in both modes.

This isolates a rendering capability derived from real emitted adapters, while
charging the copy, second check, registry construction and complete rendering.
It creates no new worker, changes no ownership body, admits no extra source
function and restores no late optimization pipeline. Source checking, finite
controls and complete-output/runtime comparison are pending for this variant.

## Private-emitter hypothesis rejected by saved artifacts

The next offline audit checked whether the baseline uses the array-enabled
private emitter while the experimental renderer uses `p113e_private`. It does
not on this workload: the saved baseline02, targeted01, private01 and callable01
descriptors all have capability value 5 (static image plus live transport).
The maintained array preparation sets value 3 before live adds bit 4, which
would yield 7. All four also have exactly 185 all-hot constructor bytes.

The saved baseline02, targeted01 and private01 QBE contain no finite selector
table definitions or inline selector prefixes, floating-point assignments,
array-pair calls, raw array operations, or array heap-template references.
`p126i_emit_one` adds audited floating-point buffer fusion, selector-table
recognition and certified array templates; absent those, its chain reaches the
same `p113e_private`. Therefore another job enabling arrays would neither be a
faithful baseline reproduction nor test an established missing capability.
No forced certificate or array mode was implemented.

For a future source that actually qualifies, array permission must come from
`p113a_certificate(request)` (scalar definitions and unshared analysis), retain
the array and transport namespace checks, and coexist with the unchanged actual
mixed-program/borrowed verification. The Phase167 scalar-or-effects permission
alone is not an array certificate. A manually asserted Boolean is not authority.

The direct identity sets already match at 93 functions. Offline comparison
finds 29 differing baseline02/targeted01 direct QBE definitions, mostly showing
ordinary inlining and scalar/range simplification differences: `index_find`
retains calls to Boolean, equality and missing-value wrappers; several accessor
and verifier helpers retain extra fail/sink sites. These static differences do
not attribute runtime. Broader inlining already failed, so restoring it blindly
is unsupported.

## Imports must be present before region discovery

A more precise ordering obstruction survives the public-view treatment:
`p134e_prepare` constructs the region registry from an empty symbol seed before
`p134e_registered` constructs its public direct-callable view. An authenticated
adapter contains a direct-worker call, which is not itself a known region
symbol during that earlier discovery. A later public flag cannot retroactively
publish the omitted region worker or its dependants.

The additive `adapter-imports.bend` reuses the exact Phase164 import-selection,
candidate filtering and forwarder logic under new names. Its only duplicate
declaration is experimental `p168v_prepare`; it overrides no production function
and leaves API04 evidence unchanged. `p168j_plan(mode,plan)` always uses the same
authenticated public adapter view, unchanged private final gate and repeated
maintained public/borrowed verification. Mode 0 uses the stock registry; mode 1
publishes eligible actual adapter owners as rank-zero region imports before
calling the existing region passes.

Each import must match a real zero-capture, zero-flag, one-result segment and a
verified public direct signature of the same arity, at most 32. Imported owners
are excluded from region candidate construction, while the full original fusion
index remains available. Every seeded symbol has a real emitted
`p112w -> p113d` forwarder, selected from the final rank-zero registry entries
and emitted once before the ordinary cursor output. No fictitious worker plan,
missing native body or extra source admission is introduced. Ordinary discovery
ranks start at one, so it cannot silently create a second rank-zero import.

This is one final bounded ordering falsifier. Mode 0 should reproduce the prior
callable-view QBE exactly on the same prepared request. The paired modes charge
all seed construction, region discovery, forwarding and rendering. Counts of
new workers or removed transition sites are descriptive; independent complete
output and clean runtime observations still decide whether it helps.
