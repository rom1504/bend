# Literal array handle entry: arrays02 focused results

Candidate arrays02 passes 40 independent oracle observations, 26 boundary observations
and 29 entry/refusal observations in `literals-controls02/report.json` under
`selfhost/build/phase48/`. The [evidence index](array-evidence02.json) binds the
checked source/API/runtime and exact reports. The later actual Evening consumer
also passes, but its first controlled screen regresses; the adapter is not ready
for promotion on the basis of coverage alone.

The follow-on to typed array effects is implemented in `array-literals.bend` and
an explicit mode of the shared `array-view.bend` audit. It keeps original Array
constructor handles and lazy `arraydata`; it does not flatten a literal tree or
change its public identity. Canonical ALeaf/ANode admission is confined to a
typed planning context with bounded variable/literal/nested-constructor fields.
All existing raw consumers fix the new audit mode to false.

The scalar entry supports a demanded nullary root and ordinary leading-lambda
scalar roots after the original region selector declines them. It preserves a
complete generic fallback and uses the established zero-formal exactCode wrapper
for nullary definitions. Every entry revalidates the complete host/dependency
contract; repeated nullary loads rerun the computation. Private helpers retain
handles and the original constructor/field order. No runtime changes or host
cache were introduced.

Independent static source review passed this contract. The executed controls in
`selfhost/tools/performance/phase48/controls/array-literals-*` separately check
nullary ABI, missing argument vectors, raw code and construct calls, repeated
fresh storage, helper mutation/error/reentry, FloatView/iterator observations,
positive entry, zero-demand branch, and public/computed-field refusal. The clean
counters establish repeated selected entry. The fresh-storage observation
deliberately changes Array.swap and therefore establishes freshness on the
generic fallback; it is not misreported as a private-allocation counter.
Controller syntax and Bend delimiter checks passed locally; targets were run by
the root, not this report author.

The optional controller argument accepts the actual maintained Evening module
from the identical candidate compiler. It requires `fpart() == 8`,
`main.out() == 81111` and real new `fpart` entry on both calls. This is the intended
consumer test. The original arrays02 focused fixture run did not supply that
optional module. A later `literals-evening02/report.json` does: both values pass
and the counter records two actual `fpart` entries. The
[adverse-screen evidence](array-evening-evidence02.json) preserves that report's
hash separately from the earlier focused checkpoint.

## Actual Evening cost and diagnostic

The root's fresh three-round `arrays-screen02/report.json` records Evening medians
of 157.648 microseconds for array06, 212.686 for arrays02 and 2.960 for upstream
TypeScript. Candidate execution is 34.91% slower than the baseline in this screen.
The short 128-iteration fold canary is 14.303 versus 14.607 microseconds. These are
two points, not a corpus summary. Evening's samples have material half-to-half
drift, so retain the raw samples and confirm any selection change in a fresh run.

Static comparison gives a strong scope discriminator: the entire Evening modules
are byte-identical except for the single `G["fpart"]` assignment. That assignment
grows from 249 to 1,859 characters, adding 1,610 module bytes. There are no other
typed-effects or guard changes in this emitted program. The new nullary entry
adds the full fresh host check and a five-definition dependency check around
two swaps and several F32 operations. It also emits two pair helpers and their
unused read-helper variants. Host scanning, wrapper dispatch and changed JIT
shape are plausible costs; the current measurement does not separate them.

`array-literal-generic-probe.py` under the Phase48 tools pins both exact modules,
checked receipts and compiler identities. It proves the generic fallback equals
the old source body and adds only `false&&` to the new private-entry condition.
Thus the derivative executes the existing ordinary fallback, retains the new
exactCode wrapper/declarations and leaves every other byte and correctness guard
unchanged. It is an unchecked saved-JavaScript diagnostic; its producer and
target remain unexecuted by this report author. A successful timing recovery
would implicate entering the adapter; lack of recovery would retain wrapper/JIT
effects as candidates. Neither outcome permits removing correctness guards.

The smallest general profitability restriction is to require the existing
`j_region_has_loop(book,j_region_helpers(s))` before choosing the standalone
literal adapter. Ordinary region roots already use it to avoid paying entry
guards for trivial scalar wrappers. It inspects completed plans: these tuple
consumers are JUnpack helpers, while countdown plans retain Mat. This proposal
would defer the present straight-line `fpart`/fixture entries and require new
positive controls with genuine loop work. Alternatively, defer the standalone
literal selector entirely while retaining the shared typed-effects correctness
repair. No selection change has been made at this checkpoint.

## Loop-qualified source candidate

