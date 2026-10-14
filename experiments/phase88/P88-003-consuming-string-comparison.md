# P88-003: consume comparison inputs without rebuilding them

Final status: accepted for the native image derivative. All1,444pairs pass
Base/native/JS/independent controls; all45 broad C outputs remain exact. Two-round
live native request savings22.4–32.3%. Ordinary JS source keeps its existing
primitive equality contract. [Report](../../implementation/phase88/README.md).

## Initial hypothesis (retained)


Status: focused control preparation; no performance acceptance yet.

The exact Phase87 native image's phase-separated ownership profile identifies
String.order's return continuation as a physical caller of term_drop for 22.4%
of Small's Base samples and 21.8% of all five Lexer request samples. Upstream
String.cmp returns both strings with the ordering, rebuilding equal prefixes;
String.order immediately discards the strings. The compiler calls String.eq
frequently, which reaches this path.

Hypothesis: a first-order consuming comparison in Bend can avoid constructing
the result strings and their later destruction. This is a general equality
operation, not a workload special case. The leaf percentage is attribution,
not a forecast: input traversal and destruction of shared inputs may remain.

Gate: finite Unicode/string-prefix/order/alias controls against unchanged Base,
then an isolated native compiler assembly whose compiler-only String.eq
references use the helper. Retain the ordinary source and upstream bytes; do
not rewrite user inputs or silently remove the JS host's primitive equality
adaptation. Compare full output C and complete request/startup clocks. A future
source integration must account for both execution hosts and their guards.

Evidence starts at `selfhost/build/phase88/ownership-small.analysis.json` and
`ownership-lexer.analysis.json`; sealed copies will be linked in the report.
Reject if native ownership fails, comparison products differ, or complete
request costs do not improve enough to justify another host-specific path.
