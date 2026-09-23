# Phase 6 ten-hour campaign report

Status: started 2026-09-23 05:06:12 UTC; authorized deadline 15:06:12 UTC.
Baseline commit `a6459af`; [design](../../design/phase6/ten_hour_campaign.md).
The [opening experiments](report.md) retain their completed historical status.

Baseline: 363.392s full-source process wall versus TS 60.248s (6.03×); 16,509
production Bend lines; 318 strict check failures, 444 exact frontend differences,
16 phase differences, 919/919 positive frontend fixtures. Estimates in the design
are hypotheses. No new improvement is claimed at this starting checkpoint.

Root coordinates isolated source candidates, independent review, combined gates,
controlled timing and release promotion. All prior failed candidates and the
current default compiler remain preserved. Subsequent entries record actual
changes, measurements, failures, size deltas and remaining limits.

## First isolated candidates

The production release remains unchanged at this checkpoint. Reviewed candidates
are preserved separately with checked builds, focused gates and raw failures:

| Candidate | Established result | Remaining promotion gate |
| --- | --- | --- |
| [Native immediate fields](native-scalar-words.md) | 255-field C shrinks 3,716,568→174,389 bytes (95.31%); the formerly timed-out program now executes; 17 paired JS/native positives, overflow and worker-count boundaries pass | Combined backend gates and controlled timings |
| [Prefix/erased semantics](prefix-semantics.md) | Focused classification agreement 78→140/140; exact33→98 with no lost exact; 20graph controls and36 paired runtime observations pass | Combined frontend and final source gates |
| [Multiline lexer cursor](lexer-cursor.md) | Focused exact6→18/20;36token controls pass; known escape-first-error residual retained | Combined frontend gate |
| [Obsolete freshening](obsolete-freshening.md) | 184 Bend lines removed; selected checked/derived API bytes and54roots unchanged | Combined source gate |
| [Declared missing imports](import-phase.md) | Ten phase differences repaired; five strict diagnostic failures remain | Combined frontend gate |

Source provenance v2 has an isolated 307-observation gate:112 of150 missing-excerpt
cases become exact, all141 previously exact negatives remain exact and16custom
cases are exact. A v1 deepest-location regression was found and retained before
v2 repaired it. Additional metadata increases cache size and allocation, so a
controlled accepted-workload pilot will decide whether this representation can
be promoted or needs revision. These are candidate counts, not new release totals.

The authoritative structured-error candidate builds and passes the maintained21
controls, retaining seven known exact differences. It reduces its three Bend
modules by140lines and preserves the original KChecked failure instead of
rechecking a rejected definition. Broader exact-result and host compatibility
gates have not run yet. No speed gain is claimed at this checkpoint.
