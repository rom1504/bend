# Generic constructor loops

The Phase102 compiler prototype now lowers a useful class of recursive builders
to native loops without recognizing a library function's name. The same rule
activates for `String.append`, dependency planning's `dp_push` and `dp_roots`,
and the separately registered renamed/user-constructor controls. It retains the
linked representation and public one-Term result ABI.

## Structural rule

The ordinary worker attempt runs first. Only the existing rejection
`flat worker: non-tail self call` triggers a bounded retry: 1–8 arguments,
at most 512 body nodes, and an ordinary boxed constructor with 2–8 live fields.
Its final field must be a saturated direct self-call. Prefix fields and recursive
arguments must not themselves reference the same function. All existing worker
dependency, foreign-call, parallel, dynamic-call and mutual-recursion gates remain.

Ordinary ordered lets evaluate the prefix fields and recursive arguments before
each new constructor allocation. The worker then creates the constructor with a
`TERM_HOLE` final field, links it into a private chain, and performs the ordinary
simultaneous argument moves followed by `goto nf_again`. A terminal value fills
the last hole. This removes per-element continuation traffic; it does not remove
the final observable list or reorder a map/filter traversal.

The private inner worker has a two-word root/hole buffer. An outer wrapper owns
that buffer, publishes only the root, and sinks a partial root if the inner
worker returns failure. No incomplete node is passed to a recursive argument or
another worker. Normal alias-retain logic remains in the existing ordered-let
and `ctr_take` paths. `rfc_seal` preserves the underlying node address, so storing
the final-field address remains valid after linking the node. Conservative
sealing is compatible with cold-constructor readers and recursive fields remain
full Terms rather than scalar fields.

Source and actual generated-C review found no ownership or ABI blocker. This is
not a proof of complete memory cleanup for every ordinary live argument on every
fatal runtime path. Allocation occurs earlier than the old recursive return,
so exact resource-exhaustion timing is also outside the claim. Current selected
application emissions are host-only under the scoped no-bang permission; device
and raw fallback require their own controls.

## Measured composed candidate

`trmc-source04` is the corrected typed-call parent, the two retained Phase99
branch-specialization edits, and 158 lines of generic constructor-loop support.
It contains no canonical append matcher. Its checked testing API acquisition
passed (`trmc-api02`). The application screen is **the composed candidate versus
the installed Phase98 B2**, not an isolated estimate of the TRMC delta.

| Full application | Workers | Candidate / installed B2 | Candidate / upstream |
| --- | ---: | ---: | ---: |
| Source index, generated 10,000 | 1 | 0.6134 | 1.0536 |
| Source index, compiler source | 1 | 0.5742 | 1.2420 |
| Renderer, production survey | 1 | 0.7960 | 1.0656 |
| Renderer, production survey | 4 | 0.7268 | 1.1632 |
| Dependency DAG, 800 | 1 | 0.8818 | 0.2965 |
| Dependency chain, 1,000 | 1 | 0.8920 | 0.3236 |

All 72 full-output executions passed: six points, four rotated rounds and three
compiler variants. Renderer median RSS fell from approximately 79.5–80.4 MiB to
51.4 MiB. These process measurements include startup/output work and are not a
compiler-latency or self-hosted-image qualification. Raw receipt:
`selfhost/build/phase102/trmc-screen01/report.json`, SHA
`6b7f78c4633275868e087c3ad5a613381fcfec78686ca4b9c9b89b772135527d`.

## Focused laws and preserved failures

[controls-v5.json](../../selfhost/tools/performance/phase102/fusion/controls-v5.json)
registers complete output and activation/refusal expectations. It covers renamed
append, an unrelated user constructor, empty/nonempty inputs, a 30,000-character
result, retained aliases, the same object as both append inputs, three-field
constructors, swapped recursive arguments, duplicated prefix fields, nonfinal
recursion, multiple self-calls, mutual recursion, and a late Nat overflow. The
three-field cases exercise hole offset 2 rather than just the String/List offset 1.
Their explicit types, unrestricted binders and full expected outputs passed
independent source review. Only the mutual-recursion refusal pair is explicitly
`@unsafe`, matching the previously qualified Phase68 fixture; this tests backend
SCC refusal, not safe frontend mutual-recursion acceptance. A separate safe
[bang builder](../../selfhost/tools/performance/phase102/fusion/bang-controls.json)
requires scheduler fallback and exact output at one and four workers. Actual
execution remains a separate pending gate.

