# Reproduce the Phase171 checkpoint

Run from the repository root at this checkpoint, with the Phase170 maintained
source/assets and retained prerequisite receipts available. `metrics.json` pins
the measured source, images, products and report files. Do not substitute an
upstream head or current source assembled from another revision. No command here
installs a compiler or updates selectors.

All compiler, machine and control executions belong under the maintained
`selfhost/tools/build-retention/guard.py`, with **fresh** guard/output roots,
CPU3 via `taskset -c 3`, no nested guards, 16GiB available-memory floor and the
default5GiB disk reserve. Actual complete invocations remain in the named
`*-guard/process.json` receipts. Preserve failures; do not reuse their roots.

| Job | RSS ceiling | Disk budget | Outer deadline |
| --- | ---: | ---: | ---: |
| Checked combined API |3GiB|64MiB|120s|
| Finite controls/small requests |2GiB|48–64MiB|60–120s|
| Native candidate acquisition, retained IR |2GiB|256MiB|330s|
| Fixed full-source native build, no retained IR |2GiB|160MiB|330s|
| Diagnostic runtime relink |2GiB|64MiB|120s|
| Full diagnostic profile |2GiB|160MiB|330s|

Use the original 128MiB file-size limit for these jobs. Source assembly and
receipt analysis are metadata-only operations and execute no compiler targets.

## Exact native source recipe

The following modules/replacements reproduce the full candidate assembly;
`prepare-native.py` requires the exact Phase170 parent and preserves every
canonical declaration, original native main and protected declaration.

```sh
python3 -B selfhost/tests/phase171/prepare-native.py \
  --prelude selfhost/tests/phase171/fail-fast-laws.bend \
  --prelude selfhost/tests/phase171/publication-laws.bend \
  --prelude selfhost/tests/phase171/scalar-catalogue-laws.bend \
  --module selfhost/tests/phase171/fail-fast.bend \
  --module selfhost/tests/phase171/lazy-admission.bend \
  --module selfhost/tests/phase171/publication-history.bend \
  --module selfhost/tests/phase171/scalar-catalogue.bend \
  --replace p113d_let --replace p113dl_let \
  --replace p113pl_bind_flat --replace p113pl_bind_boxed \
  --replace p113px_boxed --replace p113dm_more --replace p113pm_more \
  --replace p113dm_original_match --replace p113pm_original_match \
  --replace p114r_plan --replace p114g_plan --replace p114h_plan \
  --replace p112c_plan_index --replace p156cp_continue \
  --replace p156cp_start --replace p128br_retry_plans \
  --out selfhost/build/phase171/replay-native-source01
```

Check the new source against the retained `native-source01/report.json`:
3,161,409 bytes, SHA256 `74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
The report must retain inverse/signature/main/protected checks, 8,442 final
declarations and zero pruned declarations. Assembly success is not source checking.

## Checked API and 77 finite controls

The frozen combined API source is `combined-source05/compiler.bend`, with
`exports.json` and `manifest.json`. Its 1,572,266 bytes hash to `0e627cf8…`.
Reacquire it through the ordinary checked workflow in a fresh guarded root:

```sh
selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase171/combined-source05/compiler.bend \
  --exports selfhost/build/phase171/combined-source05/exports.json \
  --out selfhost/build/phase171/replay-combined-api01 \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun
```

If reconstructing that smaller API source, use `prepare-api.py` with the same
three preludes and 16 replacements above. Its module order is fail-fast,
fail-fast-controls, lazy-admission, lazy-admission-controls, publication-history,
publication-controls, scalar-catalogue, scalar-catalogue-controls. Extra exports
are `p171ff_cases`, `p171ff_scc_controls`, `p171l_case`, `p171s_controls` and
`p171sc_controls`; the assembler supplies the five standard request/cursor roots.
Require its manifest/source pins to match, then check it normally. The smaller
API closure is never the full-source benchmark input.

Run four guarded control commands with the fresh candidate API receipt:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase171/fail-fast-controls.mjs \
  --baseline selfhost/build/phase171/ff-baseline-api01/report.json \
  --candidate selfhost/build/phase171/replay-combined-api01/report.json \
  --out selfhost/build/phase171/replay-ff-controls01

selfhost/.assets/bin/bun selfhost/tests/phase171/lazy-admission-controls.mjs \
  --baseline selfhost/build/phase171/lazy-baseline-api02/report.json \
  --candidate selfhost/build/phase171/replay-combined-api01/report.json \
  --out selfhost/build/phase171/replay-lazy-controls01

selfhost/.assets/bin/bun selfhost/tests/phase171/value-controls.mjs \
  --receipt selfhost/build/phase171/replay-combined-api01/report.json \
  --export p171sc_controls --count 12 \
  --out selfhost/build/phase171/replay-catalogue-controls01

selfhost/.assets/bin/bun selfhost/tests/phase171/value-controls.mjs \
  --receipt selfhost/build/phase171/replay-combined-api01/report.json \
  --export p171s_controls --count 5 \
  --out selfhost/build/phase171/replay-publication-controls01
```

