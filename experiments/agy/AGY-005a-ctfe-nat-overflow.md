# AGY-005a · Wrong result when folding the successor of U32.max as a Nat

**Open promotion blocker for compile-time function evaluation (CTFE).** At `fb74dedc`, Agy's hosted compiler emitted an x86 executable that printed `True` for the comparison below. The pinned upstream Bend compiler and the Phase205 compiler on `selfhost/bootstrap` both printed `False`. The later native self-build checkpoint at `7cb80c34` uses the same CTFE source. Its reproduction gate checks compiler artifact agreement; this probe checks the value of a user program.

## Reproducer

Save as `nat.bend`. The successor is taken **after** conversion to Nat, so the left operand equals 4,294,967,296.

```bend
import Base

def boundary() -> Bool:
  Nat.is_eq(Succ{U32.to_nat(4294967295)}, 0n)

def main() -> IO(Unit):
  IO.print(Bool.show(boundary()))
```

## Evidence

The pinned upstream CLI at `9a4223d5` ran the source and printed `False`. For each x86 row below, the review compiled the same source once using the branch's `research/agy/emit_obj.mjs`, then linked that object separately with each runtime. All four programs exited successfully with empty stderr. Each printed the indicated line followed by a newline.

| Object producer | Phase205 runtime | Agy runtime | Object SHA-256 |
|---|---|---|---|
| Phase205 hosted API | False | False | `1750395103c5d5ea81669ca0e7b266211faa43320547175e978c917224b30fa8` |
| Agy unified hosted API | True | True | `41347e0f41c8cee53c6f3e2c81e2f3130122990d00f03f38af0fe29dcedbbec6` |

The answer follows the emitted object across both links. The Agy API and runtime identities are in the [qualification receipt](receipts/unified-qual-report.json). The original local review logs are in `selfhost/build/phase201/agyreview02-guard/stdout.log` and `selfhost/build/phase201/agyreview03/rows.json` in the bootstrap checkout.

## Diagnosis and acceptance test

In [the evaluator](../../research/agy/big_wins/ctfe.bend), `ctfe_as_nat_succ` increments a U32 accumulator. At a `CVNat{n}` leaf, `ctfe_as_nat` returns `Some{U32.add(acc, n)}`. For this input the leaf adds 1 to 4,294,967,295 in U32 arithmetic and returns zero as a successful conversion. The resulting Boolean literal passes type checking.

The smallest repair is to decline the fold whenever either accumulating a successor or adding the leaf would overflow, then evaluate the original checked expression at runtime. Add the program above as a permanent differential test. Check the adjacent representable case and a nested-successor case, and require equal outputs from upstream, Phase205 and the repaired Agy compiler before promoting CTFE. The binary-fork linearization and runtime fast paths can be evaluated independently.
