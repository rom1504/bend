# Phase89 native compiler experiments and fast loops

Run from the repository root. Use a fresh output path for every attempt; keep
failures. Root runs compiler targets serially under the existing guards. These
methods do not alter canonical production source or installed Phase82 JS B2.

The current native build profile is upstream-built B1
`selfhost/build/phase89/compiler-native-self01`, SHA256 `8bacae26…`, from frozen
Bend source `4584cf08…`. It includes owned match composition, ordered body chunks
and a narrow nine-effect private entry. All eight live/cache gates and all45
broad C comparisons pass. This is **not native B2**: full self-emission hit its
600s deadline without C. [Feasibility and exact identities](../../../../implementation/phase89/native-b2-feasibility.md).

The versioned `native.py` wrapper has a pinned admission manifest for this image,
and all ten wrapper controls pass: four cached/live exact-C emissions, five
public refusals and a private altered-manifest refusal. See
[launcher status/protocol](native-launcher.md).

## Start with identity checks and a small request

These admission checks run no compiler target:

```sh
python3 -B selfhost/tools/performance/phase89/admission.py check \
  selfhost/build/phase89/compiler-native-self01
python3 -B selfhost/tools/performance/phase89/admission.py check \
  selfhost/build/phase89/compiler-native-self01 --live
```

Compile a small source with the qualified native wrapper:

```sh
python3 -B selfhost/tools/performance/phase89/native.py \
  selfhost/tools/performance/phase77/fixtures/small.bend \
  --image selfhost/build/phase89/compiler-native-self01 \
  -o selfhost/build/phase89/NEW_SMALL.c --seconds 60
```

Default mode authenticates and decodes the exact prepared Base carrier. `--live`
prepares/checks Base in the native process. `--calls 5` retains the explicit five
request sequence; it is not a steady-state guarantee. Supported input scope is
one source importing Base, with the nine admitted provider files. Other imports
and effects remain refusals. Python authenticates/transports; the native Bend
image performs compilation. Logs retain command, inputs, refusal and resources.

## Six-source compilation loop

`measure-qualified.py` uses the admitted native image and frozen source/C
oracles. It checks every complete emitted C file. No Clang or program execution
is part of this compilation-speed loop.

```sh
# Six native requests: quickest current source screen.
python3 -B selfhost/tools/performance/phase89/measure-qualified.py \
  selfhost/build/phase89/NEW_NATIVE_SCREEN --roles native --rounds 1

# 36 interleaved cold jobs: six sources, three roles, two rounds.
python3 -B selfhost/tools/performance/phase89/measure-qualified.py \
  selfhost/build/phase89/NEW_PAIRED_SCREEN \
  --roles ts-bun,b2-node,native --rounds 2
```

Use `--cases small,numeric_closed,lexer_original,map_closed,functions65,unicode`
to state the complete set, or an explicit subset for a focused hypothesis.
Other roles are `ts-node` and `b2-bun`. `--calls 5` compares first-through-fifth
requests in each process. Report request and whole-process clocks separately;
changing engine, cache preparation, call count or CPU changes the experiment.
Per-job60s is a stop limit, not an estimated screen duration. Final qualified
cold timings belong to the root's timing report, not this command guide.

## Broader output identity, after a useful fast result

The new image's evidence is
`selfhost/build/phase89/native-b1-nine-gates01/gates.json` and
`selfhost/build/phase89/nine-broad01/report.json`. The former is the immutable
eight-pass receipt, distinct from the failed optional self-emission `report.json`.
To validate every binding without emitting a program:

```sh
python3 -B selfhost/tools/performance/phase89/broad-exact-v2.py \
  selfhost/build/phase89/compiler-native-self01 \
  selfhost/build/phase89/NEW_BROAD_PREFLIGHT \
  --nine-effects-gates selfhost/build/phase89/native-b1-nine-gates01/gates.json \
  --check-only
```

Remove `--check-only` and choose a different fresh directory to emit all45
distinct catalog-point wrappers. Each complete C hash must match its previously
executed Phase88 oracle; the first mismatch stops the campaign. This reuses
existing execution evidence without recompiling45 executables. It does not
remeasure program runtime or establish full-language conformance.

For a new nine-effect image, `native-b2/run-b1.py IMAGE FRESH_DIRECTORY
--check-only` first verifies its exact source/build/assets. Removing that flag
runs four live and four cached C gates. It admits only the frozen source4584cf08…;
it is not a general arbitrary-image admission mechanism. `--self-source` adds
the costly full S→C2 attempt and is not the fast iteration loop. The completed
600s attempt produced no C and must not be relabeled as an upstream build or B2.

## Limits, diagnostics and preserved alternatives

- Normal targets: CPU3, one native thread, GPU off,2GiB tree RSS ceiling and
  4GiB available-memory floor. At least160MiB disk headroom is required.
- Native input limit:16MiB. Guarded output-file limit:64MiB. Wrapper deadlines
  are1–600s (default60); broad requests use90s by default. Whole compiler Clang
  builds are separate root-controlled gates, not part of these commands.
- All nine effect bytes, Base/runtime/template, exact image/source/C lineage
  and private cache provenance remain bound. File effects do not gain scalar
  array or observer permission. A changed asset must refuse.
- [Partial capture](partial-capture/README.md) remains ongoing and separate from
  successful compilation. The current self-prefix sample has a timer overrun
  and its [analysis is unqualified](../../../../implementation/phase89/partial-self02-unqualified.json).
  Keep the strict analyzer, intentional stop status and complete raw evidence;
  do not turn partial sample counts into completed-request timing claims.
- `compare-owned.py` / `compare-chunks.py` preserve mechanism comparisons.
  Ordinary JS B1 screens regress4.11% combined and1.15% owned-only; therefore
  both changes stay in the native build profile. See
  [JS ablations](../../../../implementation/phase89/js-integration.md). No extra
  JS continuity campaign is needed while production JS remains unchanged.
- `prepare-js-pair-v1.py` and `broad-exact-v1.py` retain the Python3.9 hashing and
  receipt-field failures. Current methods were exercised against actual inputs;
  syntax parsing alone is not a compatibility or qualification gate.

Archived raw evidence must be restored at its recorded paths. Follow
[launcher restoration status](native-launcher.md) and the sealed manifests;
do not reconstruct proof receipts or silently substitute mutable production
inputs. The final capsule and native-asset selection are sealed; all12 selected
assets verify and the missing-executable restoration control passes.
[Restoration proof](../../../../implementation/phase89/restoration.json).
