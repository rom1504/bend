# P43-001 — Full owned native-String lexer component

Hypothesis: one exact public entry guard plus full typed lexical component
removes generic generator/lexer dispatch and yields >=2× checked16 lexer runtime,
while preserving complete String/Char, Slot/Cls/Mode/Sigma, demand, host and alias
semantics. Domain: saved emitted JS first; source promotion is separate.

Owner: phase43_strings. Baseline: installed Phase42 checked16 API
63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54,
commit714c5f5, upstream0187512. Historic phase42 artifacts are read-only.

[Design](../../design/phase43/strings.md),
[handoff](../../implementation/phase43/strings.md),
[derive](../../selfhost/tools/performance/phase43/strings/derive.mjs),
[controls](../../selfhost/tools/performance/phase43/strings/controls.mjs).

Current evidence: root-run saved-JS controls passed, and two paired small points
showed 17.67–18.84× over selected checked16. Actual source qualification remains
pending: checked05 failed complete activation; checked06 failed ident covered
prefix emission. Reviewed fixes are integrated in checked08; static emitted
prefix/outer guard inspection passes. No actual source performance result or
installation claim is made. Frozen actual source owner requires ordinary complete
outer root activation, complete intermediate values, host mutation/demand/Error
boundaries and deep stack behavior; dead emitted workers cannot qualify.

Original/noise same complete bytes quantify same-run variation. Guard, class,
step and lexical-consumer complete ablations precede full producer+consumer.
Full retains all data materialization; faster output cannot justify fusion.
Root serializes bounded jobs and timing; owner runs no compiler/build/program
execution. Failures and timeouts retain fresh output directories and JSON status.

First root derivation failed before module generation at the stale cls-site
count inherited from Phase40. Corrected derive-v2.mjs retains the exact selected16
parent hash and static counts cls2/step1/lex2. Original derive.mjs remains the
failed consumed version. No correctness or measurement status upgrade follows.

Root selected controls pass for strings-prototype02/strings-controls02 (4.925s).
Two manual ordinary-public fullcomponent screen points show17.67×/18.84× over
original and4.99×/5.53× TypeScript. This exceeds the saved-output discriminator;
source integration is now justified but unqualified. The combined-proposal-v3
patch retains actual native matcher lowering plus prng-prefix support; acceptance
requires generated source activation and full controls on the emitted derivative.

Actual checked05 emitted source fails root activation after375value observations;
G.bench/G.batch remain generic and no lex worker is emitted. Correctness does not
advance to host qualification.45canonical ABI/refusal predicate tests pass.
checked05 runtime snapshot was stale (core edit not yet composed), so earlyvalue
passes cannot qualify new guards. Missing complete actual graph remains a blocker
for source promotion; fast normalized-signature diagnostics prepared.


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


Source controllerv3 baseline-only positive-witness failure is preserved; v4 makes
positive graph witnesses candidate-specific while enforcing any existing baseline
root dependency refusal. Reviewer approved the independent-root interpretation.
Complete final owner remains instrumentv5/controlv4,439oracle/113boundaries/3admission.
