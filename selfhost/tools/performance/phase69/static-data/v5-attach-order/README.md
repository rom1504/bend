# Root integrated static successor

Exact production static.bend captured for build06, with byte identity in
identity.json and cumulative diff since frozen v2. Root fixed the two computed
match scrutinees through parameter helpers, then repaired ns_attach's match
order by moving the earlier `book` parameter match into ns_attach_book.

Bend matches must follow parameter order: matching later `built` then earlier
`book` was illegal even though both were parameters. This corrects the prior
v4 source review. Every function in this successor has only one parameter
match, so none retains that ordering issue. No source was changed by this
archive operation and no target was executed.
