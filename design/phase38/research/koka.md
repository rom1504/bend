# Koka and Perceus: allocation reuse requires a lifetime argument

Inspected 2026-10-01. Koka **v3.1.2**, commit
`3c4e721dd48d48b409a3740b42fc459bf6d7828e`, selected for a reproducible study,
not as a claim about the latest release. This chapter complements
[Lean](lean.md); neither runtime's uniqueness machinery exists automatically in JS.

## Primary evidence

- Reinking, Xie, de Moura and Leijen,
  [Perceus: Garbage Free Reference Counting with Reuse](https://www.microsoft.com/en-us/research/publication/perceus-garbage-free-reference-counting-with-reuse/),
  PLDI 2021, extended report v4 (2021-06-07).
- Lorenzen and Leijen,
  [Reference Counting with Frame Limited Reuse](https://www.microsoft.com/en-us/research/publication/reference-counting-with-frame-limited-reuse/),
  ICFP 2022, and [paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2023/07/flreuse.pdf).
- Koka implementation:
  [Parc.hs](https://github.com/koka-lang/koka/blob/3c4e721dd48d48b409a3740b42fc459bf6d7828e/src/Backend/C/Parc.hs),
  [ParcReuse.hs](https://github.com/koka-lang/koka/blob/3c4e721dd48d48b409a3740b42fc459bf6d7828e/src/Backend/C/ParcReuse.hs).
  Raw files were fetched and inspected; hashes are recorded in
  [external-source identities](../../../implementation/phase38/external-source-identities.json).

Perceus inserts precise reference operations after control flow is explicit;
its ownership information enables conditional reuse of unique storage. The
frame-limited work studies the less obvious problem that reuse can retain
objects longer, increasing peak memory. Its drop-guided approach ties reusable
storage to where it becomes dead and bounds the retention behavior. These are
runtime and semantic results in the papers' models, not JS speed predictions.

The pinned code separates reference counting from constructor reuse.
`parcExpr` in Parc.hs traverses the core with owned/borrowed environments;
`ruExpr` in ParcReuse.hs handles constructors, lambdas, applications and cases.
Reuse analysis expects case scrutinees already to be variables. `ruLam`
examines fixed allocation size; reuse availability is scoped. This is a useful
example of one pass depending on a stated invariant instead of rediscovering
all earlier facts.

## Why it matters to our profiles

Tree and list allocation estimates greatly exceed TS. Allocation removal can
reduce constructor, field-array and GC work together, but those estimates do
not identify which objects are uniquely owned or dead. Bend's affine source
discipline does not itself count references held by JavaScript hosts, runtime
closures, deferred fields or aliases introduced by representation.

The cheap transferable question is: **can the result avoid becoming an object
at all?** Existing producer/consumer and vector-slot optimizations already do
this in narrow cases. If the only consumer immediately destructures a private
result, write its fields to local destinations at the original demand point.
Only consider reusing an allocated node after direct calls and allocation
elimination leave a substantial measured cost.

## Example and necessary distinction

Pseudocode for a private tree rebuild:

```text
old = Node(left, key, right)
newLeft = visit(left)
return Node(newLeft, key, right)
```

An explicit uniqueness runtime might reuse `old`. Our JS backend cannot infer
that merely because the source consumes `old` once. Another JS reference could
observe the write; a closure might retain the original; a getter or exceptional
path may expose order. Even when reuse is sound, the old node must not be held
across unbounded unrelated work just to save a later allocation.

A narrower first case is a compiler-created temporary whose lifetime is wholly
inside one proof scope, with all aliases enumerated and no callbacks. Prefer
eliminating it. If reuse remains necessary, use invocation-local storage with a
precise last-use rule. A global scratch record is invalid under nested calls
or error reentry. Pooling can increase retained memory and worsen the fast loop.

## Proposed experiment

1. Choose an allocation site still hot after a direct tagged worker baseline.
   Count dynamic constructors/field vectors separately from sampled bytes.
2. Create independent variants: destination emission with no object, and
   invocation-local reuse with a lifetime proof. Keep algorithm/call lowering
   otherwise identical. Do not rewrite to an in-place algorithm simultaneously.
3. Test complete output trees, unchanged shared children, repeated subtrees,
   retaining the original input, failure before/after field production, and
   nested invocation. Include a deep skewed input and bounded-stack controls.
4. Time a small 20/60-second selection. Profile allocation separately. Run
   increasing input sizes under memory bounds to detect retention regressions.

**Stop** if the object escapes, ownership requires a new global runtime, or
allocation reduction fails to improve execution enough to justify the proof.
Do not change catalog input sizes after seeing a loss.

## Estimates and risks

| Proposal | Gain estimate | Complexity / risk |
| --- | --- | --- |
| Eliminate one private result container | 1.1–1.5× on an allocation-bound eligible component, low confidence | Medium; destination/demand proof, often existing mechanism |
| Reuse surviving private nodes | 1.1–1.5× eligible component, conditional on substantial remaining allocation | High correctness risk; 3–7 days including alias/retention controls |
| Add general JS reference counting | No credible positive forecast; extra bookkeeping may lose | Very high; new runtime/FFI ownership contract, defer |

These two positive ranges are alternatives or overlapping stages, not additive.
They are our planning estimates, not the papers' reported results. This work
could yield no win if dispatch remains dominant or V8 already removes the
temporary. A saved-output prototype takes roughly half a day once a site is
isolated; a full ownership analysis is not a quick iteration-loop improvement.

## Simplicity and conformance

The useful simplification is explicit local lifetime facts and a last-use
contract. Adding RC, arenas, pools and ad hoc reuse tags would add concepts
before we have evidence. Sharing a producer/destination mechanism across two
proven cases is preferable to a separate ownership subsystem.

The proposed controls strengthen alias, lifetime and reentry coverage. They do
not resolve existing backend failures, proof validity or GPU behavior. Keep
those conformance outcomes separate. Any future native backend may make
Perceus substantially more directly applicable; that is a different project.
