# Same Bend compiler, different execution backends

This began as a source-grounded measurement design. The root subsequently ran
the small and full hosted/native observations; see the
[Phase143 report](../../implementation/phase143/README.md). The native full
request passed in374.677s. Hosted small output passed, but the full hosted run
hit its3GiB process-tree limit after230.97s during frontend work; it supplies no
successful full-build ratio. No same-source native C image was acquired.

## Exact comparison

Use Phase142 `indexed-source02/compiler.bend`, SHA256
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`
(2,946,225 bytes), as the compiler implementation in both arms:

| Execution arm | Actual artifact | Provenance |
| --- | --- | --- |
| JavaScript under Bun 1.4.3 | `phase111/p142-indexed-api02/api.mjs`, SHA `e101d2eeb4bde661c45d3ad13c4ca02ed77583c6ed5772e0688aa3babe20016e` | Pinned upstream checks the complete exact Bend source, then `js_lib` exports the ordinary compiler operations. Its 14.413-second acquisition is already paid and is not request latency. |
| Native direct QBE | `phase111/p142-indexed-n1/program`, SHA `f23c1c05db96f3f7ad5a5a41b110e9c1d39b422c0166fc773eb79ccc82f671c5` | Qualified Phase137 N3 emits the exact current source; the aligned QBE builder links the existing Phase128 borrowed runtime. The image is experimentally acquired, not newly N1/N2-qualified. |

Both execute **Bend's compiler algorithm** and emit QBE. This does not compare
the TypeScript compiler's algorithm against the Bend compiler's algorithm. The
TypeScript implementation is the bootstrap producer of the JS image, while the
ordinary request logic stays in the same Bend source. It also does not compare
JS-generated user programs with C-generated user programs: generated output is
fixed to QBE in both arms.

Two useful inputs, kept separate:

1. Historical matched control: Phase137 `integrated-source03/compiler.bend`
   (2,701,952 bytes), expected complete QBE
   `phase130/p137-reproduce01/program.ssa`. This connects to prior full-source
   observations, but the old incremental cold-seed stage is not the ordinary
   cache-free baseline.
2. Primary current self-build: the exact Phase142 source above, expected
   `phase130/p142-indexed-emit01/program.ssa` (115,909,112 bytes), SHA
   `1dca2d0ea568b2e28db87066ed10dbef01a385f4e38dd4d18c99e1074d128643`.
   This oracle was emitted by qualified Phase137 N3. First join an actual current
   native image → current source request to this oracle; do not substitute the
   historical 372.554-second qualified-parent acquisition as the current image's
   self-build time.

The existing API already exports all five operations needed below. A new API
acquisition is unnecessary for this first comparison.

## Ordinary path and timing boundaries

Actual selected source entry chain:

```
p111_native_request                         lines 40455–40464
  read source, Base and compact carrier
  p134e_compile_source                     lines 57495–57498
    p88_cache_prepare
    p86_plan                               lines 37846–37851
    p134e_plan                             lines 57509–57512
      p111_runtime_admission
      p128raw_emit_admitted                 lines 56013–56016
        p113a_certificate
        p128raw_lower_request               lines 55927–55934
        p128raw_session_finish              lines 56005–56009
  p111_print_emission → p134w_plan
    p134e_begin                            lines 57361–57367
    repeated p134e_next                     lines 57433–57451
