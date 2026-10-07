# Phase61 compiler fast loop

This is a candidate-aware derivative of the frozen Phase60 compiler-request
method. It runs no generated benchmark workloads. Fresh compiler outputs must
match complete, qualified raw module bytes after each measurement window.

The active method is `selfhost/build/phase61/latency-method02`. Method01 remains
as the unexecuted first derivative; method02 corrects its optional qualified
oracle identity-list assembly. No target result came from that defect. The
factories retain parent hashes and exact textual derivations. Do not edit a
consumed method, binding, producer or receipt; create a fresh successor.

## Materialization and baseline

These commands are data-only and may use CPU0. They require initialized Phase61
raw output and fresh destinations. They do not import a compiler.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase61/latency/make-method.py \
  selfhost/build/phase61/latency-method01
taskset -c 0 python3 selfhost/tools/performance/phase61/latency/make-method-v2.py \
  selfhost/build/phase61/latency-method02
taskset -c 0 python3 selfhost/tools/performance/phase61/latency/make-bindings.py \
  selfhost/build/phase61/baseline-latency02 \
  --method selfhost/build/phase61/latency-method02
```

Those destinations already exist in this campaign. Use their frozen files;
replay materialization only after restoring the raw layout, or select fresh
names and derive matching parent paths. The recipe writes `commands.txt` and
machine-readable argv in `report.json`. It does not execute them.

Root alone launches target commands. The runner owns the one execution guard;
do not wrap it in another guard or restrict its inherited affinity to CPU0.

```sh
python3 selfhost/build/phase61/latency-method02/run.py \
  selfhost/build/phase61/baseline-latency02/preparation \
  --bindings selfhost/build/phase61/baseline-latency02/bindings.json \
  --roles baseline,typescript --cases all --prepare-only --seconds 180
```

Preparation verifies the actual image lineage, stages private helpers/API,
loads the compiler and primes its API-keyed Base cache. It inherits all 45
qualified value oracles across 23 compilation inputs; these are **not newly
executed runtime values**. The raw module references exclude the generic-row
observer, which belongs to the previously qualified post-emission boundary.

## Checked B1, genuine B2 and diagnostic images

Before an own-source B2 exists, supply an actual checked attempt:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase61/latency/make-bindings.py \
  selfhost/build/phase61/candidate-b1-screen01 \
  --method selfhost/build/phase61/latency-method02 --image b1 \
  --candidate-attempt selfhost/build/phase61/checked-CANDIDATE/attempt.json \
  --without-typescript
```

After the bootstrap owner produces the genuine emission receipt, use:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase61/latency/make-bindings.py \
  selfhost/build/phase61/candidate-b2-screen01 \
  --method selfhost/build/phase61/latency-method02 \
  --candidate-attempt selfhost/build/phase61/checked-CANDIDATE/attempt.json \
  --candidate-emission selfhost/build/phase61/CANDIDATE/bootstrap/full/report.json
```

Replace the capitalized paths with real completed artifacts. Setup independently
verifies the checked attempt, its bootstrap/source/API, actual emission generator
and subject, tiny split/unsplit gate, roots and direct runtime. The source and
driver may differ between candidates; each role stages its own actual snapshot.
No checked sidecar is invented for B2. A successful pilot is not broad semantic
qualification, self-reproduction, installation or a fixed-point claim.

For a saved-image counterfactual, use `--diagnostic DERIVATION.json` instead of
candidate attempt/emission. Its parent must be the selected baseline B2. The
receipt must contain `kind`, `complete/pass`, `diagnosticOnly: true`,
`productionQualified: false`, scope, and parent/output/producer/runtime
identities. Setup verifies the exact parent and unchanged direct-runtime prefix.
The image remains `kind: syntax`, explicitly diagnostic. This route does not
prove that the transformation is semantics preserving; ordinary output oracles
still apply. Rebind the baseline flags to test a derivative of another genuine
emission. Do not relabel diagnostic output as a checked or self-emitted image.

## Coverage, timing and profiles

The recipe records these cases and budgets:

| Recipe | Compilation inputs | Rounds / later requests | Two-role deadline | Three-role deadline |
|---|---|---|---:|---:|
| screen20 | numeric recurrence, MapSet | 1 / 0 | 20 s | 35 s |
| screen60 | those two plus active raytrace | 2 / 0 | 60 s | 90 s |
| heldout | lexer, Evening | 3 / 0 | 180 s | 180 s |
| all | all 23 | 3 / 3 | 1,200 s | 1,200 s |

20/60 are coverage labels inherited from the tested Phase60 subsets, not
guaranteed durations. Phase60's two-role whole-CLI observations were 17.529 and
49.510 seconds, excluding reusable preparation. Different images/roles may cost
more. Cases and rounds remain configurable; an incomplete budget records
failures/skips and cannot produce a successful population claim. Two or three
cyclic rounds need not be perfectly position balanced.

Each clean sample is a fresh process: actual driver/compiler import, ordinary
`loadApi`, one ordinary checked library request, then the requested zero to three
later requests. No persistent inspector is used. Fresh processes share only
their role's preprimed disk cache. First and later timings stay separate; later
requests can still be warming. Hashes, saving outputs and full-byte comparisons
occur outside each timed request.

CPU/allocation are separate fresh processes capturing import, API load and
exactly one first request. There is no warm request or earlier compiler import.
Validation is after inspector stop. CPU uses 1 ms samples; allocation uses
128 KiB sampling with collected objects included. Diagnostic time is never
clean speed. Signed CPU accounting may refuse weights and retain count-only
evidence. Allocation estimates are cumulative samples, not peak live memory.
All jobs keep CPU3, a 1 GiB Node heap, 2 GiB process-tree RSS guard and 4 GiB
available-memory minimum. Preparation and historical provenance reads are
excluded, may warm OS/process state, and are not identical to older campaigns.

## Changed generated bytes

The default policy maps both Bend roles to the frozen Phase60 direct raw output
and TS to its pinned TS raw output. Any emitted-byte difference fails. This is
appropriate for optimizations of the compiler's own work which retain emitted
code. It does not reject a proposed backend change forever; it requires a
separate correctness gate before timing that new output.

`--candidate-oracles PACKET.json` admits a reviewed qualification packet. The
validation owner constructs it from actual checked acquisition, point smoke
results and, when needed, B2/B1 raw-output equality. Source equivalence alone is
insufficient. Its schema is:

```text
kind: phase61-qualified-compiler-output-oracles
complete: true, pass: true, backend: direct
catalog: {file, sha256}                  # exact frozen Phase60 catalog
image: {api, source, base, runtime, directRuntime, driver}  # identities
inputs: [identities of the joined qualification evidence]
cases: [{id, source, output, pointIds, oracleValues,
         semanticQualification: {pass: true, receipt: identity}}]
```

Each `oracleValues` is the complete corresponding catalog `oracles` list,
including adapters. Each output is the newly qualified **raw** module. The
method pins the packet and successful evidence, joins actual staged image
hashes and requires every measured output to equal those bytes. The packet's
reviewed producer owns the detailed acquisition/runtime/equality join; this
latency method does not manufacture semantic evidence. It permits only cases
actually covered by the packet. No changed-byte packet has been fabricated by
these tools.

The full historical qualification audit occurs at preparation. Each sample
rehashes the catalog, methods, active source/import closure, staged API/helpers,
cache and active raw oracle rather than all unrelated historical outputs.
Phase54–60 raw trees, installed files and compiler source remain untouched.
