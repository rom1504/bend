# P163-001 — emit a verified direct library without generic scheduled bodies

Hypothesis: for a closed admitted set of real compiler functions, our existing
direct ABI and verifier can support construction without generic lowering,
generic optimization, fallback registries and public scheduler segments.

Refute if correctness requires hidden generic body metadata, source admission
fails broadly, or eliminated work is offset by new analysis/verification.
Measure the complete boundary and generated execution, not just output size.
Unknowns must refuse or take the existing qualified path; no invented bodies,
unchecked direct calls, unbounded native recursion or effect reordering.
