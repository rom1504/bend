# State08 diagnostic stage clocks

This measurement instruments private copies of the selected State08 host driver.
It does not change Bend compiler source, generated compiler images, installed
artifacts or the pinned TypeScript checkout. Root runs compiler targets serially
on CPU3 under the existing 1 GiB Node heap / 2 GiB tree RSS / 4 GiB available-memory
floor. Producer and reader work uses CPU0.

The [producer](../../selfhost/tools/performance/phase62/stages/derive-driver.py)
accepts only driver SHA256
`569f17b1e0ccd87da33dd07c2b7a7837f4578cae7d592e646f10eb4c2d2a313b`.
Its 81 insertions produce private driver SHA256
`5fa97cfa626d710ff82ed85ce4ba3978cd139a950328f7f743a5add2b5aa1600`.
Deleting the recorded insertions recovers the complete original bytes exactly.
The producer checks that inverse and rechecks the original source before writing.
The derived driver is adjacent to the ordinary staged driver so all relative
helpers and runtime paths retain their original meaning. Both preparation roles
use the same original/derived host bytes with their own genuine compiler images.

The [method factory](../../selfhost/tools/performance/phase62/stages/make-method.py)
is a small successor of the reviewed Phase62 generation comparison. It retains
prepared Base caches, full output byte comparison against qualified raw modules,
source/image/helper identity checks and guarded serial execution. Stage workers
admit the private driver's derivation and exact bytes before the measured window,
and recheck those identities after compilation. They assert a successful checked
library result and zero incomplete clock intervals. Preparation and byte checks
remain outside the window. All raw outputs stay ordinary library modules; no
runtime benchmarks are executed by this diagnostic.

The [clock](../../selfhost/tools/performance/phase62/stages/clock.mjs) records
monotonic wall intervals with parent IDs. Each event's exclusive time subtracts
its direct children. Exclusive times must sum to the outer first-request window;
root intervals cannot overlap. Function guards use synchronous `try/finally`, and
individual API calls retain their exact expressions, argument evaluation and
return values. Async imports and TypeScript loading remain awaited as before.
No term-level callback or inspector runs inside this diagnostic.

Bend clocks cover API loading, cache I/O, frame header/book/state parsing, byte
digests, tree validation and optional-state admission; source headers, prefix
completion and freshening; checking/completion; context and roots, source
reachability, annotation, emitted reachability, layout checks, foreign modules,
library emission and final assembly. Broad stages are nested; never add their
inclusive times. `driver.source-graph` exclusive time includes both host work and generated
API calls without a separate child marker (namespace resolution, source wrappers,
path helpers and the fallback graph trace). It is loader residual, not pure host
overhead. Cache decode exclusive time includes metadata work not assigned a child.

TypeScript retains its unchanged modules. Worker clocks surround `book_load`,
`book_valid` and `js_lib`. These are coarse boundaries, not a claim that TS has
passes matching every Bend label. In particular, TS parses/checks Base while the
Bend request reads its prepared state. Compare combined loading/checking and full
backend cost before comparing smaller mechanisms. Both sides still execute the
same ordinary library request and their separately qualified complete output
oracle.

The [reader](../../selfhost/tools/performance/phase62/stages/summarize.py) checks
completed successful receipts and clock closure, then emits a disjoint
cache/load/check/backend/request-other partition of `worker.compile`. It walks
ancestry: the API load inside inspection remains part of request-other;
startup API loading outside `worker.compile` does not leak into compilation.
Request-other can include unclocked generated API calls; it is not a CPU-language
classification.
It also retains every fine-stage exclusive value.

These clocks include hook overhead, GC and scheduler pauses. Driver `try/finally`
may change V8 optimization decisions. Their times are diagnostic, never substituted
into clean performance statistics. Compare the whole diagnostic request with
separate same-image clean medians to assess perturbation; single diagnostic runs
cannot isolate clock overhead from ordinary run variation. Revisit a stage if
sampling profiles or clean behavior disagree. There is no new compiler optimization
or speed claim in this method.

## Materialization and execution

The data-only factory was materialized at
`selfhost/build/phase62/generations01/stages-method01`, using the successful
`generations01/preparation/report.json` for B1, B2 and TypeScript. It also derived
private drivers for both Bend roles. No Node or compiler execution occurred in
producer checks; Python AST parsing and exact source inversion passed.

Root should first execute two sources (`numeric-recurrence,test-map-set-ops`)
using `--roles b2,typescript --rounds 1 --warm-requests 0 --mode stages`, then use
`--cases all` for 46 fresh workers if those observations pass. The same method
can add B1 when the generation comparison justifies it. Use a fresh output
directory for every attempt; retain failures with their original status. The
parent method, prepared image/cache files and closed historical evidence stay
unchanged. See the Phase62 report for the actual run results; this file describes
the measurement and does not imply targets already passed.
