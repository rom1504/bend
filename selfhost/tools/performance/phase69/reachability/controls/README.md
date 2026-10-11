# Reachable bang metadata controls

Prepared by an independent source reviewer before execution. These files have
not yet been checked or run. Root owns all guarded compiler/native execution.

Every executable source independently expects `42`. Run checked B1 emission
against pinned upstream, then CPU binaries with one and four threads and GPU
off. CPU execution does not prove GPU conformance; the mark assertions below
specifically prevent silently discarding live offload requests.

| Source | Expected generated-C mark | Boundary |
| --- | --- | --- |
| `ordinary.bend` | `BANGS == 0` | Ordinary baseline. |
| `dead-bang.bend` | `BANGS == 0` | An unreachable def referring to a reached function with `!` must not change runtime mode or worker admission. |
| `live-bang.bend` | `BANGS > 0`; worker entry has bang bit | A reachable offload request survives. |
| `closure-bang.bend` | `BANGS > 0`; worker entry has bang bit | Mark inside a lambda reachable through a factory and an indirect caller survives. |
| `erased-bang.bend` | `BANGS == 0` | An offload request in an erased argument has no emitted runtime call. |
| `import-plain.bend` | `BANGS == 0` | Imported ordinary worker baseline. |
| `import-dead-main.bend` | `BANGS == 0` | Imported module main is not an entry root. |

Do not require identical complete C for the import pair: loader identities and
symbol names can differ because the module filenames differ. Require equal
output and equal zero bang count, and compare presence/admission of the mapped
worker symbol. The same-file `ordinary`/`dead-bang` pair must likewise preserve
worker admission; function IDs may differ so decode FID names and tables rather
than comparing hardcoded indices. `BANGS` counts marked native segments, not
source call sites; only zero/nonzero is a stable cross-compiler expectation.

Existing pinned tests to supplement this set: `compile/gpu_mark_closure.bend`,
`compile/gpu_reach_closure_box.bend`, `compile/gpu_reach_closure_list.bend`,
`compile/bang_intrinsic_closure.bend`, and `io/foreign_runtime_apply_tail.bend`.
These cover marked partial application, closure storage and foreign callback
entry; they should not be replaced with a direct-call-only control.

`raw-cases.mjs` exports raw API definitions and assertions without loading or
executing a compiler. Its lookup and demand cases are required in addition to
valid source: a masked later duplicate definition may contain a bang, an
unreachable erroneous definition must remain unvisited, and a live missing
reference must retain the existing native diagnostic. The producer/controller
must record both original and candidate results; historical metadata is not a
valid oracle for the intentional dead-bang change.
