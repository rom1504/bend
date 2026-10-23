# P130-002 — scalar order source ceilings: rejected

Question: does computing only the comparison result avoid meaningful work from
String.cmp's preserved roots/product result? Use the unchanged qualified compiler,
retained shared String pairs, Unicode/prefix/alias controls and independent
lexicographic digests. No compiler image rebuild per candidate.

Cmp-result rewrite:133→149ms (1.1203×); direct-U32 rewrite:525→640ms (1.2190×).
Five alternating paired rounds each; repetitions differ, so compare only within
its own pair. Ordinary outputs pass. Supplemental69-line controls were not run
after the performance rejection. Initial IO.now units were mislabeled; raw
milliseconds and wall observations establish corrected seconds without changing
ratios. Future runner v2 uses milliseconds correctly.

Static machine inspection shows borrowing was already admitted. Rewrites change
loop state and scalar/owning fallback behavior, not just product projection.
Both Cmp readers still call generic U32.cmp. These negatives do not falsify a
projection composed with the existing reader, but they do not justify adding a
new optimizer capability either.

[Report](../../implementation/phase130/README.md),
[scalar evidence](../../selfhost/tools/performance/phase130/scalar/RESULTS.md),
[machine inspection](../../selfhost/tools/performance/phase130/scalar/v05-inspection/README.md).
Raw observations: `selfhost/build/phase130/scalar-timing01/report.json` and
`scalar-u32-timing01/report.json`. Preserve all parser/checker failures and the
first omitted-kc extraction failure; no gates were weakened.
