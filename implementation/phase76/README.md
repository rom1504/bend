# Phase76 native compilation work reuse

In progress. Baseline Phase75 remains installed. No new performance or parity
claim. See the [design](../../design/phase76/native-work-reuse.md).

Initial read-only attribution of the selected Phase75 profiles finds occurrence
analysis on about 7–8% of B2 sampled CPU and formatting on about 10%. B1
occurrence analysis is around 13%, with substantial anonymous/trampoline cost.
These are overlapping diagnostic samples, not clean speed measurements.
Occurrence summaries alone cannot deliver the requested gain; the prototype
must evaluate wider reuse before a broad native representation rewrite.

## Current prototype checkpoint

[Scalar pattern rows](../../experiments/phase76/P76-003-scalar-pattern-rows.md)
remove an unexpected source of amplification: one ordinary character pattern
becomes 1,421 erased nodes with repeated reconstructed defaults. Upstream already
collects scalar decision rows. The Bend prototype reduces this to two rows and
cuts the three generated C files by 52–66%. A first single-round timing screen
is 2.17x B1 / 1.60x B2 upstream; these are not final paired results.

[Prepared native trees](../../experiments/phase76/P76-004-prepared-pattern-trees.md)
move that reduction earlier so repeated analyses share it. Three C outputs stay
exactly equal to the first prototype. Candidate07 is undergoing qualification.
An alpha-equivalence capture counterexample found in review was reproduced and
fixed; candidate05 remains rejected. Runtime evidence is mixed between two short
screens, so no no-regression claim or promotion is made yet. Phase75 stays installed.

Candidate07's next single-round screen is 2.01981x B1 / 1.53276x B2, with exact
candidate05 C outputs on the three sources. Candidate08 adds shared lazy call
admission. Its checked frontend36 and 12,073 independent scalar controls pass;
full selected gates remain pending. No production runtime or JavaScript algorithm
change has been made. No agents or PR comments were used.


## Selection checkpoint

Candidate08's complete paired45 comparison is 1.99078x B1 / 1.51774x B2
upstream (32.25% / 22.20% less time than the contemporaneous Phase75 baseline).
Its complete twelve-family execution gate repeats tree +3.66% and Array.map
+4.93% regressions. It is rejected for default promotion. Scalar reconstruction
elimination and the saved-C placement variants did not resolve both regressions.

Candidate12 removes the pattern module from production and keeps only lazy
native/call admission and representation certificates. Its checked frontend36
and all twelve acquisitions pass; all twelve C files and binaries are exact
Phase75/73. Genuine B2 formation and driver comparison also pass. Clean paired
timing and final integration are running. Phase75 remains installed until review.
The complete candidate10 prototype is retained as a verified reconstructible
patch in `experiments/phase76/prototypes/`; no successful prototype speed is
being represented as a default release result.
