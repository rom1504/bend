# Phase98 independent challenges and review

These are chronological experiment notes. See the [phase report](README.md) for the selected final source, qualification, measurements and remaining limits. Earlier pending/preparation statements retain their original checkpoint scope.

Status: independent choices frozen; the first unchanged finite suites and held
and dispatch formal challenges have completed. Targeted follow-ups have completed separately; further
candidate qualification remains separately reported. This review track runs no compiler,
proof-checker or program targets and makes no canonical source changes.

## Selection and evidence boundaries

The first freeze was at **2026-10-15 20:13:56 UTC**, before the reviewer inspected
any Phase98 law bodies, finite cases, oracles, candidate implementations or
outcomes. Selection used maintained term helpers, the actual safe string helpers
embedded in D04, Base's character operations, and Phase95's ownership attribution.
Other agents provided only intended interfaces and source locations before this
freeze. Prior Phase96/97 results and the broad goal were known: this is
independent selection, not rigorous blinding.

[Initial manifest](../../selfhost/tools/laws/phase98/challenge/manifest.json):
SHA-256 `e833a5dacf7ff2f6a1cd0643199b052067f39d5ce81d795308ac487a641c8cef`.
It records five synthetic faults and two equivalent controls against source
commit `8eb661e612d1c882eef32e0d1c05836c7fc571bf`. Every unique edit was also checked
to occur exactly once in the authenticated D04 compiler source
`d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097`.
This is an exact source connection, not an assertion that every helper input can
be produced by the language frontend.

At **20:15:37 UTC**, a separately labeled supplement selected one fault from the
new literal recognizer's helper-only source. Its tests, laws, oracle and admission
results remained unread. The
[supplement manifest](../../selfhost/tools/laws/phase98/challenge/literal-manifest01.json)
has SHA-256 `72f7929949f241ebce32f9692c80582cce360b1cc4acda68d72d69dd4ff583da`.
It links the earlier frozen manifest without changing its choices. A second
candidate-source supplement was frozen at **20:19:28 UTC** after reading only
the new dispatch and held-observation helpers and their intended interfaces.
The [aggregate manifest](../../selfhost/tools/laws/phase98/challenge/all-manifest01.json)
has SHA-256 `7c6d0d7195b6acce4cbc03ed0da6e1df5ca7c19aebbd989208d3fe491ee5385d`.
The complete set has **eight bad changes and two equivalent controls**. No new
law bodies, finite case bodies, oracles or outcomes were inspected before this
final freeze. The reviewer inspected those materials only afterward, to prepare
the execution adapter and review the evidence.

All recipes have exact before/after source spans, original and changed full-source
hashes, rationale and independently reasoned complete-value witness expressions.
The adjacent `.witness.bend` files require their exact helper dependency closure;
they are not complete executable assemblies. Admission is predicted from source,
not yet verified. Recompute extraction dependencies after mutation rather than
mistaking a new missing helper for a semantic rejection.

## Frozen cases

| Recipe | Change and distinguishing behavior |
|---|---|
| bad01 logical literal / constructor | Replace `core_literal`'s constructor match with `tg(t) == "Lit"`. A generic `KTerm` whose arbitrary tag is `Lit` is incorrectly accepted as a literal. This witness is valid typed helper data, without a parser-reachability claim. |
| bad02 lambda variant | Reconstruct `KLambda` as generic `KTerm` while updating children. Tag/name/ID/quantity/children survive, but the exact constructor and explicit `quantityPresent = False` disappear. The witness retains nontrivial children, removal metadata and source spans. |
| bad03 equality carry | Return true at simultaneous string end, ignoring the accumulated result. `"ax"` versus `"ay"` becomes equal. |
| bad04 lexical carry | Reapply shorter-prefix order despite an earlier greater character. `"b"` versus `"aa"` changes from `GT` to `LT`. |
| bad05 character width | Compare only the low eight bits of each character. U+0141 `Ł` and U+0041 `A` become equal. This is exact codepoint identity, not a normalization issue. |
| bad06 literal prefix | Change the recognizer's terminal `SNil` into an ignored tail. `p98_eq_var("Varx")` becomes true. Selected from candidate helper source, separately from the maintained-source set. |
| bad07 grouped dispatch | Drop `Efq` from the `Mat || Efq` selector predicate. `p98_check_node_select("Efq")` selects Default instead of branch 2. |
| bad08 complete held observation | Return left again in the right slot of `P98EqHeld`. The complete returned helper value changes for `("left", "right")`; the final public Bool can remain correct. This is explicitly an internal full-value contract fault, not necessarily a whole-compiler semantic regression. |
| good01 exact literal reconstruction | Replace returning the original literal with rebuilding all its fields exactly. Finite values must remain equal; no allocation or pointer-identity equivalence is claimed. |
| good02 full codepoint equality | Replace `Char.is_eq` with `U32.is_eq` on both complete `Char.to_u32` fields. Base defines these operations by the same `Chr` payload; unlike bad05, no bits are discarded. |

