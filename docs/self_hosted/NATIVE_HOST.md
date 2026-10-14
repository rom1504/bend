# Running the compiler as a native executable

Phase88 provides a qualified Linux x86_64 **native B1 pilot** of the compiler
written in Bend. Once built, it parses, checks and emits C using native Bend
code. Python authenticates files, supervises resource limits and publishes the
result; it implements no compiler algorithm and runs no JavaScript. Clang is
needed to build an executable from the emitted C.

The installed `selfhost/cli.mjs` remains the separately qualified Phase82 JS B2.
The native pilot has a narrower host contract: **one source importing canonical
Base**, with the audited args, print and now effects. Additional imports and
other foreign effects refuse explicitly. It is not a native self-emitted B2.
See the [results and limitations](../../implementation/phase88/README.md).

## Restore and use the qualified image

From the repository root at its recorded canonical path
`/home/ai/bend2/build/publish/bend`:

```sh
python3 -B selfhost/tools/performance/phase88/restore.py
python3 -B selfhost/tools/performance/phase88/native.py \
  selfhost/tools/performance/phase77/fixtures/small.bend \
  --image selfhost/build/phase88/compiler-native02 \
  -o selfhost/build/native/small.c
clang -O2 selfhost/build/native/small.c -o selfhost/build/native/small -lm -pthread
selfhost/build/native/small --threads 1 --gpu off
```

The launcher requires Python3 and Linux `taskset`, with CPU3 available. The
qualified build used the Clang distributed with Lean4.32.0, plus its explicit
Clang include directory; use the exact toolchain recorded in the image's
`.build.json` for reproduction. No Node or Clang is invoked by a native request.

Output must be a new path. The launcher stages and verifies the copy before
publishing it without overwriting. It retains request stdout, stderr, hashes,
phase clocks and guard receipts under `selfhost/build/native/requests/`.
Defaults are60seconds,2GiB maximum process-tree RSS,4GiB available-memory floor
and one native thread. `--seconds N` accepts1..600; `--calls 5` repeats the same
request in one process and verifies identical C. It is a diagnostic repeated
request mode, not a persistent multi-source server. Native lazy address-space
reservations are large; avoid an arbitrary small virtual-memory limit.

The normal mode decodes an authenticated prepared Base in Bend. `--live` checks
and prepares Base in the native process instead. Wrong cache/image/path/ABI or
changed inputs refuse; no silent fallback admits a different artifact.

The restoration helper verifies the main capsule, its runtime-receipt supplement
and selected member hashes and restores
executable permission. It refuses changed existing files and preserves160MiB
free space. `--verify-only` verifies the archived native assets without writing;
`--all` restores every experiment and needs more space.

**Relocation is not qualified.** Receipts and cache source origins bind the
canonical checkout path. Merely rewriting paths or symlinking a different
checkout does not preserve the admitted identity. A portable package needs a
separate host/relocation qualification. The experimental artifacts are useful
and reproducible at the recorded path; this is not a universal installer.

## Build and validation boundaries

The build is `Bend compiler source → upstream TypeScript C emitter → Clang →
native B1`. TypeScript is a bootstrap dependency. Native B1 then handles user
Bend→C requests independently. The prepared Base was produced offline by the
identified Phase82 B2, compared against fresh Bend preparation, serialized and
decoded as shared named Data; it is not a heap snapshot or native self-hosting.

The native image contains production observer/linear-builder fixes and a native
source derivative replacing compiler-owned string equality with a safe consuming
Bend helper. The derivative leaves Base and user input untouched. It is checked
as a complete Bend program before emission. Its source, C, checked acquisition
and build receipt are in the capsule. Consult the
[build and fast-loop methods](../../selfhost/tools/performance/phase88/README.md)
before rebuilding or changing this image; cache admission is deliberately bound
to the qualified consumer. Do not relabel a new image as the existing release.

The native compiler is faster than TypeScript in five of six cold-process
screen cases, with Map1.76× slower; the fifth warm Map request is still6.46×
slower. These are compilation clocks with documented cache/startup differences,
not generated-program execution ratios. All45 broad points emit exact installed
B2 C and execute correctly. General conformance and native B2 reproduction remain
separate gates.