Expected counts are 28,32,12,5. Baseline/candidate copies of a control count as one
case, not two. All successful records, first-error expectations and complete
planner/schema observations must pass. These are not malformed runtime executions
or independent BendTT proofs.

The small exact-product request transport is `selfhost/tests/phase171/request.mjs`.
Use `--mode baseline` even for the combined overlay image: it invokes the normal
entry whose selected definitions were replaced. Pass the fresh API receipt,
the exact source assembly manifest, `--source` Map or real verifier, and
`--reference` the corresponding original request report. Actual commands are in
`combined-map01-guard/process.json` and `combined-verifier01-guard/process.json`.
Their registered runtime oracles are not executed by this transport.

## Native acquisition and fixed-source comparison

Acquire the actual N1 candidate with the installed qualified native N2. This
inner command needs the 256MiB guarded budget above:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json --image-key qbe-n2 \
  --host native --stage N2 --target qbe --mode cache \
  --source selfhost/build/phase171/replay-native-source01/compiler.bend \
  --out selfhost/build/phase171/replay-native-candidate01 \
  --seconds 300 --retain-ir --output-stage N1
```

Then compare both images on **the original Phase170 source**, preserving the
independent expected QBE. Use fresh roots and 160MiB guarded budgets:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json --image-key qbe-n2 \
  --host native --stage N2 --target qbe --mode cache \
  --source selfhost/build/phase170/source-final/compiler.bend \
  --out selfhost/build/phase171/replay-full-baseline01 --seconds 300 \
  --expected selfhost/build/phase170/native-chain-final/q3/program.ssa

python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase171/replay-native-candidate01/program \
  --image-receipt selfhost/build/phase171/replay-native-candidate01/report.json \
  --host native --stage N1 --target qbe --mode cache \
  --source selfhost/build/phase170/source-final/compiler.bend \
  --out selfhost/build/phase171/replay-full-candidate01 --seconds 300 \
  --expected selfhost/build/phase170/native-chain-final/q3/program.ssa
```

The checkpoint ran candidate first and baseline second. Alternate order for a
new repeated comparison, recording every observation. Compare complete QBE
digest, assembly and object; whole ELF may include differing non-code metadata,
so audit rather than infer any loaded-byte claim. No `--output-stage` on these
fixed-input requests promotes their output as the candidate's reproduced N2.

## Profiling and coverage-negative import inspection

The original and candidate diagnostic plans/commands are in
[`candidate-profile-plan.md`](../../experiments/phase171/candidate-profile-plan.md).
Use fresh root suffixes for replays; its preparer is pinned to the actual retained
candidate receipt/object. Preserve output, sample-loss, CPU-coverage and all stage
marker gates before interpreting clocks. Diagnostics are separate from clean
timings. Current candidate profiling is complete and valid, not pending.

The completed coverage-negative import inspection used:

```sh
selfhost/.assets/bin/bun selfhost/tests/phase171/inspect-imports.mjs \
  --receipt selfhost/build/phase171/import-api02/report.json \
  --assembly selfhost/build/phase171/import-source02/manifest.json \
  --source selfhost/build/phase167/verifier-source03/compiler.bend \
  --out selfhost/build/phase171/replay-import-inspect-verifier01
```

Expect 93 old workers, zero imports, zero added workers/callers. Do not interpret
this as a positive optimization gate. The borrowed-descendant prototype has no
completed checkpoint performance/qualification result and is not a reproduction
prerequisite. Retention/closure and later promotion remain separate root-owned
steps; these commands do not change installed assets.
