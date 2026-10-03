# Phase40 reusable evidence tools

Run from the repository root. Root owns compiler builds and program executions;
builds, timing and diagnostics are separate operations. Preserve closed Phase39
and existing Phase40 campaign outputs, including failures; choose new outputs.

## Starting baseline

The checked [baseline bundle](baseline/manifest.json) is already available;
ordinary benchmarks use it directly. To create a fresh equivalent bundle,
repackage the portable Phase39 checked05 modules as the incremental baseline,
with the unchanged pinned TypeScript modules. This derivative of Phase39's
freezer uses the maintained bundle verifier and does not depend on the ignored
checked05 build. It retains the complete original manifests, provenance and
archives, reopens every output archive member, and checks input identities again.

```sh
python3 selfhost/tools/performance/phase40/freeze-baseline.py \
  --current selfhost/tools/performance/phase39/current/manifest.json \
  --reference selfhost/tools/performance/phase39/baseline/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --expected-api 04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f \
  --out selfhost/tools/performance/phase40/baseline-NEW
```

Reuse [the existing execution guide](../phase39/README.md) with this new
`--baseline`, Phase37's explicit catalog, and fresh `selfhost/build/phase40`
outputs. Reuse `programs/prototype.py --from phase39/current/manifest.json`
for saved-output screens (supply full paths and the explicit Phase37 catalog).
Prototype output remains unchecked. Reuse `programs/prepare.py --attempt ...`
for actual checked emissions. Every timing selection needs an unchanged-byte
control. Preparation and timing own the resource lock; do not nest a supervisor.

Use the existing checked development workflow for builds. The unchanged
`phase39/development.json` is reusable because its paths resolve against that
file. The maintained Phase37 final-integration planner accepts `ATTEMPT OUT
--prepared MANIFEST`; its frozen plan lists the exact serial gates. It and the
existing final gate auditor preserve historical assertions and source boundaries.
New semantic controls remain explicit evidence; this accounting tool is not an
auditor and does not create an admission decision.

## Append-only campaign accounting

`campaign.py` records decisions, exact bounded-run receipts and module/report
hashes. It never starts a command. Record small commands with their observed
UTC epoch start and elapsed seconds; omit an interval when unavailable rather
than guessing. `start --at` can capture a known earlier campaign boundary.
Reports use a fresh output directory, preserving prior summaries and events.

```sh
python3 selfhost/tools/performance/phase40/campaign.py \
  --ledger selfhost/build/phase40/campaign.jsonl start
python3 selfhost/tools/performance/phase40/campaign.py \
  --ledger selfhost/build/phase40/campaign.jsonl event --label checked01 \
  --receipt selfhost/build/phase40/checked01-supervisor/run.json \
  --decision 'Focused checked gate completed; execution admission remains open' \
  --file selfhost/build/phase40/checked01/attempt.json
python3 selfhost/tools/performance/phase40/campaign.py \
  --ledger selfhost/build/phase40/campaign.jsonl report \
  --out selfhost/build/phase40/accounting01
```

Elapsed tool seconds are summed; overlapping intervals are merged separately
for wall coverage. Unclassified wall time includes reasoning, editing, waiting
and tools not recorded. It is neither token generation time nor a model speed
measurement. This campaign alone cannot establish an effort/model comparison.
Command failures and rejected decisions can be recorded with their original
receipts. Raw intervals, module hashes and exact command arrays remain in JSON;
the Markdown tables are a convenient view of those records.

## Portable generated-program comparisons

The published [current bundle](current/manifest.json) contains installed
checked06 API
`630879d8f030241a1d2c56e97f18f88b5be2070ac45dd02304afd06b3e3c5c0a`: all45
points,176 archive members and1,336,751compressed bytes. Ordinary/relocated
installed CLI checks pass42/42; the final postinstall audit passes15 gate groups
and exact canonical identity of227 sources. This is a checked B1 derivative,
not a newly self-emitted fixed point.

The [portable fast smoke](../../../build/phase40/portable-smoke06/report.json)
passes five points and45 samples (five ×three roles ×three rounds). Its20second
preset completes in20.36seconds including runner overhead; it is not a hard
less-than20second wall promise or an additional performance-admission result.
It validates portable execution separately from the complete catalog evidence.

The available [baseline](baseline/manifest.json) packages the exact Phase39
checked05 program outputs plus the unchanged pinned TypeScript outputs at commit
`018751270e800bc222a93dad7f257083ee53a5f7`. Phase40's incremental comparison is
therefore Phase39 versus Phase40, rather than Phase37 versus Phase40. Portable
execution needs the bundle manifests/archives, catalog and catalog sources;
historical checked build directories are not execution dependencies. Absolute
paths in provenance describe acquisition history.

Always select the explicit [Phase37 catalog](../phase37/catalog.json): it has
45 fixed input points across 23 source files. Multiple inputs share a source;
these are not 45 independent programs or complete language coverage. Historical
group names, including `coverage-holdout`, do not denote unseen workloads now.
The [maintained runner](../programs/README.md) executes already compiled modules.
It does not build, import or execute a compiler during ordinary program timing.

