# Small legacy cleanup

The audit found seven unused private helpers in the maintained legacy JavaScript
backend. Their deletion removes **42 physical / 34 code lines and seven
definitions** across two modules. Whole legacy modules remain necessary for
`--legacy-js`, the checked bootstrap and maintained compiler-image clients.

The root authorized this isolated deletion after the reference audit. The fresh
`checked-clean01` build and focused 36-probe gate now pass. The frozen host02
subject used for initial direct-image tests remains unchanged.

## Reference proof

The audit enumerated every definition in the 107 modules listed by
`selfhost/src/compiler.json`, then checked identifier references across that
complete source set. All seven names have no caller outside their own definition.
It additionally searched maintained host tools and bootstrap export configuration,
including string references. No consumer was found. Historical performance
proposals and saved source snapshots contain earlier copies; they are preserved.

| Module | Helper | Remaining source references | Physical / code lines |
| --- | --- | --- | ---: |
| `back/js/jpure.bend` | `j_pure_sigma_kind` | Definition only | 9 / 8 |
| `back/js/jpure.bend` | `j_instance_view_context` | Definition only | 4 / 3 |
| `back/js/jpure.bend` | `j_instance_clones_ready` | Definition and self recursion | 10 / 9 |
| `back/js/jpure.bend` | `j_instance_capture` | Definition and self recursion | 6 / 5 |
| `back/js/jpure.bend` | `j_map_sigma_quantity` | Definition only | 4 / 3 |
| `back/js/jpure.bend` | `j_map_closed_field_quantity` | Definition only | 5 / 3 |
| `back/js/array-view.bend` | `j_array_view_native` | Definition only | 4 / 3 |

Paths in the table are relative to `selfhost/src`. Counts include each removed
`@unsafe` annotation and separating blank line; code counts exclude blank lines
and comments. Before-edit module SHA256 values are:

- `jpure.bend`: `f625c524b34144d80330327ae9da0016c4bc171ed1f93e1679e43579ba21b71b`.
- `array-view.bend`: `3ff09fec7396c8bc8caf21fb8e63ecb22255e8e06d2a7896fe27e51f46524cb3`.

The deletion was applied only after matching those complete input hashes. Each
removed span consists of the named definition, its `@unsafe` annotation and its
following blank line; adjacent documentation and definitions remain unchanged.
The diff contains exactly 42 deletions, no additions, and passes whitespace
validation. After-edit SHA256 values are:

- `jpure.bend`: `b2dff40d2dd7f11f6c69641a8117f9c06ceb03fa02d86dfd136c39d33ed0f782`.
- `array-view.bend`: `f5d0e58c301604bb496847fe0e114b06e9c8b455b55ef47a7636a79f91f495a0`.

The active paths already use the quantity-aware `j_map_sigma_kind` and the shared
`j_array_effect_emit`. Deleting orphaned compatibility helpers does not replace
those paths or alter their predicates. The two self-recursive helpers have no
incoming external edge and therefore cannot be reached from a compiler entry.

## Deliberate retention and qualification

`jw_same_component` looks unused to a source-only scan, but the maintained
Phase45 worker-graph controller explicitly exports and calls it. It stays.
`jd_library` is retained as a direct-backend convenience entry, and no whole
legacy module or historical prototype is proposed for removal. The inherited
Phase6 files, release history and closed Phase54/55 evidence remain untouched.

Independent static review passed the exact edited hashes: it confirmed the
seven-definition-only diff, no manifest callers, no maintained host/test
references and no intersection with bootstrap exports. Historical source
proposals remain separate evidence; similarly named live helpers are untouched.

## Checked qualification

The [qualification receipt](../../selfhost/tools/performance/phase56/evidence/cleanup-qualification.json)
binds `selfhost/build/phase56/checked-clean01/{attempt,build}.json`, its bootstrap
source and `validation-001/report.json`. The supervised build plus focused gate
completed in **60.902 seconds**, with all **36 probes passing**, zero exact
differences and zero discrepancies. This is one bounded workflow observation,
not a throughput comparison.

Both API images are byte-identical to host02: the original checked API retains
SHA256 `79482fb656b9dbe1be44117ed2764271fb18b423bb59b79de90dd278e028060f`,
and the selected derived API retains
`cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62`.
Both runtimes and all 35 frozen host-tool files also retain exact bytes. The
receipt rehashes all 306 frozen files in each attempt and finds only the two
intended changed modules: **105 of 107 Bend modules remain unchanged**.

Fresh manifest accounting gives **26,244 physical / 21,583 code lines, 3,012
definitions, 100 types and 107 modules**. Existing behavior and dated timing
evidence apply to the unchanged selected linked API, runtime and host bytes;
there is no new user-program timing measurement or speedup claim here. Direct
image self-emission and fresh self-check are separate Phase56 gates.
