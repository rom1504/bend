# Same Bend source, hosted JavaScript and native QBE execution

Compact initial receipts and selected counts:
[execution-initial-evidence.json](execution-initial-evidence.json).

Status: the pilot, four-pair clean comparison, warm-engine diagnostic and
counter observations completed under the coordinator's single target lane.
These are compilation latencies for small requests, not generated-program
runtime or full-compiler build measurements.

| Request | Native median | Same-source JS median | Paired native/JS geometric ratio |
|---|---:|---:|---:|
| Lexer | 1.168s | 7.396s | 0.1604 |
| Map churn128 | 1.801s | 11.805s | 0.1528 |
| Closures256 | 0.389s | 2.772s | 0.1407 |
| Compiler-index slice | 2.141s | 13.785s | 0.1553 |

All 30 observations match complete ordinary QBE. The first three cases use
four alternating pairs and frozen products; the additional compiler-index slice
uses three alternating pairs and a fresh native oracle checked independently
by the hosted execution. Its three pairs are not exactly position-balanced. The native implementation is approximately
6.2–7.1 times faster than the same Bend compiler hosted by Bun on these cases.
The source, policy, source paths and prepared Base are fixed; this is **not** a
ratio against the upstream compiler. Peak child RSS across four pairs is
43.5/46.0/41.4MB native and 254.8/343.5/138.2MB hosted. Those peaks include engine
startup and do not isolate live compiler data. Complete clean receipt:
`selfhost/build/phase145/execution-clean01/report.json`. The compiler-index
receipt is `selfhost/build/phase145/execution-index01/report.json`, with native
oracle `selfhost/build/phase130/p145-index-oracle01/report.json`. Its exact
1,105,746-byte QBE agrees throughout; peak child RSS is 47.9MB native and
322.6MB hosted. This is compilation of a real compiler-derived slice, not
execution of a complete compiler or a scalability curve.

Two order-balanced Lexer pairs give native median 1.1874s and hosted JavaScript
median 7.4420s: native/JS 0.15956, or approximately 6.27 times faster native execution.
Both products match the complete qualified QBE. See
`selfhost/build/phase145/execution-pilot01/report.json`. JavaScript median API
import is 0.206s, prepared-Base decode 0.765s, frontend 1.295s, backend 3.942s,
registry 0.444s and Bend cursor 0.731s. Those are observed cold engine phases;
they do not isolate JIT work. An explicitly warm engine experiment is prepared
to test that issue rather than assuming import time explains the whole gap.

The corrected warm diagnostic passes in `execution-warm02`: first iteration
7.293s, then 5.601s, 5.607s and 5.196s, median 5.601s. Every iteration performs
fresh Base preparation and complete checking/emission and matches all QBE bytes.
The warm median is approximately 24.7% below the cold-JS pilot, but remains far
above native's 1.187s. These clocks differ: a warm iteration omits a new process
and retains JIT code, so their quotient is not a matched cold speed claim. Warm
phase medians are Base 0.687s, frontend 0.769s, backend 3.178s, registry 0.349s
and Bend cursor 0.435s; API import falls to approximately 56 microseconds.
Memory peaks at 483.6MB for the entire four-iteration process.

All three counter requests match complete QBE in
`selfhost/build/phase145/execution-counts01/report.json`. Each calls
`p112s_verify` twice, `p113e_verify` once and `p134v_commit` once. Raw statement
visits and distinct statement object identities are 17,696/9,908 for Lexer,
28,312/14,650 for Map and 1,798/936 for closures. These counts alone do **not**
prove repeated judgments: the same instruction can be examined with another
schema, live environment or purpose. A separate strict diagnostic fingerprints
the complete static-program verifier argument before/after synchronous checking.

Backend lookup costs are substantial even on these small requests: Lexer and
Map call `index_find` 931,026 and 856,606 times, with 3,033,872 and 3,566,756 actual
character comparisons inside `p88_string_eq_go`. These are generated-JavaScript
events, not a native instruction profile. Base's empty initial counter group
means the selected hooks omit decoder helpers; it does not mean Base preparation
does no work. Native counters and native stage boundaries cover that separate cost.

