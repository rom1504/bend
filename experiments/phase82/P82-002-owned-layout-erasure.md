# P82-002: consume owned layout annotations directly

Status: deferred; compiler05 preserved and compiler04 restored.

The Phase78 annotator already normalizes every `Ann` type head and records each
constructor field quantity in its field annotation. Ordinary native erasure
normalizes those heads again and reconstructs constructor telescopes to recover
the same quantities. Test a private erasure consumer of those existing facts.
This is an incremental representation change, with no additional retained graph.

Only the owned `annotate_selected` → `nr_prepare_annotated` path can use it. Raw
APIs keep ordinary erasure. Missing field metadata falls back to ordinary
erasure. Match field masks retain the existing telescope analysis. Keep erased
bodies as the existing per-function product feeding static, worker, scheduler
and observer lowering. First compare complete erased bodies and generated C,
then B1/B2 request times against candidate04. Reject if net gain does not justify
the additional private consumer; preserve rejected source.

This tests part of the larger fusion proposal without duplicating the annotator
or implementing a new whole-library cache. It does not claim the forecast
15–25% whole-request gain of a full replacement representation.

Checked B1/frontend36 and genuine B2/driver8 pass. Complete preparation products
match raw erasure on three sources in each stage; all54 clean C outputs and
reports match. Isolated three-source request savings are1.68% B1/1.38% B2,
insufficient to retain a second erasure consumer. See `prototypes/compiler05.patch`
and the [report](../../implementation/phase82/README.md). No compiler05 release.
