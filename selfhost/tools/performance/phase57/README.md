# Compiler execution investigation

This is a compiler-throughput investigation, separate from the generated-program
benchmark. [Findings](../../../../implementation/phase57/README.md) and the
[frozen design](../../../../design/phase57/compiler-performance-attribution.md)
define its comparisons. Production compiler source and the installed Phase56
release are unchanged.

Four roles are deliberately distinct: `typescript` is the handwritten compiler;
`raw` is upstream-generated code for our Bend compiler; `source` is optimized
checked B1; `direct` is the qualified self-emitted B2. The latter three implement
the same source. A stage experiment reconstructs the exact intermediate B1
equality/choice transforms to separate their effects.

## Reuse the preparation

Run new measurements in a separate replay environment at the recorded repository
path. Restore the Phase56 prerequisites, initialize a **fresh** Phase57 raw tree,
then make new preparations. The published Phase57 archive is for read-only
inspection: do not restore it and append new runs, even under a new subdirectory.
Its receipts contain absolute identities; portable path remapping is not provided.
Use a new `NEW_*` output for each replay run.

```sh
PYTHONDONTWRITEBYTECODE=1 taskset -c 0 python3 selfhost/tools/performance/phase57/latency/run.py selfhost/build/phase57/NEW_PREPARATION --prepare-only
```

This executes both complete fixture oracles, requires all three Bend outputs to
be byte-identical, and primes separate API-keyed Base caches. Preparation cost is
outside the comparisons below. The image source, runtime, driver and exact cache
identities are verified by each worker.

## Choose a question and a budget

These are approximate elapsed budgets on this host, not deadline guarantees.
Workers run serially on CPU3 with a 1 GiB heap, 2 GiB tree-RSS ceiling and 4 GiB
available-memory floor. The runner owns the guard; do not nest another guard.

| Budget | Command options after output and `--preparations PREPARATION/report.json` | Question |
| --- | --- | --- |
| About 20–30 s | `run.py … --cases lexer --roles source,direct --rounds 1` | Did one ordinary request/repeat sequence change? A screen, not a robust aggregate. |
| About 60 s | `run.py … --cases lexer --roles source,direct --rounds 3` | Does the B1/B2 difference persist across fresh processes? |
| About 70 s | `run-v3.py … --cases lexer --rounds 1 --mode cpu` | Which functions consume sampled time in all four roles? |
| About 70 s | `run-v3.py … --cases lexer --rounds 1 --mode allocation` | Where are objects allocated, including collected objects? |
| About 70 s | `run-v3.py … --cases lexer --rounds 1 --mode trace` | Which stages, V8 decisions and GC pauses occur? |
| About 300 s | `run.py …` | Full two-input/four-role/three-process clean comparison. |
| Up to 420 s | `emission-profile.mjs` with the documented external guard | Where does full B2 compiler reproduction spend time? |

All ordinary samples include the first request plus three subsequent requests.
They retain the observed warmup trend; none assumes three repeats establish
steady state. Profiles/traces are diagnostic runs and never enter clean medians.
`--child-seconds` and `--seconds` impose hard runner budgets; timeouts remain
failed/censored evidence rather than successful fast samples.

Use `latency/run-stages.py` and its **separate** preparation for the ordered
raw/equality/choices/final-B1 comparison. It does not accept an ordinary four-image
preparation. See [stage results](../../../../implementation/phase57/transformation-ablation.md).

## Read saved evidence cheaply

The data-only readers in `analysis/` start no compilers. `profiles-v2.py` joins
CPU/allocation profiles to exact image function spans; `trace.py` joins request
markers and coarse driver stages. `check-profiles.py` handles the distinct
full-source type-check oracle. Restore `static/code-shapes.json` from its tracked
gzip first, as described in [static/README.md](static/README.md).

The consumed original profiler and failed CPU receipt are retained. Its v2
successor preserves signed raw timestamps and separately reports time-weighted
and sample-count views, refusing inadmissible weighted corrections explicitly.
See [profiling](../../../../implementation/phase57/profiling.md). Do not silently
pool different profiler versions, request boundaries or units.

`check-profile.mjs` and `emission-profile.mjs` require the external bounded
supervisor. The former performs one complete fresh source check with the exact
expected `@unsafe` trust refusal; the latter performs one unchanged full emission
and requires B2/B3 byte equality. Neither installs a compiler or creates a checked
bootstrap sidecar for an emitted image. Saved intermediate images are diagnostic
derivatives, not new checked builds.

## Durable archive

All 1,605 Phase57 raw files, including failed captures and reader attempts, are
preserved in [artifacts/raw/raw-campaign.tar.gz](artifacts/raw/raw-campaign.tar.gz).
[archive.json](artifacts/raw/archive.json) records every member's size/hash and
the successful reopened verification. Member names are relative to
`selfhost/build/phase57`; restore only to an empty inspection tree. This archive
does not duplicate the separately preserved Phase56 prerequisites. The
[publication manifest](publication.json) links the exact reports and identities.
