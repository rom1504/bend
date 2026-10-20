# Recursive region reach after the first ordinary screen

Source inspection found the exact narrow plan on `$direct.p37.list` and
`$direct.dbl` in list-pipeline128 and on `$direct.String.append` in the append
control. The coordinator's `recursive-inspect04/report.json` records the checked
frontend, runtime admission and these names. The fallback-shapes fixture admits
only its library String append, leaving its two-child tree, non-final recursive
field and post-call projection outside the narrow plan. Inspection alone does
not establish that an emitted worker is called.

The coordinator reports 27 complete-output checks and a list screen of 700 to
464 ms (about 1.51×). Tree and lexer QBE are byte-identical to source31, with zero
new workers; their approximately 1% timing differences do not show an optimizer
effect. This is a development screen, not a new broad ratio. The local region
still allocates results and retains explicit frames, so its speedup does not
measure the benefit of removing allocation or all continuation storage.

## Why the remaining list filter is outside the narrow plan

In the actual recursive04 list product, `program.ssa` lines 7776–7785 show
`keep_gt1` retaining two head aliases and saving both in a count-two frame before
its self jump. Its continuation at 7797–7827 restores those aliases and the
recursive result, then computes `U32.is_gt(head,1)` and calls the already admitted
private `keep_gt1.at`. The helper either reconstructs Con or returns the tail.
This is not a one-capture immediate constructor. Moving the predicate earlier
would change the original evaluation order.

Consequently, simply accepting multiple same-constructor sites would not reach
this hot function. The next optional `recursive-general` prototype accepts a
bounded singleton continuation with preserved scalar prefix and an existing
private result call. It reuses exact continuation parsing and private-worker
admission. The old constructor-only path retains precedence. No new runtime ABI
or arbitrary native recursion is required.

## Why lexer generation needs another boundary

The actual lexer `$direct.gen` product contains a fused `salt` call before its
self-recursive edge. The fused region at lines 14389–14423 retains four original
captures around `salt`, then saves two values before the self call; its argument
buffer and locals have the existing fusion prefix. The narrow planner analyzes
the original graph before that fusion, so it first sees a non-self call and a
four-capture continuation. The singleton general resume extension alone does
not make this original prefix eligible.

An additional experiment could compose on the already verified fusion result,
with exact recognition of its private-call marker and hygienic buffers, or admit
that bounded prefix directly. It should use a structured N111 diagnostic from
the checked API before implementation. Parsing the displayed QBE into optimizer
decisions would be a different and unnecessary boundary.

## Bounded next extensions

Multiple static sites can share the current unwind if every associated
continuation parses to the same two-field constructor identity and field order,
up to local renaming. Each site still stores one captured head; local unwind can
ignore which equivalent FID was saved. Nested conditional prefixes and skip-tail
self edges already work when there is only one static frame site. A second
constructor identity needs actual FID dispatch, not merely a relaxed site count.

A more general finite table can retain `(FID, capture count, resume plan)` and
pop the saved FID before choosing a restore layout. Resume cases that can push
another checked continuation and descend would cover two-child traversals. The
natural invariant is a stack of well-formed internal frame variants above an
unchanged caller boundary. Every capture is restored and consumed exactly once;
entry, return and resume arguments remain full-width parallel assignments.
Unknown calls or layouts refuse the whole region. This is feasible reuse of the
existing frame/continuation parsers, but is not implemented by the singleton G
profile and should follow its ordinary gate.

No CPU share for the missed paths has been measured, so their additional speedup
cannot be predicted. Even bringing both list points to upstream parity leaves
the frozen 44-point geometric gap at about 6.29× with all other points unchanged.
General tree/String reach is needed for a corpus-level claim.

## Optional planner-cost repair, separate from reach

`recursive/plan-fast.bend` and `modules05.json` leave frozen04 untouched. The
complete failure test ends in `rt_fail`, so it is disjoint from exact return and
self-jump terminals. At block entry it is checked once. Across a scalar-safe
head, `failure(head :: rest) = failure(rest)`; a known false result can therefore
be reused for the tail. Each branch re-enters the complete test. Unsafe heads
keep the old full scan, preserving refused scan payloads too. Independent source
review found no semantic difference against the selected predicates.

This removes repeated full-suffix failure walks along ordinary scalar blocks.
Return/self-tail/frame recognizers are bounded by the existing arity/capture
limits. It does not establish linear total compiler cost: indexing, continuation
lookup, formatting and other analyses remain separate. Exact emitted-product
comparison on unchanged ordinary requests is the appropriate qualification gate.
