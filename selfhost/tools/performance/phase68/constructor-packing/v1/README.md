# P68-011 saved-C discriminator

Source/data preparation only:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/constructor-packing/v1/prepare-diagnostic-v2.py --out selfhost/build/phase68/packing-c-diagnostic01
```

This output already exists and is immutable. Plan SHA256 is
`040494be97849b2de736ec7f908d005982d44b4cb15d044d03e7bd0e98570cb6`.
The predecessor preparation failed at its imported CLI parser before creating
output; its exact one-edit successor and failure reason are preserved.

Root alone executes the frozen plan, after independent source review:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/constructor-packing/v1/run-plan.py --plan selfhost/build/phase68/packing-c-diagnostic01/plan.json
```

One existing guard owns all CPU3 children: 2 GiB tree RSS, 4 GiB available
floor, 90 seconds per Clang build, 45 seconds per runtime. Two builds, two
smokes, twelve measurements. Plan02 remains exact; short samples retain a
false timing-qualified flag. The runner verifies original snapshot manifest
continuity, artifacts, exact C derivation, toolchain, environment and all
oracles, then rehashes at completion. `execution.json` is fresh-only and keeps
partial/failure output. This is a C diagnostic, not a qualified compiler image.

The isolated compiler source proposal is the sibling `../v3/` patch; its source
version is unrelated to this diagnostic factory's parser correction. See
[design](../../../../../../design/phase68/guarded-constructor-packing.md).
