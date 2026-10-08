# Phase64 final qualification factory

This data-only factory derives the 17 Phase63 final qualification methods and
selects the completed provenance correction before any Phase64 semantic run.
Optional `canonicalPath` and `bytes` must validate; identities then normalize to
exact `{file, sha256}` pairs. The four semantic controllers retain their original
bytes and all value oracles. The failure-dependent Phase63 resume tool is not used.

Changes are limited to the Phase64 output boundary, final-plan factory/producer
bindings, that provenance correction, and recognizing frame4 cache filenames in
`bootstrap/setup.mjs` and `qualification/checked-image.mjs`. Both cache readers use
the selected driver decoder and retain semantic version checks `[4,6]`; no binary
format is reimplemented here. Every generated file records its parent, exact
replacements and output hash. Optional snapshot graph-helper copying, actual
admitted roots and JDPlan B2/B3 reproduction remain unchanged. `frame4-update.json`
records the exact update from the prior uninvoked Phase64 factory.
`derivation.json` and `factory.patch` record this factory's source provenance.

After root reviews the factory, materialize a fresh method package on CPU0:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase64/latency/qualification/make-method.py --out selfhost/build/phase64/qualification-method01
```

After root selects and freezes a checked candidate, generate final plans with its
actual admission and genuine B2 pins:

```sh
taskset -c 0 python3 -B selfhost/build/phase64/qualification-method01/qualification/final-plan.py plan --methods selfhost/build/phase64/qualification-method01 --attempt selfhost/build/phase64/checked-SELECTED --admission selfhost/build/phase64/export-SELECTED/admission.json --bootstrap-pins selfhost/build/phase64/bootstrap-SELECTED/image-pins.json --out selfhost/build/phase64/final-SELECTED --plans selfhost/build/phase64/final-SELECTED-plans
```

Omit `--bootstrap-pins` only if the selected B2 has not yet been generated. Exact
stage launch commands are recorded in the resulting `index.json`. Root runs the
checked, bootstrap/reuse and B2 stages serially after their barriers; maintained8
requires the live source to agree with the selected snapshot. Existing resource
guards and native toolchain settings are preserved. Counts and trust claims remain
separate: source96/numeric34/composition18/overapplication2, native3, program45,
fresh B2 type acceptance, expected unsafe trust refusal and exact B2/B3 bytes.

The inherited final-plan file also contains release preparation for compatibility
with the parent closure. Neither this factory nor the preparation above executes
it. The release owner must review and separately admit that stage; no release work
is authorized by method preparation.

At creation, Python syntax was checked, but the factory was not invoked. No method
package, candidate plan, source freeze, Node process or compiler target was created.
