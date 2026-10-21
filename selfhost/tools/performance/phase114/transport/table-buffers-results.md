# P114-010 result: coverage closed, selection deferred

The optional table-buffer overlay passed its checks, but the matched pair
improved by **2.3794%**, below the preregistered **3%** threshold. It remains
deferred. Selected source02 and the qualified native image are unchanged.

The checked API and exact composition admission passed. All 13 ordinary String
policy cases, both complete-output source controls, and all 24 timed outputs
passed. The first host control adapter expected boxed Bool values; the checked
API returns native JavaScript Booleans. That attempt failed after 0.331 seconds,
before native jobs. Its receipts and v1 adapter remain preserved alongside the
corrected v2; this did not require a Bend implementation change.

Three rotated rounds measured the same two previously seen frozen workloads:

| Workload | Parent median | Candidate median | Reduction |
| --- | ---: | ---: | ---: |
| Tree bitonic | 339 ms | 333 ms | 1.77% |
| Expression 128 | 134 ms | 130 ms | 2.99% |

The pair's geometric slowdown against same-run upstream was 4.179093× →
4.079657×. This is a two-workload screen, not a broad-corpus or compiler-time
result. The clock is the existing in-program interval, excluding startup,
initial validation, warmups and compilation.

Actual emitted H worker bodies confirm the intended coverage change:

| Worker | QBE frame-helper sites | Assembly frame-helper sites |
| --- | ---: | ---: |
| Tree `warp` | 1 → 0 | 1 → 0 |
| Tree `scan` | 1 → 0 | 1 → 0 |
| Expression `eval` | 3 → 0 | 3 → 0 |

Only these two of 802 tree function bodies and one of 613 expression function
bodies changed. Every other function body was byte-identical. Within the
changed H workers, the ordered sequence of other runtime-helper calls stayed
identical. Each removed call became the existing transport template: load SP,
copy the captured word, store the continuation FID, advance SP by 16 bytes, and
produce status zero. The required capture/frame work remains. These are static
site counts, not dynamic invocation counts.

The parent role is `p114-final-screen01`, whose measured binaries were produced
from final-source01. The candidate is the optional overlay on final-source02;
the companion JSON pins both actual compiler sources and products explicitly.
The source02 namespace stack repair remains part of the selected compiler.

[table-buffers-results.json](table-buffers-results.json) pins the measurement
report, API/admission, both control versions, failure receipts, ordinary
observations, QBE, assembler output, linked binaries and unchanged runtime
object. Its static comparison records each H worker and body digest. This
review read existing artifacts only; it ran no compiler or program targets.
