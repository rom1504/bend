# Retaining accepted backend context

The production change is the checked Bend module `context-v01.bend`. It replaces
only `p128raw_session_finish` in the qualified Phase144 final04 source. Its
successful path retains the existing immutable boundary through open/inline/
ranges and freshly checks the actual final functions and namespaces. Failed
openings and lowering errors retain the old path. See the [design](../../../../design/phase146/README.md),
[source audit](../../../../research/phase146/accepted-context.md), and
[report](../../../../implementation/phase146/README.md).

## Reproduce the source and cheap gates

Use fresh output paths and restore the pinned parent dependencies first:

```sh
python3 -B selfhost/tools/performance/phase146/prepare-v01.py \
  --out selfhost/build/phase146/my-source \
  --api-out selfhost/build/phase111/p146-my-api \
  --module selfhost/tools/performance/phase146/context-v01.bend \
  --module selfhost/tools/performance/phase146/controls-v02.bend \
  --module selfhost/tools/performance/phase146/supplemental-controls-v03.bend \
  --export p146ct_controls --export p146ct_case \
  --export p146ct_optimization --export p146cf_controls \
  --control p146ct_controls:24:prefix --control p146cf_controls:8:prefix \
  --control p134v_controls:26:prefix --control p114s_control_report:18:prefix
```

This composes source and writes `manifest.json` and `jobs.json`; it executes no
compiler. Run the two recorded jobs in order. Each already has its own guard;
do not add a nested guard. The frozen successful run is `source03`; source01
preserves failed fixture annotations, and source02 predates the actual-factory
error supplement. There is no new BendTT theorem.

`compare-v01.py` compares checked hosted APIs on the four Phase145 requests.
`counts-v01.py` creates reversible six-entry counter derivatives and checks all
complete QBE products; these timings are diagnostic. `native-compare-v01.py`
uses fresh processes and alternating order, four pairs per request. It consumes
the frozen `phase145/execution-plan02/plan.json`, not a new benchmark definition.

## Native acquisition and qualification

The existing `phase134/pipe/build-v02.py` builds N1 from qualified final04, then
N2 from N1 on the same source03. N1 retains the full QBE reference; N2 checks its
complete streamed size/digest. These different retention settings mean the two
acquisition wall clocks alone are not a controlled speed comparison.

`stream-compare-v01.py` compares parent and actual N2 requests with identical
bounded output handling. It literally compares every byte against retained Q1,
including EOF, without storing another 117 MB file. The N2 request is the
observed Q3 gate. This tool only transports and compares bytes; compilation
remains in Bend. Wrap it in the standard CPU3/3GiB/16GiB-floor guard, allowing
the combined pair enough time. Actual commands are in `full-stream01-guard`.

Reuse `phase125/native/coverage.py` for focused19 on each image and `full45.py`
for N2 ordinary45. Pass the Phase146 reference maps to compare complete QBE
with qualified final04 as well as the frozen independent output/refusal oracles.
Do not claim that a one-shot correctness execution is a runtime benchmark.

`seal-v01.py` authenticates the fixed completed receipts and writes the explicit
candidate/qualification files. `summarize-v01.py` records matched clocks and
nonoverlapping outer-guard cost. Neither runs targets or installs a compiler.
`archive-v01.py` packages source, methods, failures, audits and receipts; pass
the final qualification, streaming comparison and three suites with `--require`.
Large generated products/toolchains are pinned but not bundled: this is evidence,
not a hermetic SDK. Never overwrite an already consumed method or output directory.

## Storage

The fixed-path `storage-v01.py` and `storage-v02.py` verify archived diagnostic
members before reclaiming them; their receipts retain restoration details.
They do not delete qualified compilers or current oracles. The separate
`dedup-native-v01.py` journals literal-equal N1/N2 assembly/object hardlinks,
preserving both paths and their content identities. Keep those artifacts
immutable; its `split` operation restores independent storage if needed.

These are one-campaign storage tools, not compiler passes. The
[storage audit](../../../../research/phase146/validation-and-storage.md) states
their exact scope. All compiler, profiler and benchmark targets use one root-owned
execution lane; metadata-only audits can run concurrently.
