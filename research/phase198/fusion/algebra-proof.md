# Independent finite-word algebra check

Status: **not yet independently accepted in Lean**. Both original guarded attempts exhausted their 12-second deadline without a Lean diagnostic or theorem axiom report. Their exact proof/method/guard evidence is retained in `evidence/word-algebra-timeout01.json.gz` and `word-algebra-timeout02.json.gz`. A timeout does not establish that a theorem is false or accepted.

`Affine.lean` states the intended invariant for every bit-vector width `w : Nat`, including zero, and every finite `Context w`:

```text
run context m b = m * value context + b
run context 1 0 = value context
```

The context has one distinguished child beneath each add, multiply, left subtraction, or right subtraction constructor. Siblings are already evaluated `BitVec w` values. The running multiplier/bias updates match the modular affine algebra; right subtraction negates the multiplier. This model does not prove the Bend recognizer, binder matching, source evaluation order, worker loop, U64-to-U32 implementation, encoding, or runtime correct.

The staged third attempt replaces the broad `Std` import with `Init.Data.BitVec.Lemmas`, uses explicit distributivity/associativity/commutativity rewrites, and selects one Lean worker thread. It first runs an import-only control, then the theorem, with `/usr/bin/time -v` per phase and Lean heartbeat tracing. The whole internal run is bounded at 45 seconds inside a 50-second resource guard. `algebra-argv.json` is the exact coordinated command; CPU3 execution remains owned by the qualification queue.

The receipt driver writes failures as well as success, pins the proof, Lean executable/runtime and bit-vector library, records per-phase CPU/wall/RSS output, and requires both theorem axiom reports. It refuses proof placeholders, new axioms, `native_decide`, and unexpected axiom dependencies. Standard Lean logical dependencies are reported explicitly if present. A future successful report must name the exact proof bytes; no acceptance is inferred from this source file or the earlier mathematical argument.
