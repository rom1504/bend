# Borrowed-selector reproduction and intermediate source history

This experiment is **closed without integration or full compiler acquisition**.
Source15 passes complete values, the real verifier and47 finite controls. Four
balanced pairs are0.999576× for lookup and0.987457× for the real verifier. The
verifier promotes99.535% of observed calls: coverage is established, but the
benefit is too small to justify a full image. See [report](../borrowed-selectors.md)
and [coverage](../guard-coverage-verifier15.md). This is generated native program
performance, not a new native compiler self-build time or upstream parity claim.

Keep the seven root `selfhost/tests/phase171/borrowed-selectors*.bend` files
(Source11) and `descendant-v15/` at HEAD. Do **not** stage the full local v12/v13/v14
directories. The three JSON text deltas here include their exact derivations and
new controls. They occupy38,399 bytes versus148,702 bytes for those full copies.
The manifest authenticates every baseline, delta and final file. The materializer
checks every edit's original bytes, complete before/after hashes and directory
inventory before writing a fresh output. It never runs Bend or native code.

```sh
# Verify all three intermediate revisions in memory; no output directories.
python3 -B experiments/phase171/tools/materialize-descendant-history.py --revision 14

# In this original workspace, additionally compare the retained exact copies.
python3 -B experiments/phase171/tools/materialize-descendant-history.py \
  --revision 14 --check-existing

# From a fresh checkout, restore an omitted historical directory at its old path.
# Repeat with12 or13 if reproducing a receipt that pins those inputs as well.
python3 -B experiments/phase171/tools/materialize-descendant-history.py \
  --revision 14 --out selfhost/tests/phase171/descendant-v14
```

[Verification](verification.json) records exact in-memory reconstruction and
comparison of all30 intermediate files; existing files/receipts were untouched.
The materializer refuses an existing output directory. Frozen early acquisition
failures and source01–10 remain in the campaign evidence, not rewritten here.

## Reproduce Source15

Run from the repository root with the exact Phase170 maintained source and
qualified assets described in [checkpoint reproduction](../../../implementation/phase171/reproduce.md).
Restore the retained Phase166 lookup and Phase167 verifier sources before their
requests. The fixture producers pin their exact hashes. Never substitute a newer
compiler/source/runtime into old timing claims. Every example output is fresh;
choose another prefix if any exists. Run target commands serially on CPU3.

The following Bash preparation is metadata-only. Its expected source hash is
`c8757db2040349c18628192a56aa05f039d68394ea2ab72eec31c800c13b6d9f`.

```bash
p171_run=selfhost/build/phase171/replay-descendant01
p171_src=selfhost/tests/phase171/descendant-v15
p171_args=(--prelude "$p171_src/borrowed-selectors-laws.bend")
for p171_module in borrowed-selectors-types borrowed-selectors \
  borrowed-selectors-entry borrowed-selectors-controls borrowed-selectors-emission \
  borrowed-selectors-diagnostic scalar-if-controls buffer-controls sink-controls \
  promotion-controls; do
  p171_args+=(--module "$p171_src/$p171_module.bend")
done
for p171_export in p171d_request p171d_summary p171d_controls p171d_plan \
  p171d_debug_shape p171d_constant_controls p171d_scalar_if_controls \
  p171d_buffer_controls p171d_sink_controls p171d_promotion_controls \
  p171d_all_controls; do
  p171_args+=(--export "$p171_export")
done
python3 -B selfhost/tests/phase171/prepare-api.py "${p171_args[@]}" \
  --out "$p171_run/source"
sha256sum "$p171_run/source/compiler.bend"
```

This helper applies one outer guard per target job; the inner methods do not
acquire another resource lock. The limits below cover these small requests,
not a full compiler image. No full image is justified by this experiment.

```bash
p171_guard() {
  local p171_job=$1 p171_seconds=$2 p171_disk=$3
  shift 3
  python3 -B selfhost/tools/build-retention/guard.py \
    --out "$p171_job-guard" --run-root "$p171_job" --cpu 3 \
    --seconds "$p171_seconds" --disk-mib "$p171_disk" --file-mib 128 \
    --rss-mib 2048 --available-mib 16384 --reserve-mib 5120 -- "$@"
}
p171_guard "$p171_run/api" 60 128 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source "$p171_run/source/compiler.bend" --exports "$p171_run/source/exports.json" \
  --out "$p171_run/api" --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun
p171_guard "$p171_run/controls" 40 48 \
  selfhost/.assets/bin/bun selfhost/tests/phase171/descendant-controls.mjs \
  --receipt "$p171_run/api/report.json" --export p171d_all_controls --count 47 \
  --out "$p171_run/controls"
```

Emit the same fixture through both API paths, build against identical pinned
runtime/toolchain, and require the complete independent stdout before timing:

```bash
for p171_mode in baseline descendant; do
  p171_guard "$p171_run/$p171_mode" 60 96 \
    selfhost/.assets/bin/bun selfhost/tests/phase171/descendant-request.mjs \
    --receipt "$p171_run/api/report.json" --assembly "$p171_run/source/manifest.json" \
    --source selfhost/build/phase166/lookup-source02/compiler.bend \
    --owner index_find --mode "$p171_mode" --out "$p171_run/$p171_mode"
  p171_guard "$p171_run/$p171_mode-machine" 40 48 \
    python3 -B selfhost/tools/build/native.py --assets selfhost/manifests/assets-native.json \
    --ir "$p171_run/$p171_mode/program.ssa" --seconds 30 \
    --expected-stdout selfhost/build/phase166/lookup-profile-plan01/expected.stdout \
    --out "$p171_run/$p171_mode-machine"
done
p171_guard "$p171_run/pair" 30 32 \
  python3 -B experiments/phase171/tools/native-pair.py \
  --baseline "$p171_run/baseline-machine/report.json" \
  --candidate "$p171_run/descendant-machine/report.json" --rounds 4 \
  --expected selfhost/build/phase166/lookup-profile-plan01/expected.stdout \
  --out "$p171_run/pair"
```

For the real verifier, use the retained
`selfhost/build/phase167/verifier-source03/compiler.bend` and exact `768\n`
oracle, keeping distinct output roots. Complete18-record and three diagnostic
fixtures come from `tools/prepare-descendant-values.py` and
`tools/prepare-descendant-verifier.py` (both metadata-only, each needs `--out`).
Emit their actual input with the treatment, their literal expected input with the
baseline, then use `native-pair.py --rounds 1` without `--expected` to compare full
outputs. Those tiny oracle runs do not support a timing claim.

## Observe coverage separately from clean clocks

```bash
python3 -B experiments/phase171/tools/prepare-descendant-guards-v2.py \
  --machine "$p171_run/descendant-machine" --out "$p171_run/guard-plan"
p171_guard "$p171_run/guard-plan/execution" 30 32 \
  python3 -B experiments/phase171/tools/run-descendant-guards.py \
  --plan "$p171_run/guard-plan/plan.json"
taskset -c 0 python3 -B experiments/phase171/tools/analyze-descendant-guards-v2.py \
  --report "$p171_run/guard-plan/execution/report.json" \
  --policy result-or-rfc --out "$p171_run/guard-analysis"
```

Source11–14 use `--policy legacy`; Source15 requires `result-or-rfc`. Always map
the diagnostic executable's own addresses. Under Source15 promotions are old
result passes plus failed-result RFC observations, not just old guard passes.
The shim never changes guard results, touches Bend heap ownership or supplies
compiler semantics. Diagnostic clocks are not benchmark measurements. Close
fresh runs through the maintained retention workflow; never overwrite old roots.
