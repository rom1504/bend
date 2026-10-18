# Phase106 scalar-IR laws

The real experimental `nx_fold_bin` helper now has **twelve independently
checked public contracts and one support lemma**. All four deliberately wrong
helpers are safely admitted in isolation and rejected by the unchanged public
contracts. The executable Bend bridge also passes **600 native arithmetic
outputs across four products**, with **300 independent interpreter results**
and explicit checks that literal expressions really became folded constants.

The first source check (`phase106-law-check01`) rejected the attempted
reflexivity proof for `fold_eq_exact`: the candidate and reference Bool-to-word
helpers remained distinct neutral applications. This is a proof-authoring
failure, not a compiler counterexample. The repair adds one support lemma by
case analysis over Bool and uses congruence in the two comparison contracts.
All twelve public statements and the frozen reference are unchanged. The
repaired closure passes independent checking with no opaque definitions.

The eight operation contracts cover wrapping add/sub/mul, bitwise and/or/xor,
equality and unsigned less-than. Four fallback contracts retain U64 literals,
mixed literal types, one explicit unknown operation and a call-containing
operand without altering the tree. The reference uses checked Base operations;
there is no new arithmetic axiom or opaque law body.

The preparer snapshots the exact model and safe helper prefix, hashes the full
source files, and checks the actual call from `nx_simplify` into the helper.
The latter traversal is unsafe and is not part of the proof. C/CLIF emission,
machine instructions, shifts, foreign effects and memory ownership likewise
remain outside it. This is a small transformation contract, not a claim that
the new IR or compiler is universally correct.

## Accepted source and proof evidence

The [source manifest](evidence/law-source.json)
records exact extraction, the recursive call-site inspection, all frozen
packages and four single-edit mutations. Its source pins are:

- `ir/model.bend`: `4f38489f3ee5aa9b850fc64046edbf2b524c190b1209beebdb7ac7ded5d86e83`
- `ir/optimize.bend`: `674d8a58303f41c39630246d8a63fd7f024b0b9aaaa3f5f9c949b882e317f6e7`
- public laws plus support: `961f9ec21332e314b27a9664504c4c2aa2269f0dbc6878b254663c65db8d34d4`

The [positive report](evidence/laws.json)
has `complete: true`, `independentlyChecked: true`, thirteen unique named laws,
and zero opaque definitions. Guarded source checking, elaboration, independent
kernel verification and the separate false-kernel-equality rejection total
**43.145 seconds**; the kernel itself accounts for 41.440 seconds. This is
slower than the historical tiny-helper packages, so do not promise their
two-second budget for this Word32 package.

The [mutation report](evidence/mutations.json)
has `complete: true` and eight successful protocol steps, totaling **4.775
guarded seconds**. Each helper admission precedes its intended law rejection:

| Wrong implementation | Rejected unchanged contract | Distinguishing witness |
| --- | --- | --- |
| Addition becomes subtraction | `fold_add_exact` | `1 + 2`: 3 versus 4294967295 |
| Subtraction operands reversed | `fold_sub_exact` | `0 - 1`: 4294967295 versus 1 |
| Unsigned less-than becomes equality | `fold_ult_exact` | `0 < 1`: 1 versus 0 |
| Literal type guards removed | `fold_u64_preserves` | U64 operands become an inadmissible U32 folded result |

These are semantic source-check rejections after safe helper admission, not
independent-kernel rejection of unelaborated mutants. Expected/observed mismatch
and the intended law location are checked explicitly; a malformed helper,
resource stop or unrelated failure would fail the protocol. The original
failed proof-authoring attempt is retained rather than counted as a mutant.

## Completed backend bridge

`laws/bridge.bend` constructs one actual `NxProgram` containing thirty literal
cases and their runtime-dependent counterparts. The preparer checks exact
ordered correspondence with `cases.json`; independent BigInt arithmetic checks
its expected literals. This is data validation, not backend execution.

The [final control report](evidence/README.md)
has `complete: true`, `passed: true` and `inputsUnchanged: true`. It consumes
the repaired native Bend producer `producer-native02` and its `artifacts02`
products. The arithmetic subset contains 150 inputs:

- Thirty literal expressions and thirty dynamic expressions with seed zero.
- Ninety further dynamic expressions: each of the thirty rows with seeds 17,
  2147483648 and 4294967295.

For both raw and folded IR, the independent interpreter agrees with the fixed
integer oracle on all 150 inputs, giving **300 interpreter observations**.
Each IR variant is compiled through the actual Bend C printer plus Clang and
through the CLIF consumer, producing four executables and **600 exact native
outputs**. The control method additionally checks all thirty literal AST
results: raw IR retains the expected binary operation, and folded IR contains
the exact expected `u32` constant. Disabling folding cannot silently satisfy
this structural gate. Four deliberately wrong expected-output controls also
fail as required, one per executable.

The input corpus, producer, artifacts, oracle and methods are pinned at the
start and checked again at the end. The
[outer guard](../../selfhost/build/phase106/controls-guard04/process.json)
records 9.759 seconds for the entire control campaign, including its other
workloads and negative cases; this is not an arithmetic-only timing. These
checks validate the finite backend bridge, not a universal machine-code theorem.

## What the laws bought, and what they cost

The contracts reject four concrete wrong transformations and quantify over all
U32 operands in their stated helper domain. The native matrix addresses a
different boundary: both emitters and the shared recursive pass actually use
the chosen representation and agree with independent results on the selected
inputs. Neither evidence source replaces the other. Ownership and the complete
recursive pass remain unproved.

The independent positive proof costs about 43 seconds, versus under five seconds
for the eight source-only mutation steps. This cost belongs in the research
budget. It is not evidence that adding laws made optimization or research
faster. Use cheap source checks during local proof-authoring, then independently
check the frozen survivor; retain accepted proof identity when exactly unchanged
code is reused. A future claim that proof reuse saves validation work needs
its own measured comparison. The package establishes a useful constraint on a
real optimization, not a speed gain from constant folding or recursive research.

See [method and commands](../../selfhost/tools/performance/phase106/laws/README.md).
