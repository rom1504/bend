# Phase 47 independent array-view correctness contract

This contract was prepared before inspecting any proposed transformed output.
The original plan and the subsequent focused execution results are recorded
below. They do not establish broad qualification or promotion. The coordinator
owns checked acquisition, execution, performance measurements and promotion.

The [fixture](../../selfhost/tools/performance/phase47/controls/array-view-v1.bend)
uses renamed helpers, four cells, a different recurrence and independent scalar
oracles. It does not assume the benchmark's function names, 128-cell layout or
emitted variable names. The controller accepts independently checked predecessor
and candidate libraries; semantic comparisons use the original libraries and
do not use timings. Later versions add separately identified counter derivatives.
Activation is a separate obligation: agreement while both use the old path gives
no credit for validating a new array-view transformation.

## Contract and counterexamples

| Boundary | Required observation | Smallest control |
| --- | --- | --- |
| Repeated reads/writes | Later visits observe earlier writes; U32 arithmetic wraps | 0, 1, 4, 5, 9 and 33 iterations and four seeds, including maximum U32 |
| Zero iterations | No new backing-array lookup, length read or error | Public malformed/getter handles with zero loop trips; allocation in `bench(0,seed)` still happens |
| Demand and errors | A tuple match demands the native read even when its scalar is unused | `ignored_read`, throwing storage getter and native read replacement |
| Aliases | Writes through one handle are visible through another | Same backing store versus two separate stores |
| Public escape | Returned handles retain their real backing state | Return state, inspect/mutate storage, pass it back through `external` |
| Public storage | Getters/proxies and changing backing stores retain observations | Handle getter, backing proxy, malformed handle, empty store |
| Host conversion | `Number` replacement/getter/throw retains conversion observations | Post-import hook around both closed and public calls |
| Allocation callbacks | Array construction can expose storage or change later hooks | `Array.prototype.fill` proxy result, throw, reentry and installation of a new `Number` hook |
| Storage lifetime | Cached data/length cannot survive unknown clobbers | Opaque callback resizes or replaces storage before a read; callback error occurs before read |
| Public source identity | Replaced/getter/code/call dependencies trigger normal behavior | `Array.get`, `Array.set` and a source cell helper mutations |

The proposed recurrence is `next = (acc + old + 1) mod 2^32`, then
`cells[i mod 4] = next XOR i`. The oracle implements that recurrence directly in
the controller; source and expected results are not copied from emitted code.
Host boundary comparisons use the existing selfhost ABI and exact error/event
agreement. Malformed host inputs are not claimed as Bend source-level semantics.

## What existing proofs do and do not establish

The current [region planner](../../selfhost/src/back/js/region.bend) already
recognizes native array reads consumed by private tuple matches, inlines those
matches, and forwards state fields. That proves neither unobservable allocation
nor stable array length. The existing `localGuard` checks source descriptors and
prototype markers; it does **not** check `Number`, `Array.prototype.fill` or
`Number.isSafeInteger`. The broader `regionHostGuard` checks global `Number` but
does not by itself establish that a later allocation callback cannot change it.
See [runtime core](../../selfhost/src/runtime/js/core.mjs) and
[array helpers](../../selfhost/src/runtime/js/base.mjs).

`arrayfill` calls mutable host allocation/fill/safe-integer hooks. `arraydata`
can demand a getter twice, lazily flatten tree storage, or throw. `arrayset`
again fetches the backing data and calls `Number(index)`. Moving those operations
requires a stronger fact than immutable loop operands. A zero-trip loop cannot
speculatively demand its storage. A guard checked before a callback does not
cover mutations caused by that callback.

Existing [Phase 36 controls](../../selfhost/tools/performance/phase36/guard-array-controls-v2.mjs)
already witness fill-hook mutation and reentry. Existing
[Phase 30 controls](../../selfhost/tools/performance/phase30/prototype-array-controls.mjs)
cover proxy/index/native-descriptor observations. The new fixture complements
them with an independent loop and explicit lifetime/escape boundaries; it does
not replace those maintained gates or broaden the standard-at-import contract.

## Small shared facts, not an effect-free blanket permission

For the first consumer, record a storage identity and distinguish fresh/private,
public/escaped and unknown storage. Track aliases, backing replacement/resize,
opaque call barriers, and the first demanded access. Separately track whether an
operation can throw, invoke a host hook, allocate, or expose storage. Preserve
the old program on unsupported joins, recursion or analysis-budget exhaustion.
Do not equate purity, nonescape, totality and safe speculation.

The local [LLVM survey](../../research/compilers_architecture_and_techniques/llvm.md)
distinguishes alias/clobber facts from LICM execution safety; the
[Rust](../../research/compilers_architecture_and_techniques/rust.md) and
[Zig](../../research/compilers_architecture_and_techniques/zig.md) surveys motivate
explicit use/lifetime facts rather than repeated source walks. The
[V8 survey](../../research/compilers_architecture_and_techniques/v8.md) warns that
the JIT may already remove apparent repeated checks. These are transfer ideas,
not performance evidence or permission to apply C/LLVM undefined-behavior rules.

