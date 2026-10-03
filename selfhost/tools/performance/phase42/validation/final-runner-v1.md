# Frozen Phase42 final campaign handoff

Root executes heavy work serially. Preparation and verification also belong in
the root queue while timing runs; agents must not independently run Node
verification, SHA campaigns or tool materialization alongside timing. Agents
may review code/contracts/docs and perform tiny syntax checks on an explicitly
approved other CPU. No tool in this directory changes historical raw evidence.

The exact bound checked02 recipe has56 steps. Its two manual mapping entries
are executable in the new materialized recipe. Performance/cost admission is
still an explicit reviewed decision between semantic and postinstall stages.
Every selected Phase42 mechanism requires an extension contract; the facts-only
template is not a complete selected-release owner list.

```sh
python3 selfhost/tools/performance/phase42/validation/prepare-final-v1.py \
  --attempt FROZEN_ATTEMPT --out FRESH_OUT \
  --extension REVIEWED_EXTENSION --recipe FRESH_RECIPE
python3 selfhost/tools/performance/phase42/validation/run-final-v1.py \
  FRESH_RECIPE --stage semantic --ledger LEDGER --jobs JOBS \
  --prefix final-semantic --check-only
```

Use absolute paths. OUT and RECIPE must be absent, and RECIPE must lie outside
OUT. The adapter writes a preserved `.base.json` parent beside RECIPE. Extension
config artifacts may create OUT after the binder has verified its freshness.
Preparation invokes maintained verifyAttempt, hashes exact tools and contracts,
and performs no compiler emission. Remove `--check-only` only in the root queue
to run all semantic commands serially via unchanged Phase41 recipe-run.py/job.py.
The runner prints each selected command and records enclosing ledger intervals.
It stops at the first failure and retains all partial evidence. It does not
resume or overwrite earlier outputs. Root may use the unchanged recipe-run.py
for a reviewed explicit subset after preserving a failure and deriving fresh
paths; do not claim skipped mandatory gates closed.

The stages are `semantic`, `cost-prepare`, and `postinstall`. The semantic stage
includes both frontend scopes, all inherited owners, actual list/tree/Nat/TS/
linear/scalar/expanded controls, Phase41 closure, new42 extension owners, the
inherited preinstall auditor and a composite preinstall close. Cost preparation
retains the four-case checked41 baseline/final candidate cost-plan commands;
it does not execute measurement or decide performance admission. Root queues
the selected45-point measurements, actual cost-plan requests and profiles
separately under the unchanged reviewed protocol.

Postinstall requires `--admission ADMISSION_JSON`. Required fields are
`complete: true`, `pass: true`, `attempt.sha256` equal to the frozen attempt
manifest SHA and `api.sha256` equal to its selected API SHA. This is the root's
explicit reviewed performance/cost decision, not an automatically inferred
semantic admission. The runner also requires the exact selected-image composite
preinstall receipt before dispatching inherited installation, verification,
42 ordinary/relocated CLI checks, postinstall auditor and composite close.

## Extension schema

Copy `final-extension-template-v1.json` into a fresh reviewed release-specific
file. Root sets `reviewed: true` only after checking the complete selected owner
set. Required fields:

- `selectedOwners`: unique owner names covering every selected Phase42
  mechanism; rejected prototypes do not belong in this release list.
- `steps`: ordered command objects with unique `name` starting `phase42-` and
  concrete `argv` arrays. Include fresh acquisition, derivation and semantic
  controls for the exact frozen attempt. Keep lock ownership explicit; never
  wrap an acquisition that already owns a supervisor in another lock owner.
- `requirements`: one object per selected owner, with `name`, `report`,
  `execution`, `assertions` and `bindings` below.
- Optional `artifacts`: `{path, data}` objects for fresh immutable JSON configs.
  Their paths must lie inside OUT; the adapter records exact config hashes.

The only substitutions are explicit `${ATTEMPT}`, `${OUT}`, `${NODE}`,
`${UPSTREAM}`, `${PLAN}`, `${DERIVED}`, `${FULL}`, `${FULLDIR}`, `${HIST}`,
`${API}`, `${API_SHA}` and `${ATTEMPT_SHA}`. Unknown substitutions fail before
any heavy dispatch. Plain uppercase text is not a substitution mechanism in
new extensions. The existing inherited mapping instructions are replaced by
concrete mapping commands rather than shell/text evaluation.

