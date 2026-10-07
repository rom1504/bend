# Phase64 candidate B2 preparation

`prepare-bootstrap.py` is an exact two-edit successor of the frozen Phase63
producer: the writable raw boundary becomes Phase64 and the phase label changes.
`prepare-bootstrap.derivation.json` records both edits and parent/output hashes.
The checked export admission, actual core/reach decomposition, tiny split equality
against both plan and compatibility emitters, graph-helper copying and the eight
driver observations remain unchanged. Default Phase64 admission preserves the
94 State09 roots; any additions need explicit source-backed admission.

After root selects and freezes a genuinely checked attempt:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase64/latency/prepare-bootstrap.py plan selfhost/build/phase64/checked-state01 selfhost/build/phase64/bootstrap-state01 --admission selfhost/build/phase64/export-state01/admission.json
```

The resulting `plan.json` holds exact serial guarded commands. Root may run it
with the existing unpinned retention launcher after admitting this B2 gate:

```sh
python3 -B selfhost/tools/performance/phase55/run-retention-plan.py selfhost/build/phase64/bootstrap-state01/plan.json selfhost/build/phase64/bootstrap-state01-execution
```

The plan's final data-only step creates `image-pins.json`. To revalidate existing
successful emission and comparison receipts into fresh pins:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase64/latency/prepare-bootstrap.py pins selfhost/build/phase64/bootstrap-state01/plan.json selfhost/build/phase64/bootstrap-state01/full/report.json selfhost/build/phase64/bootstrap-state01/driver-comparison.json selfhost/build/phase64/bootstrap-state01-rebound-pins.json
```

No factory invocation, current candidate freeze or compiler target occurred when
preparing this successor. B2 source checking, B2/B3 reproduction, semantics,
program equality and release promotion remain separate gates.
