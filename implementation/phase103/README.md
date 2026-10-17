# Phase103: native command line implemented in Bend

The public command is now `selfhost/bend INPUT.bend -o OUTPUT.c`. It directly
runs a native compiler whose CLI and compiler algorithms are written in Bend.
Ordinary requests do not invoke Python, Node, Bun, TypeScript or another compiler
process. The package is installed here and committed for restoration elsewhere.
The [usage guide](../../docs/self_hosted/NATIVE_CLI.md) describes extraction,
options, platform support and the remaining language dependencies.

This is the implementation of the [design](../../design/phase103/native-bend-cli.md).
It replaces the public Python-launcher role; it does not port the independent
benchmark infrastructure, proof adapters or separate JavaScript CLI.

## Implementation and trust boundary

The 152-line [Bend entry](../../selfhost/src/host/native-cli.bend) owns argument
parsing, expected asset identities, cache/live selection, compiler invocation,
diagnostics and exit decisions. It directly calls `p88_cache_prepare`,
`p86_plan` and `p86_compile` in the same process. The compiler core remains the
promoted Phase102 candidate04 profile.

Three [C host effects](../../selfhost/src/host/native-os.c), 246 lines including
SHA-256, supply filesystem/path/byte operations. They read and authenticate the
same buffers before returning them to Bend. Publication writes an exclusive
temporary file, fsyncs and closes the writer, holds the inode through a separate
descriptor, and atomically links it into place without replacement. The handler
does not implement compiler or CLI policy. A 19-line [startup adapter](../../selfhost/tools/native/cli/start.c)
selects one worker/GPU off and forwards public arguments past the runtime's own
option parser. Generated user-program runtime assets are unchanged.

Assets live beside the executable; expected SHA-256 digests live in its Bend
code. The prepared carrier keeps its original logical Base identity while its
physical location changes. No original checkout file is read for that identity.
This avoids both a cache rebase and the cost of always preparing Base live.
Cache/live output equality, relocation and missing/corrupted asset refusal pass.

The new OS effects would normally disable observer optimization and constructor
packing in the compiler image. A build-only bridge admits exactly these three
operations and their pinned source path, including both permission checks.
Their C implementation consumes inputs and constructs fresh results, without
exposing or mutating immutable Bend roots. The final compiler retains the
original observer/packing predicates and nine-provider allowlist for user code.
The bridge is not installed as the public compiler.

The shipped source has only two replacements within the candidate04 text:
the private main becomes the public main, and effect reads authenticate consumed
bytes. The new entry and generated immutable asset identities are appended.
Parser, checker, IR, optimization passes and user C emission remain unchanged.

## Native production and identities

Pinned upstream `059266225b77c8ca256ac6b25ee5c21449bab151` checks and emits the
temporary bridge; Clang builds that native B1. Bridge B1 checks/emits the public
compiler, and Clang builds its native B2 generation. The final generated C is
included unchanged by the startup adapter. The public source also independently
passes the pinned upstream checker with zero holes.

This is not a new matched-source B1/B2 fixed-point claim: the build-only bridge
and public CLI have different host entries. The narrow public foreign policy
still refuses the CLI's own custom OS provider. Rebuilding the CLI uses the
explicit bridge. The underlying candidate04 fixed-point and broad qualification
remain recorded in the [preceding promotion](../phase102/default-promotion.md).

| Artifact | SHA-256 |
| --- | --- |
| Candidate04 compiler source | `63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237` |
| Public CLI compiler source | `bb65ec3cc2da290df68d7302661ab1b9a2506e1d1b49a555a4d55c2661c84497` |
| Build-only bridge source | `c0f2218495144c8b557db8e647c36323f2b44be888a0cedf0839ecd90e10923e` |
| Native bridge B1 | `2d0bec16e1093eb6de87dfb5d60afff2cf5cc7068a3051f4d68c0056a2b5216c` |
| Bend-emitted public compiler C | `6ac1de9eeef5cebabbaef44bef36fcb2fada358e3add06c877249cb10411bf8a` |
| Public native executable | `55b4def3e01e194299fc8a4c96daf12def4cb4e742975ef4a7d748ba79c09a8e` |
| Package archive | `515f7da8dbd4111b91ea2cfdcd4d2b019f524ea37bbe30863a1919a155a8ea11` |

The executable is 21,159,504 bytes; its generated C is 30,404,871 bytes. The
6,183,930-byte [package](../../selfhost/tools/native/releases/phase103-cli01/receipt.json)
contains 26 files: executable, 16 runtime assets, source/build materials and
metadata. Extraction and all 25 listed payload checksums pass; the receipt also
binds the checksum manifest. `selfhost/bend` is a direct symlink to the extracted
ELF. The old supervised `native.py` selection remains intact and explicit.

## Validation

