# Native images produced by our own C backend

The implemented experimental tools bind our C-backend images separately from
upstream-built native images. They do not feed an own-backend emission to
`native_support.authenticate` under a fabricated upstream acquisition report.
That helper remains appropriate for the checked upstream-built native B1 and
the separately authenticated origin of the runtime/cache assets.

Two honest producer lanes are possible:

| Producer | Receipt | What the next machine-code compiler represents |
| --- | --- | --- |
| Genuine JS-hosted B2 | `emit-self-v5` report | A compiler built across hosts by our C backend; not native-B1 self-emission |
| Qualified upstream-built native B1 | `phase90-native-b1-self-emission` receipt | Candidate native B2 once the emitted C is built and execution qualifies |

Both new lanes require the exact combined source `74b390d3…` and normalized
assembly receipt `209d3dfa…`. Version 5 is the new JS worker for this source;
the earlier version 3 worker retains its original source `4584…` contract.

Bind the exact successful emission report, source, complete C, producer image/API
and its real qualification receipts; then bind the actual guarded Clang command,
all build inputs and resulting executable. Keep source `4584…` separate from the
combined derivative `74b390d3…`. Neither is interchangeable with the other.
`compiled:false` and `independentlyCompared:false` in a native emission receipt
remain historical facts; a later build/comparison should add a new receipt.

The execution adapter differs from the upstream native runtime. Our retained C
runtime omits the program-name argument, while the frozen private CLI consumes
one. Insert a sentinel after `--`:

```text
NEW_IMAGE --threads 1 --gpu off -- phase90-native INPUT BASE RUNTIME EFFECTS OUTPUT_PREFIX 1
```

Reusing the upstream `native_args` unchanged would shift every path. The earlier
retained-runtime argv tests support this convention; the new compiler still needs
its own invocation and file-IO gates.

Use the same independent expected C digests as the existing eight-gate suite:
live Small, Map, Unicode and file IO first, then their cached counterparts. Keep
the nine exact provider identities and runtime/Base transport checks. The old
Phase88 cache origin remains authenticated independently. Grant its carrier to
the new **exact** image/source/C tuple only inside the experiment after all live
gates pass; leave public admission manifests and consumer tuples unchanged.

If native B1 emitted C for combined source `74b390d3…`, compare it with a separate
successful ordinary JS compiler emission of that same source and native runtime
before claiming cross-host exactness. If the candidate native B2 then emits the
same frozen source as C3, compare complete C2/C3 bytes and retain both reports.
An emitted file alone is neither native B2 qualification nor a fixed point.

Only after successful small exact-C/file-IO gates should a new native compiler
receive a bounded self-source attempt. Phase90's upstream-native gate runner uses
240 seconds after the substantial five-builder change; a repeated deadline is
failed evidence, not permission to silently raise the limit. Preserve process
and peak-memory records and the complete output-size cap.

The original [native-gates.py](../../selfhost/tools/performance/phase90/native-gates.py)
covers the upstream-built combined B1. The new
[own_native_support.py](../../selfhost/tools/performance/phase90/own_native_support.py)
verifies the actual producer, successful emission, real guarded Clang build and
resulting executable. It writes no public admission. Its build receipt records
`nativeB2Qualified:false` and `cacheAdmitted:false`; later execution gates are
separate evidence and do not rewrite those historical facts.

Root-run sequence after a successful emission and actual Clang build:

```sh
python3 -B selfhost/tools/performance/phase90/bind-own-native.py EMISSION_JSON CLANG_GUARD IMAGE
python3 -B selfhost/tools/performance/phase90/own-native-gates.py IMAGE FRESH_PREFLIGHT_DIR --check-only
python3 -B selfhost/tools/performance/phase90/own-native-gates.py IMAGE FRESH_GATE_DIR
```

The new [own-native-gates.py](../../selfhost/tools/performance/phase90/own-native-gates.py)
is a recorded derivative of the B1 gate runner. It retains all eight independent
C oracles, separates the ancestor's nine-effect proof from the new source,
verifies exact derivation reversal, and confirms all **43** `p86_*` entry
definitions remain byte-identical. It executes the bound own-backend image with
the sentinel above. The optional `--self-source` emits the next C only after
all eight gates pass, using the same 240-second/2-GiB/64-MiB limits. Its separate
`phase90-own-backend-native-self-emission` receipt records actual lineage and
`independentlyCompared:false`; it does not assert a fixed point.

For the independent JS emission of combined source, root can invoke:

```sh
node selfhost/tools/performance/phase90/bootstrap/emit-self-v5.mjs B2_IMAGE_PINS QUALIFICATION_PLAN FRESH_OUTPUT_DIR
```

The worker verifies the checked generator, actual B2 emission and driver
qualification, private API copy, exact combined-source forward/inverse proof,
all nine effects and retained-runtime policy. It checks consumed inputs before
and after the request. It uses the existing qualification plan rather than
rebinding an old installed image to new source.

Python source parsing, Node syntax checking, source/entry inspection and exact
method derivation replay passed offline. These checks do not execute compiler
targets or establish own-backend execution qualification. Root owns those
guarded target runs and their result reports. The earlier upstream-native
eight-gate success is not an own-backend gate result.

Method preservation: a path collision briefly overwrote `emit-self-v4.mjs` while
preparing the new combined-source method. Its original bytes were restored
exactly to SHA `273961ea1158714199ae5b6e5b262316f0a66ffe416a2638a6ff95a85e952e85`,
verified against both `js-self04/report.json` and that run's guarded input
manifest. The replacement lives only at fresh version 5. Original version 4
derivation-metadata bytes were not recovered; its current reconstruction receipt
states that limitation explicitly and does not claim original metadata identity.