The first data-only producer stopped after five recipes because good01's short
span was not unique in the term module. The
[failure record](../../selfhost/tools/laws/phase98/challenge/preparation01.json)
preserves that attempt. Its successor scopes the good01 span to the complete
function and verifies all five prior bad recipe/witness files unchanged. This is
a preparation failure, not a compiler admission failure or semantic result.
The first candidate-supplement producer also had a Python syntax error before
executing any code; its exact bytes are retained as a `.py.txt` artifact. The
corrected producer creates the supplementary recipes without changing prior files.

## Prepared finite and formal execution methods

[challenge-prepare.py](../../selfhost/tools/laws/phase98/challenge-prepare.py)
prepares immutable suites, while
[challenge-run.py](../../selfhost/tools/laws/phase98/challenge-run.py) reuses the
unchanged Phase97 JS executor, source checker and serial CPU3 resource guard.
[Exact derivation diffs](../../selfhost/tools/laws/phase98/challenge-derivation.json)
pin their source methods and new adapters. Preparation and Python syntax checks
are data-only; root owns every eventual target.

The production suite retains all 226 original case objects exactly; its closure
contains `k_with_children` but none of the other challenged helpers. The original
string suite retains all 1,444 pairs and every equality/order/reused-input field.
The held suite uses that same corpus and transfers the frozen equality edits by
an explicitly recorded private-walker rename. Both expected matrices were
independently computed from the frozen codepoint oracle and then checked to equal
every field and order of the historical accepted 85,349-byte output. The literal
suite retains its existing ten inputs and all seven output fields.

The targeted mode separately contains ten independently frozen witnesses and
recomputes dependency closure after each mutation. In particular, bad01's new
`tg` dependency is included; an absent import cannot earn detection credit. Its
expected wire values are full-value encodings of the frozen witness expectations.
Root must record unchanged-suite outcomes before using this follow-up.

The formal mode accepts the proof agent's pinned job plan. It requires each bad
helper's successful standalone check before a semantic law rejection. A valid
refactor's unchanged-proof outcome is observed without prelabeling it a fault;
its support-proof repair runs the full independent checker. All public law
statements and bodies must remain fixed during that maintenance exercise.

## Required incremental-evidence protocol

Run the existing finite tests unchanged before adding these witnesses. Freeze the
new law statements, bodies, dependencies and baseline execution before evaluating
the bad changes. For each fault separately record:

1. Whether the changed helper is admitted; a type/affinity failure receives no
   semantic credit.
2. Whether the unmodified finite suite detects it, or the helper lies outside that
   suite's dependency closure.
3. Whether the frozen formal obligation rejects that admitted helper, with the
   specific changed-helper connection and failed equation identified.
4. Only after retaining these results, whether the independent targeted witness
   detects an earlier escape.

Classify **proof-only, finite-only, both or neither** only for admitted changes
that both methods actually cover. Report extraction/domain gaps separately.
A targeted witness added after an escape improves the suite but must not rewrite
the initial classification. Do not turn the deliberately small chosen set into
a statistical mutation-coverage rate. Report both equivalent controls as a law
maintenance check; a brittle proof body failing after an equivalent refactor is
not evidence that the refactor is semantically wrong.

