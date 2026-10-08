# P65-001: a shared resolved backend product

Status: registered; no target or selected implementation yet.

The [design H1](../../design/phase65/reusable-backend-products.md#h1-one-resolved-backend-product)
tests whether specific annotation/call/layout facts can eliminate repeated
semantic traversals under one exact owning context. Phase63 lower-once emission
already exists and is not counted as new work.

Falsifiers: little fresh residual cost, context/demand/order/refusal mismatch,
different output without new qualification, or no clean whole-request benefit.
The prior discarded-child and typed-spine failures remain constraints.
