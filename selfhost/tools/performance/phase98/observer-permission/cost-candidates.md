# Observer planning cost candidates

These are **unqualified isolated source derivatives**, prepared offline. They
change compiler planning work, not intended generated code. Root owns targets.

Frozen parent: `permission-tag-source02/compiler.bend`, SHA256
`59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714`.
The manifest is `selfhost/build/phase98/observer-cost-sources01/manifest.json`.
Each candidate directory contains `compiler.bend` and `changes.json` with exact
sequential replay from authenticated D04, plus inverse replay and parent pins.

| Directory | Candidate SHA256 prefix | Delta from parent | Change |
|---|---|---:|---|
| `redirect` | `873e71abcc743621` | +3 lines, -26 bytes | Only construct redirect text for matching workers; reuse full original worker otherwise. |
| `scalar-specs` | `838a5409dad5d8f9` | +56 lines | Compute immutable scalar schema descriptors once per permitted route. |
| `both` | `a0254c279cab150a` | +59 lines | The two independent changes together. |

`redirect` retains list order and visits all entries, including duplicate names.
Its hit preserves parameters, code segments/fresh/error/dependencies and shape;
only code body prefix and worker dependency prefix change, exactly as before.
Misses return the original complete worker. No name cleaning or comparator
normalization is introduced: the original `p88_string_eq` remains in use.

The cached schema call graph is:

```text
no_route (permission=True only): compute nol_scalar_specs(book, book) once
  no_route_names_cached
    no_route_one_cached
      no_schema_cached
        nol_params_cached <-> nol_param_head_cached / nol_param_type_cached
          nol_result_cached
            nol_finish_cached: append passed scalarSpecs on success
      no_route_schema_cached -> unchanged no_route_plan / analysis / emission
```

The six original schema helpers and three original route helpers remain exact;
their public signatures and direct-call behavior are preserved. The added
helpers copy those bodies, changing only internal calls, a threaded final
argument and the repeated descriptor expression. No private book-cache format,
observer residual, provider certificate, representation flag or runtime changes.

The cache is eagerly computed once inside the allowed route, even if all later
schemas refuse. Per-schema old computation occurred only on schema success.
This is value-equivalent for the valid checked immutable book, but may add cost
to programs with no eligible schemas. Sharing the descriptor list can change
allocation costs. Those are measurement questions, not guaranteed improvements.

First use narrow exported/extracted APIs for exact full-value comparisons:
`no_scalar_redirect` on empty/miss/hit/duplicate/heterogeneous workers; and
`no_schema_cached(book,d,n,nol_scalar_specs(book,book)) == no_schema(book,d,n)`
on admitted and refused layouts, aliases, enums, scalar/product returns and
fresh/telescope limits. Then compare full C plus diagnostics on the **same**
program inputs through parent and candidate. Comparing their different own
compiler sources is not an identity check. Only after equivalence should a
native image or timing campaign run.

The data producer is `prepare-cost-candidates-v4.py`. A new invocation requires
a fresh `--out` beneath `selfhost/build/phase98`; never overwrite the frozen
directory. Versions1/2 failed authentication assumptions about nonunique/empty
historical recipe spans before writing output; version3 has an indentation
error. They are preserved. V4 authenticates exact offsets under the full pinned
source hash and inverse replay. No compiler/program target has been run by the
preparer.

Root subsequently ran `cost-controls.py`, preserving its malformed NC_Text
fixture failure. `cost-controls-v2.py` authenticates/reuses those admitted APIs
and fixes only the fixture and structural text checks. Its completed
`observer-cost-controls02/report.json` has105 full worker-list cases,60 full
schema cases and three exact C/diagnostic comparisons. The independent redirect
whole-list law passes separately. Native compiler image qualification and
performance remain separate pending work; these gates do not establish a gain.
