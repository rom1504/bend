# P126-005: join mutually recursive tail workers

Status: selected in source32; full qualification is separate.

The existing direct-call closure cannot admit a mutually recursive dependency
cycle. This experiment joins an exact two-member tail SCC into one private
worker using the existing full-Term loop IR. A discriminator selects the body;
parallel full-width argument lanes carry each transition. Original names remain
compatible wrappers. No IR, scheduler, runtime representation or emitter extension
is needed.

Every internal edge must be the whole residual `call → return that result`.
Additional effects, ownership work or non-tail continuation refuse. Bodies are
hygienically renamed, scratch buffers stay function-local, and the unchanged
verifier and dependency closure check the derived worker and wrappers. Duplicate
identities, arities above eight and incompatible results retain fallback.

Sixteen finite predicates pass. Actual source32 emission admits four library
pairs across the five measured programs: Nat/U32 parsing and formatting. Each
machine worker has two local backedges and no call to itself, either member's
wrapper, or generic scheduler transitions. This is a general graph transformation.

The ordinary control's100001-transition full-width and owning-String examples
also use joined workers and match all ten independent output lines. Its non-tail
cycle remains generic. Forward user laws require explicit source-language
`@unsafe` permission; Base's native-law trust does not transfer to user fixtures.
Earlier declaration/parser failures are preserved and are not counted as tests.

The new catalogue analysis costs work: the final combined hosted two-request
screen is1.08745× Phase125, versus0.99384× before this and divmod integration.
That comparison does not isolate the SCC analysis or predict native compiler
speed. Source30 is the repaired SCC-only layer, source32 adds actual divmod
admission, and source33's optional late optimizer is unselected.

Evidence: `implementation/phase126/tail-scc-machine-review.{md,json}`,
`phase126/tail-scc30-finite/report.json`, source32's98 combined finite predicates,
and `phase118/p126-final32-controls-run/report.json`.
