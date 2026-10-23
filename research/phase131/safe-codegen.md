# Safe recursion, literal selectors and native code generation

Status: V02 removes the closure in emitted QBE and reduces unchanged safe-proxy
native runtime by 59.36%. Broader qualification and compiler-cost gates remain.
No production compiler or proven summary source was edited by this work.

## Finding

The safe summary program does not fundamentally require slower native code.
Its source expresses structural recursion through a deferred callback. An
existing general selector transformation already knows how to remove that
callback, but its closedness grammar excludes a scalar constant in another
branch. This is a small missing composition rule, not evidence that safe Bend
or QBE inherently imposes the observed cost.

This is currently a hypothesis about the **size** of the performance effect;
the emitted closure and selector rejection are independently visible in code.
Neither source proofs nor static instruction counts prove compiler correctness
or attribute the whole runtime difference.

## Frozen baseline evidence

The selected Phase130 source is
`selfhost/build/phase130/mode-source01/compiler.bend`, SHA256
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.
Its native N1 image is `selfhost/build/phase111/p130-native01-n1/program`, SHA256
`a25e4c7f55a6a48829bf9d148498d6392b98fe1ab66b9664d99ce1987715c2c5`.

Two proxies execute the same fixed repeated 64-ID workload and independently
checked outputs:

| Source variant | Source SHA256 | Median native wall time |
|---|---|---:|
| unsafe summary helpers | `1226537fa16a60edc4da77a5836cbfa88c1e8a0545ba04dda33ba86974a75214` | 0.094279 s |
| proof-connected safe summary | `4954f44e5420f0c61f5279e975965eb91ba02ab214e12ea771185cd02f22a51c` | 0.241731 s |

The five alternating pairs give **2.5640×** safe/unsafe. Evidence is
`selfhost/build/phase131/usage-safe-jobs01/timing/report.json`. This fixed batch
includes process startup. It is generated proxy performance, not native
compiler request latency or a complete compiler speedup.

The QBE inputs are
`selfhost/build/phase130/p131-usage-safe-jobs01-safe-emit/program.ssa` and
`selfhost/build/phase130/p131-proxy-jobs01-usage-candidate-emit/program.ssa`.
Corresponding exact-output native build reports live in
`selfhost/build/phase111/p131-usage-safe-jobs01-safe-build/` and
`selfhost/build/phase111/p131-proxy-jobs01-usage-candidate-build/`.

The read-only [inspection script](../../selfhost/tools/performance/phase131/safe-codegen/inspect.py)
preserved source QBE and `objdump` slices in
`selfhost/build/phase131/safe-codegen-inspect01/`. Its report SHA256 is
`520b5a083386d5d9681c44b34c50aac27e0273d9f8e08a0bbeee96f1a5758564`.
No target was executed by that script.

## What the machine actually does

The safe source uses:

```bend
def choose(value: U32, tail: Unit -> U32, order: Cmp) -> U32:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: 0
```

Each `p131u_max`/`p131u_min` recursive call supplies a literal lambda for
`tail`. The full checked source remains structurally recursive. In current QBE,
the direct entry takes a list and its entry, installs a 32-byte continuation,
allocates a closure capturing the remaining list and key, and returns through
the scheduler. `choose` later applies the closure on the LT branch. The actual
safe max entry contains 137 QBE lines and 115 machine instructions, including
`p111_rt_closure` at native address `0x4118fb` and `p111_rt_return` at `0x411916`.
Those addresses belong only to the pinned binary above.

The unsafe source splits the same decision into a first-order helper. The
compiler combines helper and recursive lookup into `$p126scc.35` (max) or
`$p126scc.33` (min). Each has 135 QBE lines and 103 machine instructions, but
the crucial difference is its **local loop**: the two logical states update
arguments and jump to `@p113_loop`. It does not create a callback or use
`p111_rt_apply`, `p111_rt_jump` or `p111_rt_return` inside that loop. The remaining
calls are takes, comparison, final reclamation and cold failures.

