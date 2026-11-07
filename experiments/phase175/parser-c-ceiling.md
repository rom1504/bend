# Exact frontend source through pinned upstream C: acquisition audit

Source-only audit; no target run and no compiler/source/runtime changes. The
prepared commands and pins are in `parser-c-ceiling-plan.json`, with a directly
consumable maintained-emitter spec in `parser-c-ceiling-upstream.json`.

## Cheapest independent route

Use existing **`selfhost/tools/bench/upstream.mjs`**, not a recovered historical
emitter. It consumes a `bend-benchmark-reference-request-v1` JSON file and calls
unmodified pinned upstream `book_load`, `book_valid`, requires zero holes, then
`Comp.compile_book`. The spec pins all 81 relevant source/tool/provider inputs;
the checkout was checked against `059266225b77c8ca256ac6b25ee5c21449bab151` with
no `bend2` changes. It clears inherited BEND variables. The root must additionally
retain its normal clean environment, CPU3 lane, timeout and resource guard.

The **identical source bytes** are
`selfhost/build/phase175/baseline-source03/compiler.bend`: 656,302 bytes,
SHA256 `351ad0e69554e5b12cf8367d5cdde648ab5a1787825614e23158196f5d0e851b`.
The already-checked hosted API took 6.302s to acquire from these same bytes;
the QBE native image took 53.474s to construct. Neither predicts Clang cost.

Inside a fresh guarded output directory, the exact emission command is:

```sh
selfhost/.assets/bin/bun selfhost/tools/bench/upstream.mjs \
  experiments/phase175/parser-c-ceiling-upstream.json \
  selfhost/build/phase175/upstream-c-ceiling01/emission.json \
  > selfhost/build/phase175/upstream-c-ceiling01/program.c
```

Require exit zero, empty stderr and `complete=true, checked=true`. Source
checking is ordinary upstream checking, not an independent BendTT proof of the
compiler or a guarantee of C backend correctness. No no-check mode is needed.
The historical Phase102 emitter has been retired from the working tree; its
receipts remain useful evidence but it should not be an operational dependency.

Use the maintained C toolchain policy, **Clang `-std=c11 -O3`**, with
`-isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang`,
`-lpthread -lm`. The exact pinned Clang command is in the plan. This C includes
the upstream runtime emitted by `comp.ts`; do not link our QBE runtime object or
substitute our C runtime. No GPU macro or parallel execution is enabled.

## Preserve the actual Bend argument list

The source's `p175fn_args` requires exactly:

    ["phase175-frontend", mode, input, Base, carrier, stamp]

Upstream `comp.ts:5938` sets `io_argv=argv, io_argc=1`, retaining argv0.
Our runtime instead starts at argv+1 with zero arguments. Therefore:

- QBE: ordinary binary argv0; flags `--threads 1 --gpu off --`, then the six
  positional values above, including the sentinel.
- Upstream C: use **argv0 `phase175-frontend`**, flags
  `--threads 1 --gpu off --`, then only the remaining five values.

Existing `selfhost/tools/profiler/run.py:execute` already supports an explicit
`argv0` using subprocess `executable=...`; no source wrapper is necessary.
Its recorded command/argv0 make the difference reviewable. All paths and the
stamp stay byte-identical. Do not modify the main function or copy the QBE
argument list blindly.

`native-frontend.py` intentionally requires matching QBE runtime/toolchain
receipts. Do **not** counterfeit a `bend-native-build` receipt or weaken that
same-runtime check. A bounded host observation can use the existing profiler
execution primitive and validate the same stdout and timing-stderr grammar.

## Cost estimate and stop rule

There is no measured C acquisition of this 656 KB source. An initial planning
range is **roughly 1–3 minutes for emission plus Clang**, with large uncertainty;
it is not a linear source-size prediction. Root selected a stricter decisive
screen: **175s total inner deadline, 180s outer, 2GiB RSS, 256MiB disk**, with a
16GiB available-memory floor. Emission is capped at45s, Clang at80s and execution
uses the remaining total. Retain a resource refusal rather than silently
expanding the budget. `parser-c-ceiling.py` implements only orchestration using
the maintained reference emitter, pinned Clang and existing profiler execution
primitive; its Python syntax was checked without executing any target.

```sh
python3 -B selfhost/tests/phase175/job.py --rss-mib 2048 \
  upstream-c-ceiling01 180 256 \
  python3 -B experiments/phase175/parser-c-ceiling.py \
  --out selfhost/build/phase175/upstream-c-ceiling01 --seconds 175
```

The script writes a real `phase175-exact-source-upstream-c-diagnostic` receipt,
never a QBE native-build receipt. `--emit-only` supports stopping after emission
and the textual ABI census. Compilation warnings are retained rather than
normalized away. Root authorized one full-source/digest observation for this
bounded diagnostic; that is weaker than broad semantic qualification and is
explicitly labeled as such.

Retained scale points explain the uncertainty:

| Work | Result |
|---|---|
| Same 656 KB frontend, upstream checked JS API | 6.302s; excludes C emission/Clang |
| Same source, installed compiler → QBE executable | 53.474s |
| Phase144 2.986 MB full source → upstream C | 88.332s supervised, 32.975 MB C, ~4.47GiB peak RSS |
| That full C → Clang O2 | Stopped at 6GiB after 104.302s |
| That full C → Clang O1 | Also stopped at 6GiB after 103.464s |
| Phase103 upstream bridge → Clang | 191.22s, 4,242MiB, different source |

After emission, inspect `WL_SIG` register/formal-argument count and `WL_TABLE`
segment count before machine construction. Phase144 had 21,973 segments × 219
formal parameters: about 4.81 million slots before call operands. A similar
explosion here would reject this as a cheap diagnostic. Lowering Clang to O1
already failed to rescue the older case; do not repeat a flag sweep. An arity
refusal or guard failure is a valid acquisition result, not permission to alter
the compared source.

## What the comparison would establish

Use identical Phase170 full-source input and the same Phase175 Base/carrier
binding as `frontend-full-baseline01/report.json`. QBE measured 60.509s inside
the frontend clock and 68.874s whole process, including 8.081s structural
observation. Preserve all three clocks and complete stdout; do not compare C
frontend time against QBE whole-process time.

Before the expensive input, validate ordinary small positive and failure cases
against the independent hosted full-value controls and QBE observations. The
large source's digest is supplementary, not semantic equivalence proof. A
faster C result demonstrates execution/code-generation/runtime headroom for
**these same Bend algorithms**. It does not isolate Clang from representation,
scheduler ABI, ownership or runtime effects, and is not a new compiler release.

An alternative exists through our retained checked Phase152 C API:
`selfhost/tools/build/request.py --host js --target c --stage B1 --mode live`,
explicit `--image selfhost/build/phase152/composite-api01/api.mjs` and its
`--image-receipt .../report.json`, same input source, then the same Clang policy.
It avoids acquiring a new emitting compiler, but measures an older self-hosted
C backend and its runtime. It may also have substantial C emission/build cost.
Prefer upstream first for the clean independent question; do not acquire both
unless the first result creates a useful distinction.

## Executed outcome and diagnostic correction

The pinned source emitted 11,871,272 C bytes in 30.256s. Clang exceeded its
80-second construction budget; there is no C executable or execution-speed
result. The original ABI count fields contain a regex bug: their zero counts
are invalid. A source-only recount finds 43 Term formal parameters and 7833 WL_CASE lines;
see [corrected census](parser-c-census-correction.json). This is textual structure,
not a profile or evidence of a dynamic speed ceiling. The original failed
receipt remains unchanged.
