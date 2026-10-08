# Shared datatype printability

The completed Phase66 JavaScript survey found two compilation timeouts on
`reg/const_shared_layout.bend` and `reg/show_shared_layout.bend`. Both contain
24 nested instantiations of `Choice<A>`, with two constructors that each hold
the same child type. Frontend checking completed; the whole compile/run probe
hit its 10-second limit before an emitted JavaScript file appeared. These are
compiler failures to complete within the probe budget, not slow generated
programs.

Source inspection identifies a repeated proof before code emission.
`j_compile_error` calls `j_printable`, whose constructor loop checks both
branches with the same ancestor-only `seen` list. A successful child traversal
does not update the list supplied to its sibling. The recurrence for this
family is approximately `T(n) = 2T(n-1) + overhead`. The direct readback emitter
already has a global type worklist; replacing its descriptor format would not
address this earlier repetition. Upstream `show_main` stores a descriptor ID
before visiting its children and shares repeated `(layout, exact type key)`
nodes. The relevant source is the pinned `0592662` compiler, lines 1883–1936.

The isolated candidate in
`selfhost/tools/performance/phase66/shared-layout/printable-v2/`, with the syntax
correction in `printable-v3/`, threads the
visited type keys through successful predicate results using the existing
`Maybe` type. The public `j_printable` result remains `Bool`. Four internal
helpers return the visited list or `None`; two small continuation helpers pass
successful state to the next constructor or field. The final patch adds 27 lines,
with no new persistent cache, model type, budget, or emitted descriptor format.

The invariant is local to one book and one printability request. A datatype is
marked before descent, preserving recursive-type acceptance. Every reachable
field of a newly visited datatype must still succeed before the enclosing
request can return success. A recursive edge can therefore skip another
traversal without hiding a later invalid field: that field remains an obligation
of the original visit, and any `None` aborts the entire request. Exact normalized
`term_key` values preserve distinctions between parameters and raw namespace
spellings. Existing incoming `seen`, equality, scalar, Array, IO.OP, erased
field, and dependent field rules remain unchanged.

The previous compiled `Bool.and` evaluates both arguments eagerly. The new
`None` path intentionally skips later pure traversal after refusal; it does
not claim identical demand. The intended equivalence is the Boolean result
on finite normalized type graphs. This distinction matters for invalid or
nonterminating synthetic books. No state is reused between books or requests.

The root's bounded diagnostic confirms the location: the actual 04 public
`j_compile_error` call entered at 671 ms and did not return before the 20-second
deadline. `driver_emit_owned` had already completed. The failed trace is kept
as diagnostic evidence, not a successful compilation or clean timing sample.

The unexecuted v1 candidate is preserved: source review found its missing
universe argument in `Maybe` annotations. The v2 correction uses
`Maybe<&2, List<&2, String>>` and has passed independent source review.
The actual checked 06 build then refused a `match` on a local binding before
producing an API. V3 moves that identical `Maybe` match into a helper parameter;
the graph logic is unchanged. Both the failed attempt and its candidate are
preserved. Checked 07 and the focused controls now pass. The controller compared the actual old
and candidate checked-image predicate on 28 explicit oracles, including mutual
recursion followed by a bad field, shared good branches followed by bad
branches, distinct type parameters and namespace spellings, and incoming
`seen` behavior. It additionally passed the candidate at shared depths 16, 24, and 32.
Both original source fixtures compiled and reproduced their complete inline
stdout oracles. Their observed whole-probe durations were 4.655 seconds and 0.588
seconds, respectively; the first includes cold preparation. The private
predicate's depth 10 diagnostic fell from 113.22 ms to 6.42 ms, and candidate
depth 24 completed in 34.38 ms. These single controller/probe observations locate
the removed repetition; they are not clean compiler speed ratios or generated
program runtime measurements. The selected compiler still needs its full
conformance, selfhosting, and balanced performance campaigns.

Closed evidence: `selfhost/build/phase66/printable-controls07-01/report.json`
(`79d9ada6…6c52`), `printable-source07-01/bend-candidate-new-base/js/report.json`
(`466f01f2…d808`), and `printable-focused07-execution/report.json`
(`83a8a438…16c8`). The original 04 timeouts and failed 06 bootstrap remain intact.
