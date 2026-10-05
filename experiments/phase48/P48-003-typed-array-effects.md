# P48-003: Compositional typed Array operations

Status: arrays02 checked build, focused controls and actual Evening entry passed;
first Evening screen regressed; causal diagnostic prepared; not promoted.

Hypothesis: Broaden Array operations/types in complete private graphs with exact conversion, alias and callback order.

Design: [mechanism](../../design/phase48/typed-array-effects.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

Outcome and receipts will be appended with their original attempt identities.

## Arrays02 executed checkpoint

The shared native proof now covers canonical Array<U32/F32> new/get/set/swap/size
and the existing F32 conversion path. A separate handle-preserving literal
producer admits positive/nullary scalar roots while retaining ordinary ctor and
lazy arraydata. The [typed report](../../implementation/phase48/typed-array-effects.md)
and [literal report](../../implementation/phase48/literal-array-handles.md) explain
the distinct contracts; the [hash evidence](../../implementation/phase48/array-evidence02.json)
binds every report and selected compiler identity.

The guarded arrays02 build passed in 50.133 seconds, API
`9bdeb7bb69e0291ad46c320f30b71fd65feb503a9fefe05ddc2987b03c1331f3`, unchanged
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
Root-executed reports under `selfhost/build/phase48/`:

| Report | Scope | SHA-256 |
| --- | --- | --- |
| `arrays-controls02/report.json` | 115 oracles / 14 boundaries / 16 entry observations, pass | `e295857174bc7b0252d332a6dd33233bf4ed67220bc2c51169c4f244b34d892b` |
| `literals-controls02/report.json` | 40 oracles / 26 boundaries / 29 entry observations, pass | `24865751812d01f27e2b209b1bcd55bb058281428b4954584786daf3c974423d` |
| `array-fill-controls02/report.json` | two allocator-hook source comparisons, pass | `00cfd2dbf2e25c9b56e4c400a8a7d45959f46bd5b3352db8781c87e0dd1eb92b` |

The last report confirms an old U32 correctness bug: when fill or isSafeInteger
replaces a helper, array06's public optimized call returned `6` and skipped the
replacement. Ordinary source execution on both images threw the original helper
sentinel; arrays02 public execution now does too. The universal fresh guard is
eleven lines. Its superseded, unexecuted 53-line scoped proposal is preserved;
preserving the old U32 admission would have retained this now-demonstrated bug.

The arrays01 compiler build passed, but its first effects fixture acquisition
failed parsing a computed match. Consumed v1 remains unchanged; v2 moves matches
into helper parameters, and additive controller v3 includes the late-fill
mutation. These failures and corrections are separate from compiler conformance.

Decision: continue to the actual maintained Evening consumer and controlled
timing. The focused results establish expanded coverage and a specific repair;
they establish no corpus speed gain. Private-body duplication increases the
effects fixture by 62,676 bytes, so generated size and entry cost remain gates.

## Actual consumer and adverse first timing

The later `literals-evening02/report.json` passes the actual `fpart() == 8` and
`main.out() == 81111` observations with two instrumented fpart entries. Its SHA is
`16d7394d9873152ac16d352a74098d2998783e60eb5c194633e4b04172092a32`.
The fresh three-round `arrays-screen02/report.json`, SHA
`75f5c764a57c153a22a141fd921ad84c155a94091c5d31402d3aad0ab321eadb`, records
Evening median array06/arrays02/TypeScript times of 157.648/212.686/2.960
microseconds: 34.91% regression from array06. The short fold canary is
14.303/14.607 microseconds. All observed values pass. This is a short two-point
screen with material Evening within-sample drift, not final corpus evidence.

The [evidence](../../implementation/phase48/array-evening-evidence02.json) records
all sample medians/drifts and exact checked modules. Only G[fpart] differs
between entire Evening modules (+1,610 bytes); the typed-effects changes do not
alter any other emitted definition here. The new full host plus five-dependency
guard surrounds a small straight-line calculation. Its fixed entry cost is a
plausible cause, alongside wrapper/JIT effects, not a measured cost attribution.

A hash-bound saved-JavaScript producer now disables only the literal private
entry, retaining its ordinary fallback and all other correctness guards.
Execution is pending. Selection should be reconsidered before promotion:
reuse the ordinary region's loop-work admission, or defer standalone literal
entries. Preserve the universal array-effect guard repair and all adverse results.

## Unexecuted loop-qualified successor

The next source uses the existing `j_region_has_loop` predicate in the literal
root selector. Only `array-literals.bend` changes for this successor, SHA
`795ea4888d9dca473c8793e895bab6609276cbabcbde533bb87f88cc2b672cc3`.
The universal fresh array guard remains. New v2 source/catalog/controller retain
all acyclic cases as ordinary/refusal controls and add a renamed literal-array
F32 countdown with positive-arity and nullary entries. Separate 0/1/128/8192
diagnostic points test whether work amortizes the guard; full45 is unchanged.
This candidate has no execution/performance credit yet. Details and pending
gates are in the [literal report](../../implementation/phase48/literal-array-handles.md).

Arrays03 subsequently built and acquired both v2 fixtures, but controller v2
stopped after 96 oracle/39 boundary observations. The baseline and candidate
both threw the same source TypeError under a getter-only Object.prototype[0];
the controller had incorrectly required success for that raw nullary body.
The deferred Tuple/force stack explains the shared error. A fresh v3 controller
retains exact differential comparison, requires that precise error and zero
getter reads, and preserves private-entry refusal. V2 and its failed report are
retained; no compiler change or completed activation credit follows from this
correction. See the literal report for exact controller hashes and scope.

The fresh `literals-controls04/report.json` using reviewed v3 subsequently
passes 96 oracles, 41 boundaries and 47 entry/refusal observations, SHA
`64d4dff6f398d5856b3842a0800e7f2e87336c01f9b30cd4d7574fdbe57de12a`.
Both source lanes report the exact TypeError with zero inherited getter reads;
the positive loop roots enter and the acyclic roots refuse as intended.
Candidate API is `f26fbeee36fea7025bc731e4c79a28822a16d246b23f890ba8df00793fede653`.
The [hash evidence](../../implementation/phase48/array-literal-evidence03.json)
separates this qualified correction from the original failure. Scaled runtime
and actual arrays03 Evening equivalence are still pending.
