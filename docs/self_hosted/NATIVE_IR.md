# Native Bend → QBE compiler experiment

The Phase107 prototype compiles an admitted scalar subset of Bend using a native
compiler written in Bend. Ordinary requests use no Bun or Clang. The current
installed general compiler remains unchanged; this is a separate research path.

```text
Bend source
  → native Bend parsing/checking/ownership/layout admission
  → checked KTerm definitions
  → Bend lowering to typed Nx IR
  → Bend optimization and QBE IL emission
  → QBE machine-code compiler
  → GNU assembler → object file
  → GCC linker driver + shared runner → native executable
```

Python authenticates inputs, starts tools and retains receipts. Compiler checking,
lowering, transformations and QBE text emission are implemented in Bend. QBE is
itself implemented in C, but this path emits QBE IL, not C source. GCC compiles
the small common runner once per cache identity and drives executable linking.
Clang is used only when acquiring a new native compiler image from Bend source.

The separate Rust/Cranelift adapter consumes the same experimental IR transport.
Rust implements that machine-code adapter, not the Bend frontend or optimizer.
The native command documented here selects QBE; Cranelift experiments remain
available through the [Phase106 tools](../../selfhost/tools/performance/phase106/README.md).

## Supported source and limits

The frontend retains the selected native compiler's parsing, type checking,
ownership checks and checked-layout admission. The new lowering then accepts
first-order scalar functions, U32 operations in its explicit primitive set,
internal Boolean control flow, checked erased arguments/locals, direct calls and
the admitted Boolean match forms. Unsupported features are refused explicitly.

The source contract is one file importing the pinned Base, at most16MiB. Other
module imports are refused. Reachable annotation begins at `main`; an alternate
entry such as `bench` must be reachable from it. Exported runtime arguments must
fit the scalar entry ABI; live Boolean arguments are refused because the integer
runner does not enforce their canonical domain. Internal Booleans remain supported.
User datatypes, general Nat computations, higher-order source applications and
arbitrary foreign replacements are outside this source subset. Lookalike names
do not grant access to trusted Base primitive semantics.

The IR itself also supports pointers, explicit allocation/load/store/free,
indirect function calls and loops. Some research workloads construct these graphs
directly. Their success does not demonstrate source lowering for Bend closures,
ownership, the scheduler, GPU execution or the full language. The common runner
uses the experimental `u32(const u64*)` ABI and a sequential libc allocation
contract. It does not implement the production Bend task/device runtime.

`raw` preserves the lowered graph. Current `fast` applies self-tail conversion,
entry-first inlining with4096-node budget, constant folding and closed-program
function reachability. QBE entry-body fusion has a separate512-node cap. The
prepared manifest records the exact ordered policy, so historical images can be
compared without guessing their passes. Self-tail conversion does not establish
general mutual-tail-call support.

## Acquire an image once

Run commands from the repository root. The installed Phase103 native compiler,
its retained receipt/assets and Clang from the pinned Lean4.32 toolchain must be present.
The acquisition script checks their recorded identities and fails if they differ.
Use fresh names for every source, image, request and guard directory below.

```sh
python3 selfhost/tools/performance/phase107/frontend/native/prepare.py \
  --out selfhost/build/phase107/native-source-user01

python3 selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase107/native-image-user01-guard \
  --seconds 900 --rss-mib 3072 --available-mib 8192 --cpu 3 -- \
  python3 selfhost/tools/performance/phase107/frontend/native/acquire.py \
  --source-dir selfhost/build/phase107/native-source-user01 \
  --out selfhost/build/phase107/native-image-user01
```

Preparation assembles a complete source snapshot from authenticated selected
compiler code and the current Nx modules. Acquisition invokes the installed
native Bend compiler, then Clang `-O2` with the existing `start.c` wrapper. The
generated C is hashed before and after linking and never edited. The wrapper's
`BEND_NATIVE_HOST=1` option preserves the argument slot expected by Base IO; this
does not introduce a new foreign provider.

The result contains `compiler`, untouched `compiler.c`, exact commands/logs,
`acquisition.json` and `image.json`. The image receipt binds executable, source,
source manifest and acquisition record. Every input/tool pin is checked again
after acquisition. `--plan-only` writes a plan into a fresh output directory
without executing tools or publishing an image receipt. Per-job wall times are
recorded; the driver's RSS field is the cumulative child high-water mark on Linux.
Use the outer guard's process-tree peak for a complete memory measurement.

Successful acquisition establishes a build, not semantic qualification or a
bootstrap fixed point. Run the source/refusal and generated-program controls
before interpreting performance or promoting an experimental image. Source02's
unit transport exposed an escaping bug; the focused transport gate now checks
all control characters before another costly native acquisition. Source03 was
superseded by source04's Boolean-default-arm fix. Retained failures remain useful
evidence and are not overwritten by new runs.

## Prepare QBE once

