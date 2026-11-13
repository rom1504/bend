# General native profiler

See the [usage and interpretation guide](../../../docs/self_hosted/PROFILING.md).

`freeze.py` pins independent workloads; `run.py` captures clean timing, CPU samples
and optional runtime events; `compare.py` pools compatible observations with
quality gates. `analyze.py` decodes ELF leaf samples. `owners.py` and `attribute.py`
add authenticated segment/definition attribution. `unwind.py` provides bounded
physical callers. `runtime.py`/`build-runtime.py` create reversible diagnostic
runtime links; `build-sampler.py` builds the native collector.

`render.py` makes comparison summaries readable; `timeline.py` exposes changing
physical/context hotspots from existing sample order. `check-runtime.py` checks
hooks against frozen independent ABI fixtures. `deduplicate.py` preserves exact
completed outputs as immutable hardlinks when large compiler requests consume
disk. Counter timings, context-only timings and clean timings remain separate.

Recipes may supply a variant's optional `"argv0": "compiler-work"`. Keep
`command[0]` as the actual executable: freezing pins that ELF, and the runner
sets argv0 directly through `Popen(executable=...)`, recording it in each
receipt. No shell wrapper is needed. Empty, nonstring or NUL-containing overrides
are rejected. The comparator verifies recorded argv0 and includes its effective
value in same-variant pooling identity. Default executable names may differ
between compared variants; the experiment must establish that those names do
not change the intended work. Use a common explicit override when argv0 matters.

`build-sampler.py --all-threads` selects the bounded Linux x86-64 collector for
the main thread and intercepted `pthread_create` threads. The default remains
the main-thread collector. The thread collector has 32 lifetime thread slots
(including main), 25,000 samples per slot, and no caller-unwind or dispatch-context
support; `--all-threads --unwind-table` is rejected. It does not capture every
possible raw-clone/preexisting thread. Require the existing sampled-thread versus
process CPU coverage, lifecycle, delivery and zero-loss gates. One Bend worker
can execute on a child thread, so a main-only capture may correctly fail coverage.

Thread-collector PCs are concatenated by thread, **not globally chronological**.
Use aggregate physical attribution, not `timeline.py` for stage order. Compatible
captures with too few samples individually may pool through `compare.py`;
pooling does not excuse overruns, loss or poor coverage. Prefer 8ms/13ms periods
and additional equivalent captures over reducing periods to 2–3ms merely to reach
500 samples. See [Phase159](../../../implementation/phase159/README.md) for the
exact-output and profile-quality gates; sampling is diagnostic, not clean timing.

All target execution belongs in a resource guard. The offline tools never run
the target. Installed compiler selections and historical evidence are untouched.

`plan-runtime.py` prepares physical profiles from an explicit frozen
`bend-benchmark-manifest-v1` program manifest and its complete adaptive runtime
report. It rechecks selected calibration commands, executable identities,
independent complete-output/count observations, source/oracle pins and the
all-thread sampler build receipt. It does not compile, sample or run programs.

```sh
python3 -B selfhost/tools/profiler/plan-runtime.py \
  --manifest /absolute/runtime-products/manifest.json \
  --timing /absolute/runtime-measurements/report.json \
  --cases local-pair,editdist --roles parent,candidate \
  --sampler /absolute/thread-sampler/sampler.so \
  --sampler-receipt /absolute/thread-sampler/report.json \
  --seconds-per-run 2.9 --periods-us 8000,13000 --clean-rounds 1 \
  --out selfhost/build/runtime-profile-plan01 \
  --capture-out selfhost/build/runtime-profile-capture01 \
  --guard-out selfhost/build/runtime-profile-guard01
```

Roles must already exist under those exact names in the merged program manifest
and calibration report. The planner prints a guarded `run.py` command followed
by offline `compare.py`/`render.py` commands; root executes the capture separately
on the chosen lane. `--cpu` defaults to 3. Output directories must be fresh,
distinct and nonnested. The plan uses a 128 MiB disk budget and derives its
whole-run time ceiling from workload count and individual capture timeouts.

Each case/role receives its own workload name, one variant and an independently
calibrated repetition count. This lets the ordinary comparator pool identical
commands within that role, while producing **no cross-role total-CPU ratios**.
`plan.json` records the mapping, exact products, repetition/warmup counts and
sample estimates. Its per-repetition calibration includes process startup and
warmups; estimates do not guarantee profile admission. Keep the normal pooled
sample, period, coverage, loss/overrun and unknown-symbol gates. If interpreting
admitted physical-owner estimates across roles, divide each role's clean CPU
and estimated owner CPU by that role's recorded repetitions. Such descriptive
normalization includes startup/warmups and does not replace matched runtime
qualification or establish source ownership.

`--clean-rounds` changes clean captures only. To collect additional sampled
captures, repeat the period list, for example `8000,13000,8000,13000`; keep at
least two distinct periods. Metadata-only controls are in
`test_plan_runtime.py`, including rejection of mismatched commands, binary pins,
samplers, manifest bindings and count oracles.

Versioned [exact stage observations](STAGES.md) add data-defined FID/order/
multiplicity plans and delivered-sample ordinal association. Preparation and
observation are offline; generic runtime packaging still needs a small native
output gate before deployment. Historical collectors and captures stay intact.

A versioned [opt-in concat event extension](CONCAT.md), enabled with
`runtime.py --concat-v1`, reuses runtime materialization, counter storage, the
build driver and frozen ABI control. Its seven additional counters
separate speculative append attempts, inspected spine positions, successful
splices and refusal reasons. Reuse requires exact source/header/object identities,
reversible hooks, a fresh guarded build and independent ordinary output checks;
its positive new counter branches are source-audited, not fully fixture-qualified.
See the [measured Phase144 findings](../../../research/phase144/concat-profile.md).
Diagnostic event counts must not be reported as time saved or clean performance.

The [migration record](MIGRATION.md) identifies extracted helpers and remaining
operational dependencies. `owners.py --emitter-source PATH` accepts repeated
explicit source pins. Omitting them leaves the assumed lowering contract
unbound; source pins alone never prove which emitter produced an arbitrary QBE
file. There is no fallback to a historical phase source.

The maintained assembly target uses `owners.py --assembly program.s`, retaining
the same conditional lexical grouping and exact linked-ELF table checks as QBE.
Both ABI11101 and ABI11102 are supported. Optional `--build-receipt report.json`
binds actual completed x86 construction; `--source-map map.json --source-root
selfhost` additionally checks physical declaration spans against that build's
compiled source. Assembly maps explicitly record their source format. The
[profiling guide](../../../docs/self_hosted/PROFILING.md) shows the command and
provenance limits; no source instrumentation or compiler execution is needed to
prepare or validate the mapping.
