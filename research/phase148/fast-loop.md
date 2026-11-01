# Phase148: validate a compact function pipeline without rebuilding the compiler

Status: read-only preparation. No compiler, benchmark, generated program, or
profiler was executed for this note. No production source or tests were changed.

Start with the retained Map and compiler function packets, use Lexer as the
transfer case, and build a small executable containing **both current and compact
paths**. Charge conversion, every selected consumer, complete text construction,
writing, and destruction to the candidate. A fast lookup alone is not the result.
Do not build another full compiler image until this complete-region experiment
shows a substantial, repeatable benefit.

## Exact reusable inputs

The retained capture is
`selfhost/build/phase147/verifier-capture01/report.json`, SHA256
`e8d7443edec2c32013712d99feda52c5ba4c5fceefd4eb822128464dd397a9c3`.
It was produced by a checked Bend API from frozen source `00940ed5…`, before
Phase147 integration. Its original verifiers accepted the full lowered input
before selection. These are real compiler-produced inputs, but they must retain
that historical source identity when reused.

Each packet keeps six whole `N111Segment` bodies, six whole `P113DFunction`
bodies, **all** original raw/direct metadata headers, and all constructors.
Selection was the two largest branch counts plus a declaration-order spread.
The bodies are not shortened to fit a timing budget.

| Packet in `verifier-capture01/` | Headers: raw/direct/constructors | Selected raw statements/branches | Selected direct statements/branches | Bytes |
| --- | ---: | ---: | ---: | ---: |
| `compiler-verifier-slice.json` | 1099 / 51 / 185 | 642 / 37 | 856 / 33 | 486,235 |
| `coverage-map-churn-128.json` | 666 / 34 / 150 | 3112 / 117 | 291 / 13 | 874,606 |
| `lexer.json` | 265 / 31 / 161 | 429 / 25 | 922 / 35 | 340,672 |

Their respective SHA256 identities are
`dcce1bcbb1b80fbf08e088a4126c76409b1d20d39f3a0b4f54a6facc3209d096`,
`7328cfa76cae0cc87fd4fe305d74804c19c17e04cff59e4b3df44d55fc03b1a8`, and
`99137adbb25a54d6390f4783f91c2fa1d0e117ce1289ab83316ac7b644218b37`.

Particularly useful complete bodies are:

- Map raw index328, `$direct.Map.ins.go`: 2,037 statements, 76 branches,
  531 calls; index176, `$direct.Map.seek.go`: 1,037 statements, 41 branches.
- Compiler raw index523, `$direct.p111v_value`: 267 statements, 19 branches;
  direct index43, `$direct.index_find`: 455 statements, 17 branches.
- Lexer raw index138, `$direct.step.at`: 314 statements, 18 branches;
  direct index25, `$direct.step.at`: 403 statements, 15 branches, and index26,
  `$product.step.at`: 367 statements, 15 branches.

The compiler workload is the 37,696-byte dependency-closed original verifier
workload in `verifier-baseline02/compiler-verifier-workload.bend`, not the full
canonical compiler. Map and Lexer originate from complete ordinary benchmark
sources in `selfhost/tests/consolidation/native-broad/`, but their packets still
contain only the selected bodies. They cannot support a claim about complete
program optimization or lowering from the frontend term representation.

## Pin the baseline and oracles separately

Use the **current Phase147 integrated implementation** as the performance
baseline, not the slower pre-Phase147 verifier or renderer. The source is
`integrated-source03/compiler.bend`, SHA256 `0f3bd8a0…19227eaf`.
The current private admission entry is `p147d_function`/`p147d_functions` in
[`verify-compact.bend`](../../selfhost/src/back/qbe/verify-compact.bend).
The original `p111v_segment` and `p113e_function` remain independent correctness
oracles. Do not substitute private compact admission for the original final
verification boundary.

Before consuming old packets with current source, compare the required model
declarations and literal constructor fields against their frozen capture source:
[`model.bend`](../../selfhost/src/back/qbe/model.bend) defines `N111Type`,
`N111Value`, `N111Arg`, `N111Stmt`, `N111Segment`, `N111Ids`, `P113DStmt`, and
`P113DFunction`. Constructor names alone do not establish ABI compatibility.
Preserve the packet bytes and re-run both original verifiers on the selected
functions with their **original ordered ready-signature context**.

There are already **18 exact complete raw-function QBE text oracles** in
`selfhost/build/phase147/render-selected01/controls/report.json`. The report
binds original and Phase147 renderers and their complete `.ssa` output bytes.
It includes the large Map function's 127,386-byte output and compiler/Lexer
branching functions. Reuse those bytes; do not replace them with lengths or
checksums. The smaller three-function fragment-render set alone is insufficient:
its selected examples do not exercise these large branching bodies.

