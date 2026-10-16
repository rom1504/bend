# Phase99 native release preparation

The release adapter is outside the active, pinned `qualification/` directory.
It reuses frozen Phase98 snapshot17 admission, final controls and runtime
continuity with the same explicitly frozen current Phase98 B1/B2 baseline as the
Phase99 comparison methods. No installed selection changes during preparation.
Every command accepts candidate-bound receipt paths; no source03 identity is
built into these methods.

For the source03 experiment, prepare a prospective command list with:

```sh
python3 -B selfhost/tools/performance/phase99/release/prepare.py plan \
  --qualification selfhost/build/phase99/borrowed-qualification-plan01 \
  --source selfhost/build/phase99/borrowed-calls-source03/compiler.bend \
  --recipe selfhost/build/phase99/borrowed-calls-source03/changes.json \
  --backend-controls selfhost/build/phase99/borrowed-backend-specific01/report.json \
  --out selfhost/build/phase99/borrowed-release-plan01 \
  --public-assets selfhost/tools/native/releases/phase99-borrowed-staged01
```

This writes an exact source delta/profile and eight individually named command
arrays. It runs no compiler, proof, program or benchmark. Run each command only
after its prerequisites pass. This source03 example has been prepared, and its
first `source-replay` command already passed data-only at
`borrowed-release-plan01/profile-replay.json`; skip that command for this
existing plan. No later command has been run by this preparation.
If a follow-up source wins, use its exact source,
recipe, qualification directory and backend receipt with fresh output paths.
The recipe must replay directly from the frozen Phase98 source `2a72…051`;
compose sequential deltas before preparing qualification if a follow-up recipe
starts at source03. The unmodified public `profile.py` verifies the delta against
the existing Phase98 public asset capsule and writes the source recipe consumed
by admission. Its default profile remains Phase98; use the explicit generated
`--profile` argument.

## Additional evidence before admission

The existing 19-step qualification plan supplies exact B1/B2 builds, six-source
screens, same-source self requests and balanced stage timings, ordinary controls,
45 generated programs, 69 native golden cases per stage, six rejections and 31
explicit exclusions. A promotion also needs:

1. A new **source-bound backend-specific receipt**. Validate the selected source's
   small API controls, finite predicate expectations, independent kernel laws and
   admitted bad changes, actual small native outputs and inspected self-C. A
   successor that changes static-root acceptance needs corresponding evidence;
   source03 results cannot silently qualify its changed permission predicate.
2. New borrowed-call programs emitted by **both final native images**, with exact
   B1/B2 C agreement, independent baseline diagnostics, matched unpatched Clang,
   and complete expected stdout/stderr. Include reordered/aliased roots,
   refusal cases, root swapping and recursion boundaries from the admitted small
   plan. The upstream-hosted API executions alone do not attest these images.
3. An explicit declaration/dependency bridge for retained Phase98 boundaries.
   Historical receipts provide original fixtures and expectations; they are not
   relabeled as fresh candidate executions or a whole-compiler proof.
4. The unchanged **five final-image controls**: real I/O, generic array, schema
   refusals, all 1,444 string corpus pairs and the origin-swap owning fallback.
   Frozen `final-controls.py` performs 5 independent baseline emissions,
   10 final-image emissions, 5 matched builds and 5 exact full-output runs.

The new backend receipt must satisfy the existing
`phase98-backend-specific-qualification` schema: complete/passed/unchanged,
exact `source` and `backendPolicy`, a pinned plan whose case IDs exactly cover
passed nonempty-evidence rows, and authenticated inputs. Its
`qualifiedSourceControls`, `qualifiedSourceCorpus`, `originControls` and
`finalImageControlPlans` retain the original frozen five-control oracle
references from `phase98/origin-backend-specific01/report.json`. Candidate
borrowed-call executions are additional evidence rows; do not change the frozen
five-case schema or treat copied historical fields as new results.

These backend-specific collector/final borrowed-call execution receipts are a
remaining dependency; the release preparation does not synthesize them. Frozen
admission consumes their passed source-bound evidence, all ordinary gates and
the final five. It independently checks raw commands, guards, diagnostics,
whole C, executions and conformance provenance. A timing benefit decision stays
separate from its semantic qualification result.

## Runtime and public host

The generated `runtime-continuity` command re-emits the original 45 Phase93
batch sources with selected B2. Exact full C permits artifact continuity only,
not a new runtime timing claim. A changed subset requires matched B1 emission,
unpatched compilation and the original runtime calibration/rounds before making
a fresh performance comparison. Preserve the zero-work undefined case.

After offline admission, `staged-selection` creates a fresh private pointer and
authenticates both stages. `public-cli` uses the actual public entry and all nine
existing checks. Its checked successor changes only the output root, the parent
module location and an added parent-method pin. Expected complete diagnostics,
cache/live behavior, repeated calls and refusals stay unchanged.

`public-assets` seals the **staged pointer** with unchanged `assets.py`;
`verify-public-assets` verifies every archive member and existing asset. This
does not publish the installed default. Root may promote only after measured
benefit, all exact-source gates, public CLI and capsule verification pass:
preserve the current `selfhost/tools/native/selection.json`, atomically replace
it with the verified staged pointer bytes, and seal/verify a fresh public
capsule using the installed pointer if the published capsule must restore that
default path. Do not overwrite an old capsule or claim the staged capsule
contains the installed pointer. No launcher/profile default change is needed
to run the admitted candidate.

After report and method writers freeze, create the compact evidence index and
Phase99 evidence capsule using the existing [evidence handoff](evidence-plan.md).
Pass the actual new public capsule receipt through `--public-assets`. Preserve
failed scalar probes and superseded source attempts alongside their decisions.
