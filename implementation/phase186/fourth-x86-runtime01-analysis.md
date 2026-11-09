# Fourth assembly screen: unstable generic-row interval

The apparent 46.4% generic-row gain is contaminated and must not be claimed. The exact first-candidate binary and command from the earlier campaign recur as `before`; its first timed sample is 251 ms for 667 repetitions, agreeing with the earlier 250/250/251 ms. The later samples rise to 454/453 ms. C rises from 320/321 to 631 ms, while the new candidate rises from 249/248 to 425 ms. Subsequent ray pilots remain slow briefly, then recover before timing. Separate role medians select different performance regimes.

All correctness and count checks pass. The intervals are far above millisecond resolution. Slow-process CPU time remains close to wall time, weighing against ordinary off-CPU descheduling, but no frequency, thermal, SMT or shared-resource telemetry was retained. The physical cause is unresolved. The first normal round gives a provisional 3.26% reduction and historical C normalization gives 3.18%; neither replaces replication.

The **remaining nine-case diagnostic** has candidate/before GM **0.926368**, or **7.36% less runtime**, with before/C 4.1043 and candidate/C 3.8021. This is a separate nine-case result, not a repaired ten-case result.

The third QBE five-case candidate is mixed and negative overall: GM runtime rises 1.72%; tree +4.65%, map +15.89%, record +14.01%, text −11.56%, generic −10.96%. Rotated sample spread lacks the large temporal discontinuity seen above.

A fresh authenticated three-role, one-case manifest is ready at `selfhost/build/phase186/fourth-x86-generic-recheck-merge01/manifest.json`. The root executor can use six rotated rounds and a 30-second inner deadline under its CPU3 guard. No targets were run during this analysis.

Exact artifact identities, retained stdout mtimes (chronology only), sample/pilot values, guard pins, recomputed summaries, and output validation counts are in [fourth-x86-runtime01-analysis.json](fourth-x86-runtime01-analysis.json). Original reports remain unchanged.
