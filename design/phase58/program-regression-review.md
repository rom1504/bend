# Phase58 generated-program regression review

The completed 45-point/23-source campaign has 669 successful fresh samples.
Equal-point candidate/TypeScript time is 1.056043× versus Phase56's 1.061620×;
the aggregate is flat. Morning, Map/Set and edit-distance nevertheless take
18.26%, 11.28% and 11.23% more time than Phase56 respectively. Installation
remains held while these observations are investigated. Ten percent is the
inherited report's review trigger, not a universal preregistered release gate.

First compare exact saved choice01 and shared01 modules. This introduces no
compiler change. Map/Set, edit-distance and local-pair are byte-identical across
that step; their regressions cannot originate in shared-dispatch printing.
Morning and Evening change only through sharing two-member recursive components.

Use the unchanged program runner's 60-second preset for two independent
four-point campaigns: Morning, Evening, Map/Set and edit-distance, reversing
case order in the second campaign. Each uses three rotated fresh-process rounds
per role, 350 ms warmup, 40 ms calibration and 150 ms measured target. Roles are
genuine saved choice01, genuine shared01 and the exact pinned TypeScript output.
Every output oracle remains active. Byte-identical controls reveal measurement
and process variability. Record both runs separately; do not pool their medians
into the full45 aggregate or assume shorter warmup equals the full campaign.

An additional independent run of those same four points compares Phase56 with
shared01 to test whether the initially observed regressions repeat. Preserve all
rounds and drift/spread observations, including outcomes that disagree with the
first campaign. Root runs targets serially with the unchanged memory guards.

If the isolated Morning comparison supports a sharing cost, test one general
structural policy: share components with at least three members. Static analysis
predicts this preserves about 97% of the compiler-image sharing savings while
keeping two-member code unchanged. This is a candidate discriminator, not an
implementation decision. It requires a positive three-member focused fixture
and retained two-member nonsharing controls, then fresh source/image admission.
Do not tune names or thresholds to individual benchmark identities.

Separately inspect the actual Phase56-to-choice01 source differences for the
unchanged-byte controls. Any next experiment must isolate the corresponding
general mechanism before another full build or campaign. A source-syntax
derivative may establish causality but cannot qualify a checked release.

Keep the full campaign authoritative for representative performance. A bounded
diagnostic can explain a regression or justify a specific successor; it cannot
erase it. If material regressions remain, explicitly record the tradeoff and
keep the installed compiler unchanged until the non-regression objective is
resolved. Compiler B2 gains, installed B1 latency and generated-program time
remain separate results.

## Follow-up: interaction with literal record keys

The three planned screens completed with 108 passing observations. Sharing
changes Morning/Evening time by about ±1% in the two comparisons, while the
Phase56-to-shared Morning slowdown repeats at about 10%. No component-size
policy is justified by this result; retain the existing sharing rule.

Independent parser-only reconstruction shows that replacing computed constant
record keys with quoted keys reproduces the complete new Map/Set, edit-distance
and local-pair modules exactly (1,008 / 16 / 20 edits). This isolates their code
delta. The short-run Map/Set result changes direction substantially, emphasizing
warmup dependence; the original longer campaign remains visible.

Test whether literal-key printing still helps the compiler after constructor
lookup and residual-allocation fixes remove its original hot paths. Derive an
explicitly unchecked saved shared01 B2 image restoring computed keys only at the
three affected printer shapes. Preserve tagged object fields, host spread fields,
tag keys, special-key behavior, strings, exports and all unrelated bytes. Require
AST validation and exact inversion. Use the existing private-image library
method with genuine shared01 B2 as parent, exact output oracles and separate
first/later timings. This is a fixed-source interaction test, not a source-build
or release claim.

If this syntax optimization now has little benefit or costs more than it saves,
remove it uniformly from the three Bend printers and remove the helper. Do not
special-case a program, record name or field count. Fresh checked-image, focused
semantics, B2 reproduction, compiler costs and representative program measurements
then qualify the simpler successor. Retain all early literal-field gains as
valid observations for their original image; a changed workload can invalidate
the decision to retain an optimization without invalidating the experiment.

## Second discriminator after the rejected full rollback

The fixed-source rollback is materially worse on both compiler workloads:
first-request medians rise about 48–52% and later-request medians 56–68%, across
three fresh processes per role/input. All outputs agree. Thus uniformly removing
literal-key printing is not selected, and its original benefit survives.

There is a new, explicitly post-hoc hypothesis: wide escaping records may benefit
from literal construction while narrow loop-carried records have different V8
behavior. The compiler uses eight-field KTerm and nine-field KDef records; the
regressing DP state has four fields and common Map nodes three. Width is correlated
with payload and escape behavior, so this observation is not a production cost
model or permission to tune a threshold against benchmark names.

Run one saved-image diagnostic restoring computed fields only on fully known
tagged constructors with at most four ordinary live fields. Exclude the tag from
width; count existing computed/special keys, retain `__proto__` spelling, and leave
spread records unchanged because their total width is unknown. Apply the same
AST/inverse/runtime checks and three-process two-input compiler protocol. Record
static site counts separately from dynamic allocation or timing.

In parallel, inspect the old/new DP caller's optimized V8 code and allocation
behavior with the existing complete output oracle. Standalone `cell.f4` returns
the record, so any scalar replacement must be studied after caller inlining.
No traced timing enters clean comparisons. A production width rule would require
independent width/payload/escape controls and evidence of a stable relevant
boundary; the immediate goal is to localize the tradeoff. Keep source unchanged
and installation held while that question remains open.

## Final bounded key-placement discriminator

The narrow-width diagnostic still increases compiler first-request time about
16% and later requests 27–36%; it is not selected. The DP optimized-code capture
shows the same eight inlined functions, four static 64-byte allocation paths,
and no executed deoptimization in either variant. Thus neither lost scalar
replacement nor a width-four boundary is established. An independent synthetic
width grid was prepared but remains unexecuted; it is not supporting evidence.

One final syntax discriminator preserves the static record prefix and makes only
the last ordinary constructor key computed. This has no type-name, field-name or
width exception. The hypothesis is that this keeps most literal-prefix benefit
while changing the final map initialization/store sequence seen in the DP trace.
It is a hypothesis, not a source-backed V8 optimization claim.

Use exact AST/inverse derivations for the same B2 and the saved Morning, Map/Set
and edit-distance modules. Keep spreads, tags, existing computed/special keys,
value evaluation order, runtime and exports unchanged. Measure compiler requests
with the existing three-process two-input method; measure the three programs with
the unchanged longer program protocol and full oracles. Diagnostic modules must
be labelled as such, with genuine checked parents retained separately.

An implementation is worth qualifying only if it preserves most compiler
benefit (roughly within 10% of current first/later medians) and materially removes
the reviewed program regressions. Keep all samples and uncertainty rather than
turning these screens into a statistical guarantee. Do not continue searching
record syntax variants if this one fails. Consolidation must then make the
compiler-versus-program tradeoff explicit; uniform computed fields remain the
conservative way to preserve prior generated record code, with the now-measured
compiler cost, instead of inventing a program-specific exception.
