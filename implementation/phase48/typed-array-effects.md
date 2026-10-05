# Typed array effects: focused arrays02 results

Corrected candidate `checked-arrays02` passes all three focused control groups.
It also repairs an executed historical U32 allocation-callback bug. A subsequent
actual Evening literal entry passes correctness but regresses in a short screen;
the [literal report](literal-array-handles.md) separates that cost from these
untimed controls. Corpus performance and release qualification remain pending.

The compiler source now has a shared canonical U32/F32 array effect contract in
`selfhost/src/back/js/array-effects.bend`. It proves the native definition's erased
kind, exact live arity, element-consistent arguments and result before emitting
new/get/set/swap/size. The existing local region and raw-array consumers can use
the same proof. `array-view.bend` additionally admits the existing canonical F32
primitive catalog and F32.to_u32 through the complete closed-graph audit.

The raw and handle printers share the operation selection. Existing U32
new/get/set output spelling is preserved. Swap retains two ordered index
conversions and length reads; size returns the original handle/backing value.
No store rounding, host cache, public layout change, or runtime edit was added.
Source native calls are normalized before private emission, including the live
F32.to_u32 operand, which must not be mistaken for an erased array element.

Independent static review passed the typed source slice and root integration.
The root's guarded checked build completed successfully in 50.133 seconds. Its
API SHA is `9bdeb7bb69e0291ad46c320f30b71fd65feb503a9fefe05ddc2987b03c1331f3`;
the unchanged runtime SHA is
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
No compiler or target was executed by this report author.

| Focused report | Executed scope | Result |
| --- | --- | --- |
| `arrays-controls02/report.json` | 115 oracle observations, 14 effect/ABI boundaries, 16 entry/refusal observations | Pass |
| `literals-controls02/report.json` | 40 oracle observations, 26 boundaries, 29 entry/refusal observations | Pass |
| `array-fill-controls02/report.json` | fill and isSafeInteger mutation against ordinary source execution | Both pass |

Paths are relative to `selfhost/build/phase48/`. The
[evidence index](array-evidence02.json) binds their exact hashes, both compiler
identities, checked emissions and eight integrated frozen JS-backend sources.

The additive controls are under
`selfhost/tools/performance/phase48/controls/array-effects-*`. They bind checked
emissions to the exact source/catalog/compiler receipts, compare independent
F32/U32 recurrence oracles, distinguish NaN and signed zero, compare host-effect
and error traces, verify public handle identity with changing backing getters,
and separately instrument guarded raw entries. Prior Phase47 controls remain
unchanged, including unused aliased F32 signature checks.

Evening remains a distinct coverage question. Its nullary `fpart` constructs a
literal ANode/ALeaf tree before two swaps. The raw proof requires fresh Array.new
and scalar positive-arity entry, so widening element typing alone does not admit
that graph. Its main also includes Map, Set and string parsing/showing. The
source diagnosis is explicit in the [design](../../design/phase48/typed-array-effects.md);
the original focused checkpoint made no Evening performance claim. The implemented
[literal-handle adapter](literal-array-handles.md) preserves lazy backing
realization and repeated nullary demand. Its subsequent actual consumer passes
but costs 34.91% more than array06 in the first screen; the whole emitted Evening
module differs only in that new literal entry. This does not invalidate the
separately demonstrated U32 allocation-hook correctness repair.

The root's first checked arrays01 compiler build passed in approximately 51
seconds. Baseline acquisition of `array-effects-v1.bend` then failed during
parsing: Bend requires a parameter or field match scrutinee, whereas the fixture
destructured an Array.swap call. This is a fixture failure, not a successful
semantic gate or compiler regression. The original source/catalog/controller and
`arrays-baseline01/modules/array-effects-v1.mjs.json` failure remain intact.

The new v2 fixture moves every computed pair match into a helper parameter,
following the existing tested fixture pattern. Its arithmetic, operation order,
independent oracle and expected `bench(3,2) == 24` are unchanged. The v2 catalog
binds the new source, and the v2 controller changes only version/catalog paths.
No target was executed by the author. The separate literal-array fixture already
matches only parameters and requires no such repair.

Before promotion, a source audit found a weaker handle-fallback guard after raw
refusal: allocation callbacks could mutate helpers after validation. A scoped
53-line proposal was superseded before target consumption after independent
review confirmed old U32 new/get/set graphs share the same hole. Its exact bytes
and SHA are preserved under `selfhost/tools/performance/phase48/proposals/`.
The eleven-line replacement requires the fresh array host guard for every
proved native Array graph, including ordinary/tree and flat-record selectors.

Additive controller v3 retains the v2 source/catalog and adds a late fill callback
which replaces `wash.step.code` with a throwing sentinel. The separate
`array-fill-boundary-*` controls exercise the old U32 domain using fill and
isSafeInteger callbacks. Candidate public behavior must match ordinary ungranted
source execution; any historical public mismatch is recorded separately.
The original arrays01 snapshot is preserved. Arrays02 executed these controls,
including the new late-fill helper replacement, successfully.

The old U32 bug triggered in both tested allocator hooks. Ordinary ungranted
source execution on both images logged `[hook, "helper"]` and threw the original
`late allocation helper sentinel`. The Phase47 array06 public optimized path
instead returned `6` and logged only `[hook]`: it bypassed the newly replaced
helper. Arrays02 public execution matches the ordinary trace and original error.
The report records `historicalMatchesOrdinary: false` and
`candidateMatchesOrdinary: true` for both hooks. This is a specific executed
correctness repair, not equality to an incorrect baseline or a full conformance
inventory improvement.

Generated size remains a measured tradeoff even before timing. The effects
fixture library grows from 87,052 to 149,728 bytes as multiple public roots gain
private bodies; the literal fixture grows from 82,611 to 87,277 bytes. The old
U32 boundary fixture grows only 22 bytes, from 88,910 to 88,932. These are the
three fixture artifacts, not corpus-wide size estimates or speed predictions.