There is **no equivalent retained direct-function text oracle in these APIs**:
the frozen verifier API does not export `p113e_private`, and the selected renderer
API exports only raw rendering. Acquire a small checked reference API containing
the unchanged direct renderer, freeze all 18 direct complete outputs once, and
pin it before changing the compact implementation. This is a one-time missing
oracle acquisition, not a reason to recapture the frontend or rebuild B1/N2.

The fixed verifier cases in `selfhost/tests/phase147/verifier-cases.json` and
`verifier-cases-extra.json`, their 60+16 controls, and numeric controls remain
independent expected data. Preserve exact diagnostics and ordering, not only
accepted/rejected booleans. Add focused representation laws for nested branches,
shared names, differing argument widths, terminal/result/again nodes, zero-length
lists, unknown symbols, and failed conversion with retained source state.
Malformed IR may be inspected by pure verifier functions; never execute it.

If the design later changes lowering or optimization decisions, exact text is no
longer the only possible semantic criterion. That is a separate experiment with
whole-program independent outputs and fresh qualification, not permission to
relax this representation-preserving screen.

## One complete region, with honest boundaries

The first implementation should transform existing complete function IR. It must
not claim to accelerate frontend lowering merely because a smaller IR consumer
is fast. Define a per-family protocol with runtime-selected `old`/`new` mode,
input family, output mode, and repeat count. One binary contains both modes.

For each measured iteration:

1. Obtain the same complete captured functions and global metadata in both modes.
   Build metadata and ordered ready signatures at the same lifetime boundary.
   If production keeps them for a whole program, amortize them over the same
   twelve selected functions in both paths; also report the complete batch cost.
2. Old mode runs the current complete-function consumer chain. New mode converts
   each complete function into the proposed representation, runs the corresponding
   consumers, and performs any required conversion back. Conversion must occur
   inside the measured repetition, not once in preparation.
3. Include more than one real consumer: current admission, the ownership/scalar
   eligibility walk (`p118z_scalars` or `p118z_direct`), and complete rendering
   (`p111q_segment` / `p113e_private`). Match booleans, diagnostics, ordered
   signatures, and resulting text. Additional optimization passes belong in the
   chain only if their complete required inputs are available.
4. Preserve every independent final check that the proposed production path
   would execute. If a legacy checker needs reconstructed IR, charge that
   reconstruction and check in the same region. A private numeric table cannot
   act as a certificate for a new compact body by name or header identity alone.
5. Materialize the whole output String and perform one checked `File.write` per
   function, followed by the same cleanup and `File.close`. The compact state,
   original retained state, intermediate text, and errors must die within the
   repeated region or its measured process teardown. Do not hoist candidate
   conversion, delay destruction until an untimed phase, or share the candidate's
   private structures across repetitions when the old path cannot do so.

Use three observations, kept separate: correctness (`oracle`, one repetition,
complete stdout); the primary whole region (`bench`, output to `/dev/null`);
and optional component ablations. Oracle output should concatenate complete
functions in manifest order with an unambiguous separately frozen framing rule.
Check full stdout, empty expected stderr, and exit status. The benchmark preserves
the same materialization/write work; no extra `String.length`/checksum traversal
should dominate it. Zero-repeat startup and two positive repeat counts check
transport and scaling, but startup time is reported, never subtracted.

These are separate-region scalar/verification/render consumers, not a complete
compiler pipeline. If the proposal needs full function-call bodies or a global
optimization fixpoint, the existing headers cannot supply them. Add a newly
checked larger capture deliberately, rather than interpreting missing bodies as
empty implementations or silently reducing the work.

## Checked API first, then native ownership and cleanup

Prepare a dependency-closed current-source test image with the maintained
[`source.py`](../../selfhost/tools/build/source.py) declaration parser, a small
explicit dependency-closure preparer, and
[`hosted.mjs acquire`](../../selfhost/tools/build/hosted.mjs).
The Phase147 preparer is a useful recipe, but its pre-integration `candidate`
command must not be replayed blindly against the new recipe: the compact verifier
already exists. Keep the last selected declaration bodies and do not add a second
copy or weaken checked acquisition to make extraction pass.

Use upstream `059266225b77c8ca256ac6b25ee5c21449bab151` explicitly for the small
checked API. JS only transports constructors and compares complete observations;
it must not implement conversion, verification, or compiler semantics. Validate
full encode/decode equality, all independent diagnostics, immutable input reuse,
consumer observations, and complete raw/direct output bytes before native timing.

Then build the small dual-mode harness using maintained
[`native.py`](../../selfhost/tools/build/native.py) with:

