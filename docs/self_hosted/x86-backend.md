# x86-64 backend architecture

For the maintained `--target x86` interface, current ABI11102, source profile,
builds, bootstrap, benchmarks and profiling, use [ASSEMBLY.md](ASSEMBLY.md).
The Phase181 results and commands below describe the original experimental
ABI11101 implementation. They remain historical evidence and are not the
current build interface or qualification authority.

Phase181 adds a Bend-written AMD64 SysV assembly emitter beside QBE. It reuses
the maintained frontend, native lowering, final verification and runtime.
The [Phase181 report](../../implementation/phase181/README.md) owns exact source
identities, image receipts, executed controls and qualification decisions.
This backend does not change the installed compiler or production target selector.

The selected register/direct-call emitter passes 17 machine-function controls,
10 namespace-hygiene observations and nine existing source/output controls.
The extracted parser/checker takes 17.14 s versus QBE's 8.31 s in the paired
comparison (2.06×). The earlier stack-home version measured 18.74 s versus
7.92 s in a separate cohort. Consult the report for exact clock boundaries,
native reproduction evidence and qualification limits. These observations do
not establish a full-build speedup or qualify later source edits.

The semantic input is the actual checked program retained by `P169Prepared`:
`N111Segment` bodies, `P113DFunction` bodies, IDs and explicit data tables.
`P169Prepared` itself is not a certificate. The request entry obtains it through
the unchanged `p169n_compile` admission path. No QBE text, C expression or Nx
program is parsed to recover semantics.
The shared preparation still constructs a legacy QBE forwarding-text list
which this emitter discards. Avoiding that residual work is a future cleanup;
the current claim is removal of the QBE machine stage, not all QBE-specific
work in preparation.

Modules live under [`selfhost/src/back/x86/`](../../selfhost/src/back/x86/):

| Module | Responsibility |
| --- | --- |
| `model.bend` | Per-function placement, emission results and shared interfaces. |
| `frame.bend` | Stable local homes, aligned buffers and outgoing argument space. |
| `scalar.bend` | Integer instructions, typed memory operations and runtime calls. |
| `regalloc.bend` | Select up to four frequently read locals for distinct callee-saved registers; no register sharing or stack compaction. |
| `function.bend` | Branches, direct calls, multiple results, tail loops, prologues and reserved-name checks. |
| `program.bend` | Actual private/public bodies, import forwarders, ABI data and process entry. |
| `stream.bend` | One stdout file handle; one function or at most 128 data directives per emission step. |
| `entry.bend` | Explicit native request protocol and checked preparation. |

The machine contract remains [runtime ABI11101](../../selfhost/src/runtime/qbe/runtime.h).
Public `p111_<FID>` segments receive one borrowed state pointer and return a
64-bit runtime reply. The runtime dispatch loop owns scheduler transitions:
`p111_rt_jump`, `p111_rt_return` and `p111_rt_apply` update state and return to it.
Original continuation frames, closures, ownership operations and effects remain
runtime operations unless they were already transformed in the verified bodies.

Private `p113d_<FID>` functions receive state followed by 64-bit arguments.
One result returns in RAX. Multiple results add an output pointer immediately
after state, store ordered eight-byte words there and return status zero.
`P113DAgain` snapshots the old argument vector before updating parameter homes;
it preserves the hidden result pointer and jumps to the function's local loop.
SysV register preservation, stack alignment and spilled arguments apply to both
runtime imports and private calls. U32 operations truncate and zero-extend;
comparison signedness follows the declared operand width. Semantic locals with
the `__x181` prefix refuse before hidden buffers or parameters are introduced.

Program emission preserves table order, IDs, capability bits, constructor hot
flags, static Term words, UTF-8 names and relocations. `p111_fid_results` contains
incoming continuation widths, not each segment's result count. Exported `main`
passes argc, argv and `p111_program` to `p111_rt_main`. Literal public adapter
bodies already call their private workers. Eligible imported `p112w_` symbols
are reconstructed as ABI-preserving forwarders; unresolved legacy references
refuse instead of silently dropping a required worker.

The first emitter does not reproduce QBE's late fusion, lookup, packed-array,
borrowed-field, transport or arithmetic peephole templates. It emits the checked
operations and their runtime fallback calls. Capability authority still comes
from the original checked plan. Omitting a late optimization is not permission
to erase ownership calls, adapters or transformed private workers. Machine code
and performance therefore differ from QBE; equal execution observations and
backend-specific reproduction checks are separate gates.

Run the following illustrative commands from the repository root, choosing
fresh output paths. The Phase181 source assembler reads the maintained manifest
and explicit x86 modules, then extracts the native entry without modifying the
production manifest. Assembly is metadata work, not source checking:

```sh
python3 -B selfhost/tests/phase181/assemble.py \
  --out selfhost/build/phase181/example-source01
selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs \
  --source selfhost/build/phase181/example-source01/compiler.bend \
  --out selfhost/build/phase181/example-source01/check
```

Use repeated `--export NAME` options for a hosted API instead of the native entry;
additional `--module PATH` options can supply explicit test fixtures. Source/API
checking and native image acquisition remain separate steps in the
[maintained workflow](workflow.md). Set `X86_IMAGE_RECEIPT` to an authenticated
receipt for an image that actually implements the `phase181-x86` entry; the
source assembly above does not create that image.

```sh
python3 -B selfhost/tests/phase181/native-build.py \
  --image-receipt "$X86_IMAGE_RECEIPT" \
  --binding selfhost/build/phase181/example-source01/base-binding.json \
  --source selfhost/tools/performance/phase113/controls/fixtures/tail-argument-permutation.bend \
  --expected selfhost/tools/performance/phase113/controls/expected/tail-argument-permutation.stdout \
  --seconds 120 --out selfhost/build/phase181/example-program01
```

The build adapter invokes the native Bend emitter, assembler and linker with the
recorded runtime/tool policy; there is no QBE machine stage. Use the ordinary
outer resource guard and retain its receipt. Streaming can leave partial bytes
on failure: only a successful build receipt with unchanged inputs admits the
artifact. A successful program build is not native self reproduction or promotion.
