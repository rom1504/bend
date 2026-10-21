# Phase117 scalar identity audit and bounded candidate

Starting HEAD `6703ff7`; read-only code/machine inspection plus an experimental
Bend source file. No target/compiler runs, subagents, production changes or
performance qualification were performed by this audit.

## Finding and scope choice

The qualified scalar-region `mit` loop has no machine calls and accounts for
essentially all its runtime profile. There are two different missed simplifications:

1. Three source arithmetic-right-shift idioms retain logical shift/sign-fill and
   Boolean selection machinery instead of the `sar` present in faster C output.
2. Seven adjacent comparison-to-Boolean materializations unnecessarily compare an
   already canonical0/1 predicate to zero before explicitly extending it to U64.

The first has greater potential, but correct discovery requires expression/value
provenance across copy chains and branch joins. A function-name match, a rule
specialized to `asr8`, or stripping high bits from arbitrary machine values would
be unjustified. The bounded candidate implements only the second identity through
existing verified private-emission hooks. It can be tried within the ordinary
small-program loop without a full native acquisition. It is not a claim to have
implemented arithmetic shift recognition or achieved the Phase1161.3–2× estimate.

## Prepared implementation

[scalar-identities.bend](../../selfhost/tools/performance/phase117/scalar-identities.bend)
contains80physical lines (including comments and8 finite diagnostic controls).
It introduces `p117s_*` helpers and replaces exactly **`p113w_look`**. No original
verified IR, runtime ABI, ownership logic, shift semantics, optimizer admission or
fallback semantics change. It operates only while rendering already verified
private direct functions.

Recognized sequence, with the same predicate local and no intervening statement:

```text
predicate:U32 = compare_w_or_l(a,b)
if predicate then value:U64=1 else value:U64=0
```

Current output:

```text
%predicate =w ceql %a, %b
%normalized =w cnew %predicate, 0
%value =l extuw %normalized
```

Candidate output:

```text
%predicate =w ceql %a, %b
%value =l extuw %predicate
```

For the0/1 inverted arms, it emits `xor predicate,1` before `extuw`. Signed and
unsigned comparisons are recognized by the existing verifier's comparison
predicate; their input width is unchanged. Both N111 scalar diamonds and P113D
direct diamonds must consist of exactly one same-destination U64 constant
assignment in each arm. Other conditions, branches with extra work, noncomparison
producers, intervening statements and unrelated condition locals retain the exact
old width-pair emitter path.

This keeps the explicit zero extension that was required after the historical
QBE narrow-phi issue. It does **not** reinterpret every U32 condition as Boolean:
only the immediately preceding comparison provides that proof. The inverted
variant uses a fresh `%p117_scalar_N` temporary and the shared counter; counter
exhaustion, terminal blocks and prior errors fall back through existing checks.
The noninverted variant needs no temporary. Existing input `%v_*` and other
emitter namespaces cannot collide.

The semantic identity is immediate for comparisons, whose result is exactly0or1:
`zext(c != 0) = zext(c)` and `zext(c == 0) = zext(c xor 1)`.
It would be false for general nonzero integers in the first case, hence the
adjacent producer requirement. The old comparison and every effect in the tail
still execute in the same order. The typed original graph is still verified.

## Composition and proposed root validation

Source preparation must append all new `p117s_*` declarations and replace only
`p113w_look` from this file, after the current Phase114 width/Boolean profile.
Do not append a duplicate old definition or route the fallback recursively through
itself. `p117s_original_look` is an exact renamed copy of the parent definition;
it calls the ordinary width emitter for unmatched shapes.

Exports for a checked diagnostic API:

- `p117s_control_report`:8 finite shape/output controls; every line must beginPASS.
- `p117s_pair`, `p117s_emit`, `p117s_emit_value` if the root wants additional raw
  shape/output checks. These are diagnostic helpers, not caller-supplied proofs.
- Existing public compiler/QBE emission entries remain unchanged.

Required bounded checks before a performance claim:

1. Check the assembled Bend source and run the8 diagnostics. Verify exact old
   fallback-source identity and the single override set.
2. Reuse ordinary scalar/Boolean/array source controls, including both comparison
   outcomes, U32 sign boundaries, high U64 operands, mixed-width uses and branch
   effects. Preserve current original45/ordinary output oracles. Do not resume
   historical custom failure reproducers.
