# Tree saved-output handoff

Correctness unchecked; measurement not run by author; no compiler change or
promotion. Root owns execution and retains failed attempts. Prospective contract:
[design](../../design/phase40/tree.md).

Files: `tree-derive.mjs` parses exact Phase39 checked05 saved output, verifies its
API/output receipt, finds saturated flow/leaf call sites with Acorn and emits
unchanged/noise, leaf, flow and complete roles. Clean roles have no counters.
Diagnostic roles export owned-input flow probes and entry counts.
`tree-controls.mjs` retains Phase39 boundary observations and adds600 complete
flow equation cases, both sort directions, uneven shapes/shared children and
zero-flow freshness/child aliases. Deep controls exercise30000-level warp frames
inside a flow continuation and require120003nodes/120004leaves, without native
stack growth. The initial bench independent oracle has20 cases.

Run from repository root (root alone):

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 30 \
 selfhost/build/phase40/tree-derive-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase40/tree-derive.mjs \
 selfhost/build/phase39/candidate05/modules/tree-bitonic.mjs \
 selfhost/build/phase37/typescript01/modules/tree-bitonic.mjs \
 selfhost/build/phase40/tree-prototype01
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 120 \
 selfhost/build/phase40/tree-control-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase40/tree-controls.mjs \
 selfhost/build/phase40/tree-prototype01 selfhost/build/phase40/tree-controls01
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase40/tree-prototype01/compare.json \
 selfhost/build/phase40/tree-screen01 --node "$NODE" --cpu 3 --budget 60
```

Preparation expected<1second/<100MiB; controls expected<30seconds/<500MiB;
comparison estimated20–40seconds, heap cap1GiB. Bounds remain RSS2GiB/free2GiB;
compare owns the resource lock and must not be nested in bounded-run. For first
20-second rejection screen root should author a fresh config selecting only
`tree-bitonic`; preserve all three frozen depth points for60-second confirmation.

Compiler source route if performance survives: `j_component_plan` requires
nonbuiltin first-argument ADT; `j_component_match` handles primitive Bool and
nonbuiltin constructors; `j_component_emit_match` uses Bool comparison or tagged
fields. Admit native Nat first argument only after `j_nat_loop_native(book)`,
retain origin tracking so a Succ predecessor becomes `@child`, and emit native
Zero/Succ comparisons plus predecessor extraction. Existing recursive-call
arity/proper-descendant checks, independent RHS checks, closed pure graph,
backedge refusals, dependency guards and frames should remain. Flow's Nat
coordinate decreases even though tree children pass through warp_node first.
No broad permission for recursive host trees is justified. Public call sites
must continue to refuse absent proof. Full control parity must precede checked B1.

Preparation correction: original derive-run01 retained its missing TypeScript input
ENOENT; unchanged tool with the Phase37 TypeScript path passes derive-run02.

## 2026-10-03 resumed source experiment

Root's saved-output controls pass in1.71seconds/181MiB. Initial20second screen
passes in8.21seconds;60second confirmation passes in47.18seconds. Reported flow
ratios2.35–2.72× and complete2.73–3.17× justify the source experiment; these are
saved-output ratios, not checked-source performance.

Production `selfhost/src/back/js/tree.bend` now implements the native Nat first
coordinate/prefix extension described above, under root's explicit authorization.
`tree-nat-source-proposal.patch` and `.bend` preserve the proposed exact revision.
The proper-origin, independent RHS, full graph/backedge and proof guards are
unchanged. No function names enter production admission.

Independent fixture `tree-nat-fixture.bend` uses Nat/Bool/NatFlow prefixes,
constructor copies, a transform and aliasing combiner; computed equal predecessor,
reconstructed parent coordinate, sequential dependence and transitive backedges
must refuse. Checked-emission `tree-nat-actual-derive.mjs` audits actual helper
presence/absence and preserves clean bytes, while diagnostic counters witness
real source worker entry. `tree-nat-actual-controls.mjs` validates240 full shapes,
60 scalar/refusal oracle points, zero-case aliases, mutation/host/public-tree
boundaries, live delayed left/right case order and30000 native-Nat frames.

```sh
# ORIGINAL/CANDIDATE/TS are separately checked fixture emissions with .json receipts.
# ATTEMPT is the new checked attempt. Root alone executes under bounded-run.
node selfhost/tools/performance/phase40/tree-nat-actual-derive.mjs \
 ORIGINAL CANDIDATE TS ATTEMPT NEW_DERIVED
node selfhost/tools/performance/phase40/tree-nat-actual-controls.mjs \
 NEW_DERIVED NEW_CONTROLS
