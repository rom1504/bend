# Phase173: bounded native qualification after automatic decomposition

This is a proposed execution protocol, not a completed qualification. The
[literal command and identity plan](native-qualification-plan.json) binds the
maintained methods, catalogue, reference report and six selected runtime oracles.
No target was executed while preparing it, and no operational asset was changed.

## Smallest useful native correctness gate

Run the maintained `qualification.py --suite all` once on the actual candidate
N2 using `--image` and `--image-receipt`. It accepts the derived `native.py`
receipt directly; there is no need to replace the installed `qbe-n2` asset.
Wait for that receipt to be complete, with host `native`, stage `N2`, target
`qbe` and protocol `qbe-source-v1`. The build tool validates those dimensions and
the executable digest instead of inferring them from the directory name.

This is 61 exact whole-output positives and three stage-specific refusals.
The latter require exit 1, no emitted bytes, and the expected source-check or
fixed-provider diagnostic; a timeout/crash is not a valid refusal. The run
records source, image, Base, runtime/toolchain and oracle identities, and checks
protected inputs for changes.

The historical cost is measured, not a guess: Phase170 final native64 took
**68.283 seconds** under the outer guard, with approximately 62.8 MB peak RSS;
its first pass took 69.671 seconds. Therefore a single full64 run is preferable
to focused19 followed by all64, which would duplicate work. The suggested
240-second campaign limit is a timeout ceiling, not a predicted runtime.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase173/owned-native64-08-guard \
  --run-root selfhost/build/phase173/owned-native64-08 \
  --seconds 240 --disk-mib 512 --rss-mib 4096 \
  --available-mib 16384 --cpu 3 -- \
  python3 -B selfhost/tools/build/qualification.py \
    --assets selfhost/manifests/assets-native.json \
    --image selfhost/build/phase173/owned-native-n2-08/program \
    --image-receipt selfhost/build/phase173/owned-native-n2-08/report.json \
    --host native --stage N2 --target qbe --mode cache \
    --suite all --seconds 30 --build-seconds 30 --execute-seconds 10 \
    --out selfhost/build/phase173/owned-native64-08
```

Use fresh paths if any proposed output already exists. Preserve the one resource
supervisor/execution lane. The catalogue's pinned upstream revision is
`059266225b77c8ca256ac6b25ee5c21449bab151`, equal to the unchanged native asset
manifest. Do not alter either to admit a mismatched image or oracle.

## Runtime quality without an unnecessary timing campaign

Native64's ordinary broad45 sources are not the separately repeated **native45
timed wrappers**. Exact ordinary output alone does not establish runtime quality.
The Phase170 `timed-products-final/report.json` still retains independent source
and complete-QBE pins for all45 timed wrappers; all45 expected files were present
when this plan was written. Its full reemission took **63.159 seconds**.

Start with six explicit timed-source screens, already pinned in the JSON plan:

- editdist;
- tree-bitonic;
- test-morning-program;
- test-rle-roundtrip;
- coverage-record-aggregation-256;
- coverage-map-churn-128.

These cover numeric/branch computation, previous tree/morning sensitivities,
temporary lists, products and maps. They are a chosen regression screen, not
a representative six-point estimate of the whole benchmark geometric mean.

Each command uses maintained `request.py` with the same actual N2 binding,
`--mode cache`, original timed source and `--expected-qbe` pointing to the
independent qualified full product. Emissions stay in fresh directories under
one bounded campaign. Compare full bytes, not selected functions or checksums
of output values. Compare the target runtime object, QBE, assembler, linker and
flags with the reference report too.

If full QBE and machine policy are unchanged, generated code is preserved and
there is no reason to acquire/re-time that product just to reconfirm identity.
This is preservation of earlier code, not a new runtime observation.

A changed QBE product is **not automatically a regression**. The expected-byte
request will preserve that mismatch as a failed identity observation. Build
that exact changed product, run its independent whole-output/count oracle, and
compare fresh same-host timings against the retained baseline product through
the maintained benchmark runner. Use equal work and balanced serial role order;
increase the fixed work uniformly if intervals fail its 100ms resolution gate.
Inspect the changed admitted computation before launching a broad campaign.

If complete cold-build results justify continuing, extend exact reemission to
all45 timed wrappers. The already retained Phase170 reemission wrapper delegates
only to maintained request handling and checks frozen source/Base/runtime/tool
identities; it can be reused with the new explicit image binding. It stops at
the first changed product, so do not interpret a partial identity run as a
full45 result. Alternatively acquire selected changed cases with maintained
`bench/acquire.py`, whose role supports `image` and `imageReceipt`; no asset-map
edit is necessary.

## What each receipt establishes

| Observation | Establishes | Does not establish |
| --- | --- | --- |
| Independent checked source acquisition | Candidate source accepted by its declared checker | Mathematical validity of every unsafe declaration |
| Actual N1/N2/N3 comparison | Successive generated compilers agree on the complete compared self-build artifact | Independent compiler correctness |
| Native64 pass | All selected outputs/refusals agree with retained independent oracles | Full language, parallel/GPU or custom-FFI conformance |
| Exact timed QBE and unchanged machine policy | The corresponding generated code is preserved | A fresh runtime sample or full45 result from six cases |
| Balanced changed-product timing | Runtime comparison for the measured fixed workloads | Broad parity from a few winning cases |
| Complete self-build measurement | End-to-end cold build cost under the declared preparation policy | Source-to-executable parity with a different source or backend |

Candidate N1's compiler IR may differ from N2 because the old producer did not
have the new transformation. Compare a further actual generation against N2;
do not label the initial mismatch a failed semantic oracle or silently compare
the wrong generations. For this experimental checkpoint, no installer,
release selector or asset manifest should be changed. Unmodified JS/C entry
source is distinct from freshly qualifying their products; report that scope
honestly without repeating unrelated full campaigns.
