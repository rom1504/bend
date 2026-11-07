# Phase173 SCC revision2: reserve previously admitted identities

Revision1's source and measurement files remain unchanged. This bounded update
addresses a correctness risk identified by independent audit, not a measured
performance regression. No target was executed by the implementation agent.

## Why the ready index matters

The original prototype checked generated `$p173scc.N` names against its raw
candidate catalogue. `p113d_passes` can also receive an already populated ready
index. If that index contained the proposed generated name, it would skip the
new worker and could admit wrappers calling the old worker. Matching argument
and result counts would not prove that the old worker computes the same thing.
The final verifier cannot repair incorrect identity allocation on its own.

Revision2 passes the actual ready index into the transformation. It excludes
already-ready members from candidate SCC discovery, checks fresh worker names
against both raw and ready identities, and leaves a colliding component
unchanged. The allocation slot advances after a rejected component, allowing
later independent components to proceed. This is conservative; no search for an
arbitrarily distant unused slot is needed.

The call-site audit finds one nonempty-seed invocation:
`p168_candidates` in `selfhost/src/back/qbe/early-observers.bend`. Its private
overlay now calls `p173sc_candidates_reserved(raw, ready)` using the exact index
passed immediately afterward to `p113d_passes`. The ordinary `p113pl_plan` and
`p128raw_plan_finish` paths pass an empty ready index; their existing interface
delegates to the new function with `missing()`.

Any future call site with existing workers must pass their occupied identities.
The empty-index wrapper is not an authorization to ignore them.

## Separate implementation files

* [scc-v2.bend](../../selfhost/tests/phase173/scc-v2.bend)
* [scc-prelude-v2.bend](../../selfhost/tests/phase173/scc-prelude-v2.bend)
* [scc-overlay-v2.bend](../../selfhost/tests/phase173/scc-overlay-v2.bend)
* [scc-controls-v2.bend](../../selfhost/tests/phase173/scc-controls-v2.bend)

The new controls use an existing worker with the **same ABI but a different
constant result**, test an already-ready component member, and ensure a later
component can still fuse after the first name collides. They extend the prior
18 controls to 21. The parent's later `abi-api03` checked acquisition and
`abi-finite03/report.json` pass all 21 controls. Native execution and benchmarking
remain separate gates; this finite result is not a correctness theorem.

## Revision1 admission is visible in actual emitted QBE

The parent's `scc-owned-emission01/program.ssa` has SHA256
`9eacd24485b9c3c7bce7b8fab88d2b3006b1144b0675f04f381e8e9bad8d92a9`,
60270 bytes. Its decoded private worker is `$p113d_FID_$p173scc.0` at lines
169–353. The three decoded wrappers `$direct.p173owned_a`, `b`, and `c` each
call it once. The worker contains:

* Three local tail backedges to `@p113_loop`.
* No scheduler jump, continuation push/pop or recursive native call.
* Three static List-constructor sites and three terminal calls to the sum
  helper; these are source work preserved by the transformation.
* Entry allocations of the ordinary 2048-byte scratch and three 16-byte
  renamed member scratch buffers.

One transfer, at lines 226–232, is:

```qbe
%p113_again_0 =l copy 1
%p113_again_1 =l copy %v_p113i_0_local_p113i_0_local_v_4294967281
%p113_again_2 =l copy %v_p113i_0_local_p113i_0_local_v_4294967280
%v_p126scc_tag =l copy %p113_again_0
%v_p126scc_arg_0 =l copy %p113_again_1
%v_p126scc_arg_1 =l copy %p113_again_2
jmp @p113_loop
```

Every source value is snapshotted before any parameter assignment. The loop
backedge adds no native call frame. This is concrete code-shape evidence for
the intended transformation, not a runtime speed measurement or a theorem
about all inputs.

## Remaining large-store risks

The owned fixture has only three states. The compaction loop has 36 source
members, more arguments, arrays and multi-result helpers. It may encounter
different lowering errors, result-shape differences or the explicit body/scratch
budgets; inspect actual candidate refusal reasons before changing bounds.
The subsequent diagnostic found missing boxed-to-flat argument composition,
rather than a genuinely non-tail loop or oversized component. The narrow argument
bridge restores the complete 36-member compaction SCC without raising limits;
see [the boundary experiment](product-argument-boundary.md) and its actual emitted
QBE evidence. All four main store loops now use fused workers.

Even an admitted large component can lose time to the linear tag-dispatch
chain, padded argument lanes, register spills and larger machine bodies. A
future exact emitter specialization could jump directly to the verified member
label on constant-tag transfers after the same argument snapshots. That remains
a proposal until ordinary dispatch is measured.

Neither revision removes owned node retention, store reconstruction, work-list
allocation, import/export conversion, or mandatory output. Both still need the
complete workload oracle and clean measurements. Successful SCC fusion is a
new compilation capability; it does not by itself establish a faster full
self-build.
