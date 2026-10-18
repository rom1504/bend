# Phase106 scalar-IR laws

The real experimental `nx_fold_bin` helper now has **twelve independently
checked public contracts and one support lemma**. All four deliberately wrong
helpers are safely admitted in isolation and rejected by the unchanged public
contracts. Thirty finite backend observations and an executable Bend bridge
also exist; their native execution is a separate pending gate.

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

The [source manifest](../../selfhost/build/phase106/law-source02/manifest.json)
records exact extraction, the recursive call-site inspection, all frozen
packages and four single-edit mutations. Its source pins are:

- `ir/model.bend`: `4f38489f3ee5aa9b850fc64046edbf2b524c190b1209beebdb7ac7ded5d86e83`
- `ir/optimize.bend`: `674d8a58303f41c39630246d8a63fd7f024b0b9aaaa3f5f9c949b882e317f6e7`
- public laws plus support: `961f9ec21332e314b27a9664504c4c2aa2269f0dbc6878b254663c65db8d34d4`

The [positive report](../../selfhost/build/phase98/phase106-law-check02/report.json)
has `complete: true`, `independentlyChecked: true`, thirteen unique named laws,
and zero opaque definitions. Guarded source checking, elaboration, independent
kernel verification and the separate false-kernel-equality rejection total
**43.145 seconds**; the kernel itself accounts for 41.440 seconds. This is
slower than the historical tiny-helper packages, so do not promise their
two-second budget for this Word32 package.

The [mutation report](../../selfhost/build/phase98/phase106-law-mutants02/report.json)
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

## Backend bridge status

`laws/bridge.bend` constructs one actual `NxProgram` containing thirty literal
cases and their runtime-dependent counterparts. The preparer checks exact
ordered correspondence with `cases.json`; independent BigInt arithmetic checks
its expected literals. This is data validation, not backend execution.

The root harness additionally prepares ninety nonzero-seed dynamic cases and
explicit folded-AST checks. Across C/CLIF and raw/fold variants this yields
**600 proposed arithmetic result observations** from four built products.
Those observations remain pending until the root execution report exists;
they must not be counted as proved cases or completed runs here.

See [method and commands](../../selfhost/tools/performance/phase106/laws/README.md).
