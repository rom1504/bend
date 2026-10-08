# Occurrence summaries: remove repeated native analysis

[Design](../../design/phase68/occurrence-summary.md) ·
[P68-009](../../experiments/phase68/P68-009-occurrence-summary.md).

Templates05 passes all fifteen native request observations, but exposes a
shared algorithmic bottleneck. B2 `nc_occurs_list` has 528/543/672 ms self samples;
B1 Numeric has 1,322 ms inclusive occurrence-list time. The
[comparison receipt](evidence/native-requests05.json) keeps clean requests and
diagnostics separate. B1 is slower than the Phase67 screen while B2 is faster;
intervening native changes and separate one-sample epochs prevent isolated
attribution to template selection.

The source repeatedly calls `nc_occurs(t,id)` for each environment binding,
including independent live and dead passes over the same term. The selected
prototype collects occurrence IDs once, using the existing exact compressed
index, then queries that summary. `nc_lower_to` shares an ordered live/drop
partition. Standalone live and share helpers also use summaries; an empty
environment skips scanning. The parallel occurrence consumer retains its old
predicate. No host algorithm, public root, persistent cache format or `NC_Code`
change is introduced. The source cost is +70 Bend lines and one small partition
type. It still rebuilds summaries of overlapping subterms during recursive
lowering; it removes the environment multiplier without claiming to eliminate
all repeated analysis.

Independent source review passes the full-ID index interpretation and exact
Var-as-leaf policy. The actual Uses08 strict build passes. Focused controller v2
passes 35 terms, 67 IDs, 2,345 occurrence queries and 210 partition/share cases,
including ID extremes, duplicate environment rows, malformed Var children,
compact literals, metadata, immutable reuse and empty-env non-demand. The
unused `nc_drop_dead` wrapper is removed from the generated image by reachability;
the diagnostic checks its verified field projection of the actual compiled
partition, rather than inventing a replacement analysis.

The first controller run failed before helper cases because it expected that
dead wrapper to be emitted. Its consumed bytes were restored exactly to the
receipt hash (`f426c396…2060`); the reviewed correction is separately preserved
as `controls-v2.mjs` (`8ac67f46…5a17`) with an exact derivation. A data-only C-plan
preparation also stopped before producing files because the prior report used
`rows/equal`; its preserved v2 reads the actual schema and verifies the emission
and plan joins. Neither failure is a compiler semantic failure.

The frozen three-case C plan (`uses-c08/plan.json`, `9653036d…ac3e`) compares the
actual Uses08 outputs with runtime-qualified06 C already reproduced by07. It
changes only the actual API in the prior recipe, retains every other input and
uses the same guarded emission worker. Complete output equality and useful
B1/B2 request gains remain promotion gates; preparation and focused controls
alone establish no performance result.

Uses08 subsequently passes all three complete-C comparisons. Its B1 acquisition
requests decrease from 2,772→2,036 ms Numeric, 3,162→2,254 ms Array and
3,941→2,895 ms Lexer, roughly 27% less time. The
[receipt](evidence/occurrence08.json) binds actual images, frozen source, helper
controls and full C bytes. These are separate single observations, not a balanced
final speed score. The next actual B2 prototype uses Inline09, which retains
this analysis change; its performance and final qualification remain pending.
