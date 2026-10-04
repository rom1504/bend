# Phase43 products implementation status

Correctness: root-run saved-JS products-ablation02 oracle passes complete values,
aliases, host fallback, demand order, activation and deep12000 insertion. This is
not checked compiler-source qualification. Decision: investigate; no production edits.

Tools in `selfhost/tools/performance/phase43/products/`:

- `derive.mjs`: exact AST saved-output transformation, original/direct/products clean
  and instrumented variants, hashes, producer/parser identity and copied producer.
- `oracle.mjs`: complete tree values, duplicate/zero/limited fuel and U32 wrapping,
  fresh output shells/shared siblings, public zipper values and ordered frames,
  public hostile getter traces, ordinary-root executed apply reduction, postimport
  build-code/Math.imul fallback, proof cleanup and deep12000 iterative insertion.
- `make-source-patch.py` and `computed-u32-prefix.patch`: general held compiler
  proposal, 25 added lines and two changed selectors. No production source edited.
- `derive-v1-failed.mjs`: retained first selection attempt; root's run-products-derive01
  rejected expected one build call because guarded consequent contains two duplicated
  conditional alternatives. Latest diagnostic cleanup accessor may postdate that
  failed job; root run's consumed producer identity is exact if recorded.

Root-run commands:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase43/products/derive.mjs \
  selfhost/build/phase42/integration03/full-preparation/modules/bst.mjs \
  selfhost/build/phase43/products-ablation02
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase43/products/oracle.mjs \
  selfhost/build/phase43/products-ablation02
