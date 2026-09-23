# Phase 5 document consistency review

Reviewed at2026-09-23 01:34UTC, while the independent self-host proof was running.
This was a light document/JSON read only: no compiler, tests, archival, recount,
Git operation or source mutation. Only this review was written. The main report
is root-owned and may subsequently supersede the specific stale sentences below.

Scope: `report.md`, `final-conformance.md/.json`,
`full-source-comparison.md` and its independent audit, `equality-frontend.md`,
`base-memo-frontend.md`, `code-size.md`, and the original Phase5 design. The
backend/static-review reports were read to resolve status wording.

## Actionable report updates

1. **The full-source comparison is complete.** In “Current outcomes,” the sentence
   saying TypeScript/B1/derived comparison and self-reproduction are “still running
   or pending” incorrectly groups a completed comparison with the active proof.
   Replace it with: “The final full-source comparison passes all six rows:
   checked B1 averages642.58s process wall, its equality derivative363.39s and
   TypeScript60.25s. The derivative reduces this B1 workload by43.45%; it remains
   6.03× slower than the selected TypeScript workflow. Independent checked
   self-reproduction is still running.” Link `full-source-comparison.md` and keep
   its unequal Base-cache work explicit. These are B1/derived measurements,
   **not measurements of the self-emitted H compiler's compilation speed**.

2. **Three status passages are stale.** “Compiler source is now frozen pending
   the final combined checks” precedes already completed integration05 results;
   “The final combined checked build is running” after the memo result is also
   obsolete. The “Remaining campaign work” paragraph still requests the final
   build/frontend gate, selected CPU/backend executions, full-source comparison
   and recount, all now recorded as completed. Rewrite that paragraph around
   the active fixed point, subsequent H-specific evidence if run, final report
   reconciliation and preservation. Keep any remaining static counterexample
   explicitly unexecuted until actual observations exist.

3. **Update the top checkpoint time after incorporating those results.** The
   current00:45UTC heading predates the01:25:56UTC comparison closure. Historical
   sections and the original preimplementation design should retain their dated
   scopes and baseline numbers; their old numbers are not current-result errors.

No numerical inconsistency was found in the final conformance summary. The
reviewed records agree on919/919 positive fixtures,377→318 strict check failures,
560→444 exact live differences,116 resolved/zero new exact differences and
50→16 status/phase differences. All2,756 reference observations are unchanged.
The three pinned TypeScript strict failures remain visible. Negative parse
observations are correctly separated from strict checker passes.

## Boundaries the final summary should preserve

- The428 same-classification text/report mismatches are not necessarily cosmetic:
  they can reflect another selected parser/checker error. The116 newly exact
  observations are not116 demonstrated soundness repairs. The Nat wrong-result
  witness and actual scope/acceptance fixes supply separate semantic evidence.
- Equality's23.90% complete-frontend gain uses attempt02; the host memo's17.09%
  uses attempt03. Neither is a final-source paired frontend speed result. Their
  percentages cannot be multiplied. P523 measures the final source but has a
  different workload, process lifetime and cache policy.
- Final checked-API frontend coverage and the42-observation-per-compiler selected
  backend gate are complete. Generated output identifier/root-classifier oracles
  passed in P523, but they are neither H backend coverage nor a fixed-point proof.
  A completed proof and any later H tests need their own artifact identities.
- Production grew454 physical lines to16,509, with59 modules. The unchanged
  filter relocation and removal of two dead Nat helpers are useful local
  simplifications, not a shrinking-compiler claim. Experimental tool counts are
  a00:37 point-in-time inventory; the old223-line support-boundary discrepancy
  remains explicitly documented rather than silently corrected.

## Evidence-led priorities after the campaign

First use the maintained fast loop on the eight fixtures responsible for the
remaining16 phase/status observations: five missing-import classifications,
two premature `+` value-reference rejections and the late dead-prefix-operator
rejection. They are smaller, more precisely defined targets than treating428
text differences as one rendering problem. Preserve first-error neighbors and
the existing positive/control inventory before broadening a rule.