```

Source performance must use actual emitted bytes because the manual flow worker
also directly handles warp_node; this minimal source change leaves that helper
as generic dispatch. A separate saved actual-output ablation can isolate an
acyclic direct continuation before broadening source admission. Removing the
component positive-self-reference gate globally has potentially large code-size
and compiler-planning costs; a general criterion tying such wrappers to an
already admitted structural call would be narrower.

### Checked01 screen (completed; not promotion)

Checked01 API `4c0987e86939cfdafa3778d69a1b1e6271d33147f2afe2afc064a6745dfc6f78`
is a checked B1 derivative. The [actual-output screen](../../selfhost/build/phase40/tree-actual-screen01/report.md)
passes4/4 cases,36 samples, in29.340seconds. Three paired rounds per role use
fresh processes; export time includes result validation/checksum. Source output
preparation is outside timing. The ordinary scalar control has unchanged bytes.

| Fixed input | Checked05 ms | Checked01 ms | Incremental ratio | Checked01 / TS |
|---|---:|---:|---:|---:|
| tree depth6,seed17 |1.70553|0.87047|1.959×|23.210×|
| tree depth8,seed0 |12.14090|4.80845|2.525×|16.482×|
| tree depth9,seed123 |30.60021|12.87987|2.376×|17.591×|
| unchanged scalar8192 |0.11290|0.11342|0.995×|1.141×|

Tree ranges are disjoint at these points, but baseline within-sample drift is
29–44% at depth8 and36–59% at depth9; candidate depth9 drift reaches−19.5%.
This is a strong bounded execution screen, not complete JIT stabilization,
universal speedup, compiler-throughput or release evidence. It measures actual
minimal source Nat-flow output, unlike the earlier saved complete component.
Independent checked fixture ownership, selected mutation/stack gates, compiler
cost and broader integration remain necessary before promotion.

### Fixture failure and independent list-frame review

`tree-nat-cohort01/baseline.mjs.json` records a real checked frontend rejection:
flag consumed more than once at natflow.flow. Versioned
`tree-nat-fixture-v2.bend` marks the duplicated flow/dependent flag and unsafe
recurrence law flags unrestricted; `tree-nat-actual-derive-v2.mjs` binds that exact
successor. V1 source/consumed bytes and failed receipt remain unchanged. This is
fixture correction, not relaxed compiler admission.

Independent review of the concurrent list source extension in tree.bend finds
no blocking semantic issue statically. Its one-self-reference admission keeps
proper first-descendant/saturated recursion and whole-graph purity/backedges.
Before/child/after splitting reuses the producer helper's evaluation order;
resume aliases are limited to inert Var/Lit/Bool atoms, distinct constructor
results use the specialized result telescope, phase2/3 separates unary combines
from twochild phase0/1, and pooled before slots stay private under host/prototype
refusal. Tail transfer retains pending outer-combine frames and avoids native
recursion. This is static review only; independent child-position/result-shape,
alias/backedge/error/stack controls remain necessary.

The v2 fixture check also rejects duplicated successor predecessor p because
its n parameter remains affine. That failure stays in tree-nat-cohort02.
Versioned v3 marks Nat-flow/dependent n parameters and all unsafe recurrence
law n parameters unrestricted, so predecessor duplication inherits +n as in the
checked historical tree fixture. Full static quantity audit: flag/seed/depth
repeat only under + binders; make predecessor is used once; tree fields each
feed one child; join's duplicated left is unrestricted; dependent local +a feeds
score plus join; redirect x is used once in each mutually exclusive branch.
`tree-nat-actual-derive-v3.mjs` binds v3 bytes. No production change follows.

Checked cohort03 passes baseline/candidate/TypeScript emissions on fixturev3.
Diagnostic derivev3 then fails because it assumes the former finite-root marker;
checked02 emits a scalar-root marker before the guard. Preserve derive-run03.
`tree-nat-actual-derive-v4.mjs` requires the correct marker for each role and an
exact equal count of guarded regionProofOpen($guards) scopes. It inserts root
counters after actual proof admission inside try, rather than at a pre-guard
marker. Worker closure/refusal assertions and fixturev3 provenance are unchanged.
Controls retain their ordinary root+worker entry requirement. No production edit.

### Independent linear-order owner tools (prospective)

`tree-linear-order.bend` independently combines unary and binary branches in
four workers over OrderInput while returning distinct OrderResult. The pickers
place child at0/1/2 and preserve exact aliases; identity returns child unchanged.
`tree-linear-order-acquire.py` reuses the existing serial checked acquisition
workflow. `tree-linear-order-controls.mjs` binds all three emission receipts and
compiler/source/helper bytes, requires four actual workers and exactly one
leaf/unary-resume/binary-combine site each, then adds AST phase counters and
returned-value/alias capture only. Clean source emissions stay unchanged.

The planned owner checks160 complete structure/three-role scalar oracles,
33 live dependency wrapper/getter/binding refusal groups,9 pre/leaf/post Nat
overflow phase witnesses plus3 depth0 errors, actual aliases and mixed frame
phases in each worker. Equal Nat error text is insufficient: candidate must
show the precise actual initializer/leaf/resume-argument sequence, with paired
baseline errors and proof cleanup. Existing list/public host gates complement
this independent owner; it is not broad conformance. No executions yet.

```sh
python3 selfhost/tools/performance/phase40/tree-linear-order-acquire.py \
 --attempt selfhost/build/phase40/checked03 \
 --baseline-attempt selfhost/build/phase39/checked05 \
 --out selfhost/build/phase40/linear-order-cohort01 \
 --node "$NODE" --cpu 3 --rss-mib 2048 --available-mib 2048 --timeout 180
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 120 \
 selfhost/build/phase40/linear-order-control-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase40/tree-linear-order-controls.mjs \
 selfhost/build/phase40/linear-order-cohort01/linear \
 selfhost/build/phase40/linear-order-controls01