Comparing only 115 versus 103 instructions would miss the important result:
the safe entry performs only part of the computation, with additional work
hidden behind the runtime and continuation segments. Static callsite counts
are not per-iteration dynamic counts.

The safe merge is a useful negative control. Its three literal branch callbacks
are **already fused**; its direct body has no closure/apply call. It has 605 QBE
lines / 533 machine instructions, while unsafe merge and its separate helper
have 314/297 and 329/207 respectively. These are different function boundaries,
not a direct instruction-count speed comparison. Safe merge still performs
ownership/reconstruction work and small Unit construction/sink operations. We
must not claim a lookup-selector fix explains all of the 2.5640× gap.

## Existing capability and missing information

The relevant code is the mature bounded selector path, not a new Phase121
closure-fusion framework:

- `selfhost/tools/performance/phase99/branch-closures/helpers-v2.bend:4`
  (`nbc_closed`) admits bound variables, lambdas, applications, nullary matches,
  nullary constructors and impossible branches. Scalar literals are absent.
- The same file's `nbc_applicable`, `nbc_evaluate` and `nbc_select` preserve
  callback affinity, evaluate nonliteral actuals in ordered outer lets, enforce
  a bounded callee and check fresh binder IDs.
- `selfhost/tools/performance/phase112/selectors/emit.bend:15` routes a saturated
  known-lambda call through that plan in structured generic lowering. Phase113
  direct/product lowering has the same capability in its selector modules.
- `selfhost/src/back/native/book.bend:374` (`nc_source_body`)
  deliberately preserves pre-compaction erased source. This is correct for
  analyses that need literal types. The selector currently asks that view to
  satisfy a grammar with no literal node.
- `selfhost/src/core/term.bend:610` explains that `KLiteral` is a closed leaf;
  `selfhost/src/back/native/bridge.bend:610` lowers scalar literals to `NWord`.

Phase121 callback fusion has stricter loop/factory structure and is not needed
to repair this case. Raising general inlining limits or introducing a new IR
would obscure a much smaller missing scalar-value case.

## Isolated experiment

[Version 1](../../selfhost/tools/performance/phase131/safe-codegen/selector-literals.bend)
adds canonical leaf `NWord` to the closed selector grammar and compacts a bounded
callee before selection. It changes two existing declarations and adds one
helper. Existing saturation, closedness, one-use callback, freshness, ownership
lowering and ordered evaluation gates are retained. No source function name or
unsafe annotation participates in admission.

Source review found a cost problem before broad testing: a String literal is
one AST node but can expand into a very large spine during compaction. Hence
[version 2](../../selfhost/tools/performance/phase131/safe-codegen/selector-literals-v02.bend)
first admits only exact Nat/U32/F32 literal kinds and applies the full closedness
test **before** compaction. Strings, unknown literal kinds, references and data
fields remain refused without expansion. The candidate only compacts the small
callee, never substituted caller callbacks.

The semantic argument is deliberately narrow. An admitted scalar literal is a
closed value with no owned fields, callback invocation or effect; it introduces
no new affinity obligation when placed in a matcher arm. Its compaction is the
same checked native literal conversion already used outside this transform.
Only the selected matcher arm executes. Nonliteral actuals still become ordered
outer lets, and literal callbacks still satisfy the existing occurrence bound
and capture-avoiding freshness test. This is a source audit of an unsafe compiler
pass, not a machine-checked proof of code-generation correctness.

Finite controls cover accepted scalar leaves, malformed/canonical word text,
forbidden primitives/references/fields/free variables, strict outer evaluation,
freshness collision and string/unknown-kind refusal. Additional ordinary source
fixtures are in `selfhost/tools/performance/phase131/safe-codegen/fixtures/`:
unrelated text search, all Cmp branches, shared ownership, a dynamic callback
fallback, an unselected failing callback and an eagerly evaluated failing
nonliteral argument. Their addition does not claim they have passed yet. The
frontier forbids unsafe/failure-runtime probes: the two overflow fixtures are
source-only semantic review obligations and must not be launched. Ordinary
valid transfer and preserved ordered-let structure are the executable checks.

