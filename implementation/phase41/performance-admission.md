# Phase41 performance admission

Admit frozen checked01 to installation and postinstall gates. The six-point,
five-round maintained run passes all 90 samples. The three changed tree points
improve 1.506–1.592×; each wins all five pairs with disjoint observed ranges.
Three unchanged controls remain explicit, and the other 42 catalog modules are
byte-identical to Phase40. This is not a catalog-wide timing or parity claim.

**Explicit design exception:** accept the tree compiler request median increase
from 2248.000 to 2460.593 ms (+9.46%, about 213 ms). All three pairs are slower,
although ranges narrowly overlap. The prospective design's blanket regression
rejection language is relaxed for this measured compiler-cost tradeoff because
the user’s primary objective is generated-program runtime, reduced here by
33.6–37.2%. Do not call compiler cost neutral. Other requests show no clear
regression; all 36 requests reproduce expected output. Further planner cost work
is a separate next experiment, not an unvalidated change in this release.

Independent review recommends the scoped candidate with that cost risk visible.
[Final measurements](results.md), [review](final-independent-review.md), and
[canonical admission](../../selfhost/build/phase41/admission01.json) retain the
inputs and decision. Installation, CLI verification and postinstall audit remain
mandatory; their final outcome is recorded in [integration](integration.md).
