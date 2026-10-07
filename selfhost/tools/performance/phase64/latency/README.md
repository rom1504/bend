# Phase64 controlled compilation measurements

The baseline is the genuine Phase63 State09 B2 selected at `fd01066`, compared
with pinned upstream `018751270e800bc222a93dad7f257083ee53a5f7`. These methods
derive the frozen Phase63 latency and Phase62/63 stage collectors. No consumed
parent, compiler image, output oracle or installed artifact is changed.

`make-method.py` creates a fresh Phase64 method and records every textual edit.
The metadata verifier and its import dependencies come from the immutable
State09 snapshot. A historical State09 workflow input maps only to the exact
byte-identical snapshot entry in the genuine checked attempt. This lets source
agents work without changing the baseline's audit dependencies. Candidate
drivers, APIs, runtimes and Base caches still come from their actual snapshots.

Already materialized: `selfhost/build/phase64/latency-method01` and
`selfhost/build/phase64/baseline-state09/{bindings.json,recipe.json,commands.txt}`.
Root alone executes the generated commands serially. The parent runner owns one
guard; do not wrap it in another guard or pin the parent to CPU3. Targets use
CPU3, a 1 GiB Node heap, 2 GiB process-tree RSS ceiling, 4 GiB available-memory
floor and 4 MiB stack.

Run the recipe's `prepare` command first. It prepares private API-specific Base
caches and verifies existing qualified raw-output references outside timing.
Then `cpu` and `allocation` each capture one fresh first-window diagnostic for
Numeric, Lexer and MapSet, with both State09 B2 and TS: six workers per mode.
`baseline-three` uses two rotating rounds per role/source, giving twelve clean
workers with balanced positions. Diagnostics include compiler imports, API
load and exactly one compile, with no prior compiler request. CPU sampling stays
at 1 ms and allocation sampling at 128 KiB, including collected objects. Never
mix profile durations into clean ratios.

After root reports that preparation is complete, materialize the stage method
using data-only Python on CPU0:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase64/latency/stages/make-method.py selfhost/build/phase64/latency-method01 selfhost/build/phase64/state09-stage-method01 --preparations selfhost/build/phase64/baseline-state09/preparation/report.json
```

Root can then execute:

```sh
python3 -B selfhost/build/phase64/state09-stage-method01/run.py selfhost/build/phase64/state09-stages01 --bindings selfhost/build/phase64/baseline-state09/bindings.json --preparations selfhost/build/phase64/baseline-state09/preparation/report.json --roles baseline,typescript --cases numeric-recurrence,lexer,test-map-set-ops --rounds 1 --warm-requests 0 --mode stages --seconds 90
```

Stage driver changes are insertion-only and have an exact inverse proof.
Ordinary `inspect` receives no API override, preserving the owned world/ready
paths. Synchronous wrappers observe actual API calls; nested exclusive clocks
must reconcile to the whole interval. TS keeps its distinct load/check/emission
boundaries. These observations locate work; they do not establish feature gains.

The [build package](build/README.md) prepares candidate checked-B1 builds and
explicit export admissions only when root selects and freezes source. Then use
`make-bindings.py` with `--image b1 --candidate-attempt ...` and the admission/
reference receipts. This compares checked B1 with checked State09 B1 by default.
An actual candidate B2 requires its genuine emission receipt and `--image b2`.
Cross-generation screens require explicit `--baseline-image` and are labelled;
they cannot update the B2 headline.

The 23-source broad recipe remains available for selected candidates. With
baseline/candidate/TS its three rounds yield 207 position-balanced workers.
The corpus covers 45 program points, but those are 23 independent compilation
sources. Complete raw-module equality is required in every sample. Runtime
execution, own-source checking, fixed-point equality and release remain separate
gates; Phase64 baseline preparation does not run or claim them.
# Incremental candidates and data analysis

`make-bindings-v2.py` retains the original factory and adds explicit prior-role
selection. Use `--baseline-bindings PREVIOUS/bindings.json --baseline-role
candidate --without-typescript` to compare two checked B1 candidates. Each
side retains its actual attempt and export-admission evidence. The default
three-source recipe uses two balanced rounds for two roles; an explicitly
requested three-round diagnostic has 18 workers and is not fully balanced by
position. Fresh genuine-B2 comparisons still require their emission receipts.

Data-only summaries are produced by `analysis/clean.py`, `analysis/cpu.py`,
`analysis/allocations.py` and `stages/summarize.py`. Run them with Python pinned
to CPU0 after root closes the input campaign. The clean helper verifies every
saved output against its role-specific full-module reference, then computes
equal-source geometric means of median ratios. CPU and allocation helpers
reuse the frozen Phase62 ancestry reader with explicit new named boundaries;
shared SCC names do not establish a member-level cause.

`demand/factory.py` prepares a separate copied project with a reviewed proxy
helper and API-phase observer. This diagnostic measures which decoded graph
nodes and fields are read. It keeps compiler image, Base, runtime and cache
bytes fixed, requires full output equality and makes no latency claim. Root
alone runs its three guarded workers. Existing clean preparation files remain
unchanged.
