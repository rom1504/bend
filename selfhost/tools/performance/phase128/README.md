# Phase128 experiment tools

The [report](../../../../implementation/phase128/README.md) records the selected
compiler, negative experiments, timings and qualification. Read the
[design](../../../../design/phase128/README.md) and
[guide](../../../../docs/self_hosted/borrowed-native-queries.md) before changing it.

Compiler transformations and finite predicates are Bend source in `borrow/`,
`reachability/` and `sharedprep/`. Host tools compose declarations, check artifact
identities and orchestrate existing compilers; they do not implement lowering.
`borrow/field-read/abi-oracle.c` is an independent ABI fixture, not a compiler.

## Reproduce the selected compiler

The selected complete source is archived at
`implementation/phase128/compiler-source02.bend.gz`; its decompressed SHA-256 is
`6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d`.
`implementation/phase128/candidate.json` binds source, checked API, runtime,
admission, N1/N2, emitted QBE and qualification. The exact archived source is the
starting point for reproduction; generated build paths are evidence locations.

Use [native/MEASURE.md](native/MEASURE.md) for guarded acquisition, qualification,
native request comparisons and the separate historical runtime wrappers. Its
early admission01 example describes the first checkpoint; the selected source02
uses `selfhost/build/phase128/native-admission03.json`. New relocated runs must
produce fresh path-bound receipts, not edit archived ones.

All executable experiments use the existing serial CPU3 guard lane. Start with
the compiler-name proxy, finite predicates and independent field ABI controls;
confirm actual worker admission and caller reachability before a full image.
Use clean paired runs for speed claims and diagnostic counters for attribution.
The selected snapshots and exact commands, including failures, are retained in
the [evidence capsule](../../../../implementation/phase128/evidence/final01/index.json).

## Inspect results without executing targets

- `native/summarize.py`: summarize independent native timing blocks; never pool
  separate blocks or conflate request time with machine-build time.
- `report-cost.py`: account for completed guarded jobs, including failed attempts.
- `seal-evidence.py`: archive receipts and selected sources, then verify every
  archived byte against its original content hash.

The ordinary45 qualification corpus and original45 runtime wrappers are
different inputs. Only the wrappers support the historical 44-point runtime
metric. The final candidate is qualified but does not change installed selection.
