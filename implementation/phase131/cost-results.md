# Phase131 cost accounting

At the 00:56:25 UTC cutoff, the campaign had run **175.68 minutes** since the
coordinator's 22:00:45 start. The requested three-hour minimum ends at 01:00:45.
All 372 recorded Phase131 guards were closed; no unfinished guards were omitted.

| Lane | Guards | Summed guarded wall minutes | Main purpose |
|---|---:|---:|---|
| CPU3 | 104 | 71.72 | Native acquisition, clean comparisons, profiling and native gates |
| CPU4 | 91 | 2.52 | Proofs and law controls |
| CPU5 | 61 | 11.81 | Separate correctness and investigation work |
| CPU6 | 116 | 23.08 | Separate correctness and investigation work |

Summed guard wall is 109.13 minutes. The union of guarded intervals is **89.01
minutes** because lanes overlap. The other **86.67 elapsed minutes** include
unguarded metadata/storage work, planning, agent work, communication and gaps;
they are not a measured amount of model reasoning. Guard sums are not CPU time,
agent tokens, quota or monetary cost.

| Recorded purpose | Guard wall minutes |
|---|---:|
| Full compiler acquisition + self-emission + reproduction | 35.92 |
| Full compiler machine builds | 1.24 |
| Two full compiler-source profile captures | 12.45 |
| Other profiling/instrumentation | 5.52 |
| Independent source checks | 7.13 |
| Native semantic gates | 4.94 |
| Clean compiler comparisons | 2.60 |
| Clean proxy timing | 0.70 |
| Proxy emissions/builds | 17.25 |
| Proof/law controls | 2.52 |
| Remaining controls/diagnostics | 18.86 |

The native compiler image acquisition/qualification path consumes materially more
time than the controlled three-request timing screens. This supports making the
next native development loop incremental, while retaining complete qualification
at justified checkpoints. The two full-source profiles cost 12.45 guarded minutes
and changed the next optimization target from a short-request guess to the actual
`nc_ctor_owned`/lookup/membership workload.

There are 319 successful guard exits and 53 nonzero/incomplete outcomes. Of the
latter, 21 have explicit negative-control path labels; 32 do not. Labels record
intent, not semantic verdict: inspect the retained proof/control reports before
calling an outcome a failed optimization. All records remain in the evidence.
Peak observed process-tree RSS was 2,923,991,040 bytes.

The final incremental archive adds 742 small evidence files in 115,704 compressed
bytes. Every archived member hash and guard-row sum was checked. It depends on the
two earlier archives; no compiler images or large generated outputs are included.
[Exact totals, categories, method pins and archive chain](cost-results.json) retain
reproducibility. The versioned [complete guard ledger](cost-evidence/report.json) and
[three-archive identity index](cost-evidence/index.json) preserve the complete evidence chain.
