# P65-003: unchanged composite terms

Status: registered; no target or selected implementation yet.

The [design H3](../../design/phase65/reusable-backend-products.md#h3-avoid-rebuilding-unchanged-composite-terms)
starts with a census of rebuilding that preserves a beta-stable result. Existing
leaf sharing, graph evaluation and delayed substitution are baseline features.

Falsifiers: small avoidable share, beta/freshness/span/identity mismatch, or
guard/index cost exceeding allocation savings. Variable absence is insufficient
when the original substitution also performs beta reduction.
