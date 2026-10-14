# Running the compiler as a native executable

Phase89 provides a qualified Linux x86_64 **native B1 image** of the compiler
written in Bend. Once built, it parses, checks and emits C using native Bend
code. Python authenticates files, supervises resource limits and publishes the
result; it implements no compiler algorithm and runs no JavaScript. Clang is
needed to build an executable from the emitted C.

The current image is `selfhost/build/phase89/compiler-native-self01`, SHA256
`8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45`.
Its checked Bend source is `4584cf08…`, and its C is `b1560234…`; complete
identities and proof receipts are in the
[admission manifest](../../selfhost/tools/performance/phase89/native-admission.json).
The image has passed eight live/cache exact-C gates and the broad 45-point gate.
The versioned launcher also passed all ten acceptance/refusal controls: cached
and live Small/file-IO exact-C emissions, five public CLI refusals and a private
changed-manifest admission refusal. The sealed capsules verify all12 selected
assets, and a missing executable was restored with identical bytes and admission.
See the [restoration receipt](../../implementation/phase89/restoration.json).

The installed `selfhost/cli.mjs` remains the separately qualified Phase82 JS B2.
The native host accepts **one source importing canonical Base**, with these
nine audited effect providers: args, print, now, print_err, file_open, file_read,
file_size, file_write and file_close. Additional imports and other foreign
effects refuse explicitly. File-effect availability does not grant the backend's
scalar-array or observer optimization permission. This image is not a native
self-emitted B2. The [Phase88 report](../../implementation/phase88/README.md)
remains the history of the previous three-provider pilot.

## Restore and use the qualified image

The capsule and missing-executable restoration checks pass. Run from the
recorded canonical repository path `/home/ai/bend2/build/publish/bend`:

```sh
python3 -B selfhost/tools/performance/phase88/restore.py
python3 -B selfhost/tools/performance/phase89/restore.py
python3 -B selfhost/tools/performance/phase89/native.py \
  selfhost/tools/performance/phase77/fixtures/small.bend \
  --image selfhost/build/phase89/compiler-native-self01 \
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
Defaults are 60 seconds, 2 GiB maximum process-tree RSS, a 4 GiB available-memory
floor and one native thread. `--seconds N` accepts 1..600; `--calls 5` repeats the
same request in one process and verifies identical C. This is a diagnostic
repeated-request mode, not a persistent multi-source server. Native lazy
address-space reservations are large; avoid an arbitrary small virtual-memory
limit.

Normal mode decodes an authenticated prepared Base in Bend. `--live` checks
and prepares Base in the native process instead. Wrong cache/image/path/ABI or
changed inputs refuse; no silent fallback admits a different artifact. The
Phase89 wrapper reuses Phase88's process supervision and publication code with
its own strict admission function. The returned authentication records identify
both versions and all nine providers before and after each request. See the
[launcher methods](../../selfhost/tools/performance/phase89/native-launcher.md).

Phase88 restoration supplies the preserved shared runtime/cache dependencies;
Phase89 restoration verifies evidence02/03 and selects the required native89
assets, then restores executable permission. Both refuse changed existing files
and preserve 160 MiB free space. Phase89 `--verify-only` verifies selected archived
assets without writing. Its evidence03 receipt must include `nativeAssets`;
an incomplete capsule is not silently accepted.

**Relocation is not qualified.** Receipts and cache source origins bind the
canonical checkout path. Rewriting paths or symlinking another checkout does not
preserve the admitted identity. A portable package needs separate relocation
qualification; this is not a universal installer.

## Build profile and validation boundaries

The build is `Bend compiler source → upstream TypeScript C emitter → Clang →
native B1`. TypeScript is a bootstrap dependency. Native B1 then handles user
Bend→C requests independently. The prepared Base was produced offline by the
identified Phase82 B2, compared against fresh Bend preparation, serialized and
decoded as shared named Data; it is not a heap snapshot or native self-hosting.

The explicit native build profile adds owned match composition and ordered body
chunks to the Phase88 observer/linear-builder fixes and compiler-owned consuming
String equality adaptation. The two Phase89 compiler changes add **93 source
lines** in total (+14 owned composition, +79 chunks); entry/effect tooling is
separate. They are retained as checked source derivatives, without editing
canonical production modules or the installed JS image. The profile leaves Base
and user input untouched and is checked as a complete Bend program before
emission.

Separate ordinary JS B1 screens found the combined change 4.11% slower and
owned composition alone 1.15% slower in the six-case geometric mean of median
compilation requests. Two rounds do not establish precise statistical effects,
but neither screen supports JS promotion. The native profile therefore remains
separate; see [JS integration evidence](../../implementation/phase89/js-integration.md).
Native compilation gains from the chunks experiment are recorded in the
[body-chunks report](../../implementation/phase89/body-chunks-feasibility.md);
these are compiler request timings, not generated-program execution ratios.

The admitted nine-provider image emits complete C identical to installed B2 for
all 45 broad points and the four live/cache fixtures. The broad gate transfers
previous execution evidence for those exact C outputs; it is not a new full
language-conformance or generated-program speed campaign.

Full native self-compilation remains blocked: the exact 1,755,310-byte compiler
source attempt hit the 600-second deadline (600.022 seconds guard wall time),
with peak process-tree RSS 1,079,590,912 bytes and no emitted C. The recorded stop
was a deadline, not OOM. Its separately frozen eight-gate qualification remains
valid, while the overall self-emission attempt is failed. No native B2 was built
or executed, and no self-reproduction claim follows from this native B1 image.

The installed JS artifact remains intact and its CLI smoke test passes. Explicit
JS release verification currently rejects three Phase88 checkout-source changes;
see [release status](../../implementation/phase89/release-status.md). That inherited
source/manifest mismatch does not relax native89's separate admission checks.