```

Acquisition owns the resource lock and must not be nested in bounded-run. Root
alone runs both. Expected acquisition<30seconds/heap1GiB; controls<10seconds/
500MiB. Failed outputs require fresh successors, preserving old consumed tools.

Independent linear-order cohort01 fails parsing the fixture's computed Boolean
match scrutinee. Version2 moves that match into a separate pure saturated
order.make_choose(child,seed,flag), with make passing the computed parity as an
argument. Input shapes and semantic oracles stay unchanged. The versioned
acquirer binds tree-linear-order-v2.bend; controls-v2 adds the selector's three
mutation/refusal boundaries (36 total). Original source and parse-failure
receipt remain preserved. Future execution must use fresh output directories.

The earlier static list review is superseded in one specific area by actual
checked04 failures: emission reused ownership recognition with a lexical Env
that lacked @child origins, producing an undefined saved argument. The list
owner's successor splits emission-only saturated-call recovery from mandatory
analysis provenance checks. The independent linear owner will validate the
actual emitted child slot and phases; static review alone did not establish it.

## Checked05 actual semantic owners (completed)

Selected checked05 API:
`c1d70130a12e6309e9a964004221d61b41d74078b3a252fb7f573b9654fefc54`.
This checked B1 derivative includes the shared frame correction. These owners
establish selected semantic gates; they do not establish a compiler fixed point,
broad conformance, compiler cost or release promotion.

[Nat owner](../../selfhost/build/phase40/tree-nat-controls05/report.json) passes
302 oracle rows and84 boundary groups. Of the oracle rows,240 compare complete
independent flow shapes,60 cover source scalar/refused-shape checks, one covers
zero-root freshness/child aliases, and one covers30000 native-Nat frames.
The deep result has30000nodes/30001leaves and exact sum450737744. The ordinary
source entry independently increments actual proof admissions36→37 and actual
flow worker calls300→301. Diagnostic owned-tree adapters are explicitly separate
from that ordinary-entry witness. All final proof states close.

The derived baseline and candidate each have three exact root markers and three
matching guarded proof-admission scopes. Root instrumentation runs only after
proof admission; worker counters attach to real emitted helpers. Clean outputs
retain their original checked-emission bytes. Mutation/refusal comparisons require
zero candidate flow-worker entry and matching generic results/errors/events.
Native-Nat overflow ordering is established by the separate linear owner below.

[Linear order owner](../../selfhost/build/phase40/linear-order-controls02/report.json)
passes160 complete structure/three-role scalar oracle rows,12 order cases and36
live dependency refusal groups. Candidate syntax independently contains exactly
one leaf, one unary resume and one binary combination per order.first/middle/
last/pass worker. Its208 observed resume aliases are all exact: pickers preserve
the captured child in both stamped fields, and identity returns the same child
object. Mixed unary/binary phases execute in every worker. Nine depth1 overflow
cases establish actual before/leaf/after ordering for child positions0/1/2;
three depth0 cases show sibling expressions remain undemanded. Error observations
pair checked05 with preserved checked39; each exception closes proof state.

TypeScript participates in the small-Nat scalar oracles only. Maximum immediate
Nat overflow/error ordering and private object identity are selfhost-specific
paired/diagnostic checks; no TypeScript maximum-Nat or alias-ABI equivalence is
claimed. Full tree models use separate nested arrays and BigInt U32 arithmetic;
phase/alias captures modify only diagnostics, not evaluated work or admission.

Read-only review rehashes every input row of both successful owner reports without
mismatch. The source/API/runtime/Base/driver, checked receipts, source fixture,
producer/catalog/verifier and diagnostic module identities remain bound by the
actual derivations. Supervisor receipts pass with sampled process-tree peaks
about109MiB Nat and93MiB linear under the1GiB heap/2GiB RSS/free-memory contracts.
Closed Phase39 evidence and failed Phase40 fixture/derive/control attempts remain
preserved. Root is preparing the complete catalog separately; those outcomes
must not be inferred from these scoped owners.