Bad02 specifically challenges an observation-only specification. A theorem that
only preserves tag and children could accept it while the real compiler's full
term value changes. Either use an exact reconstruction/full-value contract or
state the narrower projection theorem and qualify callers separately. A model
with the same constructor names is insufficient without exact extraction or an
authenticated adapter connection.

## Optimization and ownership review criteria

Phase95's accepted Map profile assigns 56.44% of request samples to cleanup, but
its physical owner counts are not removable-time estimates. Its full-self
comparison bucket is exploratory because the profile failed the declared loss
rule. Phase97 already showed that a roughly threefold helper improvement can
produce only a noisy one-percent whole-compiler screen difference. Another
microbenchmark win alone cannot support promotion.

Source-level changes can affect upstream-built native B1 and self-emitted B2.
An own-C-emitter change cannot explain B1 execution gains. Keep request time,
whole-process time, image construction and generated-program runtime separate;
preserve balanced order and exact output/diagnostic comparisons. Reuse unchanged
product artifacts rather than rerunning irrelevant runtime measurements.

The pure laws here concern returned values. They cannot certify native borrow
inference, safe escaped-child lifetime, reference-count operations or allocation
savings. A shared-observation candidate still needs inspected generated C and
native controls retaining aliases until after the operation, checking their full
values on final consumption. Those checks are finite runtime evidence, not a
whole-memory-model theorem. Any stronger ownership claim needs its own concrete
lowering/runtime connection.

## Observed unchanged-suite results

The reviewer rehashed the pinned inputs/child receipts in all four finite
reports, both formal reports and the successful maintenance receipt. All target
executions below belong to root; no target was run by this reviewer.

| Independent recipe | Existing finite result | New frozen formal result |
|---|---|---|
| bad01 logical literal | Outside the unchanged226-case extraction closure | Not yet tested against a connected obligation in this campaign |
| bad02 lambda variant | Detected; six complete-value observations differ | Not yet tested against a connected obligation |
| bad03 equality carry | Detected by the unchanged1,444-pair string corpus, also by its held-wrapper reuse | Helper admitted; held equality law rejects |
| bad04 lexical carry | Detected by the unchanged string corpus and its held reuse | Not part of the held equality contract |
| bad05 character width | Detected by the unchanged string corpus and its held reuse | Helper admitted; held equality law rejects |
| bad06 literal prefix | Detected by the existing ten-input literal suite | Not yet recorded here |
| bad07 grouped dispatch | The226-case suite does not include this candidate selector; separate41-case selector corpus exists | Helper admitted; frozen dispatch law rejects |
| bad08 complete held observation | Escapes the old public-Bool/reused-input observations | Helper admitted; complete held-observation law rejects |
| good01 exact literal reconstruction | All226 complete values unchanged | No new connected proof exercised |
| good02 full codepoint equality | All original string/held corpus observations unchanged | Helper admitted; unchanged support proof needs maintenance; separate corrected support proof accepted independently |

These are five distinct bad changes detected by the currently executed finite
suites, not a mutation coverage percentage. Repeating bad03/04/05 through both
wrappers does not create six independent discoveries. The pair matrix is one
aggregate serialized case containing1,444 pairs and every original output field;
do not inflate it into1,444 independently proved properties.

Bad08 is the strongest example of a useful stronger contract, but its meaning
must remain precise. The finite suite observes the public Bool and retained
external input aliases. The law additionally observes both fields returned by
the internal held helper. Repeating the left root in the right field violates
that stronger internal contract while the public Bool can remain correct. This
is **specification expansion**, not proof that the identical public-Boolean bug
escaped tests. Bad03 and bad05 are detected by both methods; this chosen set has
not yet demonstrated an incremental same-contract semantic detection by proof.