```text
--assets selfhost/manifests/assets-native.json
--host native --stage N2 --target qbe --mode cache
--image selfhost/build/phase147/integrated-sequel02/n2/program
--image-receipt implementation/phase147/candidate.json
--source FRESH_PHASE148_HARNESS.bend --out FRESH_NATIVE_BUILD
```

The explicit qualified producer is `ab5662a1…27ca32`; using `--image-key qbe-n2`
alone would select the older installed image. Link the unchanged pinned QBE
runtime object `2d078323…8e493a3` from the asset manifest. Keep its standard
`--threads 1 --gpu off -- ...` transport. The runtime omits `argv[0]` from
`IO.args`; choose and test an explicit harness sentinel instead of inheriting the
Phase147 initial argument-count mistake. `File.write` returns the new `File`
and `Result`; failures must propagate, close the file, and fail the oracle.

Keep raw state-pointer and direct ABI rules intact: the private verifier's current
state/scratch capacities are 2088/2048 bytes, direct parameters are bounded at255,
and results at1–8. The harness is not authority to enlarge those limits, remove
pointer checks, or run malformed generated code. JS success alone does not test
native affine sharing, reference counts, or destruction.

## Fast scheduling and explicit budgets

Root owns one serial CPU3 target lane. Every new job gets one outer maintained
disk guard with fresh declared roots, the 5GiB reserve and 16GiB available-memory
floor. Use ordinary 2GiB RSS initially, with measured justification for more.
Keep build/control/timing receipts separate; do not nest guards.

Actual Phase147 precedents, not Phase148 promises:

| Existing operation | Observed elapsed |
| --- | ---: |
| Candidate04 small checked API | 2.19 s |
| Dual-mode Lexer native build | 15.56 s |
| Dual-mode compiler-slice native build | 17.73 s |
| Dual-mode Map native build | 22.72 s |
| Four alternating native timing pairs, including controls/calibration | 1.60–4.43 s per family |

Those native runs measured the complete verifier region only. Adding conversion,
additional consumers, and rendering can increase both code size and execution.
A practical first budget is **30–90 seconds per changed family**, estimated:
small checked controls, one native harness build, and four alternating pairs.
Allow a 180-second outer build limit with a 256MiB disk budget, and a separate
45-second timing budget with a64MiB output budget; report a refusal/timeout instead
of silently shrinking bodies or removing cleanup. Tighten limits after observing
the first complete pipeline. This is still far cheaper than a full compiler build.

Run Map first for large branch-heavy input, then compiler slice; hold Lexer back
until the mechanism survives both. Initially use one family per binary to bound
build cost; each binary still contains both modes. If combining all three reduces
measured acquisition cost, do that once—not on an assumption that a bigger
multi-family executable is automatically cheaper.

Calibrate both modes to at least100ms, use four alternating pairs, retain every
sample and startup observation, and verify all outputs. Extend once to eight pairs
only for a decision close to the noise range. A provisional architectural gate
should require at least20% complete-region improvement on two families with no
material transfer regression, plus a meaningful absolute/full-profile opportunity.
This is a proposed decision threshold, not measured speedup. If conversion erases
the saving, reject the representation boundary before a full-image campaign.

## Receipt reuse and the final integration boundary

Reuse retained fixture bytes, their source/capture pins, independent raw-render
outputs, and the immutable reference APIs. Re-run only the changed candidate's
checks and the same-binary baseline/candidate pair. Old timings are feasibility
and cost information, never interchangeable clean samples for a new binary.
An exact generated product can reuse its old machine-build receipt only when
the current product bytes, runtime/toolchain/build flags, binary, and original
oracle captures are independently authenticated. Preserve the old producer
identity; do not relabel an old receipt as a fresh build or skip candidate work
while claiming a clean build improvement.

If profiles are needed after a complete-region win, use maintained
[`tools/profiler`](../../selfhost/tools/profiler/README.md) with the **new harness's**
ELF, QBE, FID/owner map and unwind table. Never apply the full compiler's maps to
this executable. Allocation/keep/drop counters and stage captures are diagnostic,
separate from clean timing. Existing stage modes observe first/once boundaries,
not every repetition; do not sum repeated or overlapping stage intervals. Force
only test-boundary observation if needed and validate its output and marker
quality before attributing cost.

Only after the compact region wins should production integration pay for a fresh
source check, N1/N2/self-reproduction, independent ordinary corpus output checks,
complete QBE/object comparisons where behavior is unchanged, and a matched full
cold-build measurement. Lexer and Map whole-program outputs remain independent
`1822208108\n` and `3714872484\n` in the maintained native-broad corpus. The current
61-program QBE/object identity receipt is a baseline, not inherited approval for
new compact code. Partially rendered selected functions are not standalone
executables and must not be passed off as that whole-program qualification.
