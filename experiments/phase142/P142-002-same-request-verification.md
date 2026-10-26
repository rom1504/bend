# P142-002: compose raw verification within one request

2026-10-26. Selected after P142-001's complete hosted screen regressed despite
high witness reuse. This is a separate Phase141-based prototype; do not stack
the cross-revision witness while establishing the new contract.

Hypothesis: the first raw/static verifier successfully validates a program,
then direct-function optimization and array packaging preserve its exact
`P112StaticProgram`. The second boundary nevertheless rechecks those same raw
segments and static image. Carrying the current successful judgment along that
specific construction path could remove duplicate work, including on cold builds.

Source path to audit: `p140b_opened` → `p134u_optimize` → `p114s_close` →
`p113a_finish` → `p140b_lowered`. Preserve original first verification, all
changed direct-function checks, array-certificate and namespace checks, and the
independent final `p126bp_complete` route. If first success is absent, retain
the original second-boundary/error behavior. Reused previous-revision direct
judgments still require their exact existing context/dependency conditions.

Important distinction: `p134v_boundary_same` compares functions/validity but
ignores the original program and IDs. It cannot establish this conservation
property. Check the full original bundle/IDs in diagnostics and connect the
candidate construction to the held successful original. A caller assertion,
unchanged count or matching producer string is insufficient.

Use finite conservation/refusal controls and actual original-vs-candidate
complete source requests. No new theorem is claimed from source checking or
finite tests. Require measured request benefit before native acquisition;
retain exact QBE and the existing generated-code policy. Record new assumptions,
displaced checks, fallback, source growth and cold/warm effects separately.
