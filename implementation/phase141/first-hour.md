# First-hour decision: continue two demonstrated replacements

Checkpoint written at 22:38 UTC on 2026-10-25, 49 minutes after starting. The
decision is to finish integration, not begin a speculative universal-IR rewrite.

The parser replacement removes a mechanically duplicated 34-function grammar.
Its native candidate reproduces its complete 116 MB QBE exactly. A same-source
full request takes 370.351 seconds versus 384.828 seconds in Phase140 N1d
(0.9624×, one ordered pair). Four alternating small-request rounds are neutral
for Lexer/Map and 4.5% slower for the short closure case. These do not establish
a precise global speedup. Six ordinary native program outputs pass the broad
screen; despite its directory name `p141-native-full45`, that invocation selected
six representatives, **not all 45**. Full final coverage remains outstanding.

The second replacement uses Bend's existing static `~` arguments. The complete
comparison family shrinks from 220 to 83 code lines (62.3%). It removes the
duplicated runtime-generic/hand-specialized implementations while retaining one
canonical comparison for each data structure and one statically specialized
list traversal. Closed named policies remain distinct from runtime state.

Evidence before the first-hour gate:

- Independent source checks of baseline, parser candidate, static probe and
  corrected integrated candidate.
- 1,739 exact parser-result comparisons, including errors and metadata; five
  additional inputs hit the hosted stack limit in both versions and are untested.
- 48 checkpoint/edit/error/recovery comparisons against the independent old API.
- Static probe: 50 list pairs and five state cases; migrated family controls:
  19 rows covering 501 record pairs plus list checks with independent truth tables.
- Small native recursive-template probe returns the independent expected result.
- Native proxy: static/handwritten medians match at 32/256/2,048 elements;
  runtime callbacks take 1.81–1.88× as long. Actual dispatch reaches the same
  local-recursion mechanism; the static loop has no runtime `rt_apply` call.
- Twelve complete integrated QBE products match independently emitted earlier
  products, including edited sources. Fresh/warm plans and error recovery pass.
- Source review preserves 108 published roots, protected verifier bodies and
  existing proof declarations. No new mathematical proof is claimed.

Combined source02 is 63,580 physical / 46,202 code lines, versus Phase140's
64,408 / 46,808: **828 physical and 606 code lines removed**, including 76 code
lines from consolidating test helpers. It has 68 fewer definitions. This is
1.3% of the full experimental compiler, not progress to a 10k total by itself.
Qualified Phase137 remains 58,569 physical lines and is unchanged.

Negative evidence is retained: the first hosted corpus worker exceeded its OS/
JavaScript stack configuration; the bounded rerun reports both-version stack
failures explicitly. Integrated source01 failed because a new template appeared
after its caller. Source02 fixes only the declared insertion order. Neither
failure is counted as a correctness pass.

Finish native integration and bounded complete-request gates. Do not spend the
remaining budget adding unrelated recognizers or claiming unsupported whole-
compiler reductions. The strongest new idea is sharing *statically specialized
algorithms*, while retiring their handwritten copies; it is not a runtime visitor.
