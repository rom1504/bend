# Focused packing controls

Source/data preparation only. `prepare-raw-v2.py` binds the exact product10 API
(`c0f4eace…`) and a future strict checked packing candidate. It derives the
reviewed raw-control preparation with the same runtime/toolchain pins, CPU3
affinity, 1 GiB Node heap, 4 MiB stack, 2 GiB tree RSS and 4 GiB memory floor.
Root executes the resulting plan's command under its existing guard.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/constructor-packing/controls-v1/prepare-raw-v2.py --baseline selfhost/build/phase68/products-build10 --candidate SELECTED_PACKING_ATTEMPT --toolchain-recipe SELECTED_PACKING_RECIPE --out selfhost/build/phase68/packing-selected-raw01
```

Four original emitted programs compare full output against independent goldens
on both APIs at threads 1 and 4:

- Readback of zero, `2^40-1`, `2^40`, and `2^48-1` fields.
- Sharing and dropping a fitting packed value.
- Sharing/dereferencing an actual nested boxed pointer, and dropping another.
- Readback through an Array handle in a one-field constructor.

Eight paired compile-only probes check the permission macro: ordinary ADT/Ctr
metadata permits packing; non-Base Foreign, absent Def, annotated Foreign,
unusual raw Foreign kind, and nested child definitions disable it; Base-owned
foreign provenance retains permission. These checks do not execute foreign C
or claim a general foreign ABI.

One additional candidate-only diagnostic is an exact one-site derivative of
the first program's C readback. It verifies that zero/max40 actually arrive as
`TAG_PAK`, and the two wider fields arrive boxed, while retaining all four exact
payloads. The expected four diagnostic stderr lines and normal stdout are
checked at both thread counts. It is labeled separately from unchanged emitted
programs. Total: nine C builds, eighteen native observations, and eight paired
permission probes. Earlier original-error/checkpoint raw controls remain in
their separate reviewed lane.

For independent Base/IO error goldens, `prepare-boundary.py` changes only the
selection enum of the retained-C integration-v3 factory. Its two original
fixtures are `io/request_out_of_band.bend` and `run/nat_overflow.bend`. Prepare
and run one fresh plan for product10 and one for the selected packing attempt;
each uses the maintained TypeScript/selfhost paired workflow. Keep the two
observations' actual API roles explicit.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase68/constructor-packing/controls-v1/prepare-boundary.py --attempt SELECTED_ATTEMPT --toolchain-recipe SELECTED_PACKING_RECIPE --set packing-boundary --out FRESH_PHASE68_OUTPUT
```

All preparation outputs are fresh-only. Predecessor methods, failed compiler
attempts, exact derivation records and original fixture goldens remain intact.
No control target was run by the method owner.
