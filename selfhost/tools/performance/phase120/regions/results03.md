# Region03: constructor-ID admission

The CtorId-only change activates the intended numeric call. In both
`$product.nearest` and `$direct.nearest.t`, one of two calls to `isect5` is copied
into the caller. Region02 rejected its immutable constructor-ID operand in a
Boolean decoder. The original verifier requires a known catalogue entry and an
integer width, and the original renderer resolves that entry to its integer ID.

Root's three-round screen completed all 27 observations with exact outputs.
These are matched comparisons with Phase118 safe03, not a matched region02/03
comparison:

| Case | Safe03 median | Region03 median | Candidate / parent |
|---|---:|---:|---:|
| active ray | 1705 ms | 1363 ms | 0.7994 |
| raytrace | 1884 ms | 1842 ms | 0.9777 |
| numeric recurrence | 419 ms | 417 ms | 0.9952 |

The recurrence QBE remains unchanged from the local-lane ablation; its timing
variation is not evidence of a new region benefit. This screen does not establish
whole-suite performance or promotion. Both public and private signatures still
transport integer words, with all generic word results preserved.

The active-ray nearest body shrinks from 3150 to 2927 QBE lines including its
header. It has three copied sites: first `isect5`, then two scalar selectors.
There is no site3. The second identical `isect5` remains after these sites, so the
remaining 1024-node budget is the blocker, not the four-site limit or a different
callee admission. A separate general work-based selection policy could test this
competition; this candidate does not change policy or budgets.

The native nearest body grows from 553 to 596 instructions versus region02,
while stack references fall from 150 to 134. Static calls rise from 6 to 10:
copying `isect5` exposes its helper/failure calls, and two selectors now remain
uncopied. Thus raw whole-function call counts do not measure successful-path
call removal. The separate `isect5` body is unchanged at 129 instructions.

The compound reflected CtorId control failed independently of the native screen.
Its fixture inserted catalogue kind `ctor`; the renderer requires `N111Id`.
`ctor-controls02.bend` uses the real `p111q_constructor_ids` producer and reports
nine separate conditions, including rejection of the old wrong-kind rendering.
The original failed receipt is preserved; this report does not claim the repaired
control has executed.

Exact source, runtime, screen, QBE and disassembly pins are in `results03.json`.
Machine inspection used root's read-only `machine.py`, `nm` and `objdump` on
already-built products. No compiler or native program was run by this author.
