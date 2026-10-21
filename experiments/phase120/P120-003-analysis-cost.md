# P120-003: reduce the cost of a useful generated-code transformation

The signed-word pass improves generated scalar code, but the first matched
hosted screen increases prepared compilation cost by28–36% on the two affected
programs. A fixed prepared Mandelbrot graph attributes2.368s to new word analysis
and0.519s to its verification. These are measured medians, not native compiler
timings. Most new work is analysis; deleting a verifier would miss the main cost.

Test small exact-output refinements before a new analysis data structure:

1. Region pass: preserve the original function if no call was copied, and the
   original already verified boundary if the candidate table is empty. Keep
   the full commit for every nonempty table. The three focused QBE products
   remain byte-identical;27 selection/identity controls pass.
2. Word pass: conservatively refuse functions that cannot contain a sign
   shift, a separate logical shift, and their combining OR. Local shift counts
   must remain eligible because facts may recover their constants. Compare
   exact emitted bytes and the existing finite controls before measuring cost.

No global cache, benchmark-name dispatch or verifier weakening. Indexed fact
maintenance is a later experiment if these bounded filters leave substantial
analysis cost. Preserve negative results and do not conflate cheaper emission
with faster generated programs or faster native self-compilation.

Results and receipts are consolidated in the Phase120 report.

## Diagnostic result and next hypothesis

Word18 (prefilter09 plus separately corrected controls) preserves exact QBE on
scalar, Mandelbrot and recurrence. Thirteen new syntax controls and the existing
14/60 word and17 width controls pass. Mandelbrot analysis median falls
2.3678→0.9658s; verification stays0.5192/0.5351s. In the separate ray graph,
analysis is0.0565→0.0167s while verification remains1.4352/1.4298s. These are
fixed-graph hosted diagnostics, not complete compiler speedups.

The next inexpensive cost hypothesis is a changed-body summary: retain the
already verified range boundary if the word walk records zero rewrites across
all functions; verify every changed candidate. A preserved object/explicit hit
flag is preferable to comparing complete serialized graphs. This is not yet
implemented. First test exact identity and no-hit branches, then the existing
word controls and exact emitted-code bridge. It may remove about1.4s from the
observed ray verification stage, but whole-request savings remain unmeasured.
Do not extrapolate that stage share to all programs or remove verification when
a transformation occurs.

The complete gate rejects the narrower filter as a demonstrated whole-compiler
improvement: combined03's four-case geometric cost is1.20558×parent, versus
combined01's1.17954× in its separate matched screen. Runtime products remain
identical on45+6 sources. The simplest supported decision is to retain combined01
and keep03 as an unselected experiment. Stage gain is not whole-loop gain; do the
small whole-cost screen before an expensive broad byte bridge next time.