The stricter Lexer observation now passes in
`selfhost/build/phase145/execution-verified01/`. Both static-program checks
receive **the same object identity and the same complete data contents**:
27,479 distinct objects, hash `56e41a1f…`, unchanged before and after each check.
The first caller is `p114s_open`; the second is
`p113a_verify → p113e_verify`. Full QBE still matches. This establishes a concrete
duplicate judgment under the fixed current verifier, rather than inferring it
from similarly named phases. It does not validate a persistent certificate,
forged-cache acceptance, or removal of the independent final verifier. A future
optimization would need an explicit immutable-artifact provenance contract.

## Architectural implications

1. **Preserve checked immutable artifacts across adjacent stages.** The strongest
   observation is the exact same static-program verification twice. The next
   experiment should carry the successful raw/static judgment with its immutable
   input and verify only genuinely changed direct-function obligations, while
   retaining an independently justified final boundary. This is narrower and
   more falsifiable than a large optimization-cache or universal-IR project.
   No verifier has been weakened or omitted in this investigation.
2. **Make the verifier's complete environment cheaper.** Lexer/Map execute
   129,519/107,792 `p111v_get` entries and 51,717/46,802 `p111v_put` entries in the
   backend, in addition to almost a million index lookup entries each. A compact
   typed local environment or once-resolved IDs deserves a complete-judgment
   experiment including schema construction, joins and teardown. Faster isolated
   lookups or an array of boxed `KDef` records would not demonstrate that gain.
3. **Retain constructor and ready metadata when its semantic input is unchanged.**
   Backend `p113e_originals` runs 2/4/2 times and `ns_ctor_index` runs 3/5/3 times
   across Lexer/Map/closures. The extra Map work may reflect legitimate late
   construction/retry contexts. Exact readset/input witnesses are required before
   treating those calls as duplicates; the present counter totals do not suffice.
4. **Separate fixed acquisition and request costs.** Native Base/carrier decoding
   is approximately 0.23s on each small request, while hosted Lexer preparation
   is 0.765s. A retained prepared Base can improve development requests without
   removing significant work from a multi-minute full compiler build. It should
   be reported as an explicit session policy, with invalidation and teardown
   charged, rather than hidden inside a nominal cold benchmark.

The pilot does not support switching the research compiler to hosted JavaScript
for speed: native is already substantially faster on this cold request. Warm
engine measurements show startup/JIT contributes but does not account for the
whole observed gap. Nor do these four small workloads establish a compact-IR performance
ceiling or a path to a 50-second cold compiler build by themselves.

The fixed source is the qualified Phase144 final04 compiler, SHA
`865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed`.
Its existing independently checked JavaScript library runs under pinned Bun
1.4.3; its qualified N2 runs with the exact serial reference-count runtime,
one Bend heap mutator, `--threads 1 --gpu off`. The API and executable implement
the same ordinary compilation policy. This does not compare Bend with a newly
written JavaScript compiler, nor compare JavaScript and C backend program output.

The initial three requests are the frozen Lexer, Map churn128 and closures256
programs under `selfhost/build/phase88/broad-fixtures03/`. Complete expected QBE
already exists in `selfhost/build/phase144/final04-small-products01/`; no source
path normalization or output filtering is allowed. The compiler-index slice is
the fourth request: the retained21,869-byte `predicate-proxy-source01/positive.bend`
contains real compiler index code and the historical finite workload. It used
a fresh native ordinary oracle, then exact checked-hosted output comparison.
It is not a substitute for a full compiler scalability measurement.

## Comparable clocks

Every observation launches a fresh process. Both paths read the same actual
source, Base path and authenticated compact prepared-Base carrier. They prepare
the Base inside the measured process, check the request, optimize it and write
complete QBE to a fresh file. Parent-side hashing and full byte comparison occur
after the child clock. No previous request's checked state is retained. OS caches
are not flushed. Two or four alternating JS/native pairs balance start order.

