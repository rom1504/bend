# Native compiler request loop

Source/data preparation runs on CPU0. Only root runs targets, serially through
the existing `ExecutionGuard`; do not add another guard around `run.py`.
Historical Phase67 raw files are read-only. These scripts do not change compiler
source, emit executables, invoke Clang, or time executable runtime.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/compilation/prepare.py \
  --out selfhost/build/phase68/native-compilation01 --rounds 1
python3 selfhost/tools/performance/phase68/compilation/run.py \
  --plan selfhost/build/phase68/native-compilation01/plan.json --group prepare
python3 selfhost/tools/performance/phase68/compilation/run.py \
  --plan selfhost/build/phase68/native-compilation01/plan.json --group clean
python3 selfhost/tools/performance/phase68/compilation/run.py \
  --plan selfhost/build/phase68/native-compilation01/plan.json --group profile
taskset -c 0 python3 selfhost/tools/performance/phase68/compilation/analyze.py \
  --plan selfhost/build/phase68/native-compilation01/plan.json \
  --out selfhost/build/phase68/native-compilation01-summary.json
```

The first plan already exists; do not recreate it. Use a fresh output for another
plan. Inputs, copied projects, methods and the plan are frozen before execution.
`--only profile-array-b2` limits a group to specified exact job names; previously
consumed job directories cannot be overwritten. The analyzer explicitly lists
missing jobs and cannot mark an incomplete plan complete. A failed job stops the
runner; preserve it and derive a fresh reviewed successor before retrying.

Each target receives CPU3, a 1 GiB JS heap, a 4 MiB stack, a 90-second deadline,
a 2 GiB process-tree RSS ceiling and a 4 GiB available-memory floor. Base
preparation is explicit and unmeasured. Clean request clocks separately report
host/API imports and the full checked native request; that request includes
mandatory cache loading, frontend work, reporting, native annotation/validation,
foreign preparation and C emission. TS performs its normal Base load/check in
the request. File hashing and exact C checks are outside the clocks. This is not
a cold OS-cache measurement or the historical JS library score.

Every output must equal its qualified Phase67 complete C byte oracle; B2 earns
that equality independently. Numeric, Array and Lexer wrappers and their original
independent execution oracles are pinned. A deliberately changed C emitter needs
fresh C/Clang/runtime qualification and its own subsequent frozen oracle.

Profile jobs are separate fresh processes with public-entry stage forwarding
and request-only V8 sampling. Stage wrappers observe driver calls, not every
internal recursive call. CPU profiles preserve the inner erase/lower/render
stacks and the analyzer retains unknown/host/GC time. Never use instrumented wall
times as clean samples or add overlapping inclusive CPU rows. Default one-round
results are diagnostic; use a new `--rounds 3` plan for per-case role balancing.

The retained-bound source proposal is **isolated, unselected and unexecuted**:
`cached-bound-v1.patch` / `cached-bound-v1.json`. It preserves public full-scan
semantics and adds one owned private consumer. Read the proof and required
controls in [the research note](../../../../../research/phase68/native-compilation.md)
before integration. No persistent cache schema change is proposed.

For Clang acquisition and execution-only iteration, use the existing
[Phase67 native method](../../phase67/benchmark/README.md) with a fresh Phase68
recipe/output and actual selected API. Keep emission, Clang, and program runtime
results separate.

For final selected images, use the separate data-only
`prepare-selected-v1.py` successor. It requires explicit `--attempt` and
`--image-pins`, plus repeatable `--acquired` and `--reference-acquired` report
paths. The selected reports must cover Numeric/Array/Lexer exactly once and bind
the selected actual B1; the reference reports bind pinned TS. All three C
oracles must already have passed emission, Clang and independent execution.
The same immutable `run.py`, `worker.mjs` and `analyze.py` then consume its plan.
Use `--rounds 3` for position balancing. No final image or acquisition is
inferred from mutable checkout paths, and Phase67 C is not reused for changed C.

`demand-templates/` contains P68-006's isolated lazy-selector source proposal
and exhaustive diagnostic controller. The source review passed, but no
candidate performance or target-equivalence result is implied by that review.