## Execution and acceptance

Acquire this source with the existing `programs/prepare.py` and its sibling
catalog under `phase47/controls`, once with the selected predecessor and once
with the candidate. Run `array-view-controls-v1.mjs BASELINE_MODULE
CANDIDATE_MODULE NEW_OUTPUT_DIRECTORY` under the existing serial resource guard.
The runner verifies checked emission/source/catalog/producer identities and
preserves exact observations, failures and its consumed source in a new directory.

Before promotion, require a separate non-timing activation witness on closed
`bench`, refusal or equivalent observations for public/escaped/opaque roots,
all controller comparisons, existing array/callback gates, and the five canaries.
Preserve parse/type failures as failures; a catalog source that cannot be checked
does not count as a boundary test. A saved-output ablation may establish a speed
opportunity, but receives no compiler correctness or promotion credit.

## Worker call/aggregate composition: independent second consumer

The [second checked fixture](../../selfhost/tools/performance/phase47/controls/jw-optimize-v1.bend)
and [source controller](../../selfhost/tools/performance/phase47/controls/jw-optimize-controls-v1.mjs)
were authored independently of the new optimizer implementation. Their contract
is general helper expansion, immutable copies and private constructor projections;
they do not assume that every source shape activates all three transformations.
The acquisition anchor is `bench(5,3) = 321`, from repeated
`x = ((x+1) mod 2^32) XOR ((3*x) mod 2^32)`.

The controller prepares 72 oracle records and 11 boundary comparisons: recursive
callers through depth 129; renamed tuple/tagged producers and consumers; repeated
field use; alternating branches with reused source spellings; matching and
mismatched constructor tags; a checked-overflow computation in an unused field;
ordered/throwing fields; helper reentry; unknown replacement results; mutable
global/code/call descriptors; and public tuple/constructor layout, mutation and
getter observations. Ignored allocation is different from ignored field
evaluation. The overflow field must still throw, and first-field failure must
suppress later field execution. Boundary sentinels require thrown object identity,
not merely matching error text. These were proposed controls at authorship;
the [worker outcome](worker-outcome.md) records subsequent focused results.

The ordinary `ir/test.mjs` uses `j_library` and does not directly export the JW
optimizer. The new [IR controller](../../selfhost/tools/performance/phase47/controls/jw-ir-controls-v1.mjs)
therefore accepts `CHECKED_ATTEMPT NEW_OUTPUT_DIRECTORY`, verifies the exact
API/runtime/Base hashes and appends one diagnostic export to a fresh API copy:
`xs => run_loop($jw_optimize_functions$(xs))`. It requires unique top-level
declarations found by the pinned Node parser, preserves every original API byte,
and records its derivative and parser identities. This is diagnostic access to
the checked production implementation, not a production ABI extension, a new
compiler build or a benchmark artifact. The coordinator alone executes it.

Eighteen synthetic graph cases use an independent fuel-bounded interpreter to
compare values, errors and ordered effects before/after the actual pass. They
cover actuals evaluated once even when unused; retained field computations after
shell removal; one field used twice; tag mismatch; branch-local numerical slot
reuse; copies and captured fields surviving later slot overwrites; aggregate
fact invalidation; recursive callers; public/native escapes; invalid target,
arity and function flags; oversized helper refusal; and bounded code growth.
The positive inline/projection case must actually reduce calls and projections.
The growth case requires no more than 32 net added instructions per caller.
Malformed/overwritten-slot cases are robustness controls, not claims those graphs
are emitted from checked Bend. The interpreter does not validate JS emission,
public runtime hooks or frontend acceptance; the source controls cover those
separate boundaries. This test design alone establishes no activation result.

### Preserved first source failure and successors

Root's first checked acquisition receipt,
`selfhost/build/phase47/jw-controls-baseline01/modules/jw-optimize-v1.mjs.json`,
rejects the fixture: `prism.read` uses `Lantern.left`
twice although v1 declares it affine. This is a fixture type error, not compiler
conformance evidence. The consumed v1 source, catalog and controller stay intact.
[v2 source](../../selfhost/tools/performance/phase47/controls/jw-optimize-v2.bend)
changes only that declaration to `+left`; all other constructor fields are used
at most once. Its [catalog](../../selfhost/tools/performance/phase47/controls/jw-optimize-catalog-v2.json)
and [controller](../../selfhost/tools/performance/phase47/controls/jw-optimize-controls-v2.mjs)
bind the corrected source separately. They require fresh checked acquisition.