The authorized follow-on now adds that existing loop-work conjunct in
`j_array_literal_root_done`; the array module SHA is
`795ea4888d9dca473c8793e895bab6609276cbabcbde533bb87f88cc2b672cc3`.
There is no new score/threshold, runtime change or weaker permission. Arrays02
and all consumed v1 controls remain preserved. This new source is unexecuted at
the time of writing and must not inherit arrays02's activation credit.

`array-literals-v2.bend` retains the original acyclic definitions, then adds
renamed `ember.loop`, scalar `cycling` and demanded nullary `glowing`. The loop
starts with a canonical two-leaf Array<F32>, carries it with an F32 accumulator,
swaps cells and rounds each source arithmetic operation. The v2 controller
requires new private entry for both loop roots and absence for the old acyclic
roots. Its independent recurrence includes zero, short, nonfinite and 8,192/
50,000-iteration cases. Helper/Number/swap/fround/DataView/iterator callbacks,
throw/reentry, zero-demand storage, and nullary raw/constructed/missing-vector
calls must retain source observations and refuse permission when appropriate.

The v2 catalog's small acquisition point is `loop_bench(128,3) == 206`. An
optional separate scaled catalog keeps 0/1/128/8192 iterations and expected
0/1/206/13310; it does not modify the maintained 45 points. The optional actual
Evening check now requires the same results with no literal-entry marker.
Source/catalog hash bindings and controller lexical delimiters were inspected;
JS syntax checking, checked builds, target controls and timing remain root-owned.

## Arrays03: shared source error exposed a control assumption

The root reports the loop-qualified checked build passed in 51.61 seconds and
both v2 fixture acquisitions passed. `literals-controls03/report.json` then
stopped after 96 oracle and 39 boundary observations, before activation checks.
The v2 controller remains unchanged and this failed attempt earns no full pass.
The retained failed report SHA is
`c3bdcfe6792aa8ad440054a9f26e9acdc366d4c8acb4ed4dc58e36c1f8755601`.

At `glowing:missing-getter`, candidate and baseline observations compare equal;
the following assertion that the baseline had no error is what fails. Both raw
entries raise `TypeError: Cannot set property 0 of #<Object> which has only a
getter`. Unlike the smaller gleam body, glowing eagerly executes its loop before
returning the outer bounce. Its ordinary `ember.swapped` returns a deferred
Tuple, and runtime `force` pushes a pending frame into a fresh array. The inherited
getter-only numeric slot rejects that source operation. This is consistent with
the emitted ordinary body in both images, not evidence of a new private-path
semantic divergence.

New controller v3 keeps the v2 source/catalog and all comparisons. For this one
boundary it catches the source error before restoring the prototype, then
requires the exact TypeError, zero getter reads, equal baseline/candidate
observations and no private entry. It does not erase the error, grant permission
or substitute a candidate-derived value oracle. Its SHA is
`3cdbd0c4d68ceee7bcd5644031736de7debcd6e78ecceaee7b78359b25a7164b`;
root execution is pending. The original v2 SHA remains
`97e5371dbea218bd478e577a314b242eeafeb20931842ed36f4fc43309ba901e`.

## Arrays03 focused qualification with v3

The fresh `literals-controls04/report.json` now passes all 96 oracle, 41 boundary
and 47 entry/refusal observations on the same checked arrays03 image. Its SHA is
`64d4dff6f398d5856b3842a0800e7f2e87336c01f9b30cd4d7574fdbe57de12a`.
The [evidence](array-literal-evidence03.json) binds that success and the preserved
v2 failure separately, with candidate API
`f26fbeee36fea7025bc731e4c79a28822a16d246b23f890ba8df00793fede653`
and the unchanged array06 runtime. The guarded build took 51.611 seconds.

The corrected missing-getter boundary executes on both modules: each reports
zero getter reads and the identical required TypeError. The instrumented replay
also refuses private entry. Clean cycling calls enter once at each of 0, 1,
128 and 8192 iterations; repeated glowing calls enter twice. The old gleam,
seeded and conditional entries have no literal marker and leave the counters
unchanged. Both modules match the independent 8192/50000-step recurrences.
No compiler change was needed for the boundary correction.

The literal fixture module grows from 85,334 baseline bytes to 92,494 candidate
bytes. Scaled execution cost and actual arrays03 Evening emission remain
separate pending checks. The single serial
[command list](../../selfhost/tools/performance/phase48/controls/array-literals-scale-v2.md)
uses maintained acquisition, reference packaging and execution tools for the
four additional diagnostic points; it does not change the full45 corpus.

See the [design](../../design/phase48/literal-array-handles.md) for the exact
scope, falsifiers and remaining unsupported producer/callee boundaries.
