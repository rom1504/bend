# Phase43 products implementation status

Correctness: root-run saved-JS products-ablation02 oracle passes complete values,
aliases, host fallback, demand order, activation and deep12000 insertion. This is
not checked compiler-source qualification. Decision: investigate; no production edits.

Tools in `selfhost/tools/performance/phase43/products/`:

- `derive.mjs`: exact AST saved-output transformation, original/direct/products clean
  and instrumented variants, hashes, producer/parser identity and copied producer.
- `oracle.mjs`: complete tree values, duplicate/zero/limited fuel and U32 wrapping,
  fresh output shells/shared siblings, public zipper values and ordered frames,
  public hostile getter traces, ordinary-root executed apply reduction, postimport
  build-code/Math.imul fallback, proof cleanup and deep12000 iterative insertion.
- `make-source-patch.py` and `computed-u32-prefix.patch`: general held compiler
  proposal, 25 added lines and two changed selectors. No production source edited.
- `derive-v1-failed.mjs`: retained first selection attempt; root's run-products-derive01
  rejected expected one build call because guarded consequent contains two duplicated
  conditional alternatives. Latest diagnostic cleanup accessor may postdate that
  failed job; root run's consumed producer identity is exact if recorded.

Root-run commands:

```sh
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase43/products/derive.mjs \
  selfhost/build/phase42/integration03/full-preparation/modules/bst.mjs \
  selfhost/build/phase43/products-ablation02
/home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase43/products/oracle.mjs \
  selfhost/build/phase43/products-ablation02
```

Apply the held patch only after root's saved experiment survives. Build checked B1,
then prove ordinary source build-worker activation and actual generic-call reduction.
Check that covered lowering preserves the new RHS grammar; emitting a dead worker
is failure. Test untouched scalar/flat/vector/list consumers immediately. Keep
compact zipper prototype separate: it requires general escape/liveness/representation
proof and is not implemented by computed-prefix admission alone.

Review caught a normalization requirement: exact U32 Var gate now receives
`wnf(book,j_env(...))`. Recursive arithmetic depth fuel is not a shared-work budget;
current component source bound is required. Pure graph proof alone cannot authorize
an arbitrary computed allocating/effectful alias.

Optional separate `nat-wrapper.patch` permits exact Nat-first acyclic wrappers in
`j_component_admit`. Outer Nat-to-data precedence/type eligibility and complete
JPure plus recursive-helper coverage remain unchanged. This can directly emit
`p37.bst.insert`; U32-first `insert.fin` remains generic. Test separately; do not
attribute its effect to computed-prefix admission. The saved direct prototype
includes a manual direct fin shell and is an opportunity ceiling, not exact source
patch emission.

## Root-executed first evidence

[Oracle](../../selfhost/build/phase43/products-ablation02/oracle.json) and
[screen02](../../selfhost/build/phase43/products-screen02/report.json) pass. The
fresh budget60 protocol completes in19.82s, three process rotations per role,
350ms warmup and150ms target. Values below are milliseconds/call median [min,max].

| Point | Original | Direct | Products | TS | Original/direct | Direct/products |
|---|---:|---:|---:|---:|---:|---:|
| coverage-bst-32 | 0.250012087 [0.208163496, 0.254655704] | 0.107075650 [0.103466648, 0.108356450] | 0.053546807 [0.052718022, 0.058752167] | 0.023772640 [0.022615080, 0.024444080] | 2.335× | 2.000× |
| coverage-bst-64 | 0.376515499 [0.340994811, 0.384827355] | 0.164886983 [0.147997537, 0.164892857] | 0.097156385 [0.088322367, 0.098182337] | 0.052147589 [0.048975607, 0.053394440] | 2.283× | 1.697× |

These are two small supplemental saved-output points, not the final catalog or
an actual source-patch speed claim. Handwritten direct fin and compact zipper
kernels remain causal ceilings. Current derive additionally offers `pairs`, which
keeps BF/Con/List layout but holds tree/path state in locals and removes repeated
pair and inert leaf materialization. `derive-v2-direct-products.mjs` and
`oracle-v2-direct-products.mjs` preserve the three-variant producer/oracle.

Actual source controls: `actual-oracle.mjs ACTUAL_BST CHECKED16_BST NEW_OUT` checks
actual global build/insert workers exist, execute from ordinary root, reduce apply,
preserve complete private/public outputs and raw/data/partial boundaries, refuse
host/dependency mutations and handle deep insertion. Compile
`fixtures/prefix-controls.bend`, then supply `--fixture` to additionally check
renamed source activation, scalar-result recursion and allocating-prefix refusal.
