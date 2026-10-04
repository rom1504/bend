# Phase43 String handoff

Actual checked08 lexer source now passes the full semantic owner:439 oracle rows,
113 host/demand/Error/mutation boundaries, and3 activation observations, including
ordinary complete bench/batch entry and full owned String/Mode/Tuple intermediates.
All three renamed/alias/custom-field/literal-refusal fixture controllers also pass;
compiler type/admission controls pass59 probes. Raw reports retain prior failures.

The paired source screen improves checked16 by10.911× at depth8 and12.658× at depth6;
the remaining gap is7.003–7.392× TypeScript. The earlier saved-JS prototype showed
17.67–18.84× gain and roughly5× TypeScript. Prototype results do not describe the
actual compiler. No installation or full steady-state result is claimed here.

Latest frozen tools: source-instrument-v5.mjs, source-controls-v4.mjs,
type-controls-fast-v7.mjs (59 compiler proof probes), fixture-catalog-v4.json and
fixture-controls-v2.mjs. Exact current preparation commands are in
selfhost/tools/performance/phase43/strings/fixture-handoff-v4.md. Earlier commands
below document historical consumed versions and must not replace this handoff.

Root executes serially from repository root, using fresh Phase43 output paths:

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 30 \
 selfhost/build/phase43/strings-derive-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase43/strings/derive.mjs \
 selfhost/build/phase42/integration03/runtime-batch1/modules/candidate/modules/lexer.mjs \
 selfhost/build/phase37/typescript01/modules/lexer.mjs \
 selfhost/build/phase43/strings-prototype01
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 120 \
 selfhost/build/phase43/strings-controls-run01 -- taskset -c 3 "$NODE" \
 --max-old-space-size=1024 selfhost/tools/performance/phase43/strings/controls.mjs \
 selfhost/build/phase43/strings-prototype01 selfhost/build/phase43/strings-controls01
```

Create a fresh compare-small.json selecting variation-lexer-6-17 from the
produced compare.json, then use the existing Phase35 comparer:

```sh
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase43/strings-prototype01/compare-small.json \
 selfhost/build/phase43/strings-screen01 --node "$NODE" --cpu 3 --budget 20