Run from the repository root on Linux with Python 3.9+, `taskset` and Node 24+.
Choose an absolute Node path, an available CPU and a new output name each time:

```sh
PHASE40_NODE=/absolute/path/to/node
PHASE40_CPU=3
PHASE40_CANDIDATE=selfhost/tools/performance/phase40/current/manifest.json

run40() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog selfhost/tools/performance/phase37/catalog.json \
    --baseline selfhost/tools/performance/phase40/baseline/manifest.json \
    --candidate "$PHASE40_CANDIDATE" \
    --node "$PHASE40_NODE" --cpu "$PHASE40_CPU" \
    --rss-mib 2048 --available-mib 2048 "$@"
}

run40 --budget 20 --set fast --out selfhost/build/phase40-replay/fast-NEW
run40 --budget 60 --set core --out selfhost/build/phase40-replay/core-NEW
run40 --budget 300 --set broad --out selfhost/build/phase40-replay/broad-NEW
run40 --budget 600 --set full --out selfhost/build/phase40-replay/full-NEW
```

| Ceiling | Set | Points | Rounds per role/point | Warmup floor | Timed-block target |
|---:|---|---:|---:|---:|---:|
| 20 seconds | `fast` | 5 | 3 | 100 ms | 50 ms |
| 60 seconds | `core` | 8 | 3 | 350 ms | 150 ms |
| 300 seconds | `broad` | 10 | 5 | 600 ms | 250 ms |
| 600 seconds | `full` | 45 | 5 | 1,000 ms | 300 ms |

These ceilings include verification, extraction, process startup, import, first
call, warmup, calibration and measurement. They are not duration promises. Raytrace
uses at most three rounds and one warmup call; other points require three warmup
calls, with the time floor also required. A larger budget selects a deeper preset,
not an adaptive extension of one case's warmup. **All 45 points may not finish
inside one 600-second run.** Incomplete output remains preserved, exits nonzero
and supplies no ratio for an incomplete point; inputs are never reduced silently.

## Focused screens and complete catalog groups

The historical `fast`/`core` sets omit newly optimized list and tree points.
`broad` means the catalog's ten development application points. Select changed
workloads explicitly and keep a byte-identical control in the same run:

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json --list
run40 --budget 20 --set fast --plan

run40 --budget 20 \
  --cases coverage-list-pipeline-512,variation-tree-bitonic-6-17,scalar-region-8192 \
  --out selfhost/build/phase40-replay/component-screen-NEW
run40 --budget 60 \
  --cases coverage-list-pipeline-512,tree-bitonic,scalar-region-8192 \
  --out selfhost/build/phase40-replay/component-confirm-NEW
run40 --budget 300 \
  --cases coverage-list-pipeline-128,coverage-list-pipeline-512,variation-tree-bitonic-6-17,tree-bitonic,variation-tree-bitonic-9-123,scalar-region-8192 \
  --out selfhost/build/phase40-replay/component-deep-NEW
```

`--cases` overrides `--set`; neither changes the input or expected result.
`--plan` verifies selected source/bundle identities without running target code.
Check the report's emitted-byte identities before treating scalar-region-8192
as the unchanged control for a future revision. An unchanged module's apparent
timing shift is noise, not evidence for the new lowering.

For all 45 points, execute four disjoint groups serially. This example runs the
15-point historical group:

```sh
PHASE40_GROUP=historical
PHASE40_CASES=$(python3 selfhost/tools/performance/phase37/catalog-cases.py "$PHASE40_GROUP")
run40 --budget 600 --cases "$PHASE40_CASES" \
  --out "selfhost/build/phase40-replay/${PHASE40_GROUP}-NEW"
```

Repeat with `coverage-variation` (14 points, 600-second ceiling),
`coverage-development` (10 points, 300 seconds) and `coverage-holdout`
(six points, 300 seconds). Each invocation has its own ceiling. If another host
exhausts one, preserve it and retry smaller explicit selections in fresh outputs.
Do not replace a failed point with an old denominator or pool short screens with
deeper confirmations. Read per-role ranges, paired rounds and within-sample drift
as well as medians before accepting a gain.

## CPU, allocation and static code diagnostics

Diagnostics are separate instrumented executions on the exact copied modules.
They include syntax/function counts and generated-code comparisons, CPU profiles
and sampled allocation profiles. They never enter clean timing ratios. After a
successful list512/tree/scalar comparison above, reuse its modules:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --from-run selfhost/build/phase40-replay/component-confirm-NEW \
  --budget 60 --mode all \
  --out selfhost/build/phase40-replay/component-diagnostics-NEW \
  --node "$PHASE40_NODE" --cpu "$PHASE40_CPU" \
  --rss-mib 2048 --available-mib 2048
```

