# Running the compiler as a native executable

Phase90 provides a qualified Linux x86_64 **self-hosted native compiler written
in Bend**. It parses, checks and emits C without running JavaScript. A native
Bend compiler emitted the complete C used to build this image; the resulting
image reproduced that same C exactly from its own frozen Bend source. Python
authenticates selected files, bounds execution and publishes output. It
implements no compiler algorithm. Clang builds executables from emitted C.

The current native image is `selfhost/build/phase90/compiler-own-native07`,
SHA-256 `d7c7a47917884b14fd3ef37471d9f2a8660d7c4ab9bcc93a249c7cb6d0e37d3e`.
Its source is `d04ad79c…`; the complete 38,614,882-byte self-emitted C is
`dae071f0fae7aec4ae8036ccebe4954690a249e32f59a87ac485b2fa428016bf`.
The [native selection](../../selfhost/tools/performance/phase90/runtime-migration01/native-admission.json)
binds the admission and selected assets. The
[migration report](../../implementation/phase90/runtime-migration.md) records the
independent genuine-JS-B2/native C comparison, actual native self reproduction,
and build and qualification receipts.

This launcher is separate from `selfhost/cli.mjs`. Its native qualification does
not select or install a JavaScript release; consult the
[JS release manifest](../../selfhost/dist/release.json) for that artifact.

## Current same-source qualification

The [Phase93 program-runtime comparison](../../implementation/phase93/README.md)
freshly emits all 45 historical catalog points through both native stages and
upstream C. Native B1/B2 products agree exactly. The 44 measurable points take
1.115× upstream time with equal-point weighting, or 1.139× with equal-original-
source weighting. The remaining zero-work control is optimized away by both;
its ratio is undefined. These are generated-program timings, separate from the
compiler-request measurements below. Full results, limits and reusable commands
are in the report.

The [Phase92 native-chain scoreboard](../../implementation/phase92/README.md)
builds an upstream-C native B1 from the exact same frozen Bend source and Clang
flags. Its newly emitted self C is byte-identical to native07's existing build
input. Fresh self requests take140.3s for B1 and152.2s for native07; TS/Bun
compiles the same source to its own C in48.4s. These are single observations.

On the six-source prepared-Base screen, native B1/B2 process times are0.465×/
0.672× TS/Bun, with Map slower. The two native stages share preparation and
request boundaries; TS performs ordinary Base preparation. Without the carrier,
the single Small control takes3.257×/3.684× TS process time. These figures are
not general language/compiler speed ratios.

Both native stages pass69 selected golden execution fixtures and three rejection
controls each.31 original native100 fixtures exceed the single-source/provider
contract. Full frontend observations and JS emission are unavailable through
this entry. The public native07 selection remains unchanged.

## Restore and compile

Run from the recorded canonical repository path
`/home/ai/bend2/build/publish/bend`:

```sh
python3 -B selfhost/tools/performance/phase90/runtime-migration01/public-assets.py restore \
  selfhost/tools/performance/phase90/runtime-migration01/public-assets01/receipt.json --verify-only
python3 -B selfhost/tools/performance/phase90/runtime-migration01/public-assets.py restore \
  selfhost/tools/performance/phase90/runtime-migration01/public-assets01/receipt.json
python3 -B selfhost/tools/performance/phase90/runtime-migration01/native.py \
  selfhost/tools/performance/phase77/fixtures/small.bend \
  -o selfhost/build/native/small.c
clang -O2 selfhost/build/native/small.c -o selfhost/build/native/small -lm -pthread
selfhost/build/native/small --threads 1 --gpu off
```

The first restoration command verifies every selected archived byte and file
mode without writing. The second restores missing files atomically and refuses
changed existing bytes or permissions. Both validate the capsule and its
manifest; restoration retains 160 MiB free disk space. The capsule contains the
26 request assets, including the executable, Base, carrier, frozen Bend source,
runtime parts, effects, admission and launcher dependencies. Historical proof
and large generated C remain in the separate experiment capsules. Neither
restoration command executes a compiler. Obtain the capsule, receipt, manifest
and methods together from the reviewed repository revision.

The launcher requires Python3 and Linux `taskset`, with CPU3 available. The
qualified native07 build used Lean4.32.0's Clang with its explicit Clang include
directory and `-O2`; reproduce it using the command in the image's
`.native-build.json`. A native compiler request invokes neither Node nor Clang.

