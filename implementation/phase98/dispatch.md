# Phase98: shared term observations and dispatch

These are chronological experiment notes. See the [phase report](README.md) for the selected final source, qualification, measurements and remaining limits. Earlier pending/preparation statements retain their original checkpoint scope.

Hypothesis H98-D1: repeated `tg(t)` calls in the actual checker dispatchers add
shared constructor projection and disposal work. Cache the immutable total tag
once, retaining the original term for the selected branch. The first isolated
candidate changes only `infer_node` (12 observations to one) and `check_node`
(eight observations to one). It adds two source lines and preserves each ordered
comparison, diagnostic string, and branch expression exactly.

Preparation is data-only through
`selfhost/tools/performance/phase98/dispatch/prepare.py`. Its frozen receipt binds
the D04 compiler SHA `d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097`
to exact canonical declarations in `selfhost/src/check/kernel.bend`, applying only
the established `String.eq` to `p88_string_eq` translation. Forward construction
and exact reverse replay establish patch identity. No canonical file is edited.

`tg` is total on all three KTerm variants and preserves arbitrary generic tags.
The extra observation on `check_node`'s literal path is permitted only by that
totality; literal identity is still decided by `core_literal`, not tag text. This
candidate leaves nested `kc` thunk allocation in place. A later candidate may
replace those with explicit typed dispatch stages, but will be frozen separately.

Phase97's unpromoted `f_find` optimization is not bundled.

## Frozen candidates and source cost

| Snapshot | Mechanism | Edited callers | Extra lines | Compiler SHA256 |
| --- | --- | ---: | ---: | --- |
| dispatch-frozen01 | Cache checker tags |2|2|`84a460ebdcb53bb08bf69de83f0b918b907119e56e1c4b01caa91a781572451a`|
| dispatch-frozen02 | Ordered selector + direct branch match |4|252|`501643ae9d4577e2320318b6e0a5bf0fd1ff3668cd85d28ee1df02340aa071aa`|
| dispatch-frozen03 | Selectors + bounded conditional lifting |19|525|`514b58b4d7c974a20f4ef95ba8a81428ed1e19f427e7562d9c1fefa3c7ad6f4b`|

All are under `selfhost/build/phase98/`, with complete compiler sources, exact
canonical module copies/patches, immutable methods and before/after receipt
spans. Canonical production and historical artifacts remain unchanged.

H98-D2 removes the discarded thunk branches in `infer_node`, `check_node`,
`ka_node` and `ka_type_node`. Four safe selectors return full nullary enum values
in the original comparison order. Each typed Bool stage matches a parameter;
the original unsafe branch expressions then run in a separate parameter match.
No computed-match syntax is used. The literal gates remain before tag selection;
infer's original fallback remains intact. Syntactic `tg(t)` sites38→5. The extra
252 lines are a real simplicity cost, not hidden generated-code savings.

H98-D3 extends the closure mechanism to `core_rebuild`, `core_apply_span`,
`core_beta`, `compare`, `norm_compare`, `norm_ref`, `infer_ref`, `infer_app`,
`infer_app_type`, `infer_adt`, `check_fits`, `check_lam`, `check_lam_done`,
`check_ctr` and `nc_lower_live_to`. It lifts only complete outer conditional trees
into typed Bool-parameter helpers and preserves the complete original branch
expressions and condition order. No extra eager observer is introduced. Across
all19 edited callers, `kc` occurrences64→7 and `nt_choose`28→0:85 removed choice
calls. Native lowering already cached its tag; its saving hypothesis concerns
capturing/discarding book, term, environment and target. The D04 bridge retains
the historical `nct_leaf` wrappers on two NC_Code fields exactly. Its additional
273 lines bring the combined source increase to525.

## Hoist outcome and actual generated C

The root's `dispatch-screen01/report.json` records48 exact complete C outputs and
48 exact diagnostics across six original sources and four balanced rounds.

| Source | Baseline request ms | Hoist request ms | Ratio |
| --- | ---: | ---: | ---: |
| small |57.5|57.5|1.0000|
| numeric_closed |100|99|0.9900|
| lexer_original |357|362|1.0140|
| map_closed |1467.5|1471|1.0024|
| functions65 |229|230|1.0044|
| unicode |57.5|59.5|1.0348|

Equal-case request geometric ratio is1.007493; process-wall ratio1.004350.
This is neutral/slightly slower, with ordinary run noise; no hoist promotion.
It establishes no candidate B2, full-self or product-runtime gain.

`dispatch/hoist-c-shapes02.json` pins the actual upstream baseline C and the
root-acquired `dispatch-checked01/program.c`, and retains the exact `spin_1`
constructor observer body. Within the generated infer family, syntactic tag
observer calls fall15→4, while heap allocations remain99 and closure constructor
occurrences128. The check family falls16→9 observer calls while allocations136
and closure occurrences164 remain unchanged. These families include inlined
branch work, hence their totals differ from the edited source bodies. They are
static occurrences, not dynamic operation counts.

