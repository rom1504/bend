# Phase 5: conformance with a fast, simpler development loop

Status: design before implementation. Baseline commit: `7d69850`.
Authorized campaign: 2026-09-22 21:39:36 UTC through 2026-09-23 03:39:36 UTC.

## Objective and priorities

Improve compatibility of the compiler written in Bend while retaining the fast
validation loop established in Phase 4. Simplify code where that reduces the
cost of making and validating correctness changes. Generalize the proven B1
string-equality optimization without misrepresenting the resulting artifact as
an untouched checked bootstrap. The user authorized implementation, experiments,
documentation, commits and pushes for six hours.

Conformance is the primary outcome. An approximate allocation is 70% to fixes
and their validation, 20% to useful simplification and 10% to bounded performance
work. These are priorities rather than invented time-accounting precision.
Parallel agents may investigate independent tracks. Root owns integration,
strategy, evidence, commit/push and the final report.

Do not edit the pinned reference, human-written `bend2/bend.ts`, historical
experiment inputs, or the default distribution merely to make measurements look
better. No broad parser/kernel/emitter rewrite is planned. A complete fixed
point is an integration gate, not an edit-cycle requirement.

## Starting evidence

Read README, `selfhost/CONFORMANCE.md`, `selfhost/docs/ARCHITECTURE.md`, the
Phase 4 report and development guide, and the experiment workflow/ledger.

The latest frontend inventory has 1,378 fixtures and 2,756 parse/check probes.
All 919 positive fixtures pass both lanes. Negative check results are 82 pass
and 377 fail. There are 560 exact differences from pinned TypeScript across
375 fixtures: 510 diagnostic/report differences and 50 acceptance/phase
differences. Neither category proves that the underlying intended rule is
correct. Negative parse observations are not successful checker tests.
Two negatives accepted during checking are also accepted there by TypeScript;
later-stage rejection must be evaluated separately.

The current focused loop is a 20.735-second checked B1 rebuild, a first paired
21-case command of 16.483 seconds, and 9.328-second median reused validation.
The full four-worker frontend inventory takes about five minutes. Full-source
process measurements are approximately 51.4 seconds for TypeScript, 245.5 for
native Bend, 630.0 for ordinary B1, 340.0 for an exact-image B1 derivative,
787.3 for private H and 1,591.3 for public H. Cross-route ratios are descriptive;
the 630.0-to-340.0 change has its own controlled opposite-order comparison.

The compiler is 59 Bend modules, 16,055 physical / 13,400 nonblank lines and
1,482 definitions. Maintained support has 12,462 physical lines; performance
tools/prototypes have 12,209. These counts exclude generated artifacts and
result archives. They measure size, not cyclomatic complexity. The TypeScript
three-file total of 11,045 lines has different runtime/host boundaries.

## Track A: demonstrated frontend discrepancies

First reproduce retained constructor-binder and decorator-before-law witnesses
against live pinned TypeScript and the unmodified checked B1. Add nearby valid
programs and ordering counterexamples before repairing the implementation.

The local binder path validates patterns, while parallel binding currently
constructs scoped bindings through a separate route. Share the pattern
validation contract at the appropriate scoping boundary, retaining distinct
value/body scope, sequential declaration books and the first observable error.
Probe an earlier constructor used as a bare binder, later constructor names,
ordinary names, braced patterns, multiple/duplicate/reserved binders, and
malformed patterns followed by invalid values and bodies.

The declaration dispatcher must follow the pinned decorator grammar. Test
`@unsafe` before defs, laws, types, imports, foreign declarations, assertions,
another decorator and EOF. Repair only a demonstrated difference. Do not
change generic whitespace/semicolon handling to close one witness without a
separate grammar investigation.

Then choose the next cluster from a current exact mismatch inventory. Separate
incorrect acceptance, incorrect rejection, wrong phase/rule, and rendering.
Use near-neighbor witnesses to establish the intended rule, because an early
generic rejection can hide a missing later check. A falling diagnostic mismatch
count must not be reported as a corresponding number of soundness fixes.

## Track B: diagnostic fidelity and triage

Root will classify the current mismatch records and inspect the corresponding
source paths. Reuse existing structured errors and source-provenance machinery.
Prefer a shared rendering or attribution fix supported by several cases over
per-fixture messages or broad textual normalization in the oracle.

Keep the reference oracle unchanged. Compare exact status, phase, checked flag,
exit/signal, diagnostic and output. Any normalization used only to explain a
cluster must remain separate from the strict verdict. Preserve earlier raw
records and label changed counts by their new compiler identity. Test imports,
same-line and multiline spans, Unicode, EOF, declaration replacement and first
error order when changing attribution or syntax diagnostics.