Whole-child wall time and wait4 user/system CPU and peak RSS are the primary
comparisons. API acquisition, prior native self-hosting and machine building are
excluded and explicitly remain sunk acquisition costs. The JavaScript process
includes API import and small observer/metadata overhead. It uses natural GC;
it does not force a final collection. Native reference-count work and actual
CLI output/exit behavior remain included. Consequently an apparent JavaScript
win is not proof of equivalent memory management or eventual reclamation cost.

Hosted diagnostic clocks separate API import, source/Base/carrier reads, Base
preparation, complete frontend, backend, emission registry, Bend cursor calls,
UTF8 encoding and writes. Render-inclusive time contains the latter three, so
these are nested, not additive independent intervals. Native stage observations
are a separate diagnostic derivative managed by the profiling lane. A fixed
Base decode cost can dominate small requests without explaining full cold builds.

## Reversible operation observations

`execution/prepare-v01.py` creates a diagnostic API copy by inserting hooks into
selected **internal generated declarations**, not merely exported entry points.
Removing the exact hooks must reconstruct the checked API byte for byte. It does
not regenerate or edit compiler source, change the production API, or omit any
checker/verifier. Instrumented execution must still match complete QBE.

The selected declarations cover lookup/indexing, string predicates, checker and
term entry points, raw/direct verifier instructions, schema/live and ready-table
construction, deep equality, optimizer passes and rendering. A distinct hook at
the actual `Char.is_eq` site counts string-predicate character comparisons.
Explicit generated loop hooks avoid mistaking a tail loop for one source visit.
Weak identity sets distinguish first/revisited term or instruction objects for
the selected entries within each phase. They are identity observations, not
structural equality or a count of all unique Bend values.

All counters are phase-separated: Base, frontend, backend, registry, rendering.
An entry count is not an instruction count; initial string UTF16 length is not
the number of characters inspected; loop iterations may include terminal tests.
Hooks change JavaScript execution, JIT behavior and GC. Their timings must never
be merged into clean speed ratios. The unchanged native runtime's sixteen
operation channels measure different events and cannot be equated numerically
with these source-level events.

## Reproduction

Methods live in
`selfhost/tools/performance/phase145/execution/`; the initial frozen plan is
`selfhost/build/phase145/execution-plan01/plan.json`. The supervisor accepts
`--mode clean --rounds 2` or `--mode counts` and an optional `--case lexer`.
Use the existing Phase111 guard on the coordinator's CPU3 lane,2GiB RSS,
16GiB available-memory floor,64MiB file cap and a bounded deadline. The pilot is
two Lexer pairs; only after it passes should the other cases and counter runs
proceed. Every failed pilot remains preserved under its original output directory.

The optional `warm-v01.py` diagnostic retains only the loaded API/JavaScript
engine across one warmup and three observed iterations. Each iteration re-reads
and prepares Base and input and writes a complete new product. Its times cannot
replace fresh-process observations.

The first warm observer **failed** its product gate: this Bun build reused the
observer module despite distinct URL query suffixes. Only the first iteration
compiled anything; later near-zero intervals lacked output files. The failure
is preserved at `execution-warm01` and is not a speed result. `warm-v02.py`
instead creates four different absolute observer files with byte-identical
contents and identical original API import paths. Every iteration must produce
its own complete oracle-matching QBE before its time is accepted.

The separate `prepare-verified-v01.py`/`run-verified-v01.py` diagnostic wraps the
actual synchronous `p112s_verify` call. It records a WeakMap root identity and
a complete structural hash of the sole argument before/after execution, plus
the actual synchronous verifier caller path. The strict iterative data walker
includes all own data fields and rejects unsupported functions, nonfinite
numbers, symbols, accessors, non-data prototypes, sparse arrays and cycles.
Shared subgraphs are memoized within one fingerprint, without confusing object
identity with structural contents. The content hash deliberately does not encode alias topology, object property
attributes or array prototypes. The same actual root identity is separately
recorded. `completed` records exit through `finally`, not a captured successful
return String; the complete accepted oracle-matching request supplies the
surrounding success evidence here. A real reusable certificate must bind the
returned result and every relevant context explicitly. This is evidence about
the fixed invocation, not a proof-carrying cache or a theorem that verification
can be skipped. Independent source review: [evidence-review.md](evidence-review.md).