The decisive experiment holds safe source bytes, runtime and machine toolchain
fixed, changing only compiler selection. First require exact ordinary outputs;
then inspect whether max/min lose their callbacks and enter a direct local loop;
only then measure five alternating pairs. If the callback disappears but local
loop admission still fails, investigate that boundary before adding machinery.

Version 1 passed checked API acquisition and all 14 finite controls in the
coordinator's controlled lane. Emission of the unchanged safe source passed
the independent parent and selected final verifiers:
`selfhost/build/phase118/p131-selector-proxy01/report.json`. Candidate QBE SHA256
is `62ec41c4c3cc57df3619c0d2a3708bcc59becad552e88325a9933f965d06ad5b`.
Both lookup functions now have a 107-line direct worker with a local backedge;
neither contains a closure, apply, scheduler jump or scheduler return. On the
LT branch, `%p113_again_0/1` become the next arguments and execution jumps to
`@p113_loop`. Safe merge retains its 605-line body. Thus the first structural
falsifier has passed; this is not yet a native runtime measurement.

Version 2 also passed checked acquisition and **19/19** finite controls:
`selfhost/build/phase131/selector-finite02/report.json`. The independently verified
unchanged-source emission in `selfhost/build/phase118/p131-selector-proxy02/`
is byte-identical to version 1 (644,797 bytes, SHA256 above). Therefore rejecting
unbounded String expansion did not sacrifice this optimization. The individual
hosted emission timings are acquisition observations, not a paired compiler-cost
comparison.

The coordinator's actual native timing is now available in
`selfhost/build/phase131/selector-jobs01/timing/report.json`: five alternating
pairs give **0.245831 s → 0.0999114 s**, candidate/original **0.406423**,
**59.36% less time / 2.46× faster**. This block holds the safe source unchanged
and establishes that the missing selector capability caused most of its native
slowdown. The older unsafe-summary median belongs to a different block; the
new candidate is close to that earlier value, not a fresh paired equivalence.
This is a generated compiler-kernel result, not a complete N1 request result.

## Follow-on: keep prepared nullary constants through expansion

The local lookup loop still constructs and discards Unit when invoking its
inlined callback. `nbc_definition` intentionally asks for the erased source view,
so expansion recreates a constructor that `p112s_prepare` had already replaced
with an immutable packed word. This is another lost prepared fact at a boundary.

The separate borrow investigation exposed constant `atom(...)` calls in
`missing()` before existing static preparation and removed three constructor
calls. That source experiment and this compiler experiment share a principle:
expose closed values to the existing preparation once, then retain the result
across later transformations. Neither requires a cache or new general IR.

`selector-static-v03.bend` is an unqualified follow-on. It first retains V02's
original-source admission. Only then may it use a same-name `NativeStaticBody`
from the current `P112StaticImage`, with all static markers authenticated against
that image's constructor catalogue as **packed nullary, zero-payload** values.
One-field packed zero, static boxes, unknown constructors and special runtime
constructors are refused. Unprepared/foreign/unknown contexts keep V02 behavior.
The existing `p112s_value` and final image/program verification are unchanged.

This is a small compiler-cost/performance hypothesis, not a demonstrated gain.
First require that Unit constructor/sink calls disappear from the actual loop;
then decide whether a native paired test is worthwhile. Added context lookup and
bounded scans must also be counted. Synthetic image controls are data only and
never native targets. Production selection remains unchanged.

## Interpretation and remaining gates

This experiment tests whether a proof-friendly source formulation can reuse an
existing profitable machine representation. A positive result would justify a
small semantic admission extension and make the optimizer itself a transfer
workload. It would not demonstrate recursive research acceleration: acquisition,
qualification, compiler cost and future research throughput remain separate.

Before promotion, retain independent semantic oracles, ordinary native failure
behavior by source reasoning, ownership controls, deep stack safety, unrelated transfer and the
full final verifier. The new analyses are bounded but add a small callee scan;
measure complete compiler requests rather than claiming that a small patch has
zero compilation cost. Keep current qualified N1 and all failed attempts.
