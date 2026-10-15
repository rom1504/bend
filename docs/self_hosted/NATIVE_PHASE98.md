# Phase98 native compiler profile

Phase98 provides a qualified native compiler profile with retained String equality,
fused tag comparisons, scoped observer permission and a correction to
observer ancestry refusal. The source is separate from the installed JavaScript
release and the canonical Bend modules. The [Phase98 report](../../implementation/phase98/README.md)
records actual qualification, selected images and measurements. The stable
`selfhost/native.py` entry selects native B2 by default; `--stage b1` selects its
upstream-built parent. Both stages and the actual public launcher passed their
separate qualification gates.

The exact profile source has SHA256
`2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
It is 1,754,096 bytes and adds 79 physical lines to the D04 native source. The compact
[`comparison02` recipe](../../selfhost/tools/native/profiles/phase98-comparison02/profile.json)
applies 1,376 exact edits and reverses to the original source preserved in the
committed Phase90 capsule. Comparison01 is retained as history: its eager
nonmatching ancestry recursion can diverge. Cache/redirect experiments are not
part of comparison02.

## Use an admitted release

These commands require an actual completed admission and
`selfhost/tools/native/selection.json`. The launcher refuses missing, changed or
unqualified assets. From the repository root:

```sh
python3 -B selfhost/native.py input.bend -o output.c
python3 -B selfhost/native.py input.bend -o output-b1.c --stage b1
python3 -B selfhost/native.py input.bend -o output-live.c --live
python3 -B selfhost/native.py input.bend -o output-repeat.c --calls 5 --seconds 300
```

The selection declares the default stage. The completed Phase98 release sequence
selected B2 after its own gates and the public CLI controls passed. `--stage b1`
or `--stage b2` explicitly chooses the other admitted stage;
`--selection PATH` chooses another exact admission pointer.

| Stage | Producer and execution |
| --- | --- |
| B1 | Pinned upstream compiles the exact Bend source to C; Clang builds that C. Requests execute the resulting native Bend compiler. |
| B2 | Actual native B1 compiles that same Bend source to C; Clang builds the emitted C. Requests execute the resulting self-hosted native compiler. |

The B1 build is recorded in `selfhost/build/phase98/origin-b1.json`; its ELF SHA256
is `099df960c418c9caef6977f011074fcc2aa43e2fbbd3daee32fe80824b54e1e9`.
The B2 ELF SHA256 is
`c481bd2c1b057dee537442765aca1b36786437fe37b3543dc405677329f18554`,
recorded in `selfhost/build/phase98/origin-b2.json`. The admission is
`selfhost/build/phase98/origin-admission01/report.json`. A build receipt alone
does not qualify either image. Full self-C
agreement is a source-bound consistency check, not an ELF fixed point or a
mathematical proof of the compiler.

Python authenticates files, bounds execution and transports requests. Compiler
algorithms run in the native Bend image; ordinary requests neither invoke
JavaScript nor rebuild the compiler. This entry emits C. Building and executing
that generated program is a separate operation.

Requests use one CPU worker with GPU disabled. The default deadline is 60 seconds;
`--seconds` accepts 1–600. The default uses the authenticated prepared Base carrier;
`--live` reads and checks Base. Five-call requests require all five complete C
outputs to match. Existing output paths are refused. Each request retains its
success or failure evidence under `selfhost/build/native/requests/`, and selected
inputs are checked before and after execution.

## Source and semantic boundaries

The native entry accepts one canonical Base-importing source and these nine
authenticated effect APIs: `IO.args`, `IO.print`, `IO.now`, `IO.print_err`,
`File.open`, `File.read`, `File.size`, `File.write` and `File.close`. This is not
the full module/import or frontend observation interface. Provider identity,
trusted source origin and the checked representation contract remain required;
an API name alone grants no permission. Invoking an ELF directly with arbitrary
provider files bypasses the maintained host's authentication boundary.

Scoped observer permission allows the analysis to consider a pure borrowed
traversal within an otherwise admitted effectful program. The traversal itself
executes no foreign call and admits only its restricted typed root/scalar/result
schema. Original owned roots stay alive while borrowed cursors move. Mutable
Array roots, allocating Word views, swapped root identities, unsupported helper
calls and effects inside a traversal retain ordinary owning compilation. Existing
packed-array, scalar-narrowing and other whole-book permissions remain separate.

The ancestry correction checks for `OField` before descending to its child.
Nonmatching non-field origins return False. The old eager conjunction could
recurse forever through `Absent`; the new behavior extends termination rather
than claiming equivalence to a divergent execution. See the
[source/C diagnosis](../../implementation/phase98/profile-findings.md) and
[caller/lifetime review](../../implementation/phase98/observer-safety-review.md).

The helper laws, source audits and finite execution controls establish different
facts. They do not prove the unsafe compiler adapters, entire observer analysis,
native runtime, reference counting or arbitrary FFI. Qualification must retain
the independent output oracles, resource failures and unsupported cases. No
full frontend, GPU, parallel, universal compiler-correctness or TypeScript-speed
claim follows from this profile.

## Replay and restore

Reproduce the source without running a compiler, using fresh output paths:

```sh
python3 -B selfhost/tools/native/profile.py --profile selfhost/tools/native/profiles/phase98-comparison02/profile.json --out-source /tmp/compiler-native-phase98.bend --receipt /tmp/compiler-native-phase98-replay.json
```

The final request capsule is sealed. Verify or restore it with:

```sh
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets02/receipt.json --verify-only
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets02/receipt.json
```

The request capsule contains both qualified images, exact source/profile assets,
selection/admission, Base/carrier/runtime/providers and host methods. Full large
C products, experiment methods and failed-run logs are preserved in the separate
Phase98 evidence capsule. Both restorers create missing files and refuse changed
existing bytes or modes. Restore at the recorded canonical checkout root because
the Base carrier and receipts contain source-location identities.

The [release sequence](../../selfhost/tools/performance/phase98/comparison/promotion-plan.md)
specifies actual gate collection, public CLI validation, selection and archival.
Historical [native07 usage](NATIVE_HOST.md) and the
[original observer contract](NATIVE_OBSERVERS.md) remain unchanged audited records.
The historical native07 launcher stays explicitly available:

```sh
python3 -B selfhost/tools/performance/phase90/runtime-migration01/native.py input.bend -o historical.c
```
