# P120-002: exact signed-word identity in structured IR

Status: first bounded cycle completed,2026-10-21. Parent qualified Phase118 safe03.
Recognize a general low32 logical-shift/sign-fill composition using immutable
value-origin facts across exact copies and supported branch joins. Facts must
not survive overwritten producers, unknown effects, aliases or unsupported
backedges. Preserve all original verification and fallback behavior.

First use the existing U64 shift/arithmetic-shift/mask vocabulary, with explicit
low32 semantics. No reliance on implicit QBE word-to-long extension. Do not remove
independent side effects while replacing the final pure expression. Compare actual
hot machine instructions and scalar/Mandelbrot full outputs; shorter IR alone
does not qualify a change. Use ordinary independent boundary and invalidation
controls before broader performance claims. General rules cannot name workloads.

The existing dead-scalar cleanup is excluded. This experiment creates a precise
identity, rather than replaying that negative cleanup. Agent owns isolated Bend
word modules; root alone checks and executes targets. Evidence will retain every
checked/rejected candidate and measured cost.

## First-cycle outcome

The identity plus explicit word-width rendering is retained in the experimental
integration. Original45 scalar428→299ms, Mandelbrot800→720ms; two grid variations
improve27–31%. Most unrelated workloads remain unchanged. Word14's Boolean
rewrite violates the verifier width contract and triggers correct-but-slow
fallback; corrected word15 is neutral, so both are excluded. The initial word
analysis materially increases compiler cost;2.368s analysis versus0.519s commit
on the fixed graph motivates an indexed fact environment. Full controls,
negative attempts and exact identities are in the [report](../../implementation/phase120/README.md)
and [word findings](../../selfhost/tools/performance/phase120/word/results.md).
