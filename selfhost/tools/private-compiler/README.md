# Private compiler image

This builds a separate, worker-private specialization of a checked self-emitted
Bend compiler. The compiler algorithms still come from Bend-generated code.
It does not replace the ordinary compiler API or change emitted program/library
ABIs. Do not import `image.mjs` into an application: its private invariants hold
only behind the supplied JSON request boundary.

Build from a completed checked fixed-point proof:

```sh
node --stack-size=4096 tools/private-compiler/build.mjs \
  PROOF/report.json PROOF/stage2.mjs PROOF/runtime.mjs NEW_IMAGE_DIRECTORY
node tools/private-compiler/run.mjs NEW_IMAGE_DIRECTORY \
  /absolute/path/main.bend compile NEW_RESULT_DIRECTORY --cpu=0
```

Supported modes are `parse`, `check`, `compile`, and `library`. `--report` requests
the ordinary declaration report. `--timeout-ms=N` sets the whole worker deadline
(default 120 seconds). The optional CPU flag uses Linux `taskset`; omit it on
other platforms. The worker uses a 4 MiB Node stack and defaults to a 3 GiB heap.
`--heap-mb=N` accepts 256–16384 MiB; full compiler self-emission may need
`--heap-mb=12288 --timeout-ms=3600000`. Resource arguments are recorded.

`launch.json` records completion, the unchanged compiler observation, proof
status, consumed image and launcher identities, worker command, request time,
and launch wall time. `result.json` retains exact consumed file hashes and path
resolutions. Successful compilation publishes `generated.mjs` by rename after
artifact verification. Foreign JS is read/emitted as data, never executed. The
CLI has no interpreter, `--run`, native, callback, or raw compiler-graph mode.
A compiler rejection exits 1; infrastructure/timeout failures exit 2. Existing
result directories are refused, preserving sources and prior evidence.

The production builder accepts only the reviewed runtime SHA
`26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b`.
A runtime revision requires an explicit re-audit of projection layout, argument
ownership and primitive semantics plus the retained regression/differential gates
before updating that allowlist. Minimal transform unit fixtures are unaffected.

The builder verifies source, canonical Base, initial compiler, host helpers,
runtime, checked stage results and equal fixed-point emissions. It snapshots
these inputs and its tools. The only host rewrite moves its cache directory
inside the image. Images retain their canonical Base dependency; it must remain
at the recorded path with identical bytes. Each private/public API hash has a
separate normally validated Base cache. The first request can be substantially
slower because it checks Base; later requests reuse that cache. Build timing
excludes shell/Node startup; validation tools record complete child process wall.

An explicit `--experimental` build may use a successful, input-verified checked
stage from an incomplete proof. Its manifest and every run remain labeled
`checked-stage-proof-pending`; this is not a completed self-host proof. Old or
incomplete provenance cannot be replaced with an invented bootstrap report.

The specialization uses exact saturated internal workers, a stack-safe private
trampoline, retained scalar operations, proven immutable projection leaves,
branded exact application, and an exact-body proof for the immutable `missing`
constant. Unknown runtime/constant shapes fail closed. Partial/overapplication,
zero-arity factories outside that proof, and ordinary public runtime mutation
remain covered by the original paths/tests. Build manifests are provenance
records, not cryptographic attestations against a malicious local builder.
The worker is an API isolation boundary, not an OS sandbox for arbitrary host
plugins or a forged compiler artifact.

Focused checks:

```sh
node --stack-size=4096 tools/private-compiler/transform.test.mjs
node tools/private-compiler/boundary.test.mjs
node tools/private-compiler/overflow.test.mjs
node tools/private-compiler/tests/cli-validation.mjs CONFIG.json NEW_EVIDENCE_DIR
```

The optional integration configuration supplies `image`, `cpu`, `repetitions`,
`dependencies` and `workloads` records (`id`, `input`, optional `mode`, expected
`status`, `phase`, `checked`, `expectedStdout`, `forbiddenFile`). Relative paths
resolve from that configuration. It alternates the actual private CLI with the
original verified public H and identical host/runtime/Base, preserves failures,
compares exact observations/output bytes, and optionally executes emitted test
programs in a separate process. No median is reported unless every row passes.
This selected gate is not the full conformance corpus.

## Finite focused batches

For several cases, a bounded worker can amortize compiler loading and provenance
verification without a daemon:

```sh
node tools/private-compiler/batch.mjs IMAGE REQUESTS.json NEW_RESULT_DIRECTORY \
  --cpu=0 --heap-mb=3072 --timeout-ms=120000 --recycle=32
```

`REQUESTS.json` is an array of 1–256 records such as
`{"input":"/absolute/main.bend","mode":"check"}`. The same four modes are
allowed. A record may supply its own bounded `timeoutMs`; other resource options
remain in the supervisor. `--recycle` accepts 1–32 requests per worker. Requests
execute sequentially, with a fresh source graph and diagnostic trace each time.
Only the verified compiler image and ordinary API-specific Base cache persist.

The supervisor enforces each request deadline outside the synchronous compiler.
A crash, timeout or output limit leaves that request failed and gives later
requests a fresh worker. An ordinary parse/type/TODO rejection is a completed
compiler observation, and subsequent requests continue. Node and image identities
are checked before/after each worker lifetime; exact consumed inputs are audited
per request. **Sources must remain stable through their worker's lifetime.**
Successful output stays pending until that lifetime finishes and all identities
are verified, then the supervisor publishes it. A changed earlier input leaves
its output unpublished. No provisional proof pass is reported.

`batch.json` retains every request, result, deadline, worker lifetime, resource
argument, input identity and failure. `complete:true` means every requested
observation completed with verified infrastructure; it does not mean all sources
were accepted. Exit 0 means all sources accepted, 1 means completed observations
include compiler rejection, and 2 means incomplete infrastructure/failures.
An earlier verified result may remain available when a later request fails; the
whole batch remains incomplete. Combined stdout/stderr is capped at 2 MiB per
worker, including a final size check after exit; an overflowing lifetime cannot
publish any of its pending outputs. Pending source files and logs are retained for
failed cases, never relabeled as published output.

Additional real-image checks and the controlled focused comparison:

```sh
node tools/private-compiler/tests/batch-behavior.mjs IMAGE NEW_TEST_DIRECTORY
node tools/private-compiler/tests/fresh-graphs.mjs IMAGE NEW_TEST_DIRECTORY
node tools/private-compiler/tests/batch-compare.mjs CONFIG.json NEW_EVIDENCE_DIR
```

The comparison configuration supplies `image`, a `cases` manifest (records with
`id`, `file`, `accept`, `rejectPhase`), `cpu`, and `repetitions`. It compares the
actual finite private CLI, ordinary public H reused in a finite process, checked
B1 reused in a finite process, and checked B1 in separate processes. It primes
and hashes separate validated Base caches and demands every exact observation
match before reporting medians. The ordinary reference hosts have fewer boundary
checks; their lower startup costs are retained rather than normalized away.