Next separate remaining diagnostics by chosen-error/grammar mismatch versus
source provenance and presentation. Reuse the structured transport; do not
revive the rejected repeated application reconstruction, whose128-argument
falsifier showed substantial extra work. Keep the imported-law-fill and semicolon limitations explicit. The multiline-string
location case was unexecuted at this initial review; it has since been confirmed,
as recorded in the dated resolution below.

For performance, retain the explicit provenance-checked B1 derivative and bounded
private memo as measured development options. The final derivative still costs
6.03× the selected TypeScript process workflow; a later optimization needs a
fresh causal profile and same-source paired gate. H already has a different
equality intrinsic, so B1's43.45% result predicts no H improvement. For
simplification, consolidate only demonstrated duplicate boundaries while keeping
the maintained workflow thin; archived experimental tools are evidence, not all
part of the ordinary developer path. These priorities follow the design's
conformance-first intent without inventing an exact70/20/10 time allocation.


## Resolution review — 2026-09-23 01:52 UTC

The reread main report has SHA-256
`8efac6f074f262a602467770db3875b6cc26aa9745df1de24923b38d31f27bac`.
The three stale-status findings above are resolved in this version: P523 is
complete with the correct B1/derived scope, final integration/backend work is
reported as completed, and remaining work centers on the active proof and later
H-specific validation. The top checkpoint is advanced to01:33UTC. Historical
findings remain above rather than being rewritten as if they were never stale.

The workflow timing table matches the retained integration05 process phases:

| Recorded phase | Exact process wall | Displayed value |
| --- | ---: | ---: |
| Bootstrap child | 14,634.538099ms | 14.63s |
| Prepare Base child | 4,406.497007ms | 4.41s |
| Paired selected command | 42,127.496503ms | 42.13s |
| Full frontend child | 292,250.410487ms | 292.25s |

The live small build/validation report hashes match their entries in the completed
integration archive: build `1c065266d8bdacbd0f11f186231c50370f0bfe2ddbf317499744c9329c51e5fe`,
validation `597ce98607de319d463e56146d184d8ea5fb1fe4e2ab9dd8245ff0d2da24dd7b`.
A minor boundary clarification remains useful:14.63s is the bootstrap **child**
phase, not the entire maintained build command including snapshot/verification;
the build report's start/finish interval is15.373s. The displayed values are
correct and appropriately labeled observational, not controlled speed evidence.
The42.13s selected value covers the complete pair, not42.13s per compiler.

I independently read the actual completed P523 raw result files and recomputed
all seven entries in `full-source-phase-observations.json`: both sample arrays,
means and reductions agree. The five displayed means round correctly to
15.77→9.64s parsing,165.41→101.36s checking,161.27→104.24s annotation,
84.70→39.16s layout checking and155.64→70.36s library emission. The report
correctly warns that these timers are not additive and that TypeScript uses
different phase boundaries. No compiler, oracle, profiler or audit tool was
executed; this follow-up used only file reads and small arithmetic.

The earlier “unexecuted multiline-string” assumption is superseded by
[the confirmed counterexample](static-counterexample.md). Earlier integration01
already assigns the wrong line; final integration05 additionally renders the
wrong excerpt when its first-character guard matches. Acceptance/phase/checked
status remain unchanged and the valid neighbor agrees. The frozen source still
contains this defect; it is not described as a fix or exact conformance pass.

The proof owner reports completed genuine B1→H stage2 in661.410s, output SHA
`5043267732f5178b12d14708e7dc07e3aa1a71b9d1d5949ef279af23c4297edd`,
with stage3 running. That advances the pending-proof status but is not a
completed fixed point or a public-H compilation-speed measurement. This review
does not rerun proof verification; its final completion and H-specific gates
remain separate evidence to link when available.
