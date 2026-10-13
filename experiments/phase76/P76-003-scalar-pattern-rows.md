# P76-003: scalar pattern decision rows

The new per-definition diagnostic identifies Nat.read.trim's single character
pattern as 1,421 erased nodes, including 624 constructors and 496 bit constants.
Its ordinary and generic lowering together dominate library lowering. Pinned
upstream comp.ts mat_lits compresses scalar patterns to known-bit rows and drops
defaults covered by their reconstructed ancestor. Transfer this general method
into Bend: recognize U32/F32 wrapper patterns, retain low-bit constraints,
compare instantiated default bodies modulo bound-variable names, and emit each
uncovered row once. No function or benchmark name is recognized in production.

This is a representation change and changes C output. Require differential word
pattern controls (multiple literals, partial words, bit edges, captured defaults),
actual C execution and broad twelve-family runtime timing before promotion.
Unknown/malformed patterns fall back. Keep raw/reference disagreements explicit.
Prepared immutable rows replace repeated branch lowering; no result cache or
external-language compiler algorithm is introduced.

## Prototype observations

Candidate05 passes 1,045 independent constructor-interpreter/coverage comparisons,
36 frontend witnesses, ten paired native word-pattern programs and genuine B2
formation/driver checks. A subsequent raw alpha-equivalence counterexample
(free versus bound variable with the same numeric ID) fails candidate05 and
passes corrected candidate06's 1,047 controls. Candidate05 is not deployable.

One-round fresh numeric/array/lexer screen: B1 2.17189x, B2 1.59925x upstream.
These are preliminary ratios, not a paired Phase75 improvement claim. C falls
from 1,153,845 to 392,670 bytes on numeric, and 1,461,280 to 700,105 on lexer.
Evidence: `selfhost/build/phase76/compiler05-compilation`, `compiler05-native03`,
`compiler05-word10`, and `compiler{05,06}-controls-v2`.

The first saved-binary runtime screen shows numeric 233/252ms old/new; a second
screen measures 251/251ms. Array is stable; lexer improves slightly. A saved-C
64-byte scheduler alignment probe does not improve numeric and is not adopted.
Broad balanced timings are required; neither individual screen establishes a
stable numeric regression or non-regression. Failed attempts remain retained.

## Final decision

Rejected for default promotion after candidate08 paired 45 shows 32.25%/22.20% compilation savings but twelve-family runtime repeats Tree +3.66% and Array.map +4.93%. The alpha fix remains in the preserved prototype. See P76-008 and the final report; no parity or full-release claim.
