# P65-004: carry emitted reference/use metadata

Status: registered; no target or selected implementation yet.

The [design H4](../../design/phase65/reusable-backend-products.md#h4-finish-output-metadata-propagation)
tests remaining raw-text scans in the existing JDOrdered/JDText pipeline.
Carry exact metadata at an existing construction point, without a new output IR.

Falsifiers: too little scanning cost, changed escaping/marker/name behavior,
changed order/refusal budgets or complete module bytes, or no clean request gain.
