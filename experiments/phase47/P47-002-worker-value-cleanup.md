# P47-002: bounded private calls followed by value cleanup

Date: 2026-10-04. Pre-build status: unchecked, unmeasured, investigate.
Owner: IR implementation agent; separate controls and review agents; root builds
and measures. [Design](../../design/phase47/research-guided-optimization.md).

Select the existing typed JW worker as the first shared-facts consumer. It has
explicit evaluated slots, calls, constructor layouts and branch scopes, but its
current simplifier only removes unconditional tuple/Char cases. RLE already has
workers; Map and record profiles retain allocation. This offers a general place
to test the Rust/LLVM pattern of exposing a small helper body and then removing
the now-visible temporary aggregate. It does not address unsupported higher-order
or Array graphs by itself, and V8 may already perform the same cleanup.

Bounded scope: small linear Assign/Return helpers, stable evaluated arguments,
fresh slot renaming, immutable local copy/constructor facts, exact tuple/tagged
projection forwarding, and removal only of a proven unused private allocation
shell. Keep all field computations and their order, original graph dependencies,
public guards, function indices and fallback behavior. Unknown calls and host
operations confer no discard/move permission. Branch facts never flow into a
sibling or join. Limit expansion and fact retention; record source and output
growth and compiler request cost.

Falsification: semantic disagreement, unbounded/code-growth cost, material
canary regression, or no useful gain after the causal opportunity is confirmed.
Run independent renamed fixtures and host-boundary controls before affected
family timing; five maintained canaries precede broader screens. Promote only
after integration gates. Results and failed attempts belong in Phase47's report.