3. Emit scalar-region8192 through the checked candidate. Confirm disappearance of
   redundant compare-normalization sequences while explicit `extuw` remains.
   Root should inspect actual machine instructions: QBE may already eliminate
   some redundant intermediate comparisons, so fewer QBE lines alone is not a win.
4. Check one unrelated numeric/array workload and exact complete outputs; benchmark
   the scalar case in the existing rotated clean small loop. Do not rebuild the
   full compiler for this peephole without a material, transferable gain.

Seven syntactically adjacent compare/renormalize pairs occur in the selected
32,465-byte QBE `p113d_FID_$direct.mit` body;10 occur in the whole scalar-region
image. These are static opportunities, not a measured seven-instruction reduction
or guarantee that each pair is reached dynamically. The root must determine
whether the two-statement IR matcher actually sees those shapes before promotion.

## What a real arithmetic-shift rule needs

The source idiom, for32-bit x and a compile-time k in1..31, is:

```text
(x >>> k) | ((x >>> 31) == 0 ? 0 : (0xffffffff << (32-k)))
```

Its result equals the32-bit two's-complement arithmetic-right-shift result,
zero-extended back into the full machine Term. At the final machine interface,
`%tmp =w sar %x,k; %out =l extuw %tmp` is the desired representation.
N111 already admits `sar`; no new backend is needed. A U64 `sar` applied directly
to zero-extended x would be wrong for x>=2^31, so width is part of the law.

The current source lowering deliberately implements U32 shifts with full Nat
counts: counts>=32 return zero, including2^32. Preserve that behavior; a machine
count mask cannot replace the checked guard. The proposed idiom recognition must
prove k is in1..31 and the high fill constant is exactly derived from that k.
It must also prove both shifts read the same low32 snapshot, not merely equal
local names that may have been reassigned.

A general narrow pass would retain symbolic pure scalar expressions/versioned
origins across immutable copies, comparisons and effect-free branch joins, then
recognize the equivalence regardless of source name or inlining depth. Calls,
loads, reassignments and joins need conservative invalidation. It should reuse
existing bounds for width and exact constants, but the current `P113KFact`
range-only join is insufficient to preserve this relational expression identity.
The scalar-facts relation metadata for branches is useful infrastructure, not
already a proof of equivalence between the two dataflow paths.

Cheap falsification before that pass is a frozen ordinary source family implementing
this exact identity for k=1,8,16,31 and boundary/random U32 inputs, compared against
an independent integer arithmetic model; a negative family must vary one operand,
fill mask, shift count or intervening assignment and remain on fallback. Inspect
three expected `sar` operations in the actual scalar loop, then measure. A direct
source helper replacement keyed to the name `asr8` is explicitly excluded.

## Evidence pins and present status

| File | SHA256 |
| --- | --- |
| Selected scalar-region QBE `selfhost/build/phase111/p114-final-screen01-scalar-region-8192-emit/program.ssa` | `0e39ac9922486ea62be2e560fa47bce9693499ea6a2e0cc95318181fc3229059` |
| Corresponding `build/program.s` | `79e60feb7397414902a2c1fb754ea648529ad697aca0b383f8d4f8fe7ebf5508` |
| Prepared candidate `scalar-identities.bend` | `d70fcb6966edc5cfa432df61da4083b2fa9b530415e7c274bf22c7f1e19807a2` |

Current status: implementation prepared and inspected only; **source checking,
finite controls, semantic execution, machine-code effect and runtime gain are
unmeasured**. Keep this optional and separate from the root's array investigation.


### Source-check repair v2

Root's checked API attempt `selfhost/build/phase111/p117-boolean-api01` rejected
`p117s_control_report`: a standalone `P113DScalar` literal had no expected type
for bidirectional inference. The original candidate and failed attempt remain
unchanged. `scalar-identities-v2.bend` changes exactly six control-function let
bindings to explicit `P113DStmt`, `List<&2,N111Stmt>`, `N111Ids` and `P111QCode`
annotations, using the repository's `+name : Type = value` syntax. The emitter,
recognizer, fallback, export names and eight controls are otherwise byte-identical.
The other unannotated local (`diamond` in the hook) is a call to the explicitly
typed `p117s_pair`, so its result type is inferable. No targets or compiler runs
were performed by this repair; root qualification remains pending.

V2:5,074bytes, SHA256
`e667b1c9c2a027d136641dea454e6daf7efbe833ad6affd5549097fda0cecdb0`.
Original preserved SHA256
`d70fcb6966edc5cfa432df61da4083b2fa9b530415e7c274bf22c7f1e19807a2`.
