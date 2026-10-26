# Native edit comparison

`compare-native-v02.py` reads completed `phase140/session/run-batch-v02.py`
receipts. It does not execute, build or select a compiler. Run it only after both
native batches and their exact-output transports have completed:

```sh
python3 selfhost/tools/performance/phase142/compare-native-v02.py \
  --baseline selfhost/build/phase140/p142-parent-edit01/report.json \
  --candidate selfhost/build/phase140/p142-indexed-edit01/report.json \
  --out selfhost/build/phase142/indexed-native-comparison01.json
```

Both batches must use the same ordered jobs: source path and bytes, edit hint,
owner, cold/warm mode and expected output. The adapter rehashes pinned inputs,
native images, runtime, outputs and transport receipts. It checks the transport
chain and joins it to the successful native process rather than treating transport
completion alone as successful compilation. It refuses sampled runs, incomplete
runs, changed inputs, mismatched contexts and any output differing from the
pinned oracle. Its own receipt and both input receipt hashes are in the output.
The caller must also retain the independent oracle's provenance; an expected
output path alone does not prove how that oracle was produced.

For each job, candidate/baseline ratios retain distinct frontend, raw lowering,
backend, registry and rendering intervals. The summed native stage total,
source-read interval and host materialization interval form the **request plus
materialization subtotal**. This excludes shared process preparation/teardown
and host bookkeeping. Shared native overhead is the observed process wall time
minus all measured job intervals; `prepareMs` is separately reported as a subset
of that overhead. The remaining host residual is reported batch time minus
native process time and host materialization. None is silently charged to the
edited request, and the complete reported batch time remains available.

To include a newly measured machine build of the exact edited QBE, supply its
aligned-build receipt and the exact job name in a fresh output:

```sh
python3 selfhost/tools/performance/phase142/compare-native-v02.py \
  --baseline selfhost/build/phase140/p142-parent-edit01/report.json \
  --candidate selfhost/build/phase140/p142-indexed-edit01/report.json \
  --machine-report PATH_TO_NEW_ALIGNED_BUILD_REPORT \
  --machine-job EXACT_EDIT_JOB_NAME \
  --out selfhost/build/phase142/indexed-native-machine-comparison01.json
```

The adapter checks the machine build's QBE input and runtime against that job.
Because both compilers emitted identical bytes, the **same single measured build
cost** is added to each subtotal and explicitly labeled as such. This is not two
independent builds. Do not supply an old historical build and describe it as a
newly measured cost; the receipt identifies the observation actually used.
Without this option no machine cost is imputed. These subtotals also exclude
the acquisition cost of the compiler images themselves.

This is a descriptive comparison of single ordered native sessions. Preserve
the outer guard and image acquisition/build receipts to establish CPU affinity,
resource limits, compiler-source provenance and concurrent activity. The adapter
does not manufacture a confidence interval, infer native qualification, or turn
a warm request into a standalone cold-compilation claim. Keep source/ABI gates
and any final correctness qualification separate from the speed comparison.

## Observer validation

The first adapter incorrectly expected the transport's `wire` field to contain
a file path; the actual schema stores only byte count and digest. Its failure
is retained in `selfhost/build/phase142/comparator-v01-failure01/report.json`.
Version 2 independently authenticates the complete frame artifact and compares
its count/digest to the transport wire identity. Product, producer and session
checks remain distinct.

`comparator-selfcontrol02.json` compares the existing
`phase140/p141-full-edit-candidate01` receipt to itself: both jobs pass all
identity checks and produce unit ratios. `comparator-controls02.json` records
four small synthetic metadata controls: a valid wire schema, rejection of a
different pinned native image, rejection of a different pinned product, and
rejection of a changed wire digest. Reproduce the controls with:

```sh
python3 selfhost/tools/performance/phase142/test-compare-native-v02.py \
  --out selfhost/build/phase142/comparator-controls-FRESH.json
```

These checks execute only Python metadata validation, never a compiler image.
