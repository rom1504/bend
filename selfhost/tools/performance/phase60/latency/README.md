# Phase60 compiler survey method

This survey measures the unchanged selected Phase58 direct B2 against the same
pinned TypeScript compiler. It measures compiler requests, not execution speed of
the generated benchmark programs. The [catalog](../catalog.json) maps all 45
runtime points to exactly 23 distinct source/options inputs. Generic-row shares
the local-row input with local-pair; its observer is a post-emission adapter and
is never inserted into the compiler's timed output.

The method is prepared, with no target execution by its author. The root owns
all guarded preparation and measurements. Nothing here modifies the compiler,
installed image, or closed Phase54–59 artifacts.

## Method and retained correctness evidence

`method03` is a preserved successor of the frozen Phase59 ordinary first-request,
stage-clock and profile methods. Its `derivation.json` records exact edits and
parent hashes. `make-method.py` produced method01; `make-method-v2.py` refused an
incorrect replacement count before writing any method output or running a target.
That failure is preserved. `make-method-v3.py` corrects the count and materializes
method03. The original producers and methods remain unchanged.

Catalog SHA-256:
`d5903c18804afa14b9ca4fc51196d1d419148989a9496e768822f6637004c9ba`.
Selected B2 SHA-256:
`a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
The setup verifies its actual checked-last01 generator and genuine emission
lineage; it never fabricates a checked-bootstrap sidecar for B2.

Preparation stages each role and primes a private API-specific Base cache outside
measurement. It inherits the catalog's already-qualified raw module identities,
all 45 complete runtime-value oracles, and the B2/checked-emitter equality bridge.
It **does not execute those programs again**, or label copied oracle values as
new observations. Each fresh measured compilation must reproduce its own role's
complete raw module bytes afterward. TypeScript and Bend text are not required
to match each other. Fresh source checking remains part of the ordinary request.

The full historical qualification inventory is verified during preparation.
Later processes verify the catalog hash, actual current source/imports/runtime
and raw oracle, staged API/helpers/cache and measurement methods. They do not
rehash every unrelated historical image and output on every request. This changes
excluded provenance preflight relative to Phase59; it does not change request
clock boundaries. OS cache/process-state effects remain a limitation: fresh
processes are not equivalent to a cold filesystem.

Clean mode measures imports, actual API loading and the first ordinary library
request separately, followed by three ordinary requests with fresh source books.
Three rotated rounds × 23 inputs × two roles give **138 workers / 552 requests**.
Rotation is cyclic, not perfectly position-balanced within a source. Later
requests may still warm; report their process medians separately from first
requests and do not claim steady-state throughput.

CPU and allocation modes use separate processes and exactly one combined window:
compiler imports → API loading → first compile. No compiler import, first compile
or warm request precedes capture in the measured process. Validation, hashing and
output saving follow profiler stop. CPU sampling is 1 ms; allocation sampling is
128 KiB and includes objects collected by both GC generations. The original signed
CPU accounting/refusal policy remains unchanged. Profile durations never become
clean latency ratios.

Stage mode uses the same original API and cache with an insertion-only adjacent
driver copy. It uses synchronous clocks, no inspector and one first request.
Successful observations require three root intervals and no incomplete spans.
Nested inclusive intervals overlap; use the exclusive partition and retain
unclassified residual work. Diagnostic modes each cover **46 workers** with one
round. Selective repeats must retain their separate scope.

## Root-owned launch recipes

Run from the repository root. The runner owns the sole `ExecutionGuard`: CPU3,
1 GiB Node heap, 2 GiB process-tree RSS and 4 GiB available-memory floor. Do not
wrap it in another shared guard or restrict its inherited affinity to CPU0.
Use fresh output paths; the existing materialized method must not be overwritten.

```sh
python3 -B selfhost/build/phase60/method03/run.py \
  selfhost/build/phase60/preparation01 --prepare-only --seconds 180

python3 -B selfhost/build/phase60/method03/run.py \
  selfhost/build/phase60/clean01 \
  --preparations selfhost/build/phase60/preparation01/report.json \
  --mode clean --rounds 3 --warm-requests 3 --seconds 1800

python3 -B selfhost/build/phase60/method03/run.py \
  selfhost/build/phase60/first-cpu01 \
  --preparations selfhost/build/phase60/preparation01/report.json \
  --mode cpu --rounds 1 --seconds 1200

python3 -B selfhost/build/phase60/method03/run.py \
  selfhost/build/phase60/first-allocation01 \
  --preparations selfhost/build/phase60/preparation01/report.json \
  --mode allocation --rounds 1 --seconds 1200
```

For stage clocks, derive only the new private driver file, then run the same
source population. The original staged driver stays unchanged:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase60/stages/derive-driver.py \
  selfhost/build/phase60/preparation01/prepare-direct/stage/project/tools/typed-driver.mjs \
  selfhost/build/phase60/preparation01/prepare-direct/stage/project/tools/typed-driver-stages.mjs

python3 -B selfhost/build/phase60/method03/run.py \
  selfhost/build/phase60/stages01 \
  --preparations selfhost/build/phase60/preparation01/report.json \
  --mode stages --rounds 1 --seconds 1200 \
  --driver-receipt selfhost/build/phase60/preparation01/prepare-direct/stage/project/tools/typed-driver-stages.derivation.json
```

`--cases` accepts comma-separated **compile-input IDs**, which are source stems
from `catalog.compileInputs`; it does not accept arbitrary runtime point IDs.
`--cases lexer --rounds 1 --warm-requests 0 --seconds 60` gives a small clean
first-request-only screen with no later-request statistic. The full survey keeps
the canonical three rounds and three later requests. Profile/stage modes always
have zero later requests regardless of that CLI option.

## Failures and bounded continuation

Each worker's process/observation receipt is retained. A failed source/profile
worker does not discard subsequent bounded attempts. A failed role preparation
causes explicit skipped rows for that role; a campaign deadline or signal records
the remaining rows as skipped. Input-identity changes remain fatal integrity
errors rather than ordinary case refusals.

`complete` means the planned queue has been accounted for; `pass` is false if any
worker failed or was skipped. The runner exits nonzero for that campaign. It does
not produce a clean median for a role/input lacking all requested rounds. A broad
aggregate must require the full population, or prominently state its missing
coverage; failures must never silently reduce the denominator.
