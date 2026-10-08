# Phase65 stage clocks

This is an explicit successor of the consumed Phase64 stage tools. It profiles
`numeric-recurrence`, `lexer`, `test-map-set-ops`, and `raytrace-active` through the
normal private driver path. The prepared baseline is genuine Phase64 State09 B2
with its admitted 95 exports. Export membership and helper identities come from
the validated preparation; the stage tool does not substitute an API or helper.

The selected driver still decodes its own frame4 cache. The only new cache clocks
surround its existing `decode(bookBytes, ...)` and `decode(preparedBytes, ...)`
calls. They distinguish book and prepared payload decoding without modifying
helper internals. `driver.base-cache` remains the inclusive Base total. The
summary also reports observed `book_context_world` and `book_context` calls.

After the four-case baseline preparation completes, root can create a fresh stage
method and insertion-only diagnostic driver copies. This command is data-only:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/stages/make-method.py selfhost/build/phase65/latency-method01 selfhost/build/phase65/stage-method01 --preparations selfhost/build/phase65/baseline-state09/preparation/report.json
```

Run eight fresh diagnostic workers (four cases, baseline and TypeScript). Use the
same bindings file used to create the preparation, represented here by
`selfhost/build/phase65/baseline-state09/bindings.json`:

```sh
python3 -B selfhost/build/phase65/stage-method01/run.py selfhost/build/phase65/baseline-state09/stages --bindings selfhost/build/phase65/baseline-state09/bindings.json --preparations selfhost/build/phase65/baseline-state09/preparation/report.json --cases numeric-recurrence,lexer,test-map-set-ops,raytrace-active --roles baseline,typescript --rounds 1 --warm-requests 0 --mode stages --seconds 900 --child-seconds 180
```

The launcher must start unlocked and without an outer CPU affinity or guard. Its
existing guard runs targets serially on CPU3 with the maintained memory limits.
Reuse the preparation: stage mode does not prime new caches or alter originals.
Each Bend worker loads the private diagnostic driver and wraps the actual imported
`module.default` synchronously; it never passes a custom API to `inspect`.
Existing copied API, runtime, helper, source and cache hashes remain bound and
full raw module output must equal the prepared oracle.

Summarize the completed diagnostic receipt on CPU0:

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase65/latency/stages/summarize.py selfhost/build/phase65/baseline-state09/stages/report.json --out selfhost/build/phase65/baseline-state09/stages-summary.json
```

Nested exclusive wall intervals partition the instrumented first request. They
include observer overhead and are not clean latency estimates. Never add nested
inclusive times. Keep separate clean workers for speed claims; TypeScript's
load/check/emission intervals are not identical semantic boundaries to Bend's.

`factory-derivation.json` records each exact parent/output transformation. The
clock implementation is byte-identical. Python syntax and insertion anchors were
checked against the frozen State09 driver without running the factory or targets.
All Phase64 tools and results remain unchanged.