```

The catalog default.bench is the timed public export. Use the produced full
compare.json only after controls and the smallest-point discriminator survive.
Derivation also parses generated modules with the Node-bundled Acorn parser.
Report pins derive, worker, parent, comparator and generated module identities.

Controls inherit corrected Phase40 BigInt state/token arithmetic and add full
generated String comparisons, zero/nonzero ident/num complete outputs, mode/
tuple/fresh-field allocation and unchanged-input alias assertions, ordinary
public activation for each role and gen/line/batch/lex/step liveness for full,
raw code/partial demand, argument mutation before guard, and Error constructor
reentry. Existing controls cover Unicode/astral/lone surrogates, source metadata,
getters/bindings, String global/static/fromCodePoint/codePointAt/slice mutations,
marker hooks, Array/Object hooks, exceptions, deferred foreign tuple demand and
100000-character loop stack. Complete generation comparisons include invalid
surrogate constructors with exact error observations.

Limit: handwritten full workers establish the mechanism only. Source-valid
admission and actual ordinary compiled activation must be proven after root
integration; adding dead emitted workers or accepting String purity cannot
substitute for that evidence. No new proof flag is opened in this prototype.

The production admission proposal is saved as
[admission-proposal.patch](../../selfhost/tools/performance/phase43/strings/admission-proposal.patch),
with standalone ABI/runtime chunks alongside it. It extends exact native type
and literal0/Ref proof support, substitutes only exact covered original literal
references, captures only admitted compiler wrappers, and threads a conservative
String-family capture flag to scalarGuard's host-family check. It has not been
applied, compiled or qualified. Existing closed Sigma1/1 support stays shared.
Structural lowering activation remains an independent gate after this patch.

Reviewer correction before execution: bad() in every saved-JS role now suspends
and restores $lxActive around Error construction. A nested public step otherwise
could borrow rewritten fast edges while the diagnostic manual scope was active,
even though its nested root guard refused. The Error control asserts the flag is
false and that nested step adds no private counters. All prior Phase40 artifacts
remain untouched. Screen budget corrected to the supported20second preset.

The first root derivation failed its inherited cls-site assertion (actual2,
expected1). derive.mjs preserves that failed input. Frozen derive-v2.mjs corrects
only the static expectation to cls2/step1/lex2; a static Acorn inventory locates
the duplicated classification call in checked16's separate prior-private/fallback
branches. Both remain individually guarded operation sites. Use derive-v2.mjs
for the next root attempt; controls.mjs/full-workers.js are frozen.

Root executed strings-prototype02/strings-controls02 with frozen derive-v2 and
controls: selected controls pass in4.925s. strings-screen02 reports two manual
ordinary-bench points: depth8 original148.604ms/full8.40919ms/TypeScript1.68566ms
(17.67× faster than original; still4.99× TS), depth6 original42.1182ms/
full2.2355ms/TS0.403994ms (18.84×; still5.53× TS). These root-provided short-screen
results are mechanism evidence, not a source/installed improvement; exact raw
report remains root's authority and further source activation is pending.

The integration proposal is now combined-proposal-v3.patch, against current
production including product-owner tree additions, with staged review source
copies under proposal-v3/. It combines exact ABI/literal0 proof, all three
native matcher capability gates, source-project native fields, once-per-entry
String family guard, normalized typed-family traversal and the exact total U32
helper-prefix gate needed by prng in ident/num. Earlier admission-only and fixed
native-temporary patches remain preserved; v2 matcher temporaries use constructor
plus typed environment depth to keep outer tail references distinct from nested
Chr projections. Normalized family traversal shares512 work steps; unknown type
or budget exhaustion conservatively requests the String guard. Prefix admission
checks original all-U32 telescope, acyclic direct plan, bounded total U32 primitive
syntax and canonical arguments; no allocation/container/effect helper prefix is
added. Root alone applies/builds/tests the integration.

Root applied combinedv4; checked03 composition failed immediately because the
proposed j_string_char predicate collided with an existing literal helper of
that name. Root renamed the new exact ABI predicate to j_string_char_type in
production's finite/jpure/tree consumers, preserving the literal helper. The
original failed proposal remains unchanged. type-controls-v2.mjs exposes the
correct renamed predicate; use it with the actual source catalog lexer fixture
at selfhost/tools/performance/phase37/fixtures-historical/lexer.bend. checked04
integration is running under root ownership; no successful source qualification
is yet claimed here.

Actual checked05 qualification did not activate an owned root. Source acquisition
completed in6.69s; fast ABI/refusal controls passed45observations (5.8s including
checked-source capture). Scope-aware actual instrumenter passed; source-controls
then failed ordinary-root activation after375value observations. No host boundary
groups ran. Static emitted inspection confirms generic G.bench/G.batch and only
ident/num/expand/gen structural workers; no lex component. New emitted workers
are therefore not a delivered execution improvement. Fast-v4 signature diagnostics
were prepared to report exact normalized parameter/result quantity and graph
refusals without requiring library emission.

Root also found runtime composition had not been refreshed: checked05 snapshot
runtime.mjs retained the old runtime although core.mjs had changed. The375early
observations do not qualify the new String-family host guard. Root will regenerate
runtime before the next checked derivative. Proposed predicate-fences-v5 adds
explicit kc rejection before irrelevant native-owner lookup, nullary body/type
proof and expensive recursive purity calls; the old failed proposals stay saved.


Checked05 signature diagnostic (strings-graph05) identifies Bool.and as the
remaining immediate lexer graph blocker: both Bool parameters/results are admitted,
step.at/direct are valid, and lex's Sigma parameter is admitted, but Bool.and is
native=true and refused by the XOR-only native purity validator. This corrects the
earlier assumption that emitted matcher code implied a nonnative source definition.
Frozen bool-and-v1.patch preserves the emitted public matcher and fallback ABI,
captures its final descriptor, and selects && (with both invocation arguments
evaluated in source order) instead of the XOR emitter's !==. Root/reviewer own
integration and qualification; no new source activation pass is claimed here.

Frozen fixture-catalog-v1.json pins three source identities and independent
bench(0,0) outputs (1412342859,1412342859,154). fixture-controls-v2.mjs requires actual
complete outer graph activation for renamed cases, and refuses bench/rows activation
for computed nullary; isolated inner worker activation is permitted. Commands are in
selfhost/tools/performance/phase43/strings/fixture-handoff-v1.md. Node24 static syntax
check passed; root runs checked preparation and controls.

Consumed fixture-catalog-v1 failed preparation immediately (missing standard catalog
sets). It is preserved. fixture-catalog-v2.json now has complete standard
kind/schemaVersion/upstreamCommit/sets/cases/source identity/point shape, with
source paths confined to the catalog directory. Frozen handoff-v2 supplies exact
preparation and instrumentation commands. bool-and-v2.patch similarly preserves v1
and adds cheap name/header fences before telescope normalization; reviewer pending.


The checked Bool.and body is now pinned structurally by bool-and-v3.patch rather
than admitted from name/signature alone. Its False arm returns False, True arm
returns the exact second argument binder, final arm is Efq; quantities, child
counts and empty removed lists are exact. Private && evaluates both source
arguments left to right before invocation and preserves the public source matcher.
type-controls-fast-v6.mjs adds canonical positive and eight altered-body/native
refusals. git apply --check succeeds against current production; Node24 syntax
checks pass for the controls. Parent/reviewer integration still pending.

Baseline fixture preparation found affine seed reuse in the branch roots before
emission. Original source files remain frozen. New *-v2.bend files explicitly use
+seed where both recursive branches consume it; fixture-catalog-v3.json pins these
new identities with unchanged independent expected values. Preparation/catalog
failures are not correctness passes or performance results.


Actual checked06 source controls failed after363 oracle rows with undefined $u0
in ident's emitted worker. The deeper cause was original Let(prng) admission vs
covered Ann(JDirectCall) prefix refusal, which selected a wrong continuation
combiner (child sentinel32, empty next args, G[""], and u0..31). Frozen
prefix-lowered-v1.patch normalizes only lowered JDirectCall to its Call name/args
for the existing exact U32 helper proof, preserving all type/body/direct checks.
Reviewer statically approved Bool.and-v3 and prefix-lowered-v1 for source testing.
No source correctness/activation pass is claimed until root's next actual run.

Frozen source-controls-v2.mjs uses source-specific report kind and requires actual
ordinary complete outer entry root:bench or root:batch as well as all gen/lex/
ident/num/step workers. Exact final counts439oracle/113boundaries/3admission.
type-controls-fast-v7 adds five original/covered prefix proof and refusal probes
(total59), while retaining suppressed compiler emission. Fixture-catalog-v4 pins
fresh *-v3 sources with +depth and +seed; original failed files remain frozen.


Actual08 source-controls-v2 passed438 oracle rows including complete ordinary
outer activation, full materialized generated String and every native Mode/Tuple
intermediate, then reached69 boundary rows before a controller-only batch mutation
failure. The compiler correctly refuses bench/batch whose guard includes mutated
batch while generic fallback calls independently guarded line roots. Blanket
all-fast-counts-zero is valid for the earlier single manual flag but overrestricts
source independent roots. Frozen source-instrument-v5 derives exact lexical
$guards for each guarded root via AST scopes, records site dependencies and exports
sourceGuards. source-controls-v3 forbids only roots whose own dependency list
contains the mutated binding, requires a witness root and no ambient proof leak,
and retains complete value/event comparison. Total final counts remain439oracle,
113boundaries and3admission. No final source qualification pass is claimed yet.


The independent-root mutation contract passed reviewer static review. Frozen
source-controls-v3 initially demanded a positive affected-root witness from the
original baseline, which has no qualified full graph; this controller failure is
preserved. source-controls-v4 requires that positive witness only for candidate,
while still refusing every affected baseline root if present. Full value/event
parity and no proof leakage remain mandatory. source-instrument-v5 is unchanged.
Exact final controller totals remain439oracle/113boundaries/3admission.


Checked08 final source evidence (root-run, preserved):

- selfhost/build/phase43/strings-controls08-v4/report.json: complete/pass,439oracle,
  113boundaries,3admission; instrumentv5/controlv4.
- selfhost/build/phase43/strings-native08/report.json: complete/pass,59proof probes.
- selfhost/build/phase43/string-fixture-controls08-typed-components-v3/report.json:
  9values/30boundaries/2activation, complete/pass.
- selfhost/build/phase43/string-fixture-controls08-typed-components-renamed-v3/report.json:
  9values/30boundaries/2activation, complete/pass.
- selfhost/build/phase43/string-fixture-controls08-negative-literal0-v3/report.json:
  9values/24boundaries/2activation, complete/pass; outer bench/rows stays generic.
- selfhost/build/phase43/checked08-lexer-screen02/report.json and report.md:
  paired three rounds, lexer8 baseline151.524ms/source13.8871ms/TS1.98298ms
  (gain10.911×;source/TS7.003×), lexer6 baseline40.7852ms/source3.22199ms/
  TS0.435891ms (gain12.658×;source/TS7.392×). Short screens are not full
  steady-state evidence.

Residual source waste identified statically with guards owner: ident/num repeat
puretotal PRNG prefixes during phase2 resume; gen repeats native String/Char
projections even when continuation uses only saved fields and returned value. A
future typed continuation plan can track postchild binder/field liveness and omit
only proven dead total work under the same captured graph/host guards, preserving
all required reconstruction allocations and original generic fallback. No new
optimization is implemented or measured by this observation.
