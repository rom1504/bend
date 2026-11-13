# Base H maintained integration candidate

`recursive-maintained-integration.patch` is prepared **but not applied**. It
adds the selected recursive-region capability independently of optional scoped
frame reuse. Runtime qualification and the decision to apply remain with the
Phase 192 integration lane.

| Maintained location | Change |
| --- | --- |
| `selfhost/src/back/x86/recursive-regions.bend` | Copy the 30 declarations from `recursive-regions-experimental.bend`; change only its introductory comment. |
| `selfhost/src/back/x86/program.bend` | Replace `x181_program_public` with the body in `recursive-hook.bend`. |
| `selfhost/src/compiler.json` | Add `src/back/x86/recursive-regions.bend` immediately before `program.bend` in `profiles.x86.modules`. |

Keep `profiles.x86.roots` equal to `["main"]`. The maintained public renderer
reaches `x192h_public` transitively; an extra experimental export root is
unnecessary. The canonical `modules`, `order`, protected declarations and all
other profile inventories remain unchanged. Keep the existing full canonical
inventory available to the source assembler: a planner-only probe inventory
omits helpers needed by this consumer.

The transitive closure retains `P114HPlan`, `P114HCase`, `P114RStmt`,
`p114h_plan`, its closure machinery, `p114h_prefix`, `p114h_rename`,
`p114h_rename_stmt`, `p114r_symbol` and `p112f_rename`. Their source owners remain
`back/qbe/model.bend`, `back/qbe/local-continuations.bend` and
`back/qbe/fused-regions.bend`; no duplicate factories or QBE emitter are added.
The `x192h_body` forward law and definition remain in the same new module.

The renderer retains original-scalar availability validation. Mode zero and a
complete direct public worker use the existing segment route. Other segments
query only `p114h_plan(segment,index,ready)`, never the extended callable view.
The original H readiness, hygiene, arity, incoming/result, node and eight-case
limits remain authoritative. Both worker and adapter must pass availability,
name hygiene and emission checks; any refusal selects the original segment.
`x192h_regions_enabled()` is the explicit off switch. Existing structured
function setup and parallel transfer lowering remain the implementation path.

All 30 declarations match frozen `recursive-source01` through
`recursive-source04` after canonical normalization. This candidate deliberately
uses base `x185_function_setup`; the V2 `scope` argument,
`x192hf_function_setup` and `x192hf_case_buffers` dependencies are absent.
Path facts are also absent. Optional scoped allocation can be evaluated and
integrated separately without changing this base capability's admission rules.

`recursive-maintained-closure.json` records input and patch hashes, frozen
source comparisons, retained declaration ownership and all six profile hashes.
Validation assembled a virtual overlay using the maintained source assembler;
it did not write production sources, check Bend, compile a target or execute a
workload. All five non-x86 profiles were byte-identical. The x86 source grew
from 1,766,338 to 1,803,092 bytes. This is a transport/closure check, not runtime
qualification. The separate control and measurement receipts remain necessary.

From the repository root, review and apply only after the integration decision:

```sh
git apply --check selfhost/tests/phase192/recursive-maintained-integration.patch
git apply selfhost/tests/phase192/recursive-maintained-integration.patch
```

The patch targets the current working-tree `program.bend` and manifest, retaining
other Phase 192 changes already present. If either input changes, recheck the
patch and regenerate closure evidence against the final maintained tree.
