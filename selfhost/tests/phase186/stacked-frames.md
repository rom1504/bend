# Composing pending frames inside an admitted private region

The retained Phase185 Unicode64 QBE `sjoin.go` (SSA5485) pushes continuation89
and90 before its non-tail self descent. Each continuation calls the already-ready
String.append worker and returns (SSA5580/5607). The previous H planner cannot
skip the second frame when recognizing the first frame's tail. This witness has
two closed cases and no new mutually recursive machine call or Map dependency.

`P114RPushFrame{frame}` retains the exact original frame stores and call. The H
renderer executes them through the existing scoped frame renderer and increments
its depth once, then continues with the remaining body. Existing descent,
result, and unwind operations preserve stack order. Case renaming touches frame
locals only; the private depth remains emitter-owned. The non-H renderer refuses
the new node. Original successful local plans and unsuccessfully retried payloads
are retained. Unknown calls, missing continuations, eight-case closure bound,
eight-capture bound, hygiene and original N111 verification remain in force.

Files to register/check: new `back/qbe/stacked-frames.bend`, existing `model.bend`
and `local-continuations.bend`. No runtime ABI changes. The runtime stack still
holds recursive pending frames; native call depth does not grow with traversal
depth. It retains the existing runtime stack-capacity assumptions.

Append `stacked-frame-controls.bend` to the checked API and export:

- `p186sfc_controls`: all14 metadata rows must end `=1`.
- `p186sfc_oracle_module(mode)`: mode0 has two pending frames; mode1 alternates
  reversed two-frame order with one frame. Original segment verification is
  separately exposed as `p186sfc_verified(mode)` and must return the empty string.

Compile each returned QBE module through authenticated machine tools and link
`stacked-frame-controls.c`, defining `STACKED_MODE=0` or1 respectively. Expected
stdout is `phase186 stacked mode0 controls pass: 42\n` / mode1 similarly. The
independent iterative C oracle checks LIFO order, full64 words/wrapping, unchanged
register bank and state, stack restoration/canaries, and100001-deep descent.
Its only runtime stub aborts on the unreachable error route; success execution
must contain no global jump/return or recursive native call.

Run `stacked-source.bend` through both source targets against its three literal
output lines. This exercises shared heap-valued captures, nested non-tail self
recursion, zero iterations and alternate branches. Screen actual native45
Unicode16/64 against the retained complete oracle and inspect sjoin.go admission
using `p186hp_probe` before interpreting a timing result. Record aggregation is
not promised to admit: it also depends on unready Map.get/set/seek workers.

These are prepared controls, not passed results. No target execution occurred
while implementing this candidate.
