# P68-018: omit eager wrappers for proven-unshared user constructors

Registered 2026-10-11 before generated-C intervention. Candidate20's conservative
ownership certificate permits duplication only of trusted Base array-free types.
It therefore also excludes sharing user constructors, closures containing them,
or Base containers containing them. Packed array admission prevents implicit
duplication of a user-valued seed. Unknown foreign and proof transport decline.

Hypothesis: use the same certificate to omit `rfc_seal` wrappers for encoded
user-constructor tags, keeping Base constructors and every actual keep/drop
operation unchanged. First alter only saved candidate20 C for tree, Map and
lexer, retaining exact literal edits and source hashes. Require independent
oracles and alternating qualified same-work measurements. No production change
is selected from a static wrapper count or the array result alone.

If useful, expose a separate policy macro and user-constructor table permission.
Validate copied user records/trees and captures as refusal witnesses, plus raw
and foreign fallback. Refuse if hidden sharing, invalid RFC assumptions, output
mismatch or poor timings invalidate the mechanism. This is not lexical storage
reuse; it prevents creation of an unnecessary reference-count allocation.

## Outcome: not selected

Saved-C diagnostic02 completed three alternating observations per role/family,
all independent oracles correct. Median baseline/candidate milliseconds:
tree 647/597 (1.084× faster), Map 704/710 (unchanged control), lexer 569/585
(0.973×). This small mixed benefit does not justify a new compiler policy now.
Map has no encoded user constructors; the initial preparation assertion failed
before compiling or running anything. That failed script/source is retained in
`selfhost/build/phase68/user-seal-diagnostic01`. Diagnostic02 retains the exact
interventions, source/binary pins, build receipts and all 18 observations.

No production constructor-sealing change was made. The proof may be useful
later, but this outcome does not support a broad runtime gain.