The established tool path is
`selfhost/build/phase107/toolchain/qbe-1.3/qbe`. QBE1.3 is pinned to release archive
SHA256`d587905d620dc5e1d2bfa7c2cc642b9b837aa89a3188c6e37b53d756cf66e320`.
If the tool is absent, acquire and verify it in a fresh directory, then build
serially with GCC:

```sh
(
set -eu
test ! -e selfhost/build/phase107/toolchain/qbe-1.3
test ! -e selfhost/build/phase107/toolchain/qbe-1.3.tar.xz
mkdir -p selfhost/build/phase107/toolchain
curl --fail --location https://c9x.me/compile/release/qbe-1.3.tar.xz \
  --output selfhost/build/phase107/toolchain/qbe-1.3.tar.xz
printf '%s  %s\n' \
  d587905d620dc5e1d2bfa7c2cc642b9b837aa89a3188c6e37b53d756cf66e320 \
  selfhost/build/phase107/toolchain/qbe-1.3.tar.xz | sha256sum --check
tar -xJf selfhost/build/phase107/toolchain/qbe-1.3.tar.xz \
  -C selfhost/build/phase107/toolchain
make -C selfhost/build/phase107/toolchain/qbe-1.3 CC=gcc -j1
)
```

Use `--qbe ABSOLUTE_PATH` when the verified binary lives elsewhere. The executable
pipeline is currently Linux x86-64/SystemV and expects `/usr/bin/as`, `gcc` and
`ld`. Tool and source hashes are retained per request. System headers/shared
libraries remain part of the fixed host environment; this is not a portable
hermetic build cache.

## Compile and execute a scalar program

Whole-object mode is the default. It transports QBE text directly, reducing cold
tool launches. The following source has a retained independent expectation:

```sh
python3 selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase107/native-request-user01-guard \
  --seconds 30 --rss-mib 1024 --available-mib 4096 --cpu 3 -- \
  python3 selfhost/tools/performance/phase107/frontend/native/compile.py \
  selfhost/tools/performance/phase107/cases/arithmetic.bend \
  --image selfhost/build/phase107/native-image-user01/image.json \
  --entry bench --whole-object \
  --cache selfhost/build/phase107/native-object-cache-user \
  --out selfhost/build/phase107/native-request-user01

selfhost/build/phase107/native-request-user01/program --expect 4268337842 19 23
```

Compilation never executes the resulting program. The shared runner accepts
unsigned arguments, optional `--repeat N` and `--expect U32`; with an expectation,
every result is checked before accumulation. Do not use repeated checksum equality
alone as the correctness condition.

`--units` instead retains a typed graph and separate QBE functions/runtime/entry
objects. It permits unchanged object reuse across source edits. Keys contain exact
post-transformation unit text, all function signatures, runtime/entry ABI, compiler
source/image and backend/tool identities. Changed inline bodies therefore change
caller keys. Whole-object keys contain the complete IL and the same image/tool/ABI
identity. Both modes validate cached object/assembly hashes and rebuild corruption;
cached artifacts are copied into the fresh result directory for inspection.

The output includes QBE IL, assembly, objects, executable, method snapshots and
`report.json` with exact commands and clocks. `--units` includes `program.json`;
whole-object reports explicitly state its omission. Filenames are hashed to
support long valid function identifiers. Fresh output directories are required;
only the explicitly supplied cache directory is reused.

## Inspect output without invoking backend tools

`run.py` authenticates the same image and Base/cache identities, then invokes only
the native frontend. Select `json`, `qbe` or `units`:

```sh
python3 selfhost/tools/performance/phase107/frontend/native/run.py \
  selfhost/tools/performance/phase107/cases/arithmetic.bend \
  --image selfhost/build/phase107/native-image-user01/image.json \
  --entry bench --format json --policy fast --base cache \
  --out selfhost/build/phase107/native-inspect-user01
```

Use the external resource guard for measured requests. Cached Base requires exact
admitted Base/carrier hashes; its embedded stamp alone grants no trust. `--base live`
prepares the pinned Base from source and is a different timing condition.
`--verify-only` checks identities without executing the image.

## Interpret experiments

Compare complete cold requests separately from optimizer/emitter component clocks,
warm object-cache requests and generated-program runtime. Include authentication,
process startup, Base preparation, backend compilation and linking consistently.
One-time Clang acquisition is a distinct research cost; removing it from ordinary
requests does not remove it from compiler-development turnaround.

The [native IR kernel](../../selfhost/tools/performance/phase107/kernel/README.md)
isolates the same Bend passes on constructed graphs without the source frontend.
It has an exact paired JS adapter, allowing output equality before comparing
native execution with JS optimizer costs. Kernel wins do not establish complete
compiler wins or representative generated-program speed.

The experimental scope, failures and measurements are recorded in the
[Phase107 backend report](../../implementation/phase107/backend-options.md),
[IR contract](../../selfhost/tools/performance/phase106/ir/README.md) and
[native acquisition tools](../../selfhost/tools/performance/phase107/frontend/native/README.md).
Production ownership/layout, effects, task scheduling, device backends and full
self-hosting remain separate integration requirements.