Each requirement's `assertions` maps JSON pointers to exact expected values.
Require `/kind`, `/complete: true`, `/pass: true` where the owner emits pass,
and exact oracle/structure/boundary/admission/refusal counts or named arrays.
`{"length": N}` checks an array's exact length. All other objects/arrays/values
compare exactly, including their Python JSON value type. No broad `>=` count,
unknown field relaxation or reduced case selection is introduced.

Each `bindings` item is `{pointer, expected}` for the report, or
`{document, pointer, expected}` for its explicit derivation/emission receipt.
At least one expected value must be `${API_SHA}` or `${ATTEMPT_SHA}`. Add both
when available, and bind candidate runtime/Base/source receipt identities as
the owner requires. The facts example binds `/inputs/2/sha256` to `${API_SHA}`;
the maintained binder separately proves checked bootstrap provenance. A report
that only states a source name is not selected-image evidence.

`execution` points to the exact successful bounded control receipt. The output
directory of `report` must appear as an argument in its execution command.
The collector requires complete/zero return/no resource stop, aggregate RSS2GiB,
available floor2GiB, enclosing cap at most180s, and actual RSS/free-memory
observations within those limits. It rehashes producer and embedded report
identities, records consumed report/execution/document hashes, and checks every
explicit contract. Historical tools retain their own stricter behavioral,
source, typed-graph, failure and runtime guard assertions.

## Concrete owner mapping boundaries

`map-current-owners` reads the fresh final plan's original reports.json, checks
its exact attempt/API and all15 owner names, and copies it to fresh
OUT/owner-reports.json. It changes only counters to OUT/final-counter/report.json
and recursive-folds to the fresh preflight-fold foldV3/unchanged guards reports.
The selected final attempt is identical throughout the frozen recipe; otherwise
materialization refuses. All original owner mapping entries remain.

`map-inherited` derives from successful Phase41 inherited-mapping.json SHA
`e12b8fde1ff1808fb9b7782763e3b23705d81c593bc3d9b4dce58147e6df323f`.
It replaces only that template's old OUT prefix and requires all four groups,
component tailReport/tailExecution, fresh complete reports and successful
execution receipts. Each mapping retains copied original bytes and an adjacent
derivation with input/output hashes and every substitution. These fresh mappings
are collected by the unchanged strict Phase35 and inherited Phase40 closers.
Phase36 planner uses FULL manifest; Phase37 planner uses FULLDIR and produces
its own mapping/closure. No manual relabeling of15/45-point catalogs occurs.

## Composite closure and independent review

After the unchanged14-gate preinstall/15-gate postinstall auditor, the composite
collector requires exact selected-image inherited owner closures15+7+3+4,
Phase41's two groups, expanded154 observations with zero failures/unrun/pending,
and every reviewed Phase42 owner contract. It preserves the lower strict
auditor receipts and does not weaken the attested frontend3222/backend81
policy, failed-observation accounting, canonical sources or42 installed CLI
checks. The composite report is a semantic/installed closure; performance and
compiler cost remain separately admitted.

While root runs serial acquisition/timing, existing agents can independently
review the extension's exact count assertions and selected owner list; inspect
source and cache invalidation/guard changes; compare emitted text already in
memory using the established byte-identity contract when root queues its I/O;
review mapping schemas and report documentation; and prepare final reviewer
questions from already captured summaries. SHA sweeps, Node imports,
measurements and report collector executions remain queued root jobs.

Static preparation was tested without campaign execution against checked02 at
19:00:52–19:00:55 UTC on2026-10-03 (3.0s enclosing command, inherited/unrecorded
CPU affinity). Readonly historical mapping schema checks via `/tmp` symlinks
completed19:01:21.686770–19:01:21.830766 UTC,0.2s/noNode. Root was notified to
label any overlapping timing screen potentially interfered. Current adapters
subsequently gained explicit manifest/API/runtime/Base/Node rehash and embedded
new-report rehash; no further Node/hash execution occurred during root timing.
