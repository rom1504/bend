# Phase123 ready-call/local-resume audit

Offline only; no compiler, benchmark or target execution. Parent is Phase121 source04. This is an implementation sketch, not an enabled transformation.

## Two actual barriers, not one

Current RLE QBE `selfhost/build/phase118/p121-broad-emit04/test-rle-roundtrip.ssa` contains:

- `$direct.lrepeat` private P113D wrapper at733, using Phase118 TRMC worker678; its public bridge is9217.
- `$direct.lconcat` private P113D wrapper804, using TRMC worker742.
- `$direct.expand` generic segment9415. Its success path retains one captured rest-list and continuation FID263, converts count using opcode24, then jumps to helperFID249 (`$direct.lrepeat`).
- Continuation `$p111.k.49955` at9513 pops/restores that capture, receives the list result, pushes it underFID264, and jumps to `$direct.expand` FID262.
- Continuation `$p111.k.49956` at9544 pops/restores the first list and tails to `$direct.lconcat` FID256.

The current `p114h_scan_frame` only accepts a frame whose following scalar prefix/argument stores end in a jump to the *same owner*. `p114h_scan_target` permits existing ready workers only terminally. Thus helper-before-self-recursion genuinely crosses an unsupported local-resume boundary.

However, `$direct.lrepeat` and `$direct.lconcat` are **not P112 ready workers** in this product: there are no corresponding `p112w_$direct.*` functions. They belong to the separate verified P113D catalogue. Merely broadening `p114h_scan_frame` to a P112-ready callee cannot admit this witness. The names `lrepeat`/`expand` without `$direct.` are zero-argument closure-construction workers and must not be mistaken for the two-argument helper implementations.

## Existing reusable machinery and negative evidence

`p113e_registered` already computes `direct=p113e_signatures(functions,missing())` next to the immutable P112 registry. `p113e_functions` verifies P113D workers in order; `p113e_call` allows only already-verified callees, with explicit self-tail loops. A public worker must preserve its exact original arity and one-Term result. This excludes a call path back into an unadmitted recursive owner.

The optional Phase114 `complete-bridge/model.bend` already has the exact predicate `p114b_target`: P113Direct, result1, public flag, matching arity and bounded parameters. Its argument snapshots and call to `p113e_symbol(target)` retain owning U64 transfer. Current Phase121 deliberately omits this bridge. Prior four-program measurements were only1.51% aggregate improvement; RLE was not included. Reuse the contract and code, not its old performance estimate.

## Smallest clean general extension

1. At `p113e_registered`, create one immutable local-call view from legacy ready workers and verified public single-Term complete workers. Preserve the distinct callable symbol (`p112w_symbol` versus `p113e_symbol`) and actual arity. Restrict both to the existing H limit8. Do not alter generic P112 readiness or rescan the catalogue per segment. Original H selection/fallback remains unchanged when no new call is admitted.
2. Add one honest structured terminal node to the existing local recursive plan, for example:

   ```
   P114RResumeReady {
     frame: List<N111Stmt>,
     call: List<N111Stmt>,
     result: N111Value
   }
   ```

   `frame` is the exact original capture stores plus `rt_frame`. `call` contains the unchanged scalar preparation/argument stores, snapshots of each full U64 argument, and one call to the authenticated worker symbol. It excludes only the original final `rt_jump`/Reply return. The result is that call's fresh U64 local. This is not arbitrary nonterminal N111 calls or a string marker disguised as old IR.
3. In `p114h_scan_frame`, keep the existing same-owner descent first. For the extension, locate the terminal target past only `p112t_scalar_safe` statements and require `p114r_arguments(tail,target,arity)`, an immutable callable record, target!=owner and captures<=8. Add the same `P114GFrame{continuation,captureCount}` to the pending table.
4. Keep `p114h_close`/`p112f_cont` unchanged: every continuation is still authenticated from original segments, incoming result1, exact capture layout, <=128 statements and <=8 distinct cases. This admits helper→local-resume→same-owner-descent→local-resume→terminal-helper without expanding unknown cycles or dynamic apply.
5. H emission executes original frame, increments `%p114r_depth` once, executes `call`, assigns `%p114r_value`, then jumps to existing unwind. The helper returns without popping caller frames. Existing unwind pops the saved FID/captures and resumes the exact local case. Injective continuation renaming must cover both new statement lists and result. Existing terminal helper handling also needs the new callable-symbol distinction so `lconcat` is admitted.

The new node belongs only to the H factory/emitter. Other R/G renderers must refuse it explicitly if reachable. Do not encode it via an overloaded `Descend` payload, a special fake runtime symbol, or a suffix-matched result name; those reduce source lines at the expense of a hidden semantic variant.

## Proof obligations and cheap gates

The original graph is independently verified first. The local view comes only from the verified complete catalogue or existing immutable P112 registry; arbitrary reflected records are not authority. Exact prefix/parser checks preserve evaluation and error order. Snapshot before call; do not retain/drop any additional owning copy. Capture words live in the same explicit stack while the helper executes. Private complete workers cannot inspect/consume scheduler return frames or reenter an unadmitted owner, and their native call graph is finite apart from explicit self loops. Therefore traversal depth does not become native recursion depth. Unknown functions, dynamic apply, wrong arity/result, private flat products, oversized tables and ambiguous frames retain original fallback.

First diagnostic: return the missing target/registry kind and first refusal for actual `expand`, rather than building a whole compiler. Then emit the same ordinary RLE source and a renamed list/tree walker calling an outlined helper before recursion, with a heap-owned helper result and retained external alias. Require local H selection, exactly two continuations for the successful expand chain, complete outputs and unchanged ownership behavior. A deeper ordinary input distinguishes explicit stack from accidental native recursion. Separately test unknown/cyclic callee rejection in pure plan controls. A terminal-bridge-only ablation on RLE can establish a small transport ceiling, but cannot demonstrate local continuation elimination.

This is plausible bounded work (one node, callable-view adapter, two planner hooks and rename/emitter cases), but not a safe8-minute implementation. No module is offered before the registry and new-node contracts are wired explicitly. It does not automatically promote callers such as `go` into the P113D closure; that is a separate later admission improvement.
