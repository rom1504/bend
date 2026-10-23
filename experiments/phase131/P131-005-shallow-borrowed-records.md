# P131-005 — borrow shallow records through verified virtual helpers

Status: source03 composition admitted; source07 scheduling experiment excluded.

Hypothesis: admit finite shallow record layouts with opaque unobserved fields,
and interpret supported virtual constructor arguments through the existing
verified reader machinery. Retain held-root, escape, effect and fallback gates.

Initial reader eligibility did not reach the hot caller. Source07 late scheduling
finally improved tag/packet proxies57.73%/52.76%, but duplicated preparation and
grew QBE49–52%. That expensive version is not selected.

The cheaper source03 already transfers to actual extracted compiler `nq_uses`:
its recursive caller stays unchanged while the tag adapter uses the new reader.
Three paired native rounds improve595.33→479.70ms (19.42% less), with comparable
CPU reduction, unchanged RSS and exact independent outputs. QBE grows12.03%
and executable3.42%; these are proxy sizes, not full compiler growth.

The final composition uses the seven-field product-helper interface and reuses
current readiness closure. It does not include source07's pass-order machinery.

Evidence: `selfhost/build/phase131/regions-late02-run`,
`regions-uses-timed01`, `regions-inspection01`,
[research](../../research/phase131/private-regions.md),
[independent review](../../research/phase131/regions-review.md).