At the infer entry (`program.c:418046`), the cached tag gains its own retain and
the false-branch closure grows15→16 fields. The original shared term observer
still calls `ctr_take` over all fields and sinks non-tag boxed fields. Hoisting
removes repeated projections but leaves closure ownership work and adds a tag
capture, consistent with the neutral screen.

## Wide dispatch outcome

The root's `dispatch-wide-screen01/report.json` records48 exact C and diagnostic
comparisons. Request medians across four balanced rounds are:

| Source | Baseline ms | Wide ms | Ratio |
| --- | ---: | ---: | ---: |
| small |59|58|0.9831|
| numeric_closed |99.5|98.5|0.9899|
| lexer_original |356.5|369|1.0351|
| map_closed |1393|1350.5|0.9695|
| functions65 |229.5|222|0.9673|
| unicode |57.5|56.5|0.9826|

The equal-case request ratio is0.987662; process-wall ratio1.001928. The modest
request reduction and neutral process result do not justify525 extra source
lines. This candidate is declined for production. Its laws and finite controls
remain useful applicability evidence and are tracked separately from promotion.

`dispatch/wide-c-shapes02.json` pins the actual upstream-generated17,616,778-byte
C (`d15a5940a105f46969fbdf3b722f663df67d8772ff1e314cd9999fb6e4a65126`).
The audit locates the exact three-constructor tag observer by decoded Lam/Lit
constants and field behavior; its symbol changes from `spin_1` to `spin_32`, so
counting the old symbol in candidate C would be wrong. The audit method is frozen
in `dispatch-code-methods01/methods/`; exploratory01 reports remain preserved.

| Generated family | Tag observations | Heap allocation sites | Closure construction sites | Explicit sinks |
| --- | ---: | ---: | ---: | ---: |
| infer_node |15→5|99→50|128→52|18→74|
| check_node |16→9|136→102|164→108|26→52|
| ka_node |8→2|29→13|44→12|2→14|
| ka_type |11→1|12→0|32→0|7→60|
| core_beta |1→1|2→0|4→0|1→1|
| core_rebuild |1→1|2→0|4→0|1→1|
| core_apply_span |1→1|4→2|4→0|0→0|
| nc_lower_live_to |13→13|172→95|220→108|34→119|

These static family counts include inlined branch work. They establish the
intended closure-removal mechanism, not execution frequency or a predicted
runtime reduction. More explicit sinks appear because disposal moves from
discarded closure bodies to direct selected branches. Remaining nested branch
conditionals still allocate closures. The actual compiler screen decides the
performance outcome; source counts cannot substitute for it.

## Law and finite-control boundaries

`dispatch-proof-check01/report.json` accepts four public full-enum selector laws
with33 stage lemmas and no opaque definitions. The exact frozen02 selectors are
unchanged in frozen03; their33 ordered reference conditions were separately
audited against original D04 callers. This proves selected enum equality for
arbitrary String tags. It does not universally equate recursive unsafe callers,
prove that a selected enum is mapped to the correct branch body, or establish
generated C ownership.

`dispatch-controls01/manifest.json` freezes41 finite expectations before target
outcomes. The independent Python specification has explicit tag membership maps,
not values generated from candidate selectors. Each result includes all four
branch indices, complete escaped tag, actual constructor literal discriminator,
and the surviving complete KTerm with metadata, duplicate children/removals and
source spans. It covers every recognized tag, generic Lit/Efq/FUnboundVar,
unknown/prefix/suffix/case/NUL/Unicode strings, both lambda quantity flags and
three literal kinds. Native and genuine-JS execution remain root-owned. The root's
`dispatch-controls-check01/report.json` passes all41 through genuine JS B2, with
successful checking and unchanged inputs. Native execution is not established by
that result. These controls exercise selectors and observation aliases, not
recursive branch bodies.

`dispatch-production01/manifest.json` separately reuses the unchanged226 Phase96
full-value expectations and32 native selections. It replaces only the parent
extraction's `core_rebuild` and `core_apply_span` with their exact frozen03 bodies
and helpers, adding exact D04 comparator dependencies. Production substitution
reaches these actual changed operations. The parent corpus does not extract or
invoke `core_beta`; the other17 changed wide callers remain outside this bridge.
All expected values, original inputs and native stdout remain byte-identical to
the independently accepted Phase96 parent. The root's
`dispatch-production-check01/report.json` passes all226 through genuine JS B2,
with successful checking and unchanged inputs. Its32 native cases remain a
separate unclaimed gate until actual execution evidence exists.

## Qualification path

The separate `selfhost/tools/performance/phase98/qualification/` methods bind an
explicit new source/image/emission/Clang receipt without changing public native
admission or hardcoding D04 as the candidate source. The first runnable immutable
snapshot is `qualification-methods01/methods/`; offline build authentication of
the hoist image passed in `qualification-bind-preflight02.json`. No new target
was run for that preflight.