Use `--mode static` for syntax analysis without executing analyzed programs,
`cpu` for CPU profiles or `allocation` for allocation profiles. Alternatively
append `--diagnostics all --diagnostic-budget 60` to `run40` for a small selection.
Timing and diagnostic ceilings are separate and can both be consumed. See the
[diagnostics guide](../programs/DIAGNOSTICS.md). Allocation samples estimate bytes
allocated in a window, not retained memory or exact object counts. A CPU sample
share does not predict a speedup. Static code differences show changed emission,
not an execution benefit by themselves.

## Checked builds, preparation and publication

A source change first requires a fresh checked development attempt using the
existing [development workflow](../../development/README.md). Compiler builds
and their focused probes are separate from emitted-program execution. Once an
attempt exists, prepare selected sources for iteration or the full catalog for
acceptance:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --attempt selfhost/build/MY_CHECKED_ATTEMPT --set full \
  --out selfhost/build/phase40-replay/MY_CANDIDATE \
  --node "$PHASE40_NODE" --cpu "$PHASE40_CPU" \
  --heap-mib 1024 --rss-mib 2048 --available-mib 2048
PHASE40_CANDIDATE=selfhost/build/phase40-replay/MY_CANDIDATE/manifest.json
```

Replace `--set full` with `--cases ...` for focused preparation. Preparation
checks each distinct source once and binds output bytes to source and checked
compiler receipts; it is outside execution budgets. A saved-output prototype
tests a mechanism sooner, but remains unchecked and cannot supply release bytes.

After the same checked image satisfies root's acceptance gates, portable
publication uses the freezer without running a compiler or target program:

```sh
python3 selfhost/tools/performance/phase40/freeze-candidate.py \
  --from selfhost/build/phase40-replay/MY_CANDIDATE/manifest.json \
  --attempt selfhost/build/MY_CHECKED_ATTEMPT \
  --out selfhost/tools/performance/phase40/current-NEW
```

This requires all 45 points. The destination must be new; do not overwrite a
frozen bundle. Freezing binds portable bytes and provenance, and does not itself
establish correctness, performance admission or installation.

## Results, final gates and resource limits

The installed benchmark basis is **42 exact-byte reused checked05 point
comparisons plus three fresh checked06 ray comparisons**, with669 selected
primary samples. These are not45 newly timed checked06 points. The
[evidence selector](select-execution.py) rehashes the final checked45-point
preparation, all three roles' bytes and raw measured rows; recomputes statistics,
paired rounds, ranges and drift; and preserves each row's measurement API and
protocol. Only reused generated-program execution evidence transfers by byte
identity. Compiler cost, semantic owners and installation are fresh checked06
checks. The
[selected receipt](../../../build/phase40/selected06-execution01/report.json)
retains rejected checked05 ray rows separately. No denominator or warming
protocol is pooled across points.

Historical/variation groups use the600second preset; development/holdout use
300seconds. Three fresh ray replacements match their respective old protocols;
all42 reused rows keep their original same-run baseline/TypeScript observations.
The rejected checked05 image, its669 original primary samples and the manual
lexer prototype remain separate evidence. Read the
[performance decision](../../../../implementation/phase40/performance-admission.md)
for changed gains, adverse Mandelbrot observations, remaining TypeScript gaps
and measured compiler-request costs; a portable smoke does not replace it.

`report.md` presents per-point medians; `report.json` retains ranges, drift,
import/first-call costs, paired rounds, exact module identities and failures.
`baseline/candidate` is the incremental Phase40 speed ratio;
`candidate/typescript` is the remaining slowdown on the pinned target. Timed
exports include exact result checking/checksum work. Import and first call are
reported separately. No average here describes all Bend applications.

Normal checked compiler-cost requests are a fourth operation, distinct from
build time, generated-program timing and diagnostics. They need checked
attempt/cache artifacts and pinned sources; portable program bundles alone are
insufficient. The separate final integration suite also needs those artifacts
and checks broader semantics and identity. It is an acceptance gate, not an
edit-loop prerequisite. Follow [integration instructions](INTEGRATION.md), including the separate historical
15-point owner catalog and reviewed semantic diagnostic successors, and
the [implementation report](../../../../implementation/phase40/README.md) for
completed gates rather than inferring them from a timing pass. Selected new
Reviewed integration successors keep the existing counter semantics, fold V3
producer/fold ownership and shared aliases, selected-image guard checks, inherited
closer V2 plus tail V2, and the unary helper decoder correction. Original failed
assertions and exact predecessor hashes remain preserved; these corrections do
not waive semantic or provenance checks. The selected new
[backend semantic owners](../../../../implementation/phase40/backend-rules.md)
cover complete values, aliases, mutation/reentry, demand/error order and stack
depth; their scopes overlap and are not additive language coverage.

Preparation, timing, diagnostics and compiler-cost tools own the shared resource
lock. Invoke serially and do not nest another lock-owning supervisor. The normal
contract is a 1 GiB Node heap, 2 GiB sampled process-tree RSS ceiling and 2 GiB
available-memory floor. Sampling is not a hard kernel reservation. Keep unrelated
builds and benchmarks out of measurements, preserve failed outputs, and use a
fresh name on every retry. Closed Phase39 raw evidence remains immutable.
