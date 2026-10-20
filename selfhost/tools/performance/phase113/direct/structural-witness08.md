# Corrected08 structural witness

This is an offline inspection of the parent-run emitted products. It executes no
compiler or target. The initial source06 semantic controls mostly used generic
fallback; corrected08 now demonstrates the intended complete-function route.

| Fixture | Direct functions | Inspected function | Function bytes | Frames | Dispatcher jumps | Direct calls | Keep calls |
|---|---:|---|---:|---:|---:|---:|---:|
| p113-scalar08-scalar-region-8192-emit | 19 | `$direct.mit` | 6473 | 0 | 0 | 7 | 5 |
| p113-controls-direct08-scalar-closed-loop-emit | 2 | `$direct.loop` | 1081 | 0 | 0 | 1 | 0 |
| p113-controls-direct08-tail-argument-permutation-emit | 1 | `$direct.rotate` | 2363 | 0 | 0 | 0 | 0 |

All three inspected functions have local loop branches. The argument-permutation
control therefore tests the parallel self-tail argument transfer mechanism in
this emission, rather than merely exercising the unchanged fallback.

The scalar-region `mit` still has five ownership keep calls and seven direct
callee calls. This establishes removal of its seven previous runtime frames,
not upstream runtime parity. Performance and complete-output qualification
remain the parent-owned matched execution receipts.

Exact emitted program SHA256:

- `selfhost/build/phase111/p113-scalar08-scalar-region-8192-emit/program.ssa`: `f9c0ce3824f8edde4180b329d744d3145a907a3f24421846f5749fa7ca610dab`.
- `selfhost/build/phase111/p113-controls-direct08-scalar-closed-loop-emit/program.ssa`: `cb2893d8446952ff40075fb01aab11c28cfee23424f742c10a920ffc6e067f73`.
- `selfhost/build/phase111/p113-controls-direct08-tail-argument-permutation-emit/program.ssa`: `d3e2b1cbdddd54d247315a90f11e4acdf05c2c457f497bbbc20d415a120dca29`.

## Hot-route audit

The emitted hot path is `p113d $direct.p93.loop` → `p113d $direct.p93.value`
→ `p113d $direct.bench` → `p113d $direct.mit`. The descriptor's segment285
is the public `$direct.mit` wrapper, which also calls the new complete function.
The retained `p112w $direct.mit` symbol is a453-byte forwarding wrapper to that
same function. Thus both the descriptor/curried route and older private ABI
route converge on the new loop.

The original seven `mit` continuation entries remain in the immutable segment
table (FIDs286–292), but the emitted program has no `p111_rt_frame`,
`p111_rt_jump` or `p111_rt_closure` call targeting those FIDs. Existing fusion
calls the retained private ABI rather than embedding an alternate old `mit`
entry. No route around the new loop was found in this source audit.

The new loop's residual work includes three `asr8`, two `b2u` and two `sel`
direct calls, five ownership keeps and one special constructor take. Removing
frames therefore leaves ordinary-call and ownership overhead. This is a source
explanation of the remaining mechanism, not a measured attribution of time.