## Track C: one maintained development entry

Compose the established checked bootstrap, focused paired selection and optional
full frontend gate through one documented entry. Reuse existing selection,
adapter freeze, worker/replay, identity and supervision code. A thin workflow
should reduce commands and setup drift; do not replace the tested worker
protocol with a second general framework.

Requirements: fresh attempt directories; explicit checked/derived/self-emitted
artifact kinds; real source/API/runtime/Base/host identities; per-API validated
Base caching; frozen consumed files; finite child deadlines; nonzero failure
propagation with retained reports. Reuse only after validating inputs. A resumed
attempt cannot claim a new bootstrap or silently change its proof record.
Focused frontend tests do not substitute for backend execution witnesses.

Test changed source, changed runtime/API, stale cache identity, missing or
malformed provenance, failed children and partially completed attempts. Keep
ordinary successful use concise. Link the maintained commands from README and
the compiler guide. Label old performance prototypes as historical evidence
without rewriting files consumed by historical experiments.

## Track D: portable B1 equality derivation

Use the explicit derived-artifact approach described in
`../phase4/next_compiler_lowering.md`. Retain the untouched checked API and its
genuine bootstrap record. A separate derivation report must identify input and
output hashes, pinned Base/emitter and recognized function body/ABI, transform
version and the controls run. Never copy a checked report to transformed bytes.

Recognition must reject unknown bodies and replacements; a name match alone is
insufficient. Preserve the tested primitive, well-formed-string path and the
original generated fallback. Validate Unicode scalar behavior, malformed UTF-16
suffixes, early mismatch/exhaustion, first-error order and argument staging.
Preserve H's existing string intrinsic; this is not a public emitter rewrite.

Demonstrate applicability to at least two genuinely new checked source builds.
Separate transformation safety from compiler behavior gates and speed evidence.
Run opposite-order core comparisons with exact output and peak RSS before
escalating to a full-source comparison. Reject or defer generalization if its
recognition/provenance burden requires a fragile global textual rewrite.
Initial investigation is bounded to roughly thirty minutes before review.

## Validation and resource plan

Each source change begins with a frozen checked B1 and selected live differential
tests. Include accepted neighbors and deliberate malformed cases. Run relevant
unit/ABI tests when the changed contract warrants them. Promote source only
after inspection and focused gates; integrated batches receive the complete
parse/check inventory compared to both pinned TypeScript and the baseline.

Broad gates retain known failures. Report new, resolved and changed mismatches
separately, together with fixture/probe coverage, timeouts and worker failures.
Use four persistent workers only when other compiler jobs are paused. Root will
coordinate a final checked fixed point after the source is frozen, and selected
JS/native compile-and-execute gates for backend-impacting changes. No available
GPU hardware means no new GPU validation claim.

Short concurrent correctness work may use separate physical cores with bounded
heaps. Timing claims require all other intentional compiler work paused,
frozen inputs, stated cache policy, serial alternating variants, retained raw
samples, explicit startup/request/build boundaries and actual output checks.
Avoid full-source sampling; every long child has an external deadline.

## Campaign checkpoints and preservation

1. Commit/push this design and initial steering before implementation.
2. Reproduce and fix first semantic witnesses; complete minimal development and
   equality prototypes; review each result before widening scope.
3. Integrate useful changes, run the broad frontend comparison, choose the next
   mismatch cluster based on evidence, and checkpoint validated increments.
4. Freeze production source early enough for final self-reproduction and
   targeted backend gates. In parallel review evidence and documentation.
5. Reserve the final thirty minutes for results, scope/caveats, link/identity
   checks, commit/push and a clean status. Stop new experiments at the boundary.

Use `experiments/phase5/P5-NNN-*.md`, the chronological ledger and bounded
steering. Initial owners: compact_index P5-001 frontend, direct_calls P5-002
workflow, lexer_analysis P5-003 equality, root P5-004 mismatch triage/rendering.
Each record states hypothesis, cheapest falsifier, gates, decision and evidence.
Retain failures and counterexamples; preserve small reproducible fixtures/tools
and compressed reports durably. Do not treat an ignored local filename or hash
alone as a durable artifact. Have another agent review meaningful changes and
reported conclusions. Final results go in `implementation/phase5/report.md`.

Success means demonstrated conformance progress with no new positive failures,
a simpler documented fast edit loop, and a safely reusable equality optimization
if its gates pass. Report actual achieved scope, not an assumed completion of
every proposed investigation, and make remaining discrepancies explicit.
