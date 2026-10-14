# Native execution of the compiler

[Design](../../../../design/phase86/native-compiler-host.md) ·
[Investigation](../../../../implementation/phase86/README.md).

The experimental compiler is the current manifest's Bend source plus
`entry.bend`, fully checked and emitted to C by upstream0592662. Its output is
also C. Upstream is used at bootstrap time; native requests do not call Node or
TypeScript. The JS sibling executes the same entry and core, with the existing
primitive-string equality compatibility guard recorded as a separate derivative.
Neither artifact is native B2 or an installed release.

The investigation stopped short of promotion: native Map reaches a sharing
fail-stop, Lexer is much slower, and Base startup remains uncached. `acquire08`
is the final checked image. Do not mistake the proposed three-round five-source
campaign below for a completed qualification. `followup01` repeats four successful
sources once each for five calls and deliberately reports no broad average.

## Scope and clock contract

The pilot accepts one module importing Base, with only Base args/print/now
foreign effects. `compare.py` authenticates exact Base/effect bytes before
enabling the private checked-native path. General import discovery, arbitrary
foreign files, detailed located diagnostic replay, public trust reporting,
source-edit sessions and persistent disk caches remain outside this pilot.

Both experimental hosts read source/Base before preparation. Bend checks
and prepares Base once in memory, then reads the five authenticated runtime
chunks into `NE_Parts`. The original scanner-based image is retained as evidence.
The request
timer includes source processing, checking, report, annotation/layout validation,
effect reading/conversion, C emission and complete output/verdict traversal. It
excludes preparation and C file publication. Every successful call writes
`OUTPUT.N.c`; millisecond `IO.now` measurements stay separate from the guard's
complete process clock. Repeating five calls includes no hidden warmup or result
memo. JS preparation already exercises frontend functions: this is a prepared
session, not the installed host's first request from its disk cache.

Ordinary B2 and handwritten TypeScript are additional context controls, with their
existing host/cache/clock policies. They are not scope-identical host comparisons.
All emitted native/JS-sibling C must match an independent ordinary B2 oracle.
TypeScript emits different C and has its own output identity.

## Acquisition and fast loop

Run from the repository root with Node24.18.0 and the pinned upstream checkout.
Use a fresh output directory for each attempt. `freeze-upstream.py` and
`fixtures.py` create immutable initial inputs under `selfhost/build/phase86` and
refuse replacement; reuse only after identity verification or restore the evidence
capsule. `acquire.mjs` verifies that exact upstream snapshot before using it.

```sh
python3 -B selfhost/tools/performance/phase86/freeze-upstream.py
python3 -B selfhost/tools/performance/phase86/fixtures.py
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase86/NEW-acquire-guard --seconds 180 --cpu 2,3 -- \
  /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --max-old-space-size=1024 --stack-size=4096 \
  /absolute/repo/selfhost/tools/performance/phase86/acquire.mjs \
  /absolute/repo/selfhost/build/phase86/NEW-acquire
```

The checked build saves assembly, source map, original entry, complete raw C/JS,
input hashes, phases and failure diagnostics. C acquisition and Clang compilation
are separate. Current raw upstream JS needs the separately recorded
`js-compat.mjs BUILD NEW_DERIVATIVE` String-equality guard for the full Base source.
Its diagnostic image preserves exception stacks; do not time that image.
`node-files.cjs` supplies the upstream runtime's file-read syscall hook on Node,
where the default effect otherwise requests Bun FFI; it contains no compiler work.

Compile saved `compiler.c` under `guard.py` using the pinned Clang22.1.4,
`-isystem .../include/clang -std=c11 -O2 -lpthread -lm`. Retain the complete guard
receipt and bind the successful binary before comparison:

```sh
python3 -B selfhost/tools/performance/phase86/bind-native.py BUILD GUARD BINARY
python3 -B selfhost/tools/performance/phase86/prepare-runtime.py NEW_RUNTIME_DIR
python3 -B selfhost/tools/performance/phase86/compare.py \
  --build BUILD --binary BINARY --js-image DERIVATIVE/compiler.cjs \
  --runtime-prefix NEW_RUNTIME_DIR/runtime.c \
  --out NEW_SCREEN --cases small --roles native,js,b2 --calls 1
```

Expand only after output equality: `--cases
small,functions65,numeric_closed,map_closed,lexer_original,unicode`, then
`--rounds 3 --calls 5 --roles native,js,b2,typescript`. The numeric/map pilot
files append small main entries to unchanged existing workload bodies; they are
not the imported Phase85 batch sources. Negative controls are `type_error`,
`parse_error`, and `extra_import`; expected refusal remains a nonzero receipt.
The original `extra_import` is invalid syntax and only exercises parser refusal.
Run `extra-fixture.py` for the separate `extra_import_valid` case: its real second
module is accepted by ordinary B2 and deliberately refused by both pilot hosts.
Use `--keep-going` for these negative controls. Ordinary comparisons stop at the
first failed worker. A cancelled earlier lane and its incomplete guard receipt
remain in the evidence; unfinished timings are not invented or included in the
account's measured occupancy sum.

Targets are serial, CPU3 for timing,2GiB RSS and4GiB available floor. Acquisition
uses CPU2,3 explicitly. The native runtime is fixed to `--threads 1 --gpu off`.
Large compiler-image Clang builds have separately recorded bounds; the initial
2GiB and3GiB attempts were stopped by the guard. The final investigated build
ceiling is6GiB, allowed only with a16GiB available-memory floor. This does not
change runtime limits. No small virtual-memory limit is used: upstream reserves
large uncommitted mappings. Guarding is polling, not a kernel hard RSS limit.

`summarize.py --out NEW_JSON` verifies saved C hashes, joins native/JS outputs
to independent B2 controls across lanes, rejects missing or differing oracles,
and derives timing medians/resource accounting offline. Run it only after all
guarded targets finish. `runtime_prepare_ms` measures chunk IO/materialization,
not raw-template scanning, for acquire07 and later paired lanes.
Failed attempts, all preparation costs and compiler-build cost remain evidence.

## Native fail-stop diagnostic

`exit-trace.c` builds a small `-shared -fPIC -O1` library. A guarded run sets
`LD_PRELOAD=/absolute/path/exit-trace.so` only for the experimental executable.
It prints a stack on `_exit`, then preserves the status through `exit_group`.
The native compiler binary stays byte-identical. Do not time this diagnostic as
a clean run. `symbolize-exit.py BINARY STDERR_LOG LIBRARY NEW_JSON` authenticates
the native build binding and resolves saved PCs through the unstripped symbol
table. Return addresses use PC-1: a non-returning call can end exactly at the
next function boundary. Initial naive boundary attribution remains in raw evidence.

The Map diagnostic identifies `rfc_wrap` from `WL_FID_NOA_EVAL_K8169`; generated
source and disassembly are retained. It does not prove which source/lowering
component caused the forbidden closure/task value. A separate `perf` attempt
could not run because the system wrapper references missing `perf_5.10`; no
native CPU profile was collected and no profiling permissions were changed.
