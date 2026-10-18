# Actual-source ordinary-call execution controls

Frozen **2026-10-18 19:32:02 UTC**, before target execution. `source.bend`
preserves the five previously declared call-shape functions and two refusal
functions from `../calls/call-shapes.bend`. It adds a clearly labeled synthetic
`p110_reverse_via_call` witness: consume one list constructor, rebuild its head
onto the accumulator, then ordinarily call the actual compiler `nt_reverse`
on the remaining tail. Its complete semantics are `reverse(xs) ++ acc`.
This is a generic continuation test, not an unchanged compiler function or
hotspot claim; no source name may be used by optimization pattern matching.

`catalogue.json` supplies eight source identities and machine symbols, six
exports, live arities, argument/result roles and cross-function dependencies.
Self-tail calls are internal to a body, so they are not listed as cross-function
dependencies. The host selects exact captured facts and passes the entire
closed catalogue to the **Bend** lowerer; this JSON implements no lowering or
call algorithm. IO/join helpers from the source wrapper are outside the selected
worker catalogue. Dynamic/partial functions are separate expected refusals.

The C harness directly calls the six generated exports. Its only algorithms
construct and observe test graphs. The 28 cases cover empty, unique, held roots,
static nodes and physically overlapping arguments. Results and retained aliases
are complete lists/strings of Unicode scalar values rather than digests. Aliases
are observed after dropping the result, followed by zero-live-heap validation.

Prepare a fresh directory with `prepare.py --out selfhost/build/phase110/controls-call-shapes02`.
Optional `--split training`/`heldout` selects 18/10 cases. Each prepared directory
includes `harness.c`, `abi.h`, `cases.inc.c`, exact `expected.jsonl`, source and
catalogue. Root owns source checking, emission, native compilation and execution.
Preparation is not a passing source or machine result.