```

Apply the held patch only after root's saved experiment survives. Build checked B1,
then prove ordinary source build-worker activation and actual generic-call reduction.
Check that covered lowering preserves the new RHS grammar; emitting a dead worker
is failure. Test untouched scalar/flat/vector/list consumers immediately. Keep
compact zipper prototype separate: it requires general escape/liveness/representation
proof and is not implemented by computed-prefix admission alone.

Review caught a normalization requirement: exact U32 Var gate now receives
`wnf(book,j_env(...))`. Recursive arithmetic depth fuel is not a shared-work budget;
current component source bound is required. Pure graph proof alone cannot authorize
an arbitrary computed allocating/effectful alias.

Optional separate `nat-wrapper.patch` permits exact Nat-first acyclic wrappers in
`j_component_admit`. Outer Nat-to-data precedence/type eligibility and complete
JPure plus recursive-helper coverage remain unchanged. This can directly emit
`p37.bst.insert`; U32-first `insert.fin` remains generic. Test separately; do not
attribute its effect to computed-prefix admission. The saved direct prototype
includes a manual direct fin shell and is an opportunity ceiling, not exact source
patch emission.

## Root-executed first evidence

[Oracle](../../selfhost/build/phase43/products-ablation02/oracle.json) and
[screen02](../../selfhost/build/phase43/products-screen02/report.json) pass. The
fresh budget60 protocol completes in19.82s, three process rotations per role,
350ms warmup and150ms target. Values below are milliseconds/call median [min,max].

| Point | Original | Direct | Products | TS | Original/direct | Direct/products |
|---|---:|---:|---:|---:|---:|---:|
| coverage-bst-32 | 0.250012087 [0.208163496, 0.254655704] | 0.107075650 [0.103466648, 0.108356450] | 0.053546807 [0.052718022, 0.058752167] | 0.023772640 [0.022615080, 0.024444080] | 2.335× | 2.000× |
| coverage-bst-64 | 0.376515499 [0.340994811, 0.384827355] | 0.164886983 [0.147997537, 0.164892857] | 0.097156385 [0.088322367, 0.098182337] | 0.052147589 [0.048975607, 0.053394440] | 2.283× | 1.697× |

These are two small supplemental saved-output points, not the final catalog or
an actual source-patch speed claim. Handwritten direct fin and compact zipper
kernels remain causal ceilings. Current derive additionally offers `pairs`, which
keeps BF/Con/List layout but holds tree/path state in locals and removes repeated
pair and inert leaf materialization. `derive-v2-direct-products.mjs` and
`oracle-v2-direct-products.mjs` preserve the three-variant producer/oracle.

Actual source controls: `actual-oracle.mjs ACTUAL_BST CHECKED16_BST NEW_OUT` checks
actual global build/insert workers exist, execute from ordinary root, reduce apply,
preserve complete private/public outputs and raw/data/partial boundaries, refuse
host/dependency mutations and handle deep insertion. Compile
`fixtures/prefix-controls.bend`, then supply `--fixture` to additionally check
renamed source activation, scalar-result recursion and allocating-prefix refusal.

## Rejected source01 and corrected compiler demand gates

The first integrated computed-prefix/Nat-wrapper checked01 builds and passes36
build probes, but actual BST acquisition hits its180-second deadline with stable
~303MiB RSS. [Process receipt](../../selfhost/build/phase43/checked01-preparation/emit-00/process.json)
and [trace](../../selfhost/build/phase43/bst-trace01/report.json) preserve the failure.
The trace reaches10000 events and observes `j_linear_u32_prefix` repeatedly on
Absent with decreasing fuel. This is a compiler bug in the original proposal:
Bend's `&&` evaluates both operands, so a false Call/arity predicate does not
prevent two recursive child visits on Absent, yielding a binary expansion.
`kc` now fences exact Call/arity/native whitelist before either recursive call,
and valid Let metadata before starting the scalar prefix proof. The initial
held patch/generator are retained as `*-v1-rejected.*`; root owns the production
correction and requalification. The saved-JS oracle/timing remain valid within
their original scope and do not establish source compiler success.

`trace-planner.mjs` provides reusable preplanner KDef tree serialization plus
bounded, periodically flushed planner/emitter events. Source dt/dv ids/quantities
are exact IR facts, with explicit truncation bounds; it does not claim full wnf
normalization of source bodies.

## Held general pair-state prototype

`pair-state-proposal.bend` and `pair-state-prototype.patch` add a narrow general
private emitter, approximately180lines. Exact Nat tail recursion carries a final
strict Sigma1/1 pair and invariant scalar parameters. Zero returns the original
input pair. Positive entry allocates one fresh local pair buffer. Every incoming
pair helper parameter must immediately match the sole Tuple arm, preventing a
whole-buffer KTerm binder; terminals create Tuple or call bounded acyclic helpers
of exactly the same result type. Both field RHSs are evaluated to temporaries
before either slot is written. Original BF/Con/BLeaf construction remains.
Flat context is refused, so stronger layout/island precedence remains intact.

The fresh buffer has no incoming aliases, and no whole-buffer source binder can
store it in a field. Extracted fields retain their original aliases; each later
worker call creates a fresh buffer again. This is a local shell-ownership argument,
not a proof that arbitrary closed ADT fields are unaliased. The private result
shell is fresh on positive fuel and identical on zero fuel. Public generic calls
retain their existing worker path and ABI.

Review accepted this ownership design conditionally. Actual parser/checker/shape
activation, old-field RHS order, nested helper terminals, complete pair/path/alias
values, Error reentry, deep iteration and measured emitted-program gain remain
required. The proposal is held while current source acquisition is repaired.
Initial `pair-state-proposal-v1-held.bend` retains strict-boolean recursion hazards;
current helper/Call/Mat shape gates use `kc` before recursive proof work.

## Corrected checked02 actual-source activation

Root's corrected checked02 build passes36 gates (~45s); four-source/five-point
acquisition finishes22.8s. [Actual source oracle](../../selfhost/build/phase43/products-actual02/report.json)
passes in0.7s: actual build and Nat-first insert workers execute from the ordinary
bench entry, with complete values/aliases, raw/data/partial boundaries, supported
host/dependency fallback and deep12000 insertion. Exact instrumented apply counts:

| Size, seed | Checked16 apply | Checked02 apply |
|---|---:|---:|
| 0,0 | 7 | 2 |
| 1,0 | 19 | 6 |
| 7,17 | 91 | 30 |
| 16,4294967295 | 199 | 66 |
| 32,0 | 391 | 130 |
| 64,17 | 775 | 258 |

Residual four apply calls per insertion belong to U32-first `insert.fin`.
`scalar-wrapper.patch` is a separate minimal follow-up: exact U32/Bool/F32 first
arg, non-scalar result and zero self-reference admit only acyclic wrappers.
Existing independently admitted recursive-callee selection, complete JPure,
backedge and runtime graph guards remain. Nat retains its stronger original ABI
branch; recursive scalar-first loops and scalar results remain unchanged.
`refusal-probe.mjs` provides fast compiler-side Absent128/nonLet/freeVar/wrongarity
negative controls for the strict-boolean regression. Root executes both source
fixture qualification and runtime measurement separately.

Current static cross-review and pairs-only root-run protocol are recorded in
[static-review](../../selfhost/tools/performance/phase43/products/static-review.md).
String v5 fences preserve proof acceptance while skipping irrelevant pure compiler
work; apply is recommended for qualification. Pair-state fences and causal pair-only timing are now ready; actual source
qualification remains pending. The pairs
saved variant now retains per-step BLeaf allocation, so its comparison isolates
Tuple state arrays rather than also removing fresh leaf shells.

## Pair-only discriminator and general source candidate

Root's `products-pairs01/controller.json` passes in29.27s; maintained three-process
rotated screen passes in27.319s under the fresh60s protocol. Every pair-only fuel
step retains its BLeaf allocation and BF/Con/List layout. This saved-output causal
screen is distinct from actual source promotion. Exact ms/call:

| Point | Role | Median | Range |
|---|---|---:|---:|
| coverage-bst-32 | direct | 0.115043240 | 0.110810122–0.119384374 |
| coverage-bst-32 | pairs | 0.073054259 | 0.071512307–0.075219884 |
| coverage-bst-32 | products | 0.054554353 | 0.052416077–0.061175195 |
| coverage-bst-32 | actual | 0.114782975 | 0.108761582–0.117802255 |
| coverage-bst-32 | typescript | 0.025640601 | 0.025591977–0.026155613 |
| coverage-bst-64 | direct | 0.165689617 | 0.163045404–0.170851274 |
| coverage-bst-64 | pairs | 0.121896384 | 0.121152590–0.123049678 |
| coverage-bst-64 | products | 0.090514538 | 0.087381782–0.101998333 |
| coverage-bst-64 | actual | 0.150123084 | 0.148656298–0.179876194 |
| coverage-bst-64 | typescript | 0.055496247 | 0.054286375–0.058188131 |

Pair state saves1.575x atBST32 and1.359x atBST64 versus direct. Remaining compact
path headroom belongs to the separate products variant. This justifies trying the
169-line general pair-state source candidate, not assuming the saved kernel is
installed. `pair-state-prototype.patch` is regenerated against current tree;
explicit `kc` gates stop failed signature/argument/shape/arm checks before child
work and skip the lane entirely under flat context. Production is not edited here.

`fixture-catalog-v2.json` includes unchanged prefix-controls zero BST root and
independent pair-controls simultaneous RHS, nested helper, shared ADT fields and
whole-shell binder refusal. Maintained prepare.select and checked_source pass
all13 cases and four sets. The first catalog's missing top-level sets caused a
pre-acquisition KeyError, preserved as fixture-catalog-v1-rejected.json; no compiler
attempt or semantic assertion ran. `pair-source-oracle.mjs CANDIDATE_PAIR
BASELINE_PAIR NEW_OUT` requires actual selected worker markers and ordinary
activation, complete values, zeroalias/positivefreshness/sharedfields, mutability
fallback, Error reentry and12000-deep controls. Compiler qualification is pending.

Catalog v2 passed maintained selector/hash validation but baseline source checking
found reused affine size/seed in prefix wrappers.root. Receipt:
`selfhost/build/phase43/product-fixture-baseline02/modules/prefix-controls.mjs.json`.
Original fixture is preserved as prefix-controls-v1-rejected.bend. Added exact
`+size`/`+seed` on that wrapper root; no planner gate changed. Catalog v3 records
new source hash and again passes maintained select/checked_source all13cases.
Root owns source checking; static hash checks do not establish affine validity.

Independent callback and reviewer42 audits approve revised pair candidate for
source qualification; existing direct expansion charges every copied call occurrence
with a2048-node bound, so acyclic branching emitter expansion is already bounded.
Root applied the pair patch for build07. Baseline03 prefix source passes; pair
fixture parser refused a computed match scrutinee. Original pair source retained
as pair-controls-v1-rejected.bend. Named pair.finish/shared.finish now destructure
parameters, and escape.result uses pair.finish. Catalog v4 has fresh hashes;
maintained selector/hash13cases and match-parameter source audit pass. Actual
source compiler validity/activation remain root-owned and pending.

Separate frozen `pair-ignored-catalog-v1.json` adds the reviewer-requested
conditional helper: both Bool branches immediately Tuple-match; True ignores old
fields and reconstructs fresh P43Box data, False swaps retained aliases. Its
eight independently calculated points pass maintained selector/hash checks.
`pair-ignored-oracle.mjs CANDIDATE_IGNORED BASELINE_IGNORED NEW_OUT` requires
actual selected marker/ordinary activation, full values versus generic baseline,
old-input snapshots, zeroalias/positivefreshness/shared field aliases and12000
steps. No foreign getters are admitted by this source witness. Main v4 catalog
and its frozen sources remain unchanged. Root schedules acquisition/oracle.

Root baseline04 source acquisition passes both prefix and pair fixtures, all13
points. Ignored-control baseline01 refused the twice-used affine Bool invariant
flag in ignored.loop. Original source/catalog v1 retained; exact `+flag` now
licenses the duplicated immutable scalar. Catalog v2 has fresh hash and maintained
selector/hash8cases pass. Other repeated scalar use is result's existing `+seed`;
all other binders occur once per reachable source branch. No planner gate widened.

## Checked08 activation and fixture precedence diagnosis

Root products-actual08 and products-source-fixture08 pass actual build/insert/fin
activation and full controls; BST64 executed apply is775→2. Pair-refusal08 passes
all8 malformed predicate controls (0.006–2.907ms). Checked08-screen01 records:

| Point | Role | Median ms/call | Range |
|---|---|---:|---:|
| coverage-bst-32 | typescript | 0.024608014 | 0.023491780–0.024986943 |
| coverage-bst-32 | baseline | 0.205302204 | 0.203409458–0.229321004 |
| coverage-bst-32 | candidate | 0.084090099 | 0.082011602–0.088454622 |
| coverage-bst-64 | typescript | 0.053988609 | 0.053547161–0.058760112 |
| coverage-bst-64 | baseline | 0.334026446 | 0.327511721–0.347490943 |
| coverage-bst-64 | candidate | 0.125596895 | 0.124647178–0.141072880 |

Combined source candidate gains2.441x/2.660x versus retained baseline and is
3.417x/2.326x TypeScript atBST32/64. This screen does not independently attribute
all the source gain to pair-state lowering.

Independent original pair fixture activation assertions correctly fail: ordinary
roots call scoped old scalar `$R_encodedloop` slot workers, while new global
`$R_encodedloop$tree` remains only in a guarded fallback. Generated pair-controls
lines799/804 and ignored-controls798 establish the distinction. Stronger scalar
precedence must remain. Tools preserve consumedv1 and optional --precedence-control
now requires zero globalpair calls AND positive executed scoped scalar calls.

NEW separate pair-target-catalog-v1 (12cases) and pair-ignored-target-catalog-v1
(8cases) retain all prior expected values but wrap result fields into a custom
binary recursive observer, analogous to existing BST inorder. These aim to
block old scalar-local eligibility while preserving the complete owned root graph;
no compiler rule is widened and original fixture/catalog sources stay unchanged.
Default oracles still require genuine ordinary `$tree` execution. Both new
catalogs pass maintained selection/hash validation; source qualification pending.

actual-oracle's --pair-state additionally requires actual BST down fresh-pair
marker and ordinary root execution, complete down Tuple/path/BF values, zeroalias,
positivefreshness, sibling/tail aliases, input snapshots and fresh leaf shells.
Root runs this independent actual residual-route proof.

Final frozen oracle identities are in final-oracle-tools-v3.json: actual-oracle-v2
(with mandatory --pair-state positive BST clause), pair-source-oracle-v3 and
pair-ignored-oracle-v2. Pair source v2's static counter omission was caught before
execution: its negative clause demanded old scalar worker entry but only $tree
FunctionDeclarations were instrumented. New v3 instruments both exact names;
prior versions are preserved. Validation owner received exact producer hashes,
reportfields and positive/negative clauses. Original precedence controls cannot
satisfy pair activation requirements. Handed-off files remain immutable.
