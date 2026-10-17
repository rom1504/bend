# Native command line in Bend

The Phase103 public entry calls the Phase102 candidate04 compiler directly from
Bend. Ordinary requests run a native executable with no Python, Node, Bun or
TypeScript interpreter. The separately installed JavaScript compiler is unchanged.

From the repository root after installing the native package:

```sh
selfhost/bend input.bend -o output.c
selfhost/bend --help
selfhost/bend --version
selfhost/bend input.bend -o checked-live.c --live
```

On a fresh checkout, restore the committed package with ordinary system tools:

```sh
mkdir -p selfhost/dist/native
tar --keep-old-files -xzf selfhost/tools/native/releases/phase103-cli01/package.tar.gz -C selfhost/dist/native
(cd selfhost/dist/native && sha256sum -c FILES.sha256)
```

`selfhost/bend` is a symlink directly to that executable, not a launcher script.
The archive and its [receipt](../../selfhost/tools/native/releases/phase103-cli01/receipt.json)
retain the exact source and build identities. Extraction refuses existing files;
use a fresh directory when installing another package version.

This emits C; use a C toolchain to build the resulting program. One source that
imports Base is supported, with the same nine effects as candidate04: IO.args,
IO.print, IO.print_err, IO.now, File.open/read/size/write/close. Arbitrary module
and foreign imports are outside this entry. The compiler uses one CPU worker
with GPU disabled; that does not limit parallelism in emitted user programs.

Relative paths resolve from the caller's directory. Spaces, Unicode, symlink
invocation and PATH invocation work. Use `-o output.c -- -input.bend` for an input
name beginning with a dash. Output parents must already exist. Existing files,
directories and dangling symlinks are refused. Output is written to an exclusive
temporary file, flushed and closed, then linked into place without replacement;
an interrupted write cannot leave partial C at the requested output path.
Created outputs have mode 0600. An abrupt process termination can leave a
`.bend-native-*` temporary file. A failure after publication explicitly says
that output was published; the file is complete even if temporary cleanup failed.

Usage errors exit 2; compilation, asset and filesystem errors exit 1. Success
exits 0 and leaves stdout empty; compiler verdicts remain on stderr. Help and
version need no assets. Inputs are bounded to 16 MiB and C output to 64 MiB.
The public entry adds no automatic deadline or benchmark-log directory.

## Package and trust

The executable discovers `assets/` beside its actual executable location through
Linux `/proc/self/exe`. Move the executable and that directory together. Trusted
assets never come from the current working directory. Each consumed Base,
prepared-cache, runtime-part and effect file is checked against SHA-256 identities
embedded in the Bend executable. The same bytes are validated and returned to
Bend; no verify/reopen window is introduced. Missing or changed assets fail;
there is no silent fallback. The expected digests do not live in an editable
external manifest.

The prepared cache retains its authenticated historical **logical** Base path.
Physical assets can live anywhere next to the executable. This separates source
identity from storage location; it does not pretend that the carrier was rebased.
`--live` prepares the same logical Base from its authenticated source instead.
The original checkout path is not needed for ordinary requests.

This version targets Linux x86-64 and requires `/proc`, ordinary POSIX files and
the C runtime's system libraries. It is not a portable macOS/Windows package.

## What remains in other languages

| Component | Language and role |
| --- | --- |
| Parsing, checking, optimization, C emission | Bend, unchanged candidate04 algorithms |
| Arguments, asset identities, cache choice, compiler invocation, diagnostics | [Bend entry](../../selfhost/src/host/native-cli.bend) |
| File/path access, SHA-256, atomic publication | [Small C OS provider](../../selfhost/src/host/native-os.c) |
| Runtime startup | [C adapter](../../selfhost/tools/native/cli/start.c), passes arguments untouched to Bend after setting one worker/GPU off |
| Generated-program execution | Existing C runtime; C toolchain builds native machine code |
| Bootstrap and packaging | Node/Bun and pinned upstream TypeScript, Clang, build-time supervision |
| Benchmarks and independent controls | Existing Python/JavaScript tools, outside ordinary requests |
| Optional independent proofs | Lean and existing proof adapters |
| Separate JavaScript CLI | Existing handwritten JavaScript driver around Bend-generated compiler code |

The OS provider owns no language decisions, subprocess compiler or CLI parser.
The old `python3 -B selfhost/native.py ...` remains an explicitly supervised
experimental interface, including B1/B2 selection, repeated calls and receipts.
Its immutable candidate04 admission is not rewritten to claim this new CLI image.

## Build boundary

The build starts from the exact promoted candidate04 source. A temporary bridge
adds only the pinned three host effects to its provider-loading, observer and
constructor-packing permissions. The pinned upstream compiler builds this bridge
as native B1; it then checks and emits the public compiler to C, and Clang builds
the public native B2. The startup adapter includes the generated C unchanged.

The bridge is a build tool, never the public compiler. The final compiler retains
candidate04's original backend permissions and rejects arbitrary user foreign
effects. This avoids turning off compiler-image optimizations merely because
its own CLI needs OS bindings. It is a native Bend-produced B2, not a claim that
the new public executable reproduces its own CLI image: rebuilding the CLI uses
the explicit bridge. Existing backend qualification and new host integration
controls have distinct scopes.

With the candidate04 assets restored in the recorded development checkout, use a
fresh build directory:

```sh
node selfhost/tools/native/cli/build.mjs prepare selfhost/build/phase103/local01
node selfhost/tools/native/cli/build.mjs bootstrap selfhost/build/phase103/local01 harness
selfhost/.bootstrap/bun-1.4.3/bun selfhost/tools/native/cli/controls.mjs selfhost/build/phase103/local01 selfhost/build/phase103/harness-controls-local01 harness
node selfhost/tools/native/cli/build.mjs bootstrap selfhost/build/phase103/local01 bridge
node selfhost/tools/native/cli/build.mjs emit selfhost/build/phase103/local01
node selfhost/tools/native/cli/build.mjs link selfhost/build/phase103/local01
selfhost/.bootstrap/bun-1.4.3/bun selfhost/tools/native/cli/controls.mjs selfhost/build/phase103/local01 selfhost/build/phase103/cli-controls-local01 compiler
```

The build records identities and uses the existing Python resource guard for
large jobs. Controls should also run under that external guard in CI. Python is
a development dependency here, never a runtime launcher. Read the
[design](../../design/phase103/native-bend-cli.md) and
[implementation report](../../implementation/phase103/README.md) for exact
artifacts, installation, controls, rejected early attempts and measured scope.
