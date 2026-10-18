# Full native compiler through QBE

Phase108 extends the Clang-free experiment to the full self-hosted compiler.
The new compatibility path is:

```
Bend compiler source
  → trusted native Bend compiler
  → C with portable continuation segments
  → cproc → QBE → GNU assembler/linker
  → native Bend compiler
```

The compiler's parser, checker, eraser, optimization decisions and C/JS backend
implementations remain written in Bend. cproc is a C frontend, QBE is the machine
backend, and a small GCC-built support object supplies atomics and CLZ. No Bun or
Clang runs during ordinary compilation through this path. The initial trusted
native compiler was acquired using Clang in an earlier phase.

This is distinct from the [direct typed-IR experiment](NATIVE_IR.md), which lowers
a first-order scalar subset from checked Bend terms directly to Nx and QBE.
The compatibility path retains the mature compiler's ownership, closures, arrays,
foreign effects and continuations. It does not yet extend direct Nx to all Bend.

The installed `selfhost/bend` remains the qualified production CLI. The experimental
QBE compiler has its own image manifest and finite qualification scope. It is not
silently selected as the production compiler; current request execution is slower
than the Clang-built image. See the [report](../../implementation/phase108/README.md)
for exact clocks and limits.

## Ordinary experimental build

From the repository root, after restoring/acquiring the recorded image:

```sh
python3 -B selfhost/tools/performance/phase108/compile.py \
  selfhost/tools/performance/phase108/coverage/fixtures/nt-reverse.bend \
  --out selfhost/build/phase108/my-reverse
selfhost/build/phase108/my-reverse/program --threads 1 --gpu off
```

The output directory must be fresh. The host script authenticates the compiler,
runtime and toolchain, runs the native Bend compiler, then builds its C through
cproc/QBE. Python implements tool hosting, limits and receipts; it implements no
language/compiler algorithms. `--live` checks Base from source instead of using
the authenticated prepared Base. Generated C, diagnostics, build commands and
hashes stay alongside the executable. Linux x86-64 is the admitted host platform.

The native compiler executable can also be called directly with the supervisory
argument contract recorded in its qualification receipts. It is a native process;
the convenience wrapper is not its execution engine.

## Runtime and bootstrap

A portable segment returns to an explicit dispatcher. The dispatcher owns the
continuation stack pointer, result count and register bank. Segment transitions
do not grow the C stack. The existing heap, reference counting and IO remain in
use. v3 uses a single state pointer and five typed, single-evaluation scalar
accessor macros because cproc/QBE does not inline C helpers.

The old trusted compiler does not emit register-state metadata. A narrowly checked
bootstrap bridge adds exactly four metadata definitions to its first C output.
The updated Bend source emits these itself, and self-emitted successors need no
bridge. Experimental runtime replacements are whole authenticated template parts,
with inverse checks; program function bodies are not translated or rewritten.

Runtime profiles are compact exact-edit recipes against the selected runtime.
No duplicate full runtime implementation is maintained. Toolchain patches add
ELF constructor initialization in cproc and128-byte alignment in QBE. These are
pinned local extensions, not claims about upstream tool support.

## Reproduce and inspect

[Phase108 tools and commands](../../selfhost/tools/performance/phase108/README.md) ·
[Design](../../design/phase108/full-native-qbe.md) ·
[Report](../../implementation/phase108/README.md).

The finite suite covers data aliases, Unicode, captured functions, non-tail
recursion, arrays, IO and source rejection. GPU execution and parallel scaling
require separate qualification. Unsafe/foreign compiler definitions retain their
existing proof verdicts; successful bootstrapping is not a whole-compiler proof.
