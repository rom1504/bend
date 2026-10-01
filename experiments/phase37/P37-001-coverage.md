# P37-001: diversified execution coverage

Status: prospective; investigate. Measurement: not yet run.

Hypothesis: frozen size/seed/shape/active-work variation plus independent application
families exposes costs hidden by the15-point historical catalog and yields a more
useful optimization gate. This does not estimate population-average application
speed. Selection is fixed before optimization and whole families are held out.

Falsification: unsupported programs, unbounded costs, oracle disagreement, hidden
input specialization or insufficiently varied executed paths invalidate the affected
point. Preserve such failures rather than silently dropping them. An independent
oracle and a TS differential observation are different evidence classes.

Design: [Phase37](../../design/phase37/README.md).
Report: [Phase37](../../implementation/phase37/README.md).
