# Phase41 elapsed-time account

The closed [campaign ledger](../../selfhost/build/phase41/campaign.jsonl) and
[mechanical report](../../selfhost/build/phase41/accounting-final01/report.json)
cover 16:39:33–17:57:49 UTC on 2026-10-03: **78m16s** through raw closure.
Preservation, narrative consolidation and publication follow this boundary and
are reported separately. The raw ledger is now immutable.

| Quantity | Time |
|---|---:|
| Wall interval through raw closure | 78m16s |
| Recorded enclosing process intervals, summed | 34m03s |
| Union of process intervals | 34m03s |
| Remaining unclassified wall interval | 44m13s |
| Checked-build start through first actual screen | 3m23s |
| Portable fast-five preset, enclosing | 17.03s |

The 44m13s residual includes investigation, editing, review, orchestration,
context recovery, agent turnaround and tools not captured as experiment jobs.
It is **not measured idle time or model latency**. Agent CPU/token telemetry is
unavailable. Stage windows below overlap that residual and process activity;
do not add these windows to process time.

| Observed stage window | Minutes |
|---|---:|
| Initial investigation and saved-output prototypes | 21.14 |
| Checked build through first actual screen | 3.38 |
| Semantic validation and compiler-cost preparation | 35.63 |
| Compiler-cost run, final timing, profiles and installation | 15.12 |
| Closure preparation | 3.01 |

| Recorded process category | Seconds |
|---|---:|
| Other semantic owners, preparation, preflight and audits | 1003.001 |
| Frontend comparison, enclosing | 437.142 |
| Four-source compiler-cost sampling | 253.324 |
| Program screens, final timing, profiles and portable smoke | 207.035 |
| Installation and final audit | 60.700 |
| Checked B1 build | 44.661 |
| Prototypes, fixture work, freezing and source accounting | 37.486 |

Five failed jobs used 17.282 seconds: one deep-tree oracle mistake, one saved-JS
sequence-expression grouping mistake, one sandbox EPERM, one fixture binder
error, and one double-map oracle mistake. All originals remain preserved. There
was one checked compiler build and no rejected compiler-image rebuild. Two Sol
review dispatches failed for capacity; Luna performed fallback review. These
agent dispatch delays are not included in process totals.

Eight successful subagent owners contributed: four Sol6.1/medium implementation
and validation owners, two Luna/low evidence/research owners, one Luna/medium
profile owner, and one Luna/high review fallback. Root alone ran heavy jobs;
normal jobs used a 1 GiB Node heap / 2 GiB tree RSS ceiling, with the two-worker
frontend allowed 3 GiB aggregate RSS and a 2 GiB free-memory floor. No OOM or
resource-limit termination occurred. More simultaneous benchmarks would have
contaminated timing and increased memory pressure.

The frontend owner ran the exact 3026 + 196 comparisons in 437.028 seconds,
versus 821.743 seconds historically, a 46.817% reduction. This is not a controlled
same-image worker-count experiment. The final runtime selection was narrowed
to three changed points plus three byte-identical controls after proving 42/45
module identities. That saved a broad timing sweep while preserving full
semantic integration. This campaign therefore differs from Phase40's workload;
its shorter wall time does not establish a causal model/team speedup.

The main remaining process opportunity is the 21-minute setup and the large
unclassified interval. Give owners a short delivery format and permission for
tiny independently bounded oracle checks before handoff. Keep one build after
review, preserve stable semantic owners, and run broad gates once after the
candidate freezes. Do not add more agent slots without independent work ready.

Capture and independent reopen/source verification run outside the closed ledger;
see [preservation receipts](preservation-run01/run.json),
[verification receipts](preservation-verify-run01/run.json), and
[publication timing](publication.json). They are not hidden inside benchmark time.