The separately frozen `qualification-methods02` changes the full-Clang default
and maximum to6GiB RSS with16GiB available-memory floor, matching the current
guard. Snapshot01 and its existing binding evidence remain intact. A deliberate
backend change that changes generated C needs new independently frozen output
oracles and actual program execution; the historical exact-C mode is deliberately
insufficient for that case.

The runner derives candidate self-C and its full unsafe-dependency diagnostic
from an independent maintained native B2 reference, then compares candidate B1
and B2 self-emissions exactly. Build authentication leaves image qualification
false until the root combines self-consistency with semantic gates. Separate
methods cover4live+4cached controls,3 exact rejections,45 complete C identities,
and the unchanged native69+3 harness with31 explicit exclusions. No successful
self-emission is labeled a whole-compiler proof.

The intentional-backend path is separately frozen in `qualification-methods04`.
`observer-backend-policy02/policy.json` replays the exact permission-source recipe
and freezes all45 original full stdout/stderr expectations before target runs.
Candidate B1 must preserve the independent baseline B2 diagnostic for its exact
self source; candidate B2 must reproduce candidate B1's complete self C. The
changed-backend gates require B1/B2 emitted-C agreement and actual matched-Clang
program execution against the unchanged expectations. Historical C differences
are recorded explicitly. This is preparation, not a claim those targets passed.
An offline snapshot03 policy attempt misinterpreted sequential edit offsets;
its failure is retained in `observer-backend-policy01/failure.json` and corrected
without changing source or expected outputs.

The later data-only admission collector combines successful self, controls,
broad45 and native69 evidence into a compact nondefault native-stage manifest.
Changed backends additionally need source-bound permission/refusal/alias control
evidence. Its selected request assets are separate from the heavy historical
validation closure; the independent public launcher/archive lane consumes that
schema. No admission or default selection follows merely from preparing tools.

For the final composed source (`59b36a1c…`),
`combined-backend-policy02/policy.json` authenticates exact sequential edits,
including repeated call text and append edits, and freezes the unchanged45
program expectations. `combined-backend-specific03/report.json` is a successful
data-only consumer of the actual permission05/corpus executions and the final
declaration/proof bridge. Its29 evidence rows cover16 exact permission declarations,
five classified changed dependencies,13 final-source kernel laws,18 Boolean
controls, three emitted-program shapes, provider/raw refusals and complete native
outputs for the small and1444-pair/14-field corpora. It keeps `imageQualified=false`.
The two failed preparation attempts are preserved:01 compared declaration spans
with different trailing blank separators;02 incorrectly required ordinary JS
driver permission for print_err, which the original controlled API experiment
deliberately authenticates separately. Neither correction changes an expected
value or relabels a failed target.

The final-image continuation is frozen in
`qualification-methods10/methods/final-controls.py`. It checks the four unique
Bend control sources through both final images, full cross-stage C equality,
independent full diagnostics and original complete stdout/stderr after four
matched O2 builds. Snapshot11's admission collector independently consumes these
raw results with `--final-controls`; preparation alone claims no execution.
The bounded self request successor in snapshot09 permits4GiB RSS only when its
input equals the authenticated compiler source, with16GiB available memory.
It follows the retained2GiB `combined-b1-self01` stop and leaves general guard
and ordinary request limits unchanged.

`batch-continuity-plan01/plan.json` separately freezes all45 original Phase93
batch sources/C products and44 retained calibration plans. Snapshot11's root-only
continuity method emits through the final B2 and reports every whole-C match or
change. It builds no historical executable. Exact-C cases preserve prior product
evidence; changed cases require isolated new builds/executions and the unchanged
Phase93 timing rules before any generated-program runtime claim. This addresses
IO.args/print/now batch wrappers independently of the ordinary45 program gate.

The selected-source public replay recipe `profile-replay01.json` passes exact
forward and inverse source replay against the collector schema. It carries the
compact delta and original D04 capsule rather than intermediate compiler copies.
Audited native-host/observer document bytes are separately snapshotted for
isolated evidence replay; the source audits retain their original paths/pins.
The public request capsule and full qualification evidence closure remain
separate, so each ordinary request need only verify selected source/image/assets.

An a025 planning-cost continuation was prepared in `cost-backend-policy01` and
`permission-cost-declaration-bridge01`; methods12 freezes its proposed data-only
consumer. That consumer was not executed and no a025 backend qualification
receipt was produced. The root stopped this promotion path after the independent
native investigation identified eager nonmatching recursion in `noa_below` as
the immediate full-source failure cause. The redirect/cache candidates and their
accepted finite controls remain separate exploratory evidence; they are not
bundled into the forthcoming minimal correction or promoted by this preparation.