Receipts: `selfhost/build/phase98/challenge-{production,strings,held,literal}-check01/report.json`,
`dispatch-formal-check01/report.json`, and `held-formal-check01/report.json`.
The last report intentionally remains `complete:false`: its first eight jobs
establish the admitted bad-helper rejections and valid-refactor maintenance
result, then the first support repair fails the language's pattern-order syntax
restriction. This failed repair is preserved and receives no semantic credit.

The separate `held-maintenance-check02/report.json` is complete and independently
checked, with five accepted law definitions and no opaque definitions. Its exact
source is `selfhost/proofs/phase98/comparison/maintenance02/held-exact.bend`,
SHA-256 `54161810d0047c18989ca563cdfd3c98c0bd343da3bcbf3a9e79cf0887b48bda`.
The two-line support repair moves Chr patterns to the enclosing Cons match;
public statements/bodies and the reference remain fixed. A valid equivalent
helper failing an old proof body was therefore maintenance work, not a compiler
or semantic fault.

The separate `challenge-targeted-check01/report.json` is complete. The reviewer
rehashed its pinned inputs and child receipts and checked all11 role results:
the10-case baseline and both equivalent controls pass; each of the eight
admitted bad variants produces a complete-value mismatch, without case-loading
or compiler-admission failures. These witnesses were selected before outcomes
but were introduced into execution after the unchanged suites. They close the
observed extraction/contract gaps and catch bad08's full returned value. This
follow-up does not rewrite the original five finite detections or turn the
chosen challenge set into a coverage estimate.

A later, separately labeled candidate-specific challenge is frozen in
[tag-candidate04.json](../../selfhost/tools/laws/phase98/challenge/tag-candidate04.json)
(SHA-256 `da6d79af61be4ead791c6eb030c662a49d9a0dab7e4891dc95c96f88af1b52bf`).
It changes the exact tag helper's generic KTerm branch to compare `name` instead
of `tag`. A generic node with tagLam/nameLit and keyLam changes True to False,
while specialized literal/lambda branches stay untouched. The reviewer read
only the helper and maintained tg contract before this choice, not the new tag
law or oracle; earlier unrelated Phase98 outcomes were already known. This late
challenge is not added to the original eight-bad/two-good score.

## Candidate measurement review

The hardened Phase98 comparator authenticates D04, recursively verifies recipe
pins, replays exact edits and requires final candidate bytes to agree. The first
review found that generalized source selection lacked exact patch replay; root
fixed this before execution. Unsupported literal insertion recipes explicitly
refuse rather than silently bypass authentication. Candidate and baseline use
the same runtime/Base/providers/cache and authenticated ClangO2 build settings.

For `dispatch-screen01/report.json`, the reviewer independently checked48 passed
C/diagnostic comparisons, six sources, four paired rounds, two occurrences of
each role order per source, and recomputed the reported medians. Request ratio
is **1.007493×**, process ratio **1.004350×**: neutral to slightly slower, with
variation in the larger cases. This does not support a speedup or promotion.
Selector equations and finite selectors also do not prove equivalence of every
unsafe recursive branch body; the original compiler comparisons remain required.

The independent observer-permission review and scoped native qualification are
documented separately in [observer-permission.md](observer-permission.md). That
candidate intentionally can change emitted C; old-byte continuity must not be
misused as its only correctness criterion.


Two additional safe-permission challenges are separately frozen in
`selfhost/tools/laws/phase98/challenge/permission-candidate01.json`: ignoring the
trusted flag wrongly accepts an untrusted IO.print_err declaration, and omitting
File.close rejects the ninth legitimate provider. Selection used only the exact
safe helper and its intended contract, after hearing its positive proof passed
but before reading permission law/reference bodies. These are late negative
controls, not additions to the original challenge score. Their scope excludes
host byte authentication and the operational borrowed-memory boundary.


Both late permission faults now pass standalone safe-helper admission and fail
the unchanged `foreign_permission_exact` obligation, in
`selfhost/build/phase98/permission-negative-check01/report.json` (complete four
jobs; child reports independently rehashed). The failures concern the actual
safe value predicate. They provide no automatic authority for FFI paths or
borrowed-memory operations, and do not alter the original catalog outcomes.