| Check | Result and evidence |
| --- | --- |
| Small upstream-built native harness | 24/24 CLI/filesystem controls; `harness-controls02/report.json` |
| Small Bend-produced native harness | 24/24 controls; `harness-native-controls01/report.json` |
| Final public B2 | 41/41 controls; [retained receipt](../../selfhost/tools/native/releases/phase103-cli01/records/controls.json) |
| Complete C and verdict equivalence | 6/6 source pairs equal to candidate04 B2; [retained receipt](../../selfhost/tools/native/releases/phase103-cli01/records/equivalence.json) |
| Concurrent publication | Exactly one winner; complete bytes equal to independent successful output; `publication01/report.json` |
| Interrupted write | File-size fault leaves no requested output; temporary file recorded; same receipt |
| Installed package | Extracted checksums pass; installed symlink emits C; that C builds and prints `42` |

Final controls cover argument orders, empty/extra/missing values, help/version,
`--`, spaces and Unicode, another cwd, PATH/symlink invocation with no language
interpreters on PATH, live/cache equality, file/directory/dangling-link refusal,
source/output alias, input bound, invalid UTF-8, missing source/parent, parse and
type rejection, unsupported module/foreign rejection, and missing/corrupt Base,
cache, runtime part and consumed effect. There is no fallback to original assets.

The six matched sources are small arithmetic, 65 functions, local array folding,
the lexer benchmark, a Unicode scalar-array IO case, and upstream file roundtrip.
Every complete C byte and compiler verdict matches; only the private entry's
three timing lines are excluded from diagnostic comparison. There is no
generated-code change on those six programs; runtime speed was not remeasured.
The suite is an integration check, not new full-language conformance or a rerun
of all 45 runtime benchmarks. The original broad candidate04 evidence applies
to the unchanged compiler algorithms with its original recorded scope.

## Time, performance and complexity

| Large build step | Wall time | Peak process-tree RSS |
| --- | ---: | ---: |
| Independent public-source check and upstream C emission | 36.06 s | 2545 MiB |
| Bridge check and upstream C emission | 36.04 s | 2621 MiB |
| Native bridge Clang build | 191.22 s | 4242 MiB |
| Native bridge emits public compiler | 123.04 s | 1441 MiB |
| Public compiler Clang build | 369.88 s | 2482 MiB |

The final 41-control loop takes 5.91 s, six-pair equivalence 3.98 s, and atomic
publication controls 1.01 s. Twenty-nine Phase103 guard receipts sum to 786.88 s,
including failed early attempts and orchestration. This excludes the three old
public launcher's internal guard records outside this directory. No deadline,
RSS or available-memory stop occurred. Large target jobs ran serially; only the
explicit two-publisher correctness test overlapped compiler requests. Two reused
agents handled OS code/design/review/packaging offline; root owned target runs.

A small three-pair public-interface observation gives median **0.550 s** for the
old mandatory Python launcher and **0.208 s** for the direct native CLI. All six
outputs match. The old timing includes its required wrapper/supervisor, while
the new time is the native process observed under an external guard; these are
different capture envelopes appropriate to the two public interfaces. This is
one small source, not a compilation-throughput benchmark or a new upstream
speed comparison. The separate private-entry equivalence invocations were faster
than public CLI invocations: they omit the public authentication/publication
work. Do not conflate those figures or claim a compiler-kernel speedup.

The assembled compiler grows from 39,372 to **39,545 lines** (+173, 0.44%).
Production host support adds 246 C lines and 19 startup lines. This removes an
ordinary-request language dependency, not total repository LOC: OS work formerly
provided by Python's library is now explicit C. Build, control and packaging
scripts stay development tools. The independent JS compiler is unchanged.

## Rejected attempts and retained limits

Early harness checks caught invalid Bend match placement, a missing held `rest`
binder, and upstream's handling of absolute foreign imports. The final source
uses checked helper matches, the held binder and a relative OS provider import.
These were found before the large native image build.

The first Node 24 control runner returned `EPERM` from `spawnSync` even when
children finished with correct outputs/statuses. The unchanged runner passes
under pinned Bun; no failed process observation was ignored. A later module
refusal fixture initially used invalid import syntax. Requiring the specific
provider/import refusal exposed that test error; the corrected fixture passes.
An initial public-timing attempt nested two exclusive resource guards and was
correctly refused. Its successor uses the old interface's own guard and an
external guard for the new direct process. Failed evidence is retained.

Supported deployment is Linux x86-64 with `/proc`; output parents must exist,
files are created mode 0600, and no automatic public deadline/RSS supervisor is
installed. The program keeps the same one-source/nine-effect boundary. This is
neither a whole-compiler proof nor a GPU/parallel-compiler qualification.
Python still exists in benchmarks and historical replay; JavaScript remains in
the separate JS driver and development tools; Clang and the C runtime remain
native dependencies; optional proofs still use Lean.

The [evidence archive](evidence.tar.gz) and [inventory](evidence.json) retain successful and
failed controls, raw logs, exact source snapshots, generated C and methods.
No PR comment was posted.
