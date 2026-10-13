# Phase83 diagnostic methods

[Design](../../../../design/phase83/compilation-work-investigation.md) ·
[report](../../../../implementation/phase83/README.md).

Production and installed Phase82 remain unchanged. These methods preserve exact
input identities and retain failed outputs rather than overwriting them.

## Survey

`prepare.py` combines selected Phase82 B1/B2 with pinned TypeScript and eight
existing source/oracle pairs. It copies only small driver/runtime trees and
prepares isolated Base caches. `worker.mjs` derives from Phase81's CPU/heap worker,
adding the Phase82 preparation API names. `run.py` derives from the Phase82 serial
ExecutionGuard runner; `derivation.json` records both original method hashes.

Preparation,48 clean requests,16 CPU profiles and3 heap profiles are separate:

```sh
python3 -B selfhost/tools/performance/phase83/prepare.py
python3 -B selfhost/tools/performance/phase83/run.py --plan selfhost/build/phase83/survey01/plan.json --group prepare
python3 -B selfhost/tools/performance/phase83/run.py --plan selfhost/build/phase83/survey01/plan.json --group clean
python3 -B selfhost/tools/performance/phase83/run.py --plan selfhost/build/phase83/survey01/plan.json --group profile
```

Completed directories are immutable: these commands intentionally refuse to
overwrite them. For a new investigation derive methods with a new output root;
do not delete existing evidence to rerun a completed plan.

## Candidate fate

`prepare-regions.py` creates an observation-only B2 derivative with exact C
assertions. It times selected internal boundaries, records actual candidate
errors/body string units and final plan readiness, and runs Numeric/Map/small/
Functions65. Use the same runner's `prepare` then `clean` groups on its plan.
The historical runner group name `clean-region-*` does **not** make these
instrumented derivative intervals clean performance samples.

Wrapper counts exclude internal SCC/tail-loop iterations. Nested timings overlap;
the instrumentation may change V8 behavior. UTF-16 body length is not allocated
bytes. Later observer fate is established by source inspection, documented in
the representation research; this diagnostic observes final ordinary/product
plan readiness directly.

## Frontend size and warmth

`prepare-frontend.py` freezes8/32/65/128-definition sources;65 exactly reproduces
the existing fixture. It reuses the already prepared survey B2 cache and extracts
the exact upstream `book_promises`/`term_refs` helpers for equivalent proof-report
participation. `frontend-sweep.mjs` performs three ordinary check/report requests
per process. `run-frontend.py` serializes the eight guarded jobs.

No persistent inspector is introduced. Base preparation is excluded for Bend;
upstream loads/checks Base on every request. Results are diagnostic, not a new
native-compilation ratio, asymptotic proof or pure JIT attribution.

## Summaries and evidence

`summarize.py` derives clean medians and separate CPU/heap/region summaries.
`summarize-extra.py` checks candidate fate, frontend observations and all82 guard
receipts. Profile summation is offline and is not part of target occupancy.
`seal.py` archives all new raw files with SHA256 identities, independently
verifies the archive contents, and records method hashes. Parent artifacts remain
bound to the pre-existing Phase81/82 evidence; they are not silently reacquired.

All targets use CPU3, Node24 with1 GiB heap/4 MiB stack,2 GiB aggregate RSS and
4 GiB available-memory floor. Agents do source/research work; root executes the
single target tree. No production builds or generated-C execution are required
for this investigation-only phase.
