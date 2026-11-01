# Maintained finite qualification

Run from the repository root. `tools/build/qualification.py` selects the
[focused19 and broad45 catalog](qualification-catalog.json) and uses only
maintained build/request adapters and copied fixtures. The original source and
oracle hashes remain in [the lineage record](consolidation-lineage.json).
Historical paths there are provenance, not executable dependencies.

The reference revision is `059266225b77c8ca256ac6b25ee5c21449bab151`.
The catalog has 61 whole-output positives and three stage-specific refusals.
Expected output is independent of the candidate: retained hand-written or
previously authenticated reference oracles are identified per case. These are
regression controls, not fresh held-out observations or a full-language proof.

## Explicit host, target and image

The image binding must declare its actual host, stage, targets and protocol.
`--image-key` selects an authenticated asset; an external `--image` also requires
`--image-receipt`. JS-hosted requests require a checked API binding. The asset
manifest's upstream revision must equal the catalog revision. No compiler is
selected from PATH, installed defaults or a historical experiment script.

For the existing native QBE N2, a bounded first gate is:

```sh
python3 selfhost/tools/build-retention/guard.py \
  --out selfhost/build/qualification-qbe-focused01-guard \
  --run-root selfhost/build/qualification-qbe-focused01 \
  --seconds 900 --disk-mib 256 --cpu 3 -- \
  python3 selfhost/tools/build/qualification.py \
    --assets selfhost/manifests/assets-native.json \
    --image-key qbe-n2 --host native --stage N2 --target qbe --mode cache \
    --suite focused --seconds 30 --build-seconds 30 --execute-seconds 10 \
    --out selfhost/build/qualification-qbe-focused01
```

Use a new output directory for every attempt. The guard owns the whole campaign
deadline and disk/process budget; children have additional finite timeouts. Do
not nest guards. `--plan` authenticates inputs and prints the plan without
running a compiler or creating output. `--case NAME` repeats for a subset;
the report records the exact selected IDs. `--suite broad` runs the other 45;
`--suite all` runs 64. Allow a larger whole-run deadline and disk budget for broad
or C builds; a timeout remains a failed observation, never an implicit exclusion.

For a checked hosted API, use `--host js --stage B1 --image API --image-receipt
RECEIPT --target js --mode live`. The same bound API can use `--target c` if it
advertises C. An acquired native C compiler uses its derived build receipt,
`--host native --stage N1 --target c --mode cache`. Generation names must match
the actual binding. Choose `live` when that image has no prepared-Base protocol.
Native C requests also require `selfhost/manifests/assets-c-request.json`: its
authenticated Bend-produced runtime template supplies the five parts consumed
by that entry. The host transports those exact bytes and parses the declared
telemetry/verdict protocol; it does not split a raw runtime or discard stderr.

JS programs execute with the manifest's pinned Bun by default. C programs use
the manifest's explicit C compiler, flags, include paths and libraries. QBE uses
the bounded maintained relay, aligned assembler and exact runtime object.
Native executions use one Bend mutator and GPU off. This does not qualify
parallel, GPU, arbitrary foreign-provider or callback behavior.

## Result meaning

Each case retains the emission, machine-build and execution receipts, full
stdout/stderr, child exit and source/tool/image identities. Exact means every
byte, including the final newline; no trimming or merged unrelated diagnostics.
`complete` means all requested rows were recorded; `passed` also requires every
row to pass and all protected inputs to remain unchanged. Unsupported cases
remain visible and prevent `passed:true`. `fullConformance` is always false.

QBE refusal controls require a closed exit1, no emitted bytes and the compiler's
specific `check:` or `compile:` protocol diagnostic. JS/C hosted type/affine
controls require a structured checked rejection in the check phase. The C-native
and JS/C foreign-refusal protocols do not currently have corresponding catalog
oracles, so those combinations are explicitly unsupported. They cannot be
reported as successful frontend or backend validation. Source checking is
distinct from independent BendTT kernel verification; no kernel claim is made.

## Public CLI and upstream frontend lanes

`public-cli.py` applies seven fixed controls to `selfhost/cli.mjs`, using an
explicit checked hosted image and Base. It sets `BEND_TYPED_BASE_CACHE=off` to
exercise live source checking without
creating shared preparation files. Cache filenames and bytes must be unchanged.
The controls cover interpretation, check-only, JS emission/execution,
C emission, conflicting options, protected source output,
and the explicit unsupported kernel option. Its C-output check is structural;
the runner above supplies C execution controls. It does not replace or qualify
the installed native public selector.

```sh
python3 selfhost/tools/conformance/public-cli.py \
  --assets selfhost/manifests/assets-native.json \
  --image API --image-receipt RECEIPT --host js --stage B1 \
  --target js --mode live --seconds 30 \
  --out selfhost/build/public-cli01
```

Wrap this target command in the same outer guard pattern (fresh output, 300 seconds, 
128 MiB). Candidate acquisition receipts must establish the checked image;
writing a metadata binding does not itself check source.

For the original paired upstream frontend/golden suite, use `target.mjs` with
its checked-bootstrap provenance and exact selection format, or the full
`run.mjs` lane harness with an explicitly checked adapter. These retain upstream
`#|` oracles and exact reference checkout validation. A finite qualification
report is not a replacement bootstrap receipt. See [the harness](README.md).

Offline support checks, with no compiler or generated program execution:

```sh
python3 selfhost/tools/conformance/test_qualification.py
selfhost/.assets/bin/bun selfhost/tools/conformance/selected-graph.test.mjs
selfhost/.assets/bin/bun test selfhost/tests/conformance/judge.test.mjs \
  selfhost/tests/conformance/selection.test.mjs \
  selfhost/tests/conformance/native-adapter.test.mjs
```
