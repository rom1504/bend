# Phase111 remaining compiler costs: bounded source audit

This is a source-only audit made while `native-self02` was running. It changes no
compiler or runtime source and runs no target. The current native fixed-point
attempt should finish before any optimization or image reacquisition.

## Observed cost and limits of attribution

`selfhost/build/phase111/full-emission02/report.json` records the checked API05
compilation of `full-source05/compiler.bend`: frontend 138.776 seconds, lowering
148.245 seconds, IR verification 47.994 seconds, and QBE emission 7.256 seconds
(rounded). The resulting program has 37,018 segments, maximum arity 26,
maximum incoming/result width 1, and 442 constructors. These are hosted API
measurements, not native stage measurements.

The coordinator separately observed `p111_set_regs` in 13 of 24 native samples,
closure application in four, and `nu_has`/`nu_insert` in one each. The logical
register-bank runtime change from 256 to 26 slots improved the five small
same-QBE cases by approximately 15–18%. Those observations support substantial
generic runtime overhead; they do not quantify the source-level costs below.
The register-bank improvement must not be attributed to a lowerer change.

## Highest-confidence small correction: reuse an existing use set

The new lowerer computes the same deterministic subtree analysis twice:

* `segment/lower-control.bend:25`, `p111_bind_value`, computes
  `uses = nc_uses(body)` at line 28, then calls `p111_lower(..., body, ...)` at
  line 30. `p111_lower` at line 21 independently computes `nc_uses(t)` again.
* `p111_let_cut` at line 36 repeats the pattern: the first scan is line 38 and
  the second is reached through the call at line 41.
* `p111_lower` also scans the term when its environment is empty, although
  partitioning an empty environment produces no live bindings or sink calls.

The authoritative selected mature compiler already avoids these costs:
`selfhost/build/phase102/projection-cost-source01/compiler.bend`, SHA-256
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`:

* `nc_prepare_env`, line 32275, returns the empty partition directly for `Nil`.
* `nc_let_atom`, line 32346, passes its existing `bodyUses` to
  `nc_partition_uses` and then `nc_lower_partition`.
* `nc_let_emitted`, line 32370, and `nc_let_cut`, line 32411, do the same.

The corresponding readable base definitions are in
`selfhost/src/back/native/bridge.bend:172`, `:231`, `:252`, and `:287`.
The selected source, including its overrides, was inspected directly; the
equivalence is not inferred solely from those base files.

A minimal future patch would use `p111_lower_partition` directly in the two
let helpers, partitioning the exact same new environment with the already
computed `uses`. `p111_lower` would match its environment and call `p111_live`
directly for `Nil`; its nonempty case would retain the existing behavior.
This preserves variable identities, partition order, ownership operations,
fresh counters, continuation ordering, and generated statements. It only
removes duplicate analysis and an empty partition. No such patch is applied.

`nc_uses` traverses the entire term and builds a persistent numeric use set
(selected source lines 32220–32234). With nested lets, analyzing each remaining
body can sum suffix sizes and therefore be quadratic in a long linear chain.
The duplicate scan adds another coefficient to that inherited pattern. Reuse
removes the duplicate coefficient, not the underlying worst-case scaling.
It should reduce analysis work, but no numeric whole-compiler speedup is
established. Even a 50% reduction in this duplicated component would not imply
a 50% reduction in total lowering time.

## Verifier: real work, but no identified whole-program quadratic lookup

`segment/verify.bend:11` and `:15` use the existing exact-name hashed trie for
lookup/insertion. Function and constructor indexes are built once at lines
297 and 310. Each segment gets a schema pass followed by a flow pass
(`p111v_segment`, line 336). This audit found no repeated linear scan of all
37,018 segment names per reference.

The join operation at line 143 intersects persistent local maps only when
both branches remain nonterminal. Generated match arms terminate through
return/transition, so that expensive general-case join is not expected to
dominate this generated corpus. This is a source observation, not a measured
branch-frequency count.

A secondary, lower-priority opportunity is redundant persistent updates:
`p111v_decl` at line 57 looks up a local and still rebuilds its record/map path
when a repeated non-allocation definition has the same width and capacity.
`p111v_assign` at line 104 also inserts the schema record on every assignment,
including repeated scratch/result locals. Avoiding an identical update could
help, but adds comparisons and has no measured gain or exact mature precedent.
Any change must preserve duplicate-allocation/type-change refusals and must
not accidentally retain stale pointer capacity after `N111Offset`. A narrow
schema-only identical-record fast path would be safer than changing all flow
updates. It is not the first recommended experiment.

Local binding lookup (`nc_word`, selected source line 32040) is linear in a
local environment, not the complete program. Observed maximum segment arity
26 is encouraging but is not a proof bounding every intermediate environment.
`p111_compile_defs` (`segment/lower-book.bend:41`) accumulates reversed segments
and reverses once, so it does not append every function to a growing global
output list. No evidence from this audit establishes large accidental deep
copies of shared complete books or graphs.

## Proposed fast gate after the fixed-point attempt

1. Make an additive candidate with only use-set reuse and the empty-environment
   case. Preserve the current source/image and receipts.
2. Check that candidate, then rerun the existing focused ownership/semantic
   controls. Require byte-identical complete emitted QBE for the same frozen
   actual source inputs. This checks that the proposed analysis-only change
   leaves machine behavior and statement order unchanged.
3. Reuse a captured checked request to measure lowering separately; retain
   frontend, verifier, and emitter stage measurements as separate results.
   Compare bounded nested-let families at sizes 64, 128, and 256 to distinguish
   a coefficient reduction from a scaling improvement. An optional diagnostic
   Bend variant can count `nc_uses` visits without changing the production API.
4. Reacquire a native image only if those measurements justify it. A full
   self-hosting rerun is not the first performance experiment.

The best-supported cheap correction is the three-site mature use-set reuse
pattern. The audit does not show that the remaining 148-second lowering or
48-second verification cost is necessary, nor that this correction alone
will make native self-compilation fast enough.