Output must be a new path. The launcher verifies a staged copy and publishes it
without overwriting. Request stdout, stderr, phase clocks, file identities and
guard receipts remain under `selfhost/build/native/requests/` on success and
failure. Defaults are 60 seconds, a 2 GiB process-tree RSS limit, a 4 GiB
available-memory floor, and one native thread. `--seconds N` accepts 1..600.

`--calls 5` repeats the same request in one process. All five complete C outputs
must have identical hashes and lengths before the first is published. This is
a diagnostic repeated-request mode, not a persistent multi-source server.
`--live` checks and prepares Base inside the native process; normal mode decodes
the authenticated immutable prepared Base. Changed admitted files and wrong
cache/path identities refuse. No fallback silently selects a different image.

To repeat the full compiler C emission using the restored frozen source, allow
more than the default 60-second request deadline and choose a fresh output:

```sh
python3 -B selfhost/tools/performance/phase90/runtime-migration01/native.py \
  selfhost/tools/performance/phase90/observation/noindent01/compiler-noindent.bend \
  --seconds 240 -o selfhost/build/native/compiler-self.c
sha256sum selfhost/build/native/compiler-self.c
```

The expected SHA-256 is `dae071f0fae7aec4ae8036ccebe4954690a249e32f59a87ac485b2fa428016bf`.
This is the roughly 164-second emission gate; building that C into a new native
executable is the separate roughly 308-second Clang gate recorded above.

**Relocation is not qualified.** Admission and carrier source locations bind the
canonical checkout path. Rewriting paths or symlinking another checkout does not
preserve that identity. A portable package requires separate qualification.

## What is qualified

The entry accepts **one source importing canonical Base** and these nine audited
C effect providers: args, print, now, print_err, file_open, file_read, file_size,
file_write and file_close. Additional imports and other foreign effects refuse
explicitly. File-effect availability does not grant scalar-array or observer
optimization permission.

The actual native07 gates passed:

- Full own-source emission, exactly reproducing the C from which native07 was
  built. That complete C also equals the independently generated genuine JS B2
  output for the same frozen Bend source and runtime.
- Four source fixtures in both live and cached Base modes: Small, Map, Unicode
  and file IO. All eight emitted complete C files matched their admitted oracles.
- Invalid syntax and a type error, with the required diagnostic, actual exit 1,
  no resource stop and no output C.
- Actual Clang builds and executions of all four generated programs, including
  the file IO output bytes and diagnostics.

Native07's full self-emission request took 164.322 seconds. This measures
compiling the full compiler source; it is not a user-program speed ratio or a
claim of parity with upstream. Exact C reproduction is a finite fixed-point
check, not a proof of compiler correctness. These controls do not establish
unrestricted language conformance, GPU execution or parallel-runtime
correctness. The prepared Base remains an authenticated offline product;
`--live` exercises preparation separately.

The final native image was built from **unpatched native-emitted C**. An earlier
native06 diagnostic used an explicit C accessor patch while investigating
Clang's handling of the large function table. The accepted runtime implementation
then emitted that accessor through the normal backend. Native06 and genuine JS
B2 independently emitted the final C, native07 was built from it, and native07
reproduced it. The earlier diagnostic patch is not silently relabeled as the
final build.

See the [launcher and migration methods](../../selfhost/tools/performance/phase90/runtime-migration01/README.md)
for admission, public CLI controls, benchmark integration and restoration.

## Historical Phase89 lineage

Phase89's `selfhost/build/phase89/compiler-native-self01` was a native **B1**
bootstrapped by the upstream TypeScript C emitter, with source `4584cf08…` and
binary `8bacae26…`. Its eight live/cache controls, 45-point exact-C comparison,
public launcher and restoration evidence remain tied to that older image.
Its complete 1,755,310-byte self-compilation attempt timed out at 600.022 seconds
without C output; that was a deadline stop, not OOM. It established no native
self-emitted B2 or fixed point.

The Phase89 launcher and its Phase88/89 restoration tools remain historical;
they do not select or restore native07. The separate native source profile
retains the compiler-owned equality/observer and linear-builder work from
Phase88 plus Phase89's owned composition and ordered chunks. Their old JS
screens and native measurements must not be treated as current speed results.
See the [Phase89 report](../../implementation/phase89/README.md),
[JS integration evidence](../../implementation/phase89/js-integration.md), and
[historical restoration receipt](../../implementation/phase89/restoration.json).
