# Phase92: broad products and final comparison audit

Both native stages produced the exact expected complete C for **45 catalog
points from 23 original programs**: 90/90 compiler observations. All 45 shared
C products then built with the pinned Clang O2 and executed with the expected
stdout, one CPU thread and GPU off. This establishes finite product continuity
and execution correctness; it does not measure generated-program speed.

The completed [continuation report](../../selfhost/build/phase92/broad02/report.json)
has SHA256 `f5f8df9672b6369b265915760854e6116299ffcb41d2623aad9847f889a4e70d`
and 1,466,512 bytes. An independent offline audit rehashed 715 distinct files,
compared all 90 C files byte-for-byte with their retained current oracles,
verified the actual process receipts and request clocks, and checked all 45
executable identities and stdout observations. No additional target was run.

The original [broad01 failure](../../selfhost/build/phase92/broad01/report.json)
remains intact: its disk reserve stopped the final request **before launch**.
The continuation reused exactly its 89 successful observations, ran only the
missing B2 request, then ran 45 builds and 45 executions. The parent counter
`targetJobsRun:90` counted the pending row; it was not 90 actual executions.
The continuation explicitly records 89 earlier compiler jobs and 91 new jobs.

## Compiler timing, with the clock boundaries retained

| Comparison | Request ratio | Process ratio |
|---|---:|---:|
| B2 / B1, six-source screen, two rounds | 1.203× | 1.444× |
| B2 / B1, closed45, one round | 1.195× | 1.373× |
| B2 / B1, full self-source, one observation | 1.085× | 1.085× |

Ratios are elapsed numerator/denominator; smaller is faster. The broad ratios
are equal-case geometric means and were recomputed independently. Because
their last pair spans a disk-reclamation pause, the six-source screen remains
the primary small-workload timing evidence. The native algorithms, frozen Bend
source, prepared Base and request assets are identical between B1 and B2;
their compiler executable backends differ.

| Full self-source | Request seconds | Process seconds | Emitted C bytes |
|---|---:|---:|---:|
| TS/Bun | 48.394 | 48.659 | 17,764,676 |
| Native B1 | 140.262 | 140.944 | 38,614,882 |
| Native B2 | 152.191 | 152.984 | 38,614,882 |

Thus native full-self requests take **2.898× / 3.145× TS/Bun**, respectively.
Each output matches its own complete-C oracle; TS emits its upstream backend
product, while both native stages emit the same own-backend product. These
are end-to-end compiler comparisons, not identical-output lowering costs.

Prepared native Base is outside the request clock and inside process time.
TS loads/checks Base within its request. The separate uncached Small control
makes that distinction visible: native B1/B2 process times are **1.672/1.891 s**
versus TS/Bun **0.513 s**, or **3.257× / 3.684×**. Each is one observation;
the cached screen must not be presented as universal startup performance.

## Scope and final collector review

The [scoreboard](summary.json) correctly leaves fresh generated-program speed
unset. The original C12 batch wrappers import additional modules unsupported
by this single-Base native entry; their historical 1.067× runtime ratio cannot
be transferred to these closed45 sources. Neither this corpus nor exact C
identity establishes unrestricted conformance, GPU behavior or parallel speed.

No arithmetic or evidence discrepancy was found in the final collector output.
Its 227 actual guarded jobs, 1,176.503 seconds of target wall time and
1,695.535-second campaign span agree with the raw receipts. The guards have
no overlap, resource termination or timeout; the one prelaunch disk stop is
preserved separately. These totals include suite controllers and their
descendants, not an additional count of every unguarded child, agent work,
documentation time or quota usage. No compiler source changed in this phase.