```

`p134e_plan` includes raw lowering, optimizations, ownership-related admission and
the final independent verifier. The observer must label this **backend
inclusive**, not assign all of it to code generation or verification.
`p134e_begin` builds IDs, registries and tables. `p134e_next` emits one piece and
an explicit legacy-newline flag. The observer writes those exact bytes without
joining the complete output or retaining a list of pieces. A very large single
function can still create a large piece; this is not bounded total IR memory.

The new observer separates Base preparation, complete frontend, inclusive
backend, registry and Bend cursor calls. Source/Base/carrier reads, API import,
UTF-8 encoding, file writes/close and digest work each have separate intervals.
Render-loop time contains the cursor, encoding, write and hash intervals;
**do not add inclusive loop time to its children**. Child wall time remains the
end-to-end observation and includes its real observer/JIT/GC overhead. The script
does not silently subtract hashing to advertise a faster runtime.

Both arms use the authenticated Phase130 compact carrier and exact Base path,
bytes and stamp. The launcher reuses `phase130/native-request.py`'s original
Phase88/compact-inverse authority. It joins complete streamed byte comparison,
count and digest to a successful child exit. No output normalization is allowed.

Use one controlled CPU3 lane, no diagnostic preload, the same output medium and
fresh processes. A preliminary small matched source can expose ABI/output errors
before the full source. The first full pair establishes a large effect; only
repeat if noise or the decision boundary justifies the additional several-minute
native run. JIT code generation and JS garbage collection are properties of the
JS execution arm, not missing costs to hide. Peak RSS and user/system CPU belong
in the comparison too. Compiler acquisition and the output's QBE/as/link build
are separate costs; identical emitted QBE permits one explicitly shared machine
build observation rather than two redundant builds.

## Ready method

[`hosted-request.py`](../../selfhost/tools/performance/phase143/hosted-request.py)
authenticates the exact checked API/compiler/input/Base/oracle, supervises Bun
with a timer plus blocking `wait4`, kills/reaps its process group on timeout, and
records CPU/RSS. [`hosted-stream.mjs`](../../selfhost/tools/performance/phase143/hosted-stream.mjs)
only calls the checked API and transports bytes. The existing Phase111 guard
provides process-tree memory limits and a sufficiently large per-file limit.
See the [reproduction command](../../selfhost/tools/performance/phase143/README.md).

The implementation has a 512 MiB output/2,000,000-piece bound and 64 MiB maximum
individual encoded piece, in addition to the outer guard. Source and Base are
bounded to 16 MiB. The known current output is about 116 MB, so the older 64 MiB
file guard is unsuitable. No long-lived session cache is retained in this method.

## Native C: useful additional arm, not an existing same-source baseline

The mature C/Clang route is real: `selfhost/tools/native/selection.json` still
binds qualified Phase102 B1/B2 images for source
`63ef222c…a237` (1,788,947 bytes). That is not today's source, so running that
old executable and calling it the C version of Phase142 would confound algorithm
and backend changes.

Historical Phase102 build guards show 195.176 seconds / 4.281 GB peak tree RSS
for B1 and 374.033 seconds / 2.602 GB for B2 at Clang `-O2`. These are different
old acquisition paths, not a current-source estimate or a fair backend timing
pair. They establish that a fresh C arm is a minutes-scale acquisition with
material memory cost. Do not extrapolate a current build time from source-line
ratios. Preserve the existing 16 GiB available-memory floor and bounded build
lane if it is attempted.

The lowest-dependency acquisition route is to load and independently check the
**exact current source** with the same pinned upstream and emit C using its
existing `C.compile_book(book)`, then build with pinned Clang. The source is not
rewritten, and the resulting executable still runs Bend's QBE-emitting compiler.
The old `phase86/acquire.mjs` assembles an old entry and must not be used
unchanged. Further inspection found an existing exact-file route:
`phase102/acquire-native.mjs SOURCE FRESH_PHASE102_OUTPUT` already checks the
explicit input and emits C without assembling that old entry. No new acquisition
compiler is needed. A future guarded acquisition can pass
`selfhost/build/phase142/indexed-source02/compiler.bend` and a fresh
`selfhost/build/phase102/p143-same-source-c01` directory to that method.
Its historical smaller-source TS emission peaked near2.394GiB; the historical
Clang B1 build peaked3.987GiB. Current costs remain unmeasured, so acquisition
was deferred under this campaign's3GiB cap.

For either C acquisition, first check `IO.args`/the entry sentinel, File writing
and one small exact-QBE request. Current `p111_native_args` has precise six-field
ordinary and separate session patterns; historical B1/B2 wrappers differ in
their argv sentinel. Source inspection confirms that upstream C retains argv[0]
in `IO.args` (`comp.ts`5934–5946 and `effs/args.c`). Its ordinary request is
`C_IMAGE --threads 1 --gpu off -- SOURCE BASE cache CARRIER STAMP`, without a
`phase111` sentinel. The current Phase130 launcher hardcodes that sentinel and
needs an explicit C-launch observation variant; changing compiler logic is
unnecessary. Ordinary File open/read/write/close effects are present.
After the small independent byte-output gate,
compare the same current source and complete QBE oracle. No new runtime, C
backend, or full self-hosting campaign is required merely to answer whether a
C-built compiler image executes this workload much faster.

Recommendation: run the already available JS/Bun versus direct-QBE ordinary
comparison first. Acquire a same-source C image only if the result leaves a
concrete question about native representation or code generation. Its several-
minute acquisition should be justified by information value, not treated as a
prerequisite to profiling an image that already exists.
