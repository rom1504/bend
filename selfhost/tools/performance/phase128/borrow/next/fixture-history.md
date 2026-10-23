# Transfer fixture history

The original `ordinary-transfer.bend` (SHA256
`88d26a44c0efd15f14f72d82b14891e838d7e87285809535750cf81d97f8629e`)
fails the self-hosted frontend in `main`. The independent upstream check also
rejects it: the `+words : List<U32>` binding has Type rather than the required
Data kind. Explicit `List<&2,U32>` fixes the quantity/kind issue.

`ordinary-transfer-v02.bend` uses explicit quantities and typed constructor
helpers. The coordinator reports upstream checking, self-hosted checking and all
five native output lines passing. Its source/manifest and the original failure
remain separate immutable artifacts; the expected outputs did not change.

The v02 source comment suggested a local-annotation inference issue before the
independent upstream diagnosis was available. That hypothesis was **not**
confirmed: this was an invalid original fixture, not a demonstrated compiler
regression or inference bug. The frozen v02 source is retained verbatim so its
existing identity receipts remain valid.
