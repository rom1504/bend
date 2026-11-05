# P163-001 — emit a verified direct library without generic scheduled bodies

Hypothesis: for a closed admitted set of real compiler functions, our existing
direct ABI and verifier can support construction without generic lowering,
generic optimization, fallback registries and public scheduler segments.

Refute if correctness requires hidden generic body metadata, source admission
fails broadly, or eliminated work is offset by new analysis/verification.
Measure the complete boundary and generated execution, not just output size.
Unknowns must refuse or take the existing qualified path; no invented bodies,
unchecked direct calls, unbounded native recursion or effect reordering.

Outcome: supported for bounded closed computations, not a general replacement.
The native optimized route reduces two real compiler requests by 22.6%/34.7%;
generated runtime is neutral/+7.0%. A matched-policy hosted comparison produces
identical final QBE while omitting genuine generic construction/verification.
Six of eight preselected unrelated computations refuse; direct-only cannot
self-compile its IO main. The next test is a real mixed direct/generic adapter
and import boundary, not a full campaign on the restricted compiler.

[Complete report and rejected alternatives](../../implementation/phase163/README.md).