The coordinator reports that the 18 synthetic v1 cases passed on checked worker02. Independent
review identified a coverage gap: interpreter agreement alone cannot establish
refusal to inline a `valid:false` callee because the interpreter intentionally
ignores analysis flags. The [v2 IR controller](../../selfhost/tools/performance/phase47/controls/jw-ir-controls-v2.mjs)
adds explicit unchanged-call evidence for invalid target, wrong arity and invalid
callee. The earlier v1 result is preserved; it does not earn these additional
refusal checks. V2 JavaScript syntax checks pass; execution remains the
coordinator's responsibility.

### Array controller v2: lifetime and guard-order witnesses

The coordinator reports that the unchanged array v1 fixture passed 24 oracles and 31 boundaries
on the predecessor. The new
[array controller v2](../../selfhost/tools/performance/phase47/controls/array-view-controls-v2.mjs)
reuses the same source and catalog receipts; v1 remains unchanged. It expands to
39 scenarios, adding global Array wrapper/getter observations, inherited numeric
setters on Array/Object prototypes, safe-integer throw/reentry, a self-restoring
reflection hook, and late repeated length mutation. Setter controls record
events with captured `defineProperty`, so the observer does not itself invoke
the numeric setter.

The late Number hook is installed by `Array.fill` and alternates backing length
on successive conversions. Unlike a first-conversion-only resize, it changes
length after an initial view/length could have been cached. The reflection hook
waits until `seam.cell`'s bound-length descriptor is read, after its code/arity/
environment descriptors have been sampled; it then changes the code and restores
reflection before a later guard could inspect the host. The next call witnesses
the replacement. This tests guard ordering and fresh source checks, not a claim
that a final host check alone repairs an earlier stale proof.

After clean semantic comparisons, v2 parses complete candidate `G` assignments.
`external`, `escaped` and `opaque` must lack the raw-array entry marker. `bench`
must contain exactly one marker; a separate fresh diagnostic module counts entry
at that marker. Four clean inputs must enter once each, while all 39 hostile or
public scenarios must leave that counter unchanged and preserve the ordinary
candidate's observations. No marker or zero activation is a refusal, not a pass.
Counter derivatives are never timing evidence. Both the semantic comparisons
and activation checks must pass for this focused qualification.

### Array layout v3: several arrays, record transport and ordered writes

The coordinator reports that the array v2 suite passed on checked array01: 24 scalar oracles,
39 boundary comparisons, four successful entry counters and 39 refusals. Those
consumed files remain unchanged. The separate
[v3 source](../../selfhost/tools/performance/phase47/controls/array-layout-v3.bend),
[catalog](../../selfhost/tools/performance/phase47/controls/array-layout-catalog-v3.json)
and [controller](../../selfhost/tools/performance/phase47/controls/array-layout-controls-v3.mjs)
exercise the next layout and statement-write changes. The coordinator checked
and emitted the 4,255-byte source on both the predecessor and array03.

`Cradle` transports two arrays; `Carousel` transports four. Each iteration reads
two cells before writing two cells, then swaps or rotates array roles according
to a Boolean. Both roots allocate their arrays locally using explicit
`Array.new` calls. The independent oracle preserves references between state
transitions, so it also specifies writes through different public handles that
share all or pairs of backing arrays. Zero, one and several iterations, both
rotation directions, maximum U32 seeds and wrapping additions are included.

The controller has 77 scalar observations, 56 complete public-state checks and
seven demand/write-order boundaries. Public checks compare every backing cell,
the accumulated value and the complete backing-alias matrix. Returned storage
is mutated and fed into a second public call; zero-iteration malformed handles
must remain undemanded. Public record input/output roots must not select the
private raw layout. Existing v2 controls remain the separate 39-case host,
callback, reflection and storage-lifetime suite.

`ink.store` returns `Array.set` directly inside a one-iteration loop. Source
helper hooks establish index evaluation, then value evaluation, then native
entry, then `Number(index)`; throws at each earlier step suppress later effects
and preserve the original sentinel. Clean cases independently check the written
cell, including an index that wraps to zero. The controller checks statement
temporaries only inside the complete `write_order` root assignment, while a
separate diagnostic derivative counts actual raw entry for `dual`, `four` and
`write_order`. These are distinct requirements: source spelling alone does not
prove execution, and successful raw entry alone does not establish the statement
write path. All public and hostile controls must refuse the instrumented private
entries. The controller is untimed and does not establish a speed improvement.

The array03 run passed all 77 scalar oracles, 56 public-state cases and seven
boundaries. It also passed 15 clean entry observations, seven hostile/public
counter refusals, the four public-root shape refusals and the statement-write
spelling check. The receipt is
`selfhost/build/phase47/array03-layout-controls/observations-v3/report.json`.
These are focused correctness and activation results; broader qualification
and performance selection remain separate. The consumed v3 source, catalog and
controller are frozen.