The lineage keeps every rejected attempt. Source01 had an `NC_Text` construction
error caught before targets. Source03's first checked acquisition rejected a
match inside a closure; source04 moves the two list matches to top level. The
first fixture lacked local type annotations; the second refused an affine
predecessor used twice. The versioned v3 controls fix those source declarations
and add the alias law without changing the earlier algorithm/oracle values.
The v3 mutual forward reference and v4 attempted safe forward law were also
rejected. Version5 uses the established Phase68 `@unsafe` declaration pattern
for only those two functions; all rejected source and logs remain.

## Optional private unique-cell reuse experiment

[reuse/transform.py](../../selfhost/tools/performance/phase102/fusion/reuse/transform.py)
prepares a general C intervention only inside emitted `_trmc` functions. A
four-word private wrapper buffer adds one `(cell, size class)` slot. A constructor
match may retain the uniquely transferred cell returned by `ctr_take`; a later
ordinary allocation reuses it only for the same size class. An older unused cell
is freed before replacement, and the wrapper frees any remaining cell before
publishing the result or returning failure. At most one cell and 16 extra stack
bytes are retained per active wrapper. No source-function name list is used.

The static boundary is essential: `ctr_take` can return a read-only location below
`HEAP_OFF`, as well as zero for shared input. The helper rejects **every location
below `HEAP_OFF`**. Only a transferred unique heap cell can enter the cache.
Prefix expression order, child ownership, normal allocation fallback, output
nodes and the public ABI remain unchanged. The experiment tests avoiding the
allocator's per-node free-list push/pop. The first broad comparison was noisy on the graph; a subsequent direct paired
comparison isolates the cache delta as described below.

Prepared catalog: `selfhost/build/phase102/trmc-reuse-catalog01/catalog.json`, SHA
`9c6278ea70d78a0e12dfdf1c00e7c7e8d39eac216ec217472793e7ce68589d92`.
It records one modified worker in source-index, one in renderer and three in
dependency planning. The generic transform can be reapplied to a later combined
observer candidate; existing frozen products are never edited in place.


## Isolated reuse result and explicit compiler integration

`reuse-pair01/report.json` alternates the two frozen candidate binaries, without
including build time. All 48 complete-output executions passed: four points,
six rounds, two variants. The reuse candidate / its exact TRMC parent ratio is
0.9439 for one-worker rendering, 0.9257 for four-worker rendering, 0.9927 for the
DAG and 0.9976 for the chain. Thus this isolated intervention reduces renderer
process time by 5.6–7.4%, while graph time is effectively unchanged in this screen.
Receipt SHA: `6317542e48752630158f2b706dd0cbb74ad68c8bd840fba390a30b254ffe9ecc`.

The compiler successor uses explicit lowering hooks rather than C macros or
rewriting emitted text. A Boolean from the existing private TRMC target travels
through the match join to select cache retention after `ctr_take`. The ordinary
match API still requests the old release policy. Only the already admitted
`NTRCons` final reconstruction allocates from the cache, calling the existing
`ne_ctor_node` field/store emitter. Prefix constructor allocations remain on the
ordinary allocator; this is intentionally narrower than the C prototype. The
same four-word wrapper owns and frees the cell, and helper definitions appear
once inside the existing host-only worker prelude.

This adds 17 physical Bend lines and 1,911 bytes relative to `inline-source01`
(typed calls, branch specialization, TRMC, observer route and an 8-KiB inlining hint).
`trmc-reuse-source01` SHA is
`a67c24d6e7f7cc9cd7d9d5e540e02b6360c9273dd48095c08895ff33cec1bd59`.
Its checked API acquisition `reuse-api01` passed with API SHA
`11fe3eaf3e1a20a7c5a9756d67b4e7932633f404c0fda18ce0ff7adfae4e423f`.
This does not yet close the combined candidate's application/control execution
or genuine native self-hosted compiler qualification.


A final small source02 successor gates the helper prelude on the actual routed
worker list: at least one worker must have the private `NTRMC` shape and be in
the same ready set used by `nf_bodies`. Empty, ordinary-only and unready sets
produce an empty string, preserving inactive prelude bytes. The source is
`8b895aec2dc9eac2eaee0036239367f83b53910c309ba26ebab4c9a47fa5affa`,
adding 28 lines/2,475 bytes relative to the inline parent. Independent review
verified this exact predicate, affine uses, source pins and inverses; consumed
source01 remains unchanged. The three v5 TRMC fixture sources now passed actual
frontend planning in `reuse-emission01`; their execution gate remains separate.

The failed safe forward-law attempt also exposed a specific frontend boundary:
`check/kernel.bend` exempts Base declarations and unsafe contexts from ordinary
live use of an unfilled law. A Base mutual-recursion declaration pattern alone
therefore does not establish acceptance in an ordinary safe module. The final
refusal control states its unsafe scope explicitly.
