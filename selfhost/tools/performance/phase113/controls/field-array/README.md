# Field and array representation controls

`source-manifest01.json` freezes four new actual Bend sources, two unchanged
upstream regressions and complete independently fixed outputs. No target was
executed by the control author. The original checker must accept newly authored
sources before they can count as candidate conformance tests.

| Control | Observation |
|---|---|
| scalar-array-wrap | U32/Bool/Char/F32 cells, wrapped indices, swap/get/set/size |
| shared-array-capture | A captured shared handle observes mutation after the other root is released |
| string-array-owners | Removed/get String owners survive their array and external aliases survive |
| mixed-record-owner | Shared scalar/String record preserves field order, wrap and allocated text |
| upstream-generic-cell | Unchanged generic/dependent layout and affine closure regression |
| upstream-borrowed-generic | Unchanged borrowed array cell crossing an opaque generic layout |

The manifest records the independent rationale for each expected output.
`prepare-jobs.py` accepts the same matched direct-API arguments as the inliner
source preparer, plus `--names NAME ...` for a subset. For an explicit
`p113a_*` array pipeline, root must use the corresponding array-aware staged
transport instead. The frozen preparer uses the direct pipeline.

Output equality does not establish whether a scalar/unshared-array certificate
was accepted or whether field facts actually removed ownership calls. Record
those admission/shape observations separately. Shared or opaque cases must
retain legal fallback behavior. These fixtures do not add standalone source
coverage for an erased constructor field or a shadowed scalar type name; the
separate reflected field-position controls address the former boundary.
