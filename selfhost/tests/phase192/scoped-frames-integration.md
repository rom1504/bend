# Scoped H frame reuse, separate candidate

The frozen `recursive-regions-experimental.bend` remains unchanged. The new
`recursive-regions-experimental-v2.bend` differs only in passing the exact
factory case-buffer list to the worker's scoped setup entry; the public
adapter still uses ordinary setup.

Files to integrate for this candidate:

- `scoped-frames-experimental.bend`: scope validation and the shared late
  traversal, calling unchanged `p185fr_expand` / `x185_late_accessors`.
- `scoped-frames-integration.patch`: replaces four existing entry bodies with
  default-empty wrappers. It has not been applied by this agent.
- `recursive-regions-experimental-v2.bend`: use instead of the frozen H module,
  never alongside it, since declarations intentionally retain their names.
- `scoped-frames-controls.bend`: export `p192hf_controls`, 22 fixed `=1` rows.

Use the full canonical inventory, as for the first H candidate. The new module
depends on the existing `p185fr_expand` ownership-sensitive frame factory;
do not copy its implementation or broaden global `p114t_buffer` admission.

## Scope and traversal

`x192hf_case_buffers(cases,0)` is supplied only from an admitted, closed H plan.
Each member must have the exact generated case-buffer spelling for index0..7,
one matching top-level setup allocation of2048 bytes/alignment8, and an
unblocked fixed-buffer definition across params/setup/body. Duplicate scope
entries, missing/incompatible allocations, incoming parameters and conflicting
definitions clear the complete scope. A partial valid scope affects only its
listed buffers; other frame calls remain original.

This validates the factory capability's materialization. An arbitrary buffer
with a generated-looking name is not an independent ownership certificate;
the only production nonempty caller is the H plan factory.

The late pass is one traversal. Setup retains ordinary processing, then the
same `next` site counter flows through the scoped body visitor. Branches visit
yes/no/rest in the original order. One original scalar consumes one site,
regardless of expansion size. Generated expansion statements are not fed back
into the expansion hook. The original site saturation guard remains in force.

The scalar hook returns immediately to `x185_late_scalar` for an empty scope.
Otherwise it inspects only the possible buffer operand; canonical
`p185fr_expand` still owns every symbol/type/state/FID/count/admission check.
Successful expansion receives existing accessor expansion; every refusal
returns to the complete ordinary scalar pipeline.

Empty scopes skip allocation/definition scans. The refactor adds small wrapper
calls and one empty-list match per scalar; this is compiler work and must not
be represented as free. It does not introduce another lowering pass.

## Required default-identity gate and scoped ablation

`x192hf_scope_enabled() -> Bool` is an explicit ablation constant. Acquire the
same source with it set to false, keeping all other selected features fixed.
That disables scope admission while retaining the refactored visitor and v2 H
factory. Compare **all three complete objects byte-for-byte** against the
frozen first H candidate in `recursive-emit01` before attributing any scoped
change. The ordinary emitter path and adapter must remain exact as well.

An equivalent refactor-only control uses the frozen original H module with
the new empty-scope wrappers. Neither control is a new runtime timing claim.
After default identity passes, enable scope and require:

1. All22 compiler-data rows pass. They cover materialized scope and duplicate,
   missing, partial, short, misaligned, parameter, redefinition, function-id,
   state, symbol, count and saturated-site refusals; nested branches check the
   shared counter.
2. Repeat the H direct-worker stack sentinel controls with
   `x192hf_function_setup(symbol,formals,setup,body,ids,
   x192hf_case_buffers(cases,0))`. Keep the existing ordinary worker comparison
   and depth-zero/large-depth/external-state checks.
3. Confirm the selected helper calls disappear from the exact workers while
   all required capture/FID/SP stores remain, then run the matched output and
   runtime screen. Preserve any regressions and compiler acquisition cost.

The static witness is three frame sites in expression eval, one each in tree
scan/warp, and one in lexer gen. Source-level workloads imply64 calls per
size32 expression evaluation and9984 calls per size8 lexer evaluation
(39 template characters times256 lines). Those are control-flow counts,
not sampled runtime shares. The removable work is call/argument transport and
helper overhead, plus any newly provable private staging; actual frame writes
remain necessary.

No compiler or target jobs were executed by this agent. Patch application,
independent source checking and all identity/runtime gates belong to root's
guarded serial lane.
