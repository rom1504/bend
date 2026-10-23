# Local reshape integration review

Source-only review of `local-reshape/manifest03.json`, its three Bend modules,
`prepare-integration.py` and `runtime-prototype.c`; no targets or source changes.

**Blocker found:** `p126lr_select` passes the original typed constructor spelling
directly as `N111CtorId`. Query02's actual warp_zip match is `Node`, but saved
`p126-combined17-emit/tree-bitonic.ssa:17212` declares CID151 as
`$ctor.78_111_100_101_`. Native constructor indexing uses this exact encoded
identity. Resolve with `nc_ctor_identity(book, nm(j_strip(dv(d))))` at the native
selection boundary; keep the source recognizer on raw names. The author is
preparing versioned integration-v02/manifest04; that correction was not included
in the reviewed manifest03 bytes.

All manifest03 module/runtime hashes match. Each of the three previous hook
implementations survives as a byte-identical alias after declaration renaming
against combined-source17. The preparer authenticates these aliases, the exact
recognizer and module pins, admits only the three listed replacements, and
checks every other original declaration unchanged. Runtime compilation/linking
and checked-source qualification remain separate root-owned gates.

No additional concrete defect found. The wrapper accepts only the existing
successful public two-argument/full-Term candidate, rejects either new-local
collision across parameters and all branch declarations, and retains the
entire prior body on zero. The U64 comparison produces the existing U32 branch
condition. The import gate checks the exact state argument, four argument
widths/count, a resolvable constructor reference of arity2, and a U64 result.

The helper declines before mutation for RFC/shared, static, mismatching or
identical roots. On accepted raw dynamic distinct roots it snapshots all four
fields, transfers each exactly once into the transposed shells, follows the
selected constructor's hot/cold sealing policy, and builds the outer node with
the existing constructor helper. No consumed shell is freed and then reused.
These ownership arguments rely on authenticated checked inputs and the pinned
runtime representation; they do not license arbitrary reflected calls or raw
runtime nodes. The source equation has no intervening effect; miss branches,
other candidates and flattened private products retain the existing path.
