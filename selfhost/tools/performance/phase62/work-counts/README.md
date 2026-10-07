# Phase62 logical work counters

`run.mjs` makes private diagnostic derivatives of the exact State08 genuine B2
and pinned TypeScript compiler. It changes neither compiler source nor installed
images. Root alone runs targets under the existing serial CPU3 guard (1 GiB
Node heap, 2 GiB process-tree RSS, 4 GiB available-memory floor).

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase62/work-counts/run.mjs \
  selfhost/build/phase61/state08-b2-latency01/preparation/prepare-candidate.result.json \
  selfhost/build/phase62/work-counts01 \
  numeric-recurrence test-map-set-ops lexer raytrace-active
```

The output must be a fresh Phase62 directory. The command itself does not own a
resource guard; the root must supervise it. `all` selects the saved 23 inputs.

The script copies the prepared driver project, derives a new counter-bearing API
and primes its Base cache using **its actual new API identity**. Counters are
reset after preparation and before each request. The instrumented compiler uses
ordinary `inspect` without API injection, preserving the private-prefix route's
eligibility. Both compilers' raw output bytes must equal their respective
qualified uninstrumented references. This is a diagnostic process that reuses
modules across cases, not a clean fresh-process speed measurement.

`instrument.mjs` uses Node's bundled Acorn parser. For B2 it places numeric
counters in logical SCC cases and tail-loop bodies, rather than undercounting
recursive work by measuring only the JavaScript wrapper. Exported API wrappers
attribute counts to the synchronous public entry responsible for the work.
For TS it strips types into private copies before parsing, then adds ordinary
function-entry counters and per-table `memo` calls/misses. The original stripped
body is recovered exactly by removing edits; the generated derivative parses
again. An independent review requested and obtained fail-closed SCC selector and
unique logical-body checks. Missing named probes are reported explicitly.

The counters are not comparable AST-node counts: the compilers use different
term representations and call structure. Within each implementation they show
repetition and phase concentration. TS backend `tele_unbind` is a cached wrapper;
the theory `tele_unbind` count records actual decomposition. `memo_FUNS_calls`
and `memo_FUNS_misses` separate repeated signature requests from recomputation.
The Bend `jd_domains` count includes recursive telescope steps, whereas
`jd_arity` is a signature query entry. `subst`/`env_subst_term` count logical term
visits, not allocations or structurally unchanged reconstructions. No counter
changes are production optimizations or proof of safe memoization.

The report records exact parent/derivative hashes, insertion locations and
counter schemas. Allocation from counters, changed inlining, parser changes and
wrappers perturb execution: never use this run's elapsed time to estimate a
compiler improvement. The clean latency and profile campaigns remain separate.
